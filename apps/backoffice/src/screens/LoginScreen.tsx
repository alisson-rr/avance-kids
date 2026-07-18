import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './LoginScreen.module.css';

export function LoginScreen() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
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
          <button type="submit" className={styles.button}>Entrar</button>
        </form>
      </div>
    </div>
  );
}
