import React from 'react';
import { TouchableOpacity, Text, StyleSheet, TouchableOpacityProps, Image } from 'react-native';
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
      <Image 
        source={{ uri: 'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg' }}
        style={styles.icon}
        // Using a remote URI for testing, but ideally this should be a local asset
      />
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
  icon: {
    width: 24,
    height: 24,
  },
  text: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#727272', // Black/400 from Figma
    lineHeight: 19,
  }
});
