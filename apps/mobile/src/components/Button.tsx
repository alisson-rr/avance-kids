import React from 'react';
import { TouchableOpacity, Text, StyleSheet, TouchableOpacityProps, ActivityIndicator } from 'react-native';
import { theme } from '../theme';

interface ButtonProps extends TouchableOpacityProps {
  title: string;
  loading?: boolean;
}

export function Button({ title, loading, style, ...props }: ButtonProps) {
  return (
    <TouchableOpacity
      style={[styles.button, style]}
      activeOpacity={0.8}
      disabled={loading}
      {...props}
    >
      {loading ? (
        <ActivityIndicator color={theme.colors.white} />
      ) : (
        <Text style={styles.text}>{title}</Text>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    height: 48,
    width: '100%',
    backgroundColor: theme.colors.primary,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingVertical: 14,
  },
  text: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: theme.colors.white,
    lineHeight: 19,
  }
});
