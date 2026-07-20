import { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Users, Activity, FileText } from 'lucide-react';
import { fetchDashboardStats, type DashboardStats } from '../services/dashboard';
import layout from '../styles/crudLayout.module.css';
import styles from './DashboardScreen.module.css';

function formatCount(value: number | undefined, loading: boolean): string {
  if (loading || value === undefined) return '…';
  return value.toLocaleString('pt-BR');
}

export function DashboardScreen() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchDashboardStats()
      .then(setStats)
      .catch((err) => setError(err instanceof Error ? err.message : 'Falha ao carregar o dashboard.'))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>Dashboard</h1>

      {error && <p className={layout.errorBanner}>{error}</p>}

      {/* Stat Cards */}
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div>
              <p className={styles.statLabel}>Total de Usuários</p>
              <h3 className={styles.statValue}>{formatCount(stats?.totalUsers, loading)}</h3>
            </div>
            <div className={styles.iconWrapper}><Users size={24} color="var(--color-primary)" /></div>
          </div>
          <div className={styles.statChartMock}>
            <div className={styles.sparkline}></div>
          </div>
        </div>

        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div>
              <p className={styles.statLabel}>Planos Concluídos</p>
              <h3 className={styles.statValue}>{formatCount(stats?.completedActivities, loading)}</h3>
            </div>
            <div className={styles.iconWrapper}><Activity size={24} color="var(--color-success)" /></div>
          </div>
          <div className={styles.statChartMock}>
             <div className={styles.sparkline} style={{ borderBottomColor: 'var(--color-success)'}}></div>
          </div>
        </div>

        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div>
              <p className={styles.statLabel}>Artigos Ativos</p>
              <h3 className={styles.statValue}>{formatCount(stats?.totalArticles, loading)}</h3>
            </div>
            <div className={styles.iconWrapper}><FileText size={24} color="var(--color-danger)" /></div>
          </div>
          <div className={styles.statChartMock}>
            <div className={styles.sparkline} style={{ borderBottomColor: 'var(--color-danger)'}}></div>
          </div>
        </div>
      </div>

      {/* Main Chart */}
      <div className={styles.chartSection}>
        <h2 className={styles.sectionTitle}>Cadastros de Novos Pais (últimos 12 meses)</h2>
        <div className={styles.chartContainer}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={stats?.signupsByMonth ?? []}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E0E0E0" />
              <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#666'}} />
              <YAxis axisLine={false} tickLine={false} allowDecimals={false} tick={{fill: '#666'}} />
              <Tooltip cursor={{fill: '#F4F7FB'}} />
              <Bar dataKey="cadastros" fill="var(--color-primary)" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Bottom Lists */}
      <div className={styles.listsGrid}>
         <div className={styles.listCard}>
            <div className={styles.listHeader}>
               <h3 className={styles.listTitle}>Últimas Atividades Criadas</h3>
            </div>
            {loading && <p className={styles.itemSub}>Carregando...</p>}
            {!loading && (stats?.latestExercises.length ?? 0) === 0 && (
              <p className={styles.itemSub}>Nenhuma atividade cadastrada ainda.</p>
            )}
            {stats?.latestExercises.map((item) => (
              <div className={styles.listItem} key={item.id}>
                 <div className={styles.itemIcon}><Activity size={16} /></div>
                 <div className={styles.itemInfo}>
                    <p className={styles.itemName}>{item.titulo}</p>
                    <p className={styles.itemSub}>{item.skillNome}</p>
                 </div>
                 <div className={styles.itemStatus}>{item.status === 'ativo' ? 'Ativo' : 'Arquivado'}</div>
              </div>
            ))}
         </div>

         <div className={styles.listCard}>
            <div className={styles.listHeader}>
               <h3 className={styles.listTitle}>Últimos Artigos Publicados</h3>
            </div>
            {loading && <p className={styles.itemSub}>Carregando...</p>}
            {!loading && (stats?.latestArticles.length ?? 0) === 0 && (
              <p className={styles.itemSub}>Nenhum artigo cadastrado ainda.</p>
            )}
            {stats?.latestArticles.map((item) => (
              <div className={styles.listItem} key={item.id}>
                 <div className={styles.itemIcon}><FileText size={16} /></div>
                 <div className={styles.itemInfo}>
                    <p className={styles.itemName}>{item.titulo}</p>
                    <p className={styles.itemSub}>{item.status === 'ativo' ? 'Publicado' : 'Arquivado'}</p>
                 </div>
                 <div className={styles.itemStatus}>{item.status === 'ativo' ? 'Ativo' : 'Arquivado'}</div>
              </div>
            ))}
         </div>
      </div>
    </div>
  );
}
