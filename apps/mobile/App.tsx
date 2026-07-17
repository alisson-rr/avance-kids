import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import { LoginScreen } from './src/screens/LoginScreen';
import { ParentRegisterScreen } from './src/screens/ParentRegisterScreen';
import { ChildRegisterScreen } from './src/screens/ChildRegisterScreen';
import { Onboarding1Screen } from './src/screens/Onboarding1Screen';
import { PerguntasScreen } from './src/screens/PerguntasScreen';
import { Onboarding2Screen } from './src/screens/Onboarding2Screen';
import { TriagemScreen } from './src/screens/TriagemScreen';
import { HabilidadeScreen } from './src/screens/HabilidadeScreen';
import { Onboarding3Screen } from './src/screens/Onboarding3Screen';
import { HomeScreen } from './src/screens/HomeScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <Stack.Navigator 
          initialRouteName="Login"
          screenOptions={{ headerShown: false, animation: 'slide_from_right' }}
        >
          <Stack.Screen name="Login" component={LoginScreen} />
          <Stack.Screen name="ParentRegister" component={ParentRegisterScreen} />
          <Stack.Screen name="ChildRegister" component={ChildRegisterScreen} />
          <Stack.Screen name="Onboarding1" component={Onboarding1Screen} />
          <Stack.Screen name="Perguntas" component={PerguntasScreen} />
          <Stack.Screen name="Onboarding2" component={Onboarding2Screen} />
          <Stack.Screen name="Triagem" component={TriagemScreen} />
          <Stack.Screen name="Habilidade" component={HabilidadeScreen} />
          <Stack.Screen name="Onboarding3" component={Onboarding3Screen} />
          <Stack.Screen name="Home" component={HomeScreen} />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
