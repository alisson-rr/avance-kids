import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import { makeRedirectUri } from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import type { ProfileRow } from '../types/db';
import { digitsOnly, toIsoDate } from '../utils/formatters';

WebBrowser.maybeCompleteAuthSession();

export interface ParentSignUpInput {
  nome: string;
  email: string;
  senha: string;
  /** Data no formato BR (dd/mm/aaaa). */
  nascimento: string;
  genero?: string;
  cpf: string;
  telefone?: string;
}

export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email: email.trim(),
    password,
  });
  if (error) throw new Error(traduzErroAuth(error.message));
  return data.session;
}

/**
 * Login Google hospedado pelo Supabase.
 *
 * O Client ID e o Client Secret ficam exclusivamente no painel do Supabase;
 * o aplicativo recebe apenas a sessão devolvida pelo callback profundo.
 */
export async function signInWithGoogle() {
  const redirectTo = makeRedirectUri({ scheme: 'avancekids', path: 'auth/callback' });
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: { redirectTo, skipBrowserRedirect: true },
  });

  if (error) throw new Error(traduzErroAuth(error.message));
  if (!data.url) throw new Error('Não foi possível iniciar o login com Google.');

  const result = await WebBrowser.openAuthSessionAsync(data.url, redirectTo);
  if (result.type === 'cancel' || result.type === 'dismiss') return null;
  if (result.type !== 'success') throw new Error('Não foi possível concluir o login com Google.');

  const callbackUrl = new URL(result.url);
  const query = callbackUrl.searchParams;
  const fragment = new URLSearchParams(callbackUrl.hash.replace(/^#/, ''));
  const getParam = (name: string) => query.get(name) ?? fragment.get(name);
  const oauthError = getParam('error_description') ?? getParam('error');
  if (oauthError) throw new Error(oauthError);

  const code = getParam('code');
  if (code) {
    const { data: sessionData, error: sessionError } = await supabase.auth.exchangeCodeForSession(code);
    if (sessionError) throw new Error(traduzErroAuth(sessionError.message));
    return sessionData.session;
  }

  const accessToken = getParam('access_token');
  const refreshToken = getParam('refresh_token');
  if (!accessToken || !refreshToken) throw new Error('O Google não devolveu uma sessão válida.');

  const { data: sessionData, error: sessionError } = await supabase.auth.setSession({
    access_token: accessToken,
    refresh_token: refreshToken,
  });
  if (sessionError) throw new Error(traduzErroAuth(sessionError.message));
  return sessionData.session;
}

/**
 * Cadastro do responsável. Todos os campos vão nos metadados do signup e o
 * trigger handle_new_user (migration-02) grava o perfil completo — funciona
 * mesmo quando o projeto exige confirmação de e-mail (signup sem sessão).
 */
export async function signUpParent(input: ParentSignUpInput) {
  const { data, error } = await supabase.auth.signUp({
    email: input.email.trim(),
    password: input.senha,
    options: {
      data: {
        nome: input.nome.trim(),
        cpf: digitsOnly(input.cpf),
        data_nascimento: toIsoDate(input.nascimento),
        genero: input.genero || '',
        telefone: digitsOnly(input.telefone ?? ''),
        termos_aceitos: true,
      },
    },
  });
  if (error) throw new Error(traduzErroAuth(error.message));

  return { session: data.session, needsEmailConfirmation: !data.session };
}

/**
 * Encerra a sessão garantindo que ela saia do dispositivo.
 *
 * O auth-js só apaga a sessão do armazenamento local depois que o POST
 * /logout responde: em falha de rede ele retorna antes, e o erro era
 * descartado aqui — o usuário tocava em "Sair", nada acontecia e ele
 * continuava logado sem nenhum aviso. O `scope: 'local'` é o mesmo recurso já
 * usado em `deleteAccount`, e resolve sem depender da rede.
 */
export async function signOut() {
  const { error } = await supabase.auth.signOut();
  if (!error) return;

  const { error: erroLocal } = await supabase.auth.signOut({ scope: 'local' });
  if (erroLocal) throw new Error(erroLocal.message);
}

/**
 * Exclusão definitiva da conta.
 *
 * O servidor (delete-account) cancela a assinatura no Stripe, remove os
 * arquivos do usuário no Storage, grava o log pseudonimizado e apaga a conta
 * do Auth — o CASCADE leva perfil, crianças, respostas, planos, sessões,
 * tentativas e aceites (migration-07).
 *
 * `scope: 'local'` no signOut é proposital: o usuário do Auth já não existe,
 * então um logout global bateria em /logout com um token morto e falharia. O
 * que importa aqui é limpar a sessão guardada no dispositivo.
 */
export async function deleteAccount(): Promise<void> {
  await invokeFunction('delete-account', { confirmacao: 'EXCLUIR' });
  await supabase.auth.signOut({ scope: 'local' });
}

export async function resetPassword(email: string) {
  const { error } = await supabase.auth.resetPasswordForEmail(email.trim());
  if (error) throw new Error(traduzErroAuth(error.message));
}

/** Reautentica com a senha atual antes de trocar (updateUser não valida a antiga). */
export async function changePassword(currentPassword: string, newPassword: string) {
  const { data: userData } = await supabase.auth.getUser();
  const email = userData.user?.email;
  if (!email) throw new Error('Sessão expirada. Faça login novamente.');

  const { error: reauthError } = await supabase.auth.signInWithPassword({
    email,
    password: currentPassword,
  });
  if (reauthError) throw new Error('Senha atual incorreta.');

  const { error } = await supabase.auth.updateUser({ password: newPassword });
  if (error) throw new Error(traduzErroAuth(error.message));
}

export async function fetchProfile(): Promise<ProfileRow | null> {
  const { data: userData } = await supabase.auth.getUser();
  if (!userData.user) return null;

  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userData.user.id)
    .maybeSingle();
  if (error) throw new Error(error.message);
  return data;
}

export async function updateProfile(patch: Partial<Omit<ProfileRow, 'id'>>) {
  const { data: userData } = await supabase.auth.getUser();
  if (!userData.user) throw new Error('Sessão expirada. Faça login novamente.');

  const { error } = await supabase.from('profiles').update(patch).eq('id', userData.user.id);
  if (error) throw new Error(error.message);
}

function traduzErroAuth(message: string): string {
  const m = message.toLowerCase();
  if (m.includes('invalid login credentials')) return 'E-mail ou senha inválidos.';
  if (m.includes('email not confirmed')) return 'Confirme seu e-mail antes de entrar.';
  if (m.includes('user already registered')) return 'Este e-mail já está cadastrado.';
  if (m.includes('password should be at least')) return 'A senha deve ter pelo menos 6 caracteres.';
  if (m.includes('network')) return 'Falha de conexão. Verifique sua internet.';
  return message;
}
