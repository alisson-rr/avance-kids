import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import type { ActivityPlanRow, AttemptResult, ExerciseSessionRow, PlanWithDetails } from '../types/db';

export function generateActivityPlan(childId: string) {
  return invokeFunction<{ plans: ActivityPlanRow[]; total: number }>('generate-activity-plan', {
    child_id: childId,
  });
}

const PLAN_SELECT = '*, exercises(*), skills(id, key, nome, cor_hex), exercise_sessions(*)';

export async function fetchActivityPlans(childId: string): Promise<PlanWithDetails[]> {
  const { data, error } = await supabase
    .from('activity_plans')
    .select(PLAN_SELECT)
    .eq('child_id', childId)
    .order('ordem');
  if (error) throw new Error(error.message);
  return (data ?? []) as unknown as PlanWithDetails[];
}

export async function fetchPlan(planId: string): Promise<PlanWithDetails | null> {
  const { data, error } = await supabase
    .from('activity_plans')
    .select(PLAN_SELECT)
    .eq('id', planId)
    .maybeSingle();
  if (error) throw new Error(error.message);
  return data as unknown as PlanWithDetails | null;
}

export function startExerciseSession(planId: string) {
  return invokeFunction<{ session: ExerciseSessionRow; is_new: boolean }>(
    'start-exercise-session',
    { plan_id: planId },
  );
}

export interface RegisterAttemptResult {
  repetition: number;
  total_repetitions: number;
  successful_count: number;
  exercise_completed: boolean;
  remaining: number;
}

export function registerAttempt(input: {
  session_id: string;
  plan_id: string;
  repeticao_numero: number;
  resultado: AttemptResult;
}) {
  return invokeFunction<RegisterAttemptResult>('register-attempt', input);
}

/** Sessão em andamento (não concluída e não expirada) de um plano, se houver. */
export function findOpenSession(plan: PlanWithDetails): ExerciseSessionRow | null {
  const now = Date.now();
  const open = plan.exercise_sessions
    .filter((s) => !s.is_completed && new Date(s.expires_at).getTime() > now)
    .sort((a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime());
  return open[0] ?? null;
}

/** % de acerto da sessão concluída mais recente (para o histórico). */
export function successRate(plan: PlanWithDetails): number {
  const done = plan.exercise_sessions
    .filter((s) => s.total_repetitions > 0)
    .sort((a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime());
  const s = done[0];
  if (!s) return 0;
  return Math.round((s.successful_count / s.total_repetitions) * 100);
}
