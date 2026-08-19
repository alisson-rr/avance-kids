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

export type CheckoutPlan = 'monthly' | 'annual';

/** O servidor resolve o price ID e as URLs de retorno; o app só escolhe o plano. */
export async function createCheckoutSession(plan: CheckoutPlan): Promise<string> {
  const { url } = await invokeFunction<{ url: string; session_id: string }>(
    'create-checkout-session',
    { plan },
  );
  return url;
}

/** Portal do Stripe: trocar cartão, ver faturas e cancelar a assinatura. */
export async function createBillingPortalSession(): Promise<string> {
  const { url } = await invokeFunction<{ url: string }>('create-billing-portal-session', {});
  return url;
}
