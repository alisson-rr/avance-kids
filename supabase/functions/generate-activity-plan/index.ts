import { z } from "npm:zod@3.22.4";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, errorMessage, corsHeaders } from "../_shared/response.ts";

const InputSchema = z.object({ child_id: z.string().uuid() });

const LEVELS = ["aquisicao", "generalizacao", "manutencao"] as const;

function shuffle<T>(items: T[]): T[] {
  const shuffled = [...items];

  for (let index = shuffled.length - 1; index > 0; index--) {
    const randomIndex = Math.floor(Math.random() * (index + 1));
    [shuffled[index], shuffled[randomIndex]] = [shuffled[randomIndex], shuffled[index]];
  }

  return shuffled;
}

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

    // O plano recebe TODAS as atividades da faixa, inclusive as premium: a RLS
    // (migration-05) esconde o conteúdo pago de quem não assina e libera na
    // hora em que a assinatura entra, sem precisar regerar o plano — regerar
    // apagaria o histórico da criança.
    const { data: sub } = await serviceClient
      .from("subscriptions")
      .select("plano, status")
      .eq("user_id", user.id)
      .maybeSingle();

    const isPremium = sub?.plano === "premium" && ["active", "trialing"].includes(sub?.status ?? "");

    const plansToInsert: Record<string, unknown>[] = [];

    // Para cada habilidade, buscar as atividades ativas da faixa correspondente
    for (const sa of skillAges) {
      const { data: exercises } = await serviceClient
        .from("exercises")
        .select("id, nivel, ordem, plano")
        .eq("skill_id", sa.skill_id)
        .eq("age_bracket_id", sa.faixa_id)
        .eq("status", "ativo");

      if (!exercises || exercises.length === 0) continue;

      // `exercises.ordem` identifica a mesma atividade nos três níveis. A
      // permutação é feita uma única vez por habilidade e reaproveitada em
      // A/G/M; a posição resultante fica persistida em activity_plans.ordem.
      const activityOrder = shuffle([...new Set(exercises.map((ex) => ex.ordem))]);
      const activityPosition = new Map(activityOrder.map((ordem, index) => [ordem, index]));
      const levelPosition = new Map(LEVELS.map((nivel, index) => [nivel, index]));

      const orderedExercises = [...exercises].sort((left, right) => {
        const byLevel = (levelPosition.get(left.nivel) ?? LEVELS.length) -
          (levelPosition.get(right.nivel) ?? LEVELS.length);
        if (byLevel !== 0) return byLevel;

        return (activityPosition.get(left.ordem) ?? activityOrder.length) -
          (activityPosition.get(right.ordem) ?? activityOrder.length);
      });

      // A primeira atividade que a conta consegue abrir é a que começa ativa;
      // senão um plano que abre com atividade premium deixaria o usuário free
      // sem nada para fazer. O nível é explícito: G/M nunca podem ser o ponto
      // de entrada, mesmo se o catálogo tiver planos diferentes entre níveis.
      const firstAvailable = orderedExercises.findIndex((ex) =>
        ex.nivel === "aquisicao" && (isPremium || ex.plano === "free")
      );

      orderedExercises.forEach((ex, idx) => {
        const isFirst = idx === firstAvailable;
        plansToInsert.push({
          child_id,
          skill_id: sa.skill_id,
          exercise_id: ex.id,
          status: isFirst ? "ativo" : "bloqueado",
          ordem: idx,
          started_at: isFirst ? new Date().toISOString() : null,
        });
      });
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
    return errorResponse(errorMessage(err), 400);
  }
});
