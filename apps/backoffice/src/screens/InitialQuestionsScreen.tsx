import { QuestionCrudScreen } from './QuestionCrudScreen';

// Pré-requisitos da faixa: antes de aplicar o checklist completo da faixa
// etária da criança, essas perguntas confirmam se ela já domina o básico
// da(s) faixa(s) anterior(es) — se não, a triagem recua para essa faixa.
export function InitialQuestionsScreen() {
  return (
    <QuestionCrudScreen
      title="Perguntas Iniciais"
      newLabel="Nova Pergunta"
      formTitle={(isEditing) => (isEditing ? 'Editar Pergunta Inicial' : 'Nova Pergunta Inicial')}
      kind="inicial"
      searchPlaceholder="Buscar por texto ou habilidade..."
    />
  );
}
