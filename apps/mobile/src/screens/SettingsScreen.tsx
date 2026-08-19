import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
import { BottomTabBar } from '../components/BottomTabBar';
import { CurvedHeader, HEADER_MAX_HEIGHT } from '../components/CurvedHeader';
import { TermsModal } from '../components/TermsModal';
import { useProfileStore } from '../store/useProfileStore';
import { deleteAccount, signOut } from '../services/auth';
import { errorMessage } from '../services/api';
import { showConfirm, showDialog, showError } from '../ui/dialog';

export function SettingsScreen({ navigation }: any) {
  const [modalVisible, setModalVisible] = useState(false);
  const [excluindo, setExcluindo] = useState(false);
  const { parentName, parentAvatarUrl } = useProfileStore();

  const initials = parentName
    .split(' ')
    .filter(Boolean)
    .map((part) => part[0])
    .slice(0, 2)
    .join('')
    .toUpperCase() || '?';

  const handleSignOut = () => {
    showConfirm('Sair da conta', 'Deseja realmente sair?', {
      label: 'Sair',
      kind: 'destructive',
      onPress: async () => {
        await signOut();
        navigation.reset({ index: 0, routes: [{ name: 'Login' }] });
      },
    });
  };

  const irParaLogin = () => navigation.reset({ index: 0, routes: [{ name: 'Login' }] });

  /**
   * Exclusão de conta em duas confirmações. A ação é irreversível e do lado do
   * servidor cancela a assinatura no Stripe e apaga tudo em cascata — um toque
   * só num item de menu é pouco para isso.
   */
  const handleDeleteAccount = () => {
    showDialog({
      title: 'Excluir minha conta',
      message:
        'Esta ação é permanente e não pode ser desfeita.\n\n' +
        'Serão apagados o seu perfil, os dados e o histórico de todas as crianças, ' +
        'as respostas da triagem e as fotos enviadas. Se houver assinatura ativa, ' +
        'ela será cancelada.\n\n' +
        'Os registros financeiros exigidos por lei são mantidos de forma anonimizada.',
      variant: 'error',
      buttons: [
        { label: 'Continuar', kind: 'destructive', onPress: confirmarExclusao },
        { label: 'Cancelar', kind: 'ghost' },
      ],
    });
  };

  const confirmarExclusao = () => {
    showConfirm(
      'Tem certeza?',
      'Não há como recuperar a conta depois. Para manter seus dados, use "Sair da conta".',
      {
        label: 'Excluir definitivamente',
        kind: 'destructive',
        onPress: async () => {
          setExcluindo(true);
          try {
            await deleteAccount();
            // A sessão local já foi limpa; o reset do store (App.tsx) roda no
            // onAuthStateChange e apaga a criança ativa do AsyncStorage.
            irParaLogin();
          } catch (err) {
            // A conta pode ter sido apagada parcialmente (a function é
            // idempotente e retoma de onde parou), então a mensagem convida a
            // tentar de novo em vez de sugerir que nada aconteceu.
            showError(
              'Não foi possível excluir a conta',
              `${errorMessage(err)}\n\nNada foi perdido: tente novamente em instantes.`,
            );
          } finally {
            setExcluindo(false);
          }
        },
      },
      'Voltar',
    );
  };

  const menuItems: {
    title: string;
    action: () => void;
    destructive?: boolean;
    icon?: keyof typeof Ionicons.glyphMap;
    disabled?: boolean;
  }[] = [
    { title: 'Editar Perfil', action: () => navigation.navigate('EditParentProfile') },
    { title: 'Crianças', action: () => navigation.navigate('ChildrenList') },
    { title: 'Meu plano', action: () => navigation.navigate('Plans') },
    { title: 'Histórico de atividades', action: () => navigation.navigate('ActivityHistory') },
    { title: 'Alterar senha', action: () => navigation.navigate('ChangePassword') },
    { title: 'Sair da conta', action: handleSignOut, destructive: true },
    {
      title: excluindo ? 'Excluindo conta…' : 'Excluir minha conta',
      action: handleDeleteAccount,
      destructive: true,
      icon: 'trash-outline',
      disabled: excluindo,
    },
  ];

  return (
    <View style={styles.container}>
      <CurvedHeader title="Meu perfil" onBack={() => navigation.goBack()} />

      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.scrollSpacer} />

        <View style={styles.scrollWhiteBody}>
          <View style={styles.mainCardWrapper}>
            <View style={styles.mainCard}>
              <View style={styles.avatarContainer}>
                <View style={styles.avatarPlaceholder}>
                  {parentAvatarUrl ? (
                    <Image source={{ uri: parentAvatarUrl }} style={styles.avatarImage} />
                  ) : (
                    <Text style={styles.avatarText}>{initials}</Text>
                  )}
                </View>
                <Text style={styles.profileName} numberOfLines={2}>{parentName || 'Meu perfil'}</Text>
              </View>

              <View style={styles.menuContainer}>
                {menuItems.map((item, index) => (
                  <TouchableOpacity
                    key={index}
                    style={[
                      styles.menuItem,
                      item.destructive && styles.menuItemDestructive,
                      item.disabled && styles.menuItemDisabled,
                    ]}
                    onPress={item.action}
                    disabled={item.disabled}
                    accessibilityRole="button"
                    accessibilityState={{ disabled: Boolean(item.disabled) }}
                  >
                    <Text style={[styles.menuText, item.destructive && styles.menuTextDestructive]}>
                      {item.title}
                    </Text>
                    {item.destructive ? (
                      <Ionicons name={item.icon ?? 'log-out-outline'} color={DESTRUCTIVE} size={20} />
                    ) : (
                      <Ionicons name="chevron-forward" color={theme.colors.textLight} size={20} />
                    )}
                  </TouchableOpacity>
                ))}
              </View>

              <TouchableOpacity onPress={() => setModalVisible(true)} style={styles.termsButton}>
                <Text style={styles.termsText}>Termos de Consentimento</Text>
              </TouchableOpacity>
            </View>
          </View>

          <View style={{ height: 24 }} />
        </View>
      </ScrollView>

      <TermsModal visible={modalVisible} onClose={() => setModalVisible(false)} />

      <BottomTabBar activeScreen="Settings" />
    </View>
  );
}

