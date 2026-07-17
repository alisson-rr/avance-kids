import React from 'react';
import { View, TextInput, StyleSheet, TextInputProps } from 'react-native';
import { theme } from '../theme';

interface SolidInputProps extends TextInputProps {}

export function SolidInput(props: SolidInputProps) {
  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        placeholderTextColor={theme.colors.textLight}
        {...props}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingVertical: 14,
    paddingHorizontal: 20,
    height: 52,
    borderRadius: 100,
    width: '100%',
    backgroundColor: '#F2F2F2', // Solid gray from Figma
  },
  input: {
    flex: 1,
    fontFamily: theme.fonts.regular,
    fontSize: 16,
    color: theme.colors.textDark,
    lineHeight: 24,
  }
});
