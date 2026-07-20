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

/** Lança se o update não afetou nenhuma linha (RLS ou id inexistente). */
export function assertUpdated(data: unknown[] | null, error: { message: string } | null): void {
  if (error) throw new Error(error.message);
  if (!data || data.length === 0) throw new Error('Sem permissão para alterar este registro.');
}
