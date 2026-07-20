import { supabase } from '../lib/supabase';
import type { ArticleRow, PlayRow } from '../types/db';

export async function fetchPlays(limit = 10): Promise<PlayRow[]> {
  const { data, error } = await supabase
    .from('plays')
    .select('id, titulo, descricao, instrucoes, media_type, media_url, plano')
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw new Error(error.message);
  return data ?? [];
}

export async function fetchArticles(limit = 10): Promise<ArticleRow[]> {
  const { data, error } = await supabase
    .from('articles')
    .select('id, titulo, corpo, imagem_url, plano')
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw new Error(error.message);
  return data ?? [];
}
