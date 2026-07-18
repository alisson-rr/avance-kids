import React from 'react';
import { OnboardingLayout } from '../components/OnboardingLayout';

export function Onboarding3Screen({ navigation }: any) {
  return (
    <OnboardingLayout
      gradient={{ colors: ['#EBF3FF', '#FFFFFF'], start: { x: 0.5, y: 0 }, end: { x: 0.5, y: 1 } }}
      image={require('../../assets/onboarding3.png')}
      imageStyle={{ width: 320, height: 320 }}
      title="Oba, agora o plano de atividades está pronto!"
      subtitle="Com base nas suas respostas, criamos um plano de atividades personalizado para sua criança!"
      buttonLabel="Ver atividades personalizadas"
      onButtonPress={() => navigation.navigate('Home')}
      bodyGap={40}
      textGap={12}
    />
  );
}
