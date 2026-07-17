import React, { useState } from 'react';
import { View, Text } from 'react-native';
import { TriagemBaseScreen } from '../components/TriagemBaseScreen';
import { HabilidadeKey, MOCK_PERGUNTAS } from '../data/habilidades';

export function HabilidadeScreen({ route, navigation }: any) {
  const { habilidadeId } = route.params;

  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});

  // Map ID to Key
  const habilidadeMap: Record<number, { key: HabilidadeKey, title: string }> = {
    1: { key: 'comunicacao', title: 'Comunicação' },
    2: { key: 'social', title: 'Social' },
    3: { key: 'cognitiva', title: 'Cognitiva' },
    4: { key: 'motora', title: 'Coordenação motora' },
    5: { key: 'funcional', title: 'Funcional' }
  };

  const habilidadeInfo = habilidadeMap[habilidadeId];

  if (!habilidadeInfo) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>Habilidade não encontrada.</Text>
      </View>
    );
  }

  const q = MOCK_PERGUNTAS[currentQuestion];
  const total = MOCK_PERGUNTAS.length;

  const handleNext = (respostaIndex: number) => {
    const newAnswers = { ...answers, [currentQuestion]: respostaIndex };
    setAnswers(newAnswers);

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
    } else {
      navigation.goBack();
    }
  };

  return (
    <TriagemBaseScreen
      habilidade={habilidadeInfo.key}
      habilidadeTitle={habilidadeInfo.title}
      perguntaAtual={currentQuestion}
      totalPerguntas={total}
      perguntaTexto={q.question}
      opcoes={q.options}
      onNext={handleNext}
      onBack={handlePrev}
    />
  );
}
