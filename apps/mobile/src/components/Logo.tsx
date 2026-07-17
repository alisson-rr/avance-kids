import React from 'react';
import { StyleSheet, View } from 'react-native';
// @ts-ignore (ignoring typescript error for svg import)
import LogoSvg from '../../assets/logo+texto.svg';

export function Logo() {
  return (
    <View style={styles.container}>
      <LogoSvg width="100%" height="100%" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 233,
    height: 115,
  },
});
