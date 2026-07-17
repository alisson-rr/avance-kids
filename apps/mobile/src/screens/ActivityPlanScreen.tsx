import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  StatusBar,
  ScrollView,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { BottomTabBar } from '../components/BottomTabBar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';

// ─── SKILL COLOR MAP (same as TriagemScreen) ──────────────────────────
const SKILL_COLORS: Record<string, { text: string; bg: string }> = {
  'Comunicação':         { text: '#FFA725', bg: '#FFF5E2' },
  'Social':              { text: '#7BAB1E', bg: 'rgba(167, 213, 77, 0.1)' },
  'Cognitiva':           { text: '#9F67FF', bg: 'rgba(159, 103, 255, 0.2)' },
  'Coordenação motora':  { text: '#FF7B00', bg: 'rgba(253, 137, 54, 0.2)' },
};

// ─── MOCK DATA ────────────────────────────────────────────────────────
// Active activities (with progress bar + arrow)
const MOCK_ACTIVE = [
  {
    id: 1,
    skill: 'Comunicação',
    title: 'Imitando sons de animais',
    description: 'Encoraje a criança a imitar os sons do cachorro e gato para estimular a comunicação verbal.',
    progress: 50,
  },
  {
    id: 2,
    skill: 'Coordenação motora',
    title: 'Empilhando blocos coloridos',
    description: 'Incentive a criança a empilhar 3 blocos coloridos para desenvolver a coordenação motora fina.',
    progress: 50,
  },
  {
    id: 3,
    skill: 'Funcional',
    title: 'Brincando de esconder',
    description: 'Use um pano para esconder o rosto e brincar de "Achou!" para estimular a interação social.',
    progress: 50,
  },
  {
    id: 4,
    skill: 'Cognitiva',
    title: 'Identificando cores',
    description: 'Mostre objetos coloridos e peça para a criança identificar as cores de forma lúdica.',
    progress: 50,
  },
];

// Locked activities (lock icon, all #AAAAAA)
const MOCK_LOCKED = [
  {
    id: 5,
    skill: 'Comunicação',
    title: 'Apontar para objetos',
    description: 'Ensine a criança a apontar para o que deseja para desenvolver a comunicação gestual.',
  },
  {
    id: 6,
    skill: 'Comunicação',
    title: 'Cantar músicas simples',
    description: 'Cante músicas infantis simples com a criança para estimular a linguagem receptiva e expressiva.',
  },
  {
    id: 7,
    skill: 'Comunicação',
    title: 'Nomear partes do corpo',
    description: 'Aponte para partes do corpo e peça para a criança repetir os nomes para ampliar o vocabulário.',
  },
];

