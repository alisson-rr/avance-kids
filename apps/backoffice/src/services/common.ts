import { supabase } from '../lib/supabase';
import type { RecordStatus, WithId } from '../types/common';

/**
 * Alterna ativo <-> arquivado. Usa .select() para detectar updates silenciados
 * pela RLS (0 linhas afetadas = sem permissão).
 */
export async function toggleArchiveStatus(table: string, row: WithId): Promise<void> {
  const nextStatus: RecordStatus = row.status === 'ativo' ? 'arquivado' : 'ativo';
  const { data, error } = await supabase
    .from(table)
    .update({ status: nextStatus })
    .eq('id', row.id)
    .select('id');

  if (error) throw new Error(error.message);
  if (!data || data.length === 0) throw new Error('Sem permissão para alterar este registro.');
}

const PAGE_SIZE = 1000;

/**
 * Busca todas as linhas em lotes: o PostgREST corta cada resposta em max_rows
 * (supabase/config.toml). Avança pelo número de linhas recebidas, e não pelo
 * tamanho pedido, para continuar correto se o servidor tiver um limite menor.
 */
export async function fetchAllRows<T>(
  page: (from: number, to: number) => PromiseLike<{ data: T[] | null; error: { message: string } | null }>
): Promise<T[]> {
  const rows: T[] = [];
  for (;;) {
    const from = rows.length;
    const { data, error } = await page(from, from + PAGE_SIZE - 1);
    if (error) throw new Error(error.message);
    if (!data || data.length === 0) return rows;
    rows.push(...data);
  }
}

/** Lança se o update não afetou nenhuma linha (RLS ou id inexistente). */
export function assertUpdated(data: unknown[] | null, error: { message: string } | null): void {
  if (error) throw new Error(error.message);
  if (!data || data.length === 0) throw new Error('Sem permissão para alterar este registro.');
}
