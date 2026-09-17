import { useProfileStore, selectPerfilIncompleto } from '../store/useProfileStore';
import { fetchSubscription, testeGratisEncerrado } from '../services/subscription';

/** "Seu cadastro" em modo completar (App.tsx registra com o parâmetro). */
export const ROTA_COMPLETAR_CADASTRO = { name: 'CompletarCadastro' } as const;
/** "Meu plano" depois do fim do teste grátis, com "Agora não". */
export const ROTA_FIM_DO_TESTE = { name: 'FimDoTeste' } as const;
const ROTA_HOME = { name: 'Home' } as const;

/**
 * Primeira tela de quem já tem sessão (boot, login por e-mail e Google).
 * Chamar depois de loadAll().
 */
export async function destinoAoEntrar(): Promise<{ name: string }> {
  if (selectPerfilIncompleto(useProfileStore.getState())) return ROTA_COMPLETAR_CADASTRO;

  // Sem conseguir ler a assinatura, entra normalmente: o bloqueio do conteúdo
  // premium continua valendo no banco.
  const assinatura = await fetchSubscription().catch(() => null);
  return testeGratisEncerrado(assinatura) ? ROTA_FIM_DO_TESTE : ROTA_HOME;
}
