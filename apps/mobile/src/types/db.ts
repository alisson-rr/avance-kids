// Espelho manual das tabelas do baseline (supabase/migrations/20260718000000_baseline.sql).
// Quando o projeto remoto estiver ativo, substituir por `supabase gen types typescript`.

export type RecordStatus = 'ativo' | 'arquivado';
export type MediaType = 'imagem' | 'video';
export type QuestionKind = 'inicial' | 'triagem';
export type ExerciseLevel = 'aquisicao' | 'generalizacao' | 'manutencao';
export type AttemptResult = 'sem_ajuda' | 'ajuda_parcial' | 'ajuda_total';
export type PlanStatus = 'ativo' | 'concluido' | 'bloqueado';
export type SubscriptionPlan = 'free' | 'premium';

export interface ProfileRow {
  id: string;
  nome: string;
  data_nascimento: string | null;
  genero: string | null;
  cpf: string | null;
  telefone: string | null;
  avatar_url: string | null;
  termos_aceitos: boolean;
}

export interface ChildRow {
  id: string;
  user_id: string;
  nome: string;
  data_nascimento: string;
  genero: string | null;
  cpf: string | null;
  condicoes: string[];
  avatar_url: string | null;
  idade_biologica_meses: number | null;
  idade_geral_meses: number | null;
  triagem_completa: boolean;
}

export interface SkillRow {
  id: string;
  key: string;
  nome: string;
  cor_hex: string;
  icone: string | null;
  ordem: number;
}

export interface AgeBracketRow {
  id: string;
  codigo: string;
  nome: string;
  meses_min: number;
  meses_max: number;
  descricao: string | null;
  ordem: number;
}

export interface QuestionRow {
  id: string;
  kind: QuestionKind;
  skill_id: string;
  age_bracket_id: string;
  texto: string;
  ordem: number;
  status: RecordStatus;
}

export interface ExerciseRow {
  id: string;
  skill_id: string;
  age_bracket_id: string;
  codigo: string | null;
  titulo: string;
  media_type: MediaType;
  media_url: string | null;
  nivel: ExerciseLevel;
  ordem: number;
  plano: SubscriptionPlan;
  status: RecordStatus;
  objetivo: string | null;
  procedimento: string | null;
  materiais: string | null;
  recursos_extras: string | null;
  frequencia: string | null;
  brincadeiras: string | null;
  hierarquia_dicas: string | null;
  resposta_esperada: string | null;
  procedimento_correcao: string | null;
  criterio_avanco: string | null;
  registro_dados: string | null;
  reforcos: string | null;
}

export interface ActivityPlanRow {
  id: string;
  child_id: string;
  skill_id: string;
  exercise_id: string;
  status: PlanStatus;
  ordem: number;
  started_at: string | null;
  completed_at: string | null;
}

export interface ExerciseSessionRow {
  id: string;
  plan_id: string;
  child_id: string;
  total_repetitions: number;
  successful_count: number;
  started_at: string;
  expires_at: string;
  is_completed: boolean;
}

export interface PlanWithDetails extends ActivityPlanRow {
  /** Nulo quando a atividade é premium e a conta não tem assinatura ativa (RLS). */
  exercises: ExerciseRow | null;
  skills: Pick<SkillRow, 'id' | 'key' | 'nome' | 'cor_hex'>;
  exercise_sessions: ExerciseSessionRow[];
}

/**
 * Linhas das views plays_feed / articles_feed: o item premium aparece na
 * listagem com `bloqueado = true` e sem conteúdo (migration-05).
 */
export interface PlayRow {
  id: string;
  titulo: string;
  descricao: string | null;
  instrucoes: string | null;
  media_type: MediaType;
  media_url: string | null;
  plano: SubscriptionPlan;
  bloqueado: boolean;
}

export interface ArticleRow {
  id: string;
  titulo: string;
  corpo: string | null;
  imagem_url: string | null;
  plano: SubscriptionPlan;
  bloqueado: boolean;
}

export interface SubscriptionRow {
  plano: SubscriptionPlan;
  status: 'active' | 'canceled' | 'past_due' | 'trialing';
  trial_end: string | null;
  current_period_end: string | null;
}

/** Documento legal vigente publicado pelo servidor (migration-06). */
export interface TermsDocumentRow {
  id: string;
  tipo: string;
  versao: string;
  titulo: string;
  url: string | null;
}

/** Linha do log de aceite devolvida por accept-terms. */
export interface TermsAcceptanceRow {
  tipo: string;
  versao: string;
  aceito_em: string;
}
