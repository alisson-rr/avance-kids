import React, { useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Image,
  TouchableOpacity,
  ScrollView,
  StatusBar,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';
import { HabilidadeKey, HABILIDADE_STYLES } from '../data/habilidades';

interface TriagemBaseScreenProps {
  habilidade: HabilidadeKey;
  habilidadeTitle: string;
  perguntaAtual: number;
  totalPerguntas: number;
  perguntaTexto: string;
  opcoes: string[];
  onNext: (respostaIndex: number) => void;
  onBack: () => void;
}

export function TriagemBaseScreen({
  habilidade,
  habilidadeTitle,
  perguntaAtual,
  totalPerguntas,
  perguntaTexto,
  opcoes,
  onNext,
  onBack,
}: TriagemBaseScreenProps) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);
  const stylesConfig = HABILIDADE_STYLES[habilidade];

  const [selectedOption, setSelectedOption] = useState<number | null>(null);

  const handleNext = () => {
    if (selectedOption !== null) {
      onNext(selectedOption);
      setSelectedOption(null); // Reseta
    }
  };

  const handleOptionSelect = (index: number) => {
    setSelectedOption(index);
  };

  // ─── Progress bar segments ──────────────────────────────────────
  const renderProgressBar = () => {
    const segments = [];
    for (let i = 0; i < totalPerguntas; i++) {
      const isActive = i <= perguntaAtual;
      const isFirst = i === 0;
      const isLast = i === totalPerguntas - 1;
      segments.push(
        <View
          key={i}
          style={[
            styles.progressSegment,
            isActive
              ? { backgroundColor: stylesConfig.textColor, opacity: 0.6 } // Active com a cor da habilidade
              : styles.progressInactive,
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
      <StatusBar barStyle="dark-content" backgroundColor={stylesConfig.background} />

      {/* ── DYNAMIC HEADER BAND ── */}
      <View style={[styles.blueHeader, { paddingTop: safeTop, backgroundColor: stylesConfig.background }]}>
        <View style={styles.titleRow}>
          <TouchableOpacity
            onPress={onBack}
            style={styles.headerIconBtn}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Text style={styles.headerChevron}>‹</Text>
          </TouchableOpacity>

          <Text style={styles.headerTitle}>{habilidadeTitle}</Text>

          <TouchableOpacity
            style={styles.headerIconBtn}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
            disabled
          >
            <View />
          </TouchableOpacity>
        </View>
      </View>

      {/* ── CARD (overlaps the header) ── */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        bounces={false}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.card}>
          {/* Image area */}
          <View style={[styles.cardImageSection, { backgroundColor: stylesConfig.tagBackground }]}>
            <Image
              source={stylesConfig.image}
              style={styles.heroImage}
              resizeMode="contain"
            />
          </View>

          {/* White content area */}
          <View style={styles.cardContent}>
            
            {/* Tag Habilidade */}
            <View style={[styles.tagBadge, { backgroundColor: stylesConfig.tagBackground }]}>
              <Text style={[styles.tagText, { color: stylesConfig.textColor }]}>{habilidadeTitle}</Text>
            </View>

            {/* Progress */}
            <View style={styles.progressBlock}>
              <Text style={styles.progressLabel}>
                {perguntaAtual + 1}/{totalPerguntas}
              </Text>
              <View style={styles.progressTrack}>{renderProgressBar()}</View>
            </View>

            {/* Question & options */}
            <View style={styles.questionBlock}>
              <Text style={styles.questionText}>{perguntaTexto}</Text>

              <View style={styles.optionsList}>
                {opcoes.map((opt, i) => {
                  const isSelected = selectedOption === i;
                  const isLast = i === opcoes.length - 1;
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
                onPress={onBack}
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
                  {perguntaAtual < totalPerguntas - 1 ? 'próxima' : 'finalizar'}
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
const CARD_SIDE_MARGIN = 24; 

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  blueHeader: {
    paddingBottom: 80, 
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
  },
  titleRow: {
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
    fontSize: 28,
    color: '#FFFFFF',
    lineHeight: 30,
    marginTop: -2,
  },
  headerInfo: {
    fontSize: 20,
    color: '#FFFFFF',
  },
  headerTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    letterSpacing: 0.32, 
    textAlign: 'center',
    color: '#FFFFFF', // Title in white
  },
  scrollView: {
    flex: 1,
    marginTop: -60, // overlap the card onto the header
  },
  scrollContent: {
    paddingBottom: 40,
  },
  card: {
    marginHorizontal: CARD_SIDE_MARGIN,
    borderRadius: 12,
    overflow: 'hidden',
  },
  cardImageSection: {
    height: 252,
    paddingVertical: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroImage: {
    width: '100%',
    height: 190,
  },
  cardContent: {
    backgroundColor: '#FFFFFF',
    borderLeftWidth: 2,
    borderRightWidth: 2,
    borderBottomWidth: 2,
    borderColor: '#EEF4FF', // Assuming this remains the same or changes per habilidade, using a neutral or specific one
    borderBottomLeftRadius: 12,
    borderBottomRightRadius: 12,
    paddingTop: 16,
    paddingHorizontal: 24,
    paddingBottom: 24,
    gap: 32,
  },
  tagBadge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
  },
  tagText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 12,
  },
  progressBlock: {
    gap: 4,
  },
  progressLabel: {
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    lineHeight: 15,
    textAlign: 'right',
    color: '#424242',
  },
  progressTrack: {
    flexDirection: 'row',
    gap: 2,
    height: 4,
  },
  progressSegment: {
    flex: 1,
    height: 4,
  },
  progressInactive: {
    backgroundColor: '#F0F0F0',
  },
  progressFirst: {
    borderTopLeftRadius: 4,
    borderBottomLeftRadius: 4,
  },
  progressLast: {
    borderTopRightRadius: 4,
    borderBottomRightRadius: 4,
  },
  questionBlock: {
    gap: 24,
  },
  questionText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    color: '#000000',
  },
  optionsList: {
    gap: 20,
  },
  optionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  radio: {
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
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    lineHeight: 17,
    color: '#000000',
    flex: 1,
    marginTop: 3, // Small adjustment for better centering with custom radio if needed
  },
  optionDivider: {
    height: 1,
    backgroundColor: '#F0F0F0',
    marginTop: 20,
  },
  navRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  navBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingVertical: 8,
  },
  navBtnDisabled: {
    opacity: 0.35,
  },
  navLabel: {
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    lineHeight: 24,
    color: '#02349A',
  },
  navChevronLeft: {
    fontSize: 22,
    color: '#02349C',
    lineHeight: 24,
  },
  navChevronRight: {
    fontSize: 22,
    color: '#02349C',
    lineHeight: 24,
  },
});
