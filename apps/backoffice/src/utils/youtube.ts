// Mesmo parser do app mobile (apps/mobile/src/utils/youtube.ts): os dois
// projetos não compartilham pacote.
const YOUTUBE_ID =
  /^(?:https?:\/\/)?(?:www\.|m\.|music\.)?(?:youtube(?:-nocookie)?\.com\/(?:watch\?(?:[^#]*&)?v=|embed\/|shorts\/|live\/|v\/)|youtu\.be\/)([\w-]{11})(?:[?&#/]|$)/i;

/** ID do vídeo nos formatos watch, youtu.be, shorts, embed e live; `null` se não for YouTube. */
export function youtubeId(url: string | null | undefined): string | null {
  return url?.trim().match(YOUTUBE_ID)?.[1] ?? null;
}

export function youtubeThumbnail(id: string): string {
  return `https://i.ytimg.com/vi/${id}/hqdefault.jpg`;
}
