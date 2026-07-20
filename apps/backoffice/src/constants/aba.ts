// Domínio ABA (Análise do Comportamento Aplicada) usado no cadastro de atividades.
// Espelha os 5 domínios já usados no app mobile (apps/mobile/src/data/habilidades.ts)
// e a paleta cadastrada em skills no schema de referência.

import type { RecordStatus, MediaType } from '../types/common';

export type HabilidadeKey = 'comunicacao' | 'social' | 'cognitiva' | 'motora' | 'funcional';

export interface Habilidade {
  key: HabilidadeKey;
  label: string;
  corHex: string;
}

export const SKILLS: Habilidade[] = [
  { key: 'comunicacao', label: 'Comunicação', corHex: '#3B82F6' },
  { key: 'social', label: 'Social', corHex: '#22C55E' },
  { key: 'cognitiva', label: 'Cognitiva', corHex: '#F59E0B' },
  { key: 'motora', label: 'Coordenação Motora', corHex: '#8B5CF6' },
  { key: 'funcional', label: 'Funcional', corHex: '#EC4899' },
];

export function getSkill(key: HabilidadeKey): Habilidade {
  return SKILLS.find((s) => s.key === key) ?? SKILLS[0];
}

export type AgeBracketCode = 'F01A' | 'F02A' | 'F03A' | 'F04A' | 'F05A' | 'F06A';

export interface AgeBracket {
  code: AgeBracketCode;
  label: string;
}

export const AGE_BRACKETS: AgeBracket[] = [
  { code: 'F01A', label: '12 a 24 meses' },
  { code: 'F02A', label: '25 a 36 meses' },
  { code: 'F03A', label: '37 a 48 meses' },
  { code: 'F04A', label: '49 a 60 meses' },
  { code: 'F05A', label: '6 a 8 anos' },
  { code: 'F06A', label: '9 a 12 anos' },
];

export function getAgeBracket(code: AgeBracketCode): AgeBracket {
  return AGE_BRACKETS.find((a) => a.code === code) ?? AGE_BRACKETS[0];
}

// Estágio de progressão pedagógica do exercício (não é "dificuldade").
export type ExerciseLevel = 'aquisicao' | 'generalizacao' | 'manutencao';

export const EXERCISE_LEVELS: { value: ExerciseLevel; label: string }[] = [
  { value: 'aquisicao', label: 'Aquisição' },
  { value: 'generalizacao', label: 'Generalização' },
  { value: 'manutencao', label: 'Manutenção' },
];

export type AccessPlan = 'free' | 'premium';

export const ACCESS_PLANS: { value: AccessPlan; label: string }[] = [
  { value: 'free', label: 'Gratuito (Free)' },
  { value: 'premium', label: 'Premium (Pago)' },
];

export type AtividadeStatus = RecordStatus;

export interface Atividade {
  id: string;
  codigo: string;
  titulo: string;
  mediaType: MediaType;
  mediaUrl: string;
  skillKey: HabilidadeKey;
  ageBracketCode: AgeBracketCode;
  nivel: ExerciseLevel;
  plano: AccessPlan;
  status: AtividadeStatus;
  objetivo: string;
  procedimento: string;
  materiais: string;
  recursosExtras: string;
  frequencia: string;
  brincadeiras: string;
  hierarquiaDicas: string;
  respostaEsperada: string;
  procedimentoCorrecao: string;
  criterioAvanco: string;
  registroDados: string;
  reforcos: string;
}

export function buildProgramaLabel(skillKey: HabilidadeKey, ageBracketCode: AgeBracketCode): string {
  return `${getSkill(skillKey).label} · Faixa ${getAgeBracket(ageBracketCode).label}`;
}
