import React, { useCallback, useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StatusBar,
  ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { theme } from '../theme';
import { Button } from '../components/Button';
import { HABILIDADE_STYLES, type HabilidadeKey } from '../data/habilidades';
import { fetchAgeBrackets, fetchSkills, resolveBracketForMonths } from '../services/catalog';
import { fetchQuestions, fetchScreeningAnsweredCounts } from '../services/questions';
import { generateActivityPlan } from '../services/activities';
import { errorMessage } from '../services/api';
import { showDialog, showError } from '../ui/dialog';
import { useProfileStore, selectActiveChild } from '../store/useProfileStore';
import type { SkillRow } from '../types/db';

const FALLBACK_STYLE = HABILIDADE_STYLES.comunicacao;

// ─── COMPONENT ────────────────────────────────────────────────────────
export function TriagemScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);
  const activeChild = useProfileStore(selectActiveChild);

  const [skills, setSkills] = useState<SkillRow[]>([]);
  const [bracketId, setBracketId] = useState<string | null>(null);
  const [totals, setTotals] = useState<Record<string, number>>({});
  const [answered, setAnswered] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);

  const load = useCallback(async () => {
    if (!activeChild) return;
    setLoading(true);
    try {
      const [brackets, skillRows] = await Promise.all([fetchAgeBrackets(), fetchSkills()]);
      const months =
        activeChild.idadeGeralMeses ?? activeChild.idadeBiologicaMeses ?? 12;
      const bracket = resolveBracketForMonths(months, brackets);
      if (!bracket) throw new Error('Faixas etárias não configuradas.');

      const [questions, counts] = await Promise.all([
        fetchQuestions('triagem', bracket.id),
        fetchScreeningAnsweredCounts(activeChild.id),
      ]);

      const totalsBySkill: Record<string, number> = {};
      for (const q of questions) {
        totalsBySkill[q.skill_id] = (totalsBySkill[q.skill_id] ?? 0) + 1;
      }

      setSkills(skillRows);
      setBracketId(bracket.id);
      setTotals(totalsBySkill);
      setAnswered(counts);
    } catch (err) {
      showError('Erro ao carregar', errorMessage(err));
    } finally {
      setLoading(false);
    }
  }, [activeChild?.id]);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load]),
  );

  const handleConcluir = async () => {
    if (!activeChild) return;

    // Só conclui com TODAS as habilidades respondidas por completo
    const pendentes = skills.filter(
      (s) => (totals[s.id] ?? 0) > 0 && (answered[s.id] ?? 0) < (totals[s.id] ?? 0),
    );
    if (pendentes.length > 0) {
      showDialog({
        title: 'Triagem incompleta',
        message: `Para gerar o plano personalizado, responda todas as habilidades. Ainda ${
          pendentes.length === 1 ? 'falta' : 'faltam'
        }: ${pendentes.map((p) => p.nome).join(', ')}.`,
        variant: 'info',
        buttons: [{ label: 'Continuar respondendo', kind: 'primary' }],
      });
      return;
    }

    setGenerating(true);
    try {
      await generateActivityPlan(activeChild.id);
      await useProfileStore.getState().refreshChildren();
      navigation.navigate('Onboarding3');
    } catch (err) {
      showError('Não foi possível gerar o plano', errorMessage(err));
    } finally {
      setGenerating(false);
    }
  };

  const styleFor = (skill: SkillRow) =>
    HABILIDADE_STYLES[skill.key as HabilidadeKey] ?? FALLBACK_STYLE;

  return (
    <View style={[styles.safeArea, { paddingTop: safeTop, paddingBottom: insets.bottom }]}>
      <StatusBar barStyle="dark-content" backgroundColor="#FAFAFA" />

      {/* ── HEADER SECTION ── */}
      <View style={styles.headerSection}>
        <View style={styles.titleRow}>
          <TouchableOpacity
            onPress={() => navigation.goBack()}
            style={styles.iconBtn}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Text style={styles.chevron}>‹</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.titleBlock}>
          <Text style={styles.pageTitle}>Habilidades</Text>
          <Text style={styles.pageDescription}>
            Responda para receber o plano personalizado para o desenvolvimento de{' '}
            {activeChild?.name ?? 'sua criança'}.
          </Text>
        </View>
      </View>

      {/* ── CARDS + BUTTON ── */}
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        bounces={false}
      >
        {loading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color={theme.colors.primary} />
          </View>
        ) : (
          <View style={styles.cardsList}>
            {skills.map((skill) => (
              <TouchableOpacity
                key={skill.id}
                style={styles.card}
                activeOpacity={0.7}
                onPress={() =>
                  navigation.navigate('Habilidade', {
                    skillId: skill.id,
                    skillKey: skill.key,
                    skillNome: skill.nome,
                    bracketId,
                  })
                }
              >
                {/* Colored circle */}
                <View style={[styles.circle, { backgroundColor: styleFor(skill).background }]} />

                {/* Right content */}
                <View style={styles.cardRight}>
                  <View style={styles.cardMeta}>
                    <View style={styles.cardTitleGroup}>
                      <Text style={styles.cardTitle}>{skill.nome}</Text>
                    </View>
                    <View style={styles.cardCountGroup}>
                      <Text style={styles.cardCount}>
                        {Math.min(answered[skill.id] ?? 0, totals[skill.id] ?? 0)}/
                        {totals[skill.id] ?? 0}
                      </Text>
                    </View>
                  </View>

                  <View style={styles.responderRow}>
                    <Text style={styles.responderText}>Responder</Text>
                    <Text style={styles.responderArrow}>›</Text>
                  </View>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        )}

        <View style={styles.bottomActions}>
          <Button title="Concluir" loading={generating} onPress={handleConcluir} />
          <TouchableOpacity style={styles.ghostBtn} onPress={() => navigation.navigate('Onboarding3')}>
            <Text style={styles.ghostBtnText}>Responder depois</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </View>
  );
}

