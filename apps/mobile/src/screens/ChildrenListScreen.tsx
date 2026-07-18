import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, FlatList } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { theme } from '../theme';
import { CurvedHeader, HEADER_MAX_HEIGHT } from '../components/CurvedHeader';
import { useProfileStore, Child } from '../store/useProfileStore';

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
      <CurvedHeader title="Crianças" onBack={() => navigation.goBack()} />

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
