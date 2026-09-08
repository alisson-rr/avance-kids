import React, { useEffect, useState } from 'react';
import { Modal, Platform, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { theme } from '../theme';

type InstallChoice = {
  outcome: 'accepted' | 'dismissed';
  platform: string;
};

type BeforeInstallPromptEvent = Event & {
  prompt: () => Promise<void>;
  userChoice: Promise<InstallChoice>;
};

function estaInstalado() {
  const navegador = window.navigator as Navigator & { standalone?: boolean };
  return window.matchMedia('(display-mode: standalone)').matches || navegador.standalone === true;
}

function ehIos() {
  const navegador = window.navigator as Navigator & { userAgent: string };
  return /iphone|ipad|ipod/i.test(navegador.userAgent);
}

/**
 * Convite de instalação exclusivo da versão web.
 *
 * O navegador só permite abrir o diálogo nativo depois de uma ação do usuário.
 * Por isso guardamos o evento `beforeinstallprompt` e o usamos no botão. Quando
 * o navegador não oferece esse evento (Safari/iOS, por exemplo), mostramos a
 * orientação para adicionar o app pela opção de compartilhamento/menu.
 */
export function PwaInstallPrompt() {
  const [visivel, setVisivel] = useState(false);
  const [eventoInstalacao, setEventoInstalacao] = useState<BeforeInstallPromptEvent | null>(null);
  const [ios, setIos] = useState(false);

  useEffect(() => {
    if (Platform.OS !== 'web' || estaInstalado()) return;

    const solicitadoPelaLanding = new URLSearchParams(window.location.search).get('install') === '1';
    const dispositivoIos = ehIos();
    setIos(dispositivoIos);

    if (solicitadoPelaLanding || dispositivoIos) {
      setVisivel(true);
    }

    const aoFicarInstalavel = (evento: Event) => {
      evento.preventDefault();
      setEventoInstalacao(evento as BeforeInstallPromptEvent);
      setVisivel(true);
    };

    const aoInstalar = () => {
      setEventoInstalacao(null);
      setVisivel(false);
    };

    window.addEventListener('beforeinstallprompt', aoFicarInstalavel);
    window.addEventListener('appinstalled', aoInstalar);

    return () => {
      window.removeEventListener('beforeinstallprompt', aoFicarInstalavel);
      window.removeEventListener('appinstalled', aoInstalar);
    };
  }, []);

  if (Platform.OS !== 'web') return null;

  const instalar = async () => {
    if (!eventoInstalacao) {
      setVisivel(false);
      return;
    }

    await eventoInstalacao.prompt();
    await eventoInstalacao.userChoice;
    setEventoInstalacao(null);
    setVisivel(false);
  };

  const mensagem = eventoInstalacao
    ? 'Instale o Avance Kids para abrir o app direto pela sua tela inicial, com a mesma experiência do navegador.'
    : ios
      ? 'No Safari, toque em Compartilhar e depois em “Adicionar à Tela de Início”.'
      : 'Abra o menu do navegador e escolha “Instalar aplicativo” ou “Adicionar à tela inicial”.';

  return (
    <Modal
      visible={visivel}
      transparent
      animationType="fade"
      onRequestClose={() => setVisivel(false)}
    >
      <View style={styles.overlay} accessibilityViewIsModal>
        <View style={styles.card}>
          <View style={styles.icone} accessible={false}>
            <Text style={styles.iconeTexto}>+</Text>
          </View>

          <Text style={styles.titulo}>Instale o Avance Kids</Text>
          <Text style={styles.mensagem}>{mensagem}</Text>

          <TouchableOpacity
            style={styles.botaoPrincipal}
            activeOpacity={0.8}
            accessibilityRole="button"
            onPress={() => void instalar()}
          >
            <Text style={styles.botaoPrincipalTexto}>
              {eventoInstalacao ? 'Instalar agora' : 'Entendi'}
            </Text>
          </TouchableOpacity>

          {eventoInstalacao ? (
            <TouchableOpacity
              style={styles.botaoDepois}
              activeOpacity={0.7}
              accessibilityRole="button"
              onPress={() => setVisivel(false)}
            >
              <Text style={styles.botaoDepoisTexto}>Agora não</Text>
            </TouchableOpacity>
          ) : null}
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
    maxWidth: 380,
    borderRadius: 20,
    backgroundColor: theme.colors.white,
    padding: 24,
    alignItems: 'center',
  },
  icone: {
    width: 56,
    height: 56,
    borderRadius: 16,
    backgroundColor: '#EAF1FF',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
  },
  iconeTexto: {
    color: theme.colors.primary,
    fontFamily: theme.fonts.semiBold,
    fontSize: 32,
    lineHeight: 36,
  },
  titulo: {
    color: theme.colors.textDark,
    fontFamily: theme.fonts.mulishBold,
    fontSize: 21,
    lineHeight: 27,
    textAlign: 'center',
    marginBottom: 10,
  },
  mensagem: {
    color: theme.colors.textLight,
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    lineHeight: 22,
    textAlign: 'center',
    marginBottom: 22,
  },
  botaoPrincipal: {
    width: '100%',
    minHeight: 48,
    borderRadius: 24,
    backgroundColor: theme.colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
    paddingVertical: 12,
  },
  botaoPrincipalTexto: {
    color: theme.colors.white,
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 20,
  },
  botaoDepois: {
    minHeight: 44,
    justifyContent: 'center',
    paddingHorizontal: 20,
    marginTop: 6,
  },
  botaoDepoisTexto: {
    color: theme.colors.textLight,
    fontFamily: theme.fonts.medium,
    fontSize: 14,
  },
});
