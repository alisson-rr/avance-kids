import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Linking,
  AppState,
} from 'react-native';
// SafeAreaView do 'react-native' e no-op no Android; com edge-to-edge o header
// ficava por baixo da status bar.
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { Feather } from '@expo/vector-icons';
import { theme } from '../theme';
import { Button } from '../components/Button';
import { ScreenHeader } from '../components/ScreenHeader';
import {
  createBillingPortalSession,
  createCheckoutSession,
  fetchBillingConfig,
  fetchSubscription,
  isPremiumActive,
} from '../services/subscription';
import type { BillingConfig } from '../services/subscription';
import { errorMessage } from '../services/api';
import { fromIsoDate } from '../utils/formatters';
import { showError } from '../ui/dialog';
import type { SubscriptionRow } from '../types/db';

/**
 * Centavos do Stripe para texto. Sem Intl de propósito: o valor precisa sair
 * igual em qualquer runtime, e o único caso real é BRL.
 */
function formatarPreco(centavos: number, moeda: string): string {
  const valor = (centavos / 100).toFixed(2).replace('.', ',');
  return moeda.toLowerCase() === 'brl' ? `R$ ${valor}` : `${moeda.toUpperCase()} ${valor}`;
}

/** Releituras após voltar do checkout: o webhook do Stripe leva alguns segundos. */
const POLL_TRIES = 4;
const POLL_INTERVAL_MS = 2000;

