import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Text, SafeAreaView, KeyboardAvoidingView, Platform, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { PhotoPicker } from '../components/PhotoPicker';
import { useProfileStore } from '../store/useProfileStore';
import { maskDate, maskCpf } from '../utils/formatters';

export function EditChildProfileScreen({ navigation, route }: any) {
  const { childId } = route.params || {};
  const { children, updateChild } = useProfileStore();
  
  const child = children.find(c => c.id === childId);

  const [photoUri, setPhotoUri] = useState<string>();
  const [nome, setNome] = useState('');
  const [nascimento, setNascimento] = useState('');
  const [genero, setGenero] = useState('');
  const [cpf, setCpf] = useState('');
  const [transtornos, setTranstornos] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (child) {
      setNome(child.name);
      setNascimento(child.birthDate);
      setGenero(child.gender || '');
      setCpf(child.cpf || '');
      setTranstornos(child.disorders || []);
    } else {
      Alert.alert('Erro', 'Criança não encontrada.', [
        { text: 'Voltar', onPress: () => navigation.goBack() }
      ]);
    }
  }, [child]);

  const handleSave = () => {
    if (!nome.trim() || !nascimento.trim()) {
      Alert.alert('Erro', 'Preencha o nome e data de nascimento.');
      return;
    }
    
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(nascimento)) {
      Alert.alert('Erro', 'Formato de data inválido. Use YYYY-MM-DD.');
      return;
    }
    
    setLoading(true);
    // Simulating API call
    setTimeout(() => {
      updateChild(childId, {
        name: nome,
        birthDate: nascimento,
        gender: genero,
        cpf,
        disorders: transtornos
      });
      setLoading(false);
      Alert.alert('Sucesso', 'Perfil da criança atualizado!', [
        { text: 'OK', onPress: () => navigation.goBack() }
      ]);
    }, 500);
  };

  if (!child) return null;

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
          <Text style={styles.headerTitle}>Editar Criança</Text>
          <View style={{ width: 44 }} />
        </View>

        <ScrollView contentContainerStyle={styles.scrollContent} bounces={false}>
          <View style={styles.body}>
            <PhotoPicker imageUri={photoUri} onImageSelected={setPhotoUri} />
            
            <View style={styles.formArea}>
              <SolidInput 
                placeholder="Nome" 
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
                placeholder="Gênero" 
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
              <BottomSheetSelect 
                placeholder="Outros transtornos" 
                value={transtornos}
                onChange={setTranstornos}
                options={['TDAH', 'TEA (Autismo)', 'Dislexia', 'Ansiedade', 'Depressão', 'TOD', 'Nenhum']}
                multiSelect
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
