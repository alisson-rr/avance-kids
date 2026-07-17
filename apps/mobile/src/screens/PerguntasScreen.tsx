import React, { useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Image,
  SafeAreaView,
  TouchableOpacity,
  ScrollView,
  StatusBar,
  Platform,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';

// ─── MOCK DATA ────────────────────────────────────────────────────────
const QUESTIONS = [
  {
    id: 1,
    question: 'Seu filho(a) olha quando você o chama pelo nome?',
    options: [
      'Quase nunca faz, mesmo com ajuda',
      'Faz às vezes ou com ajuda',
      'Faz quase sempre, com autonomia',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 2,
    question: 'Seu filho(a) aponta para objetos que deseja?',
    options: [
      'Ainda não faz esse gesto',
      'Faz com ajuda ou raramente',
      'Faz com frequência e autonomia',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 3,
    question: 'Seu filho(a) consegue brincar junto com outras crianças?',
    options: [
      'Prefere brincar sozinho(a)',
      'Às vezes interage, com incentivo',
      'Brinca bem com outras crianças',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 4,
    question: 'Seu filho(a) imita gestos ou expressões de outras pessoas?',
    options: [
      'Raramente ou nunca imita',
      'Imita com ajuda ou às vezes',
      'Imita com facilidade e espontaneidade',
      'Não observei essa situação ainda',
    ],
  },
];

// ─── COMPONENT ────────────────────────────────────────────────────────
export function PerguntasScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [answers, setAnswers] = useState<Record<number, number>>({});

  const q = QUESTIONS[currentQuestion];
  const total = QUESTIONS.length;

  const handleOptionSelect = (index: number) => {
    setSelectedOption(index);
  };

  const handleNext = () => {
    if (selectedOption === null) return;
    const newAnswers = { ...answers, [currentQuestion]: selectedOption };
    setAnswers(newAnswers);

    if (currentQuestion < total - 1) {
      setCurrentQuestion(currentQuestion + 1);
      setSelectedOption(null);
    } else {
      navigation.navigate('Onboarding2');
    }
  };

  const handlePrev = () => {
    if (currentQuestion > 0) {
      setCurrentQuestion(currentQuestion - 1);
      setSelectedOption(answers[currentQuestion - 1] ?? null);
    } else {
      navigation.goBack();
    }
  };

  // ─── Progress bar segments ──────────────────────────────────────
  const renderProgressBar = () => {
    const segments = [];
    for (let i = 0; i < total; i++) {
      const isActive = i <= currentQuestion;
      const isFirst = i === 0;
      const isLast = i === total - 1;
      segments.push(
        <View
          key={i}
          style={[
            styles.progressSegment,
            isActive ? styles.progressActive : styles.progressInactive,
            isFirst && styles.progressFirst,
            isLast && styles.progressLast,
          ]}
        />
      );
    }
    return segments;
  };

  return (
    <View style={styles.screen}>
      <StatusBar barStyle="light-content" backgroundColor="#3678FD" />

      {/* ── BLUE HEADER BAND ── */}
      <View style={[styles.blueHeader, { paddingTop: safeTop }]}>
        <View style={styles.titleRow}>
          <TouchableOpacity
            onPress={handlePrev}
            style={styles.headerIconBtn}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Text style={styles.headerChevron}>‹</Text>
          </TouchableOpacity>

          <Text style={styles.headerTitle}>Perguntas iniciais</Text>

          {/* Espaçador invisível para manter o título centralizado */}
          <View style={styles.headerIconBtn} />
        </View>
      </View>

      {/* ── CARD (overlaps the blue band) ── */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        bounces={false}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.card}>
          {/* Image area */}
          <View style={styles.cardImageSection}>
            <Image
              source={require('../../assets/perguntas.png')}
              style={styles.cardImage}
              resizeMode="contain"
            />
          </View>

          {/* White content area */}
          <View style={styles.cardContent}>
            {/* Progress */}
            <View style={styles.progressBlock}>
              <Text style={styles.progressLabel}>
                {currentQuestion + 1}/{total}
              </Text>
              <View style={styles.progressTrack}>{renderProgressBar()}</View>
            </View>

            {/* Question & options */}
            <View style={styles.questionBlock}>
              <Text style={styles.questionText}>{q.question}</Text>

              <View style={styles.optionsList}>
                {q.options.map((opt, i) => {
                  const isSelected = selectedOption === i;
                  const isLast = i === q.options.length - 1;
                  return (
                    <View key={i}>
                      <TouchableOpacity
                        style={styles.optionRow}
                        activeOpacity={0.65}
                        onPress={() => handleOptionSelect(i)}
                      >
                        <View
                          style={[
                            styles.radio,
                            isSelected && styles.radioSelected,
                          ]}
                        >
                          {isSelected && <View style={styles.radioDot} />}
                        </View>
                        <Text style={styles.optionText}>{opt}</Text>
                      </TouchableOpacity>
                      {!isLast && <View style={styles.optionDivider} />}
                    </View>
                  );
                })}
              </View>
            </View>

            {/* Nav buttons */}
            <View style={styles.navRow}>
              <TouchableOpacity
                onPress={handlePrev}
                style={styles.navBtn}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
              >
                <Text style={styles.navChevronLeft}>‹</Text>
                <Text style={styles.navLabel}>anterior</Text>
              </TouchableOpacity>

              <TouchableOpacity
                onPress={handleNext}
                style={[
                  styles.navBtn,
                  selectedOption === null && styles.navBtnDisabled,
                ]}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                disabled={selectedOption === null}
              >
                <Text style={styles.navLabel}>
                  {currentQuestion < total - 1 ? 'próxima' : 'finalizar'}
                </Text>
                <Text style={styles.navChevronRight}>›</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}

// ─── STYLES (Figma-faithful) ──────────────────────────────────────────
const CARD_SIDE_MARGIN = 24; // (393 - 345) / 2 = 24

const styles = StyleSheet.create({
  // ── Screen ──────────────────────────────────────────────────────────
  screen: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },

  // ── Blue header band ─────────────────────────────────────────────
  // Figma: #3678FD, 198px tall, bottom radius 30px
  blueHeader: {
    backgroundColor: '#3678FD',
    paddingBottom: 80, // extra space for the card overlap
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
  },
  titleRow: {
    // Figma: row, space-between, padding 0 24px, height ~55px
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
    // Figma: border 1.5px solid #FFFFFF — we render as text
    fontSize: 28,
    color: '#FFFFFF',
    lineHeight: 30,
    marginTop: -2,
  },
  headerTitle: {
    // Figma: Inter 600, 16px, line-height 20px, letter-spacing 2%, center, #FFFFFF
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    letterSpacing: 0.32, // 16 * 0.02
    textAlign: 'center',
    color: '#FFFFFF',
  },
  headerInfo: {
    // Figma: info icon, border 1.5px solid #FAFAFA
    fontSize: 20,
    color: '#FAFAFA',
  },

  // ── ScrollView ──────────────────────────────────────────────────
  scrollView: {
    flex: 1,
    marginTop: -60, // overlap the card onto the blue header
  },
  scrollContent: {
    paddingBottom: 40,
  },

  // ── Card ────────────────────────────────────────────────────────
  // Figma: 345px wide, centered, border-radius 12px
  card: {
    marginHorizontal: CARD_SIDE_MARGIN,
    borderRadius: 12,
    overflow: 'hidden',
  },

  // ── Card — image section ────────────────────────────────────────
  // Figma: #EEF4FF, height 252px, padding 24px 0, border-radius 12 12 0 0
  cardImageSection: {
    backgroundColor: '#EEF4FF',
    height: 252,
    paddingVertical: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cardImage: {
    // Figma: 345×190
    width: '100%',
    height: 190,
  },

  // ── Card — white content ────────────────────────────────────────
  // Figma: bg #FFF, border 2px solid #EEF4FF (left/right/bottom), padding 16px 24px 24px, gap 32px
  cardContent: {
    backgroundColor: '#FFFFFF',
    borderLeftWidth: 2,
    borderRightWidth: 2,
    borderBottomWidth: 2,
    borderColor: '#EEF4FF',
    borderBottomLeftRadius: 12,
    borderBottomRightRadius: 12,
    paddingTop: 16,
    paddingHorizontal: 24,
    paddingBottom: 24,
    gap: 32,
  },

  // ── Progress ────────────────────────────────────────────────────
  // Figma: Frame 427319708 — gap 4px
  progressBlock: {
    gap: 4,
  },
  progressLabel: {
    // Figma: Inter 400, 12px, line-height 15px, text-align right, #424242
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    lineHeight: 15,
    textAlign: 'right',
    color: '#424242',
  },
  progressTrack: {
    // Figma: row, gap 2px, height 4px
    flexDirection: 'row',
    gap: 2,
    height: 4,
  },
  progressSegment: {
    flex: 1,
    height: 4,
  },
  progressActive: {
    // Figma: rgba(54, 120, 253, 0.6)
    backgroundColor: 'rgba(54, 120, 253, 0.6)',
  },
  progressInactive: {
    // Figma: rgba(54, 120, 253, 0.2)
    backgroundColor: 'rgba(54, 120, 253, 0.2)',
  },
  progressFirst: {
    // Figma: border-radius 4px 0 0 4px
    borderTopLeftRadius: 4,
    borderBottomLeftRadius: 4,
  },
  progressLast: {
    // Figma: border-radius 0 4px 4px 0
    borderTopRightRadius: 4,
    borderBottomRightRadius: 4,
  },

  // ── Question ────────────────────────────────────────────────────
  // Figma: Frame 427319664 — gap 24px, border-radius 12px
  questionBlock: {
    gap: 24,
  },
  questionText: {
    // Figma: Inter 600, 16px, line-height 20px, #000000
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    color: '#000000',
  },

  // ── Options ─────────────────────────────────────────────────────
  // Figma: Frame 427319663 — gap 20px (between option rows + dividers)
  optionsList: {
    gap: 20,
  },
  optionRow: {
    // Figma: row, gap 12px, height 20px
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  radio: {
    // Figma: 20×20, border 1px solid #C9C9C9
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#C9C9C9',
    alignItems: 'center',
    justifyContent: 'center',
  },
  radioSelected: {
    borderColor: '#3678FD',
    borderWidth: 2,
  },
  radioDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: '#3678FD',
  },
  optionText: {
    // Figma: Inter 500, 14px, line-height 17px, #000000
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    lineHeight: 17,
    color: '#000000',
    flex: 1,
  },
  optionDivider: {
    // Figma: border 1px solid #F0F0F0
    height: 1,
    backgroundColor: '#F0F0F0',
    marginTop: 20,
  },

  // ── Navigation buttons ──────────────────────────────────────────
  // Figma: Frame 427319707 — row, space-between, 297×40
  navRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  navBtn: {
    // Figma: row, gap 8px, padding 8px 0
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingVertical: 8,
  },
  navBtnDisabled: {
    opacity: 0.35,
  },
  navLabel: {
    // Figma: Inter 500, 14px, line-height 24px, #02349A
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    lineHeight: 24,
    color: '#02349A',
  },
  navChevronLeft: {
    // Figma: arrow rotated, #02349C
    fontSize: 22,
    color: '#02349C',
    lineHeight: 24,
  },
  navChevronRight: {
    // Figma: arrow, #02349C
    fontSize: 22,
    color: '#02349C',
    lineHeight: 24,
  },
});
