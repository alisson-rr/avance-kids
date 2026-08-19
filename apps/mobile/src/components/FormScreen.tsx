import React from 'react';
import {
  StyleSheet,
  View,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { theme } from '../theme';
import { ScreenHeader } from './ScreenHeader';

interface FormScreenProps {
  /** Quando presente, renderiza o header com botão de voltar. */
  title?: string;
  onBack?: () => void;
  children: React.ReactNode;
  contentStyle?: StyleProp<ViewStyle>;
}

/**
 * Esqueleto comum das telas de formulário:
 * SafeArea + KeyboardAvoiding + ScrollView + corpo centralizado.
 *
 * SafeAreaView vem de react-native-safe-area-context: o do react-native é
 * no-op no Android e, com edge-to-edge ligado, o conteúdo ficava embaixo da
 * status bar.
 */
export function FormScreen({ title, onBack, children, contentStyle }: FormScreenProps) {
  return (
    <SafeAreaView style={styles.safeArea} edges={['top', 'bottom']}>
      <KeyboardAvoidingView
        style={styles.container}
        // No Android o windowSoftInputMode já é adjustResize; usar 'height'
        // aqui encolhe a tela duas vezes e espreme o formulário.
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        {title && onBack && <ScreenHeader title={title} onBack={onBack} />}

        <ScrollView
          contentContainerStyle={styles.scrollContent}
          bounces={false}
          // Sem isto o primeiro toque com o teclado aberto só fecha o teclado
          // e o botão de salvar exige dois toques.
          keyboardShouldPersistTaps="handled"
          keyboardDismissMode="on-drag"
        >
          <View style={[styles.body, { paddingTop: title ? 20 : 60 }, contentStyle]}>
            {children}
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: theme.colors.background },
  container: { flex: 1 },
  scrollContent: { flexGrow: 1 },
  body: { flex: 1, alignItems: 'center', paddingHorizontal: 24, paddingBottom: 40 },
});
