import { supabase } from '../lib/supabase';
import { resolveMediaUrl } from './storage';
import { assertUpdated, toggleArchiveStatus } from './common';
import type { Brincadeira, ProdutoBrincadeira } from '../types/entities';
import type { AccessPlan } from '../constants/aba';
import type { MediaType, RecordStatus, WithId } from '../types/common';

interface PlayRow {
  id: string;
  codigo: string | null;
  titulo: string;
  descricao: string | null;
  instrucoes: string | null;
  media_type: MediaType;
  media_url: string | null;
  plano: AccessPlan;
  status: RecordStatus;
  play_products: ProductRow[] | null;
}

interface ProductRow {
  id: string;
  titulo: string;
  descricao: string;
  imagem_url: string;
  link_url: string;
  ordem: number;
  status: RecordStatus;
}

export async function fetchBrincadeiras(): Promise<Brincadeira[]> {
  const { data, error } = await supabase
    .from('plays')
    .select(
      'id, codigo, titulo, descricao, instrucoes, media_type, media_url, plano, status, play_products(id, titulo, descricao, imagem_url, link_url, ordem, status)'
    )
    .order('created_at', { ascending: false });
  if (error) throw new Error(error.message);

  return ((data ?? []) as PlayRow[]).map((row) => ({
    id: row.id,
    codigo: row.codigo ?? '',
    titulo: row.titulo,
    descricao: row.descricao ?? '',
    instrucoes: row.instrucoes ?? '',
    mediaType: row.media_type,
    mediaUrl: row.media_url ?? '',
    plano: row.plano,
    status: row.status,
    produtos: (row.play_products ?? [])
      .map((produto) => ({
        id: produto.id,
        titulo: produto.titulo,
        descricao: produto.descricao,
        imagemUrl: produto.imagem_url,
        linkUrl: produto.link_url,
        ordem: produto.ordem,
        status: produto.status,
      }))
      .sort((a, b) => a.ordem - b.ordem),
  }));
}

export async function saveBrincadeira(item: Brincadeira, isEditing: boolean): Promise<void> {
  if (!item.titulo.trim()) throw new Error('Informe o título da brincadeira.');

  item.produtos.forEach(validarProduto);

  const playId = isEditing ? item.id : crypto.randomUUID();

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
    const { error } = await supabase.from('plays').insert({ id: playId, ...payload });
    if (error) throw new Error(error.message);
  }

  await salvarProdutos(playId, item.produtos);
}

function validarProduto(produto: ProdutoBrincadeira): void {
  if (!produto.titulo.trim()) throw new Error('Informe o título de todos os produtos.');
  if (!produto.descricao.trim()) throw new Error('Informe a descrição de todos os produtos.');
  if (!produto.imagemUrl) throw new Error('Selecione uma imagem para todos os produtos.');

  let url: URL;
  try {
    url = new URL(produto.linkUrl.trim());
  } catch {
    throw new Error(`O link do produto “${produto.titulo}” não é uma URL válida.`);
  }

  const host = url.hostname.toLowerCase();
  if (url.protocol !== 'https:' || (host !== 'shopee.com.br' && !host.endsWith('.shopee.com.br'))) {
    throw new Error(`O link do produto “${produto.titulo}” precisa ser da Shopee.`);
  }
}

async function salvarProdutos(playId: string, produtos: ProdutoBrincadeira[]): Promise<void> {
  const payload = await Promise.all(
    produtos.map(async (produto, index) => ({
      id: produto.id,
      play_id: playId,
      titulo: produto.titulo.trim(),
      descricao: produto.descricao.trim(),
      imagem_url: (await resolveMediaUrl(`play-products/${playId}`, produto.imagemUrl))!,
      link_url: produto.linkUrl.trim(),
      ordem: index + 1,
      status: produto.status,
    }))
  );

  if (payload.length > 0) {
    const { error } = await supabase.from('play_products').upsert(payload, { onConflict: 'id' });
    if (error) throw new Error(`Falha ao salvar produtos: ${error.message}`);
  }

  const { data: existentes, error: fetchError } = await supabase
    .from('play_products')
    .select('id')
    .eq('play_id', playId);
  if (fetchError) throw new Error(`Falha ao conferir produtos: ${fetchError.message}`);

  const idsMantidos = new Set(payload.map((produto) => produto.id));
  const idsRemovidos = (existentes ?? [])
    .map((produto) => produto.id as string)
    .filter((id) => !idsMantidos.has(id));

  if (idsRemovidos.length > 0) {
    const { error } = await supabase.from('play_products').delete().in('id', idsRemovidos);
    if (error) throw new Error(`Falha ao remover produtos: ${error.message}`);
  }
}

export function toggleArchiveBrincadeira(row: WithId): Promise<void> {
  return toggleArchiveStatus('plays', row);
}
