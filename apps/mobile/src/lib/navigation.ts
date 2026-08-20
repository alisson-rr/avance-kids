import { createNavigationContainerRef } from '@react-navigation/native';

/**
 * Referência do navigator para quem está fora dele.
 *
 * Só o TermsGate precisa: ele é renderizado ao lado do NavigationContainer
 * (para cobrir o app inteiro) e, ao sair da conta, tem de mandar o usuário
 * para o Login. As telas continuam usando a prop `navigation`.
 */
export const navigationRef = createNavigationContainerRef();

export function irParaLogin() {
  if (navigationRef.isReady()) {
    navigationRef.reset({ index: 0, routes: [{ name: 'Login' }] });
  }
}
