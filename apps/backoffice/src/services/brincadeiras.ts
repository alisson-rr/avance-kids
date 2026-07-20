import { supabase } from '../lib/supabase';
import { resolveMediaUrl } from './storage';
import { assertUpdated, toggleArchiveStatus } from './common';
import type { Brincadeira } from '../types/entities';
import type { AccessPlan } from '../constants/aba';
import type { MediaType, RecordStatus, WithId } from '../types/common';

interface PlayRow {
  id: string;
  titulo: string;
  descricao: string | null;
  instrucoes: string | null;
  media_type: MediaType;
  media_url: string | null;
  plano: AccessPlan;
  status: RecordStatus;
}

export async function fetchBrincadeiras(): Promise<Brincadeira[]> {
  const { data, error } = await supabase
    .from('plays')
    .select('id, titulo, descricao, instrucoes, media_type, media_url, plano, status')
    .order('created_at', { ascending: false });
  if (error) throw new Error(error.message);

  return ((data ?? []) as PlayRow[]).map((row) => ({
    id: row.id,
    titulo: row.titulo,
    descricao: row.descricao ?? '',
    instrucoes: row.instrucoes ?? '',
    mediaType: row.media_type,
    mediaUrl: row.media_url ?? '',
    plano: row.plano,
    status: row.status,
  }));
}

export async function saveBrincadeira(item: Brincadeira, isEditing: boolean): Promise<void> {
  if (!item.titulo.trim()) throw new Error('Informe o título da brincadeira.');

  const mediaUrl =
    item.mediaType === 'imagem'
      ? await resolveMediaUrl('plays', item.mediaUrl)
      : item.mediaUrl.trim() || null;

  const payload = {
    titulo: item.titulo.trim(),
    descricao: item.descricao.trim() || null,
    instrucoes: item.instrucoes.trim() || null,
    media_type: item.mediaType,
    media_url: mediaUrl,
    plano: item.plano,
    status: item.status,
  };

  if (isEditing) {
    const { data, error } = await supabase.from('plays').update(payload).eq('id', item.id).select('id');
    assertUpdated(data, error);
  } else {
    const { error } = await supabase.from('plays').insert(payload);
    if (error) throw new Error(error.message);
  }
}

export function toggleArchiveBrincadeira(row: WithId): Promise<void> {
  return toggleArchiveStatus('plays', row);
}
