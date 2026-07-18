import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import * as SplashScreen from 'expo-splash-screen';
import { useFonts, Inter_400Regular, Inter_500Medium, Inter_600SemiBold } from '@expo-google-fonts/inter';
import { Mulish_400Regular, Mulish_600SemiBold, Mulish_700Bold, Mulish_800ExtraBold } from '@expo-google-fonts/mulish';

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
import { ActivityPlanScreen } from './src/screens/ActivityPlanScreen';
import { ActivityScreen } from './src/screens/ActivityScreen';
import { SettingsScreen } from './src/screens/SettingsScreen';
import { EditParentProfileScreen } from './src/screens/EditParentProfileScreen';
import { ChildrenListScreen } from './src/screens/ChildrenListScreen';
import { EditChildProfileScreen } from './src/screens/EditChildProfileScreen';
import { ChangePasswordScreen } from './src/screens/ChangePasswordScreen';
import { ActivityHistoryScreen } from './src/screens/ActivityHistoryScreen';
import { PlansScreen } from './src/screens/PlansScreen';

const Stack = createNativeStackNavigator();

// Keep the splash screen visible while we fetch resources
SplashScreen.preventAutoHideAsync();

export default function App() {
  const [fontsLoaded] = useFonts({
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
    Mulish_400Regular,
    Mulish_600SemiBold,
    Mulish_700Bold,
    Mulish_800ExtraBold,
  });

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded]);

  if (!fontsLoaded) {
    return null;
  }

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
          <Stack.Screen name="ActivityPlan" component={ActivityPlanScreen} />
          <Stack.Screen name="Activity" component={ActivityScreen} />
          <Stack.Screen name="Settings" component={SettingsScreen} />
          <Stack.Screen name="EditParentProfile" component={EditParentProfileScreen} />
          <Stack.Screen name="ChildrenList" component={ChildrenListScreen} />
          <Stack.Screen name="EditChildProfile" component={EditChildProfileScreen} />
          <Stack.Screen name="ChangePassword" component={ChangePasswordScreen} />
          <Stack.Screen name="ActivityHistory" component={ActivityHistoryScreen} />
          <Stack.Screen name="Plans" component={PlansScreen} />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
