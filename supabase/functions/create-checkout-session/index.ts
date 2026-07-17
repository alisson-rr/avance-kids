import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@13.11.0?target=deno";
import { CreateCheckoutSchema } from "../_shared/schemas.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const body = CreateCheckoutSchema.parse(await req.json());

    // Buscar ou criar Stripe Customer
    const serviceClient = getServiceClient();
    const { data: sub } = await serviceClient
      .from("subscriptions")
      .select("stripe_customer_id")
      .eq("user_id", user.id)
      .single();

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

    // Criar sessão de checkout
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: "subscription",
      payment_method_types: ["card"],
      line_items: [{ price: body.price_id, quantity: 1 }],
      success_url: body.success_url,
      cancel_url: body.cancel_url,
      subscription_data: {
        trial_period_days: 7,
        metadata: { user_id: user.id },
      },
      metadata: { user_id: user.id },
    });

    return jsonResponse({ url: session.url, session_id: session.id });
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
