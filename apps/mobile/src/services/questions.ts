import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import type { QuestionKind, QuestionRow } from '../types/db';

/**
 * Escala fixa de resposta (ANSWER_SCALE do backoffice) exibida em toda
 * pergunta. A 4ª opção mapeia para valor 0 com nao_observado = true.
 */
export const QUESTION_OPTIONS = [
  { label: 'Quase nunca faz, mesmo com ajuda', valorNumerico: 0, naoObservado: false },
  { label: 'Faz às vezes ou com ajuda', valorNumerico: 1, naoObservado: false },
  { label: 'Faz quase sempre, com autonomia', valorNumerico: 2, naoObservado: false },
  { label: 'Não observei essa situação ainda', valorNumerico: 0, naoObservado: true },
] as const;

export interface AnswerInput {
  question_id: string;
  valor_numerico: number;
  nao_observado: boolean;
}

export async function fetchQuestions(
  kind: QuestionKind,
  ageBracketId: string,
  skillId?: string,
): Promise<QuestionRow[]> {
  let query = supabase
    .from('questions')
    .select('*')
    .eq('kind', kind)
    .eq('age_bracket_id', ageBracketId)
    .eq('status', 'ativo')
    .order('ordem');
  if (skillId) query = query.eq('skill_id', skillId);

  const { data, error } = await query;
  if (error) throw new Error(error.message);
  return data ?? [];
}

export interface SubmitInitialResult {
  idade_geral_meses: number;
  faixa_sugerida: { id: string; codigo: string; nome: string } | null;
}

export function submitInitialAnswers(childId: string, answers: AnswerInput[]) {
  return invokeFunction<SubmitInitialResult>('submit-initial-answers', {
    child_id: childId,
    answers,
  });
}

export interface SubmitScreeningResult {
  skill_id: string;
  idade_meses: number;
  faixa_id: string | null;
}

export function submitScreeningAnswers(
  childId: string,
  skillId: string,
  answers: AnswerInput[],
) {
  return invokeFunction<SubmitScreeningResult>('submit-screening-answers', {
    child_id: childId,
    skill_id: skillId,
    answers,
  });
}

/** Quantas perguntas de triagem a criança já respondeu, por habilidade. */
export async function fetchScreeningAnsweredCounts(
  childId: string,
): Promise<Record<string, number>> {
  const { data, error } = await supabase
    .from('child_question_answers')
    .select('question_id, questions!inner(skill_id, kind)')
    .eq('child_id', childId)
    .eq('questions.kind', 'triagem');
  if (error) throw new Error(error.message);

  const counts: Record<string, number> = {};
  for (const row of data ?? []) {
    const skillId = (row as unknown as { questions: { skill_id: string } }).questions.skill_id;
    counts[skillId] = (counts[skillId] ?? 0) + 1;
  }
  return counts;
}
