import React, { useCallback, useEffect, useState } from 'react';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';
import { QuestionScreenLayout } from '../components/QuestionScreenLayout';
import { Button } from '../components/Button';
import { theme } from '../theme';
import { HABILIDADE_STYLES, type HabilidadeKey } from '../data/habilidades';
import {
  QUESTION_OPTIONS,
  fetchQuestions,
  submitScreeningAnswers,
  type AnswerInput,
} from '../services/questions';
import { errorMessage } from '../services/api';
import { showError } from '../ui/dialog';
import { useProfileStore, selectActiveChild } from '../store/useProfileStore';
import type { QuestionRow } from '../types/db';

const OPTION_LABELS = QUESTION_OPTIONS.map((o) => o.label);

export function HabilidadeScreen({ route, navigation }: any) {
  const { skillId, skillKey, skillNome, bracketId } = route.params ?? {};
  const activeChild = useProfileStore(selectActiveChild);

  const [questions, setQuestions] = useState<QuestionRow[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [submitting, setSubmitting] = useState(false);

  const stylesConfig =
    HABILIDADE_STYLES[skillKey as HabilidadeKey] ?? HABILIDADE_STYLES.comunicacao;

  const load = useCallback(async () => {
    if (!skillId || !bracketId) {
      setLoadError('Habilidade não encontrada.');
      return;
    }
    setLoadError(null);
    setQuestions(null);
    try {
      const rows = await fetchQuestions('triagem', bracketId, skillId);
      if (rows.length === 0) {
        setLoadError('Ainda não há perguntas de triagem cadastradas para esta habilidade.');
        return;
      }
      setQuestions(rows);
    } catch (err) {
      setLoadError(errorMessage(err));
    }
  }, [skillId, bracketId]);

  useEffect(() => {
    load();
  }, [load]);

  const finish = async (finalAnswers: Record<number, number>) => {
    if (!activeChild || !questions) return;
    setSubmitting(true);
    try {
      const payload: AnswerInput[] = questions.map((q, index) => {
        const option = QUESTION_OPTIONS[finalAnswers[index]];
        return {
          question_id: q.id,
          valor_numerico: option.valorNumerico,
          nao_observado: option.naoObservado,
        };
      });
      await submitScreeningAnswers(activeChild.id, skillId, payload);
      navigation.goBack();
    } catch (err) {
      showError('Erro ao enviar respostas', errorMessage(err));
    } finally {
      setSubmitting(false);
    }
  };

  const handleNext = () => {
    if (selectedOption === null || submitting || !questions) return;
    const nextAnswers = { ...answers, [currentQuestion]: selectedOption };
    setAnswers(nextAnswers);

    if (currentQuestion < questions.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
      setSelectedOption(nextAnswers[currentQuestion + 1] ?? null);
    } else {
      finish(nextAnswers);
    }
  };

  const handlePrev = () => {
    if (submitting) return;
    if (currentQuestion > 0) {
      setCurrentQuestion(currentQuestion - 1);
      setSelectedOption(answers[currentQuestion - 1] ?? null);
    } else {
      navigation.goBack();
    }
  };

  if (loadError) {
    return (
      <View style={stateStyles.stateContainer}>
        <Text style={stateStyles.stateText}>{loadError}</Text>
        <Button title="Tentar novamente" onPress={load} />
        <Text style={stateStyles.skipText} onPress={() => navigation.goBack()}>
          Voltar
        </Text>
      </View>
    );
  }

  if (!questions) {
    return (
      <View style={stateStyles.stateContainer}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  const q = questions[currentQuestion];

  return (
    <QuestionScreenLayout
      headerColor={stylesConfig.background}
      headerTitle={skillNome ?? 'Habilidade'}
      statusBarStyle="dark-content"
      onBack={handlePrev}
      image={stylesConfig.image}
      imageBackground={stylesConfig.tagBackground}
      tag={{
        label: skillNome ?? 'Habilidade',
        background: stylesConfig.tagBackground,
        color: stylesConfig.textColor,
      }}
      perguntaAtual={currentQuestion}
      totalPerguntas={questions.length}
      progressActiveStyle={{ backgroundColor: stylesConfig.textColor, opacity: 0.6 }}
      progressInactiveStyle={{ backgroundColor: '#F0F0F0' }}
      pergunta={q.texto}
      opcoes={OPTION_LABELS}
      selectedOption={selectedOption}
      onSelectOption={setSelectedOption}
      onPrev={handlePrev}
      onNext={handleNext}
      busy={submitting}
    />
  );
}

const stateStyles = StyleSheet.create({
  stateContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
    gap: 24,
    backgroundColor: '#FAFAFA',
  },
  stateText: {
    fontFamily: theme.fonts.regular,
    fontSize: 16,
    color: '#424242',
    textAlign: 'center',
  },
  skipText: {
    fontFamily: theme.fonts.medium,
    fontSize: 16,
    color: '#727272',
  },
});