// ─── COMPONENT ────────────────────────────────────────────────────────
export function ActivityPlanScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  const getSkillColor = (skill: string) => SKILL_COLORS[skill] || { text: '#3678FD', bg: '#EEF4FF' };

  // ── Active card ─────────────────────────────────────────────────
  const renderActiveCard = (item: typeof MOCK_ACTIVE[0]) => {
    const color = getSkillColor(item.skill);
    return (
      <TouchableOpacity style={styles.card} key={item.id} activeOpacity={0.7} onPress={() => navigation.navigate('Activity', { activityId: item.id, skill: item.skill })}>
        {/* Top row: tag + progress */}
        <View style={styles.cardTopRow}>
          {/* Skill tag */}
          <View style={[styles.tagBadge, { backgroundColor: color.bg }]}>
            <Text style={[styles.tagText, { color: color.text }]}>{item.skill}</Text>
          </View>
          {/* Progress: bar + percentage */}
          <View style={styles.progressRow}>
            <View style={styles.progressTrack}>
              <View style={[styles.progressFill, { width: `${item.progress}%` }]} />
            </View>
            <Text style={styles.progressText}>{item.progress}%</Text>
          </View>
        </View>

        {/* Bottom row: text content + arrow */}
        <View style={styles.cardBottomRow}>
          <View style={styles.cardTextArea}>
            <Text style={styles.cardTitle}>{item.title}</Text>
            <Text style={styles.cardDescription} numberOfLines={2}>{item.description}</Text>
          </View>
          <View style={styles.arrowContainer}>
            <Text style={styles.arrowIcon}>›</Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  // ── Locked card ─────────────────────────────────────────────────
  const renderLockedCard = (item: typeof MOCK_LOCKED[0]) => {
    return (
      <View style={styles.card} key={item.id}>
        {/* Tag row */}
        <View style={[styles.tagBadge, { backgroundColor: '#F1F1F1', alignSelf: 'flex-start' }]}>
          <Text style={[styles.tagText, { color: '#AAAAAA' }]}>{item.skill}</Text>
        </View>
        {/* Bottom row: text + lock icon */}
        <View style={styles.cardLockedTopRow}>
          <View style={styles.cardTextArea}>
            <Text style={[styles.cardTitle, { color: '#AAAAAA' }]}>{item.title}</Text>
            <Text style={[styles.cardDescription, { color: '#AAAAAA' }]} numberOfLines={2}>{item.description}</Text>
          </View>
          {/* Lock icon */}
          <Text style={styles.lockIcon}>🔒</Text>
        </View>
      </View>
    );
  };

  return (
    <View style={[styles.screen, { paddingTop: safeTop }]}>
      <StatusBar barStyle="dark-content" backgroundColor="#FAFAFA" />

      {/* ── HEADER (Figma: 393×55, row, space-between, padding 0 24px) ── */}
      <View style={styles.titlePageRow}>
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={styles.headerIconBtn}
          hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
        >
          <Ionicons name="chevron-back" size={24} color="#0E5DFD" />
        </TouchableOpacity>

        <Text style={styles.headerTitle}>Plano de atividades</Text>

        {/* Spacer (no icon) */}
        <View style={styles.headerIconBtn} />
      </View>


      {/* ── CONTENT ── */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Ver histórico button (right aligned) */}
        <View style={styles.historyRow}>
          <TouchableOpacity style={styles.historyBtn}>
            <Text style={styles.historyText}>Ver histórico</Text>
          </TouchableOpacity>
        </View>

        {/* ── "Atividades atuais" section ── */}
        <View style={styles.sectionContainer}>
          <View style={styles.sectionHeaderGroup}>
            <Text style={styles.sectionTitle}>Atividades atuais</Text>
            <Text style={styles.sectionSubtitle}>Conclua para desbloquear as próximas</Text>
          </View>
          <View style={styles.cardsList}>
            {MOCK_ACTIVE.map(renderActiveCard)}
          </View>
        </View>

        {/* ── "Próximos exercícios" section ── */}
        <View style={styles.sectionContainer}>
          <View style={styles.sectionHeaderGroup}>
            <Text style={styles.sectionTitle}>Próximos exercícios</Text>
            <Text style={styles.sectionSubtitle}>Conclua os exercícios acima para desbloquear as próximas atividades</Text>
          </View>
          <View style={styles.cardsList}>
            {MOCK_LOCKED.map(renderLockedCard)}
          </View>
        </View>
      </ScrollView>

      {/* ── BOTTOM TAB BAR ── */}
      <BottomTabBar activeScreen="ActivityPlan" />
    </View>
  );
}

// ─── STYLES (Figma-faithful from CSS export) ──────────────────────────
const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },

  // ── Title Page Row (Figma: row, space-between, padding 0 24px, 393×55, gap 113) ──
  titlePageRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
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
    // Figma: border 1.5px solid #0E5DFD
    fontSize: 28,
    color: '#0E5DFD',
    lineHeight: 30,
    marginTop: -2,
  },
  headerTitle: {
    // Figma: Inter 600, 16px, line-height 20px, letter-spacing 2%, center, #000000
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    letterSpacing: 0.32,
    textAlign: 'center',
    color: '#000000',
  },
  infoCircle: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 0.875,
    borderColor: '#0E5DFD',
    alignItems: 'center',
    justifyContent: 'center',
  },
  infoText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 11,
    color: '#0E5DFD',
    lineHeight: 14,
  },

  // ── ScrollView ──────────────────────────────────────────────────
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 24,
    paddingBottom: 40,
    gap: 32,
  },

  // ── History row (Figma: right-aligned, padding 0 24px, 393×20) ──
  historyRow: {
    alignItems: 'flex-end',
  },
  historyBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  historyIcon: {
    fontSize: 14,
    color: '#0E5DFD',
  },
  historyText: {
    // Figma: Inter 600, 14px, line-height 17px, text-align right, #0E5DFD
    fontFamily: theme.fonts.semiBold,
    fontSize: 14,
    lineHeight: 17,
    textAlign: 'right',
    color: '#0E5DFD',
  },

  // ── Sections ───────────────────────────────────────────────────
  sectionContainer: {
    gap: 24,
  },
  sectionHeaderGroup: {
    gap: 4,
  },
  sectionTitle: {
    // Figma: Inter 500, 18px, line-height 22px, #000000
    fontFamily: theme.fonts.medium,
    fontSize: 18,
    lineHeight: 22,
    color: '#000000',
  },
  sectionSubtitle: {
    // Figma: Inter 500, 14px, line-height 17px, #5E5E5E
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    lineHeight: 17,
    color: '#5E5E5E',
  },
  cardsList: {
    gap: 24,
  },

  // ── Card (Figma: column, padding 24, 345×157/140, bg #FFF, shadow, radius 12) ──
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 24,
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 12,
    elevation: 4,
    gap: 26,
  },

  // ── Active card top row (tag + progress) ────────────────────────
  cardTopRow: {
    // Figma: row, space-between, gap 12, 297×37
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 12,
  },

  // ── Tag badge ──────────────────────────────────────────────────
  tagBadge: {
    // Figma: row, center, padding 0 10px, gap 10, border-radius 12
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 10,
    height: 20,
    borderRadius: 12,
  },
  tagText: {
    // Figma: Inter 700, 12px, line-height 20px
    fontFamily: theme.fonts.semiBold,
    fontSize: 12,
    lineHeight: 20,
    fontWeight: '700',
  },

  // ── Progress (bar + percentage text) ───────────────────────────
  progressRow: {
    // Figma: row, gap 12, isolation isolate, 139×17
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  progressTrack: {
    // Figma: 97×6, bg #DDDDDD, border-radius 50px
    flex: 1,
    height: 6,
    backgroundColor: '#DDDDDD',
    borderRadius: 50,
    overflow: 'hidden',
  },
  progressFill: {
    // Figma: bg #79A5FF, border-radius 50px, height 7
    height: 7,
    backgroundColor: '#79A5FF',
    borderRadius: 50,
    marginTop: -0.5,
  },
  progressText: {
    // Figma: Inter 500, 14px, line-height 17px, #5E5E5E
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    lineHeight: 17,
    color: '#5E5E5E',
  },

  // ── Active card bottom row (text + arrow) ──────────────────────
  cardBottomRow: {
    // Figma: row, gap 12, 297×60
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  cardTextArea: {
    // Figma: column, gap 4, 262×60
    flex: 1,
    gap: 4,
  },
  cardTitle: {
    // Figma: Inter 600, 16px, line-height 20px, #3B3B3B
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    color: '#3B3B3B',
  },
  cardDescription: {
    // Figma: Inter 400, 12px, line-height 18px, #5E5E5E
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    lineHeight: 18,
    color: '#5E5E5E',
  },
  arrowContainer: {
    // Figma: row, justify-end, align-end, 23×60
    width: 23,
    justifyContent: 'flex-end',
    alignItems: 'flex-end',
  },
  arrowIcon: {
    // Figma: 7.13×12.97, bg #3678FD, rotated
    fontSize: 22,
    color: '#3678FD',
    lineHeight: 24,
  },

  // ── Locked card top row ────────────────────────────────────────
  cardLockedTopRow: {
    // Figma: row, space-between, align-end, gap 11, 297×92
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    gap: 11,
  },
  cardLockedContent: {
    // Figma: column, gap 12, 262×92
    flex: 1,
    gap: 12,
  },
  lockIcon: {
    // Figma: 15×20, bg #AAAAAA
    fontSize: 16,
    color: '#AAAAAA',
  },
});
