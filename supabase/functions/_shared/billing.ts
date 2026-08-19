/**
 * Preços e URLs de retorno do Stripe — resolvidos no servidor.
 *
 * Secrets esperados (supabase secrets set ...):
 *   STRIPE_PRICE_MONTHLY, STRIPE_PRICE_ANNUAL
 * Opcionais, para quando o site tiver domínio próprio:
 *   CHECKOUT_SUCCESS_URL, CHECKOUT_CANCEL_URL
 */

import { errorResponse } from "./response.ts";

const returnPage = `${Deno.env.get("SUPABASE_URL")}/functions/v1/checkout-return`;

export const SUCCESS_URL = Deno.env.get("CHECKOUT_SUCCESS_URL") ?? `${returnPage}?status=sucesso`;
export const CANCEL_URL = Deno.env.get("CHECKOUT_CANCEL_URL") ?? `${returnPage}?status=cancelado`;

/** Volta do portal de cobrança: pode ser assinatura, troca de cartão ou cancelamento. */
export const PORTAL_RETURN_URL = `${returnPage}?status=portal`;

/** Erro cuja mensagem pode ser mostrada ao usuário. */
export class BillingError extends Error {
  constructor(message: string, readonly status = 400) {
    super(message);
    this.name = "BillingError";
  }
}

export function priceIdFor(plan: "monthly" | "annual"): string {
  const priceId = Deno.env.get(plan === "monthly" ? "STRIPE_PRICE_MONTHLY" : "STRIPE_PRICE_ANNUAL");
  if (!priceId) throw new BillingError("Plano indisponível no momento. Tente novamente mais tarde.");
  return priceId;
}

/**
 * O app mostra `error` em um Alert, então devolver err.message cru vazaria a
 * resposta do provedor — uma StripeError carrega o modo da conta, o prefixo
 * da chave e URLs internas do dashboard. Só mensagem nossa sai daqui; o
 * detalhe fica no log da function.
 */
export function handleBillingError(err: unknown, contexto: string): Response {
  if (err instanceof BillingError) return errorResponse(err.message, err.status);
  if (err instanceof Error && err.message === "Unauthorized") {
    return errorResponse("Não autorizado", 401);
  }
  if (err instanceof Error && err.name === "ZodError") {
    return errorResponse("Dados inválidos.", 400);
  }

  console.error(`[${contexto}]`, err instanceof Error ? err.message : err);
  return errorResponse("Não foi possível concluir a operação de pagamento. Tente novamente em instantes.", 502);
}
