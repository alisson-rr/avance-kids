import { Alert, Platform, type AlertButton } from 'react-native';

// React Native Web NÃO implementa Alert.alert (é um no-op silencioso):
// alerts de erro e confirmações simplesmente não aparecem no navegador.
// Este shim redireciona para window.alert/window.confirm quando rodando na web.
// Importado uma única vez no App.tsx.
if (Platform.OS === 'web') {
  (Alert as { alert: typeof Alert.alert }).alert = (
    title: string,
    message?: string,
    buttons?: AlertButton[],
  ) => {
    const text = [title, message].filter(Boolean).join('\n\n');

    if (!buttons || buttons.length <= 1) {
      window.alert(text);
      buttons?.[0]?.onPress?.();
      return;
    }

    const confirmBtn = buttons.find((b) => b.style !== 'cancel') ?? buttons[buttons.length - 1];
    const cancelBtn = buttons.find((b) => b.style === 'cancel');
    if (window.confirm(text)) {
      confirmBtn.onPress?.();
    } else {
      cancelBtn?.onPress?.();
    }
  };
}
