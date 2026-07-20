import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from 'react';
import { supabase } from '../lib/supabase';
import type { AdminRole } from '../types/entities';

export interface CurrentAdmin {
  id: string;
  nome: string;
  email: string;
  role: AdminRole;
}

interface AuthContextValue {
  /** true enquanto a sessão inicial ainda está sendo restaurada. */
  loading: boolean;
  admin: CurrentAdmin | null;
  /** Retorna mensagem de erro, ou null em caso de sucesso. */
  signIn: (email: string, password: string) => Promise<string | null>;
  signOut: () => Promise<void>;
  refreshAdmin: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

const ACCESS_DENIED = 'Esta conta não tem acesso ao painel administrativo.';

/**
 * Carrega o registro de admin_users do usuário logado. Contas sem registro
 * ativo (usuários do app, admins arquivados) são deslogadas na hora.
 */
async function loadAdmin(userId: string): Promise<CurrentAdmin | null> {
  const { data } = await supabase
    .from('admin_users')
    .select('id, nome, email, role, status')
    .eq('id', userId)
    .maybeSingle();

  if (!data || data.status !== 'ativo') return null;
  return { id: data.id, nome: data.nome, email: data.email, role: data.role as AdminRole };
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [loading, setLoading] = useState(true);
  const [admin, setAdmin] = useState<CurrentAdmin | null>(null);

  useEffect(() => {
    let cancelled = false;

    supabase.auth.getSession().then(async ({ data: { session } }) => {
      if (cancelled) return;
      if (session?.user) {
        const current = await loadAdmin(session.user.id);
        if (!current) await supabase.auth.signOut();
        if (!cancelled) setAdmin(current);
      }
      if (!cancelled) setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((event) => {
      if (event === 'SIGNED_OUT') setAdmin(null);
    });

    return () => {
      cancelled = true;
      subscription.unsubscribe();
    };
  }, []);

  const signIn = useCallback(async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error || !data.user) return error?.message ?? 'Falha ao entrar.';

    const current = await loadAdmin(data.user.id);
    if (!current) {
      await supabase.auth.signOut();
      return ACCESS_DENIED;
    }

    setAdmin(current);
    return null;
  }, []);

  const signOut = useCallback(async () => {
    await supabase.auth.signOut();
    setAdmin(null);
  }, []);

  const refreshAdmin = useCallback(async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (session?.user) setAdmin(await loadAdmin(session.user.id));
  }, []);

  return (
    <AuthContext.Provider value={{ loading, admin, signIn, signOut, refreshAdmin }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth deve ser usado dentro de <AuthProvider>');
  return ctx;
}
