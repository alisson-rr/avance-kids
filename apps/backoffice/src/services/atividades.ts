import { supabase } from '../lib/supabase';
import { getRefData } from './refData';
import { resolveMediaUrl } from './storage';
import { assertUpdated, toggleArchiveStatus } from './common';
import type { Atividade, ExerciseLevel, AccessPlan } from '../constants/aba';
import type { MediaType, RecordStatus, WithId } from '../types/common';

interface ExerciseRow {
  id: string;
  skill_id: string;
  age_bracket_id: string;
  codigo: string | null;
  titulo: string;
  media_type: MediaType;
  media_url: string | null;
  nivel: ExerciseLevel;
  ordem: number;
  plano: AccessPlan;
  status: RecordStatus;
  objetivo: string | null;
  procedimento: string | null;
  materiais: string | null;
  recursos_extras: string | null;
  frequencia: string | null;
  brincadeiras: string | null;
  hierarquia_dicas: string | null;
  resposta_esperada: string | null;
  procedimento_correcao: string | null;
  criterio_avanco: string | null;
  registro_dados: string | null;
  reforcos: string | null;
}

const COLUMNS =
  'id, skill_id, age_bracket_id, codigo, titulo, media_type, media_url, nivel, ordem, plano, status, ' +
  'objetivo, procedimento, materiais, recursos_extras, frequencia, brincadeiras, hierarquia_dicas, ' +
  'resposta_esperada, procedimento_correcao, criterio_avanco, registro_dados, reforcos';

export async function fetchAtividades(): Promise<Atividade[]> {
  const [{ data, error }, ref] = await Promise.all([
    supabase.from('exercises').select(COLUMNS).order('created_at', { ascending: false }),
    getRefData(),
  ]);
  if (error) throw new Error(error.message);

  return ((data ?? []) as ExerciseRow[]).map((row) => ({
    id: row.id,
    codigo: row.codigo ?? '',
    titulo: row.titulo,
    mediaType: row.media_type,
    mediaUrl: row.media_url ?? '',
    skillKey: ref.skillKeyById(row.skill_id),
    ageBracketCode: ref.bracketCodeById(row.age_bracket_id),
    nivel: row.nivel,
    plano: row.plano,
    status: row.status,
    objetivo: row.objetivo ?? '',
    procedimento: row.procedimento ?? '',
    materiais: row.materiais ?? '',
    recursosExtras: row.recursos_extras ?? '',
    frequencia: row.frequencia ?? '',
    brincadeiras: row.brincadeiras ?? '',
    hierarquiaDicas: row.hierarquia_dicas ?? '',
    respostaEsperada: row.resposta_esperada ?? '',
    procedimentoCorrecao: row.procedimento_correcao ?? '',
    criterioAvanco: row.criterio_avanco ?? '',
    registroDados: row.registro_dados ?? '',
    reforcos: row.reforcos ?? '',
  }));
}

export async function saveAtividade(item: Atividade, isEditing: boolean): Promise<void> {
  if (!item.titulo.trim()) throw new Error('Informe o título da atividade.');

  const ref = await getRefData();
  const mediaUrl =
    item.mediaType === 'imagem'
      ? await resolveMediaUrl('exercises', item.mediaUrl)
      : item.mediaUrl.trim() || null;

  const payload = {
    skill_id: ref.skillIdByKey(item.skillKey),
    age_bracket_id: ref.bracketIdByCode(item.ageBracketCode),
    codigo: item.codigo.trim() || null,
    titulo: item.titulo.trim(),
    media_type: item.mediaType,
    media_url: mediaUrl,
    nivel: item.nivel,
    plano: item.plano,
    status: item.status,
    objetivo: item.objetivo.trim() || null,
    procedimento: item.procedimento.trim() || null,
    materiais: item.materiais.trim() || null,
    recursos_extras: item.recursosExtras.trim() || null,
    frequencia: item.frequencia.trim() || null,
    brincadeiras: item.brincadeiras.trim() || null,
    hierarquia_dicas: item.hierarquiaDicas.trim() || null,
    resposta_esperada: item.respostaEsperada.trim() || null,
    procedimento_correcao: item.procedimentoCorrecao.trim() || null,
    criterio_avanco: item.criterioAvanco.trim() || null,
    registro_dados: item.registroDados.trim() || null,
    reforcos: item.reforcos.trim() || null,
  };

  if (isEditing) {
    const { data, error } = await supabase.from('exercises').update(payload).eq('id', item.id).select('id');
    assertUpdated(data, error);
  } else {
    const { error } = await supabase.from('exercises').insert(payload);
    if (error) throw new Error(error.message);
  }
}

export function toggleArchiveAtividade(row: WithId): Promise<void> {
  return toggleArchiveStatus('exercises', row);
}
