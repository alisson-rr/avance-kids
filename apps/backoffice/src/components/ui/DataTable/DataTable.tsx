import { useEffect, useMemo, useState, type ReactNode } from 'react';
import { Search, Filter, ArrowUp, ArrowDown, ArrowUpDown, ChevronLeft, ChevronRight } from 'lucide-react';
import styles from './DataTable.module.css';

const DEFAULT_PAGE_SIZE = 10;

/** Janela de páginas visíveis: com muitas páginas, colapsa o miolo em reticências. */
function buildPageList(current: number, total: number): (number | 'ellipsis')[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);

  const pages: (number | 'ellipsis')[] = [1];
  const first = Math.max(2, current - 1);
  const last = Math.min(total - 1, current + 1);

  if (first > 2) pages.push('ellipsis');
  for (let page = first; page <= last; page++) pages.push(page);
  if (last < total - 1) pages.push('ellipsis');
  pages.push(total);

  return pages;
}

export interface DataTableColumn<T> {
  key: string;
  header: string;
  width?: string;
  render: (row: T) => ReactNode;
  /** Se presente, o cabeçalho fica clicável e ordena a tabela por este valor. */
  sortValue?: (row: T) => string | number;
}

interface DataTableProps<T> {
  columns: DataTableColumn<T>[];
  rows: T[];
  getRowId: (row: T) => string | number;
  searchValue: string;
  onSearchChange: (value: string) => void;
  searchPlaceholder?: string;
  toolbarExtra?: ReactNode;
  emptyMessage?: string;
  selectable?: boolean;
  selectedIds?: Set<string | number>;
  onToggleRow?: (id: string | number) => void;
  onToggleAll?: (checked: boolean) => void;
  /** Registros por página. */
  pageSize?: number;
}

type SortDirection = 'asc' | 'desc';

export function DataTable<T>({
  columns,
  rows,
  getRowId,
  searchValue,
  onSearchChange,
  searchPlaceholder = 'Buscar...',
  toolbarExtra,
  emptyMessage = 'Nenhum registro encontrado.',
  selectable,
  selectedIds,
  onToggleRow,
  onToggleAll,
  pageSize = DEFAULT_PAGE_SIZE,
}: DataTableProps<T>) {
  const [sortKey, setSortKey] = useState<string | null>(null);
  const [sortDirection, setSortDirection] = useState<SortDirection>('asc');
  const [currentPage, setCurrentPage] = useState(1);

  function handleHeaderClick(column: DataTableColumn<T>) {
    if (!column.sortValue) return;
    if (sortKey === column.key) {
      setSortDirection((dir) => (dir === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(column.key);
      setSortDirection('asc');
    }
  }

  const sortedRows = useMemo(() => {
    const sortColumn = columns.find((c) => c.key === sortKey);
    if (!sortColumn?.sortValue) return rows;
    const { sortValue } = sortColumn;
    const factor = sortDirection === 'asc' ? 1 : -1;
    return [...rows].sort((a, b) => {
      const va = sortValue(a);
      const vb = sortValue(b);
      if (typeof va === 'number' && typeof vb === 'number') return (va - vb) * factor;
      return String(va).localeCompare(String(vb), 'pt-BR') * factor;
    });
  }, [rows, columns, sortKey, sortDirection]);

  // Busca, filtros (mudam a contagem) e reordenação sempre voltam para a 1ª página.
  useEffect(() => {
    setCurrentPage(1);
  }, [searchValue, sortedRows.length, sortKey, sortDirection]);

  const totalPages = Math.max(1, Math.ceil(sortedRows.length / pageSize));
  // Clamp: filtrar enquanto está numa página alta não pode deixar a tabela vazia.
  const page = Math.min(currentPage, totalPages);
  const pagedRows = useMemo(
    () => sortedRows.slice((page - 1) * pageSize, page * pageSize),
    [sortedRows, page, pageSize]
  );

  const firstShown = sortedRows.length === 0 ? 0 : (page - 1) * pageSize + 1;
  const lastShown = Math.min(page * pageSize, sortedRows.length);

  const allSelected = selectable && rows.length > 0 && rows.every((r) => selectedIds?.has(getRowId(r)));

  return (
    <div className={styles.tableCard}>
      <div className={styles.toolbar}>
        <div className={styles.searchBox}>
          <Search size={18} color="var(--color-text-light)" />
          <input
            type="text"
            placeholder={searchPlaceholder}
            value={searchValue}
            onChange={(e) => onSearchChange(e.target.value)}
          />
        </div>
        {toolbarExtra ?? (
          <button className={styles.filterBtn} type="button">
            <Filter size={18} />
            <span>Filtros</span>
          </button>
        )}
      </div>

      <div className={styles.tableWrapper}>
        <table className={styles.table}>
          <thead>
            <tr>
              {selectable && (
                <th style={{ width: '40px' }}>
                  <input
                    type="checkbox"
                    checked={allSelected}
                    onChange={(e) => onToggleAll?.(e.target.checked)}
                  />
                </th>
              )}
              {columns.map((col) => {
                const isSortable = !!col.sortValue;
                const isActive = isSortable && sortKey === col.key;
                return (
                  <th
                    key={col.key}
                    style={col.width ? { width: col.width } : undefined}
                    className={isSortable ? styles.sortableHeader : undefined}
                    onClick={isSortable ? () => handleHeaderClick(col) : undefined}
                  >
                    <span className={styles.headerContent}>
                      {col.header}
                      {isSortable &&
                        (isActive ? (
                          sortDirection === 'asc' ? (
                            <ArrowUp size={14} />
                          ) : (
                            <ArrowDown size={14} />
                          )
                        ) : (
                          <ArrowUpDown size={14} className={styles.sortIconIdle} />
                        ))}
                    </span>
                  </th>
                );
              })}
            </tr>
          </thead>
          <tbody>
            {sortedRows.length === 0 ? (
              <tr>
                <td className={styles.emptyCell} colSpan={columns.length + (selectable ? 1 : 0)}>
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              pagedRows.map((row) => {
                const id = getRowId(row);
                return (
                  <tr key={id}>
                    {selectable && (
                      <td>
                        <input
                          type="checkbox"
                          checked={selectedIds?.has(id) ?? false}
                          onChange={() => onToggleRow?.(id)}
                        />
                      </td>
                    )}
                    {columns.map((col) => (
                      <td key={col.key}>{col.render(row)}</td>
                    ))}
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {sortedRows.length > 0 && (
        <div className={styles.pagination}>
          <span className={styles.pageInfo}>
            Mostrando {firstShown} a {lastShown} de {sortedRows.length} registros
          </span>

          {totalPages > 1 && (
            <div className={styles.pageControls}>
              <button
                className={styles.pageBtn}
                type="button"
                onClick={() => setCurrentPage(page - 1)}
                disabled={page === 1}
                title="Página anterior"
              >
                <ChevronLeft size={16} />
              </button>

              {buildPageList(page, totalPages).map((item, index) =>
                item === 'ellipsis' ? (
                  <span key={`ellipsis-${index}`} className={styles.pageEllipsis}>
                    …
                  </span>
                ) : (
                  <button
                    key={item}
                    className={item === page ? styles.pageBtnActive : styles.pageBtn}
                    type="button"
                    onClick={() => setCurrentPage(item)}
                  >
                    {item}
                  </button>
                )
              )}

              <button
                className={styles.pageBtn}
                type="button"
                onClick={() => setCurrentPage(page + 1)}
                disabled={page === totalPages}
                title="Próxima página"
              >
                <ChevronRight size={16} />
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
