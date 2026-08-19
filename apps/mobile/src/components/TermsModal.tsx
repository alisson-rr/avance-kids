import React, { useEffect, useState } from 'react';
import { Modal, View, Text, TouchableOpacity, ScrollView, StyleSheet, Linking } from 'react-native';
import { theme } from '../theme';
import { TERMOS_SECOES, TERMOS_TITULO, TERMOS_VERSAO_EMBUTIDA } from '../constants/termos';
import { fetchTermosVigentes } from '../services/terms';
import type { TermsDocumentRow } from '../types/db';

interface TermsModalProps {
  visible: boolean;
  onClose: () => void;
}

/**
 * Termos de Uso e Política de Privacidade — usado no cadastro e no perfil.
 *
 * O texto vem embutido (constants/termos.ts) porque o modal aparece antes de
 * existir sessão e precisa funcionar offline. A versão exibida é a que o
 * servidor declara vigente; quando ela não bate com a do texto embutido, o
 * modal avisa e oferece o link publicado em vez de fingir que são a mesma.
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

  const versaoServidor = documento?.versao ?? null;
  const desatualizado = versaoServidor !== null && versaoServidor !== TERMOS_VERSAO_EMBUTIDA;

  return (
    <Modal visible={visible} animationType="slide" transparent onRequestClose={onClose}>
      <View style={styles.modalContainer}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>{documento?.titulo ?? TERMOS_TITULO}</Text>
          <Text style={styles.modalVersion}>
            {versaoServidor
              ? `Versão ${versaoServidor}`
              : `Versão ${TERMOS_VERSAO_EMBUTIDA} (não foi possível confirmar com o servidor)`}
          </Text>

          <ScrollView style={styles.modalScrollView} contentContainerStyle={styles.modalScrollContent}>
            {desatualizado && (
              <View style={styles.avisoBox} accessible accessibilityRole="alert">
                <Text style={styles.avisoText}>
                  O texto exibido aqui é o da versão {TERMOS_VERSAO_EMBUTIDA}. A versão vigente é a{' '}
                  {versaoServidor}
                  {documento?.url ? '. Toque para abrir o documento atualizado.' : '. Atualize o aplicativo.'}
                </Text>
                {documento?.url && (
                  <TouchableOpacity
                    onPress={() => Linking.openURL(documento.url as string)}
                    accessibilityRole="link"
                  >
                    <Text style={styles.avisoLink}>Abrir versão vigente</Text>
                  </TouchableOpacity>
                )}
              </View>
            )}

            {TERMOS_SECOES.map((secao, i) => (
              <View key={i} style={styles.secao}>
                {secao.titulo && <Text style={styles.secaoTitulo}>{secao.titulo}</Text>}
                {secao.paragrafos?.map((p, j) => (
                  <Text key={j} style={styles.modalText}>
                    {p}
                  </Text>
                ))}
                {secao.itens?.map((item, j) => (
                  <View key={j} style={styles.itemRow}>
                    <Text style={styles.itemMarcador}>•</Text>
                    <Text style={[styles.modalText, styles.itemTexto]}>{item}</Text>
                  </View>
                ))}
              </View>
            ))}
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
  modalTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    marginBottom: 4,
    color: '#424242',
    textAlign: 'center',
  },
  modalVersion: {
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    color: '#8A8A8A',
    textAlign: 'center',
    marginBottom: 12,
  },
  modalScrollView: {
    // Sem maxHeight fixo: com texto longo o conteúdo ultrapassava o maxHeight
    // de 80% do card e cortava o botão "Fechar".
    flexShrink: 1,
  },
  modalScrollContent: {
    paddingBottom: 4,
  },
  avisoBox: {
    backgroundColor: '#FFF6E6',
    borderRadius: 12,
    padding: 12,
    marginBottom: 16,
  },
  avisoText: {
    fontFamily: theme.fonts.regular,
    fontSize: 13,
    color: '#7A5210',
    lineHeight: 19,
  },
  avisoLink: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 13,
    color: theme.colors.primary,
    marginTop: 8,
  },
  secao: {
    marginBottom: 16,
  },
  secaoTitulo: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 15,
    color: '#424242',
    marginBottom: 6,
  },
  modalText: {
    fontFamily: theme.fonts.regular,
    color: '#5E5E5E',
    lineHeight: 22,
    fontSize: 14,
    marginBottom: 8,
  },
  itemRow: {
    flexDirection: 'row',
    paddingLeft: 4,
  },
  itemMarcador: {
    fontFamily: theme.fonts.regular,
    color: '#5E5E5E',
    fontSize: 14,
    lineHeight: 22,
    marginRight: 8,
  },
  itemTexto: {
    flex: 1,
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
