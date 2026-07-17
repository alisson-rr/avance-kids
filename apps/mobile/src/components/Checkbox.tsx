import React from 'react';
import { TouchableOpacity, Text, StyleSheet, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { theme } from '../theme';

interface CheckboxProps {
  value: boolean;
  onValueChange: (value: boolean) => void;
  label: React.ReactNode;
}

export function Checkbox({ value, onValueChange, label }: CheckboxProps) {
  return (
    <TouchableOpacity 
      style={styles.container} 
      activeOpacity={0.8} 
      onPress={() => onValueChange(!value)}
    >
      <View style={[styles.box, value && styles.boxChecked]}>
        {value && <Feather name="check" size={14} color={theme.colors.white} />}
      </View>
      <View style={styles.labelContainer}>
        {typeof label === 'string' ? <Text style={styles.labelText}>{label}</Text> : label}
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 8,
  },
  box: {
    width: 20,
    height: 20,
    borderRadius: 4,
    backgroundColor: '#E5E7EB', // Gray background when unchecked
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  boxChecked: {
    backgroundColor: theme.colors.primary,
  },
  labelContainer: {
    flex: 1,
  },
  labelText: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    color: theme.colors.textDark,
  }
});
