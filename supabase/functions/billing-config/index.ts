/**
 * Configuração vigente da assinatura, lida do Stripe em tempo de chamada.
 *
 * Existe para eliminar a única forma de a tela mentir: preço e período de
 * teste ficavam escritos na PlansScreen enquanto quem cobra é o Stripe. Mudar
 * o preço no dashboard (ou o secret STRIPE_TRIAL_DAYS) fazia a UI anunciar um
 * valor e o checkout cobrar outro, sem nenhum sinal.
 *
 * A fonte da verdade do preço é o próprio Price do Stripe — o mesmo objeto que
 * create-checkout-session usa na sessão. Do trial vale trialPeriodDays(), o
 * mesmo helper que a criação da sessão consulta.
 *
 * `trial_dias` já vem descontado do caso "esta conta não tem mais direito a
 * teste": create-checkout-session não repete o período para quem já assinou
 * uma vez (stripe_subscription_id gravado), então anunciar 15 dias ali seria
 * outra divergência entre a tela e a cobrança.
 *
 * Só existe plano mensal. Se o Price configurado não for mensal recorrente, a
 * function falha em vez de exibir um período inventado.
 */
import Stripe from "npm:stripe@13.11.0";
import { monthlyPriceId, trialPeriodDays, handleBillingError, BillingError } from "../_shared/billing.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, corsHeaders } from "../_shared/response.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { user } = await getUser(req);

    const price = await stripe.prices.retrieve(monthlyPriceId());

    if (!price.active) {
      throw new BillingError("Plano indisponível no momento. Tente novamente mais tarde.", 503);
    }
    if (price.recurring?.interval !== "month" || price.recurring.interval_count !== 1) {
      // Configuração errada do ambiente, não erro do usuário: o app só sabe
      // desenhar assinatura mensal.
      console.error("[billing-config] STRIPE_PRICE_MONTHLY não é mensal:", price.recurring);
      throw new BillingError("Plano indisponível no momento. Tente novamente mais tarde.", 503);
    }
    if (price.unit_amount === null) {
      console.error("[billing-config] price sem unit_amount (preço graduado?):", price.id);
      throw new BillingError("Plano indisponível no momento. Tente novamente mais tarde.", 503);
    }

    const serviceClient = getServiceClient();
    const { data: sub } = await serviceClient
      .from("subscriptions")
      .select("stripe_subscription_id")
      .eq("user_id", user.id)
      .maybeSingle();

    const jaUsouTeste = Boolean(sub?.stripe_subscription_id);

    return jsonResponse({
      intervalo: "mensal",
      valor_centavos: price.unit_amount,
      moeda: price.currency,
      trial_dias: jaUsouTeste ? 0 : trialPeriodDays(),
      ja_usou_teste: jaUsouTeste,
    });
  } catch (err) {
    return handleBillingError(err, "billing-config");
  }
});
