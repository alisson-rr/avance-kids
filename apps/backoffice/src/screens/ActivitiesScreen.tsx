import { useState } from 'react';
import { Plus, Edit2, Archive, ArchiveRestore, ArrowLeft, Save } from 'lucide-react';
import { Badge, DataTable, FormField, ImageUploadField, Select, Tabs, ConfirmDialog } from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import { useArchivableList } from '../hooks/useArchivableList';
import type { MediaType } from '../types/common';
import {
  SKILLS,
  AGE_BRACKETS,
  EXERCISE_LEVELS,
  ACCESS_PLANS,
  getSkill,
  getAgeBracket,
  buildProgramaLabel,
  type Atividade,
  type HabilidadeKey,
  type AgeBracketCode,
  type ExerciseLevel,
  type AccessPlan,
  type AtividadeStatus,
} from '../constants/aba';
import styles from '../styles/crudLayout.module.css';

const MEDIA_TYPE_OPTIONS: { value: MediaType; label: string }[] = [
  { value: 'imagem', label: 'Imagem' },
  { value: 'video', label: 'Vídeo' },
];

const MOCK_ATIVIDADES: Atividade[] = [
  {
    id: 1,
    codigo: 'F03AC004',
    titulo: 'Nomear Objetos do Cotidiano',
    mediaType: 'imagem',
    mediaUrl: '',
    skillKey: 'comunicacao',
    ageBracketCode: 'F03A',
    nivel: 'aquisicao',
    plano: 'free',
    status: 'ativo',
    objetivo: 'Nomear objetos do cotidiano de forma espontânea.',
    procedimento: '',
    materiais: 'Cartões de objetos do cotidiano.',
    recursosExtras: '',
    frequencia: '3x na semana',
    brincadeiras: '',
    hierarquiaDicas: '',
    respostaEsperada: '',
    procedimentoCorrecao: '',
    criterioAvanco: '',
    registroDados: '',
    reforcos: '',
  },
  {
    id: 2,
    codigo: 'F01AM001',
    titulo: 'Pular com os Dois Pés',
    mediaType: 'video',
    mediaUrl: '',
    skillKey: 'motora',
    ageBracketCode: 'F01A',
    nivel: 'generalizacao',
    plano: 'premium',
    status: 'ativo',
    objetivo: 'Pular com os dois pés juntos.',
    procedimento: '',
    materiais: '',
    recursosExtras: '',
    frequencia: '',
    brincadeiras: '',
    hierarquiaDicas: '',
    respostaEsperada: '',
    procedimentoCorrecao: '',
    criterioAvanco: '',
    registroDados: '',
    reforcos: '',
  },
  {
    id: 3,
    codigo: '',
    titulo: 'Brincar em Grupo Respeitando a Vez',
    mediaType: 'imagem',
    mediaUrl: '',
    skillKey: 'social',
    ageBracketCode: 'F02A',
    nivel: 'manutencao',
    plano: 'free',
    status: 'arquivado',
    objetivo: 'Brincar em grupo respeitando a vez (descontinuada).',
    procedimento: '',
    materiais: '',
    recursosExtras: '',
    frequencia: '',
    brincadeiras: '',
    hierarquiaDicas: '',
    respostaEsperada: '',
    procedimentoCorrecao: '',
    criterioAvanco: '',
    registroDados: '',
    reforcos: '',
  },
];

function emptyAtividade(): Atividade {
  return {
    id: 0,
    codigo: '',
    titulo: '',
    mediaType: 'imagem',
    mediaUrl: '',
    skillKey: SKILLS[0].key,
    ageBracketCode: AGE_BRACKETS[0].code,
    nivel: 'aquisicao',
    plano: 'free',
    status: 'ativo',
    objetivo: '',
    procedimento: '',
    materiais: '',
    recursosExtras: '',
    frequencia: '',
    brincadeiras: '',
    hierarquiaDicas: '',
    respostaEsperada: '',
    procedimentoCorrecao: '',
    criterioAvanco: '',
    registroDados: '',
    reforcos: '',
  };
}

