import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import type { ChildRow } from '../types/db';
import { digitsOnly, toIsoDate } from '../utils/formatters';

export interface RegisterChildInput {
  nome: string;
  /** Data no formato BR (dd/mm/aaaa). */
  nascimento: string;
  genero?: string;
  cpf?: string;
  condicoes: string[];
}

export async function registerChild(input: RegisterChildInput): Promise<ChildRow> {
  const dataIso = toIsoDate(input.nascimento);
  if (!dataIso) throw new Error('Data de nascimento inválida. Use dd/mm/aaaa.');

  const cpfDigits = digitsOnly(input.cpf ?? '');
  const { child } = await invokeFunction<{ child: ChildRow }>('register-child', {
    nome: input.nome.trim(),
    data_nascimento: dataIso,
    genero: input.genero || undefined,
    cpf: cpfDigits.length === 11 ? cpfDigits : undefined,
    condicoes: input.condicoes.filter((c) => c !== 'Nenhum'),
  });
  return child;
}

export async function listChildren(): Promise<ChildRow[]> {
  const { data, error } = await supabase
    .from('children')
    .select('*')
    .order('created_at', { ascending: false });
  if (error) throw new Error(error.message);
  return data ?? [];
}

export async function fetchChild(childId: string): Promise<ChildRow | null> {
  const { data, error } = await supabase
    .from('children')
    .select('*')
    .eq('id', childId)
    .maybeSingle();
  if (error) throw new Error(error.message);
  return data;
}

export async function updateChild(
  childId: string,
  patch: Partial<
    Pick<ChildRow, 'nome' | 'data_nascimento' | 'genero' | 'cpf' | 'condicoes' | 'avatar_url'>
  >,
) {
  const { error } = await supabase.from('children').update(patch).eq('id', childId);
  if (error) throw new Error(error.message);
}
