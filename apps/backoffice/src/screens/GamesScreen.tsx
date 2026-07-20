import { ACCESS_PLANS } from '../constants/aba';
import { Badge, EntityCrudScreen, FormField, ImageUploadField, Select } from '../components/ui';
import type { DataTableColumn, EntityFilterConfig } from '../components/ui';
import { useEntityList } from '../hooks/useEntityList';
import { fetchBrincadeiras, saveBrincadeira, toggleArchiveBrincadeira } from '../services/brincadeiras';
import type { Brincadeira, MediaType } from '../types/entities';

const MEDIA_TYPE_OPTIONS: { value: MediaType; label: string }[] = [
  { value: 'imagem', label: 'Imagem' },
  { value: 'video', label: 'Vídeo' },
];

function emptyBrincadeira(): Brincadeira {
  return {
    id: '',
    titulo: '',
    descricao: '',
    instrucoes: '',
    mediaType: 'imagem',
    mediaUrl: '',
    plano: 'free',
    status: 'ativo',
  };
}

function matchesSearch(row: Brincadeira, term: string): boolean {
  return row.titulo.toLowerCase().includes(term) || row.descricao.toLowerCase().includes(term);
}

const columns: DataTableColumn<Brincadeira>[] = [
  { key: 'titulo', header: 'Título', render: (row) => row.titulo, sortValue: (row) => row.titulo },
  {
    key: 'mediaType',
    header: 'Mídia',
    render: (row) => <Badge variant="neutral">{row.mediaType === 'video' ? 'Vídeo' : 'Imagem'}</Badge>,
    sortValue: (row) => row.mediaType,
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

const filters: EntityFilterConfig<Brincadeira>[] = [
  {
    key: 'plano',
    allLabel: 'Todos os Planos',
    options: ACCESS_PLANS,
    getValue: (row) => row.plano,
  },
];

export function GamesScreen() {
  const { rows, loading, error, refresh } = useEntityList(fetchBrincadeiras);

  return (
    <EntityCrudScreen<Brincadeira>
      title="Brincadeiras"
      newLabel="Nova Brincadeira"
      formTitle={(isEditing) => (isEditing ? 'Editar Brincadeira' : 'Nova Brincadeira')}
      columns={columns}
      rows={rows}
      loading={loading}
      errorMessage={error}
      matchesSearch={matchesSearch}
      emptyItem={emptyBrincadeira}
      searchPlaceholder="Buscar por título ou descrição..."
      filters={filters}
      onSave={async (item, isEditing) => {
        await saveBrincadeira(item, isEditing);
        await refresh();
      }}
      onToggleArchive={async (row) => {
        await toggleArchiveBrincadeira(row);
        await refresh();
      }}
      renderForm={(item, update) => (
        <>
          <FormField label="Título" required fullWidth>
            <input type="text" value={item.titulo} onChange={(e) => update('titulo', e.target.value)} />
          </FormField>

          <FormField label="Tipo de Mídia">
            <Select
              value={item.mediaType}
              onChange={(v) => {
                update('mediaType', v as MediaType);
                update('mediaUrl', '');
              }}
              options={MEDIA_TYPE_OPTIONS}
            />
          </FormField>

          {item.mediaType === 'imagem' ? (
            <FormField label="Imagem" fullWidth>
              <ImageUploadField value={item.mediaUrl} onChange={(dataUrl) => update('mediaUrl', dataUrl)} />
            </FormField>
          ) : (
            <FormField label="URL do Vídeo" hint="Link do YouTube/Vimeo.">
              <input type="text" value={item.mediaUrl} onChange={(e) => update('mediaUrl', e.target.value)} />
            </FormField>
          )}

          <FormField label="Plano de Acesso">
            <Select value={item.plano} onChange={(v) => update('plano', v as Brincadeira['plano'])} options={ACCESS_PLANS} />
          </FormField>

          <FormField label="Status">
            <Select
              value={item.status}
              onChange={(v) => update('status', v as Brincadeira['status'])}
              options={[
                { value: 'ativo', label: 'Ativo' },
                { value: 'arquivado', label: 'Arquivado' },
              ]}
            />
          </FormField>

          <FormField label="Descrição" fullWidth>
            <textarea rows={3} value={item.descricao} onChange={(e) => update('descricao', e.target.value)} />
          </FormField>

          <FormField label="Instruções" fullWidth>
            <textarea rows={4} value={item.instrucoes} onChange={(e) => update('instrucoes', e.target.value)} />
          </FormField>
        </>
      )}
    />
  );
}
