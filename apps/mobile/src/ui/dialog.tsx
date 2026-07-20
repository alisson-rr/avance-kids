import React from 'react';
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
} from 'react-native';
import { create } from 'zustand';
import { theme } from '../theme';

// Diálogo padrão do app: substitui o Alert nativo (feio e inconsistente
// entre plataformas — inexistente no web) por um modal com a cara do app.
// Uso: showDialog / showError / showSuccess / showConfirm + <DialogHost/> no App.

export type DialogVariant = 'info' | 'success' | 'error';

export interface DialogButton {
  label: string;
  onPress?: () => void;
  kind?: 'primary' | 'ghost' | 'destructive';
}

export interface DialogOptions {
  title: string;
  message?: string;
  variant?: DialogVariant;
  buttons?: DialogButton[];
}

interface DialogState {
  visible: boolean;
  options: DialogOptions | null;
  open: (options: DialogOptions) => void;
  close: () => void;
}

const useDialogStore = create<DialogState>((set) => ({
  visible: false,
  options: null,
  open: (options) => set({ visible: true, options }),
  close: () => set({ visible: false }),
}));

export function showDialog(options: DialogOptions) {
  useDialogStore.getState().open(options);
}

export function showError(title: string, message?: string, buttons?: DialogButton[]) {
  showDialog({ title, message, variant: 'error', buttons });
}

export function showSuccess(title: string, message?: string, buttons?: DialogButton[]) {
  showDialog({ title, message, variant: 'success', buttons });
}

export function showConfirm(
  title: string,
  message: string,
  confirm: DialogButton,
  cancelLabel = 'Cancelar',
) {
  showDialog({
    title,
    message,
    buttons: [confirm, { label: cancelLabel, kind: 'ghost' }],
  });
}

const VARIANT_STYLE: Record<DialogVariant, { icon: string; bg: string; color: string }> = {
  info: { icon: 'i', bg: '#EEF4FF', color: '#0E5DFD' },
  success: { icon: '✓', bg: '#F3FAE8', color: '#82C302' },
  error: { icon: '!', bg: '#FFE9EE', color: '#FE6D94' },
};

export function DialogHost() {
  const { visible, options, close } = useDialogStore();
  if (!options) return null;

  const variant = VARIANT_STYLE[options.variant ?? 'info'];
  const buttons: DialogButton[] =
    options.buttons && options.buttons.length > 0
      ? options.buttons
      : [{ label: 'OK', kind: 'primary' }];

  const handlePress = (button: DialogButton) => {
    close();
    // Fecha antes de executar para permitir que o onPress abra outro diálogo/navegue
    button.onPress?.();
  };

  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={close}>
      <View style={styles.overlay}>
        <View style={styles.card}>
          <View style={[styles.iconCircle, { backgroundColor: variant.bg }]}>
            <Text style={[styles.iconText, { color: variant.color }]}>{variant.icon}</Text>
          </View>

          <Text style={styles.title}>{options.title}</Text>

          {options.message ? (
            <ScrollView style={styles.messageScroll} showsVerticalScrollIndicator={false}>
              <Text style={styles.message}>{options.message}</Text>
            </ScrollView>
          ) : null}

          <View style={styles.buttonColumn}>
            {buttons.map((button, index) => {
              const kind = button.kind ?? (index === 0 ? 'primary' : 'ghost');
              return (
                <TouchableOpacity
                  key={index}
                  style={[
                    styles.button,
                    kind === 'primary' && styles.buttonPrimary,
                    kind === 'destructive' && styles.buttonDestructive,
                    kind === 'ghost' && styles.buttonGhost,
                  ]}
                  activeOpacity={0.8}
                  onPress={() => handlePress(button)}
                >
                  <Text
                    style={[
                      styles.buttonLabel,
                      kind === 'ghost' ? styles.buttonLabelGhost : styles.buttonLabelFilled,
                    ]}
                  >
                    {button.label}
                  </Text>
                </TouchableOpacity>
              );
            })}
          </View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.45)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  card: {
    width: '100%',
    maxWidth: 360,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 24,
    alignItems: 'center',
    gap: 16,
  },
  iconCircle: {
    width: 56,
    height: 56,
    borderRadius: 28,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 26,
    lineHeight: 32,
  },
  title: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 18,
    lineHeight: 24,
    color: '#3B3B3B',
    textAlign: 'center',
  },
  messageScroll: {
    maxHeight: 260,
    alignSelf: 'stretch',
  },
  message: {
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    lineHeight: 22,
    color: '#5E5E5E',
    textAlign: 'center',
  },
  buttonColumn: {
    alignSelf: 'stretch',
    gap: 12,
    marginTop: 4,
  },
  button: {
    height: 48,
    borderRadius: 50,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  buttonPrimary: {
    backgroundColor: theme.colors.primary,
  },
  buttonDestructive: {
    backgroundColor: '#FE6D94',
  },
  buttonGhost: {
    borderWidth: 1.5,
    borderColor: theme.colors.primary,
    backgroundColor: '#FFFFFF',
  },
  buttonLabel: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
  },
  buttonLabelFilled: {
    color: '#FFFFFF',
  },
  buttonLabelGhost: {
    color: theme.colors.primary,
  },
});
