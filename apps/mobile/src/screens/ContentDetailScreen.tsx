import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  StatusBar,
  Image,
  ScrollView,
  Linking,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { BottomTabBar } from '../components/BottomTabBar';
import { theme } from '../theme';
import { showError } from '../ui/dialog';

export interface ContentDetailParams {
  title: string;
  subtitle?: string;
  body: string;
  mediaUrl?: string | null;
  mediaType?: 'imagem' | 'video';
}

/**
 * Tela de leitura para Brincadeiras e Artigos — mesmo layout visual da
 * tela de Atividade (header com voltar, título, mídia e texto corrido).
 */
export function ContentDetailScreen({ navigation, route }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  const { title, subtitle, body, mediaUrl, mediaType }: ContentDetailParams =
    route?.params ?? { title: 'Conteúdo', body: '' };

  const isVideo = mediaType === 'video' && !!mediaUrl;

  const handlePlayVideo = () => {
    if (mediaUrl) {
      Linking.openURL(mediaUrl).catch(() =>
        showError('Erro', 'Não foi possível abrir o vídeo.'),
      );
    }
  };

  return (
    <View style={[styles.screen, { paddingTop: safeTop }]}>
      <StatusBar barStyle="dark-content" backgroundColor="#FAFAFA" />

      {/* ── HEADER ── */}
      <View style={styles.headerRow}>
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={styles.headerIconBtn}
          hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
        >
          <Ionicons name="chevron-back" size={24} color="#0E5DFD" />
        </TouchableOpacity>
      </View>

      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: 120 }}>
        <Text style={styles.title}>{title}</Text>
        {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}

        {/* ── MEDIA ── */}
        <View style={styles.mediaContainer}>
          {mediaUrl && !isVideo ? (
            <Image source={{ uri: mediaUrl }} style={styles.mediaImage} resizeMode="cover" />
          ) : (
            <Image
              source={require('../../assets/onboarding3.png')}
              style={styles.mediaImage}
              resizeMode="cover"
            />
          )}
          {isVideo && (
            <TouchableOpacity style={styles.playOverlay} onPress={handlePlayVideo} activeOpacity={0.8}>
              <View style={styles.playButton}>
                <Ionicons name="play" size={32} color="#FFFFFF" style={{ marginLeft: 3 }} />
              </View>
            </TouchableOpacity>
          )}
        </View>

        {/* ── BODY ── */}
        <Text style={styles.bodyText}>{body}</Text>
      </ScrollView>

      <BottomTabBar activeScreen="Home" />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 24,
    height: 44,
  },
  headerIconBtn: {
    width: 24,
    height: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 24,
    lineHeight: 29,
    color: '#000000',
    fontWeight: '700',
    paddingHorizontal: 24,
    marginTop: 16,
  },
  subtitle: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    lineHeight: 17,
    color: '#5E5E5E',
    paddingHorizontal: 24,
    marginTop: 4,
    marginBottom: 20,
  },
  mediaContainer: {
    marginHorizontal: 24,
    marginTop: 8,
    borderRadius: 12,
    overflow: 'hidden',
    height: 260,
    backgroundColor: '#D9D9D9',
  },
  mediaImage: {
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
  bodyText: {
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    lineHeight: 24,
    color: '#3B3B3B',
    paddingHorizontal: 24,
    marginTop: 24,
  },
});
