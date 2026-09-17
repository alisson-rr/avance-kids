import React, { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { theme } from '../theme';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { Button } from '../components/Button';
import { GhostButton } from '../components/GhostButton';
import { changePassword, saveRecoveredPassword, signOut } from '../services/auth';
import { errorMessage } from '../services/api';
import { showDialog, showError, showSuccess } from '../ui/dialog';
import { irParaLogin } from '../lib/navigation';

export function ChangePasswordScreen({ navigation, route }: any) {
  // Aberta pelo link "Esqueci a senha" (App.tsx): a sessão do link já comprova
  // o acesso ao e-mail, então não pede a senha atual.
  const recuperacao = route.params?.recuperacao === true;
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPasswordValue] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);

  // Sem salvar, a sessão do link não pode ficar aberta; sem rede, sai do mesmo jeito.
  const handleCancelar = () => {
    signOut()
      .catch((err) => console.warn('[auth] signOut falhou:', err))
      .finally(irParaLogin);
  };

  const handleSave = async () => {
    if ((!recuperacao && !currentPassword) || !newPassword || !confirmPassword) {
      showDialog({ title: 'Atenção', message: 'Preencha todos os campos.', variant: 'info' });
      return;
    }

    if (newPassword.length < 6) {
      showDialog({ title: 'Atenção', message: 'A nova senha deve ter pelo menos 6 caracteres.', variant: 'info' });
      return;
    }

    if (newPassword !== confirmPassword) {
      showDialog({ title: 'Atenção', message: 'A nova senha e a confirmação não conferem.', variant: 'info' });
      return;
    }

    setLoading(true);
    try {
      if (recuperacao) {
        // A saída da conta já leva para o Login (App.tsx).
        await saveRecoveredPassword(newPassword);
        showSuccess('Tudo certo!', 'Senha alterada. Entre com a nova senha.');
        return;
      }
      await changePassword(currentPassword, newPassword);
      showSuccess('Tudo certo!', 'Senha alterada com sucesso.', [
        { label: 'OK', onPress: () => navigation.goBack() },
      ]);
    } catch (err) {
      showError('Erro', errorMessage(err));
    } finally {
      setLoading(false);
    }
  };

  return (
    <FormScreen
      title={recuperacao ? undefined : 'Alterar Senha'}
      onBack={recuperacao ? undefined : () => navigation.goBack()}
    >
      {recuperacao && (
        <View style={styles.headerArea}>
          <Text style={styles.title}>Crie uma nova senha</Text>
          <Text style={styles.subtitle}>Digite a nova senha da sua conta.</Text>
        </View>
      )}

      <View style={styles.formArea}>
        {!recuperacao && (
          <SolidInput
            placeholder="Senha atual"
            value={currentPassword}
            onChangeText={setCurrentPassword}
            secureTextEntry
          />
        )}
        <SolidInput
          placeholder="Nova senha"
          value={newPassword}
          onChangeText={setNewPasswordValue}
          secureTextEntry
        />
        <SolidInput
          placeholder="Confirmar nova senha"
          value={confirmPassword}
          onChangeText={setConfirmPassword}
          secureTextEntry
        />
      </View>

      <View style={styles.actionGroup}>
        <Button
          title={recuperacao ? 'Salvar nova senha' : 'Salvar Alterações'}
          loading={loading}
          onPress={handleSave}
        />
        {recuperacao && <GhostButton title="Cancelar" onPress={handleCancelar} />}
      </View>
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  headerArea: { alignItems: 'center' },
  title: { fontFamily: theme.fonts.semiBold, fontSize: 24, color: '#333333', marginBottom: 8 },
  subtitle: { fontFamily: theme.fonts.regular, fontSize: 16, color: '#666666', textAlign: 'center', paddingHorizontal: 20 },
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 16 },
  actionGroup: { width: '100%', gap: 12 },
});