export function PlansScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const [loading, setLoading] = useState(false);
  // Preço e teste vêm do servidor (billing-config). Enquanto não chegam a tela
  // não inventa valor nenhum: anunciar um número que o Stripe não pratica é
  // pior do que não anunciar.
  const [billing, setBilling] = useState<BillingConfig | null>(null);
  const [billingErro, setBillingErro] = useState(false);
  const [subscription, setSubscription] = useState<SubscriptionRow | null>(null);
  // Sem isto, "ainda verificando" e "nao tem assinatura" ficam indistinguiveis e
  // um assinante ve "Assinar agora" por alguns instantes.
  const [checking, setChecking] = useState(true);
  const pollRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const isPremium = isPremiumActive(subscription);
  // Cobrança recusada: mandar para um checkout novo criaria uma segunda
  // assinatura no Stripe. O caminho certo é o portal, para trocar o cartão.
  const needsPaymentFix =
    subscription?.plano === 'premium' && subscription.status === 'past_due';

  const refresh = useCallback(async (retries = 0) => {
    // Cada volta ao primeiro plano recomeça o poll; sem isso a cadeia anterior
    // continuaria rodando sem ninguém para cancelá-la.
    if (pollRef.current) clearTimeout(pollRef.current);
    try {
      const next = await fetchSubscription();
      setSubscription(next);
      if (!isPremiumActive(next) && retries > 0) {
        pollRef.current = setTimeout(() => refresh(retries - 1), POLL_INTERVAL_MS);
      }
    } catch {
      // Sem o status a tela continua utilizável; o botão informa o erro real.
    } finally {
      setChecking(false);
    }
  }, []);

  useEffect(() => {
    fetchBillingConfig()
      .then(setBilling)
      .catch(() => setBillingErro(true));
  }, []);

  useEffect(() => {
    refresh();
    // O checkout abre no navegador e a tela não remonta na volta — só o
    // AppState avisa que o app voltou ao primeiro plano.
    const sub = AppState.addEventListener('change', (state) => {
      if (state === 'active') refresh(POLL_TRIES);
    });
    return () => {
      sub.remove();
      if (pollRef.current) clearTimeout(pollRef.current);
    };
  }, [refresh]);

  const openStripe = async (getUrl: () => Promise<string>, tituloErro: string) => {
    setLoading(true);
    try {
      await Linking.openURL(await getUrl());
    } catch (err) {
      showError(tituloErro, errorMessage(err));
    } finally {
      setLoading(false);
    }
  };

  const handleSubscribe = () => openStripe(createCheckoutSession, 'Erro na assinatura');

  const handleManage = () =>
    openStripe(createBillingPortalSession, 'Erro ao abrir a assinatura');

  const statusLabel = () => {
    if (!isPremium) return null;
    if (subscription?.status === 'trialing' && subscription.trial_end) {
      return `Teste grátis até ${fromIsoDate(subscription.trial_end)}`;
    }
    if (subscription?.current_period_end) {
      return `Renova em ${fromIsoDate(subscription.current_period_end)}`;
    }
    return 'Assinatura ativa';
  };

  const benefits = [
    'Acesso a todas as atividades',
    'Avaliação de desenvolvimento ilimitada',
    'Histórico detalhado de evolução',
    'Dicas diárias para os pais',
    'Suporte prioritário',
  ];

  return (
    <SafeAreaView style={styles.safeArea} edges={['top', 'bottom']}>
      <View style={styles.container}>
        <ScreenHeader title="Meu Plano" onBack={() => navigation.goBack()} />

        <ScrollView
          contentContainerStyle={[styles.scrollContent, { paddingBottom: 40 + insets.bottom }]}
          showsVerticalScrollIndicator={false}
        >
          
          <View style={styles.introSection}>
            <Text style={styles.title}>Desbloqueie todo o potencial do seu filho</Text>
            <Text style={styles.subtitle}>Assinatura mensal, sem fidelidade, para acompanhar e estimular o desenvolvimento contínuo.</Text>
          </View>

          {needsPaymentFix && (
            <View style={[styles.activeBanner, styles.warningBanner]} accessible accessibilityRole="alert">
              <Feather name="alert-circle" size={20} color="#B26A00" />
              <View style={styles.activeBannerText}>
                <Text style={[styles.activeBannerTitle, styles.warningTitle]}>Pagamento não confirmado</Text>
                <Text style={[styles.activeBannerSubtitle, styles.warningSubtitle]}>
                  Atualize a forma de pagamento para manter o acesso premium.
                </Text>
              </View>
            </View>
          )}

          {isPremium && (
            <View
              style={styles.activeBanner}
              accessible
              accessibilityRole="summary"
              accessibilityLabel={`Assinatura premium ativa. ${statusLabel()}`}
            >
              <Feather name="check-circle" size={20} color="#0B7D57" />
              <View style={styles.activeBannerText}>
                <Text style={styles.activeBannerTitle}>Assinatura premium ativa</Text>
                <Text style={styles.activeBannerSubtitle}>{statusLabel()}</Text>
              </View>
            </View>
          )}

          <View style={styles.plansContainer}>
            {/* Plano único: mensal. Não existe anual — o backend recusa
                qualquer plano diferente de "monthly" (billing.ts). */}
            <View style={styles.planCard} accessible accessibilityRole="summary">
              <View style={styles.planHeader}>
                <Text style={styles.planName}>Mensal</Text>
              </View>

              {billing ? (
                <>
                  <Text style={styles.planPrice}>
                    {formatarPreco(billing.valor_centavos, billing.moeda)}
                    <Text style={styles.planPeriod}>/mês</Text>
                  </Text>
                  {billing.trial_dias > 0 && (
                    <Text style={styles.trialText}>
                      {billing.trial_dias} dias grátis para experimentar
                    </Text>
                  )}
                  {billing.ja_usou_teste && !isPremium && (
                    <Text style={styles.planNote}>
                      O período de teste já foi utilizado nesta conta.
                    </Text>
                  )}
                </>
              ) : (
                <Text style={styles.planNote}>
                  {billingErro
                    ? 'Não foi possível carregar o valor agora. O preço aparece na tela de pagamento.'
                    : 'Carregando valor…'}
                </Text>
              )}
            </View>
          </View>

          <View style={styles.benefitsContainer}>
            <Text style={styles.benefitsTitle}>O que está incluído:</Text>
            {benefits.map((benefit, index) => (
              <View key={index} style={styles.benefitRow}>
                <Feather name="check-circle" size={20} color={theme.colors.primary} />
                <Text style={styles.benefitText}>{benefit}</Text>
              </View>
            ))}
          </View>

          <View style={styles.actionContainer}>
            <Button
              title={
                checking
                  ? 'Verificando assinatura…'
                  : needsPaymentFix
                    ? 'Atualizar pagamento'
                    : isPremium
                      ? 'Gerenciar assinatura'
                      : 'Assinar agora'
              }
              loading={loading}
              disabled={checking}
              onPress={isPremium || needsPaymentFix ? handleManage : handleSubscribe}
            />
            <Text style={styles.termsText}>
              {isPremium || needsPaymentFix
                ? 'No portal do Stripe você troca o cartão, vê suas faturas e cancela quando quiser.'
                : 'Cancelamento grátis a qualquer momento. Ao assinar, você concorda com nossos Termos de Uso e Política de Privacidade.'}
            </Text>
          </View>
          
        </ScrollView>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 24,
    // paddingBottom entra inline somando insets.bottom
  },
  introSection: {
    marginBottom: 32,
    alignItems: 'center',
  },
  title: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 24,
    color: theme.colors.textDark,
    textAlign: 'center',
    marginBottom: 12,
  },
  subtitle: {
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    color: theme.colors.textHint,
    textAlign: 'center',
    lineHeight: 22,
  },
  activeBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    backgroundColor: '#E8F6F0',
    borderRadius: 12,
    padding: 16,
    marginBottom: 24,
  },
  activeBannerText: {
    flex: 1,
  },
  activeBannerTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 15,
    color: '#0B7D57',
  },
  activeBannerSubtitle: {
    fontFamily: theme.fonts.regular,
    fontSize: 13,
    color: '#3B6B5B',
    marginTop: 2,
  },
  warningBanner: {
    backgroundColor: '#FFF6E6',
  },
  warningTitle: {
    color: '#B26A00',
  },
  warningSubtitle: {
    color: '#7A5210',
  },
  plansContainer: {
    gap: 16,
    marginBottom: 32,
  },
  planCard: {
    backgroundColor: theme.colors.white,
    borderRadius: 16,
    padding: 20,
    borderWidth: 2,
    borderColor: 'transparent',
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  planHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  planName: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    color: theme.colors.textDark,
  },
  planPrice: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 28,
    color: theme.colors.textDark,
  },
  planPeriod: {
    fontFamily: theme.fonts.regular,
    fontSize: 16,
    color: theme.colors.textHint,
  },
  trialText: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 13,
    color: '#00A86B',
    marginTop: 8,
  },
  planNote: {
    fontFamily: theme.fonts.regular,
    fontSize: 13,
    color: theme.colors.textHint,
    marginTop: 8,
    lineHeight: 19,
  },
  benefitsContainer: {
    backgroundColor: theme.colors.white,
    borderRadius: 16,
    padding: 24,
    marginBottom: 32,
  },
  benefitsTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    color: theme.colors.textDark,
    marginBottom: 16,
  },
  benefitRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  benefitText: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 15,
    color: theme.colors.textDark,
    marginLeft: 12,
    flex: 1,
  },
  actionContainer: {
    alignItems: 'center',
  },
  termsText: {
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    color: theme.colors.textHint,
    textAlign: 'center',
    marginTop: 16,
    lineHeight: 18,
    paddingHorizontal: 20,
  },
});
