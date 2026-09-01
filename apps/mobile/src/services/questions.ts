import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import type { QuestionKind, QuestionRow } from '../types/db';

/**
 * Escala A/B/C/NV do checklist oficial, na frequência que a própria planilha
 * define (1 em 5 / 2 a 3 em 5 / 4 a 5 em 5). O contrato com o banco não muda:
 * A/B/C continuam sendo valor_numerico 0/1/2 e NV continua sendo valor 0 com
 * nao_observado = true — a diferença é que a partir da migration-11 as médias
 * de idade ignoram as linhas de NV, em vez de tratá-las como "quase nunca".
 */
export const QUESTION_OPTIONS = [
  { label: 'Quase nunca — cerca de 1 vez a cada 5', valorNumerico: 0, naoObservado: false },
  { label: 'Às vezes — cerca de 2 a 3 vezes a cada 5', valorNumerico: 1, naoObservado: false },
  { label: 'Quase sempre — cerca de 4 a 5 vezes a cada 5', valorNumerico: 2, naoObservado: false },
  { label: 'Ainda não verifiquei essa situação', valorNumerico: 0, naoObservado: true },
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

export interface BracketRef {
  id: string;
  codigo: string;
  nome: string;
}

export interface SubmitInitialResult {
  idade_geral_meses: number;
  /** Faixa pela idade geral. Campo legado — a que vale é `faixa_atual`. */
  faixa_sugerida: BracketRef | null;
  faixa_avaliada: BracketRef | null;
  /** Faixa gravada em children.faixa_id depois de aplicar o rebaixamento. */
  faixa_atual: BracketRef | null;
  rebaixou: boolean;
  /** Faixa cujos pré-requisitos ainda precisam ser respondidos, se desceu. */
  proxima_faixa: BracketRef | null;
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
