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

export function Onboarding2Screen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  return (
    <LinearGradient
      // Mesmo fundo do Onboarding 1
      colors={['#B2CCFF', '#FFFFFF']}
      start={{ x: 0.3, y: 0 }}
      end={{ x: 0.7, y: 1 }}
      style={styles.gradient}
    >
      <View style={[styles.safeArea, { paddingTop: safeTop, paddingBottom: insets.bottom }]}>
        <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />

        {/* ── HEADER: só a seta de voltar (igual ao Onboarding 1) ── */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
            <Text style={styles.chevron}>‹</Text>
          </TouchableOpacity>
        </View>

        {/* ── BODY ── */}
        <View style={styles.body}>

          {/* Illustration */}
          <View style={styles.imageWrapper}>
            <Image
              source={require('../../assets/onboarding2.png')}
              style={styles.image}
              resizeMode="contain"
            />
          </View>

          {/* Title + subtitle */}
          <View style={styles.textBlock}>
            <View style={styles.titleContainer}>
              <Text style={styles.title}>
                Agora, vamos entender as habilidades específicas
              </Text>
            </View>
            <Text style={styles.subtitle}>
              Assim, com base nas respostas, vamos criar um plano de atividades personalizado para sua criança!
            </Text>
          </View>
        </View>

        {/* ── BUTTON SECTION ── */}
        <View style={styles.buttonSection}>
          <TouchableOpacity
            style={styles.primaryButton}
            activeOpacity={0.85}
            onPress={() => navigation.navigate('Triagem')}
          >
            <Text style={styles.primaryButtonText}>Continuar</Text>
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
    fontFamily: theme.fonts.mulishExtraBold,
    fontSize: 24,
    lineHeight: 30,
    textAlign: 'center',
    color: '#424242',
  },
  subtitle: {
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
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 19,
    color: theme.colors.white,
  },
});
