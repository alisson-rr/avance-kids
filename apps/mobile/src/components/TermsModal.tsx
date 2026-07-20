import React from 'react';
import { Modal, View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { theme } from '../theme';

interface TermsModalProps {
  visible: boolean;
  onClose: () => void;
}

/** Modal dos Termos de Consentimento — usado no cadastro e no perfil. */
export function TermsModal({ visible, onClose }: TermsModalProps) {
  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={onClose}>
      <View style={styles.modalContainer}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>Termos de Consentimento</Text>
          <ScrollView style={styles.modalScrollView}>
            <Text style={styles.modalText}>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
              {'\n\n'}
              Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            </Text>
          </ScrollView>
          <TouchableOpacity onPress={onClose} style={styles.modalCloseButton}>
            <Text style={styles.modalCloseText}>Fechar</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  modalContainer: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: theme.colors.white,
    padding: 24,
    borderRadius: 16,
    width: '90%',
    maxWidth: 400,
    maxHeight: '80%',
  },
  modalTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    marginBottom: 15,
    color: '#424242',
    textAlign: 'center',
  },
  modalScrollView: {
    maxHeight: 400,
  },
  modalText: {
    fontFamily: theme.fonts.regular,
    color: '#5E5E5E',
    lineHeight: 22,
    fontSize: 14,
  },
  modalCloseButton: {
    marginTop: 20,
    padding: 14,
    backgroundColor: '#3678FD',
    borderRadius: 50,
    alignItems: 'center',
  },
  modalCloseText: {
    fontFamily: theme.fonts.mulishSemiBold,
    color: theme.colors.white,
    fontSize: 16,
  },
});
