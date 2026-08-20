/**
 * Registra o aceite dos termos com trilha de auditoria.
 *
 * Por que uma function e não um insert direto do app: versão do documento, data
 * e IP não podem vir do client — senão o registro prova apenas o que o próprio
 * usuário (ou alguém com o token dele) resolveu afirmar. Aqui o servidor resolve
 * qual versão está vigente, carimba o horário e lê o IP do proxy.
 *
 * Idempotente: reenviar o mesmo aceite não duplica linha nem reescreve o
 * `aceito_em` original (UNIQUE (user_id, document_id) + ON CONFLICT DO NOTHING).
 */
import { z } from "npm:zod@3.22.4";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

const InputSchema = z.object({
  // Opcional: sem `tipos`, aceita todos os documentos vigentes (é como o app
  // apresenta hoje — um único texto de Termos + Privacidade).
  tipos: z.array(z.string().regex(/^[a-z0-9_]+$/)).min(1).optional(),
  // Documento que estava na tela quando o usuário aceitou. Não é o client
  // escolhendo versão — continua sendo o servidor que resolve a vigente. É o
  // client AFIRMANDO o que exibiu, para o servidor recusar quando a vigente
  // mudou no meio (tela aberta enquanto uma versão nova foi publicada). Sem
  // isso o log afirmaria consentimento a um texto que o titular não leu, que é
  // justamente a prova que esta function existe para produzir.
  document_id: z.string().uuid().optional(),
  origem: z.enum(["app", "backoffice"]).default("app"),
});

/**
 * Só grava o IP se for um endereço plausível: a coluna é INET e um cast
 * inválido derrubaria o insert inteiro — o aceite falharia por causa de um
 * header malformado, que é o oposto do que esta function precisa garantir.
 */
const IPV4 = /^(\d{1,3}\.){3}\d{1,3}$/;
const IPV6 = /^[0-9a-fA-F:]+$/;

function clientIp(req: Request): string | null {
  const raw = req.headers.get("x-forwarded-for") ?? req.headers.get("x-real-ip");
  if (!raw) return null;

  const first = raw.split(",")[0].trim();
  if (!first) return null;

  if (IPV4.test(first)) {
    return first.split(".").every((o) => Number(o) <= 255) ? first : null;
  }
  return IPV6.test(first) && first.includes(":") ? first : null;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { user } = await getUser(req);

    // Body vazio é um aceite válido de tudo que está vigente.
    const body = await req.json().catch(() => ({}));
    const { tipos, document_id, origem } = InputSchema.parse(body ?? {});

    const serviceClient = getServiceClient();

    let query = serviceClient
      .from("terms_documents")
      .select("id, tipo, versao, conteudo_hash")
      .eq("vigente", true);

    if (tipos) query = query.in("tipo", tipos);

    const { data: documentos, error: docsErr } = await query;
    if (docsErr) return errorResponse(docsErr.message, 500);

    if (!documentos || documentos.length === 0) {
      return errorResponse("Nenhum documento vigente para aceitar.", 404);
    }

    if (tipos && documentos.length !== tipos.length) {
      const encontrados = documentos.map((d) => d.tipo);
      const faltando = tipos.filter((t) => !encontrados.includes(t));
      return errorResponse(`Documento não encontrado: ${faltando.join(", ")}`, 404);
    }

    if (document_id && !documentos.some((d) => d.id === document_id)) {
      // 409 e não 400: nada está errado com o pedido, a versão é que mudou
      // desde que a tela carregou. O app reavalia e mostra o texto novo.
      return errorResponse(
        "Os termos foram atualizados enquanto esta tela estava aberta. Leia a nova versão para aceitar.",
        409,
      );
    }

    const ip = clientIp(req);
    const userAgent = req.headers.get("user-agent")?.slice(0, 500) ?? null;

    const { error: insertErr } = await serviceClient
      .from("terms_acceptances")
      .upsert(
        documentos.map((doc) => ({
          user_id: user.id,
          document_id: doc.id,
          tipo: doc.tipo,
          versao: doc.versao,
          conteudo_hash: doc.conteudo_hash,
          ip,
          user_agent: userAgent,
          origem,
        })),
        { onConflict: "user_id,document_id", ignoreDuplicates: true },
      );

    if (insertErr) return errorResponse(insertErr.message, 500);

    // Flag de UX. Se falhar, o aceite já está registrado — o que importa é o
    // log; o app no máximo mostra o modal outra vez.
    await serviceClient
      .from("profiles")
      .update({ termos_aceitos: true })
      .eq("id", user.id);

    // Devolve o estado gravado (e não o que acabamos de montar): em um reenvio,
    // `aceito_em` é o do primeiro aceite, que é a data que vale.
    const { data: registros } = await serviceClient
      .from("terms_acceptances")
      .select("tipo, versao, aceito_em")
      .eq("user_id", user.id)
      .in("document_id", documentos.map((d) => d.id));

    return jsonResponse({ aceites: registros ?? [] }, 201);
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    if (err instanceof Error && err.name === "ZodError") {
      return errorResponse("Dados inválidos.", 400);
    }
    console.error("[accept-terms]", err instanceof Error ? err.message : err);
    return errorResponse("Não foi possível registrar o aceite.", 500);
  }
});
