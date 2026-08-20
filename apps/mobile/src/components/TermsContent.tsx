import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Linking } from 'react-native';
import { theme } from '../theme';
import { showError } from '../ui/dialog';
import { TERMOS_SECOES, TERMOS_TITULO, TERMOS_VERSAO_EMBUTIDA } from '../constants/termos';
import type { TermsDocumentRow } from '../types/db';

/**
 * Texto dos termos, compartilhado pelo modal informativo (TermsModal) e pelo
 * bloqueio de reaceite (TermsGate). São duas molduras diferentes em volta do
 * mesmo conteúdo — duplicar o texto e o aviso de versão faria as duas telas
 * divergirem na primeira alteração.
 */

interface Props {
  documento: TermsDocumentRow | null;
}

/**
 * O texto embutido no app é o da versão que o servidor declara vigente?
 *
 * Quando não é, o app não tem como exibir o documento vigente — só o antigo
 * mais um aviso. Serve ao TermsGate: aceitar nessa situação gravaria
 * consentimento a um texto que o titular não leu.
 */
export function textoEhDoVigente(documento: TermsDocumentRow | null): boolean {
  return documento === null || documento.versao === TERMOS_VERSAO_EMBUTIDA;
}

export function TermsHeader({ documento }: Props) {
  const versaoServidor = documento?.versao ?? null;
  return (
    <>
      <Text style={styles.titulo}>{documento?.titulo ?? TERMOS_TITULO}</Text>
      <Text style={styles.versao}>
        {versaoServidor
          ? `Versão ${versaoServidor}`
          : `Versão ${TERMOS_VERSAO_EMBUTIDA} (não foi possível confirmar com o servidor)`}
      </Text>
    </>
  );
}

/** Conteúdo rolável. Precisa ficar dentro de um ScrollView do chamador. */
export function TermsBody({ documento }: Props) {
  const versaoServidor = documento?.versao ?? null;
  // O texto embutido funciona offline e antes de existir sessão; quando ele não
  // é o vigente, avisar é mais honesto do que exibir como se fosse.
  const desatualizado = versaoServidor !== null && versaoServidor !== TERMOS_VERSAO_EMBUTIDA;

  return (
    <>
      {desatualizado && (
        <View style={styles.avisoBox} accessible accessibilityRole="alert">
          <Text style={styles.avisoText}>
            O texto exibido aqui é o da versão {TERMOS_VERSAO_EMBUTIDA}. A versão vigente é a{' '}
            {versaoServidor}
            {documento?.url ? '. Toque para abrir o documento atualizado.' : '. Atualize o aplicativo.'}
          </Text>
          {documento?.url && (
            <TouchableOpacity
              onPress={() =>
                Linking.openURL(documento.url as string).catch(() =>
                  showError('Erro', 'Não foi possível abrir o documento.'),
                )
              }
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
            <Text key={j} style={styles.texto}>
              {p}
            </Text>
          ))}
          {secao.itens?.map((item, j) => (
            <View key={j} style={styles.itemRow}>
              <Text style={styles.itemMarcador}>•</Text>
              <Text style={[styles.texto, styles.itemTexto]}>{item}</Text>
            </View>
          ))}
        </View>
      ))}
    </>
  );
}

const styles = StyleSheet.create({
  titulo: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    marginBottom: 4,
    color: '#424242',
    textAlign: 'center',
  },
  versao: {
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    color: '#8A8A8A',
    textAlign: 'center',
    marginBottom: 12,
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
  texto: {
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
});
