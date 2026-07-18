import React, { useState } from 'react';
import { StyleSheet, View, Alert } from 'react-native';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { PhotoPicker } from '../components/PhotoPicker';
import { useProfileStore } from '../store/useProfileStore';
import { maskDate, maskCpf, maskPhone } from '../utils/formatters';
import { GENDER_OPTIONS } from '../constants/options';

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
    <FormScreen title="Editar Perfil" onBack={() => navigation.goBack()}>
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
          options={GENDER_OPTIONS}
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
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 32 },
  actionGroup: { width: '100%', gap: 12 },
});