// ─── STYLES ───────────────────────────────────────────────────────────
const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  headerSection: {
    paddingHorizontal: 24,
    gap: 24,
  },
  titleRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 24,
  },
  iconBtn: {
    width: 24,
    height: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  chevron: {
    fontSize: 28,
    color: '#000000',
    lineHeight: 30,
    marginTop: -2,
  },
  titleBlock: {
    gap: 8,
  },
  pageTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 24,
    lineHeight: 29,
    color: '#000000',
    fontWeight: '700',
  },
  pageDescription: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    lineHeight: 17,
    color: '#000000',
  },
  scrollContent: {
    paddingBottom: 40,
  },
  loadingContainer: {
    paddingTop: 64,
    alignItems: 'center',
  },
  cardsList: {
    paddingHorizontal: 24,
    paddingTop: 24,
    gap: 16,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 24,
    gap: 16,
    height: 124,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 12,
    elevation: 4,
  },
  circle: {
    width: 76,
    height: 76,
    borderRadius: 100,
  },
  cardRight: {
    flex: 1,
    justifyContent: 'center',
    gap: 12,
  },
  cardMeta: {
    gap: 8,
  },
  cardTitleGroup: {
    gap: 12,
  },
  cardTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 19,
    color: '#424242',
    fontWeight: '700',
  },
  cardCountGroup: {
    gap: 12,
  },
  cardCount: {
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    lineHeight: 15,
    color: '#424242',
  },
  responderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  responderText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 14,
    lineHeight: 17,
    color: '#3678FD',
    flex: 1,
  },
  responderArrow: {
    fontSize: 18,
    color: '#3678FD',
    lineHeight: 20,
  },
  bottomActions: {
    paddingHorizontal: 24,
    paddingTop: 24,
    alignItems: 'center',
    gap: 16,
  },
  ghostBtn: {
    alignItems: 'center',
    paddingVertical: 4,
  },
  ghostBtnText: {
    fontFamily: theme.fonts.medium,
    fontSize: 16,
    lineHeight: 19,
    color: '#727272',
    textAlign: 'center',
  },
});
