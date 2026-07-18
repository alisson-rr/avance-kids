import React, { useState } from 'react';
import { StyleSheet, View, Text, SafeAreaView, KeyboardAvoidingView, Platform, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { PhotoPicker } from '../components/PhotoPicker';
import { useProfileStore } from '../store/useProfileStore';
import { maskDate, maskCpf, maskPhone } from '../utils/formatters';

export function EditParentProfileScreen({ navigation }: any) {
  const { parentName, parentBirthDate, parentGender, parentCpf, parentPhone, setParentData } = useProfileStore();
  
  const [photoUri, setPhotoUri] = useState<string>();
  const [nome, setNome] = useState(parentName);
  const [nascimento, setNascimento] = useState(parentBirthDate);
  const [genero, setGenero] = useState(parentGender);
  const [cpf, setCpf] = useState(parentCpf);
  const [telefone, setTelefone] = useState(parentPhone);
  const [loading, setLoading] = useState(false);

  const handleSave = () => {
    if (!nome.trim()) {
      Alert.alert('Erro', 'O nome é obrigatório.');
      return;
    }
    
    setLoading(true);
    // Simulating API call
    setTimeout(() => {
      setParentData({
        parentName: nome,
        parentBirthDate: nascimento,
        parentGender: genero,
        parentCpf: cpf,
        parentPhone: telefone
      });
      setLoading(false);
      Alert.alert('Sucesso', 'Perfil atualizado com sucesso!', [
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
          <Text style={styles.headerTitle}>Editar Perfil</Text>
          <View style={{ width: 44 }} />
        </View>

        <ScrollView contentContainerStyle={styles.scrollContent} bounces={false}>
          <View style={styles.body}>
            <PhotoPicker imageUri={photoUri} onImageSelected={setPhotoUri} />
            
            <View style={styles.formArea}>
              <SolidInput 
                placeholder="Nome completo" 
                value={nome}
                onChangeText={setNome}
              />
              <SolidInput 
                placeholder="Data de nascimento" 
                value={nascimento}
                onChangeText={(t) => setNascimento(maskDate(t))}
                keyboardType="numeric"
                maxLength={10}
              />
              <BottomSheetSelect 
                placeholder="Gênero (opcional)" 
                value={genero}
                onChange={setGenero}
                options={['Masculino', 'Feminino', 'Outro', 'Prefiro não informar']}
              />
              <SolidInput 
                placeholder="CPF" 
                value={cpf}
                onChangeText={(t) => setCpf(maskCpf(t))}
                keyboardType="numeric"
                maxLength={14}
              />
              <SolidInput 
                placeholder="Número de telefone" 
                value={telefone}
                onChangeText={(t) => setTelefone(maskPhone(t))}
                keyboardType="phone-pad"
                maxLength={15}
              />
            </View>

            <View style={styles.actionGroup}>
              <Button title={loading ? 'Salvando...' : 'Salvar'} onPress={handleSave} />
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
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 32 },
  actionGroup: { width: '100%', gap: 12 },
});
