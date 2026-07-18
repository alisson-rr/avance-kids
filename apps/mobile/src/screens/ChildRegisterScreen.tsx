import React, { useState } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { theme } from '../theme';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { GhostButton } from '../components/GhostButton';
import { PhotoPicker } from '../components/PhotoPicker';
import { maskDate, maskCpf } from '../utils/formatters';
import { GENDER_OPTIONS, DISORDER_OPTIONS } from '../constants/options';

export function ChildRegisterScreen({ navigation }: any) {
  const [photoUri, setPhotoUri] = useState<string>();
  const [nome, setNome] = useState('');
  const [nascimento, setNascimento] = useState('');
  const [genero, setGenero] = useState('');
  const [cpf, setCpf] = useState('');
  const [transtornos, setTranstornos] = useState<string[]>([]);

  const handleSave = () => {
    // Navigate to onboarding flow after child registration
    navigation.navigate('Onboarding1');
  };

  return (
    <FormScreen>
      <PhotoPicker imageUri={photoUri} onImageSelected={setPhotoUri} />

      <View style={styles.headerArea}>
        <Text style={styles.title}>Cadastrar criança</Text>
        <Text style={styles.subtitle}>Preencha os campos para realizarmos uma avaliação totalmente personalizada.</Text>
      </View>

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
          options={GENDER_OPTIONS}
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
          options={DISORDER_OPTIONS}
          multiSelect
        />
      </View>

      <View style={styles.actionGroup}>
        <Button title="Salvar" onPress={handleSave} />
        <GhostButton title="Cancelar" onPress={() => navigation.goBack()} />
      </View>
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  headerArea: { alignItems: 'center', marginBottom: 32 },
  title: { fontFamily: theme.fonts.semiBold, fontSize: 24, color: '#333333', marginBottom: 8 },
  subtitle: { fontFamily: theme.fonts.regular, fontSize: 16, color: '#666666', textAlign: 'center', paddingHorizontal: 20 },
  formArea: { width: '100%', gap: 16, marginBottom: 32 },
  actionGroup: { width: '100%', gap: 12 },
});
