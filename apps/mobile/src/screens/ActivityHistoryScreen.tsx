import React, { useCallback, useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  StatusBar,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { theme } from '../theme';
import { Button } from '../components/Button';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { ScreenHeader } from '../components/ScreenHeader';
import { SkillActivityCard } from '../components/SkillActivityCard';
import { useProfileStore, selectActiveChild } from '../store/useProfileStore';
import { fetchActivityPlans, successRate } from '../services/activities';
import { errorMessage } from '../services/api';
import type { PlanWithDetails } from '../types/db';

export function ActivityHistoryScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  const { children } = useProfileStore();
  const activeChild = useProfileStore(selectActiveChild);
  const [selectedChildId, setSelectedChildId] = useState(activeChild?.id || '');

  const [history, setHistory] = useState<PlanWithDetails[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  const childOptions = children.map(c => c.name);
  const selectedChildName = children.find(c => c.id === selectedChildId)?.name || childOptions[0];

  const handleChildChange = (name: string) => {
    const child = children.find(c => c.name === name);
    if (child) {
      setSelectedChildId(child.id);
    }
  };

  const load = useCallback(async () => {
    const childId = selectedChildId || activeChild?.id;
    if (!childId) {
      setHistory([]);
      return;
    }
    setHistory(null);
    setLoadError(null);
    try {
      const plans = await fetchActivityPlans(childId);
      // `exercises` nulo = atividade premium que a assinatura atual não abre
      // (ex.: assinatura cancelada). Sem o exercício não há o que exibir.
      setHistory(plans.filter((p) => p.status === 'concluido' && p.exercises !== null));
    } catch (err) {
      setLoadError(errorMessage(err));
      setHistory([]);
    }
  }, [selectedChildId, activeChild?.id]);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load]),
  );

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
          {history === null ? (
            <View style={styles.stateContainer}>
              <ActivityIndicator size="large" color={theme.colors.primary} />
            </View>
          ) : loadError ? (
            <View style={styles.stateContainer}>
              <Text style={styles.stateText}>{loadError}</Text>
              <Button title="Tentar novamente" onPress={load} />
            </View>
          ) : history.length === 0 ? (
            <View style={styles.stateContainer}>
              <Text style={styles.stateTitle}>Nenhuma atividade concluída ainda</Text>
              <Text style={styles.stateText}>
                Quando uma atividade do plano for concluída, ela aparece aqui com o
                desempenho de cada repetição.
              </Text>
            </View>
          ) : (
            <View style={styles.cardsList}>
              {history.map((plan) => (
                <SkillActivityCard
                  key={plan.id}
                  skill={plan.skills.nome}
                  title={plan.exercises!.titulo}
                  description={plan.exercises!.objetivo ?? ''}
                  progress={successRate(plan)}
                  progressSuffix="% de acerto"
                  compactProgress
                  onPress={() => navigation.navigate('Activity', { planId: plan.id })}
                />
              ))}
            </View>
          )}
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
  stateContainer: {
    paddingTop: 24,
    alignItems: 'center',
    gap: 16,
  },
  stateTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 22,
    color: '#3B3B3B',
    textAlign: 'center',
  },
  stateText: {
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    lineHeight: 22,
    color: '#5E5E5E',
    textAlign: 'center',
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
