import { StartSessionSchema } from "../_shared/schemas.ts";
import { getUser } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const { plan_id } = StartSessionSchema.parse(await req.json());

    // Verificar ownership e que o plano está ativo
    const { data: plan } = await supabase
      .from("activity_plans")
      .select("id, child_id, status")
      .eq("id", plan_id)
      .single();

    if (!plan) return errorResponse("Plano não encontrado", 404);
    if (plan.status !== "ativo") return errorResponse("Este exercício não está ativo", 400);

    // Verificar se já existe sessão ativa (não expirada e com repetições
    // restantes — sessão cheia sem atingir o critério recomeça do zero)
    const { data: existingSession } = await supabase
      .from("exercise_sessions")
      .select("*")
      .eq("plan_id", plan_id)
      .eq("is_completed", false)
      .lt("total_repetitions", 10)
      .gt("expires_at", new Date().toISOString())
      .order("started_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (existingSession) {
      // Retornar sessão existente
      return jsonResponse({ session: existingSession, is_new: false });
    }

    // Criar nova sessão
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    const { data: session, error } = await supabase
      .from("exercise_sessions")
      .insert({
        plan_id,
        child_id: plan.child_id,
        expires_at: expiresAt.toISOString(),
      })
      .select()
      .single();

    if (error) return errorResponse(error.message, 500);

    return jsonResponse({ session, is_new: true }, 201);
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
