import { supabase } from '../lib/supabase';
import { getRefData } from './refData';
import type { RecordStatus } from '../types/common';

export interface DashboardStats {
  totalUsers: number;
  completedActivities: number;
  totalArticles: number;
  signupsByMonth: { name: string; cadastros: number }[];
  latestExercises: { id: string; titulo: string; skillNome: string; status: RecordStatus }[];
  latestArticles: { id: string; titulo: string; status: RecordStatus }[];
}

const MONTH_LABELS = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

async function countRows(table: string, filter?: { column: string; value: string }): Promise<number> {
  let query = supabase.from(table).select('id', { count: 'exact', head: true });
  if (filter) query = query.eq(filter.column, filter.value);
  const { count, error } = await query;
  if (error) throw new Error(error.message);
  return count ?? 0;
}

async function fetchSignupsByMonth(): Promise<{ name: string; cadastros: number }[]> {
  const start = new Date();
  start.setMonth(start.getMonth() - 11, 1);
  start.setHours(0, 0, 0, 0);

  const { data, error } = await supabase
    .from('profiles')
    .select('created_at')
    .gte('created_at', start.toISOString());
  if (error) throw new Error(error.message);

  const buckets = new Map<string, { name: string; cadastros: number }>();
  const cursor = new Date(start);
  for (let i = 0; i < 12; i++) {
    const key = `${cursor.getFullYear()}-${cursor.getMonth()}`;
    buckets.set(key, { name: MONTH_LABELS[cursor.getMonth()], cadastros: 0 });
    cursor.setMonth(cursor.getMonth() + 1);
  }

  for (const row of data ?? []) {
    const d = new Date(row.created_at);
    const bucket = buckets.get(`${d.getFullYear()}-${d.getMonth()}`);
    if (bucket) bucket.cadastros += 1;
  }

  return [...buckets.values()];
}

export async function fetchDashboardStats(): Promise<DashboardStats> {
  const [totalUsers, completedActivities, totalArticles, signupsByMonth, exercisesRes, articlesRes, ref] =
    await Promise.all([
      countRows('profiles'),
      countRows('activity_plans', { column: 'status', value: 'concluido' }),
      countRows('articles', { column: 'status', value: 'ativo' }),
      fetchSignupsByMonth(),
      supabase
        .from('exercises')
        .select('id, titulo, skill_id, status')
        .order('created_at', { ascending: false })
        .limit(5),
      supabase
        .from('articles')
        .select('id, titulo, status')
        .order('created_at', { ascending: false })
        .limit(5),
      getRefData(),
    ]);

  if (exercisesRes.error) throw new Error(exercisesRes.error.message);
  if (articlesRes.error) throw new Error(articlesRes.error.message);

  const skillNomeById = new Map(ref.skills.map((s) => [s.id, s.nome]));

  return {
    totalUsers,
    completedActivities,
    totalArticles,
    signupsByMonth,
    latestExercises: (exercisesRes.data ?? []).map((row) => ({
      id: row.id,
      titulo: row.titulo,
      skillNome: skillNomeById.get(row.skill_id) ?? '—',
      status: row.status as RecordStatus,
    })),
    latestArticles: (articlesRes.data ?? []).map((row) => ({
      id: row.id,
      titulo: row.titulo,
      status: row.status as RecordStatus,
    })),
  };
}
