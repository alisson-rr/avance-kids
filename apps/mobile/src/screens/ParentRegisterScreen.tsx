import React, { useState } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { theme } from '../theme';
import { FormScreen } from '../components/FormScreen';
import { SolidInput } from '../components/SolidInput';
import { BottomSheetSelect } from '../components/BottomSheetSelect';
import { Button } from '../components/Button';
import { GhostButton } from '../components/GhostButton';
import { Checkbox } from '../components/Checkbox';
import { PhotoPicker } from '../components/PhotoPicker';
import { TermsModal } from '../components/TermsModal';
import { maskDate, maskCpf, maskPhone, toIsoDate, digitsOnly } from '../utils/formatters';
import { GENDER_OPTIONS } from '../constants/options';
import { signUpParent, updateProfile } from '../services/auth';
import { uploadAvatar } from '../services/storage';
import { errorMessage } from '../services/api';
import { showDialog, showError, showSuccess } from '../ui/dialog';
import { useProfileStore } from '../store/useProfileStore';

export function ParentRegisterScreen({ navigation }: any) {
  const [photoUri, setPhotoUri] = useState<string>();
  const [nome, setNome] = useState('');
  const [email, setEmail] = useState('');
  const [nascimento, setNascimento] = useState('');
  const [genero, setGenero] = useState('');
  const [cpf, setCpf] = useState('');
  const [telefone, setTelefone] = useState('');
  const [senha, setSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');
  const [aceitouTermos, setAceitouTermos] = useState(false);
  const [termsVisible, setTermsVisible] = useState(false);
  const [loading, setLoading] = useState(false);

  const validate = (): string | null => {
    if (nome.trim().length < 2) return 'Informe seu nome completo.';
    if (!/^\S+@\S+\.\S+$/.test(email.trim())) return 'Informe um e-mail válido.';
    if (!toIsoDate(nascimento)) return 'Data de nascimento inválida. Use dd/mm/aaaa.';
    if (digitsOnly(cpf).length !== 11) return 'CPF inválido.';
    if (senha.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
    if (senha !== confirmarSenha) return 'A senha e a confirmação não conferem.';
    if (!aceitouTermos) return 'Você precisa aceitar os termos de consentimento.';
    return null;
  };

  const handleSave = async () => {
    const validationError = validate();
    if (validationError) {
      showDialog({ title: 'Atenção', message: validationError, variant: 'info' });
      return;
    }

    setLoading(true);
    try {
      const { needsEmailConfirmation } = await signUpParent({
        nome,
        email,
        senha,
        nascimento,
        genero,
        cpf,
        telefone,
      });

      if (needsEmailConfirmation) {
        showSuccess(
          'Confirme seu e-mail',
          `Enviamos um link de confirmação para ${email.trim()}. Depois de confirmar, faça login.`,
          [{ label: 'OK', onPress: () => navigation.reset({ index: 0, routes: [{ name: 'Login' }] }) }],
        );
        return;
      }

      if (photoUri) {
        try {
          const avatarUrl = await uploadAvatar(photoUri, 'parent');
          await updateProfile({ avatar_url: avatarUrl });
        } catch (uploadErr) {
          console.warn('[avatar] upload falhou:', uploadErr);
        }
      }

      await useProfileStore.getState().loadAll();
      navigation.navigate('ChildRegister');
    } catch (err) {
      showError('Erro no cadastro', errorMessage(err));
    } finally {
      setLoading(false);
    }
  };

  return (
    <FormScreen>
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
          placeholder="E-mail"
          value={email}
          onChangeText={setEmail}
          keyboardType="email-address"
          autoCapitalize="none"
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
        <SolidInput
          placeholder="Senha"
          value={senha}
          onChangeText={setSenha}
          secureTextEntry
        />
        <SolidInput
          placeholder="Confirmar senha"
          value={confirmarSenha}
          onChangeText={setConfirmarSenha}
          secureTextEntry
        />

        <View style={styles.termsContainer}>
          <Checkbox
            value={aceitouTermos}
            onValueChange={setAceitouTermos}
            label={
              <Text style={styles.termsLabelText}>
                Concordo com os{' '}
                <Text style={styles.termsLink} onPress={() => setTermsVisible(true)}>
                  Termos de Consentimento.
                </Text>
              </Text>
            }
          />
        </View>
      </View>

      <View style={styles.actionGroup}>
        <Button title="Salvar" loading={loading} onPress={handleSave} />
        <GhostButton title="Cancelar" onPress={() => navigation.goBack()} />
      </View>

      <TermsModal visible={termsVisible} onClose={() => setTermsVisible(false)} />
    </FormScreen>
  );
}

const styles = StyleSheet.create({
  headerArea: { alignItems: 'center', marginBottom: 32 },
  title: { fontFamily: theme.fonts.semiBold, fontSize: 24, color: '#333333', marginBottom: 8 },
  subtitle: { fontFamily: theme.fonts.regular, fontSize: 16, color: '#666666', textAlign: 'center', paddingHorizontal: 20 },
  formArea: { width: '100%', gap: 16, marginBottom: 32 },
  termsContainer: { marginTop: 8 },
  termsLabelText: { fontFamily: theme.fonts.regular, fontSize: 14, color: '#666666' },
  termsLink: { fontFamily: theme.fonts.semiBold, color: theme.colors.primary },
  actionGroup: { width: '100%', gap: 12 },
});
