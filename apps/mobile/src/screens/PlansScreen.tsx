import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, SafeAreaView, Linking } from 'react-native';
import { Ionicons, Feather } from '@expo/vector-icons';
import { theme } from '../theme';
import { Button } from '../components/Button';
import { ScreenHeader } from '../components/ScreenHeader';
import { createCheckoutSession, fetchSubscription } from '../services/subscription';
import { errorMessage } from '../services/api';
import { showDialog, showError } from '../ui/dialog';

export function PlansScreen({ navigation }: any) {
  const [selectedPlan, setSelectedPlan] = useState<'monthly' | 'annual'>('annual');
  const [loading, setLoading] = useState(false);
  const [isPremium, setIsPremium] = useState(false);

  useEffect(() => {
    fetchSubscription()
      .then((sub) => {
        setIsPremium(sub?.plano === 'premium' && ['active', 'trialing'].includes(sub.status));
      })
      .catch(() => {});
  }, []);

  const handleSubscribe = async () => {
    if (isPremium) {
      showDialog({
        title: 'Assinatura ativa',
        message: 'Você já é assinante premium. Obrigado!',
        variant: 'success',
      });
      return;
    }
    setLoading(true);
    try {
      const url = await createCheckoutSession(selectedPlan);
      const supported = await Linking.canOpenURL(url);
      if (!supported) throw new Error('Não foi possível abrir a página de pagamento.');
      await Linking.openURL(url);
    } catch (err) {
      showError('Erro na assinatura', errorMessage(err));
    } finally {
      setLoading(false);
    }
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
              title={isPremium ? 'Assinatura ativa' : 'Assinar agora'}
              loading={loading}
              onPress={handleSubscribe}
            />
            <Text style={styles.termsText}>
              Cancelamento grátis a qualquer momento. Ao assinar, você concorda com nossos Termos de Uso e Política de Privacidade.
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
