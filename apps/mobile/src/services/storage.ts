import { supabase } from '../lib/supabase';

const AVATAR_BUCKET = 'avatars';
export const AVATAR_URL_TTL_SECONDS = 5 * 60;
export const AVATAR_URL_REFRESH_MS = 4 * 60 * 1000;

interface CachedSignedUrl {
  url: string;
  refreshAfter: number;
}

const signedUrlCache = new Map<string, CachedSignedUrl>();
const pendingSignedUrls = new Map<string, Promise<string>>();

/**
 * Normaliza tanto o caminho novo salvo no banco quanto URLs públicas/assinadas
 * antigas. Isso permite fechar o bucket sem reescrever dados pessoais já
 * existentes e sem continuar renderizando uma URL pública persistida.
 */
export function avatarPathFromReference(reference?: string | null): string {
  const value = reference?.trim();
  if (!value) return '';

  if (!/^https?:\/\//i.test(value)) {
    return value.replace(/^\/+/, '');
  }

  try {
    const pathname = decodeURIComponent(new URL(value).pathname);
    const marker = `/${AVATAR_BUCKET}/`;
    const markerIndex = pathname.indexOf(marker);
    return markerIndex >= 0 ? pathname.slice(markerIndex + marker.length) : '';
  } catch {
    return '';
  }
}

/**
 * Cria uma URL assinada curta para um avatar privado. O cache em memória só é
 * usado até um minuto antes da expiração; chamadas simultâneas para o mesmo
 * objeto compartilham a mesma requisição.
 */
export async function getSignedAvatarUrl(
  reference?: string | null,
  forceRefresh = false,
): Promise<string> {
  const path = avatarPathFromReference(reference);
  if (!path) return '';

  const cached = signedUrlCache.get(path);
  if (!forceRefresh && cached && Date.now() < cached.refreshAfter) {
    return cached.url;
  }

  const pending = pendingSignedUrls.get(path);
  if (pending) return pending;

  const request = supabase.storage
    .from(AVATAR_BUCKET)
    .createSignedUrl(path, AVATAR_URL_TTL_SECONDS)
    .then(({ data, error }) => {
      if (error) throw new Error(`Falha ao carregar a foto: ${error.message}`);

      signedUrlCache.set(path, {
        url: data.signedUrl,
        refreshAfter: Date.now() + AVATAR_URL_REFRESH_MS,
      });
      return data.signedUrl;
    })
    .finally(() => pendingSignedUrls.delete(path));

  pendingSignedUrls.set(path, request);
  return request;
}

/**
 * Sobe uma foto local (URI do expo-image-picker) para o bucket `avatars`,
 * na pasta do usuário logado (exigida pela policy de Storage), e retorna
 * apenas o caminho persistente do objeto. A UI transforma esse caminho em URL
 * assinada curta quando precisa exibir a foto.
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
    .from(AVATAR_BUCKET)
    .upload(path, arrayBuffer, { contentType, upsert: true });
  if (error) throw new Error(`Falha no upload da foto: ${error.message}`);

  return path;
}
