import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import type { GateDeps } from './termsGate';
import type { TermsAcceptanceRow, TermsDocumentRow } from '../types/db';

const TIPO_TERMOS = 'termos_e_privacidade';

/**
 * Documento vigente segundo o servidor. Quem decide qual versão está valendo é
 * `terms_documents.vigente` (migration-06), nunca o app — por isso a versão
 * não é constante no client.
 *
 * Lança quando a consulta falha e devolve null só quando realmente não há
 * documento vigente. Os dois casos precisam ser distinguíveis: o gate de
 * reaceite não pode tratar erro de rede como "nada a aceitar".
 */
async function consultarVigente(): Promise<TermsDocumentRow | null> {
  const { data, error } = await supabase
    .from('terms_documents')
    .select('id, tipo, versao, titulo, url')
    .eq('tipo', TIPO_TERMOS)
    .eq('vigente', true)
    .maybeSingle();

  if (error) throw new Error(error.message);
  return data;
}

/**
 * Versão vigente para exibição. A policy permite leitura por `anon`, então
 * funciona no cadastro, antes de existir sessão. Devolve null quando não dá
 * para consultar (offline, por exemplo): o modal continua exibindo o texto
 * embutido em vez de ficar vazio.
 */
export async function fetchTermosVigentes(): Promise<TermsDocumentRow | null> {
  try {
    return await consultarVigente();
  } catch {
    return null;
  }
}

/**
 * Prova de consentimento de um usuário para um documento específico.
 *
 * O filtro por `user_id` é explícito de propósito: `terms_acceptances` tem
 * DUAS policies permissivas de SELECT (migration-06) — a do próprio usuário e
 * a de admin — e policies permissivas se somam com OR. Para quem está em
 * `admin_users`, deixar a RLS ser o único escopo faria esta consulta enxergar
 * o aceite de outras contas: com uma linha, liberaria o app sem aceite nenhum;
 * com duas ou mais, `maybeSingle()` erraria e travaria a conta no gate.
 *
 * O UNIQUE (user_id, document_id) garante no máximo uma linha — por isso
 * `maybeSingle()` basta.
 */
async function temAceiteRegistrado(documentId: string, usuarioId: string): Promise<boolean> {
  const { data, error } = await supabase
    .from('terms_acceptances')
    .select('id')
    .eq('user_id', usuarioId)
    .eq('document_id', documentId)
    .maybeSingle();

  if (error) throw new Error(error.message);
  return data !== null;
}

/**
 * Registra o aceite com trilha de auditoria (usuário, versão, data, IP).
 *
 * O servidor continua resolvendo a versão vigente e carimbando o resto — o
 * client não escolhe versão. `documentId` apenas AFIRMA qual documento estava
 * na tela: se uma versão nova passou a vigorar enquanto o usuário lia, a
 * function responde 409 em vez de gravar consentimento a um texto que ele não
 * viu. Sem `documentId` (cadastro, onde o aceite é o do checkbox), o
 * comportamento é o de antes.
 *
 * Idempotente — reenviar não duplica nem reescreve a data do primeiro aceite.
 */
export async function registrarAceiteTermos(documentId?: string): Promise<TermsAcceptanceRow[]> {
  const { aceites } = await invokeFunction<{ aceites: TermsAcceptanceRow[] }>(
    'accept-terms',
    documentId ? { tipos: [TIPO_TERMOS], document_id: documentId } : { tipos: [TIPO_TERMOS] },
  );
  return aceites;
}

/** Ligação entre a decisão pura (termsGate.ts) e o Supabase. */
export const gateDeps: GateDeps = {
  documentoVigente: consultarVigente,
  temAceite: temAceiteRegistrado,
  registrarAceite: async (documentId) => {
    await registrarAceiteTermos(documentId);
  },
};
