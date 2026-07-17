import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { SubmitScreeningAnswersSchema } from "../_shared/schemas.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const body = SubmitScreeningAnswersSchema.parse(await req.json());

    // Verificar ownership
    const { data: child } = await supabase
      .from("children")
      .select("id")
      .eq("id", body.child_id)
      .eq("user_id", user.id)
      .single();

    if (!child) return errorResponse("Criança não encontrada", 404);

    // Salvar respostas da triagem
    const answersToInsert = body.answers.map((a) => ({
      child_id: body.child_id,
      question_id: a.question_id,
      option_id: a.option_id,
      skill_id: body.skill_id,
    }));

    const { error: insertErr } = await supabase
      .from("child_screening_answers")
      .upsert(answersToInsert, { onConflict: "child_id,question_id" });

    if (insertErr) return errorResponse(insertErr.message, 500);

    // Calcular idade da habilidade
    const serviceClient = getServiceClient();
    const { data: skillAge, error: ageErr } = await serviceClient
      .rpc("calculate_skill_age", {
        p_child_id: body.child_id,
        p_skill_id: body.skill_id,
      });

    if (ageErr) return errorResponse(ageErr.message, 500);

    // Resolver faixa
    const { data: bracketId } = await serviceClient
      .rpc("resolve_age_bracket", { idade_meses: skillAge });

    // Salvar/atualizar idade da habilidade
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
