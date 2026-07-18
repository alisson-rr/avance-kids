import React, { useState } from 'react';
import { QuestionScreenLayout } from '../components/QuestionScreenLayout';

// ─── MOCK DATA ────────────────────────────────────────────────────────
const QUESTIONS = [
  {
    id: 1,
    question: 'Seu filho(a) olha quando você o chama pelo nome?',
    options: [
      'Quase nunca faz, mesmo com ajuda',
      'Faz às vezes ou com ajuda',
      'Faz quase sempre, com autonomia',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 2,
    question: 'Seu filho(a) aponta para objetos que deseja?',
    options: [
      'Ainda não faz esse gesto',
      'Faz com ajuda ou raramente',
      'Faz com frequência e autonomia',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 3,
    question: 'Seu filho(a) consegue brincar junto com outras crianças?',
    options: [
      'Prefere brincar sozinho(a)',
      'Às vezes interage, com incentivo',
      'Brinca bem com outras crianças',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 4,
    question: 'Seu filho(a) imita gestos ou expressões de outras pessoas?',
    options: [
      'Raramente ou nunca imita',
      'Imita com ajuda ou às vezes',
      'Imita com facilidade e espontaneidade',
      'Não observei essa situação ainda',
    ],
  },
];

// ─── COMPONENT ────────────────────────────────────────────────────────
export function PerguntasScreen({ navigation }: any) {
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [answers, setAnswers] = useState<Record<number, number>>({});

  const q = QUESTIONS[currentQuestion];
  const total = QUESTIONS.length;

  const handleNext = () => {
    if (selectedOption === null) return;
    setAnswers({ ...answers, [currentQuestion]: selectedOption });

    if (currentQuestion < total - 1) {
      setCurrentQuestion(currentQuestion + 1);
      setSelectedOption(null);
    } else {
      navigation.navigate('Onboarding2');
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
      headerColor="#3678FD"
      headerTitle="Perguntas iniciais"
      onBack={handlePrev}
      image={require('../../assets/perguntas.png')}
      imageBackground="#EEF4FF"
      perguntaAtual={currentQuestion}
      totalPerguntas={total}
      progressActiveStyle={{ backgroundColor: 'rgba(54, 120, 253, 0.6)' }}
      progressInactiveStyle={{ backgroundColor: 'rgba(54, 120, 253, 0.2)' }}
      pergunta={q.question}
      opcoes={q.options}
      selectedOption={selectedOption}
      onSelectOption={setSelectedOption}
      onPrev={handlePrev}
      onNext={handleNext}
    />
  );
}
