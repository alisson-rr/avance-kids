import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
  Linking,
  AppState,
} from 'react-native';
import { Ionicons, Feather } from '@expo/vector-icons';
import { theme } from '../theme';
import { Button } from '../components/Button';
import { ScreenHeader } from '../components/ScreenHeader';
import {
  createBillingPortalSession,
  createCheckoutSession,
  fetchSubscription,
  isPremiumActive,
} from '../services/subscription';
import { errorMessage } from '../services/api';
import { fromIsoDate } from '../utils/formatters';
import { showError } from '../ui/dialog';
import type { SubscriptionRow } from '../types/db';

/** Releituras após voltar do checkout: o webhook do Stripe leva alguns segundos. */
const POLL_TRIES = 4;
const POLL_INTERVAL_MS = 2000;

export function PlansScreen({ navigation }: any) {
  const [selectedPlan, setSelectedPlan] = useState<'monthly' | 'annual'>('annual');
  const [loading, setLoading] = useState(false);
  const [subscription, setSubscription] = useState<SubscriptionRow | null>(null);
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
    }
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

  const handleSubscribe = () =>
    openStripe(() => createCheckoutSession(selectedPlan), 'Erro na assinatura');

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
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <ScreenHeader title="Meu Plano" onBack={() => navigation.goBack()} />

        <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
          
          <View style={styles.introSection}>
            <Text style={styles.title}>Desbloqueie todo o potencial do seu filho</Text>
            <Text style={styles.subtitle}>Escolha o plano ideal para acompanhar e estimular o desenvolvimento contínuo.</Text>
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
            {/* Plano Mensal */}
            <TouchableOpacity 
              style={[styles.planCard, selectedPlan === 'monthly' && styles.planCardActive]}
              activeOpacity={0.8}
              onPress={() => setSelectedPlan('monthly')}
            >
              <View style={styles.planHeader}>
                <Text style={styles.planName}>Mensal</Text>
                {selectedPlan === 'monthly' && (
                  <Ionicons name="checkmark-circle" size={24} color={theme.colors.primary} />
                )}
              </View>
              <Text style={styles.planPrice}>R$ 29,90<Text style={styles.planPeriod}>/mês</Text></Text>
            </TouchableOpacity>

            {/* Plano Anual */}
            <TouchableOpacity 
              style={[styles.planCard, selectedPlan === 'annual' && styles.planCardActive]}
              activeOpacity={0.8}
              onPress={() => setSelectedPlan('annual')}
            >
              <View style={styles.popularBadge}>
                <Text style={styles.popularBadgeText}>Mais vantajoso</Text>
              </View>
              <View style={styles.planHeader}>
                <Text style={styles.planName}>Anual</Text>
                {selectedPlan === 'annual' && (
                  <Ionicons name="checkmark-circle" size={24} color={theme.colors.primary} />
                )}
              </View>
              <Text style={styles.planPrice}>R$ 299,00<Text style={styles.planPeriod}>/ano</Text></Text>
              <Text style={styles.discountText}>Equivale a R$ 24,91/mês</Text>
            </TouchableOpacity>
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
                needsPaymentFix
                  ? 'Atualizar pagamento'
                  : isPremium
                    ? 'Gerenciar assinatura'
                    : 'Assinar agora'
              }
              loading={loading}
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
    paddingBottom: 40,
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
  planCardActive: {
    borderColor: theme.colors.primary,
    backgroundColor: '#F5F9FF',
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
  discountText: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 13,
    color: '#00A86B',
    marginTop: 8,
  },
  popularBadge: {
    position: 'absolute',
    top: -12,
    right: 20,
    backgroundColor: theme.colors.primary,
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
  },
  popularBadgeText: {
    fontFamily: theme.fonts.mulishBold,
    color: theme.colors.white,
    fontSize: 12,
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
