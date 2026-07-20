import { supabase } from '../lib/supabase';
import type { ProfileRow } from '../types/db';
import { digitsOnly, toIsoDate } from '../utils/formatters';

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

export async function signOut() {
  await supabase.auth.signOut();
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
