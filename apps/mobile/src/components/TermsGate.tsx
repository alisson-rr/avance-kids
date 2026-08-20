import React, { useEffect } from 'react';
import { View, Text, ScrollView, StyleSheet, TouchableOpacity, BackHandler } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { theme } from '../theme';
import { Button } from './Button';
import { TermsHeader, TermsBody, textoEhDoVigente } from './TermsContent';
import { AnimatedSplash } from './AnimatedSplash';
import { useTermsGate } from '../store/useTermsGate';
import { signOut } from '../services/auth';
import { errorMessage } from '../services/api';
import { irParaLogin } from '../lib/navigation';
import type { TermsDocumentRow } from '../types/db';

/**
 * Bloqueio de reaceite dos termos.
 *
 * Contas criadas antes da migration-06 não têm linha em `terms_acceptances`, e
 * uma versão nova publicada em `terms_documents` invalida o aceite anterior.
 * Nos dois casos o app precisa pedir o aceite de novo — sem exigir cadastro
 * novo e sem deslogar.
 *
 * É um overlay absoluto e NÃO um <Modal>: o DialogHost já monta um Modal na
 * mesma raiz e, no iOS, dois Modais irmãos disputam a apresentação do mesmo
 * view controller — se um diálogo já estiver na tela, o segundo simplesmente
 * não aparece, e nunca tenta de novo. O bloqueio ficaria invisível com o app
 * navegável por baixo. Como overlay, cobrir é garantido; o botão voltar do
 * Android, que o Modal neutralizava de graça, passa a ser um BackHandler.
 *
 * Também não é uma rota: o navigator é único e plano (as 20 telas são irmãs),
 * então empurrar uma rota não impediria a navegação para as outras.
 *
 * Fechar o app durante o bloqueio não libera nada: a avaliação roda de novo no
 * próximo start e a prova continua sendo a linha no banco.
 */
export function TermsGate() {
  const estado = useTermsGate((s) => s.estado);
  const enviando = useTermsGate((s) => s.enviando);
  const aceitar = useTermsGate((s) => s.aceitar);
  const reavaliar = useTermsGate((s) => s.reavaliar);

  const bloqueando = estado.tipo !== 'ocioso' && estado.tipo !== 'liberado';

  useEffect(() => {
    if (!bloqueando) return;
    const sub = BackHandler.addEventListener('hardwareBackPress', () => true);
    return () => sub.remove();
  }, [bloqueando]);

  if (!bloqueando) return null;

  const sair = async () => {
    try {
      await signOut();
    } finally {
      // Sem isto o gate ficava permanente quando a sessão já não existia:
      // `signOut` não emite evento nenhum, o efeito de sessão do App não
      // roda e nada mais zera o estado — o overlay cobria até o Login.
      useTermsGate.getState().limpar();
      irParaLogin();
    }
  };

  return (
    <View style={styles.overlay}>
      {estado.tipo === 'verificando' ? (
        // Mesma tela do start do app: enquanto não se sabe se o aceite existe,
        // nada fica acessível — e não há um piscar estranho logo após o login.
        <AnimatedSplash />
      ) : (
        <SafeAreaView style={styles.safe} edges={['top', 'bottom']}>
          {estado.tipo === 'erro' ? (
            <View style={styles.centro}>
              <Text style={styles.tituloErro}>Não foi possível verificar os termos</Text>
              <Text style={styles.mensagemErro}>{errorMessage(estado.erro)}</Text>
              <Text style={styles.mensagemErro}>
                Verifique sua conexão e tente de novo. Você não precisa entrar na conta outra vez.
              </Text>
              <View style={styles.acoes}>
                <Button title="Tentar novamente" onPress={() => void reavaliar()} />
              </View>
              <TouchableOpacity onPress={() => void sair()} accessibilityRole="button">
                <Text style={styles.sair}>Sair da conta</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <Conteudo
              documento={estado.documento}
              erro={estado.erro}
              enviando={enviando}
              onAceitar={() => void aceitar()}
              onSair={() => void sair()}
            />
          )}
        </SafeAreaView>
      )}
    </View>
  );
}

interface ConteudoProps {
  documento: TermsDocumentRow;
  erro: unknown;
  enviando: boolean;
  onAceitar: () => void;
  onSair: () => void;
}

function Conteudo({ documento, erro, enviando, onAceitar, onSair }: ConteudoProps) {
  // O app só sabe exibir o texto embutido no binário. Quando a versão vigente
  // é outra, aceitar aqui gravaria consentimento a um documento que o usuário
  // não teve como ler — o oposto do que a trilha de auditoria existe para
  // provar. Com `url` publicada ele consegue ler a versão vigente e o aceite
  // volta a ter lastro.
  const podeLerVigente = textoEhDoVigente(documento) || documento?.url != null;

  return (
    <View style={styles.conteudo}>
      <Text style={styles.chamada}>
        Para continuar usando o Avance Kids, leia e aceite a versão vigente dos Termos de Uso e da
        Política de Privacidade.
      </Text>

      <TermsHeader documento={documento} />

      <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollConteudo}>
        <TermsBody documento={documento} />
      </ScrollView>

      {erro !== undefined && (
        <View style={styles.erroBox} accessible accessibilityRole="alert">
          <Text style={styles.erroTexto}>
            Não foi possível registrar seu aceite: {errorMessage(erro)}
          </Text>
        </View>
      )}

      {podeLerVigente ? (
        <View style={styles.acoes}>
          <Button title="Li e aceito os termos" loading={enviando} onPress={onAceitar} />
        </View>
      ) : (
        <View style={styles.erroBox} accessible accessibilityRole="alert">
          <Text style={styles.erroTexto}>
            Atualize o aplicativo para ler e aceitar a versão vigente. Não é possível aceitar um
            texto que este aplicativo ainda não consegue exibir.
          </Text>
        </View>
      )}

      <TouchableOpacity onPress={onSair} disabled={enviando} accessibilityRole="button">
        <Text style={styles.sair}>Sair da conta</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  overlay: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: theme.colors.white,
    // Garante a cobertura mesmo se alguma tela abaixo definir elevation.
    zIndex: 10,
    elevation: 10,
  },
  safe: {
    flex: 1,
    backgroundColor: theme.colors.white,
  },
  conteudo: {
    flex: 1,
    paddingHorizontal: 24,
    paddingTop: 16,
    paddingBottom: 8,
  },
  centro: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  chamada: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    lineHeight: 21,
    color: '#5E5E5E',
    marginBottom: 16,
  },
  scroll: {
    // flexShrink em vez de altura fixa: com texto longo o conteúdo empurrava o
    // botão de aceite para fora da tela.
    flexShrink: 1,
  },
  scrollConteudo: {
    paddingBottom: 8,
  },
  erroBox: {
    backgroundColor: '#FDECEC',
    borderRadius: 12,
    padding: 12,
    marginTop: 12,
  },
  erroTexto: {
    fontFamily: theme.fonts.regular,
    fontSize: 13,
    lineHeight: 19,
    color: '#8A1F1F',
  },
  tituloErro: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    color: '#424242',
    textAlign: 'center',
    marginBottom: 12,
  },
  mensagemErro: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    lineHeight: 21,
    color: '#5E5E5E',
    textAlign: 'center',
    marginBottom: 8,
  },
  acoes: {
    marginTop: 16,
    marginBottom: 4,
  },
  sair: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 14,
    color: '#8A8A8A',
    textAlign: 'center',
    paddingVertical: 12,
  },
});
