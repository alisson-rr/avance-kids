import React, { useState, useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { PhotoPicker } from '../components/PhotoPicker';
import { useProfileStore } from '../store/useProfileStore';
import { maskDate, maskCpf, toIsoDate, fromIsoDate, digitsOnly } from '../utils/formatters';
import { GENDER_OPTIONS, DISORDER_OPTIONS } from '../constants/options';
import { updateChild as updateChildRemote } from '../services/children';
import { uploadAvatar } from '../services/storage';
import { errorMessage } from '../services/api';
import { showDialog, showError, showSuccess } from '../ui/dialog';

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
      setNascimento(fromIsoDate(child.birthDate));
      setGenero(child.gender || '');
      setCpf(child.cpf ? maskCpf(child.cpf) : '');
      setTranstornos(child.disorders || []);
      setPhotoUri(child.avatarUrl || undefined);
    } else {
      showError('Erro', 'Criança não encontrada.', [
        { label: 'Voltar', onPress: () => navigation.goBack() },
      ]);
    }
  }, [child]);

  const handleSave = async () => {
    if (!nome.trim() || !nascimento.trim()) {
      showDialog({ title: 'Atenção', message: 'Preencha o nome e data de nascimento.', variant: 'info' });
      return;
    }

    const dataIso = toIsoDate(nascimento);
    if (!dataIso) {
      showDialog({ title: 'Atenção', message: 'Data de nascimento inválida. Use dd/mm/aaaa.', variant: 'info' });
      return;
    }

    setLoading(true);
    try {
      let avatarUrl = child?.avatarUrl ?? '';
      if (photoUri && photoUri !== child?.avatarUrl) {
        avatarUrl = await uploadAvatar(photoUri, `child-${childId}`);
      }

      const cpfDigits = digitsOnly(cpf);
      await updateChildRemote(childId, {
        nome: nome.trim(),
        data_nascimento: dataIso,
        genero: genero || null,
        cpf: cpfDigits || null,
        condicoes: transtornos.filter((t) => t !== 'Nenhum'),
        avatar_url: avatarUrl || null,
      });
      updateChild(childId, {
        name: nome.trim(),
        birthDate: dataIso,
        gender: genero,
        cpf: cpfDigits,
        disorders: transtornos,
        avatarUrl,
      });
      showSuccess('Tudo certo!', 'Perfil da criança atualizado.', [
        { label: 'OK', onPress: () => navigation.goBack() },
      ]);
    } catch (err) {
      showError('Erro ao salvar', errorMessage(err));
    } finally {
      setLoading(false);
    }
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
        <Button title="Salvar" loading={loading} onPress={handleSave} />
      </View>
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 32 },
  actionGroup: { width: '100%', gap: 12 },
});
