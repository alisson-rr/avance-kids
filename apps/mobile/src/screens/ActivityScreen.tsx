import React, { useCallback, useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  StatusBar,
  Image,
  ScrollView,
  Modal,
  TouchableWithoutFeedback,
  ActivityIndicator,
  Linking,
} from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { BottomTabBar } from '../components/BottomTabBar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
import {
  fetchPlan,
  startExerciseSession,
  registerAttempt,
} from '../services/activities';
import { errorMessage } from '../services/api';
import { showDialog, showError } from '../ui/dialog';
import { useProfileStore, selectActiveChild } from '../store/useProfileStore';
import type { AttemptResult, ExerciseSessionRow, PlanWithDetails } from '../types/db';

const RESULT_OPTIONS: { id: number; label: string; resultado: AttemptResult }[] = [
  { id: 1, label: 'Fez sem ajuda', resultado: 'sem_ajuda' },
  { id: 2, label: 'Fez com ajuda parcial', resultado: 'ajuda_parcial' },
  { id: 3, label: 'Fez com ajuda total', resultado: 'ajuda_total' },
];

// ─── COMPONENT ────────────────────────────────────────────────────────
export function ActivityScreen({ navigation, route }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);
  const activeChild = useProfileStore(selectActiveChild);

  const planId: string | undefined = route?.params?.planId;

  const [plan, setPlan] = useState<PlanWithDetails | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [session, setSession] = useState<ExerciseSessionRow | null>(null);
  const [starting, setStarting] = useState(false);
  const [registering, setRegistering] = useState(false);

  const [isBottomSheetVisible, setIsBottomSheetVisible] = useState(false);
  const [currentRepetition, setCurrentRepetition] = useState(1);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [isCompleted, setIsCompleted] = useState(false);

  const load = useCallback(async () => {
    if (!planId) {
      setLoadError('Atividade não encontrada.');
      return;
    }
    setLoadError(null);
    try {
      const data = await fetchPlan(planId);
      if (!data) {
        setLoadError('Atividade não encontrada.');
        return;
      }
      setPlan(data);
    } catch (err) {
      setLoadError(errorMessage(err));
    }
  }, [planId]);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load]),
  );

  const handleStart = async () => {
    if (!plan) return;
    setStarting(true);
    try {
      const { session: openSession } = await startExerciseSession(plan.id);
      setSession(openSession);
      setCurrentRepetition(Math.min(openSession.total_repetitions + 1, 10));
      setSelectedOption(null);
      setIsCompleted(false);
      setIsBottomSheetVisible(true);
    } catch (err) {
      showError('Não foi possível iniciar', errorMessage(err));
    } finally {
      setStarting(false);
    }
  };

  const handleRegister = async () => {
    if (selectedOption === null || !session || !plan || registering) return;
    const option = RESULT_OPTIONS.find((o) => o.id === selectedOption);
    if (!option) return;

    setRegistering(true);
    try {
      const result = await registerAttempt({
        session_id: session.id,
        plan_id: plan.id,
        repeticao_numero: currentRepetition,
        resultado: option.resultado,
      });

      setSelectedOption(null);

      if (result.exercise_completed) {
        setIsCompleted(true);
      } else if (result.remaining <= 0) {
        // 10 repetições sem atingir 8 acertos sem ajuda: recomeça do zero
        setIsBottomSheetVisible(false);
        setSession(null);
        const acertos = result.successful_count;
        showDialog({
          title: 'Quase lá!',
          message: `Foram ${acertos} de 10 repetições sem ajuda — o exercício avança com 8 ou mais. Tudo bem, a prática leva à conquista: vamos recomeçar do zero!`,
          variant: 'info',
          buttons: [
            { label: 'Recomeçar agora', kind: 'primary', onPress: () => handleStart() },
            { label: 'Voltar ao plano', kind: 'ghost', onPress: () => navigation.navigate('ActivityPlan') },
          ],
        });
      } else {
        setCurrentRepetition(result.total_repetitions + 1);
      }
    } catch (err) {
      showError('Erro ao registrar', errorMessage(err));
    } finally {
      setRegistering(false);
    }
  };

  const handleSkipOrNext = () => {
    setIsBottomSheetVisible(false);
    navigation.navigate('ActivityPlan');
  };

  const handleInfo = () => {
    if (!plan) return;
    const e = plan.exercises;
    const sections = [
      ['Materiais', e.materiais],
      ['Frequência', e.frequencia],
      ['Hierarquia de dicas', e.hierarquia_dicas],
      ['Resposta esperada', e.resposta_esperada],
      ['Critério de avanço', e.criterio_avanco],
      ['Reforços', e.reforcos],
    ].filter(([, value]) => value);
    showDialog({
      title: e.titulo,
      message:
        sections.length > 0
          ? sections.map(([label, value]) => `${label}:\n${value}`).join('\n\n')
          : 'Sem informações adicionais.',
      variant: 'info',
      buttons: [{ label: 'Entendi', kind: 'primary' }],
    });
  };

  const handlePlayVideo = () => {
    const url = plan?.exercises.media_url;
    if (url) {
      Linking.openURL(url).catch(() => showError('Erro', 'Não foi possível abrir o vídeo.'));
    }
  };

  if (loadError) {
    return (
      <View style={[styles.screen, styles.stateContainer, { paddingTop: safeTop }]}>
        <Text style={styles.stateText}>{loadError}</Text>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.stateLink}>Voltar</Text>
        </TouchableOpacity>
      </View>
    );
  }

  if (!plan) {
    return (
      <View style={[styles.screen, styles.stateContainer, { paddingTop: safeTop }]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  const exercise = plan.exercises;
  const isVideo = exercise.media_type === 'video' && !!exercise.media_url;
  const description = [exercise.objetivo, exercise.procedimento].filter(Boolean).join('\n\n');

  return (
    <View style={[styles.screen, { paddingTop: safeTop }]}>
      <StatusBar barStyle="dark-content" backgroundColor="#FFFFFF" />

      {/* ── HEADER: < ... (i) ── */}
      <View style={styles.headerRow}>
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={styles.headerIconBtn}
          hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
        >
          <Ionicons name="chevron-back" size={24} color="#0E5DFD" />
        </TouchableOpacity>

        {/* Spacer */}
        <View style={{ flex: 1 }} />

        <TouchableOpacity style={styles.headerIconBtn} onPress={handleInfo}>
          <View style={styles.infoCircle}>
            <Text style={styles.infoText}>i</Text>
          </View>
        </TouchableOpacity>
      </View>

      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: 120 }}>
        {/* ── SKILL NAME (big bold) ── */}
        <Text style={styles.skillName}>{plan.skills.nome}</Text>

        {/* ── ACTIVITY NAME (smaller, gray) ── */}
        <Text style={styles.activityName}>{exercise.titulo}</Text>

        {/* ── IMAGE / VIDEO AREA ── */}
        <View style={styles.mediaContainer}>
          {exercise.media_url && !isVideo ? (
            <Image
              source={{ uri: exercise.media_url }}
              style={styles.mediaImage}
              resizeMode="cover"
            />
          ) : (
            <Image
              source={require('../../assets/onboarding3.png')}
              style={styles.mediaImage}
              resizeMode="cover"
            />
          )}
          {isVideo && (
            <TouchableOpacity style={styles.playOverlay} onPress={handlePlayVideo} activeOpacity={0.8}>
              <View style={styles.playButton}>
                <Ionicons name="play" size={32} color="#FFFFFF" style={{ marginLeft: 3 }} />
              </View>
            </TouchableOpacity>
          )}
        </View>

        {/* ── DESCRIPTION TEXT ── */}
        <Text style={styles.descriptionText}>
          {description || 'Siga as orientações do programa para aplicar esta atividade.'}
        </Text>
      </ScrollView>

      {/* ── FIXED COMEÇAR BUTTON ── */}
      <View style={[styles.fixedFooter, { paddingBottom: Math.max(insets.bottom, 16) }]}>
        <TouchableOpacity
          style={[styles.primaryButton, starting && { opacity: 0.6 }]}
          activeOpacity={0.8}
          onPress={handleStart}
          disabled={starting}
        >
          {starting ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.primaryButtonText}>Começar</Text>
          )}
        </TouchableOpacity>
      </View>

      {/* ── BOTTOM TAB BAR ── */}
      <BottomTabBar activeScreen="ActivityPlan" />

      {/* ── BOTTOM SHEET MODAL ── */}
      <Modal
        visible={isBottomSheetVisible}
        transparent
        animationType="slide"
        onRequestClose={() => setIsBottomSheetVisible(false)}
      >
        <TouchableOpacity
          style={styles.modalOverlay}
          activeOpacity={1}
          onPress={() => setIsBottomSheetVisible(false)}
        >
          <TouchableWithoutFeedback>
            <View style={styles.bottomSheet}>
              {/* Drag Handle */}
              <View style={styles.dragHandle} />

            {isCompleted ? (
              // COMPLETED STATE
              <View style={styles.sheetContent}>
                <View style={styles.completionImageContainer}>
                  <Image
                    source={require('../../assets/perguntas.png')}
                    style={styles.completionImage}
                    resizeMode="contain"
                  />
                </View>
                <Text style={styles.completionText}>
                  {activeChild?.name ?? 'Sua criança'}{' '}
                  <Text style={{ fontFamily: theme.fonts.mulishBold, fontWeight: '700' }}>concluiu as tentativas</Text> deste exercício e uma nova atividade foi liberada!
                </Text>
                <TouchableOpacity style={styles.primaryButton} onPress={handleSkipOrNext}>
                  <Text style={styles.primaryButtonText}>Próxima atividade</Text>
                </TouchableOpacity>
              </View>
            ) : (
              // REPETITION STATE
              <View style={styles.sheetContent}>
                <Text style={styles.sheetTitle}>
                  Aplique a atividade 10 vezes seguidas, mesmo que conclua sem ajuda
                </Text>

                {/* Progress Text */}
                <Text style={styles.progressText}>{currentRepetition}/10 repetições</Text>

                {/* Progress Bar Row */}
                <View style={styles.progressBarsRow}>
                  {[...Array(10)].map((_, index) => (
                    <View
                      key={index}
                      style={[
                        styles.progressBarSegment,
                        index < currentRepetition ? styles.progressBarActive : styles.progressBarInactive
                      ]}
                    />
                  ))}
                </View>

                <Text style={styles.questionText}>Como a criança se saiu nessa repetição?</Text>

                {/* Radio Options */}
                {RESULT_OPTIONS.map((option) => (
                  <TouchableOpacity
                    key={option.id}
                    style={styles.radioRow}
                    activeOpacity={0.7}
                    onPress={() => setSelectedOption(option.id)}
                  >
                    <View style={styles.radioOuter}>
                      {selectedOption === option.id && <View style={styles.radioInner} />}
                    </View>
                    <Text style={styles.radioLabel}>{option.label}</Text>
                  </TouchableOpacity>
                ))}

                {/* Action Buttons */}
                <View style={styles.sheetButtonsContainer}>
                  <TouchableOpacity
                    style={[styles.primaryButton, (selectedOption === null || registering) && { opacity: 0.5 }]}
                    onPress={handleRegister}
                    disabled={selectedOption === null || registering}
                  >
                    {registering ? (
                      <ActivityIndicator color="#FFFFFF" />
                    ) : (
                      <Text style={styles.primaryButtonText}>Registrar atividade</Text>
                    )}
                  </TouchableOpacity>

                  <TouchableOpacity style={styles.secondaryButton} onPress={handleSkipOrNext}>
                    <Text style={styles.secondaryButtonText}>Pular atividade</Text>
                  </TouchableOpacity>
                </View>
              </View>
            )}
          </View>
          </TouchableWithoutFeedback>
        </TouchableOpacity>
      </Modal>
    </View>
  );
}

