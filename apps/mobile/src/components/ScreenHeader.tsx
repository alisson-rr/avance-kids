import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';

interface ScreenHeaderProps {
  title: string;
  onBack: () => void;
  /**
   * 'large': header de telas de formulário (chevron escuro, título Mulish 18).
   * 'compact': header de páginas de conteúdo (chevron azul, título Inter 16, altura 55).
   */
  variant?: 'large' | 'compact';
}

export function ScreenHeader({ title, onBack, variant = 'large' }: ScreenHeaderProps) {
  if (variant === 'compact') {
    return (
      <View style={styles.compactRow}>
        <TouchableOpacity
          onPress={onBack}
          style={styles.compactIconBtn}
          hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
        >
          <Ionicons name="chevron-back" size={24} color={theme.colors.primary} />
        </TouchableOpacity>

        <Text style={styles.compactTitle}>{title}</Text>

        {/* Espaçador invisível para manter o título centralizado */}
        <View style={styles.compactIconBtn} />
      </View>
    );
  }

  return (
    <View style={styles.largeRow}>
      <TouchableOpacity style={styles.largeBackButton} onPress={onBack}>
        <Ionicons name="chevron-back" size={28} color={theme.colors.textDark} />
      </TouchableOpacity>
      <Text style={styles.largeTitle}>{title}</Text>
      <View style={{ width: 44 }} />
    </View>
  );
}

const styles = StyleSheet.create({
  largeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: Platform.OS === 'ios' ? 10 : 20,
    paddingHorizontal: 20,
    paddingBottom: 20,
    backgroundColor: theme.colors.background,
  },
  largeBackButton: {
    width: 44,
    height: 44,
    justifyContent: 'center',
  },
  largeTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    color: theme.colors.textDark,
  },
  compactRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    height: 55,
  },
  compactIconBtn: {
    width: 24,
    height: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  compactTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
    letterSpacing: 0.32,
    textAlign: 'center',
    color: '#000000',
  },
});
