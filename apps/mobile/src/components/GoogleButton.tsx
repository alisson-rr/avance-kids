import React from 'react';
import { TouchableOpacity, Text, StyleSheet, TouchableOpacityProps } from 'react-native';
import { FontAwesome } from '@expo/vector-icons';
import { theme } from '../theme';

interface GoogleButtonProps extends TouchableOpacityProps {
  title?: string;
}

export function GoogleButton({ title = "Fazer login com o Google", style, ...props }: GoogleButtonProps) {
  return (
    <TouchableOpacity
      style={[styles.button, style]}
      activeOpacity={0.8}
      {...props}
    >
      {/* O <Image> do RN não renderiza SVG — o logo remoto ficava em branco no Android. */}
      <FontAwesome name="google" size={20} color="#4285F4" />
      <Text style={styles.text}>{title}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    height: 48,
    width: '100%',
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: theme.colors.divider,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 10,
    paddingHorizontal: 16,
    gap: 12,
  },
  text: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#727272', // Black/400 from Figma
    lineHeight: 19,
  }
});
