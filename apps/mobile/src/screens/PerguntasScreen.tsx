import React, { useCallback, useEffect, useRef, useState } from 'react';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';
import { QuestionScreenLayout } from '../components/QuestionScreenLayout';
import { Button } from '../components/Button';
import { theme } from '../theme';
import { fetchAgeBrackets, resolveBracketForMonths } from '../services/catalog';
import {
  QUESTION_OPTIONS,
  fetchQuestions,
  submitInitialAnswers,
  type AnswerInput,
} from '../services/questions';
import { errorMessage } from '../services/api';
import { showDialog, showError } from '../ui/dialog';
import { useProfileStore, selectActiveChild } from '../store/useProfileStore';
import type { QuestionRow } from '../types/db';

const OPTION_LABELS = QUESTION_OPTIONS.map((o) => o.label);

export function PerguntasScreen({ navigation }: any) {
  const activeChild = useProfileStore(selectActiveChild);

  const [questions, setQuestions] = useState<QuestionRow[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [submitting, setSubmitting] = useState(false);

  // Garantia de término do rebaixamento: uma faixa é respondida no máximo uma
  // vez por passagem pela tela. O piso (F01A) já vem do servidor, que devolve
  // a mesma faixa quando não há para onde descer; isto é a segunda trava.
  const faixasRespondidas = useRef<Set<string>>(new Set());

  const load = useCallback(
    async (faixaAlvo?: string) => {
      if (!activeChild) {
        setLoadError('Nenhuma criança selecionada.');
        return;
      }
      setLoadError(null);
      setQuestions(null);
      try {
        // A faixa dos pré-requisitos é a que o servidor gravou (children.faixa_id).
        // A idade só entra quando a criança nunca foi avaliada.
        let bracketId = faixaAlvo ?? activeChild.faixaId ?? null;
        if (!bracketId) {
          const brackets = await fetchAgeBrackets();
          const bracket = resolveBracketForMonths(activeChild.idadeBiologicaMeses ?? 12, brackets);
          if (!bracket) throw new Error('Faixas etárias não configuradas.');
          bracketId = bracket.id;
        }

        const rows = await fetchQuestions('inicial', bracketId);
        if (rows.length === 0) {
          setLoadError('Ainda não há perguntas cadastradas para a faixa etária da criança.');
          return;
        }
        faixasRespondidas.current.add(bracketId);
        setAnswers({});
        setCurrentQuestion(0);
        setSelectedOption(null);
        setQuestions(rows);
      } catch (err) {
        setLoadError(errorMessage(err));
      }
    },
    [activeChild?.id],
  );

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
      const result = await submitInitialAnswers(activeChild.id, payload);
      await useProfileStore.getState().refreshChildren();

      // Rebaixamento é automático: o aviso informa, não pergunta.
      const proxima = result.rebaixou ? result.proxima_faixa : null;
      if (proxima && !faixasRespondidas.current.has(proxima.id)) {
        showDialog({
          title: 'Ajustando o ponto de partida',
          message: `Pelas respostas, ${activeChild.name} ainda está construindo alguns pré-requisitos. Vamos seguir com as perguntas de ${proxima.nome} para começar no ponto certo.`,
          variant: 'info',
          buttons: [{ label: 'Continuar', kind: 'primary', onPress: () => load(proxima.id) }],
        });
        return;
      }

      navigation.navigate('Onboarding2');
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
      <View style={styles.stateContainer}>
        <Text style={styles.stateText}>{loadError}</Text>
        {/* Arrow function de propósito: onPress passa o evento como 1º
            argumento, e `load` agora recebe a faixa alvo nessa posição. */}
        <Button title="Tentar novamente" onPress={() => load()} />
        <Text style={styles.skipText} onPress={() => navigation.navigate('Onboarding2')}>
          Pular por enquanto
        </Text>
      </View>
    );
  }

  if (!questions) {
    return (
      <View style={styles.stateContainer}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  const q = questions[currentQuestion];

  return (
    <QuestionScreenLayout
      headerColor="#3678FD"
      headerTitle="Perguntas iniciais"
      onBack={handlePrev}
      image={require('../../assets/perguntas.png')}
      imageBackground="#EEF4FF"
      perguntaAtual={currentQuestion}
      totalPerguntas={questions.length}
      progressActiveStyle={{ backgroundColor: 'rgba(54, 120, 253, 0.6)' }}
      progressInactiveStyle={{ backgroundColor: 'rgba(54, 120, 253, 0.2)' }}
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

const styles = StyleSheet.create({
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
