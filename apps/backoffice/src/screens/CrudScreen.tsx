import { useMemo, useState } from 'react';
import { Plus, Edit2, Trash2 } from 'lucide-react';
import { Badge, DataTable } from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import styles from './CrudScreen.module.css';

interface CrudScreenProps {
  title: string;
  entity: string;
}

interface CrudRow {
  id: number;
  title: string;
  category: string;
  status: 'Ativo' | 'Inativo';
  date: string;
}

// Mock Data Builder
const mockData: CrudRow[] = Array.from({ length: 8 }).map((_, i) => ({
  id: i + 1,
  title: `Item de Exemplo ${i + 1}`,
  category: ['Comunicação', 'Motor', 'Cognitivo'][i % 3],
  status: i % 4 === 0 ? 'Inativo' : 'Ativo',
  date: `2024-03-0${i + 1}`,
}));

export function CrudScreen({ title }: CrudScreenProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());

  const filteredRows = useMemo(() => {
    const term = searchTerm.trim().toLowerCase();
    if (!term) return mockData;
    return mockData.filter(
      (row) => row.title.toLowerCase().includes(term) || row.category.toLowerCase().includes(term)
    );
  }, [searchTerm]);

  function toggleRow(id: number | string) {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id as number)) next.delete(id as number);
      else next.add(id as number);
      return next;
    });
  }

  function toggleAll(checked: boolean) {
    setSelectedIds(checked ? new Set(filteredRows.map((r) => r.id)) : new Set());
  }

  const columns: DataTableColumn<CrudRow>[] = [
    { key: 'title', header: 'Título', render: (row) => row.title },
    { key: 'category', header: 'Categoria', render: (row) => <Badge variant="neutral">{row.category}</Badge> },
    {
      key: 'status',
      header: 'Status',
      render: (row) => <Badge variant={row.status === 'Ativo' ? 'success' : 'danger'}>{row.status}</Badge>,
    },
    { key: 'date', header: 'Data Criação', render: (row) => row.date },
    {
      key: 'actions',
      header: 'Ações',
      width: '100px',
      render: () => (
        <div className={styles.actions}>
          <button className={styles.iconBtn} title="Editar" type="button">
            <Edit2 size={18} />
          </button>
          <button className={styles.iconBtnDanger} title="Excluir" type="button">
            <Trash2 size={18} />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>{title}</h1>
        <button className={styles.addButton} type="button">
          <Plus size={20} />
          <span>Novo Registro</span>
        </button>
      </div>

      <DataTable
        columns={columns}
        rows={filteredRows}
        getRowId={(row) => row.id}
        searchValue={searchTerm}
        onSearchChange={setSearchTerm}
        emptyMessage="Nenhum registro encontrado."
        selectable
        selectedIds={selectedIds}
        onToggleRow={toggleRow}
        onToggleAll={toggleAll}
      />
    </div>
  );
}
