import { useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import styles from './LoginScreen.module.css';

export function LoginScreen() {
  const navigate = useNavigate();
  const { admin, signIn } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  if (admin) return <Navigate to="/" replace />;

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    const message = await signIn(email.trim(), password);
    setSubmitting(false);

    if (message) {
      setError(message);
      return;
    }
    navigate('/');
  };

  return (
    <div className={styles.container}>
      <div className={styles.card}>
        <div className={styles.header}>
          <div className={styles.logo}>A</div>
          <h1 className={styles.title}>Avance Kids Admin</h1>
          <p className={styles.subtitle}>Acesso restrito</p>
        </div>

        <form onSubmit={handleLogin} className={styles.form}>
          <div className={styles.inputGroup}>
            <label>E-mail administrativo</label>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              placeholder="admin@avancekids.com"
              required
            />
          </div>
          <div className={styles.inputGroup}>
            <label>Senha</label>
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="••••••••"
              required
            />
          </div>

          {error && <p style={{ color: 'var(--color-danger, #DC2626)', fontSize: 14 }}>{error}</p>}

          <button type="submit" className={styles.button} disabled={submitting}>
            {submitting ? 'Entrando...' : 'Entrar'}
          </button>
        </form>
      </div>
    </div>
  );
}
