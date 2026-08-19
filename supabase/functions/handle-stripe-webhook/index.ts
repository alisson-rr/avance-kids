import Stripe from "npm:stripe@13.11.0";
import { getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse } from "../_shared/response.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

const endpointSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

type SubscriptionStatus = "active" | "trialing" | "past_due" | "canceled";

/**
 * O enum do banco tem 4 valores e o Stripe tem 8. Gravar o status cru
 * estouraria o enum e derrubaria o webhook. Só `active` e `trialing` liberam
 * o conteúdo premium; o resto fica em `past_due` (mantém a assinatura viva
 * para uma nova cobrança) ou `canceled` quando é terminal.
 */
const STATUS_MAP: Record<string, SubscriptionStatus> = {
  active: "active",
  trialing: "trialing",
  past_due: "past_due",
  unpaid: "past_due",
  incomplete: "past_due",
  canceled: "canceled",
  incomplete_expired: "canceled",
  paused: "canceled",
};

const toStatus = (stripeStatus: string): SubscriptionStatus =>
  STATUS_MAP[stripeStatus] ?? "past_due";

/** Únicos status que liberam conteúdo pago — espelha has_premium_access(). */
const ACCESS_STATUSES: SubscriptionStatus[] = ["active", "trialing"];

const toIso = (seconds: number | null | undefined): string | null =>
  typeof seconds === "number" && Number.isFinite(seconds)
    ? new Date(seconds * 1000).toISOString()
    : null;

