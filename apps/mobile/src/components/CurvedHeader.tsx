import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';

export const HEADER_MIN_HEIGHT = Platform.OS === 'ios' ? 110 : 90;
export const HEADER_MAX_HEIGHT = 198;
export const CURVE_TOP = HEADER_MIN_HEIGHT - 30;
export const CURVE_MAX_HEIGHT = HEADER_MAX_HEIGHT - CURVE_TOP;

interface CurvedHeaderProps {
  title: string;
  onBack: () => void;
}

/**
 * Header azul fixo com extensão curva atrás do conteúdo (versão estática).
 * A HomeScreen usa uma variante animada própria, compartilhando as constantes acima.
 */
export function CurvedHeader({ title, onBack }: CurvedHeaderProps) {
  return (
    <>
      {/* Curved background extension (behind the ScrollView) */}
      <View style={styles.headerCurve} />

      {/* Top fixed header */}
      <View style={styles.topFixedHeader}>
        <View style={styles.topBar}>
          <TouchableOpacity style={styles.iconButton} onPress={onBack}>
            <Ionicons name="chevron-back" size={28} color={theme.colors.white} />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>{title}</Text>
          <View style={{ width: 44 }} />
        </View>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  headerCurve: {
    backgroundColor: '#3678FD',
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
    position: 'absolute',
    top: CURVE_TOP,
    height: CURVE_MAX_HEIGHT,
    left: 0,
    right: 0,
    zIndex: 0,
    elevation: 0,
  },
  topFixedHeader: {
    backgroundColor: '#3678FD',
    height: HEADER_MIN_HEIGHT,
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
    paddingTop: Platform.OS === 'ios' ? 50 : 30,
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 10,
    elevation: 10,
    justifyContent: 'center',
  },
  topBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 50,
    paddingHorizontal: 12,
  },
  iconButton: {
    padding: 8,
    width: 44,
    alignItems: 'center',
    zIndex: 20,
  },
  headerTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 20,
    color: '#FFFFFF',
  },
});
