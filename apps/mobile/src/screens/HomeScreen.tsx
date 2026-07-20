import React, { useCallback, useRef, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Image, Platform, Animated, ScrollView } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { BottomTabBar } from '../components/BottomTabBar';
import { HEADER_MIN_HEIGHT, HEADER_MAX_HEIGHT, CURVE_TOP, CURVE_MAX_HEIGHT } from '../components/CurvedHeader';
import { Ionicons, Feather } from '@expo/vector-icons';
import { theme } from '../theme';
import { useProfileStore, selectActiveChild } from '../store/useProfileStore';
import { fetchPlays, fetchArticles } from '../services/content';
import { fetchActivityPlans } from '../services/activities';
import { formatAgeFromIso } from '../utils/formatters';
import type { ArticleRow, PlayRow } from '../types/db';

interface ActivityCardProps {
  title: string;
  description?: string;
  imageSource?: any;
  onPress?: () => void;
}

const ActivityCard = ({ title, description, imageSource, onPress }: ActivityCardProps) => (
  <TouchableOpacity style={styles.activityCard} activeOpacity={0.8} onPress={onPress}>
    <View style={[styles.activityCardImageContainer, !imageSource && styles.activityCardPlaceholder]}>
      {imageSource && (
        <Image source={imageSource} style={styles.activityCardImage} resizeMode="cover" />
      )}
    </View>
    <View style={styles.activityCardContent}>
      <View style={styles.activityCardTextGroup}>
        <Text style={styles.activityCardTitle} numberOfLines={1}>{title}</Text>
        {description && <Text style={styles.activityCardDescription} numberOfLines={2}>{description}</Text>}
      </View>
      <View style={styles.activityCardLinkGroup}>
        <Text style={styles.activityCardLink}>Acessar</Text>
        <Ionicons name="chevron-forward" size={16} color={theme.colors.primary} />
      </View>
    </View>
  </TouchableOpacity>
);

const SectionHeader = ({ title, subtitle }: { title: string; subtitle?: string }) => (
  <View style={styles.sectionHeaderContainer}>
    <View style={styles.sectionHeaderTitleGroup}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {subtitle && <Text style={styles.sectionSubtitle}>{subtitle}</Text>}
    </View>
    <TouchableOpacity style={styles.sectionSeeAllBtn}>
      <Text style={styles.sectionSeeAll}>ver todos</Text>
      <Ionicons name="chevron-forward" size={14} color={theme.colors.primary} />
    </TouchableOpacity>
  </View>
);

