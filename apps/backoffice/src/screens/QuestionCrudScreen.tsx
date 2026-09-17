import { SKILLS, AGE_BRACKETS, getSkill, getAgeBracket, type HabilidadeKey, type AgeBracketCode } from '../constants/aba';
import { ANSWER_SCALE } from '../types/common';
import { Badge, EntityCrudScreen, FormField, MediaThumb, Select } from '../components/ui';
import type { DataTableColumn, EntityFilterConfig } from '../components/ui';
import { useEntityList } from '../hooks/useEntityList';
import { fetchPerguntas, savePergunta, toggleArchivePergunta, type QuestionKind } from '../services/perguntas';
import type { Pergunta } from '../types/entities';
import type { CsvColumn } from '../utils/csv';
import { youtubeId } from '../utils/youtube';
import layout from '../styles/crudLayout.module.css';
import styles from './QuestionCrudScreen.module.css';

interface QuestionCrudScreenProps {
  title: string;
  newLabel: string;
  formTitle: (isEditing: boolean) => string;
  kind: QuestionKind;
  searchPlaceholder: string;
}

// Fetchers estáveis por kind — useEntityList exige referência fixa.
const FETCHERS: Record<QuestionKind, () => Promise<Pergunta[]>> = {
  inicial: () => fetchPerguntas('inicial'),
  triagem: () => fetchPerguntas('triagem'),
};

const EXPORT_FILE_BASES: Record<QuestionKind, string> = {
  inicial: 'perguntas-iniciais',
  triagem: 'perguntas-triagem',
};

const exportColumns: CsvColumn<Pergunta>[] = [
  { header: 'ID', value: (row) => row.id },
  { header: 'Pergunta', value: (row) => row.texto },
  { header: 'Habilidade', value: (row) => getSkill(row.skillKey).label },
  { header: 'Faixa etária', value: (row) => `${row.ageBracketCode} · ${getAgeBracket(row.ageBracketCode).label}` },
  { header: 'Ordem', value: (row) => row.ordem },
  { header: 'Status', value: (row) => (row.status === 'ativo' ? 'Ativo' : 'Arquivado') },
  { header: 'Como responder (texto)', value: (row) => row.comoResponderTexto },
  { header: 'Como responder (vídeo)', value: (row) => row.comoResponderVideoUrl },
];

function emptyPergunta(): Pergunta {
  return {
    id: '',
    texto: '',
    skillKey: SKILLS[0].key,
    ageBracketCode: AGE_BRACKETS[0].code,
    ordem: 1,
    status: 'ativo',
    comoResponderTexto: '',
    comoResponderVideoUrl: '',
  };
}

function matchesSearch(row: Pergunta, term: string): boolean {
  const skillLabel = getSkill(row.skillKey).label.toLowerCase();
  return row.texto.toLowerCase().includes(term) || skillLabel.includes(term);
}

const filters: EntityFilterConfig<Pergunta>[] = [
  {
    key: 'skill',
    allLabel: 'Todas as Habilidades',
    options: SKILLS.map((s) => ({ value: s.key, label: s.label })),
    getValue: (row) => row.skillKey,
  },
  {
    key: 'faixa',
    allLabel: 'Todas as Faixas',
    options: AGE_BRACKETS.map((a) => ({ value: a.code, label: `${a.code} · ${a.label}` })),
    getValue: (row) => row.ageBracketCode,
  },
];

const columns: DataTableColumn<Pergunta>[] = [
  {
    key: 'skill',
    header: 'Habilidade',
    render: (row) => {
      const skill = getSkill(row.skillKey);
      return <Badge color={skill.tagText} backgroundColor={skill.tagBackground}>{skill.label}</Badge>;
    },
    sortValue: (row) => getSkill(row.skillKey).label,
  },
  {
    key: 'faixa',
    header: 'Faixa Etária',
    render: (row) => getAgeBracket(row.ageBracketCode).label,
    sortValue: (row) => row.ageBracketCode,
  },
  { key: 'texto', header: 'Pergunta', render: (row) => row.texto, sortValue: (row) => row.texto },
  { key: 'ordem', header: 'Ordem', width: '80px', render: (row) => row.ordem, sortValue: (row) => row.ordem },
  {
    key: 'status',
    header: 'Status',
    render: (row) => (
      <Badge variant={row.status === 'ativo' ? 'success' : 'neutral'}>
        {row.status === 'ativo' ? 'Ativo' : 'Arquivado'}
      </Badge>
    ),
    sortValue: (row) => row.status,
  },
];

export function QuestionCrudScreen({ title, newLabel, formTitle, kind, searchPlaceholder }: QuestionCrudScreenProps) {
  const { rows, loading, error, refresh } = useEntityList(FETCHERS[kind]);

  return (
    <EntityCrudScreen<Pergunta>
      title={title}
      newLabel={newLabel}
      formTitle={formTitle}
      columns={columns}
      rows={rows}
      loading={loading}
      errorMessage={error}
      matchesSearch={matchesSearch}
      emptyItem={emptyPergunta}
      searchPlaceholder={searchPlaceholder}
      filters={filters}
      exportConfig={{ fileBase: EXPORT_FILE_BASES[kind], load: FETCHERS[kind], columns: exportColumns }}
      onSave={async (item, isEditing) => {
        await savePergunta(kind, item, isEditing);
        await refresh();
      }}
      onToggleArchive={async (row) => {
        await toggleArchivePergunta(row);
        await refresh();
      }}
      renderForm={(item, update) => (
        <>
          <FormField label="Texto da Pergunta" required fullWidth>
            <textarea rows={2} value={item.texto} onChange={(e) => update('texto', e.target.value)} />
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
              onChange={(v) => update('status', v as Pergunta['status'])}
              options={[
                { value: 'ativo', label: 'Ativo' },
                { value: 'arquivado', label: 'Arquivado' },
              ]}
            />
          </FormField>

          <FormField label="Como responder: link do vídeo (YouTube)">
            <input
              type="url"
              value={item.comoResponderVideoUrl}
              onChange={(e) => update('comoResponderVideoUrl', e.target.value)}
            />
            {youtubeId(item.comoResponderVideoUrl) && (
              <>
                <MediaThumb size="large" mediaType="video" url={item.comoResponderVideoUrl} />
                <span className={layout.previewNote}>Pré-visualização apenas demonstrativa</span>
              </>
            )}
          </FormField>

          <FormField
            label="Como responder: texto"
            fullWidth
            hint="Com vídeo e texto vazios, a opção não aparece no app para esta pergunta."
          >
            <textarea
              rows={4}
              maxLength={5000}
              value={item.comoResponderTexto}
              onChange={(e) => update('comoResponderTexto', e.target.value)}
            />
          </FormField>

          <div className={layout.fullWidth}>
            <p className={styles.scaleNote}>
              Escala de resposta fixa (igual para todas as perguntas):{' '}
              {ANSWER_SCALE.map((s) => `${s.valorNumerico} = ${s.label}`).join(' · ')}
            </p>
          </div>
        </>
      )}
    />
  );
}
