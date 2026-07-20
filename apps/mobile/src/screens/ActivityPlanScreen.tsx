import React, { useCallback, useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  StatusBar,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { BottomTabBar } from '../components/BottomTabBar';
import { ScreenHeader } from '../components/ScreenHeader';
import { SkillActivityCard } from '../components/SkillActivityCard';
import { Button } from '../components/Button';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';
import { fetchActivityPlans, findOpenSession } from '../services/activities';
import { errorMessage } from '../services/api';
import { useProfileStore, selectActiveChild } from '../store/useProfileStore';
import type { PlanWithDetails } from '../types/db';

function planDescription(plan: PlanWithDetails): string {
  return plan.exercises.objetivo ?? plan.exercises.procedimento ?? '';
}

// ─── COMPONENT ────────────────────────────────────────────────────────
export function ActivityPlanScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);
  const activeChild = useProfileStore(selectActiveChild);

  const [plans, setPlans] = useState<PlanWithDetails[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!activeChild) {
      setPlans([]);
      return;
    }
    setLoadError(null);
    try {
      setPlans(await fetchActivityPlans(activeChild.id));
    } catch (err) {
      setLoadError(errorMessage(err));
      setPlans([]);
    }
  }, [activeChild?.id]);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load]),
  );

  const activePlans = (plans ?? []).filter((p) => p.status === 'ativo');
  const lockedPlans = (plans ?? []).filter((p) => p.status === 'bloqueado');

  // % = acertos "sem ajuda" da sessão atual rumo à meta de 8/10 (80% conclui)
  const progressFor = (plan: PlanWithDetails): number => {
    const session = findOpenSession(plan);
    return session ? session.successful_count * 10 : 0;
  };

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

        {plans === null ? (
          <View style={styles.stateContainer}>
            <ActivityIndicator size="large" color={theme.colors.primary} />
          </View>
        ) : loadError ? (
          <View style={styles.stateContainer}>
            <Text style={styles.stateText}>{loadError}</Text>
            <Button title="Tentar novamente" onPress={load} />
          </View>
        ) : plans.length === 0 ? (
          <View style={styles.stateContainer}>
            <Text style={styles.stateText}>
              {activeChild
                ? `${activeChild.name} ainda não tem um plano de atividades. Complete a triagem para gerar o plano personalizado.`
                : 'Cadastre uma criança para gerar o plano de atividades.'}
            </Text>
            <Button
              title={activeChild ? 'Fazer triagem' : 'Cadastrar criança'}
              onPress={() => navigation.navigate(activeChild ? 'Triagem' : 'ChildRegister')}
            />
          </View>
        ) : (
          <>
            {/* ── "Atividades atuais" section ── */}
            <View style={styles.sectionContainer}>
              <View style={styles.sectionHeaderGroup}>
                <Text style={styles.sectionTitle}>Atividades atuais</Text>
                <Text style={styles.sectionSubtitle}>Conclua para desbloquear as próximas</Text>
              </View>
              <View style={styles.cardsList}>
                {activePlans.map((plan) => (
                  <SkillActivityCard
                    key={plan.id}
                    skill={plan.skills.nome}
                    title={plan.exercises.titulo}
                    description={planDescription(plan)}
                    progress={progressFor(plan)}
                    onPress={() => navigation.navigate('Activity', { planId: plan.id })}
                  />
                ))}
                {activePlans.length === 0 && (
                  <Text style={styles.stateText}>Nenhuma atividade ativa no momento.</Text>
                )}
              </View>
            </View>

            {/* ── "Próximos exercícios" section ── */}
            {lockedPlans.length > 0 && (
              <View style={styles.sectionContainer}>
                <View style={styles.sectionHeaderGroup}>
                  <Text style={styles.sectionTitle}>Próximos exercícios</Text>
                  <Text style={styles.sectionSubtitle}>Conclua os exercícios acima para desbloquear as próximas atividades</Text>
                </View>
                <View style={styles.cardsList}>
                  {lockedPlans.map((plan) => (
                    <SkillActivityCard
                      key={plan.id}
                      skill={plan.skills.nome}
                      title={plan.exercises.titulo}
                      description={planDescription(plan)}
                      locked
                    />
                  ))}
                </View>
              </View>
            )}
          </>
        )}
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
    fontFamily: theme.fonts.semiBold,
    fontSize: 14,
    lineHeight: 17,
    textAlign: 'right',
    color: '#0E5DFD',
  },
  stateContainer: {
    paddingTop: 32,
    alignItems: 'center',
    gap: 24,
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
