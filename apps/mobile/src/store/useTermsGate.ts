import { criarTermsGate } from '../services/termsGate';
import { gateDeps } from '../services/terms';

/**
 * Instância real do bloqueio de reaceite, ligada ao Supabase.
 *
 * A lógica está em services/termsGate.ts, que não importa nada de rede — é o
 * que permite testar o sequenciamento com fakes em scripts/test_terms_gate.ts.
 */
export const useTermsGate = criarTermsGate(gateDeps);
