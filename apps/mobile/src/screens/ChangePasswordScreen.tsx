import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { Button } from '../components/Button';
import { changePassword } from '../services/auth';
import { errorMessage } from '../services/api';
import { showDialog, showError, showSuccess } from '../ui/dialog';

export function ChangePasswordScreen({ navigation }: any) {
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSave = async () => {
    if (!currentPassword || !newPassword || !confirmPassword) {
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
    <FormScreen title="Alterar Senha" onBack={() => navigation.goBack()}>
      <View style={styles.formArea}>
        <SolidInput
          placeholder="Senha atual"
          value={currentPassword}
          onChangeText={setCurrentPassword}
          secureTextEntry
        />
        <SolidInput
          placeholder="Nova senha"
          value={newPassword}
          onChangeText={setNewPassword}
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
        <Button title="Salvar Alterações" loading={loading} onPress={handleSave} />
      </View>
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 16 },
  actionGroup: { width: '100%', gap: 12 },
});