// ─── STYLES ───────────────────────────────────────────────────────────
const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },

  stateContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
    gap: 16,
  },
  stateText: {
    fontFamily: theme.fonts.regular,
    fontSize: 16,
    color: '#424242',
    textAlign: 'center',
  },
  stateLink: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#0E5DFD',
  },

  // ── Header ──────────────────────────────────────────────────────
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 24,
    height: 44,
  },
  headerIconBtn: {
    width: 24,
    height: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  infoCircle: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 1.5,
    borderColor: '#0E5DFD',
    alignItems: 'center',
    justifyContent: 'center',
  },
  infoText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 12,
    color: '#0E5DFD',
    lineHeight: 14,
  },

  // ── Skill name (large bold) ──────────────────────────────────────
  skillName: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 24,
    lineHeight: 29,
    color: '#000000',
    fontWeight: '700',
    paddingHorizontal: 24,
    marginTop: 16,
  },

  // ── Activity name (smaller, gray) ────────────────────────────────
  activityName: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    lineHeight: 17,
    color: '#5E5E5E',
    paddingHorizontal: 24,
    marginTop: 4,
    marginBottom: 20,
  },

  // ── Media (image/video) ──────────────────────────────────────────
  mediaContainer: {
    marginHorizontal: 24,
    borderRadius: 12,
    overflow: 'hidden',
    height: 340,
    backgroundColor: '#D9D9D9',
  },
  mediaImage: {
    width: '100%',
    height: '100%',
  },
  playOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  playButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    justifyContent: 'center',
    alignItems: 'center',
  },

  // ── Description Text ──────────────────────────────────────────
  descriptionText: {
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    lineHeight: 22,
    color: '#3B3B3B',
    paddingHorizontal: 24,
    marginTop: 24,
  },

  // ── Fixed Footer (Começar button) ───────────────────────────────
  fixedFooter: {
    position: 'absolute',
    bottom: 85, // above bottomTabBar
    left: 0,
    right: 0,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    paddingHorizontal: 24,
    paddingTop: 24,
    zIndex: 40,
  },
  primaryButton: {
    width: '100%',
    height: 52,
    backgroundColor: '#0E5DFD',
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
  primaryButtonText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#FFFFFF',
    fontWeight: '600',
  },

  // ── Bottom Sheet ────────────────────────────────────────────────
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    justifyContent: 'flex-end',
  },
  bottomSheet: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    paddingHorizontal: 24,
    paddingTop: 12,
    paddingBottom: 32, // to ensure space at bottom
  },
  dragHandle: {
    width: 48,
    height: 4,
    backgroundColor: '#D1D1D6',
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 24,
  },
  sheetContent: {
    gap: 16,
  },
  sheetTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 18,
    lineHeight: 24,
    color: '#3B3B3B',
    marginBottom: 8,
  },
  progressText: {
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    color: '#5E5E5E',
    textAlign: 'right',
    marginBottom: -8,
  },
  progressBarsRow: {
    flexDirection: 'row',
    gap: 4,
    marginBottom: 16,
  },
  progressBarSegment: {
    flex: 1,
    height: 4,
    borderRadius: 2,
  },
  progressBarActive: {
    backgroundColor: '#79A5FF',
  },
  progressBarInactive: {
    backgroundColor: '#D6E4FF',
  },
  questionText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#3B3B3B',
    marginBottom: 8,
  },
  radioRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  radioOuter: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 1.5,
    borderColor: '#C9C9C9',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  radioInner: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: '#0E5DFD',
  },
  radioLabel: {
    fontFamily: theme.fonts.regular,
    fontSize: 16,
    color: '#5E5E5E',
  },
  sheetButtonsContainer: {
    gap: 16,
    marginTop: 16,
  },
  secondaryButton: {
    width: '100%',
    height: 48,
    backgroundColor: '#FFFFFF',
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1.5,
    borderColor: '#0E5DFD',
  },
  secondaryButtonText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#0E5DFD',
    fontWeight: '600',
  },
  completionText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 22,
    color: '#3B3B3B',
    textAlign: 'center',
    marginBottom: 24,
  },
  completionImageContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 160,
    marginBottom: 16,
  },
  completionImage: {
    width: '100%',
    height: '100%',
  },
});
