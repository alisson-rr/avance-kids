import { supabase } from '../lib/supabase';
import { getRefData } from './refData';
import { assertUpdated, fetchAllRows, toggleArchiveStatus } from './common';
import { MAX_TEXTO, MAX_VIDEO_URL, assertYoutubeUrl } from './howToAnswer';
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
  como_responder_texto: string | null;
  como_responder_video_url: string | null;
}

export async function fetchPerguntas(kind: QuestionKind): Promise<Pergunta[]> {
  const [rows, ref] = await Promise.all([
    fetchAllRows<QuestionRow>((from, to) =>
      supabase
        .from('questions')
        .select('id, skill_id, age_bracket_id, texto, ordem, status, como_responder_texto, como_responder_video_url')
        .eq('kind', kind)
        .order('ordem', { ascending: true })
        .order('id')
        .range(from, to)
    ),
    getRefData(),
  ]);

  return rows.map((row) => ({
    id: row.id,
    texto: row.texto,
    skillKey: ref.skillKeyById(row.skill_id),
    ageBracketCode: ref.bracketCodeById(row.age_bracket_id),
    ordem: row.ordem,
    status: row.status,
    comoResponderTexto: row.como_responder_texto ?? '',
    comoResponderVideoUrl: row.como_responder_video_url ?? '',
  }));
}

export async function savePergunta(kind: QuestionKind, item: Pergunta, isEditing: boolean): Promise<void> {
  if (!item.texto.trim()) throw new Error('Informe o texto da pergunta.');
  const comoResponderTexto = item.comoResponderTexto.trim();
  const comoResponderVideoUrl = item.comoResponderVideoUrl.trim();
  if (comoResponderTexto.length > MAX_TEXTO) {
    throw new Error(`O texto de "Como responder" pode ter no máximo ${MAX_TEXTO} caracteres.`);
  }
  if (comoResponderVideoUrl.length > MAX_VIDEO_URL) {
    throw new Error(`O link do vídeo de "Como responder" pode ter no máximo ${MAX_VIDEO_URL} caracteres.`);
  }
  assertYoutubeUrl(comoResponderVideoUrl);

  const ref = await getRefData();
  const payload = {
    kind,
    skill_id: ref.skillIdByKey(item.skillKey),
    age_bracket_id: ref.bracketIdByCode(item.ageBracketCode),
    texto: item.texto.trim(),
    ordem: item.ordem,
    status: item.status,
    como_responder_texto: comoResponderTexto || null,
    como_responder_video_url: comoResponderVideoUrl || null,
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
