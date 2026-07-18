import { useState } from 'react';
import { Plus, Edit2, Trash2, Search, Filter, ArrowLeft, Save } from 'lucide-react';
import styles from './ActivitiesScreen.module.css';

// Mock Data
const mockData = [
  { id: 1, code: 'F03AC004', skill: 'Nomeia objetos', program: 'Comunicação Básica', isPremium: false },
  { id: 2, code: 'F01AM001', skill: 'Pular', program: 'Coordenação Motora', isPremium: true },
];

export function ActivitiesScreen() {
  const [view, setView] = useState<'list' | 'form'>('list');
  const [activeTab, setActiveTab] = useState<'basic' | 'execution' | 'evaluation'>('basic');

  return (
    <div className={styles.container}>
      {view === 'list' ? (
        <>
          {/* HEADER LIST */}
          <div className={styles.header}>
            <h1 className={styles.title}>Cadastro de Atividades</h1>
            <button className={styles.primaryButton} onClick={() => setView('form')}>
              <Plus size={20} />
              <span>Nova Atividade</span>
            </button>
          </div>

          <div className={styles.tableCard}>
            <div className={styles.toolbar}>
              <div className={styles.searchBox}>
                <Search size={18} color="var(--color-text-light)" />
                <input type="text" placeholder="Buscar por código ou nome..." />
              </div>
              <button className={styles.filterBtn}>
                <Filter size={18} />
                <span>Filtros</span>
              </button>
            </div>

            <div className={styles.tableWrapper}>
              <table className={styles.table}>
                <thead>
                  <tr>
                    <th>Código</th>
                    <th>Habilidade</th>
                    <th>Programa ABA</th>
                    <th>Plano</th>
                    <th style={{ width: '100px' }}>Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {mockData.map((row) => (
                    <tr key={row.id}>
                      <td className={styles.primaryCell}>{row.code}</td>
                      <td>{row.skill}</td>
                      <td>{row.program}</td>
                      <td>
                        <span className={row.isPremium ? styles.badgePremium : styles.badgeFree}>
                          {row.isPremium ? 'Premium' : 'Gratuito'}
                        </span>
                      </td>
                      <td>
                        <div className={styles.actions}>
                          <button className={styles.iconBtn} onClick={() => setView('form')}><Edit2 size={18} /></button>
                          <button className={styles.iconBtnDanger}><Trash2 size={18} /></button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      ) : (
        <>
          {/* HEADER FORM */}
          <div className={styles.header}>
            <div className={styles.backWrapper}>
              <button className={styles.iconBtn} onClick={() => setView('list')}>
                <ArrowLeft size={24} />
              </button>
              <h1 className={styles.title}>Nova Atividade (Programa ABA)</h1>
            </div>
            <button className={styles.primaryButton} onClick={() => setView('list')}>
              <Save size={20} />
              <span>Salvar Atividade</span>
            </button>
          </div>

          <div className={styles.formCard}>
            {/* TABS */}
            <div className={styles.tabs}>
              <button 
                className={`${styles.tab} ${activeTab === 'basic' ? styles.tabActive : ''}`}
                onClick={() => setActiveTab('basic')}
              >
                1. Informações Básicas
              </button>
              <button 
                className={`${styles.tab} ${activeTab === 'execution' ? styles.tabActive : ''}`}
                onClick={() => setActiveTab('execution')}
              >
                2. Execução & Materiais
              </button>
              <button 
                className={`${styles.tab} ${activeTab === 'evaluation' ? styles.tabActive : ''}`}
                onClick={() => setActiveTab('evaluation')}
              >
                3. Critérios & Avaliação
              </button>
            </div>

            {/* FORM FIELDS */}
            <div className={styles.formContent}>
              {activeTab === 'basic' && (
                <div className={styles.gridContainer}>
                  <div className={styles.inputGroup}>
                    <label>Código da Atividade *</label>
                    <input type="text" placeholder="Ex: F03AC004" />
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Habilidade *</label>
                    <input type="text" placeholder="Ex: Nomeia objetos do cotidiano" />
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Programa ABA *</label>
                    <input type="text" placeholder="Nome do programa..." />
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Função</label>
                    <input type="text" placeholder="Ex: Comunicação" />
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Nível</label>
                    <input type="text" placeholder="Nível de dificuldade" />
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Plano de Acesso</label>
                    <select>
                      <option>Gratuito (Free)</option>
                      <option>Premium (Pago)</option>
                    </select>
                  </div>
                  <div className={`${styles.inputGroup} ${styles.fullWidth}`}>
                    <label>Objetivo *</label>
                    <textarea rows={3} placeholder="Descreva o objetivo da atividade..."></textarea>
                  </div>
                </div>
              )}

              {activeTab === 'execution' && (
                <div className={styles.gridContainer}>
                  <div className={`${styles.inputGroup} ${styles.fullWidth}`}>
                    <label>Procedimento (Passo a Passo) *</label>
                    <textarea rows={5} placeholder="Descreva o passo a passo da execução..."></textarea>
                  </div>
                  <div className={`${styles.inputGroup} ${styles.fullWidth}`}>
                    <label>Materiais Necessários</label>
                    <textarea rows={2} placeholder="Ex: Blocos lógicos, cartões..."></textarea>
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Recursos Extras</label>
                    <input type="text" placeholder="Recursos visuais ou links" />
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Frequência Recomendada</label>
                    <input type="text" placeholder="Ex: 3x na semana" />
                  </div>
                  <div className={`${styles.inputGroup} ${styles.fullWidth}`}>
                    <label>Exemplos de Brincadeiras</label>
                    <textarea rows={3} placeholder="Ideias de como aplicar na prática..."></textarea>
                  </div>
                </div>
              )}

              {activeTab === 'evaluation' && (
                <div className={styles.gridContainer}>
                  <div className={styles.inputGroup}>
                    <label>Hierarquia de Dicas</label>
                    <textarea rows={3} placeholder="Dica física total -> Dica leve..."></textarea>
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Resposta Esperada</label>
                    <textarea rows={3} placeholder="O que a criança deve fazer..."></textarea>
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Procedimento de Correção</label>
                    <textarea rows={3} placeholder="Como corrigir se errar..."></textarea>
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Critério de Avanço</label>
                    <textarea rows={3} placeholder="Ex: 3 acertos seguidos..."></textarea>
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Registro de Dados (Detalhado)</label>
                    <textarea rows={3} placeholder="Como registrar os acertos..."></textarea>
                  </div>
                  <div className={styles.inputGroup}>
                    <label>Exemplos de Reforços</label>
                    <textarea rows={3} placeholder="O que usar como prêmio..."></textarea>
                  </div>
                </div>
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
}
