import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AdminLayout } from './components/Layout/AdminLayout';
import { LoginScreen } from './screens/LoginScreen';
import { DashboardScreen } from './screens/DashboardScreen';
import { CrudScreen } from './screens/CrudScreen';
import { ActivitiesScreen } from './screens/ActivitiesScreen';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginScreen />} />
        
        <Route path="/" element={<AdminLayout />}>
          <Route index element={<DashboardScreen />} />
          <Route path="users" element={<CrudScreen title="Usuários Admin" entity="user" />} />
          <Route path="activities" element={<ActivitiesScreen />} />
          <Route path="games" element={<CrudScreen title="Brincadeiras" entity="game" />} />
          <Route path="articles" element={<CrudScreen title="Artigos" entity="article" />} />
          <Route path="initial-questions" element={<CrudScreen title="Perguntas Iniciais" entity="initial_question" />} />
          <Route path="triage-questions" element={<CrudScreen title="Perguntas Triagem" entity="triage_question" />} />
        </Route>
        
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
