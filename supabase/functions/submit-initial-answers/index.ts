import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { SubmitInitialAnswersSchema } from "../_shared/schemas.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const body = SubmitInitialAnswersSchema.parse(await req.json());

    // Verificar ownership da criança
    const { data: child, error: childErr } = await supabase
      .from("children")
      .select("id, idade_biologica_meses")
      .eq("id", body.child_id)
      .eq("user_id", user.id)
      .single();

    if (childErr || !child) return errorResponse("Criança não encontrada", 404);

    // Salvar respostas (upsert para permitir refazer)
    const answersToInsert = body.answers.map((a) => ({
      child_id: body.child_id,
      question_id: a.question_id,
      option_id: a.option_id,
    }));

    const { error: insertErr } = await supabase
      .from("child_initial_answers")
      .upsert(answersToInsert, { onConflict: "child_id,question_id" });

    if (insertErr) return errorResponse(insertErr.message, 500);

    // Chamar função PL/pgSQL para calcular idade geral
    const serviceClient = getServiceClient();
    const { data: ageResult, error: ageErr } = await serviceClient
      .rpc("calculate_general_age", { p_child_id: body.child_id });

    if (ageErr) return errorResponse(ageErr.message, 500);

    // Atualizar criança com idade geral
    const { error: updateErr } = await supabase
      .from("children")
      .update({ idade_geral_meses: ageResult })
      .eq("id", body.child_id);

    if (updateErr) return errorResponse(updateErr.message, 500);

    return jsonResponse({
      idade_geral_meses: ageResult,
      faixa_sugerida: null, // será resolvida pelo front ao buscar perguntas
    });
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
