import { useState } from 'react';
import { Plus, Edit2, Trash2, Search, Filter } from 'lucide-react';
import styles from './CrudScreen.module.css';

interface CrudScreenProps {
  title: string;
  entity: string;
}

// Mock Data Builder
const mockData = Array.from({ length: 8 }).map((_, i) => ({
  id: i + 1,
  title: `Item de Exemplo ${i + 1}`,
  category: ['Comunicação', 'Motor', 'Cognitivo'][i % 3],
  status: i % 4 === 0 ? 'Inativo' : 'Ativo',
  date: `2024-03-0${i + 1}`,
}));

export function CrudScreen({ title }: CrudScreenProps) {
  const [searchTerm, setSearchTerm] = useState('');

  return (
    <div className={styles.container}>
      {/* Header */}
      <div className={styles.header}>
        <h1 className={styles.title}>{title}</h1>
        <button className={styles.addButton}>
          <Plus size={20} />
          <span>Novo Registro</span>
        </button>
      </div>

      <div className={styles.tableCard}>
        {/* Toolbar */}
        <div className={styles.toolbar}>
          <div className={styles.searchBox}>
            <Search size={18} color="var(--color-text-light)" />
            <input 
              type="text" 
              placeholder="Buscar..." 
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
            />
          </div>
          <button className={styles.filterBtn}>
            <Filter size={18} />
            <span>Filtros</span>
          </button>
        </div>

        {/* Table */}
        <div className={styles.tableWrapper}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th style={{ width: '40px' }}><input type="checkbox" /></th>
                <th>Título</th>
                <th>Categoria</th>
                <th>Status</th>
                <th>Data Criação</th>
                <th style={{ width: '100px' }}>Ações</th>
              </tr>
            </thead>
            <tbody>
              {mockData.map((row) => (
                <tr key={row.id}>
                  <td><input type="checkbox" /></td>
                  <td className={styles.primaryCell}>{row.title}</td>
                  <td>
                    <span className={styles.badgeNeutral}>{row.category}</span>
                  </td>
                  <td>
                    <span className={row.status === 'Ativo' ? styles.badgeSuccess : styles.badgeError}>
                      {row.status}
                    </span>
                  </td>
                  <td className={styles.dateCell}>{row.date}</td>
                  <td>
                    <div className={styles.actions}>
                      <button className={styles.iconBtn} title="Editar">
                        <Edit2 size={18} />
                      </button>
                      <button className={styles.iconBtnDanger} title="Excluir">
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination Mock */}
        <div className={styles.pagination}>
           <span className={styles.pageInfo}>Mostrando 1 a 8 de 42 registros</span>
           <div className={styles.pageControls}>
              <button disabled>&lt;</button>
              <button className={styles.activePage}>1</button>
              <button>2</button>
              <button>3</button>
              <button>&gt;</button>
           </div>
        </div>
      </div>
    </div>
  );
}
