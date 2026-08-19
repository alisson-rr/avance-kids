import React, { useState } from 'react';
import { View, TouchableOpacity, StyleSheet, ActivityIndicator } from 'react-native';
import { Image } from 'expo-image';
import { Feather } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { showDialog, showError } from '../ui/dialog';
import { theme } from '../theme';

interface PhotoPickerProps {
  imageUri?: string;
  onImageSelected: (uri: string) => void;
}

export function PhotoPicker({ imageUri, onImageSelected }: PhotoPickerProps) {
  const [loading, setLoading] = useState(false);

  const pickImage = async () => {
    try {
      setLoading(true);
      const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
      
      if (permissionResult.granted === false) {
        showDialog({
          title: 'Permissão necessária',
          message: 'Permita o acesso à galeria para escolher uma foto.',
          variant: 'info',
        });
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['images'],
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (!result.canceled && result.assets[0]) {
        onImageSelected(result.assets[0].uri);
      }
    } catch (error) {
      console.warn('[foto] seleção falhou:', error);
      showError('Erro', 'Não foi possível abrir a galeria. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity 
        style={styles.pickerCircle} 
        onPress={pickImage}
        activeOpacity={0.8}
      >
        {imageUri ? (
          <Image source={{ uri: imageUri }} style={styles.image} contentFit="cover" />
        ) : (
          loading ? (
            <ActivityIndicator color={theme.colors.textLight} />
          ) : (
            <Feather name="camera" size={32} color={theme.colors.textLight} />
          )
        )}
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    marginBottom: 24,
  },
  pickerCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: '#E5E7EB',
    justifyContent: 'center',
    alignItems: 'center',
    overflow: 'hidden',
  },
  image: {
    width: '100%',
    height: '100%',
  }
});
