import { supabase } from '../lib/supabase';
import type { HowToAnswerRow } from '../types/db';

// Linha única (migration-19): ajuda global do sheet de repetição.
export async function fetchHowToAnswer(): Promise<HowToAnswerRow | null> {
  const { data, error } = await supabase
    .from('how_to_answer')
    .select('texto, video_url')
    .maybeSingle();
  if (error) throw new Error(error.message);
  return data;
}
