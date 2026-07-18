import React from 'react';
import { OnboardingLayout } from '../components/OnboardingLayout';
import { useProfileStore } from '../store/useProfileStore';

export function Onboarding1Screen({ navigation }: any) {
  const { parentName } = useProfileStore();
  const firstName = parentName.split(' ')[0] || 'Usuário';

  return (
    <OnboardingLayout
      // Figma: linear-gradient(198.82deg, #B2CCFF -44.6%, #FFFFFF 59.3%)
      gradient={{ colors: ['#B2CCFF', '#FFFFFF'], start: { x: 0.3, y: 0 }, end: { x: 0.7, y: 1 } }}
      onBack={() => navigation.goBack()}
      greeting={`Olá, ${firstName}!`}
      image={require('../../assets/onboarding1.png')}
      imageStyle={{ width: 273, height: 404 }}
      title="Primeiro, vamos conhecer o momento da criança"
      subtitle="Vamos fazer algumas perguntas gerais para entender melhor a criança e montar atividades que ajudem no desenvolvimento."
      buttonLabel="Começar"
      onButtonPress={() => navigation.navigate('Perguntas')}
    />
  );
}
