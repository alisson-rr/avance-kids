import { SKILLS, AGE_BRACKETS, getSkill, getAgeBracket, type HabilidadeKey, type AgeBracketCode } from '../constants/aba';
import { Badge, EntityCrudScreen, FormField, OptionListEditor, Select } from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import { createDefaultOptions } from '../types/common';
import type { PerguntaTriagem } from '../types/entities';

const MOCK_PERGUNTAS_TRIAGEM: PerguntaTriagem[] = [
  {
    id: 1,
    codigo: 'F02AC001',
    skillKey: 'comunicacao',
    ageBracketCode: 'F02A',
    texto: 'A criança consegue seguir instruções simples de uma etapa?',
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
    codigo: 'F01AM001',
    skillKey: 'motora',
    ageBracketCode: 'F01A',
    texto: 'A criança consegue caminhar sozinha por alguns passos?',
    ordem: 1,
    status: 'ativo',
    opcoes: [
      { id: 1, texto: 'Ainda não caminha sem apoio', valorNumerico: 0 },
      { id: 2, texto: 'Caminha com apoio ocasional', valorNumerico: 1 },
      { id: 3, texto: 'Caminha sozinha com firmeza', valorNumerico: 2 },
      { id: 4, texto: 'Não observei essa situação ainda', valorNumerico: 0 },
    ],
  },
];

function emptyPerguntaTriagem(): PerguntaTriagem {
  return {
    id: 0,
    codigo: '',
    skillKey: SKILLS[0].key,
    ageBracketCode: AGE_BRACKETS[0].code,
    texto: '',
    ordem: 1,
    status: 'ativo',
    opcoes: createDefaultOptions(),
  };
}

function matchesSearch(row: PerguntaTriagem, term: string): boolean {
  const skillLabel = getSkill(row.skillKey).label.toLowerCase();
  return row.codigo.toLowerCase().includes(term) || row.texto.toLowerCase().includes(term) || skillLabel.includes(term);
}

const columns: DataTableColumn<PerguntaTriagem>[] = [
  { key: 'codigo', header: 'Código', render: (row) => row.codigo || '—' },
  {
    key: 'skill',
    header: 'Habilidade',
    render: (row) => <Badge color={getSkill(row.skillKey).corHex}>{getSkill(row.skillKey).label}</Badge>,
  },
  { key: 'faixa', header: 'Faixa Etária', render: (row) => getAgeBracket(row.ageBracketCode).label },
  { key: 'texto', header: 'Pergunta', render: (row) => row.texto },
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

export function TriageQuestionsScreen() {
  return (
    <EntityCrudScreen<PerguntaTriagem>
      title="Perguntas de Triagem"
      newLabel="Nova Pergunta"
      formTitle={(isEditing) => (isEditing ? 'Editar Pergunta de Triagem' : 'Nova Pergunta de Triagem')}
      columns={columns}
      initialRows={MOCK_PERGUNTAS_TRIAGEM}
      matchesSearch={matchesSearch}
      emptyItem={emptyPerguntaTriagem}
      searchPlaceholder="Buscar por código, habilidade ou texto..."
      renderForm={(item, update) => (
        <>
          <FormField label="Código" hint="Referência do padrão FXAYZZZ — apenas um guia visual.">
            <input type="text" placeholder="Ex: F02AC001" value={item.codigo} onChange={(e) => update('codigo', e.target.value)} />
          </FormField>

          <FormField label="Habilidade" required>
            <Select
              value={item.skillKey}
              onChange={(v) => update('skillKey', v as HabilidadeKey)}
              options={SKILLS.map((s) => ({ value: s.key, label: s.label }))}
            />
          </FormField>

          <FormField label="Faixa Etária" required>
            <Select
              value={item.ageBracketCode}
              onChange={(v) => update('ageBracketCode', v as AgeBracketCode)}
              options={AGE_BRACKETS.map((a) => ({ value: a.code, label: `${a.code} · ${a.label}` }))}
            />
          </FormField>

          <FormField label="Ordem de Exibição">
            <input type="number" min={1} value={item.ordem} onChange={(e) => update('ordem', Number(e.target.value))} />
          </FormField>

          <FormField label="Status">
            <Select
              value={item.status}
              onChange={(v) => update('status', v as PerguntaTriagem['status'])}
              options={[
                { value: 'ativo', label: 'Ativo' },
                { value: 'arquivado', label: 'Arquivado' },
              ]}
            />
          </FormField>

          <FormField label="Texto da Pergunta" required fullWidth>
            <textarea rows={2} value={item.texto} onChange={(e) => update('texto', e.target.value)} />
          </FormField>

          <FormField label="Opções de Resposta" fullWidth hint="Usadas para calcular a idade funcional dessa habilidade.">
            <OptionListEditor options={item.opcoes} onChange={(opcoes) => update('opcoes', opcoes)} />
          </FormField>
        </>
      )}
    />
  );
}
