import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
import { BottomTabBar } from '../components/BottomTabBar';
import { CurvedHeader, HEADER_MAX_HEIGHT } from '../components/CurvedHeader';
import { TermsModal } from '../components/TermsModal';
import { useProfileStore } from '../store/useProfileStore';
import { signOut } from '../services/auth';
import { showConfirm } from '../ui/dialog';

export function SettingsScreen({ navigation }: any) {
  const [modalVisible, setModalVisible] = useState(false);
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

  const menuItems = [
    { title: 'Editar Perfil', action: () => navigation.navigate('EditParentProfile') },
    { title: 'Crianças', action: () => navigation.navigate('ChildrenList') },
    { title: 'Meu plano', action: () => navigation.navigate('Plans') },
    { title: 'Histórico de atividades', action: () => navigation.navigate('ActivityHistory') },
    { title: 'Alterar senha', action: () => navigation.navigate('ChangePassword') },
    { title: 'Sair da conta', action: handleSignOut },
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
                <Text style={styles.profileName}>{parentName || 'Meu perfil'}</Text>
              </View>

              <View style={styles.menuContainer}>
                {menuItems.map((item, index) => (
                  <TouchableOpacity key={index} style={styles.menuItem} onPress={item.action}>
                    <Text style={styles.menuText}>{item.title}</Text>
                    <Ionicons name="chevron-forward" color={theme.colors.textLight} size={20} />
                  </TouchableOpacity>
                ))}
              </View>

              <TouchableOpacity onPress={() => setModalVisible(true)} style={styles.termsButton}>
                <Text style={styles.termsText}>Termos de Consentimento</Text>
              </TouchableOpacity>
            </View>
          </View>

          <View style={{ height: 120 }} />
        </View>
      </ScrollView>

      <TermsModal visible={modalVisible} onClose={() => setModalVisible(false)} />

      <BottomTabBar activeScreen="Settings" />
    </View>
  );
}

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
    fontWeight: '700',
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
  menuText: {
    fontFamily: theme.fonts.mulishSemiBold,
    fontSize: 16,
    color: '#424242'
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
