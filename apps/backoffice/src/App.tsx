import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import type { ReactNode } from 'react';
import { AuthProvider, useAuth } from './auth/AuthContext';
import { AdminLayout } from './components/Layout/AdminLayout';
import { LoginScreen } from './screens/LoginScreen';
import { DashboardScreen } from './screens/DashboardScreen';
import { ActivitiesScreen } from './screens/ActivitiesScreen';
import { AdminUsersScreen } from './screens/AdminUsersScreen';
import { GamesScreen } from './screens/GamesScreen';
import { ArticlesScreen } from './screens/ArticlesScreen';
import { InitialQuestionsScreen } from './screens/InitialQuestionsScreen';
import { TriageQuestionsScreen } from './screens/TriageQuestionsScreen';
import { AdminProfileScreen } from './screens/AdminProfileScreen';

function RequireAdmin({ children }: { children: ReactNode }) {
  const { loading, admin } = useAuth();

  if (loading) {
    return <div style={{ display: 'grid', placeItems: 'center', minHeight: '100vh' }}>Carregando...</div>;
  }
  if (!admin) return <Navigate to="/login" replace />;

  return children;
}

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginScreen />} />

          <Route
            path="/"
            element={
              <RequireAdmin>
                <AdminLayout />
              </RequireAdmin>
            }
          >
            <Route index element={<DashboardScreen />} />
            <Route path="users" element={<AdminUsersScreen />} />
            <Route path="activities" element={<ActivitiesScreen />} />
            <Route path="games" element={<GamesScreen />} />
            <Route path="articles" element={<ArticlesScreen />} />
            <Route path="initial-questions" element={<InitialQuestionsScreen />} />
            <Route path="triage-questions" element={<TriageQuestionsScreen />} />
            <Route path="profile" element={<AdminProfileScreen />} />
          </Route>

          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
