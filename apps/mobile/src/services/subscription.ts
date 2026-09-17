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
    .select('plano, status, trial_end, current_period_end, teste_gratis_ate')
    .eq('user_id', userData.user.id)
    .maybeSingle();
  if (error) throw new Error(error.message);
  return data;
}

/**
 * Assinatura paga pelo Stripe. has_premium_access() no banco é esta regra OU
 * emTesteGratis() (migration-22).
 */
export function isPremiumActive(sub: SubscriptionRow | null | undefined): boolean {
  return sub?.plano === 'premium' && (sub.status === 'active' || sub.status === 'trialing');
}

const DIA_MS = 86_400_000;
// O Brasil não tem horário de verão desde 2019: UTC-3 fixo dispensa Intl.
const OFFSET_BRASILIA_MS = 3 * 60 * 60 * 1000;
const diaEmBrasilia = (ms: number) => Math.floor((ms - OFFSET_BRASILIA_MS) / DIA_MS);

function fimDoTeste(sub: SubscriptionRow | null | undefined): number | null {
  // past_due tem assinatura viva no Stripe (pagamento pendente): não é
  // "teste encerrado", é caso de trocar o cartão.
  if (isPremiumActive(sub) || sub?.status === 'past_due' || !sub?.teste_gratis_ate) return null;
  return Date.parse(sub.teste_gratis_ate);
}

/** Teste grátis do cadastro em andamento (quem já paga não está "em teste"). */
export function emTesteGratis(sub: SubscriptionRow | null | undefined, agora = Date.now()): boolean {
  const fim = fimDoTeste(sub);
  return fim !== null && fim > agora;
}

/** Teste grátis acabou e a conta não assinou. */
export function testeGratisEncerrado(sub: SubscriptionRow | null | undefined, agora = Date.now()): boolean {
  const fim = fimDoTeste(sub);
  return fim !== null && fim <= agora;
}

/**
 * Dias inteiros de teste, contados em Brasília: 15 no dia do cadastro, 1 no
 * último. O prazo termina à meia-noite (fim_do_teste_gratis no banco).
 */
export function diasRestantesDeTeste(sub: SubscriptionRow | null | undefined, agora = Date.now()): number | null {
  if (!emTesteGratis(sub, agora)) return null;
  return Math.max(1, diaEmBrasilia(fimDoTeste(sub)!) - diaEmBrasilia(agora));
}

/** Último dia com acesso, em dd/mm/aaaa (o prazo em si é a meia-noite seguinte). */
export function ultimoDiaDeTeste(sub: SubscriptionRow | null | undefined): string | null {
  const fim = fimDoTeste(sub);
  if (fim === null) return null;
  const dia = new Date(fim - OFFSET_BRASILIA_MS - 1);
  const dd = String(dia.getUTCDate()).padStart(2, '0');
  const mm = String(dia.getUTCMonth() + 1).padStart(2, '0');
  return `${dd}/${mm}/${dia.getUTCFullYear()}`;
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
