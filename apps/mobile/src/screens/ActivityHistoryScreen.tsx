import React, { useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  StatusBar,
  ScrollView,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { useProfileStore } from '../store/useProfileStore';

const SKILL_COLORS: Record<string, { text: string; bg: string }> = {
  'Comunicação':         { text: '#FFA725', bg: '#FFF5E2' },
  'Social':              { text: '#7BAB1E', bg: 'rgba(167, 213, 77, 0.1)' },
  'Cognitiva':           { text: '#9F67FF', bg: 'rgba(159, 103, 255, 0.2)' },
  'Coordenação motora':  { text: '#FF7B00', bg: 'rgba(253, 137, 54, 0.2)' },
};

const MOCK_HISTORY = [
  {
    id: 1,
    skill: 'Comunicação',
    title: 'Imitando sons de animais',
    description: 'Encoraje a criança a imitar os sons do cachorro e gato para estimular a comunicação verbal.',
    successRate: 80,
  },
  {
    id: 2,
    skill: 'Coordenação motora',
    title: 'Empilhando blocos coloridos',
    description: 'Incentive a criança a empilhar 3 blocos coloridos para desenvolver a coordenação motora fina.',
    successRate: 100,
  },
  {
    id: 3,
    skill: 'Cognitiva',
    title: 'Identificando cores',
    description: 'Mostre objetos coloridos e peça para a criança identificar as cores de forma lúdica.',
    successRate: 60,
  },
];

export function ActivityHistoryScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);
  
  const { children } = useProfileStore();
  const activeChild = children.find(c => c.isActive) || children[0];
  const [selectedChildId, setSelectedChildId] = useState(activeChild?.id || '');

  const childOptions = children.map(c => c.name);
  const selectedChildName = children.find(c => c.id === selectedChildId)?.name || childOptions[0];

  const getSkillColor = (skill: string) => SKILL_COLORS[skill] || { text: '#3678FD', bg: '#EEF4FF' };

  const handleChildChange = (name: string) => {
    const child = children.find(c => c.name === name);
    if (child) {
      setSelectedChildId(child.id);
    }
  };

  const renderHistoryCard = (item: typeof MOCK_HISTORY[0]) => {
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
              <View style={[styles.progressFill, { width: `${item.successRate}%` }]} />
            </View>
            <Text style={styles.progressText}>{item.successRate}% de acerto</Text>
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

  return (
    <View style={[styles.screen, { paddingTop: safeTop }]}>
      <StatusBar barStyle="dark-content" backgroundColor="#FAFAFA" />

      {/* ── HEADER ── */}
      <View style={styles.titlePageRow}>
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={styles.headerIconBtn}
          hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
        >
          <Ionicons name="chevron-back" size={24} color="#0E5DFD" />
        </TouchableOpacity>

        <Text style={styles.headerTitle}>Histórico de Atividades</Text>

        <View style={styles.headerIconBtn} />
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.filterContainer}>
          <Text style={styles.filterLabel}>Criança</Text>
          <BottomSheetSelect 
            placeholder="Selecione a criança" 
            value={selectedChildName}
            onChange={handleChildChange}
            options={childOptions}
          />
        </View>

        <View style={styles.sectionContainer}>
          <View style={styles.sectionHeaderGroup}>
            <Text style={styles.sectionTitle}>Atividades Concluídas</Text>
            <Text style={styles.sectionSubtitle}>Reveja o desempenho e repita se desejar</Text>
          </View>
          <View style={styles.cardsList}>
            {MOCK_HISTORY.map(renderHistoryCard)}
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
  headerTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    letterSpacing: 0.32,
    textAlign: 'center',
    color: '#000000',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 24,
    paddingBottom: 40,
    gap: 24,
  },
  filterContainer: {
    marginTop: 10,
    marginBottom: 8,
  },
  filterLabel: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 14,
    color: theme.colors.textDark,
    marginBottom: 8,
    marginLeft: 4,
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
  cardTopRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 12,
  },
  tagBadge: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 10,
    height: 20,
    borderRadius: 12,
  },
  tagText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 12,
    lineHeight: 20,
    fontWeight: '700',
  },
  progressRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  progressTrack: {
    width: 60,
    height: 6,
    backgroundColor: '#DDDDDD',
    borderRadius: 50,
    overflow: 'hidden',
  },
  progressFill: {
    height: 7,
    backgroundColor: '#79A5FF',
    borderRadius: 50,
    marginTop: -0.5,
  },
  progressText: {
    fontFamily: theme.fonts.medium,
    fontSize: 12,
    lineHeight: 15,
    color: '#5E5E5E',
  },
  cardBottomRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  cardTextArea: {
    flex: 1,
    gap: 4,
  },
  cardTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    color: '#3B3B3B',
  },
  cardDescription: {
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    lineHeight: 18,
    color: '#5E5E5E',
  },
  arrowContainer: {
    width: 23,
    justifyContent: 'flex-end',
    alignItems: 'flex-end',
  },
  arrowIcon: {
    fontSize: 22,
    color: '#3678FD',
    lineHeight: 24,
  },
});
