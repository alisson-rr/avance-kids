import React, { useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { theme } from '../theme';
import { FormScreen } from '../components/FormScreen';
import { Input } from '../components/Input';
import { Button } from '../components/Button';
import { GoogleButton } from '../components/GoogleButton';
import { Logo } from '../components/Logo';

export function LoginScreen({ navigation }: any) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  return (
    <FormScreen contentStyle={styles.body}>
      <Logo />

      <View style={styles.formArea}>
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
              icon="lock"
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

        <View style={styles.actionGroup}>
          <Button title="Acessar" onPress={() => navigation.navigate('Home')} />

          <View style={styles.dividerContainer}>
            <View style={styles.dividerLine} />
            <Text style={styles.dividerText}>OU</Text>
            <View style={styles.dividerLine} />
          </View>

          <GoogleButton onPress={() => console.log('Google Login')} />

          <View style={styles.registerContainer}>
            <Text style={styles.registerText}>
              Não possui uma conta? <Text style={styles.registerLink} onPress={() => navigation.navigate('ParentRegister')}>Cadastre-se</Text>
            </Text>
          </View>
        </View>
      </View>
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  body: { paddingTop: 100, gap: 42 },
  formArea: { width: '100%', alignItems: 'center', gap: 32 },
  topGroup: { width: '100%', gap: 12 },
  inputsGroup: { width: '100%', gap: 16 },
  forgotPasswordContainer: { width: '100%', alignItems: 'flex-end' },
  forgotPasswordText: { fontFamily: theme.fonts.semiBold, fontSize: 14, color: theme.colors.primary },
  actionGroup: { width: '100%', alignItems: 'center', gap: 16 },
  dividerContainer: { flexDirection: 'row', alignItems: 'center', width: '100%', justifyContent: 'center', gap: 9, paddingVertical: 8 },
  dividerLine: { height: 1, width: 143, backgroundColor: theme.colors.divider },
  dividerText: { fontFamily: theme.fonts.medium, fontSize: 14, color: '#727272' },
  registerContainer: { marginTop: 8 },
  registerText: { fontFamily: theme.fonts.regular, fontSize: 14, color: '#727272' },
  registerLink: { fontFamily: theme.fonts.semiBold, color: theme.colors.primary }
});
