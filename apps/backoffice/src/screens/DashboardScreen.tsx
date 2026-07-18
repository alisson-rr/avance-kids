import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Users, Activity, FileText } from 'lucide-react';
import styles from './DashboardScreen.module.css';

const data = [
  { name: 'Jan', cadastros: 40 },
  { name: 'Fev', cadastros: 30 },
  { name: 'Mar', cadastros: 20 },
  { name: 'Abr', cadastros: 27 },
  { name: 'Mai', cadastros: 18 },
  { name: 'Jun', cadastros: 23 },
  { name: 'Jul', cadastros: 34 },
];

export function DashboardScreen() {
  return (
    <div className={styles.container}>
      <h1 className={styles.title}>Dashboard</h1>
      
      {/* Stat Cards */}
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div>
              <p className={styles.statLabel}>Total de Usuários</p>
              <h3 className={styles.statValue}>1,248</h3>
            </div>
            <div className={styles.iconWrapper}><Users size={24} color="var(--color-primary)" /></div>
          </div>
          <div className={styles.statChartMock}>
            {/* Mock small chart line */}
            <div className={styles.sparkline}></div>
          </div>
        </div>

        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div>
              <p className={styles.statLabel}>Atividades Concluídas</p>
              <h3 className={styles.statValue}>8,432</h3>
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
              <p className={styles.statLabel}>Novos Artigos</p>
              <h3 className={styles.statValue}>12</h3>
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
        <h2 className={styles.sectionTitle}>Cadastros de Novos Pais (2024)</h2>
        <div className={styles.chartContainer}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={data}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E0E0E0" />
              <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#666'}} />
              <YAxis axisLine={false} tickLine={false} tick={{fill: '#666'}} />
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
               <button className={styles.moreBtn}>...</button>
            </div>
            <div className={styles.listItem}>
               <div className={styles.itemIcon}><Activity size={16} /></div>
               <div className={styles.itemInfo}>
                  <p className={styles.itemName}>Brincar com blocos</p>
                  <p className={styles.itemSub}>Coordenação motora</p>
               </div>
               <div className={styles.itemStatus}>Ativo</div>
            </div>
            <div className={styles.listItem}>
               <div className={styles.itemIcon}><Activity size={16} /></div>
               <div className={styles.itemInfo}>
                  <p className={styles.itemName}>Imitar sons</p>
                  <p className={styles.itemSub}>Comunicação</p>
               </div>
               <div className={styles.itemStatus}>Ativo</div>
            </div>
         </div>

         <div className={styles.listCard}>
            <div className={styles.listHeader}>
               <h3 className={styles.listTitle}>Últimos Artigos Publicados</h3>
               <button className={styles.moreBtn}>...</button>
            </div>
            <div className={styles.listItem}>
               <div className={styles.itemIcon}><FileText size={16} /></div>
               <div className={styles.itemInfo}>
                  <p className={styles.itemName}>Importância do Sono</p>
                  <p className={styles.itemSub}>Dicas para pais</p>
               </div>
               <div className={styles.itemStatus}>Ativo</div>
            </div>
         </div>
      </div>
    </div>
  );
}
