import React, { ReactNode, useCallback, useEffect, useRef, useState } from 'react';
import { AppState, Image, ImageStyle, StyleProp } from 'react-native';
import {
  AVATAR_URL_REFRESH_MS,
  getSignedAvatarUrl,
} from '../services/storage';

interface PrivateAvatarProps {
  avatarPath?: string | null;
  style: StyleProp<ImageStyle>;
  fallback?: ReactNode;
}

/**
 * Renderiza um objeto do bucket privado e renova sua URL antes de expirar.
 * Também força a renovação ao voltar do background ou se a imagem falhar.
 */
export function PrivateAvatar({ avatarPath, style, fallback = null }: PrivateAvatarProps) {
  const [signedUrl, setSignedUrl] = useState('');
  const requestVersion = useRef(0);
  const retriedAfterImageError = useRef(false);

  const refresh = useCallback(async (force = false) => {
    const version = ++requestVersion.current;
    if (!avatarPath) {
      setSignedUrl('');
      return;
    }

    try {
      const nextUrl = await getSignedAvatarUrl(avatarPath, force);
      if (version === requestVersion.current) setSignedUrl(nextUrl);
    } catch (error) {
      console.warn('[avatar] URL assinada falhou:', error);
      if (version === requestVersion.current) setSignedUrl('');
    }
  }, [avatarPath]);

  useEffect(() => {
    setSignedUrl('');
    retriedAfterImageError.current = false;
    void refresh();

    const timer = setInterval(() => {
      retriedAfterImageError.current = false;
      void refresh(true);
    }, AVATAR_URL_REFRESH_MS);
    const appStateSubscription = AppState.addEventListener('change', (state) => {
      if (state === 'active') {
        retriedAfterImageError.current = false;
        void refresh(true);
      }
    });

    return () => {
      requestVersion.current += 1;
      clearInterval(timer);
      appStateSubscription.remove();
    };
  }, [refresh]);

  return signedUrl ? (
    <Image
      source={{ uri: signedUrl }}
      style={style}
      onLoad={() => { retriedAfterImageError.current = false; }}
      onError={() => {
        if (retriedAfterImageError.current) {
          setSignedUrl('');
          return;
        }
        retriedAfterImageError.current = true;
        void refresh(true);
      }}
    />
  ) : fallback;
}
