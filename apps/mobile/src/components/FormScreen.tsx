import React from 'react';
import {
  StyleSheet,
  View,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleProp,
  ViewStyle,
} from 'react-native';
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
 */
export function FormScreen({ title, onBack, children, contentStyle }: FormScreenProps) {
  return (
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        {title && onBack && <ScreenHeader title={title} onBack={onBack} />}

        <ScrollView contentContainerStyle={styles.scrollContent} bounces={false}>
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
