import { createClient } from '@supabase/supabase-js';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppState, Platform } from 'react-native';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '';

if (!supabaseUrl || !supabaseAnonKey || supabaseAnonKey === 'COLE_AQUI_A_ANON_KEY') {
  console.warn(
    '[supabase] EXPO_PUBLIC_SUPABASE_URL / EXPO_PUBLIC_SUPABASE_ANON_KEY não configuradas em apps/mobile/.env',
  );
}

/**
 * Retorno do e-mail "Esqueci a senha" no app web. Lido antes de criar o
 * cliente, que troca a sessão do link e limpa a URL. `accessToken` nulo =
 * link expirado ou já usado.
 */
export const linkDeSenha = lerLinkDeSenha();

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    // Só o link de nova senha; o retorno do login Google é tratado em auth.ts.
    detectSessionInUrl: (_url, params) => params.type === 'recovery',
  },
});

function lerLinkDeSenha(): { accessToken: string | null } | null {
  if (Platform.OS !== 'web' || typeof window === 'undefined') return null;
  const params = new URLSearchParams(window.location.hash.slice(1));
  if (params.get('type') !== 'recovery' && params.get('error_code') !== 'otp_expired') return null;
  return { accessToken: params.get('access_token') };
}

// Renova o token apenas com o app em foreground (recomendação do guia Supabase+Expo).
AppState.addEventListener('change', (state) => {
  if (state === 'active') {
    supabase.auth.startAutoRefresh();
  } else {
    supabase.auth.stopAutoRefresh();
  }
});
