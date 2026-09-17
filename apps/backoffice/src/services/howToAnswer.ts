import { supabase } from '../lib/supabase';
import { assertUpdated } from './common';
import { youtubeId } from '../utils/youtube';

export interface HowToAnswer {
  texto: string;
  videoUrl: string;
}

// Mesmos limites dos CHECK de how_to_answer (migration-19) e das colunas
// como_responder_* de questions (migration-23).
export const MAX_TEXTO = 5000;
export const MAX_VIDEO_URL = 500;

/** O app só toca vídeo do YouTube: outro link seria salvo e sumiria sem aviso. */
export function assertYoutubeUrl(url: string): void {
  if (url && !youtubeId(url)) {
    throw new Error('O link do vídeo precisa ser do YouTube (youtube.com/watch, youtu.be, shorts, embed ou live).');
  }
}

export async function fetchHowToAnswer(): Promise<HowToAnswer> {
  const { data, error } = await supabase
    .from('how_to_answer')
    .select('texto, video_url')
    .eq('id', true)
    .maybeSingle();
  if (error) throw new Error(error.message);
  return { texto: data?.texto ?? '', videoUrl: data?.video_url ?? '' };
}

export async function saveHowToAnswer(item: HowToAnswer): Promise<void> {
  const texto = item.texto.trim();
  const videoUrl = item.videoUrl.trim();
  if (texto.length > MAX_TEXTO) {
    throw new Error(`O texto pode ter no máximo ${MAX_TEXTO} caracteres.`);
  }
  if (videoUrl.length > MAX_VIDEO_URL) {
    throw new Error(`O link do vídeo pode ter no máximo ${MAX_VIDEO_URL} caracteres.`);
  }
  assertYoutubeUrl(videoUrl);

  const { data, error } = await supabase
    .from('how_to_answer')
    .update({ texto: texto || null, video_url: videoUrl || null })
    .eq('id', true)
    .select('id');
  assertUpdated(data, error);
}
