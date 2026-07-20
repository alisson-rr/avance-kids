import { supabase } from '../lib/supabase';
import { invokeFunction } from './api';
import type { SubscriptionRow } from '../types/db';

export async function fetchSubscription(): Promise<SubscriptionRow | null> {
  const { data, error } = await supabase
    .from('subscriptions')
    .select('plano, status, trial_end, current_period_end')
    .maybeSingle();
  if (error) throw new Error(error.message);
  return data;
}

export type CheckoutPlan = 'monthly' | 'annual';

const PRICE_IDS: Record<CheckoutPlan, string | undefined> = {
  monthly: process.env.EXPO_PUBLIC_STRIPE_PRICE_MONTHLY,
  annual: process.env.EXPO_PUBLIC_STRIPE_PRICE_ANNUAL,
};

export async function createCheckoutSession(plan: CheckoutPlan): Promise<string> {
  const priceId = PRICE_IDS[plan];
  if (!priceId) {
    throw new Error(
      'Plano indisponível no momento. (Price ID do Stripe não configurado no app.)',
    );
  }

  const { url } = await invokeFunction<{ url: string; session_id: string }>(
    'create-checkout-session',
    {
      price_id: priceId,
      success_url:
        process.env.EXPO_PUBLIC_CHECKOUT_SUCCESS_URL ??
        'https://avancekids.com.br/assinatura/sucesso',
      cancel_url:
        process.env.EXPO_PUBLIC_CHECKOUT_CANCEL_URL ??
        'https://avancekids.com.br/assinatura/cancelado',
    },
  );
  return url;
}
