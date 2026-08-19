import Stripe from "npm:stripe@13.11.0";
import { CreateCheckoutSchema } from "../_shared/schemas.ts";
import { priceIdFor, handleBillingError, SUCCESS_URL, CANCEL_URL } from "../_shared/billing.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { user } = await getUser(req);
    const { plan } = CreateCheckoutSchema.parse(await req.json());

    // Buscar ou criar Stripe Customer
    const serviceClient = getServiceClient();
    const { data: sub } = await serviceClient
      .from("subscriptions")
      .select("stripe_customer_id, stripe_subscription_id, plano, status")
      .eq("user_id", user.id)
      .maybeSingle();

    // Só 'canceled' significa que não existe assinatura viva no Stripe.
    // past_due é dunning em andamento: abrir um checkout novo criaria uma
    // segunda assinatura no mesmo customer e cobraria duas vezes. Esse caso
    // vai para o portal de cobrança trocar o cartão.
    if (sub?.plano === "premium" && sub.status !== "canceled") {
      return errorResponse(
        sub.status === "past_due"
          ? "Sua assinatura está com pagamento pendente. Atualize a forma de pagamento em Gerenciar assinatura."
          : "Você já tem uma assinatura ativa.",
        409,
      );
    }

    let customerId = sub?.stripe_customer_id;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        metadata: { supabase_user_id: user.id },
      });
      customerId = customer.id;

      await serviceClient
        .from("subscriptions")
        .update({ stripe_customer_id: customerId })
        .eq("user_id", user.id);
    }

    // O Stripe não deduplica trial: sem esta checagem daria para assinar,
    // cancelar dentro dos 7 dias e reabrir o teste indefinidamente. O
    // stripe_subscription_id fica gravado mesmo após o cancelamento e é o
    // registro de que esta conta já usou o período de teste.
    const jaUsouTeste = Boolean(sub?.stripe_subscription_id);

    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: "subscription",
      payment_method_types: ["card"],
      line_items: [{ price: priceIdFor(plan), quantity: 1 }],
      success_url: SUCCESS_URL,
      cancel_url: CANCEL_URL,
      subscription_data: {
        ...(jaUsouTeste ? {} : { trial_period_days: 7 }),
        metadata: { user_id: user.id },
      },
      metadata: { user_id: user.id },
    });

    return jsonResponse({ url: session.url, session_id: session.id });
  } catch (err) {
    return handleBillingError(err, "create-checkout-session");
  }
});