export function HomeScreen({ navigation }: any) {
  const { parentName } = useProfileStore();
  const activeChild = useProfileStore(selectActiveChild);
  const firstName = parentName.split(' ')[0] || 'Usuário';
  const childAge = formatAgeFromIso(activeChild?.birthDate);

  const [plays, setPlays] = useState<PlayRow[]>([]);
  const [articles, setArticles] = useState<ArticleRow[]>([]);
  const [planProgress, setPlanProgress] = useState(0);

  useFocusEffect(
    useCallback(() => {
      fetchPlays(6).then(setPlays).catch(() => {});
      fetchArticles(6).then(setArticles).catch(() => {});
      if (activeChild) {
        fetchActivityPlans(activeChild.id)
          .then((plans) => {
            const done = plans.filter((p) => p.status === 'concluido').length;
            setPlanProgress(plans.length > 0 ? Math.round((done / plans.length) * 100) : 0);
          })
          .catch(() => {});
      } else {
        setPlanProgress(0);
      }
    }, [activeChild?.id]),
  );

  const openPlay = (play: PlayRow) => {
    navigation.navigate('ContentDetail', {
      title: play.titulo,
      subtitle: 'Brincadeira educativa',
      body: [play.descricao, play.instrucoes].filter(Boolean).join('\n\n') || 'Sem instruções.',
      mediaUrl: play.media_url,
      mediaType: play.media_type,
    });
  };

  const openArticle = (article: ArticleRow) => {
    navigation.navigate('ContentDetail', {
      title: article.titulo,
      subtitle: 'Conteúdo para pais',
      body: article.corpo,
      mediaUrl: article.imagem_url,
      mediaType: 'imagem',
    });
  };

  const scrollY = useRef(new Animated.Value(0)).current;

  // Fade out large title
  const largeTitleOpacity = scrollY.interpolate({
    inputRange: [0, 80],
    outputRange: [1, 0], 
    extrapolate: 'clamp',
  });

  // Fade in compact profile
  const compactHeaderOpacity = scrollY.interpolate({
    inputRange: [60, CURVE_MAX_HEIGHT],
    outputRange: [0, 1], 
    extrapolate: 'clamp',
  });

  // Shrinks the curve height mathematically perfectly as you scroll
  const curveHeight = scrollY.interpolate({
    inputRange: [0, CURVE_MAX_HEIGHT],
    outputRange: [CURVE_MAX_HEIGHT, 0], 
    extrapolate: 'clamp',
  });

  return (
    <View style={styles.container}>
      
      {/* 1. Curved Background Extension (zIndex 0 - Behind ScrollView) */}
      {/* Animates its height to 0 so it morphs seamlessly into the top fixed header */}
      <Animated.View style={[styles.headerCurve, { height: curveHeight }]} />

      {/* 2. Top Fixed Header (zIndex 10 - Covers content scrolling under it) */}
      {/* Has rounded corners that are revealed when the curved background shrinks! */}
      <View style={styles.topFixedHeader}>
        <View style={styles.topBar}>
          <TouchableOpacity style={styles.iconButton} onPress={() => navigation.goBack()}>
            <Ionicons name="chevron-back" size={28} color={theme.colors.white} />
          </TouchableOpacity>
          
          <Animated.View style={[styles.compactProfile, { opacity: compactHeaderOpacity }]}>
            <View style={styles.compactAvatarPlaceholder}>
              {activeChild?.avatarUrl ? (
                <Image source={{ uri: activeChild.avatarUrl }} style={styles.compactAvatarImage} />
              ) : (
                <Text style={styles.compactAvatarText}>{activeChild?.name.charAt(0).toUpperCase()}</Text>
              )}
            </View>
            <View>
              <Text style={styles.compactProfileName}>{activeChild?.name}</Text>
              <Text style={styles.compactProfileAge}>{childAge}</Text>
            </View>
          </Animated.View>
          
          <TouchableOpacity style={styles.iconButton} onPress={() => navigation.navigate('ChildrenList')}>
            <Feather name="users" size={24} color={theme.colors.white} />
          </TouchableOpacity>
        </View>
      </View>

      {/* 3. Main Scroll View (zIndex 5 - Overlaps curve, slides under top header) */}
      <Animated.ScrollView 
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
        onScroll={Animated.event(
          [{ nativeEvent: { contentOffset: { y: scrollY } } }],
          { useNativeDriver: false } // Required false for height interpolation
        )}
        scrollEventThrottle={16}
      >
        <View style={styles.scrollSpacer}>
           <Animated.Text style={[styles.greeting, { opacity: largeTitleOpacity }]}>
             Olá, {firstName}
           </Animated.Text>
        </View>

        <View style={styles.scrollWhiteBody}>
          
          <View style={styles.mainCardWrapper}>
            <View style={styles.mainCard}>
              <View style={styles.mainCardHeader}>
                <Text style={styles.mainCardTitle}>Plano de atividades atual</Text>
                <Text style={styles.mainCardSubtitle}>
                  Cada conquista de {activeChild?.name} é um passo incrível no desenvolvimento!
                </Text>
              </View>
              
              <View style={styles.profileSection}>
                <View style={styles.avatarPlaceholder}>
                  {activeChild?.avatarUrl ? (
                    <Image source={{ uri: activeChild.avatarUrl }} style={styles.avatarImage} />
                  ) : (
                    <Text style={styles.avatarText}>{activeChild?.name.charAt(0).toUpperCase()}</Text>
                  )}
                </View>
                <View style={styles.profileInfo}>
                  <Text style={styles.profileName}>{activeChild?.name}</Text>
                  <Text style={styles.profileAge}>{childAge}</Text>
                </View>
                <View style={styles.progressCircle}>
                  <Text style={styles.progressText}>{planProgress}%</Text>
                </View>
              </View>
              
              <TouchableOpacity style={styles.primaryButton} activeOpacity={0.8} onPress={() => navigation.navigate('ActivityPlan')}>
                <Text style={styles.primaryButtonText}>Acessar</Text>
              </TouchableOpacity>
            </View>
          </View>

          {plays.length > 0 && (
            <View style={styles.section}>
              <SectionHeader title="Brincadeiras educativas" subtitle="Ideias para estimular brincando" />
              <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.horizontalScroll}>
                {plays.map((play) => (
                  <ActivityCard
                    key={play.id}
                    title={play.titulo}
                    description={play.descricao ?? undefined}
                    imageSource={
                      play.media_type === 'imagem' && play.media_url
                        ? { uri: play.media_url }
                        : undefined
                    }
                    onPress={() => openPlay(play)}
                  />
                ))}
              </ScrollView>
            </View>
          )}

          {articles.length > 0 && (
            <View style={styles.section}>
              <SectionHeader title="Conteúdo para pais" subtitle="Artigos e dicas para o dia a dia" />
              <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.horizontalScroll}>
                {articles.map((article) => (
                  <ActivityCard
                    key={article.id}
                    title={article.titulo}
                    description={article.corpo.slice(0, 90)}
                    imageSource={article.imagem_url ? { uri: article.imagem_url } : undefined}
                    onPress={() => openArticle(article)}
                  />
                ))}
              </ScrollView>
            </View>
          )}

          <View style={styles.section}>
            <SectionHeader title="Conheça nossa loja" subtitle="Conheça os produtos terapêuticos infantis" />
            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.horizontalScroll}>
              <ActivityCard 
                title="Brincar de imitar sons" 
                description="Que tal tentar o jogo “Quem Imita Primeiro”?" 
              />
              <ActivityCard 
                title="Brincar de imitar sons" 
                description="Que tal tentar o jogo “Quem Imita Primeiro”?" 
              />
            </ScrollView>
            
            <View style={{ height: 120 }} />
          </View>
        </View>
      </Animated.ScrollView>

      {/* Bottom Tab Bar */}
      <BottomTabBar activeScreen="Home" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  headerCurve: {
    backgroundColor: '#3678FD',
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
    position: 'absolute',
    top: CURVE_TOP, // Starts filling the corner gaps of the top header perfectly
    left: 0,
    right: 0,
    zIndex: 0,
    elevation: 0,
  },
  topFixedHeader: {
    backgroundColor: '#3678FD',
    height: HEADER_MIN_HEIGHT,
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
    paddingTop: Platform.OS === 'ios' ? 50 : 30,
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 10,
    elevation: 10,
  },
  topBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 50,
    paddingHorizontal: 12,
  },
  iconButton: {
    padding: 8,
    width: 44,
    alignItems: 'center',
    zIndex: 20,
  },
  compactProfile: {
    position: 'absolute',
    left: 0,
    right: 0,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 50, 
  },
  compactAvatarPlaceholder: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
    overflow: 'hidden',
  },
  compactAvatarImage: {
    width: '100%',
    height: '100%',
  },
  compactAvatarText: {
    fontFamily: theme.fonts.mulishBold,
    color: theme.colors.primary,
    fontSize: 14,
  },
  compactProfileName: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 16,
    color: '#FFFFFF',
  },
  compactProfileAge: {
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.8)',
  },
  scrollView: {
    flex: 1,
    zIndex: 5,
    elevation: 5,
  },
  scrollSpacer: {
    height: HEADER_MAX_HEIGHT,
    backgroundColor: 'transparent',
  },
  greeting: {
    position: 'absolute',
    top: HEADER_MIN_HEIGHT + 10, 
    left: 36, 
    fontFamily: theme.fonts.mulishBold,
    fontSize: 24,
    color: '#FFFFFF',
    fontWeight: '700',
  },
  scrollWhiteBody: {
    backgroundColor: '#FFFFFF', 
    flex: 1,
  },
  mainCardWrapper: {
    alignItems: 'center',
    marginBottom: 32,
    marginTop: -40,
  },
  mainCard: {
    width: 345,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    paddingVertical: 40,
    paddingHorizontal: 0,
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 10,
    elevation: 4,
    alignItems: 'center',
  },
  mainCardHeader: {
    width: 297,
    marginBottom: 32,
  },
  mainCardTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 20,
    color: '#000000',
    fontWeight: '500',
    marginBottom: 6,
  },
  mainCardSubtitle: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    color: '#5E5E5E',
    lineHeight: 18,
  },
  profileSection: {
    width: 297,
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 32,
  },
  avatarPlaceholder: {
    width: 76,
    height: 76,
    borderRadius: 38,
    backgroundColor: '#EBF3FF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
    overflow: 'hidden',
  },
  avatarImage: {
    width: '100%',
    height: '100%',
  },
  avatarText: {
    fontFamily: theme.fonts.mulishBold,
    color: theme.colors.primary,
    fontSize: 20,
  },
  profileInfo: {
    flex: 1,
  },
  profileName: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 16,
    color: '#424242',
    fontWeight: '700',
    marginBottom: 4,
  },
  profileAge: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    color: '#424242',
  },
  progressCircle: {
    width: 55,
    height: 55,
    borderRadius: 27.5,
    borderWidth: 3,
    borderColor: 'rgba(14, 93, 253, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  progressText: {
    fontFamily: theme.fonts.mulishBold, 
    fontSize: 12,
    color: '#3678FD',
  },
  primaryButton: {
    width: 297,
    height: 40,
    backgroundColor: '#0E5DFD',
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
  primaryButtonText: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 16,
    color: '#FFFFFF',
    fontWeight: '600',
  },
  section: {
    width: 393,
    marginBottom: 32,
  },
  sectionHeaderContainer: {
    width: 345,
    alignSelf: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    marginBottom: 24,
  },
  sectionHeaderTitleGroup: {
    flex: 1,
  },
  sectionTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    color: '#000000',
    fontWeight: '500',
    marginBottom: 4,
  },
  sectionSubtitle: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    color: '#5E5E5E',
    lineHeight: 18,
  },
  sectionSeeAllBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingBottom: 2, 
  },
  sectionSeeAll: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 12,
    color: '#3678FD',
    fontWeight: '600',
    marginRight: 4,
  },
  horizontalScroll: {
    paddingLeft: 24,
    paddingRight: 8,
    gap: 24,
  },
  activityCard: {
    width: 262,
    height: 347,
    backgroundColor: '#FFFFFF', 
    borderRadius: 12,
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 12,
    elevation: 3,
  },
  activityCardImageContainer: {
    width: 262,
    height: 173,
    borderTopLeftRadius: 12,
    borderTopRightRadius: 12,
    overflow: 'hidden',
  },
  activityCardPlaceholder: {
    backgroundColor: '#C9C9C9',
  },
  activityCardImage: {
    width: '100%',
    height: '100%',
  },
  activityCardContent: {
    width: 262,
    height: 174,
    backgroundColor: '#FFFFFF',
    borderBottomLeftRadius: 12,
    borderBottomRightRadius: 12,
    padding: 24,
    justifyContent: 'space-between',
  },
  activityCardTextGroup: {
    gap: 12,
  },
  activityCardTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 14,
    color: '#424242',
    fontWeight: '700',
  },
  activityCardDescription: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    color: '#424242',
    lineHeight: 17,
  },
  activityCardLinkGroup: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  activityCardLink: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 14,
    color: '#3678FD',
    fontWeight: '600',
    marginRight: 4,
  },
});