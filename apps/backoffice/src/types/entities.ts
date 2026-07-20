import type { HabilidadeKey, AgeBracketCode, AccessPlan } from '../constants/aba';
import type { RecordStatus, MediaType } from './common';

export type { MediaType } from './common';

// === Usuários Admin (admin_users) ===
export type AdminRole = 'admin' | 'super_admin';

export interface AdminUser {
  id: string;
  nome: string;
  email: string;
  role: AdminRole;
  status: RecordStatus;
  /** Somente no formulário de criação — enviada à edge function, nunca lida do banco. */
  password?: string;
}

// === Brincadeiras (plays) ===
export interface Brincadeira {
  id: string;
  titulo: string;
  descricao: string;
  instrucoes: string;
  mediaType: MediaType;
  mediaUrl: string;
  plano: AccessPlan;
  status: RecordStatus;
}

// === Artigos (articles) ===
export interface Artigo {
  id: string;
  titulo: string;
  corpo: string;
  imagemUrl: string;
  plano: AccessPlan;
  status: RecordStatus;
}

// === Perguntas (Iniciais e de Triagem) ===
// Mesma forma para os dois tipos: cada pergunta pertence a uma Faixa Etária
// (a triagem inicial é o pré-requisito daquela faixa; a triagem completa
// avalia a habilidade dentro dela) e usa sempre a mesma escala fixa de
// resposta (0 = nunca/não observei, 1 = às vezes, 2 = sempre) — por isso não
// há edição de opções por pergunta, e nenhuma das duas precisa de código.
export interface Pergunta {
  id: string;
  texto: string;
  skillKey: HabilidadeKey;
  ageBracketCode: AgeBracketCode;
  ordem: number;
  status: RecordStatus;
}

export type PerguntaInicial = Pergunta;
export type PerguntaTriagem = Pergunta;
