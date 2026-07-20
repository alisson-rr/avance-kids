import { supabase } from '../lib/supabase';
import type { AgeBracketRow, SkillRow } from '../types/db';

export async function fetchSkills(): Promise<SkillRow[]> {
  const { data, error } = await supabase.from('skills').select('*').order('ordem');
  if (error) throw new Error(error.message);
  return data ?? [];
}

export async function fetchAgeBrackets(): Promise<AgeBracketRow[]> {
  const { data, error } = await supabase.from('age_brackets').select('*').order('ordem');
  if (error) throw new Error(error.message);
  return data ?? [];
}

/**
 * Espelha resolve_age_bracket do banco: clamp 12..144 e, em gaps entre
 * faixas (ex.: 61-71 meses), usa a faixa anterior.
 */
export function resolveBracketForMonths(
  months: number,
  brackets: AgeBracketRow[],
): AgeBracketRow | null {
  if (brackets.length === 0) return null;
  const clamped = Math.max(12, Math.min(144, months));

  const exact = brackets.find((b) => clamped >= b.meses_min && clamped <= b.meses_max);
  if (exact) return exact;

  const anteriores = brackets
    .filter((b) => b.meses_min <= clamped)
    .sort((a, b) => b.meses_min - a.meses_min);
  return anteriores[0] ?? brackets[0];
}
