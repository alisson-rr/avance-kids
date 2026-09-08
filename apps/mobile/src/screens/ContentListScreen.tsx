import React, { useCallback, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  Image,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { Feather, Ionicons } from '@expo/vector-icons';
import { useFocusEffect } from '@react-navigation/native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ScreenHeader } from '../components/ScreenHeader';
import { fetchArticles, fetchPlays } from '../services/content';
import { errorMessage } from '../services/api';
import { theme } from '../theme';
import type { ArticleRow, PlayRow } from '../types/db';

type ContentKind = 'plays' | 'articles';
type ContentItem = PlayRow | ArticleRow;

function normalizeSearch(value: string): string {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

export function ContentListScreen({ navigation, route }: any) {
  const kind: ContentKind = route?.params?.kind === 'articles' ? 'articles' : 'plays';
  const isPlays = kind === 'plays';
  const title = isPlays ? 'Brincadeiras educativas' : 'Conteúdo para pais';

  const [items, setItems] = useState<ContentItem[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setLoadError(null);
    try {
      setItems(isPlays ? await fetchPlays() : await fetchArticles());
    } catch (err) {
      setLoadError(errorMessage(err));
      setItems([]);
    } finally {
      setLoading(false);
    }
  }, [isPlays]);

  useFocusEffect(
    useCallback(() => {
      void load();
    }, [load]),
  );

  const filteredItems = useMemo(() => {
    const term = normalizeSearch(search);
    if (!term) return items;
    return items.filter((item) => normalizeSearch(item.titulo).includes(term));
  }, [items, search]);

  const openItem = (item: ContentItem) => {
    if (item.bloqueado) {
      navigation.navigate('Plans');
      return;
    }

    if (isPlays) {
      const play = item as PlayRow;
      navigation.navigate('ContentDetail', {
        playId: play.id,
        title: play.titulo,
        subtitle: 'Brincadeira educativa',
        body: [play.descricao, play.instrucoes].filter(Boolean).join('\n\n') || 'Sem instruções.',
        mediaUrl: play.media_url,
        mediaType: play.media_type,
      });
      return;
    }

    const article = item as ArticleRow;
    navigation.navigate('ContentDetail', {
      title: article.titulo,
      subtitle: 'Conteúdo para pais',
      body: article.corpo ?? '',
      mediaUrl: article.imagem_url,
      mediaType: 'imagem',
    });
  };

  const renderItem = ({ item }: { item: ContentItem }) => {
    const play = isPlays ? item as PlayRow : null;
    const article = isPlays ? null : item as ArticleRow;
    const imageUrl = play?.media_type === 'imagem' ? play.media_url : article?.imagem_url;
    const description = play?.descricao ?? article?.corpo ?? (item.bloqueado ? 'Disponível no plano premium' : '');

    return (
      <TouchableOpacity
        style={styles.card}
        activeOpacity={0.8}
        onPress={() => openItem(item)}
        accessibilityRole="button"
        accessibilityLabel={item.bloqueado ? `${item.titulo}. Conteúdo premium, assine para ver.` : item.titulo}
      >
        <View style={[styles.imageContainer, !imageUrl && styles.imagePlaceholder]}>
          {imageUrl && <Image source={{ uri: imageUrl }} style={styles.image} resizeMode="cover" />}
          {item.bloqueado && (
            <View style={styles.lockOverlay}>
              <Ionicons name="lock-closed" size={22} color="#FFFFFF" />
            </View>
          )}
        </View>

        <View style={styles.cardContent}>
          <Text style={styles.cardTitle} numberOfLines={2}>{item.titulo}</Text>
          {description && <Text style={styles.cardDescription} numberOfLines={3}>{description}</Text>}
          <View style={styles.cardLinkRow}>
            <Text style={styles.cardLink}>{item.bloqueado ? 'Assinar para ver' : 'Acessar'}</Text>
            <Ionicons
              name={item.bloqueado ? 'lock-closed' : 'chevron-forward'}
              size={16}
              color={theme.colors.primary}
            />
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <SafeAreaView style={styles.screen} edges={['top', 'bottom']}>
      <StatusBar barStyle="dark-content" backgroundColor="#FAFAFA" />
      <ScreenHeader title={title} variant="compact" onBack={() => navigation.goBack()} />

      <View style={styles.searchContainer}>
        <Feather name="search" size={20} color={theme.colors.textLight} />
        <TextInput
          style={styles.searchInput}
          value={search}
          onChangeText={setSearch}
          placeholder={`Pesquisar em ${title.toLowerCase()}`}
          placeholderTextColor={theme.colors.textLight}
          returnKeyType="search"
        />
        {search.length > 0 && (
          <TouchableOpacity
            onPress={() => setSearch('')}
            accessibilityRole="button"
            accessibilityLabel="Limpar pesquisa"
          >
            <Ionicons name="close-circle" size={20} color={theme.colors.textLight} />
          </TouchableOpacity>
        )}
      </View>

      {loading ? (
        <View style={styles.stateContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
        </View>
      ) : loadError ? (
        <View style={styles.stateContainer}>
          <Text style={styles.stateText}>{loadError}</Text>
          <TouchableOpacity style={styles.retryButton} onPress={load}>
            <Text style={styles.retryText}>Tentar novamente</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <FlatList
          data={filteredItems}
          renderItem={renderItem}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          keyboardShouldPersistTaps="handled"
          keyboardDismissMode="on-drag"
          showsVerticalScrollIndicator={false}
          ListEmptyComponent={(
            <View style={styles.stateContainer}>
              <Text style={styles.stateText}>
                {search ? 'Nenhum conteúdo encontrado para essa pesquisa.' : 'Ainda não há conteúdos disponíveis.'}
              </Text>
            </View>
          )}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  searchContainer: {
    height: 48,
    marginHorizontal: 24,
    marginTop: 8,
    marginBottom: 20,
    paddingHorizontal: 16,
    borderRadius: 24,
    backgroundColor: '#F0F0F0',
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  searchInput: {
    flex: 1,
    paddingVertical: 0,
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    color: theme.colors.textDark,
  },
  listContent: {
    paddingHorizontal: 24,
    paddingBottom: 32,
    gap: 16,
  },
  card: {
    minHeight: 142,
    flexDirection: 'row',
    overflow: 'hidden',
    borderRadius: 12,
    backgroundColor: '#FFFFFF',
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 3,
  },
  imageContainer: {
    width: 116,
    minHeight: 142,
    overflow: 'hidden',
  },
  imagePlaceholder: {
    backgroundColor: '#D7D7D7',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  lockOverlay: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(14, 93, 253, 0.55)',
  },
  cardContent: {
    flex: 1,
    padding: 16,
    gap: 8,
  },
  cardTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 15,
    lineHeight: 19,
    color: '#424242',
  },
  cardDescription: {
    flex: 1,
    fontFamily: theme.fonts.regular,
    fontSize: 13,
    lineHeight: 18,
    color: '#5E5E5E',
  },
  cardLinkRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  cardLink: {
    marginRight: 4,
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 13,
    color: theme.colors.primary,
  },
  stateContainer: {
    flex: 1,
    minHeight: 180,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 32,
    gap: 20,
  },
  stateText: {
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    lineHeight: 22,
    textAlign: 'center',
    color: '#5E5E5E',
  },
  retryButton: {
    minHeight: 44,
    paddingHorizontal: 20,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 22,
    backgroundColor: theme.colors.primary,
  },
  retryText: {
    fontFamily: theme.fonts.semiBold,
    color: '#FFFFFF',
  },
});