Deno.serve(async (req: Request) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) return errorResponse("Missing stripe-signature", 400);

  const body = await req.text();
  let event: Stripe.Event;

  try {
    event = await stripe.webhooks.constructEventAsync(body, signature, endpointSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", (err as Error).message);
    return errorResponse("Webhook signature verification failed", 400);
  }

  const supabase = getServiceClient();

  /**
   * Erro de escrita vira 500 para o Stripe reenviar o evento.
   *
   * `onlySubscription` existe porque um mesmo customer pode ter mais de uma
   * assinatura no Stripe (ex.: uma em dunning e outra nova). Sem esse filtro,
   * o cancelamento da assinatura velha rebaixaria para free quem está pagando
   * na nova. O `is.null` cobre o intervalo entre o checkout e o primeiro
   * evento, quando ainda não sabemos qual assinatura é a nossa.
   */
  const updateSubscription = async (
    match: { column: "user_id" | "stripe_customer_id"; value: string },
    patch: Record<string, unknown>,
    onlySubscription?: string,
  ) => {
    let query = supabase.from("subscriptions").update(patch).eq(match.column, match.value);
    if (onlySubscription) {
      query = query.or(
        `stripe_subscription_id.is.null,stripe_subscription_id.eq.${onlySubscription}`,
      );
    }
    const { data, error } = await query.select("user_id");

    if (error) throw new Error(`subscriptions.update: ${error.message}`);
    if (!data?.length) {
      // Cliente do Stripe sem assinatura no banco: reenviar não resolve.
      console.warn(`[${event.type}] nenhuma assinatura para ${match.column}`);
    }
    return data ?? [];
  };

  try {
    switch (event.type) {
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session;
        const userId = session.metadata?.user_id;
        const subscriptionId = session.subscription as string | null;
        if (!userId || !subscriptionId) {
          console.warn("checkout.session.completed sem user_id ou subscription");
          break;
        }

        // Buscar o estado real no Stripe em vez de assumir 'trialing': a
        // entrega pode chegar fora de ordem (o Stripe reenvia por ~3 dias),
        // e gravar um status inventado deixaria a conta liberada para sempre
        // se nenhum evento posterior chegasse.
        const stripeSub = await stripe.subscriptions.retrieve(subscriptionId);
        const status = toStatus(stripeSub.status);
        const liberado = ACCESS_STATUSES.includes(status);

        const rows = await updateSubscription(
          { column: "user_id", value: userId },
          {
            stripe_customer_id: session.customer as string,
            stripe_subscription_id: subscriptionId,
            plano: liberado ? "premium" : "free",
            status,
            trial_start: toIso(stripeSub.trial_start),
            trial_end: toIso(stripeSub.trial_end),
            current_period_start: toIso(stripeSub.current_period_start),
            current_period_end: toIso(stripeSub.current_period_end),
          },
        );

        // Sem isso, quem já concluiu tudo que era gratuito paga e continua
        // sem nenhuma atividade ativa (ver unlock_available_plans).
        if (rows.length && liberado) {
          const { error } = await supabase.rpc("unlock_available_plans", { p_user_id: userId });
          if (error) throw new Error(`unlock_available_plans: ${error.message}`);
        }
        break;
      }

      case "invoice.paid": {
        const invoice = event.data.object as Stripe.Invoice;
        const customerId = invoice.customer as string;

        const { data: sub, error } = await supabase
          .from("subscriptions")
          .select("user_id")
          .eq("stripe_customer_id", customerId)
          .maybeSingle();

        if (error) throw new Error(`subscriptions.select: ${error.message}`);
        if (!sub) {
          console.warn("invoice.paid para customer sem assinatura no banco");
          break;
        }

        // uq_payment_intent garante idempotência, mas NULL não colide com
        // NULL no Postgres: sem payment_intent (fatura de teste, valor zero)
        // não há o que registrar.
        const paymentIntentId = invoice.payment_intent as string | null;
        if (paymentIntentId) {
          const { error: payErr } = await supabase
            .from("payment_history")
            .upsert(
              {
                user_id: sub.user_id,
                stripe_payment_intent_id: paymentIntentId,
                amount_cents: invoice.amount_paid,
                currency: invoice.currency,
                status: "succeeded",
                paid_at: toIso(invoice.status_transitions?.paid_at) ?? new Date().toISOString(),
              },
              { onConflict: "stripe_payment_intent_id" },
            );
          if (payErr) throw new Error(`payment_history.upsert: ${payErr.message}`);
        }

        const rows = await updateSubscription(
          { column: "stripe_customer_id", value: customerId },
          {
            current_period_start: toIso(invoice.period_start),
            current_period_end: toIso(invoice.period_end),
            plano: "premium",
            status: "active",
          },
          invoice.subscription as string | undefined,
        );

        // Cobre a renovação que reativa uma conta que estava sem acesso.
        if (rows.length) {
          const { error: rpcErr } = await supabase.rpc("unlock_available_plans", {
            p_user_id: sub.user_id,
          });
          if (rpcErr) throw new Error(`unlock_available_plans: ${rpcErr.message}`);
        }
        break;
      }

      case "invoice.payment_failed": {
        const invoice = event.data.object as Stripe.Invoice;
        await updateSubscription(
          { column: "stripe_customer_id", value: invoice.customer as string },
          { status: "past_due" },
          invoice.subscription as string | undefined,
        );
        break;
      }

      case "customer.subscription.updated": {
        const sub = event.data.object as Stripe.Subscription;
        const status = toStatus(sub.status);
        await updateSubscription(
          { column: "stripe_customer_id", value: sub.customer as string },
          {
            status,
            plano: ACCESS_STATUSES.includes(status) ? "premium" : "free",
            current_period_start: toIso(sub.current_period_start),
            current_period_end: toIso(sub.current_period_end),
            trial_start: toIso(sub.trial_start),
            trial_end: toIso(sub.trial_end),
          },
          sub.id,
        );
        break;
      }

      case "customer.subscription.deleted": {
        const sub = event.data.object as Stripe.Subscription;
        // stripe_subscription_id fica gravado: é o registro de que esta conta
        // já usou o período de teste (ver create-checkout-session).
        await updateSubscription(
          { column: "stripe_customer_id", value: sub.customer as string },
          { status: "canceled", plano: "free" },
          sub.id,
        );
        break;
      }
    }

    return jsonResponse({ received: true });
  } catch (err) {
    // Sem detalhe do provedor na resposta; o log fica no painel do Supabase.
    console.error(`Webhook ${event.type} falhou:`, (err as Error).message);
    return errorResponse("Internal processing error", 500);
  }
});
