import { supabase } from '../lib/supabase';

/**
 * Sobe uma foto local (URI do expo-image-picker) para o bucket `avatars`,
 * na pasta do usuário logado (exigida pela policy de Storage), e retorna
 * a URL pública.
 */
export async function uploadAvatar(localUri: string, prefix: string): Promise<string> {
  const { data: userData } = await supabase.auth.getUser();
  const uid = userData.user?.id;
  if (!uid) throw new Error('Sessão expirada. Faça login novamente.');

  const response = await fetch(localUri);
  const arrayBuffer = await response.arrayBuffer();
  const contentType = response.headers.get('content-type') ?? 'image/jpeg';
  const ext = contentType.includes('png') ? 'png' : 'jpg';
  const path = `${uid}/${prefix}-${Date.now()}.${ext}`;

  const { error } = await supabase.storage
    .from('avatars')
    .upload(path, arrayBuffer, { contentType, upsert: true });
  if (error) throw new Error(`Falha no upload da foto: ${error.message}`);

  return supabase.storage.from('avatars').getPublicUrl(path).data.publicUrl;
}
