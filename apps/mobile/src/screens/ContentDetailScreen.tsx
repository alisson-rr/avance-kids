import React, { useEffect, useState } from 'react';
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
import { fetchPlayProducts } from '../services/content';
import type { PlayProductRow } from '../types/db';

export interface ContentDetailParams {
  playId?: string;
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

  const { playId, title, subtitle, body, mediaUrl, mediaType }: ContentDetailParams =
    route?.params ?? { title: 'Conteúdo', body: '' };
  const [products, setProducts] = useState<PlayProductRow[]>([]);

  useEffect(() => {
    let mounted = true;
    setProducts([]);
    if (!playId) return () => { mounted = false; };

    fetchPlayProducts(playId)
      .then((items) => {
        if (mounted) setProducts(items);
      })
      .catch(() => {
        if (mounted) setProducts([]);
      });

    return () => { mounted = false; };
  }, [playId]);

  const isVideo = mediaType === 'video' && !!mediaUrl;

  const handlePlayVideo = () => {
    if (mediaUrl) {
      Linking.openURL(mediaUrl).catch(() =>
        showError('Erro', 'Não foi possível abrir o vídeo.'),
      );
    }
  };

  const handleOpenProduct = (product: PlayProductRow) => {
    Linking.openURL(product.link_url).catch(() =>
      showError('Erro', 'Não foi possível abrir o produto na Shopee.'),
    );
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

      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: 110 }}>
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

        {products.length > 0 ? (
          <View style={styles.productsSection}>
            <Text style={styles.productsTitle}>Produtos recomendados</Text>
            <Text style={styles.productsSubtitle}>
              Sugestões para complementar esta brincadeira. Os links abrem na Shopee.
            </Text>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.productsList}
            >
              {products.map((product) => (
                <TouchableOpacity
                  key={product.id}
                  style={styles.productCard}
                  activeOpacity={0.8}
                  onPress={() => handleOpenProduct(product)}
                  accessibilityRole="link"
                  accessibilityLabel={`Ver ${product.titulo} na Shopee`}
                >
                  <Image
                    source={{ uri: product.imagem_url }}
                    style={styles.productImage}
                    resizeMode="cover"
                  />
                  <View style={styles.productContent}>
                    <Text style={styles.productTitle} numberOfLines={2}>{product.titulo}</Text>
                    <Text style={styles.productDescription} numberOfLines={3}>
                      {product.descricao}
                    </Text>
                    <View style={styles.productLinkRow}>
                      <Text style={styles.productLink}>Ver produto</Text>
                      <Ionicons name="open-outline" size={16} color={theme.colors.primary} />
                    </View>
                  </View>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>
        ) : null}
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
    width: 44,
    height: 44,
    marginLeft: -10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 24,
    lineHeight: 30,
    color: '#000000',
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
  productsSection: {
    marginTop: 32,
  },
  productsTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 20,
    lineHeight: 26,
    color: '#000000',
    paddingHorizontal: 24,
  },
  productsSubtitle: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    lineHeight: 20,
    color: '#5E5E5E',
    paddingHorizontal: 24,
    marginTop: 4,
  },
  productsList: {
    paddingHorizontal: 24,
    paddingVertical: 20,
    gap: 16,
  },
  productCard: {
    width: 238,
    borderRadius: 12,
    overflow: 'hidden',
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E4E4E4',
  },
  productImage: {
    width: '100%',
    height: 150,
    backgroundColor: '#EAEAEA',
  },
  productContent: {
    minHeight: 178,
    padding: 16,
  },
  productTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 15,
    lineHeight: 20,
    color: '#292929',
  },
  productDescription: {
    fontFamily: theme.fonts.regular,
    fontSize: 13,
    lineHeight: 18,
    color: '#5E5E5E',
    marginTop: 8,
    flex: 1,
  },
  productLinkRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginTop: 14,
  },
  productLink: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 14,
    color: theme.colors.primary,
  },
});
