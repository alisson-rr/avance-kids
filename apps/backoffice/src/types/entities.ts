import type { HabilidadeKey, AgeBracketCode, AccessPlan } from '../constants/aba';
import type { RecordStatus, QuestionOption, MediaType } from './common';

export type { MediaType } from './common';

// === Usuários Admin (admin_users) ===
export type AdminRole = 'admin' | 'super_admin';

export interface AdminUser {
  id: number;
  nome: string;
  email: string;
  role: AdminRole;
  status: RecordStatus;
}

// === Brincadeiras (plays) ===
export interface Brincadeira {
  id: number;
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
  id: number;
  titulo: string;
  corpo: string;
  imagemUrl: string;
  plano: AccessPlan;
  status: RecordStatus;
}

// === Perguntas Iniciais (initial_questions + initial_question_options) ===
export interface PerguntaInicial {
  id: number;
  texto: string;
  ordem: number;
  status: RecordStatus;
  opcoes: QuestionOption[];
}

// === Perguntas de Triagem (screening_questions + screening_question_options) ===
export interface PerguntaTriagem {
  id: number;
  codigo: string;
  skillKey: HabilidadeKey;
  ageBracketCode: AgeBracketCode;
  texto: string;
  ordem: number;
  status: RecordStatus;
  opcoes: QuestionOption[];
}
