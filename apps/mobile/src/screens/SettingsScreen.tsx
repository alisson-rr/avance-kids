import React, { useState } from 'react';
import { View, Text, TouchableOpacity, Modal, StyleSheet, ScrollView, Alert, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
import { BottomTabBar } from '../components/BottomTabBar';

const HEADER_MIN_HEIGHT = Platform.OS === 'ios' ? 110 : 90;
const HEADER_MAX_HEIGHT = 198;
const CURVE_TOP = HEADER_MIN_HEIGHT - 30;

export function SettingsScreen({ navigation }: any) {
  const [modalVisible, setModalVisible] = useState(false);

  const menuItems = [
    { title: 'Editar Perfil', action: () => navigation.navigate('EditParentProfile') },
    { title: 'Crianças', action: () => navigation.navigate('ChildrenList') },
    { title: 'Meu plano', action: () => navigation.navigate('Plans') },
    { title: 'Histórico de atividades', action: () => navigation.navigate('ActivityHistory') },
    { title: 'Alterar senha', action: () => navigation.navigate('ChangePassword') },
  ];

  return (
    <View style={styles.container}>
      
      {/* 1. Curved Background Extension (Behind ScrollView) */}
      <View style={styles.headerCurve} />

      {/* 2. Top Fixed Header */}
      <View style={styles.topFixedHeader}>
        <View style={styles.topBar}>
          <TouchableOpacity style={styles.iconButton} onPress={() => navigation.goBack()}>
            <Ionicons name="chevron-back" size={28} color={theme.colors.white} />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Meu perfil</Text>
          <View style={{ width: 44 }} />
        </View>
      </View>

      {/* 3. Main Scroll View */}
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
                  <Text style={styles.avatarText}>PA</Text>
                </View>
                <Text style={styles.profileName}>Pedro Almeida</Text>
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

      {/* Modal de Termos de Consentimento */}
      <Modal visible={modalVisible} animationType="slide" transparent>
        <View style={styles.modalContainer}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Termos de Consentimento</Text>
            <ScrollView style={styles.modalScrollView}>
              <Text style={styles.modalText}>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                {'\n\n'}
                Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
              </Text>
            </ScrollView>
            <TouchableOpacity onPress={() => setModalVisible(false)} style={styles.modalCloseButton}>
              <Text style={styles.modalCloseText}>Fechar</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      <BottomTabBar activeScreen="Settings" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { 
    flex: 1, 
    backgroundColor: '#FFFFFF',
  },
  headerCurve: {
    backgroundColor: '#3678FD',
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
    position: 'absolute',
    top: CURVE_TOP,
    height: HEADER_MAX_HEIGHT - CURVE_TOP,
    left: 0,
    right: 0,
    zIndex: 0,
    elevation: 0,
  },
  topFixedHeader: {
    backgroundColor: '#3678FD',
    height: HEADER_MIN_HEIGHT,
    borderBottomLeftRadius: 30,
    borderBottomRightRadius: 30,
    paddingTop: Platform.OS === 'ios' ? 50 : 30,
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 10,
    elevation: 10,
    justifyContent: 'center',
  },
  topBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 50,
    paddingHorizontal: 12,
  },
  iconButton: {
    padding: 8,
    width: 44,
    alignItems: 'center',
    zIndex: 20,
  },
  headerTitle: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 20,
    color: '#FFFFFF',
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
  modalContainer: { 
    flex: 1, 
    backgroundColor: 'rgba(0,0,0,0.5)', 
    justifyContent: 'center', 
    alignItems: 'center' 
  },
  modalContent: { 
    backgroundColor: theme.colors.white, 
    padding: 24, 
    borderRadius: 16, 
    width: '90%',
    maxHeight: '80%'
  },
  modalTitle: { 
    fontFamily: theme.fonts.mulishBold,
    fontSize: 18, 
    marginBottom: 15, 
    color: '#424242',
    textAlign: 'center'
  },
  modalScrollView: {
    maxHeight: 400,
  },
  modalText: { 
    fontFamily: theme.fonts.regular,
    color: '#5E5E5E', 
    lineHeight: 22,
    fontSize: 14,
  },
  modalCloseButton: { 
    marginTop: 20, 
    padding: 14, 
    backgroundColor: '#3678FD', 
    borderRadius: 50, 
    alignItems: 'center' 
  },
  modalCloseText: { 
    fontFamily: theme.fonts.mulishSemiBold,
    color: theme.colors.white, 
    fontSize: 16 
  }
});
