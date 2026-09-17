import React from 'react';
import {
  Modal,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
} from 'react-native';
import { VideoPlayer } from './VideoPlayer';
import { theme } from '../theme';

interface HowToAnswerSheetProps {
  visible: boolean;
  onClose: () => void;
  texto: string | null;
  videoId: string | null;
}

export function HowToAnswerSheet({ visible, onClose, texto, videoId }: HowToAnswerSheetProps) {
  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <TouchableOpacity style={styles.overlay} activeOpacity={1} onPress={onClose}>
        <TouchableWithoutFeedback onPress={() => {}}>
          <View style={styles.sheet}>
            <View style={styles.dragHandle} />
            <Text style={styles.title}>Como responder</Text>

            <ScrollView contentContainerStyle={styles.content}>
              {videoId ? <VideoPlayer key={videoId} videoId={videoId} /> : null}
              {texto ? <Text style={styles.text}>{texto}</Text> : null}
            </ScrollView>

            <TouchableOpacity style={styles.button} onPress={onClose}>
              <Text style={styles.buttonText}>Entendi</Text>
            </TouchableOpacity>
          </View>
        </TouchableWithoutFeedback>
      </TouchableOpacity>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    justifyContent: 'flex-end',
  },
  sheet: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    paddingHorizontal: 24,
    paddingTop: 12,
    paddingBottom: 32,
    maxHeight: '90%',
  },
  dragHandle: {
    width: 48,
    height: 4,
    backgroundColor: '#D1D1D6',
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 24,
  },
  title: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 18,
    lineHeight: 24,
    color: '#3B3B3B',
    marginBottom: 16,
  },
  content: {
    gap: 16,
  },
  text: {
    fontFamily: theme.fonts.regular,
    fontSize: 15,
    lineHeight: 22,
    color: '#3B3B3B',
  },
  button: {
    width: '100%',
    height: 52,
    backgroundColor: '#0E5DFD',
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 24,
  },
  buttonText: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    color: '#FFFFFF',
  },
});
