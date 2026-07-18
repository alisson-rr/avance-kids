import { useMemo, useState } from 'react';
import type { RecordStatus, WithId } from '../types/common';

/**
 * Shared list state (search, archived filter, archive/unarchive, upsert) for
 * the `ativo` soft-delete pattern used across every catalog screen.
 */
export function useArchivableList<T extends WithId>(
  initialRows: T[],
  matchesSearch: (row: T, term: string) => boolean
) {
  const [rows, setRows] = useState<T[]>(initialRows);
  const [searchTerm, setSearchTerm] = useState('');
  const [showArchived, setShowArchived] = useState(false);
  const [archiveTarget, setArchiveTarget] = useState<T | null>(null);

  const filteredRows = useMemo(() => {
    const term = searchTerm.trim().toLowerCase();
    return rows.filter((row) => {
      if (!showArchived && row.status === 'arquivado') return false;
      if (!term) return true;
      return matchesSearch(row, term);
    });
  }, [rows, searchTerm, showArchived, matchesSearch]);

  function upsert(row: T) {
    setRows((prev) => {
      const exists = prev.some((r) => r.id === row.id);
      if (exists) return prev.map((r) => (r.id === row.id ? row : r));
      const nextId = Math.max(0, ...prev.map((r) => r.id)) + 1;
      return [...prev, { ...row, id: nextId }];
    });
  }

  function confirmArchive() {
    if (!archiveTarget) return;
    const nextStatus: RecordStatus = archiveTarget.status === 'ativo' ? 'arquivado' : 'ativo';
    setRows((prev) => prev.map((r) => (r.id === archiveTarget.id ? { ...r, status: nextStatus } : r)));
    setArchiveTarget(null);
  }

  return {
    rows,
    filteredRows,
    searchTerm,
    setSearchTerm,
    showArchived,
    setShowArchived,
    archiveTarget,
    setArchiveTarget,
    confirmArchive,
    upsert,
  };
}
