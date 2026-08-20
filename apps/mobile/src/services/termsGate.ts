import { create } from 'zustand';
import type { TermsDocumentRow } from '../types/db';

/**
 * Bloqueio de reaceite dos termos: decisão e sequenciamento, sem React e sem
 * Supabase.
 *
 * Fica isolado porque as regras que importam são todas sobre o que fazer
 * quando algo dá errado, e é aí que uma refatoração quebra sem o caminho feliz
 * mudar:
 *
 *   - "não consegui verificar" nunca pode virar "já aceitou";
 *   - resultado de uma chamada antiga não pode sobrescrever o estado de outra
 *     sessão (trocou de conta, perdeu a sessão no meio);
 *   - o aceite vale para o documento que estava na tela, não para o que virou
 *     vigente enquanto o usuário lia.
 *
 * A fonte da verdade é `terms_documents` (vigente) + `terms_acceptances` (linha
 * do usuário para aquele documento). `profiles.termos_aceitos` não serve: nasce
 * true no cadastro e ninguém o reseta quando uma versão nova passa a vigorar.
 *
 * Cenários cobertos em scripts/test_terms_gate.ts.
 */

export type EstadoGate =
  | { tipo: 'ocioso' }
  | { tipo: 'verificando' }
  | { tipo: 'liberado' }
  /** `erro` aqui é a falha do registro, com o documento ainda em tela. */
  | { tipo: 'pendente'; documento: TermsDocumentRow; erro?: unknown }
  /** Não deu nem para descobrir se precisa aceitar. Nunca vira 'liberado'. */
  | { tipo: 'erro'; erro: unknown };

export interface GateDeps {
  /** Documento vigente segundo o servidor. Lança se a consulta falhar. */
  documentoVigente: () => Promise<TermsDocumentRow | null>;
  /** Existe aceite DESTE usuário para ESTE documento? Lança se falhar. */
  temAceite: (documentId: string, usuarioId: string) => Promise<boolean>;
  /** Chama accept-terms afirmando qual documento foi exibido. Lança se falhar. */
  registrarAceite: (documentId: string) => Promise<void>;
}

export async function avaliarGate(deps: GateDeps, usuarioId: string): Promise<EstadoGate> {
  try {
    const documento = await deps.documentoVigente();
    // Sem documento vigente não há o que aceitar — não é o mesmo que falhar.
    if (!documento) return { tipo: 'liberado' };

    return (await deps.temAceite(documento.id, usuarioId))
      ? { tipo: 'liberado' }
      : { tipo: 'pendente', documento };
  } catch (erro) {
    return { tipo: 'erro', erro };
  }
}

export async function aceitarGate(
  deps: GateDeps,
  documento: TermsDocumentRow,
  usuarioId: string,
): Promise<EstadoGate> {
  try {
    await deps.registrarAceite(documento.id);
    return { tipo: 'liberado' };
  } catch (erro) {
    // Uma das causas possíveis é o 409 de accept-terms: a versão vigente mudou
    // enquanto a tela estava aberta. Insistir no documento antigo deixaria o
    // usuário preso num texto que já não vale, então reavalia — e só volta ao
    // documento anterior se nem isso funcionar.
    const novo = await avaliarGate(deps, usuarioId);
    if (novo.tipo === 'liberado') return novo;
    if (novo.tipo === 'pendente') return { ...novo, erro };
    return { tipo: 'pendente', documento, erro };
  }
}

interface TermsGateStore {
  estado: EstadoGate;
  /** true enquanto accept-terms está em voo (spinner do botão). */
  enviando: boolean;
  avaliar: (usuarioId: string | null) => Promise<void>;
  /** Repete a avaliação para o mesmo usuário — botão "Tentar novamente". */
  reavaliar: () => Promise<void>;
  aceitar: () => Promise<void>;
  /** Silencia o gate enquanto o cadastro registra o próprio aceite. */
  suspender: () => void;
  retomar: (reavaliar?: boolean) => void;
  limpar: () => void;
}

/**
 * A fábrica recebe as dependências para que o sequenciamento possa ser testado
 * com fakes — foi exatamente aqui que moraram os dois piores defeitos da
 * primeira versão (resultado atrasado sobrescrevendo estado de outra sessão, e
 * suspensão que nunca era desfeita). A instância real fica em
 * store/useTermsGate.ts.
 */
export function criarTermsGate(deps: GateDeps) {
  // Fora do store de propósito: mudar qualquer um destes não deve
  // re-renderizar ninguém.
  let sequencia = 0; // descarta resposta de uma chamada que já foi superada
  let suspenso = false;
  let usuarioId: string | null = null;

  return create<TermsGateStore>((set, get) => ({
    estado: { tipo: 'ocioso' },
    enviando: false,

    avaliar: async (id) => {
      usuarioId = id;

      // Sem sessão a consulta rodaria como `anon`: a RLS devolveria zero
      // linhas em terms_acceptances e o gate acusaria pendência de um usuário
      // que nem está logado.
      if (!id || suspenso) return;

      const meu = ++sequencia;
      set({ estado: { tipo: 'verificando' } });
      const estado = await avaliarGate(deps, id);
      if (meu === sequencia && !suspenso) set({ estado });
    },

    reavaliar: () => get().avaliar(usuarioId),

    aceitar: async () => {
      const atual = get().estado;
      const dono = usuarioId;
      if (atual.tipo !== 'pendente' || !dono || get().enviando) return;

      // Mesma guarda de avaliar(): sem ela, um aceite que responde depois de a
      // sessão cair reabre o bloqueio para um usuário que já não existe — e o
      // gate fica sem saída, porque nada mais mexe no estado.
      const meu = ++sequencia;
      set({ enviando: true });
      const estado = await aceitarGate(deps, atual.documento, dono);

      if (meu !== sequencia || dono !== usuarioId || suspenso) {
        set({ enviando: false });
        return;
      }
      set({ estado, enviando: false });
    },

    // ponytail: a suspensão é global e só é desfeita por retomar() ou
    // limpar(). Se a chamada de cadastro nunca liquidar, o gate fica desligado
    // até o timeout de rede da plataforma — janela curta e que se resolve
    // sozinha. Vale trocar por suspensão com prazo se o cadastro ganhar
    // caminhos assíncronos além do signUp.
    suspender: () => {
      suspenso = true;
      sequencia++;
      set({ estado: { tipo: 'ocioso' } });
    },

    // O cadastro só precisa reavaliar quando o próprio registro do aceite
    // falhou; no caminho feliz reavaliar só pintaria uma tela de carregamento
    // por cima da tela seguinte.
    retomar: (reavaliar = true) => {
      suspenso = false;
      if (reavaliar) void get().reavaliar();
    },

    limpar: () => {
      sequencia++;
      usuarioId = null;
      // Sem isto, um cadastro interrompido no meio deixaria o gate desligado
      // para qualquer conta que entrasse depois.
      suspenso = false;
      set({ estado: { tipo: 'ocioso' }, enviando: false });
    },
  }));
}
