import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { PhotoPicker } from '../components/PhotoPicker';
import { useProfileStore } from '../store/useProfileStore';
import { maskDate, maskCpf, maskPhone, toIsoDate, digitsOnly } from '../utils/formatters';
import { GENDER_OPTIONS } from '../constants/options';
import { updateProfile } from '../services/auth';
import { uploadAvatar } from '../services/storage';
import { errorMessage } from '../services/api';
import { showDialog, showError, showSuccess } from '../ui/dialog';

export function EditParentProfileScreen({ navigation }: any) {
  const { parentName, parentBirthDate, parentGender, parentCpf, parentPhone, parentAvatarUrl, setParentData } = useProfileStore();

  const [photoUri, setPhotoUri] = useState<string | undefined>(parentAvatarUrl || undefined);
  const [nome, setNome] = useState(parentName);
  const [nascimento, setNascimento] = useState(parentBirthDate);
  const [genero, setGenero] = useState(parentGender);
  const [cpf, setCpf] = useState(parentCpf ? maskCpf(parentCpf) : '');
  const [telefone, setTelefone] = useState(parentPhone ? maskPhone(parentPhone) : '');
  const [loading, setLoading] = useState(false);

  const handleSave = async () => {
    if (!nome.trim()) {
      showDialog({ title: 'Atenção', message: 'O nome é obrigatório.', variant: 'info' });
      return;
    }
    if (nascimento && !toIsoDate(nascimento)) {
      showDialog({ title: 'Atenção', message: 'Data de nascimento inválida. Use dd/mm/aaaa.', variant: 'info' });
      return;
    }

    setLoading(true);
    try {
      let avatarUrl = parentAvatarUrl;
      if (photoUri && photoUri !== parentAvatarUrl) {
        avatarUrl = await uploadAvatar(photoUri, 'parent');
      }

      const cpfDigits = digitsOnly(cpf);
      await updateProfile({
        nome: nome.trim(),
        data_nascimento: toIsoDate(nascimento),
        genero: genero || null,
        cpf: cpfDigits || null,
        telefone: digitsOnly(telefone) || null,
        avatar_url: avatarUrl || null,
      });
      setParentData({
        parentName: nome.trim(),
        parentBirthDate: nascimento,
        parentGender: genero,
        parentCpf: cpfDigits,
        parentPhone: digitsOnly(telefone),
        parentAvatarUrl: avatarUrl,
      });
      showSuccess('Tudo certo!', 'Perfil atualizado com sucesso.', [
        { label: 'OK', onPress: () => navigation.goBack() },
      ]);
    } catch (err) {
      showError('Erro ao salvar', errorMessage(err));
    } finally {
      setLoading(false);
    }
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
        <Button title="Salvar" loading={loading} onPress={handleSave} />
      </View>
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  formArea: { width: '100%', gap: 16, marginBottom: 32, marginTop: 32 },
  actionGroup: { width: '100%', gap: 12 },
});
