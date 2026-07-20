import { useMemo, useState, type ReactNode } from 'react';
import { Plus, Edit2, Archive, ArchiveRestore, ArrowLeft, Save } from 'lucide-react';
import { DataTable } from '../DataTable/DataTable';
import type { DataTableColumn } from '../DataTable/DataTable';
import { ConfirmDialog } from '../ConfirmDialog/ConfirmDialog';
import { Select } from '../Select/Select';
import { useArchivableList, STATUS_FILTER_OPTIONS } from '../../../hooks/useArchivableList';
import type { WithId } from '../../../types/common';
import styles from '../../../styles/crudLayout.module.css';

export interface EntityFilterConfig<T> {
  key: string;
  allLabel: string;
  options: { value: string; label: string }[];
  getValue: (row: T) => string;
}

interface EntityCrudScreenProps<T extends WithId> {
  title: string;
  newLabel: string;
  formTitle: (isEditing: boolean) => string;
  columns: DataTableColumn<T>[];
  rows: T[];
  loading?: boolean;
  errorMessage?: string | null;
  matchesSearch: (row: T, term: string) => boolean;
  emptyItem: () => T;
  searchPlaceholder?: string;
  filters?: EntityFilterConfig<T>[];
  /** Persiste no Supabase; deve lançar Error com mensagem amigável em falha. */
  onSave: (item: T, isEditing: boolean) => Promise<void>;
  onToggleArchive: (item: T) => Promise<void>;
  renderForm: (item: T, update: <K extends keyof T>(key: K, value: T[K]) => void) => ReactNode;
}

export function EntityCrudScreen<T extends WithId>({
  title,
  newLabel,
  formTitle,
  columns,
  rows,
  loading = false,
  errorMessage = null,
  matchesSearch,
  emptyItem,
  searchPlaceholder = 'Buscar...',
  filters = [],
  onSave,
  onToggleArchive,
  renderForm,
}: EntityCrudScreenProps<T>) {
  const list = useArchivableList<T>(rows, matchesSearch);
  const [view, setView] = useState<'list' | 'form'>('list');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [formState, setFormState] = useState<T>(emptyItem());
  const [filterValues, setFilterValues] = useState<Record<string, string>>({});
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [listError, setListError] = useState<string | null>(null);

  const filteredRows = useMemo(
    () =>
      list.filteredRows.filter((row) =>
        filters.every((f) => {
          const value = filterValues[f.key];
          return !value || f.getValue(row) === value;
        })
      ),
    [list.filteredRows, filters, filterValues]
  );

  function update<K extends keyof T>(key: K, value: T[K]) {
    setFormState((prev) => ({ ...prev, [key]: value }));
  }

  function openNew() {
    setFormState(emptyItem());
    setEditingId(null);
    setFormError(null);
    setView('form');
  }

  function openEdit(row: T) {
    setFormState({ ...row });
    setEditingId(row.id);
    setFormError(null);
    setView('form');
  }

  async function handleSave() {
    if (saving) return;
    setSaving(true);
    setFormError(null);
    try {
      await onSave(formState, editingId !== null);
      setView('list');
    } catch (err) {
      setFormError(err instanceof Error ? err.message : 'Falha ao salvar.');
    } finally {
      setSaving(false);
    }
  }

  async function handleConfirmArchive() {
    const target = list.archiveTarget;
    if (!target) return;
    setListError(null);
    try {
      await onToggleArchive(target);
    } catch (err) {
      setListError(err instanceof Error ? err.message : 'Falha ao atualizar o registro.');
    } finally {
      list.setArchiveTarget(null);
    }
  }

  const tableColumns: DataTableColumn<T>[] = [
    ...columns,
    {
      key: '__actions',
      header: 'Ações',
      width: '100px',
      render: (row) => (
        <div className={styles.actions}>
          <button className={styles.iconBtn} onClick={() => openEdit(row)} title="Editar" type="button">
            <Edit2 size={18} />
          </button>
          <button
            className={styles.iconBtnDanger}
            onClick={() => list.setArchiveTarget(row)}
            title={row.status === 'ativo' ? 'Arquivar' : 'Reativar'}
            type="button"
          >
            {row.status === 'ativo' ? <Archive size={18} /> : <ArchiveRestore size={18} />}
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className={styles.container}>
      {view === 'list' ? (
        <>
          <div className={styles.header}>
            <h1 className={styles.title}>{title}</h1>
            <button className={styles.primaryButton} onClick={openNew} type="button">
              <Plus size={20} />
              <span>{newLabel}</span>
            </button>
          </div>

          {(errorMessage || listError) && <p className={styles.errorBanner}>{errorMessage || listError}</p>}

          <DataTable
            columns={tableColumns}
            rows={filteredRows}
            getRowId={(row) => row.id}
            searchValue={list.searchTerm}
            onSearchChange={list.setSearchTerm}
            searchPlaceholder={searchPlaceholder}
            emptyMessage={loading ? 'Carregando...' : 'Nenhum registro encontrado.'}
            toolbarExtra={
              <div className={styles.filterRow}>
                {filters.map((f) => (
                  <div key={f.key} className={styles.filterItem}>
                    <Select
                      value={filterValues[f.key] ?? ''}
                      onChange={(v) => setFilterValues((prev) => ({ ...prev, [f.key]: v }))}
                      options={[{ value: '', label: f.allLabel }, ...f.options]}
                    />
                  </div>
                ))}
                <div className={styles.filterItem}>
                  <Select
                    value={list.statusFilter}
                    onChange={(v) => list.setStatusFilter(v as typeof list.statusFilter)}
                    options={STATUS_FILTER_OPTIONS}
                  />
                </div>
              </div>
            }
          />
        </>
      ) : (
        <>
          <div className={styles.header}>
            <div className={styles.backWrapper}>
              <button className={styles.iconBtn} onClick={() => setView('list')} type="button">
                <ArrowLeft size={24} />
              </button>
              <h1 className={styles.title}>{formTitle(editingId !== null)}</h1>
            </div>
            <button className={styles.primaryButton} onClick={handleSave} type="button" disabled={saving}>
              <Save size={20} />
              <span>{saving ? 'Salvando...' : 'Salvar'}</span>
            </button>
          </div>

          {formError && <p className={styles.errorBanner}>{formError}</p>}

          <div className={styles.formCard}>
            <div className={styles.formContent}>
              <div className={styles.gridContainer}>{renderForm(formState, update)}</div>
            </div>
          </div>
        </>
      )}

      <ConfirmDialog
        open={list.archiveTarget !== null}
        title={list.archiveTarget?.status === 'ativo' ? 'Arquivar registro?' : 'Reativar registro?'}
        message={
          list.archiveTarget?.status === 'ativo'
            ? 'O registro deixa de aparecer para os usuários, mas continua no histórico. Você pode reativá-lo depois.'
            : 'O registro volta a ficar disponível para os usuários.'
        }
        confirmLabel={list.archiveTarget?.status === 'ativo' ? 'Arquivar' : 'Reativar'}
        danger={list.archiveTarget?.status === 'ativo'}
        onConfirm={handleConfirmArchive}
        onCancel={() => list.setArchiveTarget(null)}
      />
    </div>
  );
}
