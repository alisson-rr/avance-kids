import { SubmitInitialAnswersSchema } from "../_shared/schemas.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

interface BracketRef {
  id: string;
  codigo: string;
  nome: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const body = SubmitInitialAnswersSchema.parse(await req.json());

    // Verificar ownership da criança
    const { data: child, error: childErr } = await supabase
      .from("children")
      .select("id")
      .eq("id", body.child_id)
      .eq("user_id", user.id)
      .maybeSingle();

    if (childErr || !child) return errorResponse("Criança não encontrada", 404);

    // Validar que todas as perguntas existem, estão ativas e são do tipo 'inicial'
    // (perguntas arquivadas ficam invisíveis pela RLS e falham aqui).
    const questionIds = body.answers.map((a) => a.question_id);
    if (new Set(questionIds).size !== questionIds.length) {
      return errorResponse("Respostas duplicadas para a mesma pergunta", 400);
    }
    const { data: questions } = await supabase
      .from("questions")
      .select("id, kind, age_bracket_id")
      .in("id", questionIds);

    const iniciais = (questions ?? []).filter((q) => q.kind === "inicial");
    if (iniciais.length !== new Set(questionIds).size) {
      return errorResponse("Uma ou mais perguntas são inválidas para a triagem inicial", 400);
    }

    // O rebaixamento é sempre relativo a UMA faixa: um lote misturando faixas
    // não teria como ser contado. Recusar na fronteira é mais honesto do que
    // escolher uma delas por conta própria.
    const faixasNoLote = new Set(iniciais.map((q) => q.age_bracket_id));
    if (faixasNoLote.size !== 1) {
      return errorResponse("As perguntas iniciais devem ser todas da mesma faixa etária", 400);
    }
    const faixaAvaliadaId = [...faixasNoLote][0] as string;

    // Salvar respostas na escala fixa (upsert permite refazer)
    const answersToInsert = body.answers.map((a) => ({
      child_id: body.child_id,
      question_id: a.question_id,
      valor_numerico: a.valor_numerico,
      nao_observado: a.nao_observado,
      answered_at: new Date().toISOString(),
    }));

    const { error: insertErr } = await supabase
      .from("child_question_answers")
      .upsert(answersToInsert, { onConflict: "child_id,question_id" });

    if (insertErr) return errorResponse(insertErr.message, 500);

    // Recalcular idade geral (NV fora da média desde a migration-11)
    const serviceClient = getServiceClient();
    const { data: idadeGeral, error: ageErr } = await serviceClient
      .rpc("calculate_general_age", { p_child_id: body.child_id });

    if (ageErr) return errorResponse(ageErr.message, 500);

    // Rebaixamento automático (D3): 2+ respostas "A" nos pré-requisitos desta
    // faixa descem uma faixa, sem perguntar ao responsável. A regra mora no
    // banco (resolve_bracket_after_prerequisites) para não ter duas cópias.
    const { data: faixaResultanteId, error: bracketErr } = await serviceClient
      .rpc("resolve_bracket_after_prerequisites", {
        p_child_id: body.child_id,
        p_bracket_id: faixaAvaliadaId,
      });

    if (bracketErr) return errorResponse(bracketErr.message, 500);

    const rebaixou = faixaResultanteId !== faixaAvaliadaId;

    const { error: updateErr } = await supabase
      .from("children")
      .update({ idade_geral_meses: idadeGeral, faixa_id: faixaResultanteId })
      .eq("id", body.child_id);

    if (updateErr) return errorResponse(updateErr.message, 500);

    // Faixa pela idade geral: campo antigo da resposta, mantido para não
    // quebrar builds do app já publicadas. A faixa que vale para as perguntas
    // é `faixa_atual`.
    const { data: sugeridaId } = await serviceClient
      .rpc("resolve_age_bracket", { idade_meses: idadeGeral });

    const idsDesejados = [faixaAvaliadaId, faixaResultanteId, sugeridaId].filter(
      (id): id is string => typeof id === "string",
    );
    const { data: brackets } = await serviceClient
      .from("age_brackets")
      .select("id, codigo, nome")
      .in("id", idsDesejados);

    const porId = new Map<string, BracketRef>((brackets ?? []).map((b) => [b.id, b]));
    const faixaAtual = porId.get(faixaResultanteId) ?? null;

    return jsonResponse({
      idade_geral_meses: idadeGeral,
      faixa_sugerida: sugeridaId ? porId.get(sugeridaId) ?? null : null,
      faixa_avaliada: porId.get(faixaAvaliadaId) ?? null,
      faixa_atual: faixaAtual,
      rebaixou,
      // Quando desceu, os pré-requisitos da faixa nova precisam ser aplicados
      // — e podem rebaixar de novo. Sem rebaixamento não há o que repetir.
      proxima_faixa: rebaixou ? faixaAtual : null,
    });
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
