export type RecordStatus = 'ativo' | 'arquivado';

/** Mirrors plays.media_type / exercises media (imagem = upload, video = URL). */
export type MediaType = 'imagem' | 'video';

export interface WithId {
  /** UUID no banco; string vazia identifica um registro ainda não salvo. */
  id: string;
  status: RecordStatus;
}

/** The fixed response scale used by every Pergunta — never customized per-question. */
export const ANSWER_SCALE = [
  { valorNumerico: 0, label: 'Nunca / Não observei' },
  { valorNumerico: 1, label: 'Às vezes' },
  { valorNumerico: 2, label: 'Sempre' },
];
