import { supabase } from '../lib/supabase';

const MEDIA_BUCKET = 'media';

function extensionFromMime(mime: string): string {
  const map: Record<string, string> = {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
    'image/gif': 'gif',
    'image/svg+xml': 'svg',
  };
  return map[mime] ?? 'bin';
}

/**
 * Resolve o valor do campo de imagem antes de salvar:
 * - '' -> null
 * - data-URL (recém-selecionada no ImageUploadField) -> sobe para o bucket
 *   `media` e retorna a URL pública
 * - qualquer outra URL (imagem já hospedada / link de vídeo) -> mantém
 */
export async function resolveMediaUrl(folder: string, value: string): Promise<string | null> {
  if (!value) return null;
  if (!value.startsWith('data:')) return value;

  const blob = await (await fetch(value)).blob();
  const path = `${folder}/${crypto.randomUUID()}.${extensionFromMime(blob.type)}`;

  const { error } = await supabase.storage
    .from(MEDIA_BUCKET)
    .upload(path, blob, { contentType: blob.type, upsert: false });

  if (error) throw new Error(`Falha ao enviar imagem: ${error.message}`);

  const { data } = supabase.storage.from(MEDIA_BUCKET).getPublicUrl(path);
  return data.publicUrl;
}
