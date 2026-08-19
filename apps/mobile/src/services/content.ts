import { supabase } from '../lib/supabase';
import type { ArticleRow, PlayRow } from '../types/db';

// Views do banco (migration-05): listam o item premium com `bloqueado = true`
// e sem o conteúdo pago. Ler as tabelas direto devolveria só o que é free.
export async function fetchPlays(limit = 10): Promise<PlayRow[]> {
  const { data, error } = await supabase
    .from('plays_feed')
    .select('id, titulo, descricao, instrucoes, media_type, media_url, plano, bloqueado')
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw new Error(error.message);
  return data ?? [];
}

export async function fetchArticles(limit = 10): Promise<ArticleRow[]> {
  const { data, error } = await supabase
    .from('articles_feed')
    .select('id, titulo, corpo, imagem_url, plano, bloqueado')
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw new Error(error.message);
  return data ?? [];
}
