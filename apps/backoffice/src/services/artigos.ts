import { supabase } from '../lib/supabase';
import { resolveMediaUrl } from './storage';
import { assertUpdated, toggleArchiveStatus } from './common';
import type { Artigo } from '../types/entities';
import type { AccessPlan } from '../constants/aba';
import type { RecordStatus, WithId } from '../types/common';

interface ArticleRow {
  id: string;
  titulo: string;
  corpo: string;
  imagem_url: string | null;
  plano: AccessPlan;
  status: RecordStatus;
}

export async function fetchArtigos(): Promise<Artigo[]> {
  const { data, error } = await supabase
    .from('articles')
    .select('id, titulo, corpo, imagem_url, plano, status')
    .order('created_at', { ascending: false });
  if (error) throw new Error(error.message);

  return ((data ?? []) as ArticleRow[]).map((row) => ({
    id: row.id,
    titulo: row.titulo,
    corpo: row.corpo,
    imagemUrl: row.imagem_url ?? '',
    plano: row.plano,
    status: row.status,
  }));
}

export async function saveArtigo(item: Artigo, isEditing: boolean): Promise<void> {
  if (!item.titulo.trim()) throw new Error('Informe o título do artigo.');
  if (!item.corpo.trim()) throw new Error('O corpo do artigo não pode ficar vazio.');

  const payload = {
    titulo: item.titulo.trim(),
    corpo: item.corpo,
    imagem_url: await resolveMediaUrl('articles', item.imagemUrl),
    plano: item.plano,
    status: item.status,
  };

  if (isEditing) {
    const { data, error } = await supabase.from('articles').update(payload).eq('id', item.id).select('id');
    assertUpdated(data, error);
  } else {
    const { error } = await supabase.from('articles').insert(payload);
    if (error) throw new Error(error.message);
  }
}

export function toggleArchiveArtigo(row: WithId): Promise<void> {
  return toggleArchiveStatus('articles', row);
}
