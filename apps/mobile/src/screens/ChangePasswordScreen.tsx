import React, { useState } from 'react';
import { StyleSheet, View, Text, SafeAreaView, KeyboardAvoidingView, Platform, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
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
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView 
        style={styles.container} 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
            <Ionicons name="chevron-back" size={28} color={theme.colors.textDark} />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Alterar Senha</Text>
          <View style={{ width: 44 }} />
        </View>

        <ScrollView contentContainerStyle={styles.scrollContent} bounces={false}>
          <View style={styles.body}>
            
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
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: theme.colors.background },
  container: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: Platform.OS === 'ios' ? 10 : 20,
    paddingHorizontal: 20,
    paddingBottom: 20,
    backgroundColor: theme.colors.background,
  },
  backButton: {
    width: 44,
    height: 44,
    justifyContent: 'center',
  },
  headerTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18,
    color: theme.colors.textDark,
  },
  scrollContent: { flexGrow: 1 },
  body: { flex: 1, alignItems: 'center', paddingTop: 20, paddingHorizontal: 24, paddingBottom: 40 },
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 16 },
  actionGroup: { width: '100%', gap: 12 },
});
