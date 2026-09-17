import { useState } from 'react';
import { ImageOff, Play, Video } from 'lucide-react';
import { youtubeId, youtubeThumbnail } from '../../../utils/youtube';
import type { MediaType } from '../../../types/common';
import styles from './MediaThumb.module.css';

interface MediaThumbProps {
  mediaType: MediaType;
  url: string;
  size?: 'small' | 'large';
}

export function MediaThumb({ mediaType, url, size = 'small' }: MediaThumbProps) {
  // Guarda qual src falhou (e não um booleano) para que um novo link volte a tentar.
  const [failedSrc, setFailedSrc] = useState<string | null>(null);
  const videoId = mediaType === 'video' ? youtubeId(url) : null;
  const src = mediaType === 'imagem' ? url || null : videoId ? youtubeThumbnail(videoId) : null;
  const PlaceholderIcon = mediaType === 'imagem' ? ImageOff : Video;
  const large = size === 'large';

  return (
    <div className={`${styles.thumb} ${large ? styles.large : styles.small}`}>
      {src && src !== failedSrc ? (
        <>
          <img src={src} alt="" loading="lazy" className={styles.image} onError={() => setFailedSrc(src)} />
          {mediaType === 'video' && (
            <span className={styles.play}>
              <Play size={large ? 22 : 12} fill="currentColor" />
            </span>
          )}
        </>
      ) : (
        <PlaceholderIcon size={large ? 32 : 20} />
      )}
    </div>
  );
}
