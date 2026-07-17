import React, { useState } from 'react';
import { StyleSheet, View, Text, SafeAreaView, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { theme } from '../theme';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { GhostButton } from '../components/GhostButton';
import { Checkbox } from '../components/Checkbox';
import { PhotoPicker } from '../components/PhotoPicker';

export function ParentRegisterScreen({ navigation }: any) {
  const [photoUri, setPhotoUri] = useState<string>();
  const [nome, setNome] = useState('');
  const [nascimento, setNascimento] = useState('');
  const [genero, setGenero] = useState('');
  const [cpf, setCpf] = useState('');
  const [telefone, setTelefone] = useState('');
  const [aceitouTermos, setAceitouTermos] = useState(false);

  const handleSave = () => {
    // Basic check
    if (!aceitouTermos) {
      alert('Você precisa aceitar os termos de consentimento.');
      return;
    }
    // Navigate to Child Register
    navigation.navigate('ChildRegister');
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView 
        style={styles.container} 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <ScrollView contentContainerStyle={styles.scrollContent} bounces={false}>
          
          <View style={styles.body}>
            <PhotoPicker imageUri={photoUri} onImageSelected={setPhotoUri} />
            
            <View style={styles.headerArea}>
              <Text style={styles.title}>Seu cadastro</Text>
              <Text style={styles.subtitle}>Cadastre-se gratuitamente e comece a trilha personalizada ainda hoje!</Text>
            </View>
            
            <View style={styles.formArea}>
              <SolidInput 
                placeholder="Nome completo" 
                value={nome}
                onChangeText={setNome}
              />
              <SolidInput 
                placeholder="Data de nascimento" 
                value={nascimento}
                onChangeText={setNascimento}
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
                onChangeText={setCpf}
                keyboardType="numeric"
              />
              <SolidInput 
                placeholder="Número de telefone" 
                value={telefone}
                onChangeText={setTelefone}
                keyboardType="phone-pad"
              />

              <View style={styles.termsContainer}>
                <Checkbox 
                  value={aceitouTermos} 
                  onValueChange={setAceitouTermos}
                  label={
                    <Text style={styles.termsLabelText}>
                      Concordo com os <Text style={styles.termsLink}>Termos de Consentimento.</Text>
                    </Text>
                  }
                />
              </View>
            </View>

            <View style={styles.actionGroup}>
              <Button title="Salvar" onPress={handleSave} />
              <GhostButton title="Cancelar" onPress={() => navigation.goBack()} />
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
  scrollContent: { flexGrow: 1 },
  body: { flex: 1, alignItems: 'center', paddingTop: 60, paddingHorizontal: 24, paddingBottom: 40 },
  headerArea: { alignItems: 'center', marginBottom: 32 },
  title: { fontFamily: theme.fonts.semiBold, fontSize: 24, color: '#333333', marginBottom: 8 },
  subtitle: { fontFamily: theme.fonts.regular, fontSize: 16, color: '#666666', textAlign: 'center', paddingHorizontal: 20 },
  formArea: { width: '100%', gap: 16, marginBottom: 32 },
  termsContainer: { marginTop: 8 },
  termsLabelText: { fontFamily: theme.fonts.regular, fontSize: 14, color: '#666666' },
  termsLink: { fontFamily: theme.fonts.semiBold, color: theme.colors.primary },
  actionGroup: { width: '100%', gap: 12 },
});
