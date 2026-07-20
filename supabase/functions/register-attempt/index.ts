import { RegisterAttemptSchema } from "../_shared/schemas.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const body = RegisterAttemptSchema.parse(await req.json());

    // Verificar sessão ativa e não expirada
    const { data: session } = await supabase
      .from("exercise_sessions")
      .select("*")
      .eq("id", body.session_id)
      .eq("is_completed", false)
      .gt("expires_at", new Date().toISOString())
      .maybeSingle();

    if (!session) return errorResponse("Sessão inválida ou expirada", 400);
    if (session.plan_id !== body.plan_id) return errorResponse("Plano não corresponde à sessão", 400);
    if (session.total_repetitions >= 10) return errorResponse("Máximo de 10 repetições atingido", 400);

    // Inserir tentativa
    const { error: attemptErr } = await supabase
      .from("exercise_attempts")
      .insert({
        session_id: body.session_id,
        plan_id: body.plan_id,
        child_id: session.child_id,
        repeticao_numero: body.repeticao_numero,
        resultado: body.resultado,
      });

    if (attemptErr) return errorResponse(attemptErr.message, 500);

    // Atualizar contadores da sessão
    const newTotal = session.total_repetitions + 1;
    const newSuccess = body.resultado === "sem_ajuda"
      ? session.successful_count + 1
      : session.successful_count;

    const { error: updateErr } = await supabase
      .from("exercise_sessions")
      .update({
        total_repetitions: newTotal,
        successful_count: newSuccess,
      })
      .eq("id", body.session_id);

    if (updateErr) return errorResponse(updateErr.message, 500);

    // Verificar conclusão (≥8/10 sem ajuda)
    let exerciseCompleted = false;
    if (newSuccess >= 8) {
      const serviceClient = getServiceClient();
      const { data: completed } = await serviceClient
        .rpc("check_exercise_completion", { p_session_id: body.session_id });
      exerciseCompleted = completed === true;
    }

    return jsonResponse({
      repetition: body.repeticao_numero,
      total_repetitions: newTotal,
      successful_count: newSuccess,
      exercise_completed: exerciseCompleted,
      remaining: 10 - newTotal,
    });
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
