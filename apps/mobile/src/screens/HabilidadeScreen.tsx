import React, { useState } from 'react';
import { View, Text } from 'react-native';
import { QuestionScreenLayout } from '../components/QuestionScreenLayout';
import { HABILIDADES, HABILIDADE_STYLES, MOCK_PERGUNTAS } from '../data/habilidades';

export function HabilidadeScreen({ route, navigation }: any) {
  const { habilidadeId } = route.params;

  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [answers, setAnswers] = useState<Record<number, number>>({});

  const habilidadeInfo = HABILIDADES.find((h) => h.id === habilidadeId);

  if (!habilidadeInfo) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>Habilidade não encontrada.</Text>
      </View>
    );
  }

  const stylesConfig = HABILIDADE_STYLES[habilidadeInfo.key];
  const q = MOCK_PERGUNTAS[currentQuestion];
  const total = MOCK_PERGUNTAS.length;

  const handleNext = () => {
    if (selectedOption === null) return;
    setAnswers({ ...answers, [currentQuestion]: selectedOption });
    setSelectedOption(null);

    if (currentQuestion < total - 1) {
      setCurrentQuestion(currentQuestion + 1);
    } else {
      // Mock submit and return to TriagemScreen
      navigation.goBack();
    }
  };

  const handlePrev = () => {
    if (currentQuestion > 0) {
      setCurrentQuestion(currentQuestion - 1);
      setSelectedOption(answers[currentQuestion - 1] ?? null);
    } else {
      navigation.goBack();
    }
  };

  return (
    <QuestionScreenLayout
      headerColor={stylesConfig.background}
      headerTitle={habilidadeInfo.title}
      statusBarStyle="dark-content"
      onBack={handlePrev}
      image={stylesConfig.image}
      imageBackground={stylesConfig.tagBackground}
      tag={{
        label: habilidadeInfo.title,
        background: stylesConfig.tagBackground,
        color: stylesConfig.textColor,
      }}
      perguntaAtual={currentQuestion}
      totalPerguntas={total}
      progressActiveStyle={{ backgroundColor: stylesConfig.textColor, opacity: 0.6 }}
      progressInactiveStyle={{ backgroundColor: '#F0F0F0' }}
      pergunta={q.question}
      opcoes={q.options}
      selectedOption={selectedOption}
      onSelectOption={setSelectedOption}
      onPrev={handlePrev}
      onNext={handleNext}
    />
  );
}
