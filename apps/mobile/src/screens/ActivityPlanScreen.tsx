import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  StatusBar,
  ScrollView,
} from 'react-native';
import { BottomTabBar } from '../components/BottomTabBar';
import { ScreenHeader } from '../components/ScreenHeader';
import { SkillActivityCard } from '../components/SkillActivityCard';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';

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

  return (
    <View style={[styles.screen, { paddingTop: safeTop }]}>
      <StatusBar barStyle="dark-content" backgroundColor="#FAFAFA" />

      <ScreenHeader
        variant="compact"
        title="Plano de atividades"
        onBack={() => navigation.goBack()}
      />

      {/* ── CONTENT ── */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Ver histórico button (right aligned) */}
        <View style={styles.historyRow}>
          <TouchableOpacity style={styles.historyBtn} onPress={() => navigation.navigate('ActivityHistory')}>
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
            {MOCK_ACTIVE.map((item) => (
              <SkillActivityCard
                key={item.id}
                skill={item.skill}
                title={item.title}
                description={item.description}
                progress={item.progress}
                onPress={() => navigation.navigate('Activity', { activityId: item.id, skill: item.skill })}
              />
            ))}
          </View>
        </View>

        {/* ── "Próximos exercícios" section ── */}
        <View style={styles.sectionContainer}>
          <View style={styles.sectionHeaderGroup}>
            <Text style={styles.sectionTitle}>Próximos exercícios</Text>
            <Text style={styles.sectionSubtitle}>Conclua os exercícios acima para desbloquear as próximas atividades</Text>
          </View>
          <View style={styles.cardsList}>
            {MOCK_LOCKED.map((item) => (
              <SkillActivityCard
                key={item.id}
                skill={item.skill}
                title={item.title}
                description={item.description}
                locked
              />
            ))}
          </View>
        </View>
      </ScrollView>

      {/* ── BOTTOM TAB BAR ── */}
      <BottomTabBar activeScreen="ActivityPlan" />
    </View>
  );
}

// ─── STYLES ───────────────────────────────────────────────────────────
const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 24,
    paddingBottom: 40,
    gap: 32,
  },
  historyRow: {
    alignItems: 'flex-end',
  },
  historyBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  historyText: {
    // Figma: Inter 600, 14px, line-height 17px, text-align right, #0E5DFD
    fontFamily: theme.fonts.semiBold,
    fontSize: 14,
    lineHeight: 17,
    textAlign: 'right',
    color: '#0E5DFD',
  },
  sectionContainer: {
    gap: 24,
  },
  sectionHeaderGroup: {
    gap: 4,
  },
  sectionTitle: {
    fontFamily: theme.fonts.medium,
    fontSize: 18,
    lineHeight: 22,
    color: '#000000',
  },
  sectionSubtitle: {
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    lineHeight: 17,
    color: '#5E5E5E',
  },
  cardsList: {
    gap: 24,
  },
});
