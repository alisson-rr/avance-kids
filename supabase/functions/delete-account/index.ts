/**
 * Exclusão definitiva da própria conta.
 *
 * O usuário a ser excluído vem SEMPRE do JWT — nunca do body. Aceitar um
 * `user_id` no corpo transformaria esta function em um endpoint para apagar a
 * conta de qualquer outra pessoa.
 *
 * Ordem das etapas (idempotente: se qualquer passo falhar, chamar de novo
 * retoma de onde parou):
 *   1. cancela a assinatura no Stripe — a conta some do banco, o cartão não
 *      pararia de ser cobrado sozinho;
 *   2. apaga os arquivos do usuário no bucket `avatars` (Storage não tem FK,
 *      então nada é removido em cascata);
 *   3. grava o log pseudonimizado em account_deletions;
 *   4. remove o usuário do Auth — o CASCADE leva profile, crianças, respostas,
 *      planos, sessões, tentativas, assinatura e aceites (ver migration-07).
 *
 * `payment_history` permanece com user_id = NULL (retenção fiscal prevista nos
 * próprios Termos).
 */
import Stripe from "npm:stripe@13.11.0";
import { z } from "npm:zod@3.22.4";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

const AVATAR_BUCKET = "avatars";

// Confirmação explícita: evita que um POST acidental (retry de rede, deep link,
// botão duplo) apague a conta. O app manda a string que o usuário digitou.
const InputSchema = z.object({
  confirmacao: z.literal("EXCLUIR"),
});

// apiVersion "2023-08-16" e não "2023-10-16" como nas outras functions de
// billing: é a versão que os tipos do stripe@13.11.0 declaram como
// LatestApiVersion, então "2023-10-16" não passa em `deno check`. As demais
// functions ficaram como estavam para não mexer no comportamento do checkout
// (ver docs/DEPENDENCIAS-E-PENDENCIAS.md).
const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
const stripe = stripeKey
  ? new Stripe(stripeKey, { apiVersion: "2023-08-16", httpClient: Stripe.createFetchHttpClient() })
  : null;

async function sha256(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/** Cancela a assinatura viva. Assinatura já cancelada/inexistente não é erro. */
async function cancelarAssinatura(subscriptionId: string): Promise<void> {
  if (!stripe) {
    console.error("[delete-account] STRIPE_SECRET_KEY ausente; assinatura não cancelada", subscriptionId);
    return;
  }
  try {
    await stripe.subscriptions.cancel(subscriptionId);
  } catch (err) {
    const code = (err as { code?: string })?.code;
    if (code === "resource_missing") return;
    throw err;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { user } = await getUser(req);
    InputSchema.parse(await req.json().catch(() => ({})));

    const serviceClient = getServiceClient();

    // 1. Stripe
    const { data: sub } = await serviceClient
      .from("subscriptions")
      .select("stripe_customer_id, stripe_subscription_id, plano, status")
      .eq("user_id", user.id)
      .maybeSingle();

    if (sub?.stripe_subscription_id && sub.status !== "canceled") {
      await cancelarAssinatura(sub.stripe_subscription_id);
    }

    // 2. Storage — os uploads ficam em `avatars/{user_id}/arquivo.jpg`
    //    (apps/mobile/src/services/storage.ts), um único nível.
    const { data: arquivos } = await serviceClient.storage.from(AVATAR_BUCKET).list(user.id);
    let arquivosRemovidos = 0;

    if (arquivos && arquivos.length > 0) {
      const paths = arquivos.map((f) => `${user.id}/${f.name}`);
      const { error: removeErr } = await serviceClient.storage.from(AVATAR_BUCKET).remove(paths);
      if (removeErr) {
        console.error("[delete-account] falha ao remover avatares", removeErr.message);
      } else {
        arquivosRemovidos = paths.length;
      }
    }

    // 3. Log — antes do delete, enquanto os dados ainda existem.
    const { error: logErr } = await serviceClient.from("account_deletions").upsert(
      {
        user_id: user.id,
        email_hash: user.email ? await sha256(user.email.toLowerCase()) : null,
        stripe_customer_id: sub?.stripe_customer_id ?? null,
        stripe_subscription_id: sub?.stripe_subscription_id ?? null,
        teve_assinatura_paga: sub?.plano === "premium",
        arquivos_removidos: arquivosRemovidos,
      },
      { onConflict: "user_id" },
    );
    if (logErr) return errorResponse(logErr.message, 500);

    // 4. Auth — dispara todos os CASCADEs.
    const { error: deleteErr } = await serviceClient.auth.admin.deleteUser(user.id);
    if (deleteErr) {
      console.error("[delete-account] falha no deleteUser", deleteErr.message);
      return errorResponse("Não foi possível concluir a exclusão. Tente novamente.", 500);
    }

    return jsonResponse({ excluido: true, arquivos_removidos: arquivosRemovidos });
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    if (err instanceof Error && err.name === "ZodError") {
      return errorResponse('Envie { "confirmacao": "EXCLUIR" } para confirmar a exclusão.', 400);
    }
    console.error("[delete-account]", err instanceof Error ? err.message : err);
    return errorResponse("Não foi possível concluir a exclusão. Tente novamente.", 500);
  }
});
