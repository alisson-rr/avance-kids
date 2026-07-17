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
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { theme } from '../theme';

const { width } = Dimensions.get('window');

export function Onboarding3Screen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  return (
    <LinearGradient
      colors={['#EBF3FF', '#FFFFFF']}
      start={{ x: 0.5, y: 0 }}
      end={{ x: 0.5, y: 1 }}
      style={styles.gradient}
    >
      <View style={[styles.safeArea, { paddingTop: safeTop, paddingBottom: insets.bottom }]}>
        <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />

        {/* ── BODY ── */}
        <View style={styles.body}>

          {/* Illustration */}
          <View style={styles.imageWrapper}>
            <Image
              source={require('../../assets/onboarding3.png')}
              style={styles.image}
              resizeMode="contain"
            />
          </View>

          {/* Title + subtitle */}
          <View style={styles.textBlock}>
            <View style={styles.titleContainer}>
              <Text style={styles.title}>
                Oba, agora o plano de atividades está pronto!
              </Text>
            </View>
            <Text style={styles.subtitle}>
              Com base nas suas respostas, criamos um plano de atividades personalizado para sua criança!
            </Text>
          </View>
        </View>

        {/* ── BUTTON SECTION ── */}
        <View style={styles.buttonSection}>
          <TouchableOpacity
            style={styles.primaryButton}
            activeOpacity={0.85}
            onPress={() => navigation.navigate('Home')}
          >
            <Text style={styles.primaryButtonText}>Ver atividades personalizadas</Text>
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

  // ── BODY ────────────────────────────────────────────────────────
  body: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
    gap: 40, // More spacing to balance the missing back button
  },
  imageWrapper: {
    alignItems: 'center',
    width: '100%',
  },
  image: {
    width: 320,
    height: 320,
  },
  textBlock: {
    width: '100%',
    alignItems: 'center',
    gap: 12,
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
