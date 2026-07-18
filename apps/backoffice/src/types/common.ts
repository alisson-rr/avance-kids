export type RecordStatus = 'ativo' | 'arquivado';

/** Mirrors plays.media_type / exercises media (imagem = upload, video = URL). */
export type MediaType = 'imagem' | 'video';

export interface WithId {
  id: number;
  status: RecordStatus;
}

/** Mirrors initial_question_options / screening_question_options. */
export interface QuestionOption {
  id: number;
  texto: string;
  valorNumerico: number;
}

export function createDefaultOptions(): QuestionOption[] {
  return [
    { id: 1, texto: '', valorNumerico: 0 },
    { id: 2, texto: '', valorNumerico: 1 },
    { id: 3, texto: '', valorNumerico: 2 },
    { id: 4, texto: 'Não observei essa situação ainda', valorNumerico: 0 },
  ];
}
