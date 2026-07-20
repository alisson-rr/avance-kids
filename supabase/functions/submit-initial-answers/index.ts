import { SubmitInitialAnswersSchema } from "../_shared/schemas.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

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
      .select("id, kind")
      .in("id", questionIds);

    const validIds = new Set((questions ?? []).filter((q) => q.kind === "inicial").map((q) => q.id));
    if (validIds.size !== new Set(questionIds).size) {
      return errorResponse("Uma ou mais perguntas são inválidas para a triagem inicial", 400);
    }

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

    // Recalcular idade geral e faixa sugerida
    const serviceClient = getServiceClient();
    const { data: idadeGeral, error: ageErr } = await serviceClient
      .rpc("calculate_general_age", { p_child_id: body.child_id });

    if (ageErr) return errorResponse(ageErr.message, 500);

    const { error: updateErr } = await supabase
      .from("children")
      .update({ idade_geral_meses: idadeGeral })
      .eq("id", body.child_id);

    if (updateErr) return errorResponse(updateErr.message, 500);

    const { data: bracketId } = await serviceClient
      .rpc("resolve_age_bracket", { idade_meses: idadeGeral });

    let faixaSugerida: { id: string; codigo: string; nome: string } | null = null;
    if (bracketId) {
      const { data: bracket } = await serviceClient
        .from("age_brackets")
        .select("id, codigo, nome")
        .eq("id", bracketId)
        .maybeSingle();
      faixaSugerida = bracket ?? null;
    }

    return jsonResponse({
      idade_geral_meses: idadeGeral,
      faixa_sugerida: faixaSugerida,
    });
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
