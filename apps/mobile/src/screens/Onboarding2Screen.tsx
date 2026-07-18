import React from 'react';
import { OnboardingLayout } from '../components/OnboardingLayout';

export function Onboarding2Screen({ navigation }: any) {
  return (
    <OnboardingLayout
      gradient={{ colors: ['#B2CCFF', '#FFFFFF'], start: { x: 0.3, y: 0 }, end: { x: 0.7, y: 1 } }}
      onBack={() => navigation.goBack()}
      image={require('../../assets/onboarding2.png')}
      imageStyle={{ width: 273, height: 404 }}
      title="Agora, vamos entender as habilidades específicas"
      subtitle="Assim, com base nas respostas, vamos criar um plano de atividades personalizado para sua criança!"
      buttonLabel="Continuar"
      onButtonPress={() => navigation.navigate('Triagem')}
    />
  );
}
