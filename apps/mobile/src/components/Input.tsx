import React, { useState } from 'react';
import { View, TextInput, StyleSheet, TextInputProps, TouchableOpacity } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { theme } from '../theme';

interface InputProps extends TextInputProps {
  icon: keyof typeof Feather.glyphMap;
}

export function Input({ icon, secureTextEntry, ...props }: InputProps) {
  const [senhaVisivel, setSenhaVisivel] = useState(false);
  const permiteAlternarSenha = Boolean(secureTextEntry);

  return (
    <View style={styles.container}>
      <Feather name={icon} size={20} color={theme.colors.textLight} style={styles.icon} />
      <TextInput
        style={styles.input}
        placeholderTextColor={theme.colors.textLight}
        secureTextEntry={permiteAlternarSenha && !senhaVisivel}
        {...props}
      />
      {permiteAlternarSenha && (
        <TouchableOpacity
          style={styles.passwordButton}
          onPress={() => setSenhaVisivel((visivel) => !visivel)}
          accessibilityRole="button"
          accessibilityLabel={senhaVisivel ? 'Ocultar senha' : 'Mostrar senha'}
          hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
        >
          <Feather name={senhaVisivel ? 'eye-off' : 'eye'} size={20} color={theme.colors.textLight} />
        </TouchableOpacity>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    paddingHorizontal: 16,
    height: 44,
    borderWidth: 1,
    borderColor: theme.colors.border,
    borderRadius: 100,
    width: '100%',
    backgroundColor: '#FFFFFF', // Assuming input is white based on common practices, or transparent
  },
  icon: {
    marginRight: 8,
  },
  input: {
    flex: 1,
    fontFamily: theme.fonts.regular,
    fontSize: 16,
    color: theme.colors.textDark,
    // Sem lineHeight e sem padding vertical próprio: no Android, a combinação
    // com altura fixa do container recorta o texto digitado (fica invisível).
    paddingVertical: 0,
    textAlignVertical: 'center',
  },
  passwordButton: {
    marginLeft: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
