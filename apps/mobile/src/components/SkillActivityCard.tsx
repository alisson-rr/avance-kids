import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { theme } from '../theme';
import { getSkillColor } from '../data/habilidades';

/** Cinza do card bloqueado: #AAAAAA dava 2.3:1 sobre branco (ilegivel). */
const LOCKED_TEXT = '#6B6B6B';

interface SkillActivityCardProps {
  skill: string;
  title: string;
  description: string;
  onPress?: () => void;
  /** 0–100; quando definido, renderiza barra + label de progresso. */
  progress?: number;
  /** Sufixo do label de progresso (ex.: '% de acerto'). Padrão: '%'. */
  progressSuffix?: string;
  /** Progresso compacto (barra estreita, texto menor) — usado no histórico. */
  compactProgress?: boolean;
  /** Card bloqueado: tudo cinza, cadeado no lugar da seta, sem progresso. */
  locked?: boolean;
}

export function SkillActivityCard({
  skill,
  title,
  description,
  onPress,
  progress,
  progressSuffix = '%',
  compactProgress = false,
  locked = false,
}: SkillActivityCardProps) {
  if (locked) {
    // Sem onPress continua sendo um card inerte (atividade ainda não liberada
    // pela progressão); com onPress vira o atalho para a tela de planos.
    return (
      <TouchableOpacity
        style={styles.card}
        activeOpacity={0.7}
        onPress={onPress}
        disabled={!onPress}
        accessibilityRole={onPress ? 'button' : undefined}
        accessibilityLabel={`${title}. ${description}`}
        accessibilityState={{ disabled: !onPress }}
      >
        <View style={[styles.tagBadge, { backgroundColor: '#F1F1F1', alignSelf: 'flex-start' }]}>
          <Text style={[styles.tagText, { color: LOCKED_TEXT }]} numberOfLines={1}>{skill}</Text>
        </View>
        <View style={styles.lockedRow}>
          <View style={styles.cardTextArea}>
            <Text style={[styles.cardTitle, { color: LOCKED_TEXT }]}>{title}</Text>
            <Text style={[styles.cardDescription, { color: LOCKED_TEXT }]} numberOfLines={2}>{description}</Text>
          </View>
          <Text style={styles.lockIcon}>🔒</Text>
        </View>
      </TouchableOpacity>
    );
  }

  const color = getSkillColor(skill);

  return (
    <TouchableOpacity style={styles.card} activeOpacity={0.7} onPress={onPress}>
      {/* Top row: tag + progress */}
      <View style={styles.cardTopRow}>
        <View style={[styles.tagBadge, { backgroundColor: color.bg }]}>
          <Text style={[styles.tagText, { color: color.text }]} numberOfLines={1}>{skill}</Text>
        </View>
        {progress !== undefined && (
          <View style={[styles.progressRow, compactProgress && styles.progressRowCompact]}>
            <View style={[styles.progressTrack, compactProgress && styles.progressTrackCompact]}>
              <View style={[styles.progressFill, { width: `${progress}%` }]} />
            </View>
            <Text style={[styles.progressText, compactProgress && styles.progressTextCompact]}>
              {progress}{progressSuffix}
            </Text>
          </View>
        )}
      </View>

      {/* Bottom row: text content + arrow */}
      <View style={styles.cardBottomRow}>
        <View style={styles.cardTextArea}>
          <Text style={styles.cardTitle}>{title}</Text>
          <Text style={styles.cardDescription} numberOfLines={2}>{description}</Text>
        </View>
        <View style={styles.arrowContainer}>
          <Text style={styles.arrowIcon}>›</Text>
        </View>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
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
    flexShrink: 1,
  },
  tagText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 12,
    lineHeight: 20,
  },
  progressRow: {
    // Sem flex:1 aqui a linha "abraça" o conteúdo e o track (flexBasis 0)
    // fica com 0px de largura — a barra some.
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    gap: 12,
  },
  progressRowCompact: {
    gap: 8,
  },
  progressTrack: {
    flex: 1,
    height: 6,
    backgroundColor: '#DDDDDD',
    borderRadius: 50,
    overflow: 'hidden',
  },
  progressTrackCompact: {
    flexGrow: 0,
    flexShrink: 0,
    flexBasis: 60,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#79A5FF',
    borderRadius: 50,
  },
  progressText: {
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    lineHeight: 17,
    color: '#5E5E5E',
  },
  progressTextCompact: {
    fontSize: 12,
    lineHeight: 15,
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
  lockedRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    gap: 11,
  },
  lockIcon: {
    fontSize: 16,
    color: LOCKED_TEXT,
  },
});
