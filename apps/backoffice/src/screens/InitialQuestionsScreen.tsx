import { EntityCrudScreen, FormField, OptionListEditor, Badge, Select } from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import { createDefaultOptions } from '../types/common';
import type { PerguntaInicial } from '../types/entities';

const MOCK_PERGUNTAS_INICIAIS: PerguntaInicial[] = [
  {
    id: 1,
    texto: 'Seu filho(a) olha quando você o chama pelo nome?',
    ordem: 1,
    status: 'ativo',
    opcoes: [
      { id: 1, texto: 'Quase nunca faz, mesmo com ajuda', valorNumerico: 0 },
      { id: 2, texto: 'Faz às vezes ou com ajuda', valorNumerico: 1 },
      { id: 3, texto: 'Faz quase sempre, com autonomia', valorNumerico: 2 },
      { id: 4, texto: 'Não observei essa situação ainda', valorNumerico: 0 },
    ],
  },
  {
    id: 2,
    texto: 'Seu filho(a) aponta para objetos que deseja?',
    ordem: 2,
    status: 'ativo',
    opcoes: [
      { id: 1, texto: 'Ainda não faz esse gesto', valorNumerico: 0 },
      { id: 2, texto: 'Faz com ajuda ou raramente', valorNumerico: 1 },
      { id: 3, texto: 'Faz com frequência e autonomia', valorNumerico: 2 },
      { id: 4, texto: 'Não observei essa situação ainda', valorNumerico: 0 },
    ],
  },
];

function emptyPerguntaInicial(): PerguntaInicial {
  return { id: 0, texto: '', ordem: 1, status: 'ativo', opcoes: createDefaultOptions() };
}

function matchesSearch(row: PerguntaInicial, term: string): boolean {
  return row.texto.toLowerCase().includes(term);
}

const columns: DataTableColumn<PerguntaInicial>[] = [
  { key: 'ordem', header: 'Ordem', width: '80px', render: (row) => row.ordem },
  { key: 'texto', header: 'Pergunta', render: (row) => row.texto },
  { key: 'opcoes', header: 'Opções', width: '100px', render: (row) => <Badge variant="neutral">{row.opcoes.length}</Badge> },
  {
    key: 'status',
    header: 'Status',
    render: (row) => (
      <Badge variant={row.status === 'ativo' ? 'success' : 'neutral'}>
        {row.status === 'ativo' ? 'Ativo' : 'Arquivado'}
      </Badge>
    ),
  },
];

export function InitialQuestionsScreen() {
  return (
    <EntityCrudScreen<PerguntaInicial>
      title="Perguntas Iniciais"
      newLabel="Nova Pergunta"
      formTitle={(isEditing) => (isEditing ? 'Editar Pergunta Inicial' : 'Nova Pergunta Inicial')}
      columns={columns}
      initialRows={MOCK_PERGUNTAS_INICIAIS}
      matchesSearch={matchesSearch}
      emptyItem={emptyPerguntaInicial}
      searchPlaceholder="Buscar por texto da pergunta..."
      renderForm={(item, update) => (
        <>
          <FormField label="Texto da Pergunta" required fullWidth>
            <textarea rows={2} value={item.texto} onChange={(e) => update('texto', e.target.value)} />
          </FormField>

          <FormField label="Ordem de Exibição">
            <input
              type="number"
              min={1}
              value={item.ordem}
              onChange={(e) => update('ordem', Number(e.target.value))}
            />
          </FormField>

          <FormField label="Status">
            <Select
              value={item.status}
              onChange={(v) => update('status', v as PerguntaInicial['status'])}
              options={[
                { value: 'ativo', label: 'Ativo' },
                { value: 'arquivado', label: 'Arquivado' },
              ]}
            />
          </FormField>

          <FormField label="Opções de Resposta" fullWidth hint="A mesma escala (0/1/2) usada para calcular a idade geral da criança.">
            <OptionListEditor options={item.opcoes} onChange={(opcoes) => update('opcoes', opcoes)} />
          </FormField>
        </>
      )}
    />
  );
}
