import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Modal, FlatList, TouchableWithoutFeedback, SafeAreaView } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { theme } from '../theme';

interface BottomSheetSelectProps {
  placeholder: string;
  value: string | string[];
  options: string[];
  multiSelect?: boolean;
  onChange: (val: any) => void;
}

export function BottomSheetSelect({ placeholder, value, options, multiSelect, onChange }: BottomSheetSelectProps) {
  const [modalVisible, setModalVisible] = useState(false);

  const handleSelect = (option: string) => {
    if (multiSelect) {
      const currentValues = Array.isArray(value) ? value : [];
      if (currentValues.includes(option)) {
        onChange(currentValues.filter(v => v !== option));
      } else {
        onChange([...currentValues, option]);
      }
    } else {
      onChange(option);
      setModalVisible(false);
    }
  };

  const getDisplayText = () => {
    if (multiSelect && Array.isArray(value)) {
      return value.length > 0 ? value.join(', ') : '';
    }
    return value ? String(value) : '';
  };

  const displayText = getDisplayText();

  return (
    <>
      <TouchableOpacity 
        style={styles.inputContainer} 
        activeOpacity={0.8} 
        onPress={() => setModalVisible(true)}
      >
        <Text style={[styles.inputText, !displayText && styles.placeholderText]}>
          {displayText || placeholder}
        </Text>
        <Feather name="chevron-down" size={20} color={theme.colors.textLight} />
      </TouchableOpacity>

      <Modal
        visible={modalVisible}
        transparent
        animationType="slide"
        onRequestClose={() => setModalVisible(false)}
      >
        <TouchableOpacity 
          style={styles.modalOverlay} 
          activeOpacity={1} 
          onPressOut={() => setModalVisible(false)}
        >
          <View style={styles.bottomSheet}>
            <View style={styles.dragHandle} />
            
            <View style={styles.sheetHeader}>
              <Text style={styles.sheetTitle}>Selecione {placeholder.toLowerCase()}</Text>
              <TouchableOpacity onPress={() => setModalVisible(false)}>
                <Feather name="x" size={24} color={theme.colors.textDark} />
              </TouchableOpacity>
            </View>

            <FlatList
              data={options}
              keyExtractor={(item) => item}
              renderItem={({ item }) => {
                const isSelected = multiSelect 
                  ? Array.isArray(value) && value.includes(item)
                  : value === item;

                return (
                  <TouchableOpacity 
                    style={styles.optionRow} 
                    onPress={() => handleSelect(item)}
                  >
                    <Text style={[styles.optionText, isSelected && styles.optionTextSelected]}>
                      {item}
                    </Text>
                    {isSelected && <Feather name="check" size={20} color={theme.colors.primary} />}
                  </TouchableOpacity>
                );
              }}
              contentContainerStyle={styles.listContent}
            />
            <SafeAreaView />
          </View>
        </TouchableOpacity>
      </Modal>
    </>
  );
}

const styles = StyleSheet.create({
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 14,
    paddingHorizontal: 20,
    height: 52,
    borderRadius: 100,
    width: '100%',
    backgroundColor: '#F2F2F2',
  },
  inputText: {
    fontFamily: theme.fonts.regular,
    fontSize: 16,
    color: theme.colors.textDark,
    flex: 1,
  },
  placeholderText: {
    color: theme.colors.textLight,
  },
  modalOverlay: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.4)',
  },
  bottomSheet: {
    backgroundColor: theme.colors.background,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    maxHeight: '70%',
    minHeight: '40%',
  },
  dragHandle: {
    width: 40,
    height: 4,
    backgroundColor: '#D5D7DA',
    borderRadius: 2,
    alignSelf: 'center',
    marginTop: 12,
  },
  sheetHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.divider,
  },
  sheetTitle: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 18,
    color: theme.colors.textDark,
  },
  listContent: {
    paddingBottom: 24,
  },
  optionRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 16,
    paddingHorizontal: 24,
    borderBottomWidth: 1,
    borderBottomColor: '#F2F2F2',
  },
  optionText: {
    fontFamily: theme.fonts.regular,
    fontSize: 16,
    color: theme.colors.textDark,
  },
  optionTextSelected: {
    fontFamily: theme.fonts.medium,
    color: theme.colors.primary,
  }
});
