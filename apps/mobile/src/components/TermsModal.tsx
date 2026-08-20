import React, { useEffect, useState } from 'react';
import { Modal, View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { theme } from '../theme';
import { TermsHeader, TermsBody } from './TermsContent';
import { fetchTermosVigentes } from '../services/terms';
import type { TermsDocumentRow } from '../types/db';

interface TermsModalProps {
  visible: boolean;
  onClose: () => void;
}

/**
 * Termos de Uso e Política de Privacidade — leitura no cadastro e no perfil.
 *
 * Só exibe. Quem exige o aceite é o TermsGate, que bloqueia o app quando não
 * há registro em terms_acceptances para a versão vigente.
 */
export function TermsModal({ visible, onClose }: TermsModalProps) {
  const [documento, setDocumento] = useState<TermsDocumentRow | null>(null);

  useEffect(() => {
    if (!visible) return;
    let ativo = true;
    fetchTermosVigentes().then((doc) => {
      if (ativo) setDocumento(doc);
    });
    return () => {
      ativo = false;
    };
  }, [visible]);

  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={onClose}>
      <View style={styles.modalContainer}>
        <View style={styles.modalContent}>
          <TermsHeader documento={documento} />

          <ScrollView style={styles.modalScrollView} contentContainerStyle={styles.modalScrollContent}>
            <TermsBody documento={documento} />
          </ScrollView>

          <TouchableOpacity onPress={onClose} style={styles.modalCloseButton} accessibilityRole="button">
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
  modalScrollView: {
    // Sem maxHeight fixo: com texto longo o conteúdo ultrapassava o maxHeight
    // de 80% do card e cortava o botão "Fechar".
    flexShrink: 1,
  },
  modalScrollContent: {
    paddingBottom: 4,
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
