import React from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { theme } from '../theme';
import { getSkillColor } from '../data/habilidades';

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
    return (
      <View style={styles.card}>
        <View style={[styles.tagBadge, { backgroundColor: '#F1F1F1', alignSelf: 'flex-start' }]}>
          <Text style={[styles.tagText, { color: '#AAAAAA' }]}>{skill}</Text>
        </View>
        <View style={styles.lockedRow}>
          <View style={styles.cardTextArea}>
            <Text style={[styles.cardTitle, { color: '#AAAAAA' }]}>{title}</Text>
            <Text style={[styles.cardDescription, { color: '#AAAAAA' }]} numberOfLines={2}>{description}</Text>
          </View>
          <Text style={styles.lockIcon}>🔒</Text>
        </View>
      </View>
    );
  }

  const color = getSkillColor(skill);

  return (
    <TouchableOpacity style={styles.card} activeOpacity={0.7} onPress={onPress}>
      {/* Top row: tag + progress */}
      <View style={styles.cardTopRow}>
        <View style={[styles.tagBadge, { backgroundColor: color.bg }]}>
          <Text style={[styles.tagText, { color: color.text }]}>{skill}</Text>
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
    flex: 0,
    width: 60,
  },
  progressFill: {
    height: 7,
    backgroundColor: '#79A5FF',
    borderRadius: 50,
    marginTop: -0.5,
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
    color: '#AAAAAA',
  },
});
