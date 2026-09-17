import React from 'react';
import { youtubeEmbedUrl } from '../utils/youtube';

export function YoutubeEmbed({ videoId }: { videoId: string }) {
  return React.createElement('iframe', {
    src: youtubeEmbedUrl(videoId),
    title: 'Vídeo',
    allow: 'autoplay; encrypted-media; picture-in-picture; fullscreen',
    allowFullScreen: true,
    referrerPolicy: 'strict-origin-when-cross-origin',
    // Sem allow-popups: o link "Assistir no YouTube" não abre outra aba.
    sandbox: 'allow-scripts allow-same-origin allow-presentation',
    style: { border: 0, width: '100%', height: '100%' },
  });
}
