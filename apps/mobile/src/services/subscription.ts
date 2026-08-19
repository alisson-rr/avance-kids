import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import type { SubscriptionRow } from '../types/db';

export async function fetchSubscription(): Promise<SubscriptionRow | null> {
  const { data: userData } = await supabase.auth.getUser();
  if (!userData.user) return null;

  // Filtro explícito: a policy de admin enxerga todas as assinaturas e sem o
  // eq() o maybeSingle() quebraria para quem é admin.
  const { data, error } = await supabase
    .from('subscriptions')
    .select('plano, status, trial_end, current_period_end')
    .eq('user_id', userData.user.id)
    .maybeSingle();
  if (error) throw new Error(error.message);
  return data;
}

/** Única definição de "tem acesso premium" no app — espelha has_premium_access() no banco. */
export function isPremiumActive(sub: SubscriptionRow | null | undefined): boolean {
  return sub?.plano === 'premium' && (sub.status === 'active' || sub.status === 'trialing');
}

/**
 * Preço e período de teste vigentes, resolvidos no servidor.
 *
 * O preço vem do próprio Price do Stripe usado no checkout, e `trial_dias` já
 * chega zerado para quem não tem mais direito ao teste — é o que impede a tela
 * de anunciar um valor ou um período diferente do que será cobrado.
 */
export interface BillingConfig {
  intervalo: 'mensal';
  valor_centavos: number;
  moeda: string;
  trial_dias: number;
  ja_usou_teste: boolean;
}

export async function fetchBillingConfig(): Promise<BillingConfig> {
  return invokeFunction<BillingConfig>('billing-config', {});
}

/**
 * Abre o checkout da assinatura mensal — o único plano que existe.
 *
 * Nenhum plano é enviado: o servidor resolve o price ID, o período de teste e
 * as URLs de retorno. Mandar o plano daqui foi o que permitiu, por um tempo, a
 * tela oferecer um anual que o backend recusa.
 */
export async function createCheckoutSession(): Promise<string> {
  const { url } = await invokeFunction<{ url: string; session_id: string }>(
    'create-checkout-session',
    {},
  );
  return url;
}

/** Portal do Stripe: trocar cartão, ver faturas e cancelar a assinatura. */
export async function createBillingPortalSession(): Promise<string> {
  const { url } = await invokeFunction<{ url: string }>('create-billing-portal-session', {});
  return url;
}