/** Sair da conta e uma acao destrutiva: nao pode ter o mesmo peso visual dos
 *  itens de navegacao. Mesmo tom do botao destrutivo do dialogo. */
const DESTRUCTIVE = '#C2244B';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  scrollView: {
    flex: 1,
    zIndex: 5,
    elevation: 5,
  },
  scrollSpacer: {
    height: HEADER_MAX_HEIGHT,
    backgroundColor: 'transparent',
  },
  scrollWhiteBody: {
    backgroundColor: '#FFFFFF',
    flex: 1,
  },
  mainCardWrapper: {
    alignItems: 'center',
    marginTop: -40,
  },
  mainCard: {
    backgroundColor: '#FFFFFF',
    width: 345,
    borderRadius: 12,
    paddingVertical: 20,
    paddingHorizontal: 20,
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 10,
    elevation: 4,
  },
  avatarContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  avatarPlaceholder: {
    width: 76,
    height: 76,
    borderRadius: 38,
    backgroundColor: '#EBF3FF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
    overflow: 'hidden',
  },
  avatarImage: {
    width: '100%',
    height: '100%',
  },
  avatarText: {
    fontFamily: theme.fonts.mulishBold,
    color: '#0E5DFD',
    fontSize: 24,
  },
  profileName: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 18,
    color: '#424242',
  },
  menuContainer: {
    marginTop: 10,
    width: '100%',
  },
  menuItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 18,
    borderBottomWidth: 1,
    borderBottomColor: '#EBEBEB'
  },
  menuItemDestructive: {
    borderBottomWidth: 0,
    marginTop: 8,
  },
  menuText: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 16,
    color: '#424242'
  },
  menuItemDisabled: {
    opacity: 0.5,
  },
  menuTextDestructive: {
    color: DESTRUCTIVE,
  },
  termsButton: {
    marginTop: 30,
    alignItems: 'center',
    paddingBottom: 10
  },
  termsText: {
    fontFamily: theme.fonts.mulishBold,
    color: '#3678FD',
    fontSize: 14
  },
});
