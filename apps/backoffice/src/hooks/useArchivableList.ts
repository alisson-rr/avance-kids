import { useMemo, useState } from 'react';
import type { RecordStatus, WithId } from '../types/common';

export type StatusFilter = RecordStatus | 'todos';

export const STATUS_FILTER_OPTIONS: { value: StatusFilter; label: string }[] = [
  { value: 'ativo', label: 'Ativos' },
  { value: 'arquivado', label: 'Arquivados' },
  { value: 'todos', label: 'Todos' },
];

/**
 * Filtros compartilhados (busca, status, alvo de arquivamento) para as listas
 * do padrão soft-delete. Os dados vêm do Supabase (useEntityList) e as
 * mutações ficam na camada de serviços — aqui é só estado de UI.
 */
export function useArchivableList<T extends WithId>(
  rows: T[],
  matchesSearch: (row: T, term: string) => boolean
) {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('ativo');
  const [archiveTarget, setArchiveTarget] = useState<T | null>(null);

  const filteredRows = useMemo(() => {
    const term = searchTerm.trim().toLowerCase();
    return rows.filter((row) => {
      if (statusFilter !== 'todos' && row.status !== statusFilter) return false;
      if (!term) return true;
      return matchesSearch(row, term);
    });
  }, [rows, searchTerm, statusFilter, matchesSearch]);

  return {
    filteredRows,
    searchTerm,
    setSearchTerm,
    statusFilter,
    setStatusFilter,
    archiveTarget,
    setArchiveTarget,
  };
}
