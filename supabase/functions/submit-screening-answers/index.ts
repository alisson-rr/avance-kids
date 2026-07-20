import { SubmitScreeningAnswersSchema } from "../_shared/schemas.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const body = SubmitScreeningAnswersSchema.parse(await req.json());

    // Verificar ownership da criança
    const { data: child } = await supabase
      .from("children")
      .select("id")
      .eq("id", body.child_id)
      .eq("user_id", user.id)
      .maybeSingle();

    if (!child) return errorResponse("Criança não encontrada", 404);

    // Validar que as perguntas são de triagem e pertencem à habilidade enviada
    const questionIds = body.answers.map((a) => a.question_id);
    if (new Set(questionIds).size !== questionIds.length) {
      return errorResponse("Respostas duplicadas para a mesma pergunta", 400);
    }
    const { data: questions } = await supabase
      .from("questions")
      .select("id, kind, skill_id")
      .in("id", questionIds);

    const validIds = new Set(
      (questions ?? [])
        .filter((q) => q.kind === "triagem" && q.skill_id === body.skill_id)
        .map((q) => q.id),
    );
    if (validIds.size !== new Set(questionIds).size) {
      return errorResponse("Uma ou mais perguntas são inválidas para esta habilidade", 400);
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

    // Calcular idade da habilidade e resolver a faixa correspondente
    const serviceClient = getServiceClient();
    const { data: skillAge, error: ageErr } = await serviceClient
      .rpc("calculate_skill_age", {
        p_child_id: body.child_id,
        p_skill_id: body.skill_id,
      });

    if (ageErr) return errorResponse(ageErr.message, 500);

    const { data: bracketId } = await serviceClient
      .rpc("resolve_age_bracket", { idade_meses: skillAge });

    const { error: upsertErr } = await supabase
      .from("child_skill_ages")
      .upsert({
        child_id: body.child_id,
        skill_id: body.skill_id,
        idade_meses: skillAge,
        faixa_id: bracketId,
        evaluated_at: new Date().toISOString(),
      }, { onConflict: "child_id,skill_id" });

    if (upsertErr) return errorResponse(upsertErr.message, 500);

    return jsonResponse({
      skill_id: body.skill_id,
      idade_meses: skillAge,
      faixa_id: bracketId,
    });
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
