import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  Image,
  SafeAreaView,
  TouchableOpacity,
  Dimensions,
  StatusBar,
  Platform,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { theme } from '../theme';

const { width } = Dimensions.get('window');

// Mock — em produção vem do contexto de autenticação
const MOCK_USER_NAME = 'Alisson';

export function Onboarding1Screen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  return (
    <LinearGradient
      // Figma: linear-gradient(198.82deg, #B2CCFF -44.6%, #FFFFFF 59.3%)
      colors={['#B2CCFF', '#FFFFFF']}
      start={{ x: 0.3, y: 0 }}
      end={{ x: 0.7, y: 1 }}
      style={styles.gradient}
    >
      <View style={[styles.safeArea, { paddingTop: safeTop, paddingBottom: insets.bottom }]}>
        <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />

        {/* ── HEADER: seta em cima, saudação embaixo ── */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
            <Text style={styles.chevron}>‹</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.greetingRow}>
          <Text style={styles.greeting}>Olá, {MOCK_USER_NAME}!</Text>
        </View>

        {/* ── BODY ── */}
        <View style={styles.body}>

          {/* iPhone 13 illustration */}
          <View style={styles.imageWrapper}>
            <Image
              source={require('../../assets/onboarding1.png')}
              style={styles.image}
              resizeMode="contain"
            />
          </View>

          {/* Title + subtitle */}
          <View style={styles.textBlock}>
            <View style={styles.titleContainer}>
              <Text style={styles.title}>
                Primeiro, vamos conhecer o momento da criança
              </Text>
            </View>
            <Text style={styles.subtitle}>
              Vamos fazer algumas perguntas gerais para entender melhor a criança e montar atividades que ajudem no desenvolvimento.
            </Text>
          </View>
        </View>

        {/* ── BUTTON SECTION ── */}
        <View style={styles.buttonSection}>
          <TouchableOpacity
            style={styles.primaryButton}
            activeOpacity={0.85}
            onPress={() => navigation.navigate('Perguntas')}
          >
            <Text style={styles.primaryButtonText}>Começar</Text>
          </TouchableOpacity>
        </View>
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  gradient: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
    backgroundColor: 'transparent',
  },

  // ── HEADER ──────────────────────────────────────────────────────
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 4,
  },
  backBtn: {
    padding: 4,
    alignItems: 'center',
    justifyContent: 'center',
  },
  chevron: {
    fontSize: 30,
    color: '#000000',
    lineHeight: 34,
  },
  greetingRow: {
    paddingHorizontal: 24,
    paddingTop: 8,
    paddingBottom: 4,
  },
  greeting: {
    fontFamily: theme.fonts.mulishExtraBold,
    fontSize: 24,
    lineHeight: 29,
    color: '#000000',
  },

  // ── BODY ────────────────────────────────────────────────────────
  body: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
    gap: 24,
  },
  imageWrapper: {
    alignItems: 'center',
    width: '100%',
  },
  image: {
    // Figma: width 273px, height 404.5px
    width: 273,
    height: 404,
  },
  textBlock: {
    width: '100%',
    alignItems: 'center',
    gap: 8,
  },
  titleContainer: {
    alignItems: 'center',
    width: '100%',
  },
  title: {
    // Figma: Mulish 800, 24px, line-height 30px, centered, #424242
    fontFamily: theme.fonts.mulishExtraBold,
    fontSize: 24,
    lineHeight: 30,
    textAlign: 'center',
    color: '#424242',
  },
  subtitle: {
    // Figma: Mulish 400, 14px, line-height 18px, centered, #424242
    fontFamily: theme.fonts.mulishRegular,
    fontSize: 14,
    lineHeight: 18,
    textAlign: 'center',
    color: '#424242',
    width: '100%',
  },

  // ── BUTTON SECTION ──────────────────────────────────────────────
  buttonSection: {
    paddingHorizontal: 24,
    paddingTop: 16,
    paddingBottom: 40,
    alignItems: 'center',
  },
  primaryButton: {
    // Figma: height 48px, border-radius 50px, bg #0E5DFD, padding 16px 24px
    width: '100%',
    height: 48,
    backgroundColor: theme.colors.primary,
    borderRadius: 50,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingVertical: 16,
  },
  primaryButtonText: {
    // Figma: Inter 600, 16px, line-height 19px, white
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 19,
    color: theme.colors.white,
  },
});
