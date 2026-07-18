import React, { useState } from 'react';
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
} from 'react-native';
import { BottomTabBar } from '../components/BottomTabBar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';

// ─── MOCK DATA ────────────────────────────────────────────────────────


const MOCK_ACTIVITIES: Record<number, {
  skill: string;
  title: string;
  description: string;
}> = {
  1: { skill: 'Comunicação', title: 'Olhar quando chama pelo nome', description: 'Esta atividade tem como objetivo ajudar a criança a reconhecer e responder ao próprio nome. Mantenha contato visual e chame a criança com um tom de voz alegre.' },
  2: { skill: 'Coordenação motora', title: 'Empilhando blocos coloridos', description: 'Incentive a criança a empilhar blocos para desenvolver a coordenação motora fina e noção de equilíbrio.' },
  3: { skill: 'Funcional', title: 'Brincando de esconder', description: 'Use um pano para esconder o rosto e brincar de "Achou!" para estimular a interação social e a permanência do objeto.' },
  4: { skill: 'Cognitiva', title: 'Identificando cores', description: 'Mostre objetos coloridos e peça para a criança identificar as cores de forma lúdica e divertida.' },
};

// ─── COMPONENT ────────────────────────────────────────────────────────
export function ActivityScreen({ navigation, route }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  const activityId = route?.params?.activityId || 1;
  const activity = MOCK_ACTIVITIES[activityId] || MOCK_ACTIVITIES[1];

  const [isBottomSheetVisible, setIsBottomSheetVisible] = useState(false);
  const [currentRepetition, setCurrentRepetition] = useState(1);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [isCompleted, setIsCompleted] = useState(false);

  const handleStart = () => {
    setIsBottomSheetVisible(true);
  };

  const handleRegister = () => {
    if (selectedOption === null) return;
    if (currentRepetition < 10) {
      setCurrentRepetition((prev) => prev + 1);
      setSelectedOption(null);
    } else {
      setIsCompleted(true);
    }
  };

  const handleSkipOrNext = () => {
    setIsBottomSheetVisible(false);
    navigation.navigate('ActivityPlan');
  };

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

        <TouchableOpacity style={styles.headerIconBtn}>
          <View style={styles.infoCircle}>
            <Text style={styles.infoText}>i</Text>
          </View>
        </TouchableOpacity>
      </View>

      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingBottom: 120 }}>
        {/* ── SKILL NAME (big bold) ── */}
        <Text style={styles.skillName}>{activity.skill}</Text>

        {/* ── ACTIVITY NAME (smaller, gray) ── */}
        <Text style={styles.activityName}>{activity.title}</Text>

        {/* ── IMAGE / VIDEO AREA ── */}
        <View style={styles.mediaContainer}>
          <Image
            source={require('../../assets/onboarding3.png')}
            style={styles.mediaImage}
            resizeMode="cover"
          />
          {/* Play button overlay */}
          <View style={styles.playOverlay}>
            <View style={styles.playButton}>
              <Ionicons name="play" size={32} color="#FFFFFF" style={{ marginLeft: 3 }} />
            </View>
          </View>
        </View>

        {/* ── DESCRIPTION TEXT ── */}
        <Text style={styles.descriptionText}>{activity.description}</Text>
      </ScrollView>

      {/* ── FIXED COMEÇAR BUTTON ── */}
      <View style={[styles.fixedFooter, { paddingBottom: Math.max(insets.bottom, 16) }]}>
        <TouchableOpacity style={styles.primaryButton} activeOpacity={0.8} onPress={handleStart}>
          <Text style={styles.primaryButtonText}>Começar</Text>
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
                  Pedro <Text style={{ fontFamily: theme.fonts.mulishBold, fontWeight: '700' }}>concluiu as tentativas</Text> deste exercício e uma nova atividade foi liberada!
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
                {[
                  { id: 1, label: 'Fez sem ajuda' },
                  { id: 2, label: 'Fez com ajuda parcial' },
                  { id: 3, label: 'Fez com ajuda total' }
                ].map((option) => (
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
                    style={[styles.primaryButton, selectedOption === null && { opacity: 0.5 }]}
                    onPress={handleRegister}
                    disabled={selectedOption === null}
                  >
                    <Text style={styles.primaryButtonText}>Registrar atividade</Text>
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
