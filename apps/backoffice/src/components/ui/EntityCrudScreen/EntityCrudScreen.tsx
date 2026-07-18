import { useState, type ReactNode } from 'react';
import { Plus, Edit2, Archive, ArchiveRestore, ArrowLeft, Save } from 'lucide-react';
import { DataTable } from '../DataTable/DataTable';
import type { DataTableColumn } from '../DataTable/DataTable';
import { ConfirmDialog } from '../ConfirmDialog/ConfirmDialog';
import { useArchivableList } from '../../../hooks/useArchivableList';
import type { WithId } from '../../../types/common';
import styles from '../../../styles/crudLayout.module.css';

interface EntityCrudScreenProps<T extends WithId> {
  title: string;
  newLabel: string;
  formTitle: (isEditing: boolean) => string;
  columns: DataTableColumn<T>[];
  initialRows: T[];
  matchesSearch: (row: T, term: string) => boolean;
  emptyItem: () => T;
  searchPlaceholder?: string;
  renderForm: (item: T, update: <K extends keyof T>(key: K, value: T[K]) => void) => ReactNode;
}

export function EntityCrudScreen<T extends WithId>({
  title,
  newLabel,
  formTitle,
  columns,
  initialRows,
  matchesSearch,
  emptyItem,
  searchPlaceholder = 'Buscar...',
  renderForm,
}: EntityCrudScreenProps<T>) {
  const list = useArchivableList<T>(initialRows, matchesSearch);
  const [view, setView] = useState<'list' | 'form'>('list');
  const [editingId, setEditingId] = useState<number | null>(null);
  const [formState, setFormState] = useState<T>(emptyItem());

  function update<K extends keyof T>(key: K, value: T[K]) {
    setFormState((prev) => ({ ...prev, [key]: value }));
  }

  function openNew() {
    setFormState(emptyItem());
    setEditingId(null);
    setView('form');
  }

  function openEdit(row: T) {
    setFormState({ ...row });
    setEditingId(row.id);
    setView('form');
  }

  function handleSave() {
    list.upsert(editingId !== null ? { ...formState, id: editingId } : formState);
    setView('list');
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

          <DataTable
            columns={tableColumns}
            rows={list.filteredRows}
            getRowId={(row) => row.id}
            searchValue={list.searchTerm}
            onSearchChange={list.setSearchTerm}
            searchPlaceholder={searchPlaceholder}
            emptyMessage="Nenhum registro encontrado."
            toolbarExtra={
              <label className={styles.showArchivedToggle}>
                <input
                  type="checkbox"
                  checked={list.showArchived}
                  onChange={(e) => list.setShowArchived(e.target.checked)}
                />
                <span>Mostrar arquivados</span>
              </label>
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
            <button className={styles.primaryButton} onClick={handleSave} type="button">
              <Save size={20} />
              <span>Salvar</span>
            </button>
          </div>

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
        onConfirm={list.confirmArchive}
        onCancel={() => list.setArchiveTarget(null)}
      />
    </div>
  );
}
