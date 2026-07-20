import { supabase } from '../lib/supabase';
import { getRefData } from './refData';
import { assertUpdated, toggleArchiveStatus } from './common';
import type { Pergunta } from '../types/entities';
import type { RecordStatus, WithId } from '../types/common';

export type QuestionKind = 'inicial' | 'triagem';

interface QuestionRow {
  id: string;
  skill_id: string;
  age_bracket_id: string;
  texto: string;
  ordem: number;
  status: RecordStatus;
}

export async function fetchPerguntas(kind: QuestionKind): Promise<Pergunta[]> {
  const [{ data, error }, ref] = await Promise.all([
    supabase
      .from('questions')
      .select('id, skill_id, age_bracket_id, texto, ordem, status')
      .eq('kind', kind)
      .order('ordem', { ascending: true }),
    getRefData(),
  ]);
  if (error) throw new Error(error.message);

  return ((data ?? []) as QuestionRow[]).map((row) => ({
    id: row.id,
    texto: row.texto,
    skillKey: ref.skillKeyById(row.skill_id),
    ageBracketCode: ref.bracketCodeById(row.age_bracket_id),
    ordem: row.ordem,
    status: row.status,
  }));
}

export async function savePergunta(kind: QuestionKind, item: Pergunta, isEditing: boolean): Promise<void> {
  if (!item.texto.trim()) throw new Error('Informe o texto da pergunta.');

  const ref = await getRefData();
  const payload = {
    kind,
    skill_id: ref.skillIdByKey(item.skillKey),
    age_bracket_id: ref.bracketIdByCode(item.ageBracketCode),
    texto: item.texto.trim(),
    ordem: item.ordem,
    status: item.status,
  };

  if (isEditing) {
    const { data, error } = await supabase.from('questions').update(payload).eq('id', item.id).select('id');
    assertUpdated(data, error);
  } else {
    const { error } = await supabase.from('questions').insert(payload);
    if (error) throw new Error(error.message);
  }
}

export function toggleArchivePergunta(row: WithId): Promise<void> {
  return toggleArchiveStatus('questions', row);
}
