import React, { useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { theme } from '../theme';
import { FormScreen } from '../components/FormScreen';
import { Input } from '../components/Input';
import { Button } from '../components/Button';
import { GoogleButton } from '../components/GoogleButton';
import { Logo } from '../components/Logo';
import { signIn, resetPassword } from '../services/auth';
import { errorMessage } from '../services/api';
import { showDialog, showError, showSuccess } from '../ui/dialog';
import { useProfileStore } from '../store/useProfileStore';

export function LoginScreen({ navigation }: any) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!email.trim() || !password) {
      showDialog({ title: 'Atenção', message: 'Informe seu e-mail e senha.', variant: 'info' });
      return;
    }
    setLoading(true);
    try {
      await signIn(email, password);
      await useProfileStore.getState().loadAll();
      navigation.reset({ index: 0, routes: [{ name: 'Home' }] });
    } catch (err) {
      showError('Erro ao entrar', errorMessage(err));
    } finally {
      setLoading(false);
    }
  };

  const handleForgotPassword = async () => {
    if (!email.trim()) {
      showDialog({
        title: 'Recuperar senha',
        message: 'Digite seu e-mail no campo acima e toque novamente em "Esqueci a senha".',
        variant: 'info',
      });
      return;
    }
    try {
      await resetPassword(email);
      showSuccess('E-mail enviado', `Enviamos um link de recuperação para ${email.trim()}.`);
    } catch (err) {
      showError('Erro', errorMessage(err));
    }
  };

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

          <TouchableOpacity style={styles.forgotPasswordContainer} onPress={handleForgotPassword}>
            <Text style={styles.forgotPasswordText}>Esqueci a senha</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.actionGroup}>
          <Button title="Acessar" loading={loading} onPress={handleLogin} />

          <View style={styles.dividerContainer}>
            <View style={styles.dividerLine} />
            <Text style={styles.dividerText}>OU</Text>
            <View style={styles.dividerLine} />
          </View>

          <GoogleButton
            onPress={() =>
              showDialog({
                title: 'Em breve',
                message: 'O login com Google estará disponível em breve.',
                variant: 'info',
              })
            }
          />

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
