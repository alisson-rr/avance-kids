import React, { useState } from 'react';
import { StyleSheet, View, Alert } from 'react-native';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { Button } from '../components/Button';

export function ChangePasswordScreen({ navigation }: any) {
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSave = () => {
    if (!currentPassword || !newPassword || !confirmPassword) {
      Alert.alert('Erro', 'Preencha todos os campos.');
      return;
    }

    if (newPassword !== confirmPassword) {
      Alert.alert('Erro', 'A nova senha e a confirmação não conferem.');
      return;
    }

    setLoading(true);
    // Simulating API call
    setTimeout(() => {
      setLoading(false);
      Alert.alert('Sucesso', 'Senha alterada com sucesso!', [
        { text: 'OK', onPress: () => navigation.goBack() }
      ]);
    }, 500);
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
        <Button title={loading ? 'Salvando...' : 'Salvar Alterações'} onPress={handleSave} />
      </View>
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 16 },
  actionGroup: { width: '100%', gap: 12 },
});
