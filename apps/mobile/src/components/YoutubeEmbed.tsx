import React from 'react';
import { WebView } from 'react-native-webview';
import { youtubeEmbedUrl } from '../utils/youtube';

// O YouTube recusa o player (erro 152/153) sem Referer https; a origem usada
// é o domínio da cliente.
const EMBED_ORIGIN = 'https://avancekids.com.br';

export function YoutubeEmbed({ videoId }: { videoId: string }) {
  // Cantos arredondados também no HTML: no Android o WebView pode ignorar o
  // recorte (borderRadius + overflow) do container enquanto o vídeo toca.
  const html = `<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>html,body{margin:0;height:100%;background:transparent;overflow:hidden}iframe{display:block;border:0;width:100%;height:100%;border-radius:12px;background:#000}</style></head><body><iframe src="${youtubeEmbedUrl(videoId)}" allow="autoplay; encrypted-media; picture-in-picture; fullscreen" allowfullscreen referrerpolicy="strict-origin-when-cross-origin"></iframe></body></html>`;

  return (
    <WebView
      source={{ html, baseUrl: EMBED_ORIGIN }}
      originWhitelist={['*']}
      allowsFullscreenVideo
      allowsInlineMediaPlayback
      mediaPlaybackRequiresUserAction={false}
      onOpenWindow={() => {}}
      // Só o iframe navega: o frame principal nunca sai para youtube.com,
      // intent:// ou vnd.youtube, então o app/site do YouTube não abre.
      onShouldStartLoadWithRequest={(req) =>
        req.isTopFrame === false || req.url === 'about:blank' || req.url.startsWith(EMBED_ORIGIN)
      }
      style={{ flex: 1, backgroundColor: 'transparent' }}
    />
  );
}
