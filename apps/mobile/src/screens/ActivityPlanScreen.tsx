import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  SafeAreaView,
  TouchableOpacity,
  ScrollView,
  StatusBar,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';

// ─── MOCK DATA ────────────────────────────────────────────────────────
const MOCK_ACTIVITIES = [
  {
    id: 1,
    tag: 'Comunicação',
    title: 'Imitando sons de animais',
    description: 'Encoraje a criança a imitar os sons do cachorro e gato.',
    progress: 75,
    locked: false,
  },
  {
    id: 2,
    tag: 'Social',
    title: 'Brincando de esconder',
    description: 'Use um pano para esconder o rosto e brincar de "Achou!".',
    progress: 30,
    locked: false,
  },
];

const MOCK_UPCOMING = [
  {
    id: 3,
    tag: 'Motor',
    title: 'Empilhar 3 blocos',
    description: 'Atividade focada em coordenação motora fina.',
    progress: 0,
    locked: true,
  },
  {
    id: 4,
    tag: 'Comunicação',
    title: 'Apontar para objetos',
    description: 'Ensine a criança a apontar para o que deseja.',
    progress: 0,
    locked: true,
  }
];

export function ActivityPlanScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  const handleGoBack = () => {
    navigation.goBack();
  };

  const renderActivityCard = (item: any) => {
    return (
      <View style={[styles.activityCard, item.locked && styles.activityCardLocked]} key={item.id}>
        <View style={styles.cardHeaderRow}>
          <View style={[styles.tagBadge, item.locked && styles.tagBadgeLocked]}>
            <Text style={[styles.tagText, item.locked && styles.tagTextLocked]}>{item.tag}</Text>
          </View>
          {item.locked && (
            <Text style={styles.lockIcon}>🔒</Text>
          )}
        </View>

        <Text style={[styles.cardTitle, item.locked && styles.cardTitleLocked]}>
          {item.title}
        </Text>
        
        <Text style={[styles.cardDescription, item.locked && styles.cardDescriptionLocked]}>
          {item.description}
        </Text>

        {!item.locked && (
          <View style={styles.progressContainer}>
            <View style={styles.progressTrack}>
              <View style={[styles.progressFill, { width: `${item.progress}%` }]} />
            </View>
            <Text style={styles.progressText}>{item.progress}%</Text>
          </View>
        )}
      </View>
    );
  };

  return (
    <View style={styles.screen}>
      <StatusBar barStyle="light-content" backgroundColor="#3678FD" />

      {/* ── BLUE HEADER BAND ── */}
      <View style={[styles.blueHeader, { paddingTop: safeTop }]}>
        <View style={styles.titleRow}>
          <TouchableOpacity
            onPress={handleGoBack}
            style={styles.headerIconBtn}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Text style={styles.headerChevron}>‹</Text>
          </TouchableOpacity>

          <Text style={styles.headerTitle}>Plano de Atividades</Text>

          {/* Espaçador invisível (Sem ícone "I") */}
          <View style={styles.headerIconBtn} />
        </View>
      </View>

      {/* ── CONTENT ── */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Atividades atuais</Text>
          <View style={styles.cardsList}>
            {MOCK_ACTIVITIES.map(renderActivityCard)}
          </View>
        </View>

        <View style={[styles.section, styles.lockedSection]}>
          <Text style={styles.sectionTitle}>Próximos exercícios</Text>
          <View style={styles.cardsList}>
            {MOCK_UPCOMING.map(renderActivityCard)}
          </View>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  // ── Blue header band ─────────────────────────────────────────────
  blueHeader: {
    backgroundColor: '#3678FD',
    paddingBottom: 20, 
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 24,
    height: 55,
  },
  headerIconBtn: {
    width: 24,
    height: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerChevron: {
    fontSize: 28,
    color: '#FFFFFF',
    lineHeight: 30,
    marginTop: -2,
  },
  headerTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    textAlign: 'center',
    color: '#FFFFFF',
  },
  
  // ── ScrollView ──────────────────────────────────────────────────
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingTop: 32,
    paddingHorizontal: 24,
    paddingBottom: 40,
    gap: 32,
  },

  // ── Sections ───────────────────────────────────────────────────
  section: {
    gap: 16,
  },
  lockedSection: {
    marginTop: 16,
  },
  sectionTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 18,
    color: '#333333',
  },
  cardsList: {
    gap: 16,
  },

  // ── Card ───────────────────────────────────────────────────────
  activityCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: '#EFEFEF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
    elevation: 2,
    gap: 12,
  },
  activityCardLocked: {
    backgroundColor: '#F5F5F5',
    borderColor: '#E0E0E0',
    shadowOpacity: 0,
    elevation: 0,
  },

  // ── Card Header ───────────────────────────────────────────────
  cardHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  tagBadge: {
    backgroundColor: '#EEF4FF',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 100,
    alignSelf: 'flex-start',
  },
  tagBadgeLocked: {
    backgroundColor: '#EBEBEB',
  },
  tagText: {
    fontFamily: theme.fonts.medium,
    fontSize: 12,
    color: '#3678FD',
  },
  tagTextLocked: {
    color: '#999999',
  },
  lockIcon: {
    fontSize: 16,
  },

  // ── Text Content ─────────────────────────────────────────────
  cardTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#000000',
  },
  cardTitleLocked: {
    color: '#AAAAAA',
  },
  cardDescription: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    color: '#555555',
    lineHeight: 20,
  },
  cardDescriptionLocked: {
    color: '#AAAAAA',
  },

  // ── Progress ─────────────────────────────────────────────────
  progressContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginTop: 4,
  },
  progressTrack: {
    flex: 1,
    height: 6,
    backgroundColor: '#EEF4FF',
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#3678FD',
    borderRadius: 3,
  },
  progressText: {
    fontFamily: theme.fonts.medium,
    fontSize: 12,
    color: '#3678FD',
    width: 35,
    textAlign: 'right',
  },
});
