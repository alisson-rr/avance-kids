import { z } from "npm:zod@3.22.4";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

const InputSchema = z.object({ child_id: z.string().uuid() });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const { child_id } = InputSchema.parse(await req.json());

    // Verificar ownership
    const { data: child } = await supabase
      .from("children")
      .select("id")
      .eq("id", child_id)
      .eq("user_id", user.id)
      .maybeSingle();

    if (!child) return errorResponse("Criança não encontrada", 404);

    // Buscar idades por habilidade (resultado da triagem)
    const { data: skillAges } = await supabase
      .from("child_skill_ages")
      .select("skill_id, idade_meses, faixa_id")
      .eq("child_id", child_id);

    if (!skillAges || skillAges.length === 0) {
      return errorResponse("Triagem não concluída. Complete a triagem de todas as habilidades.", 400);
    }

    const serviceClient = getServiceClient();

    // Gating free/premium: assinante free só recebe atividades do plano free
    const { data: sub } = await serviceClient
      .from("subscriptions")
      .select("plano, status")
      .eq("user_id", user.id)
      .maybeSingle();

    const isPremium = sub?.plano === "premium" && ["active", "trialing"].includes(sub?.status ?? "");

    const plansToInsert: Record<string, unknown>[] = [];

    // Para cada habilidade, buscar as atividades ativas da faixa correspondente
    for (const sa of skillAges) {
      let query = serviceClient
        .from("exercises")
        .select("id, nivel, ordem")
        .eq("skill_id", sa.skill_id)
        .eq("age_bracket_id", sa.faixa_id)
        .eq("status", "ativo");

      if (!isPremium) {
        query = query.eq("plano", "free");
      }

      const { data: exercises } = await query
        .order("nivel", { ascending: true })   // aquisicao → generalizacao → manutencao
        .order("ordem", { ascending: true });

      if (exercises && exercises.length > 0) {
        exercises.forEach((ex, idx) => {
          plansToInsert.push({
            child_id,
            skill_id: sa.skill_id,
            exercise_id: ex.id,
            status: idx === 0 ? "ativo" : "bloqueado", // primeiro = ativo
            ordem: idx,
            started_at: idx === 0 ? new Date().toISOString() : null,
          });
        });
      }
    }

    if (plansToInsert.length === 0) {
      return errorResponse("Nenhuma atividade encontrada para as faixas da criança.", 404);
    }

    // Limpar planos anteriores (caso refaça a triagem)
    await serviceClient
      .from("activity_plans")
      .delete()
      .eq("child_id", child_id);

    const { data: plans, error: insertErr } = await serviceClient
      .from("activity_plans")
      .insert(plansToInsert)
      .select();

    if (insertErr) return errorResponse(insertErr.message, 500);

    // Marcar triagem como completa
    await supabase
      .from("children")
      .update({ triagem_completa: true })
      .eq("id", child_id);

    return jsonResponse({ plans, total: plans?.length || 0 }, 201);
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
