import { useState } from 'react';
import { Save } from 'lucide-react';
import { Badge, FormField } from '../components/ui';
import layout from '../styles/crudLayout.module.css';
import styles from './AdminProfileScreen.module.css';

const CURRENT_ADMIN = {
  nome: 'Administrador',
  email: 'admin@avancekids.com',
  role: 'super_admin' as const,
};

export function AdminProfileScreen() {
  const [nome, setNome] = useState(CURRENT_ADMIN.nome);
  const [email, setEmail] = useState(CURRENT_ADMIN.email);
  const [senhaAtual, setSenhaAtual] = useState('');
  const [novaSenha, setNovaSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');
  const [feedback, setFeedback] = useState<{ type: 'ok' | 'error'; text: string } | null>(null);

  function handleSave() {
    if (novaSenha && novaSenha !== confirmarSenha) {
      setFeedback({ type: 'error', text: 'A nova senha e a confirmação não coincidem.' });
      return;
    }
    setSenhaAtual('');
    setNovaSenha('');
    setConfirmarSenha('');
    setFeedback({ type: 'ok', text: 'Alterações salvas.' });
  }

  return (
    <div className={layout.container}>
      <div className={layout.header}>
        <h1 className={layout.title}>Meu Perfil</h1>
        <button className={layout.primaryButton} onClick={handleSave} type="button">
          <Save size={20} />
          <span>Salvar Alterações</span>
        </button>
      </div>

      <div className={layout.formCard}>
        <div className={layout.formContent}>
          <div className={layout.gridContainer}>
            <FormField label="Nome" required>
              <input type="text" value={nome} onChange={(e) => setNome(e.target.value)} />
            </FormField>

            <FormField label="Email" required>
              <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
            </FormField>

            <FormField label="Papel">
              <div>
                <Badge variant="info">
                  {CURRENT_ADMIN.role === 'super_admin' ? 'Super Administrador' : 'Administrador'}
                </Badge>
              </div>
            </FormField>
          </div>
        </div>
      </div>

      <div className={layout.formCard}>
        <div className={layout.formContent}>
          <h2 className={styles.sectionTitle}>Alterar Senha</h2>
          <div className={layout.gridContainer}>
            <FormField label="Senha Atual" fullWidth>
              <input type="password" value={senhaAtual} onChange={(e) => setSenhaAtual(e.target.value)} />
            </FormField>

            <FormField label="Nova Senha">
              <input type="password" value={novaSenha} onChange={(e) => setNovaSenha(e.target.value)} />
            </FormField>

            <FormField label="Confirmar Nova Senha">
              <input type="password" value={confirmarSenha} onChange={(e) => setConfirmarSenha(e.target.value)} />
            </FormField>
          </div>
        </div>
      </div>

      {feedback && (
        <p className={feedback.type === 'ok' ? styles.savedMessage : styles.errorMessage}>{feedback.text}</p>
      )}
    </div>
  );
}
