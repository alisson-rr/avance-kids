import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Platform, FlatList } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
import { useProfileStore, Child } from '../store/useProfileStore';

const HEADER_MIN_HEIGHT = Platform.OS === 'ios' ? 110 : 90;
const HEADER_MAX_HEIGHT = 198;
const CURVE_TOP = HEADER_MIN_HEIGHT - 30;

export function ChildrenListScreen({ navigation }: any) {
  const { children, setActiveChild } = useProfileStore();

  const handleEdit = (child: Child) => {
    navigation.navigate('EditChildProfile', { childId: child.id });
  };

  const renderItem = ({ item }: { item: Child }) => (
    <TouchableOpacity 
      style={[styles.card, item.isActive && styles.cardActive]}
      activeOpacity={0.8}
      onPress={() => setActiveChild(item.id)}
    >
      <View style={styles.cardContent}>
        <View style={styles.avatarPlaceholder}>
          <Text style={styles.avatarText}>{item.name.charAt(0).toUpperCase()}</Text>
        </View>
        <View style={styles.infoContainer}>
          <Text style={styles.nameText}>{item.name}</Text>
          <Text style={styles.dateText}>{item.birthDate}</Text>
        </View>
        <View style={styles.actionsContainer}>
          {item.isActive && (
            <View style={styles.activeBadge}>
              <Text style={styles.activeBadgeText}>Selecionado</Text>
            </View>
          )}
          <TouchableOpacity 
            style={styles.editButton} 
            onPress={() => handleEdit(item)}
            hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
          >
            <Ionicons name="pencil" size={20} color={theme.colors.primary} />
          </TouchableOpacity>
        </View>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <View style={styles.headerCurve} />

      <View style={styles.topFixedHeader}>
        <View style={styles.topBar}>
          <TouchableOpacity style={styles.iconButton} onPress={() => navigation.goBack()}>
            <Ionicons name="chevron-back" size={28} color={theme.colors.white} />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Crianças</Text>
          <View style={{ width: 44 }} />
        </View>
      </View>

      <FlatList
        data={children}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        style={styles.scrollView}
        contentContainerStyle={styles.listContainer}
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={() => <View style={styles.scrollSpacer} />}
        ListFooterComponent={() => (
          <TouchableOpacity 
            style={styles.addButton} 
            onPress={() => navigation.navigate('ChildRegister')}
          >
            <Ionicons name="add" size={24} color={theme.colors.white} />
            <Text style={styles.addButtonText}>Adicionar nova criança</Text>
          </TouchableOpacity>
        )}
      />
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
    height: HEADER_MAX_HEIGHT - 60,
    backgroundColor: 'transparent',
  },
  listContainer: {
    padding: 24,
    paddingBottom: 40,
  },
  listDescription: {
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    color: '#5E5E5E',
    marginBottom: 24,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  addButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: theme.colors.primary,
    borderRadius: 50,
    paddingVertical: 12,
    marginBottom: 24,
  },
  addButtonText: {
    fontFamily: theme.fonts.mulishSemiBold,
    color: theme.colors.white,
    fontSize: 16,
    marginLeft: 8,
  },
  card: {
    backgroundColor: theme.colors.white,
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    borderWidth: 2,
    borderColor: 'transparent',
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 3,
  },
  cardActive: {
    borderColor: theme.colors.primary,
    backgroundColor: '#F5F9FF',
  },
  cardContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatarPlaceholder: {
    width: 54,
    height: 54,
    borderRadius: 27,
    backgroundColor: '#EBF3FF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  avatarText: {
    fontFamily: theme.fonts.mulishBold,
    color: theme.colors.primary,
    fontSize: 22,
  },
  infoContainer: {
    flex: 1,
  },
  nameText: {
    fontFamily: theme.fonts.mulishBold,
    fontSize: 16,
    color: theme.colors.textDark,
  },
  dateText: {
    fontFamily: theme.fonts.regular,
    fontSize: 13,
    color: theme.colors.textHint,
    marginTop: 4,
  },
  actionsContainer: {
    alignItems: 'flex-end',
    justifyContent: 'center',
  },
  activeBadge: {
    backgroundColor: theme.colors.primary,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
    marginBottom: 8,
  },
  activeBadgeText: {
    fontFamily: theme.fonts.mulishBold,
    color: theme.colors.white,
    fontSize: 10,
  },
  editButton: {
    padding: 10,
    backgroundColor: 'rgba(14, 93, 253, 0.1)',
    borderRadius: 50,
  },
});
