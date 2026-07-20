import { supabase } from '../lib/supabase';
import { assertUpdated, toggleArchiveStatus } from './common';
import type { AdminUser, AdminRole } from '../types/entities';
import type { RecordStatus, WithId } from '../types/common';

interface AdminRow {
  id: string;
  nome: string;
  email: string;
  role: AdminRole;
  status: RecordStatus;
}

export async function fetchAdmins(): Promise<AdminUser[]> {
  const { data, error } = await supabase
    .from('admin_users')
    .select('id, nome, email, role, status')
    .order('created_at', { ascending: false });
  if (error) throw new Error(error.message);
  return (data ?? []) as AdminRow[];
}

/**
 * Criação passa pela edge function admin-create-user (precisa da Auth Admin
 * API); edição atualiza direto — a RLS garante que só super_admin consegue.
 * O e-mail de login não é editável por aqui (mudança de e-mail exige fluxo
 * de confirmação no Auth).
 */
export async function saveAdmin(item: AdminUser, isEditing: boolean): Promise<void> {
  if (!item.nome.trim()) throw new Error('Informe o nome.');

  if (isEditing) {
    const { data, error } = await supabase
      .from('admin_users')
      .update({ nome: item.nome.trim(), role: item.role, status: item.status })
      .eq('id', item.id)
      .select('id');
    assertUpdated(data, error);
    return;
  }

  if (!item.email.trim()) throw new Error('Informe o e-mail.');
  if (!item.password || item.password.length < 8) {
    throw new Error('A senha inicial precisa ter pelo menos 8 caracteres.');
  }

  const { data, error } = await supabase.functions.invoke('admin-create-user', {
    body: {
      nome: item.nome.trim(),
      email: item.email.trim(),
      password: item.password,
      role: item.role,
    },
  });

  if (error) {
    // FunctionsHttpError: o corpo da resposta traz a mensagem real
    const context = (error as { context?: Response }).context;
    if (context) {
      const body = await context.json().catch(() => null);
      if (body?.error) throw new Error(body.error);
    }
    throw new Error(error.message);
  }
  if (!data?.admin) throw new Error('Resposta inesperada ao criar admin.');
}

export function toggleArchiveAdmin(row: WithId): Promise<void> {
  return toggleArchiveStatus('admin_users', row);
}
