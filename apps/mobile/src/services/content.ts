import { supabase } from '../lib/supabase';
import type { ArticleRow, PlayProductRow, PlayRow } from '../types/db';

// Views do banco (migration-05): listam o item premium com `bloqueado = true`
// e sem o conteúdo pago. Ler as tabelas direto devolveria só o que é free.
export async function fetchPlays(limit?: number): Promise<PlayRow[]> {
  let query = supabase
    .from('plays_feed')
    .select('id, codigo, titulo, descricao, instrucoes, media_type, media_url, plano, bloqueado')
    .order('codigo', { ascending: true, nullsFirst: false })
    .order('created_at', { ascending: false });
  if (limit !== undefined) query = query.limit(limit);
  const { data, error } = await query;
  if (error) throw new Error(error.message);
  return data ?? [];
}

export async function fetchPlayProducts(playId: string): Promise<PlayProductRow[]> {
  const { data, error } = await supabase
    .from('play_products')
    .select('id, play_id, titulo, descricao, imagem_url, link_url, ordem')
    .eq('play_id', playId)
    .eq('status', 'ativo')
    .order('ordem', { ascending: true });
  if (error) throw new Error(error.message);
  return data ?? [];
}

export async function fetchArticles(limit?: number): Promise<ArticleRow[]> {
  let query = supabase
    .from('articles_feed')
    .select('id, titulo, corpo, imagem_url, plano, bloqueado')
    .order('created_at', { ascending: false });
  if (limit !== undefined) query = query.limit(limit);
  const { data, error } = await query;
  if (error) throw new Error(error.message);
  return data ?? [];
}
