import { getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse } from "../_shared/response.ts";
import { stripe, type Stripe } from "../_shared/stripe.ts";

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

  try {
    let payload: Record<string, unknown> = {};

    switch (event.type) {
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session;
        const userId = session.metadata?.user_id;
        const subscriptionId = session.subscription as string | null;
        if (!userId || !subscriptionId) {
          break;
        }

        // Buscar o estado real no Stripe em vez de assumir 'trialing': a
        // entrega pode chegar fora de ordem (o Stripe reenvia por ~3 dias),
        // e gravar um status inventado deixaria a conta liberada para sempre
        // se nenhum evento posterior chegasse.
        const stripeSub = await stripe.subscriptions.retrieve(subscriptionId);
        const status = toStatus(stripeSub.status);
        const liberado = ACCESS_STATUSES.includes(status);

        payload = {
          user_id: userId,
          customer_id: session.customer as string,
          subscription_id: subscriptionId,
          plano: liberado ? "premium" : "free",
          status,
          trial_start: toIso(stripeSub.trial_start),
          trial_end: toIso(stripeSub.trial_end),
          current_period_start: toIso(stripeSub.current_period_start),
          current_period_end: toIso(stripeSub.current_period_end),
        };
        break;
      }

      case "invoice.paid": {
        const invoice = event.data.object as Stripe.Invoice;
        payload = {
          customer_id: invoice.customer as string,
          subscription_id: invoice.subscription as string | null,
          payment_intent_id: invoice.payment_intent as string | null,
          amount_cents: invoice.amount_paid,
          currency: invoice.currency,
          paid_at: toIso(invoice.status_transitions?.paid_at) ?? new Date().toISOString(),
          current_period_start: toIso(invoice.period_start),
          current_period_end: toIso(invoice.period_end),
        };
        break;
      }

      case "invoice.payment_failed": {
        const invoice = event.data.object as Stripe.Invoice;
        payload = {
          customer_id: invoice.customer as string,
          subscription_id: invoice.subscription as string | null,
        };
        break;
      }

      case "customer.subscription.updated": {
        const sub = event.data.object as Stripe.Subscription;
        const status = toStatus(sub.status);
        payload = {
          customer_id: sub.customer as string,
          subscription_id: sub.id,
          status,
          plano: ACCESS_STATUSES.includes(status) ? "premium" : "free",
          current_period_start: toIso(sub.current_period_start),
          current_period_end: toIso(sub.current_period_end),
          trial_start: toIso(sub.trial_start),
          trial_end: toIso(sub.trial_end),
        };
        break;
      }

      case "customer.subscription.deleted": {
        const sub = event.data.object as Stripe.Subscription;
        // stripe_subscription_id fica gravado: é o registro de que esta conta
        // já usou o período de teste (ver create-checkout-session).
        payload = {
          customer_id: sub.customer as string,
          subscription_id: sub.id,
        };
        break;
      }
    }

    /**
     * Uma única chamada ao Postgres registra o event.id e aplica o efeito na
     * mesma transação. Se o efeito falhar, o marcador também sofre rollback.
     * Em entregas concorrentes, a PK espera a primeira transação terminar e
     * então gera 23505 somente se ela tiver sido concluída com sucesso.
     */
    const { data, error } = await supabase.rpc("process_stripe_webhook_event", {
      p_event_id: event.id,
      p_event_type: event.type,
      p_payload: payload,
    });

    const duplicateEvent = error?.code === "23505"
      && error.message.includes("stripe_webhook_events_pkey");
    if (duplicateEvent) {
      return jsonResponse({ received: true, duplicate: true });
    }
    if (error) throw new Error(`process_stripe_webhook_event: ${error.message}`);

    const result = data as { warning?: string | null } | null;
    if (result?.warning) console.warn(result.warning);

    return jsonResponse({ received: true });
  } catch (err) {
    // Sem detalhe do provedor na resposta; o log fica no painel do Supabase.
    console.error(`Webhook ${event.type} falhou:`, (err as Error).message);
    return errorResponse("Internal processing error", 500);
  }
});
