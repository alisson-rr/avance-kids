import { useState } from 'react';
import { Plus, Edit2, Archive, ArchiveRestore, ArrowLeft, Save } from 'lucide-react';
import {
  Badge,
  DataTable,
  ExportButton,
  FormField,
  ImageUploadField,
  MediaThumb,
  Select,
  Tabs,
  ConfirmDialog,
} from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import { useArchivableList, STATUS_FILTER_OPTIONS } from '../hooks/useArchivableList';
import { useEntityList } from '../hooks/useEntityList';
import { fetchAtividades, saveAtividade, toggleArchiveAtividade } from '../services/atividades';
import type { MediaType } from '../types/common';
import type { CsvColumn } from '../utils/csv';
import { youtubeId } from '../utils/youtube';
import {
  SKILLS,
  AGE_BRACKETS,
  EXERCISE_LEVELS,
  ACCESS_PLANS,
  getSkill,
  getAgeBracket,
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

function emptyAtividade(): Atividade {
  return {
    id: '',
    codigo: '',
    titulo: '',
    mediaType: 'imagem',
    mediaUrl: '',
    skillKey: SKILLS[0].key,
    ageBracketCode: AGE_BRACKETS[0].code,
    nivel: 'aquisicao',
    ordem: 1,
    plano: 'free',
    status: 'ativo',
    programaAba: '',
    funcao: '',
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

const EXPORT_COLUMNS: CsvColumn<Atividade>[] = [
  { header: 'ID', value: (row) => row.id },
  { header: 'Código', value: (row) => row.codigo },
  { header: 'Título', value: (row) => row.titulo },
  { header: 'Habilidade', value: (row) => getSkill(row.skillKey).label },
  { header: 'Faixa etária', value: (row) => `${row.ageBracketCode} · ${getAgeBracket(row.ageBracketCode).label}` },
  { header: 'Nível', value: (row) => EXERCISE_LEVELS.find((l) => l.value === row.nivel)?.label ?? row.nivel },
  { header: 'Plano', value: (row) => (row.plano === 'premium' ? 'Premium' : 'Gratuito') },
  { header: 'Ordem', value: (row) => row.ordem },
  { header: 'Status', value: (row) => (row.status === 'ativo' ? 'Ativo' : 'Arquivado') },
  { header: 'Tipo de mídia', value: (row) => (row.mediaType === 'video' ? 'Vídeo' : 'Imagem') },
  { header: 'URL da mídia', value: (row) => row.mediaUrl },
  { header: 'Programa ABA', value: (row) => row.programaAba },
  { header: 'Função', value: (row) => row.funcao },
  { header: 'Objetivo', value: (row) => row.objetivo },
  { header: 'Procedimento (Passo a Passo)', value: (row) => row.procedimento },
  { header: 'Materiais Necessários', value: (row) => row.materiais },
  { header: 'Recursos Extras', value: (row) => row.recursosExtras },
  { header: 'Frequência Recomendada', value: (row) => row.frequencia },
  { header: 'Exemplos de Brincadeiras', value: (row) => row.brincadeiras },
  { header: 'Hierarquia de Dicas', value: (row) => row.hierarquiaDicas },
  { header: 'Resposta Esperada', value: (row) => row.respostaEsperada },
  { header: 'Procedimento de Correção', value: (row) => row.procedimentoCorrecao },
  { header: 'Critério de Avanço', value: (row) => row.criterioAvanco },
  { header: 'Registro de Dados (Detalhado)', value: (row) => row.registroDados },
  { header: 'Exemplos de Reforços', value: (row) => row.reforcos },
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
  const { rows, loading, error, refresh } = useEntityList(fetchAtividades);
  const list = useArchivableList<Atividade>(rows, matchesSearch);
  const [view, setView] = useState<'list' | 'form'>('list');
  const [activeTab, setActiveTab] = useState<string>('basic');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [formState, setFormState] = useState<Atividade>(emptyAtividade());
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [listError, setListError] = useState<string | null>(null);
  const [nivelFilter, setNivelFilter] = useState('');
  const [faixaFilter, setFaixaFilter] = useState('');
  const [planoFilter, setPlanoFilter] = useState('');

  const filteredRows = list.filteredRows.filter(
    (row) =>
      (!nivelFilter || row.nivel === nivelFilter) &&
      (!faixaFilter || row.ageBracketCode === faixaFilter) &&
      (!planoFilter || row.plano === planoFilter)
  );

  function updateField<K extends keyof Atividade>(key: K, value: Atividade[K]) {
    setFormState((prev) => ({ ...prev, [key]: value }));
  }

  function openNew() {
    setFormState(emptyAtividade());
    setEditingId(null);
    setActiveTab('basic');
    setFormError(null);
    setView('form');
  }

  function openEdit(row: Atividade) {
    setFormState({ ...row });
    setEditingId(row.id);
    setActiveTab('basic');
    setFormError(null);
    setView('form');
  }

  async function handleSave() {
    if (saving) return;
    setSaving(true);
    setFormError(null);
    try {
      await saveAtividade(formState, editingId !== null);
      await refresh();
      setView('list');
    } catch (err) {
      setFormError(err instanceof Error ? err.message : 'Falha ao salvar a atividade.');
    } finally {
      setSaving(false);
    }
  }

  async function handleConfirmArchive() {
    const target = list.archiveTarget;
    if (!target) return;
    setListError(null);
    try {
      await toggleArchiveAtividade(target);
      await refresh();
    } catch (err) {
      setListError(err instanceof Error ? err.message : 'Falha ao atualizar a atividade.');
    } finally {
      list.setArchiveTarget(null);
    }
  }

  const columns: DataTableColumn<Atividade>[] = [
    {
      key: 'media',
      header: 'Mídia',
      width: '120px',
      render: (row) => <MediaThumb mediaType={row.mediaType} url={row.mediaUrl} />,
    },
    { key: 'titulo', header: 'Título', render: (row) => row.titulo, sortValue: (row) => row.titulo },
    { key: 'codigo', header: 'Código', render: (row) => row.codigo || '—', sortValue: (row) => row.codigo },
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
    {
      key: 'nivel',
      header: 'Nível',
      render: (row) => EXERCISE_LEVELS.find((l) => l.value === row.nivel)?.label ?? row.nivel,
      sortValue: (row) => EXERCISE_LEVELS.findIndex((l) => l.value === row.nivel),
    },
    {
      key: 'plano',
      header: 'Plano',
      render: (row) => (
        <Badge variant={row.plano === 'premium' ? 'danger' : 'neutral'}>
          {row.plano === 'premium' ? 'Premium' : 'Gratuito'}
        </Badge>
      ),
      sortValue: (row) => row.plano,
    },
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
    {
      key: 'actions',
      header: 'Ações',
      width: '100px',
      render: (row) => (
        // A linha inteira abre a edição; os botões não podem disparar esse clique por baixo.
        <div className={styles.actions} onClick={(e) => e.stopPropagation()} onKeyDown={(e) => e.stopPropagation()}>
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
            <div className={styles.headerActions}>
              <ExportButton fileBase="atividades" load={fetchAtividades} columns={EXPORT_COLUMNS} />
              <button className={styles.primaryButton} onClick={openNew} type="button">
                <Plus size={20} />
                <span>Nova Atividade</span>
              </button>
            </div>
          </div>

          {(error || listError) && <p className={styles.errorBanner}>{error || listError}</p>}

          <DataTable
            columns={columns}
            rows={filteredRows}
            getRowId={(row) => row.id}
            onRowClick={openEdit}
            searchValue={list.searchTerm}
            onSearchChange={list.setSearchTerm}
            searchPlaceholder="Buscar por código, habilidade ou objetivo..."
            emptyMessage={loading ? 'Carregando...' : 'Nenhuma atividade encontrada.'}
            toolbarExtra={
              <div className={styles.filterRow}>
                <div className={styles.filterItem}>
                  <Select
                    value={nivelFilter}
                    onChange={setNivelFilter}
                    options={[{ value: '', label: 'Todos os Níveis' }, ...EXERCISE_LEVELS]}
                  />
                </div>
                <div className={styles.filterItem}>
                  <Select
                    value={faixaFilter}
                    onChange={setFaixaFilter}
                    options={[
                      { value: '', label: 'Todas as Faixas' },
                      ...AGE_BRACKETS.map((a) => ({ value: a.code, label: `${a.code} · ${a.label}` })),
                    ]}
                  />
                </div>
                <div className={styles.filterItem}>
                  <Select
                    value={planoFilter}
                    onChange={setPlanoFilter}
                    options={[{ value: '', label: 'Todos os Planos' }, ...ACCESS_PLANS]}
                  />
                </div>
                <div className={styles.filterItem}>
                  <Select
                    value={list.statusFilter}
                    onChange={(v) => list.setStatusFilter(v as typeof list.statusFilter)}
                    options={STATUS_FILTER_OPTIONS}
                  />
                </div>
              </div>
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
            <button className={styles.primaryButton} onClick={handleSave} type="button" disabled={saving}>
              <Save size={20} />
              <span>{saving ? 'Salvando...' : 'Salvar Atividade'}</span>
            </button>
          </div>

          {formError && <p className={styles.errorBanner}>{formError}</p>}

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
                      {youtubeId(formState.mediaUrl) && (
                        <>
                          <MediaThumb size="large" mediaType="video" url={formState.mediaUrl} />
                          <span className={styles.previewNote}>Pré-visualização apenas demonstrativa</span>
                        </>
                      )}
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

                  <FormField label="Programa ABA">
                    <input
                      type="text"
                      value={formState.programaAba}
                      onChange={(e) => updateField('programaAba', e.target.value)}
                    />
                  </FormField>

                  <FormField label="Função">
                    <input
                      type="text"
                      value={formState.funcao}
                      onChange={(e) => updateField('funcao', e.target.value)}
                    />
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

                  <FormField
                    label="Ordem de Exibição"
                    hint="Define a sequência em que a atividade é liberada para a criança dentro da mesma habilidade, faixa e nível."
                  >
                    <input
                      type="number"
                      min={1}
                      value={formState.ordem}
                      onChange={(e) => updateField('ordem', Number(e.target.value))}
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
        onConfirm={handleConfirmArchive}
        onCancel={() => list.setArchiveTarget(null)}
      />
    </div>
  );
}
