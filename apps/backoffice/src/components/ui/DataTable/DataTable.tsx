import type { ReactNode } from 'react';
import { Search, Filter } from 'lucide-react';
import styles from './DataTable.module.css';

export interface DataTableColumn<T> {
  key: string;
  header: string;
  width?: string;
  render: (row: T) => ReactNode;
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
}

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
}: DataTableProps<T>) {
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
              {columns.map((col) => (
                <th key={col.key} style={col.width ? { width: col.width } : undefined}>
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.length === 0 ? (
              <tr>
                <td className={styles.emptyCell} colSpan={columns.length + (selectable ? 1 : 0)}>
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              rows.map((row) => {
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

      {rows.length > 0 && (
        <div className={styles.pagination}>
          <span className={styles.pageInfo}>
            Mostrando 1 a {rows.length} de {rows.length} registros
          </span>
        </div>
      )}
    </div>
  );
}