const FORM_TABS = [
  { id: 'basic', label: '1. Informações Básicas' },
  { id: 'execution', label: '2. Execução & Materiais' },
  { id: 'evaluation', label: '3. Critérios & Avaliação' },
];

function matchesSearch(row: Atividade, term: string): boolean {
  const skillLabel = getSkill(row.skillKey).label.toLowerCase();
  return (
    row.titulo.toLowerCase().includes(term) ||
    row.codigo.toLowerCase().includes(term) ||
    skillLabel.includes(term) ||
    row.objetivo.toLowerCase().includes(term)
  );
}

export function ActivitiesScreen() {
  const list = useArchivableList<Atividade>(MOCK_ATIVIDADES, matchesSearch);
  const [view, setView] = useState<'list' | 'form'>('list');
  const [activeTab, setActiveTab] = useState<string>('basic');
  const [editingId, setEditingId] = useState<number | null>(null);
  const [formState, setFormState] = useState<Atividade>(emptyAtividade());

  function updateField<K extends keyof Atividade>(key: K, value: Atividade[K]) {
    setFormState((prev) => ({ ...prev, [key]: value }));
  }

  function openNew() {
    setFormState(emptyAtividade());
    setEditingId(null);
    setActiveTab('basic');
    setView('form');
  }

  function openEdit(row: Atividade) {
    setFormState({ ...row });
    setEditingId(row.id);
    setActiveTab('basic');
    setView('form');
  }

  function handleSave() {
    list.upsert(editingId !== null ? { ...formState, id: editingId } : formState);
    setView('list');
  }

  const columns: DataTableColumn<Atividade>[] = [
    { key: 'titulo', header: 'Título', render: (row) => row.titulo },
    { key: 'codigo', header: 'Código', render: (row) => row.codigo || '—' },
    {
      key: 'skill',
      header: 'Habilidade',
      render: (row) => <Badge color={getSkill(row.skillKey).corHex}>{getSkill(row.skillKey).label}</Badge>,
    },
    { key: 'faixa', header: 'Faixa Etária', render: (row) => getAgeBracket(row.ageBracketCode).label },
    {
      key: 'nivel',
      header: 'Nível',
      render: (row) => EXERCISE_LEVELS.find((l) => l.value === row.nivel)?.label ?? row.nivel,
    },
    {
      key: 'plano',
      header: 'Plano',
      render: (row) => (
        <Badge variant={row.plano === 'premium' ? 'danger' : 'neutral'}>
          {row.plano === 'premium' ? 'Premium' : 'Gratuito'}
        </Badge>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (row) => (
        <Badge variant={row.status === 'ativo' ? 'success' : 'neutral'}>
          {row.status === 'ativo' ? 'Ativo' : 'Arquivado'}
        </Badge>
      ),
    },
    {
      key: 'actions',
      header: 'Ações',
      width: '100px',
      render: (row) => (
        <div className={styles.actions}>
          <button className={styles.iconBtn} onClick={() => openEdit(row)} title="Editar" type="button">
            <Edit2 size={18} />
          </button>
          <button
            className={styles.iconBtnDanger}
            onClick={() => list.setArchiveTarget(row)}
            title={row.status === 'ativo' ? 'Arquivar' : 'Reativar'}
            type="button"
          >
            {row.status === 'ativo' ? <Archive size={18} /> : <ArchiveRestore size={18} />}
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className={styles.container}>
      {view === 'list' ? (
        <>
          <div className={styles.header}>
            <h1 className={styles.title}>Cadastro de Atividades</h1>
            <button className={styles.primaryButton} onClick={openNew} type="button">
              <Plus size={20} />
              <span>Nova Atividade</span>
            </button>
          </div>

          <DataTable
            columns={columns}
            rows={list.filteredRows}
            getRowId={(row) => row.id}
            searchValue={list.searchTerm}
            onSearchChange={list.setSearchTerm}
            searchPlaceholder="Buscar por código, habilidade ou objetivo..."
            emptyMessage="Nenhuma atividade encontrada."
            toolbarExtra={
              <label className={styles.showArchivedToggle}>
                <input
                  type="checkbox"
                  checked={list.showArchived}
                  onChange={(e) => list.setShowArchived(e.target.checked)}
                />
                <span>Mostrar arquivadas</span>
              </label>
            }
          />
        </>
      ) : (
        <>
          <div className={styles.header}>
            <div className={styles.backWrapper}>
              <button className={styles.iconBtn} onClick={() => setView('list')} type="button">
                <ArrowLeft size={24} />
              </button>
              <h1 className={styles.title}>{editingId !== null ? 'Editar Atividade' : 'Nova Atividade'} (Programa ABA)</h1>
            </div>
            <button className={styles.primaryButton} onClick={handleSave} type="button">
              <Save size={20} />
              <span>Salvar Atividade</span>
            </button>
          </div>

          <div className={styles.formCard}>
            <Tabs tabs={FORM_TABS} activeId={activeTab} onChange={setActiveTab} />

            <div className={styles.formContent}>
              {activeTab === 'basic' && (
                <div className={styles.gridContainer}>
                  <FormField label="Título" required fullWidth>
                    <input
                      type="text"
                      placeholder="Ex: Nomear Objetos do Cotidiano"
                      value={formState.titulo}
                      onChange={(e) => updateField('titulo', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Tipo de Mídia">
                    <Select
                      value={formState.mediaType}
                      onChange={(v) => {
                        updateField('mediaType', v as MediaType);
                        updateField('mediaUrl', '');
                      }}
                      options={MEDIA_TYPE_OPTIONS}
                    />
                  </FormField>

                  {formState.mediaType === 'imagem' ? (
                    <FormField label="Imagem">
                      <ImageUploadField
                        value={formState.mediaUrl}
                        onChange={(dataUrl) => updateField('mediaUrl', dataUrl)}
                      />
                    </FormField>
                  ) : (
                    <FormField label="URL do Vídeo" hint="Link do YouTube/Vimeo.">
                      <input
                        type="text"
                        value={formState.mediaUrl}
                        onChange={(e) => updateField('mediaUrl', e.target.value)}
                      />
                    </FormField>
                  )}

                  <FormField label="Código da Atividade" hint="Referência do padrão FXAYZZZ — apenas um guia visual, não é gerado automaticamente.">
                    <input
                      type="text"
                      placeholder="Ex: F03AC004"
                      value={formState.codigo}
                      onChange={(e) => updateField('codigo', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Habilidade" required>
                    <Select
                      value={formState.skillKey}
                      onChange={(v) => updateField('skillKey', v as HabilidadeKey)}
                      options={SKILLS.map((s) => ({ value: s.key, label: s.label }))}
                    />
                  </FormField>

                  <FormField label="Faixa Etária" required>
                    <Select
                      value={formState.ageBracketCode}
                      onChange={(v) => updateField('ageBracketCode', v as AgeBracketCode)}
                      options={AGE_BRACKETS.map((a) => ({ value: a.code, label: `${a.code} · ${a.label}` }))}
                    />
                  </FormField>

                  <FormField label="Programa ABA" hint="Gerado automaticamente a partir da Habilidade e Faixa Etária.">
                    <input type="text" value={buildProgramaLabel(formState.skillKey, formState.ageBracketCode)} readOnly />
                  </FormField>

                  <FormField label="Nível" required>
                    <Select
                      value={formState.nivel}
                      onChange={(v) => updateField('nivel', v as ExerciseLevel)}
                      options={EXERCISE_LEVELS}
                    />
                  </FormField>

                  <FormField label="Plano de Acesso">
                    <Select
                      value={formState.plano}
                      onChange={(v) => updateField('plano', v as AccessPlan)}
                      options={ACCESS_PLANS}
                    />
                  </FormField>

                  <FormField label="Status">
                    <Select
                      value={formState.status}
                      onChange={(v) => updateField('status', v as AtividadeStatus)}
                      options={[
                        { value: 'ativo', label: 'Ativo' },
                        { value: 'arquivado', label: 'Arquivado' },
                      ]}
                    />
                  </FormField>

                  <FormField label="Objetivo" required fullWidth>
                    <textarea
                      rows={3}
                      placeholder="Descreva o objetivo da atividade..."
                      value={formState.objetivo}
                      onChange={(e) => updateField('objetivo', e.target.value)}
                    />
                  </FormField>
                </div>
              )}

              {activeTab === 'execution' && (
                <div className={styles.gridContainer}>
                  <FormField label="Procedimento (Passo a Passo)" required fullWidth>
                    <textarea
                      rows={5}
                      placeholder="Descreva o passo a passo da execução..."
                      value={formState.procedimento}
                      onChange={(e) => updateField('procedimento', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Materiais Necessários" fullWidth>
                    <textarea
                      rows={2}
                      placeholder="Ex: Blocos lógicos, cartões..."
                      value={formState.materiais}
                      onChange={(e) => updateField('materiais', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Recursos Extras">
                    <input
                      type="text"
                      placeholder="Recursos visuais ou links"
                      value={formState.recursosExtras}
                      onChange={(e) => updateField('recursosExtras', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Frequência Recomendada">
                    <input
                      type="text"
                      placeholder="Ex: 3x na semana"
                      value={formState.frequencia}
                      onChange={(e) => updateField('frequencia', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Exemplos de Brincadeiras" fullWidth>
                    <textarea
                      rows={3}
                      placeholder="Ideias de como aplicar na prática..."
                      value={formState.brincadeiras}
                      onChange={(e) => updateField('brincadeiras', e.target.value)}
                    />
                  </FormField>
                </div>
              )}

              {activeTab === 'evaluation' && (
                <div className={styles.gridContainer}>
                  <FormField label="Hierarquia de Dicas">
                    <textarea
                      rows={3}
                      placeholder="Dica física total -> Dica leve..."
                      value={formState.hierarquiaDicas}
                      onChange={(e) => updateField('hierarquiaDicas', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Resposta Esperada">
                    <textarea
                      rows={3}
                      placeholder="O que a criança deve fazer..."
                      value={formState.respostaEsperada}
                      onChange={(e) => updateField('respostaEsperada', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Procedimento de Correção">
                    <textarea
                      rows={3}
                      placeholder="Como corrigir se errar..."
                      value={formState.procedimentoCorrecao}
                      onChange={(e) => updateField('procedimentoCorrecao', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Critério de Avanço">
                    <textarea
                      rows={3}
                      placeholder="Ex: 3 acertos seguidos..."
                      value={formState.criterioAvanco}
                      onChange={(e) => updateField('criterioAvanco', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Registro de Dados (Detalhado)">
                    <textarea
                      rows={3}
                      placeholder="Como registrar os acertos..."
                      value={formState.registroDados}
                      onChange={(e) => updateField('registroDados', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Exemplos de Reforços">
                    <textarea
                      rows={3}
                      placeholder="O que usar como prêmio..."
                      value={formState.reforcos}
                      onChange={(e) => updateField('reforcos', e.target.value)}
                    />
                  </FormField>
                </div>
              )}
            </div>
          </div>
        </>
      )}

      <ConfirmDialog
        open={list.archiveTarget !== null}
        title={list.archiveTarget?.status === 'ativo' ? 'Arquivar atividade?' : 'Reativar atividade?'}
        message={
          list.archiveTarget?.status === 'ativo'
            ? 'A atividade deixa de aparecer para os usuários, mas continua no histórico. Você pode reativá-la depois.'
            : 'A atividade volta a ficar disponível para os usuários.'
        }
        confirmLabel={list.archiveTarget?.status === 'ativo' ? 'Arquivar' : 'Reativar'}
        danger={list.archiveTarget?.status === 'ativo'}
        onConfirm={list.confirmArchive}
        onCancel={() => list.setArchiveTarget(null)}
      />
    </div>
  );
}
