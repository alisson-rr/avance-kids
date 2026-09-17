import React, { useState } from 'react';
import { Image, StyleSheet, TouchableOpacity, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { YoutubeEmbed } from './YoutubeEmbed';
import { youtubeThumbnail } from '../utils/youtube';

/** Capa do vídeo com botão de play; o player só carrega depois do toque. */
export function VideoPlayer({ videoId }: { videoId: string }) {
  const [playing, setPlaying] = useState(false);

  return (
    <View style={styles.container}>
      {playing ? (
        <YoutubeEmbed videoId={videoId} />
      ) : (
        <>
          <Image
            source={{ uri: youtubeThumbnail(videoId) }}
            style={styles.thumbnail}
            resizeMode="cover"
          />
          <TouchableOpacity
            style={styles.playOverlay}
            activeOpacity={0.8}
            onPress={() => setPlaying(true)}
            accessibilityRole="button"
            accessibilityLabel="Reproduzir vídeo"
          >
            <View style={styles.playButton}>
              <Ionicons name="play" size={32} color="#FFFFFF" style={{ marginLeft: 3 }} />
            </View>
          </TouchableOpacity>
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
    aspectRatio: 16 / 9,
    borderRadius: 12,
    overflow: 'hidden',
    backgroundColor: '#D9D9D9',
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  playOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  playButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
