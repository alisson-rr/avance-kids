import { ACCESS_PLANS } from '../constants/aba';
import { Badge, EntityCrudScreen, FormField, ImageUploadField, RichTextEditor, Select } from '../components/ui';
import type { DataTableColumn, EntityFilterConfig } from '../components/ui';
import { useEntityList } from '../hooks/useEntityList';
import { fetchArtigos, saveArtigo, toggleArchiveArtigo } from '../services/artigos';
import type { Artigo } from '../types/entities';

function stripHtml(html: string): string {
  return html.replace(/<[^>]*>/g, ' ');
}

function emptyArtigo(): Artigo {
  return { id: '', titulo: '', corpo: '', imagemUrl: '', plano: 'free', status: 'ativo' };
}

function matchesSearch(row: Artigo, term: string): boolean {
  return row.titulo.toLowerCase().includes(term) || stripHtml(row.corpo).toLowerCase().includes(term);
}

const columns: DataTableColumn<Artigo>[] = [
  { key: 'titulo', header: 'Título', render: (row) => row.titulo, sortValue: (row) => row.titulo },
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

const filters: EntityFilterConfig<Artigo>[] = [
  {
    key: 'plano',
    allLabel: 'Todos os Planos',
    options: ACCESS_PLANS,
    getValue: (row) => row.plano,
  },
];

export function ArticlesScreen() {
  const { rows, loading, error, refresh } = useEntityList(fetchArtigos);

  return (
    <EntityCrudScreen<Artigo>
      title="Artigos"
      newLabel="Novo Artigo"
      formTitle={(isEditing) => (isEditing ? 'Editar Artigo' : 'Novo Artigo')}
      columns={columns}
      rows={rows}
      loading={loading}
      errorMessage={error}
      matchesSearch={matchesSearch}
      emptyItem={emptyArtigo}
      searchPlaceholder="Buscar por título ou conteúdo..."
      filters={filters}
      onSave={async (item, isEditing) => {
        await saveArtigo(item, isEditing);
        await refresh();
      }}
      onToggleArchive={async (row) => {
        await toggleArchiveArtigo(row);
        await refresh();
      }}
      renderForm={(item, update) => (
        <>
          <FormField label="Título" required fullWidth>
            <input type="text" value={item.titulo} onChange={(e) => update('titulo', e.target.value)} />
          </FormField>

          <FormField label="Imagem de Capa" fullWidth>
            <ImageUploadField value={item.imagemUrl} onChange={(dataUrl) => update('imagemUrl', dataUrl)} />
          </FormField>

          <FormField label="Plano de Acesso">
            <Select value={item.plano} onChange={(v) => update('plano', v as Artigo['plano'])} options={ACCESS_PLANS} />
          </FormField>

          <FormField label="Status">
            <Select
              value={item.status}
              onChange={(v) => update('status', v as Artigo['status'])}
              options={[
                { value: 'ativo', label: 'Ativo' },
                { value: 'arquivado', label: 'Arquivado' },
              ]}
            />
          </FormField>

          <FormField label="Corpo do Artigo" required fullWidth>
            <RichTextEditor value={item.corpo} onChange={(html) => update('corpo', html)} />
          </FormField>
        </>
      )}
    />
  );
}
