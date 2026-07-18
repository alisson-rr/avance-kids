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
import { maskDate, maskCpf, maskPhone } from '../utils/formatters';
import { GENDER_OPTIONS } from '../constants/options';

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
