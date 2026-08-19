import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import type { TermsAcceptanceRow, TermsDocumentRow } from '../types/db';

const TIPO_TERMOS = 'termos_e_privacidade';

/**
 * Documento vigente segundo o servidor. Quem decide qual versão está valendo é
 * `terms_documents.vigente` (migration-06), nunca o app — por isso a versão
 * não é constante no client.
 *
 * A policy permite leitura por `anon`, então funciona no cadastro, antes de
 * existir sessão. Devolve null quando não dá para consultar (offline, por
 * exemplo): o modal continua exibindo o texto embutido.
 */
export async function fetchTermosVigentes(): Promise<TermsDocumentRow | null> {
  const { data, error } = await supabase
    .from('terms_documents')
    .select('id, tipo, versao, titulo, url')
    .eq('tipo', TIPO_TERMOS)
    .eq('vigente', true)
    .maybeSingle();

  if (error) return null;
  return data;
}

/**
 * Registra o aceite com trilha de auditoria (usuário, versão, data, IP).
 *
 * Nenhuma versão é enviada: o servidor resolve a vigente e carimba o resto.
 * Idempotente — reenviar não duplica nem reescreve a data do primeiro aceite.
 */
export async function registrarAceiteTermos(): Promise<TermsAcceptanceRow[]> {
  const { aceites } = await invokeFunction<{ aceites: TermsAcceptanceRow[] }>(
    'accept-terms',
    { tipos: [TIPO_TERMOS] },
  );
  return aceites;
}
