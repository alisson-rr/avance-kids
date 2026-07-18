import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Activity, 
  Gamepad2, 
  FileText, 
  MessageSquare, 
  CheckSquare, 
  LogOut,
  Users
} from 'lucide-react';
import styles from './AdminLayout.module.css';

const navItems = [
  { path: '/', label: 'Dashboard', icon: <LayoutDashboard size={20} /> },
  { path: '/users', label: 'Usuários Admin', icon: <Users size={20} /> },
  { path: '/activities', label: 'Atividades', icon: <Activity size={20} /> },
  { path: '/games', label: 'Brincadeiras', icon: <Gamepad2 size={20} /> },
  { path: '/articles', label: 'Artigos', icon: <FileText size={20} /> },
  { path: '/initial-questions', label: 'Perguntas Iniciais', icon: <MessageSquare size={20} /> },
  { path: '/triage-questions', label: 'Perguntas Triagem', icon: <CheckSquare size={20} /> },
];

export function AdminLayout() {
  const navigate = useNavigate();

  const handleLogout = () => {
    navigate('/login');
  };

  return (
    <div className={styles.layout}>
      {/* Sidebar */}
      <aside className={styles.sidebar}>
        <div className={styles.logoContainer}>
          <img src="/logo.svg" alt="Avance Kids" className={styles.logoImage} />
        </div>
        
        <nav className={styles.nav}>
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => 
                isActive ? `${styles.navItem} ${styles.navItemActive}` : styles.navItem
              }
            >
              {item.icon}
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>

        <div className={styles.sidebarFooter}>
          <NavLink to="/profile" className={styles.userProfile}>
            <div className={styles.avatar}>AD</div>
            <div className={styles.userInfo}>
              <span className={styles.userName}>Administrador</span>
              <span className={styles.userRole}>admin@avancekids.com</span>
            </div>
          </NavLink>
          <button className={styles.logoutButton} onClick={handleLogout}>
            <LogOut size={20} />
            <span>Sair</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className={styles.mainContent}>
        {/* Page Content */}
        <main className={styles.pageContent}>
          <Outlet />
        </main>
      </div>
    </div>
  );
}
