import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  Image,
  ImageSourcePropType,
  ImageStyle,
  TouchableOpacity,
  StatusBar,
  StyleProp,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient, LinearGradientProps } from 'expo-linear-gradient';
import { theme } from '../theme';

interface OnboardingLayoutProps {
  gradient: Pick<LinearGradientProps, 'colors' | 'start' | 'end'>;
  onBack?: () => void;
  greeting?: string;
  image: ImageSourcePropType;
  imageStyle: StyleProp<ImageStyle>;
  title: string;
  subtitle: string;
  buttonLabel: string;
  onButtonPress: () => void;
  bodyGap?: number;
  textGap?: number;
}

export function OnboardingLayout({
  gradient,
  onBack,
  greeting,
  image,
  imageStyle,
  title,
  subtitle,
  buttonLabel,
  onButtonPress,
  bodyGap = 24,
  textGap = 8,
}: OnboardingLayoutProps) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  return (
    <LinearGradient
      colors={gradient.colors}
      start={gradient.start}
      end={gradient.end}
      style={styles.gradient}
    >
      <View style={[styles.safeArea, { paddingTop: safeTop, paddingBottom: insets.bottom }]}>
        <StatusBar barStyle="dark-content" backgroundColor="transparent" translucent />

        {onBack && (
          <View style={styles.header}>
            <TouchableOpacity onPress={onBack} style={styles.backBtn}>
              <Text style={styles.chevron}>‹</Text>
            </TouchableOpacity>
          </View>
        )}
        {greeting && (
          <View style={styles.greetingRow}>
            <Text style={styles.greeting}>{greeting}</Text>
          </View>
        )}

        <View style={[styles.body, { gap: bodyGap }]}>
          <View style={styles.imageWrapper}>
            <Image source={image} style={imageStyle} resizeMode="contain" />
          </View>

          <View style={[styles.textBlock, { gap: textGap }]}>
            <Text style={styles.title}>{title}</Text>
            <Text style={styles.subtitle}>{subtitle}</Text>
          </View>
        </View>

        <View style={styles.buttonSection}>
          <TouchableOpacity
            style={styles.primaryButton}
            activeOpacity={0.85}
            onPress={onButtonPress}
          >
            <Text style={styles.primaryButtonText}>{buttonLabel}</Text>
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
  body: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  imageWrapper: {
    alignItems: 'center',
    width: '100%',
  },
  textBlock: {
    width: '100%',
    alignItems: 'center',
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
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 19,
    color: theme.colors.white,
  },
});
