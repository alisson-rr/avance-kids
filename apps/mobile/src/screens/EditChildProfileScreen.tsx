import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Alert } from 'react-native';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { PhotoPicker } from '../components/PhotoPicker';
import { useProfileStore } from '../store/useProfileStore';
import { maskDate, maskCpf } from '../utils/formatters';
import { GENDER_OPTIONS, DISORDER_OPTIONS } from '../constants/options';

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
    <FormScreen title="Editar Criança" onBack={() => navigation.goBack()}>
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
        <Button title={loading ? 'Salvando...' : 'Salvar'} onPress={handleSave} />
      </View>
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 32 },
  actionGroup: { width: '100%', gap: 12 },
});
