import Stripe from "npm:stripe@13.11.0";
import { handleBillingError, PORTAL_RETURN_URL } from "../_shared/billing.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

/**
 * Portal do Stripe: o assinante troca o cartão, vê as faturas e cancela sem
 * sair para o suporte. O customer e a URL de retorno vêm sempre do servidor,
 * nunca do corpo da requisição.
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { user } = await getUser(req);

    const serviceClient = getServiceClient();
    const { data: sub } = await serviceClient
      .from("subscriptions")
      .select("stripe_customer_id")
      .eq("user_id", user.id)
      .maybeSingle();

    if (!sub?.stripe_customer_id) {
      return errorResponse("Nenhuma assinatura encontrada para esta conta.", 404);
    }

    // Não usar a página de sucesso do checkout aqui: quem acabou de cancelar
    // leria "Pagamento confirmado".
    const session = await stripe.billingPortal.sessions.create({
      customer: sub.stripe_customer_id,
      return_url: PORTAL_RETURN_URL,
    });

    return jsonResponse({ url: session.url });
  } catch (err) {
    return handleBillingError(err, "create-billing-portal-session");
  }
});
