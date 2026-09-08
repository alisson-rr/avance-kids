import React, { useState } from 'react';
import { View, TextInput, StyleSheet, TextInputProps, TouchableOpacity } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { theme } from '../theme';

interface SolidInputProps extends TextInputProps {}

export function SolidInput({ secureTextEntry, ...props }: SolidInputProps) {
  const [senhaVisivel, setSenhaVisivel] = useState(false);
  const permiteAlternarSenha = Boolean(secureTextEntry);

  return (
    <View style={styles.container}>
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
    paddingHorizontal: 20,
    height: 52,
    borderRadius: 100,
    width: '100%',
    backgroundColor: '#F2F2F2', // Solid gray from Figma
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
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
