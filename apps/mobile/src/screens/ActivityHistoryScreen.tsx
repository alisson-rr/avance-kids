import React, { useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  StatusBar,
  ScrollView,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { ScreenHeader } from '../components/ScreenHeader';
import { SkillActivityCard } from '../components/SkillActivityCard';
import { useProfileStore } from '../store/useProfileStore';

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

  const handleChildChange = (name: string) => {
    const child = children.find(c => c.name === name);
    if (child) {
      setSelectedChildId(child.id);
    }
  };

  return (
    <View style={[styles.screen, { paddingTop: safeTop }]}>
      <StatusBar barStyle="dark-content" backgroundColor="#FAFAFA" />

      <ScreenHeader
        variant="compact"
        title="Histórico de Atividades"
        onBack={() => navigation.goBack()}
      />

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
            {MOCK_HISTORY.map((item) => (
              <SkillActivityCard
                key={item.id}
                skill={item.skill}
                title={item.title}
                description={item.description}
                progress={item.successRate}
                progressSuffix="% de acerto"
                compactProgress
                onPress={() => navigation.navigate('Activity', { activityId: item.id, skill: item.skill })}
              />
            ))}
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
});
