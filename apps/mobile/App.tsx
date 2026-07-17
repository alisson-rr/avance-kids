import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Text, SafeAreaView, TouchableOpacity, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { useFonts, Inter_400Regular, Inter_500Medium, Inter_600SemiBold } from '@expo-google-fonts/inter';
import * as SplashScreen from 'expo-splash-screen';

import { theme } from './src/theme';
import { Input } from './src/components/Input';
import { Button } from './src/components/Button';
import { GoogleButton } from './src/components/GoogleButton';
import { Logo } from './src/components/Logo';

// Keep the splash screen visible while we fetch resources
SplashScreen.preventAutoHideAsync();

export default function App() {
  const [fontsLoaded] = useFonts({
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
  });

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded]);

  if (!fontsLoaded) {
    return null;
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView 
        style={styles.container} 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <ScrollView contentContainerStyle={styles.scrollContent} bounces={false}>
          
          <View style={styles.body}>
            {/* Logo */}
            <Logo />
            
            {/* Main Form Area */}
            <View style={styles.formArea}>
              
              {/* Inputs and Forgot Password */}
              <View style={styles.topGroup}>
                <View style={styles.inputsGroup}>
                  <Input 
                    icon="mail" 
                    placeholder="Digite seu e-mail" 
                    value={email}
                    onChangeText={setEmail}
                    keyboardType="email-address"
                    autoCapitalize="none"
                  />
                  <Input 
                    icon="lock" // Using lock instead of mail for password
                    placeholder="Digite sua senha" 
                    value={password}
                    onChangeText={setPassword}
                    secureTextEntry
                  />
                </View>
                
                <TouchableOpacity style={styles.forgotPasswordContainer}>
                  <Text style={styles.forgotPasswordText}>Esqueci a senha</Text>
                </TouchableOpacity>
              </View>

              {/* Actions */}
              <View style={styles.actionGroup}>
                <Button title="Acessar" onPress={() => console.log('Login')} />
                
                {/* Divider */}
                <View style={styles.dividerContainer}>
                  <View style={styles.dividerLine} />
                  <Text style={styles.dividerText}>OU</Text>
                  <View style={styles.dividerLine} />
                </View>

                {/* Google Auth */}
                <GoogleButton onPress={() => console.log('Google Login')} />

                {/* Register Link */}
                <View style={styles.registerContainer}>
                  <Text style={styles.registerText}>
                    Não possui uma conta? <Text style={styles.registerLink}>Cadastre-se</Text>
                  </Text>
                </View>
              </View>

            </View>
          </View>

        </ScrollView>
      </KeyboardAvoidingView>
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
    flexGrow: 1,
  },
  body: {
    flex: 1,
    alignItems: 'center',
    paddingTop: 100, // Based on Figma CSS: padding: 100px 24px 40px
    paddingHorizontal: 24,
    paddingBottom: 40,
    gap: 42,
  },
  formArea: {
    width: '100%',
    alignItems: 'center',
    gap: 32,
  },
  topGroup: {
    width: '100%',
    gap: 12, // Gap between inputs group and forgot password
  },
  inputsGroup: {
    width: '100%',
    gap: 16, // Gap between inputs
  },
  forgotPasswordContainer: {
    width: '100%',
    alignItems: 'flex-end',
  },
  forgotPasswordText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 14,
    color: theme.colors.primary,
  },
  actionGroup: {
    width: '100%',
    alignItems: 'center',
    gap: 16,
  },
  dividerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    width: '100%',
    justifyContent: 'center',
    gap: 9,
    paddingVertical: 8,
  },
  dividerLine: {
    height: 1,
    width: 143,
    backgroundColor: theme.colors.divider,
  },
  dividerText: {
    fontFamily: theme.fonts.medium,
    fontSize: 14,
    color: '#727272', // Black/400
  },
  registerContainer: {
    marginTop: 8,
  },
  registerText: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    color: '#727272', // Black/400
  },
  registerLink: {
    fontFamily: theme.fonts.semiBold,
    color: theme.colors.primary,
  }
});
