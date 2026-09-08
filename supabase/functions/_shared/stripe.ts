import Stripe from "npm:stripe@13.11.0";

// O stripe@13.11.0 declara "2023-08-16" como LatestApiVersion em types/lib.d.ts.
// billing-config já usava essa versão e não depende de comportamento exclusivo
// dela: a function apenas lê um Price. Compartilhar o cliente preserva esse
// comportamento e mantém a configuração compatível com os tipos do SDK.
export const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-08-16",
  httpClient: Stripe.createFetchHttpClient(),
});

export type { Stripe };
