import { QuestionCrudScreen } from './QuestionCrudScreen';

// Checklist completo: avalia se a criança já domina a habilidade dentro da
// própria faixa etária (define se o plano de atividades avança ou recua).
export function TriageQuestionsScreen() {
  return (
    <QuestionCrudScreen
      title="Perguntas de Triagem"
      newLabel="Nova Pergunta"
      formTitle={(isEditing) => (isEditing ? 'Editar Pergunta de Triagem' : 'Nova Pergunta de Triagem')}
      kind="triagem"
      searchPlaceholder="Buscar por texto ou habilidade..."
    />
  );
}
