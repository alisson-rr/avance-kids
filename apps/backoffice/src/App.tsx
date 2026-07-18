import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
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

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginScreen />} />

        <Route path="/" element={<AdminLayout />}>
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
  );
}

export default App;
