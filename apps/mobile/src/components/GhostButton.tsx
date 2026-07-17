import React from 'react';
import { TouchableOpacity, Text, StyleSheet, TouchableOpacityProps } from 'react-native';
import { theme } from '../theme';

interface GhostButtonProps extends TouchableOpacityProps {
  title: string;
}

export function GhostButton({ title, style, ...props }: GhostButtonProps) {
  return (
    <TouchableOpacity
      style={[styles.button, style]}
      activeOpacity={0.6}
      {...props}
    >
      <Text style={styles.text}>{title}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    height: 48,
    width: '100%',
    backgroundColor: 'transparent',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingVertical: 14,
  },
  text: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#727272', // Gray from Figma
    lineHeight: 19,
  }
});
