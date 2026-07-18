import { ACCESS_PLANS } from '../constants/aba';
import { Badge, EntityCrudScreen, FormField, ImageUploadField, RichTextEditor, Select } from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import type { Artigo } from '../types/entities';

function stripHtml(html: string): string {
  return html.replace(/<[^>]*>/g, ' ');
}

const MOCK_ARTIGOS: Artigo[] = [
  {
    id: 1,
    titulo: 'A Importância do Sono para o Desenvolvimento Infantil',
    corpo: '<p>Dicas práticas para uma <strong>rotina de sono</strong> saudável...</p>',
    imagemUrl: '',
    plano: 'free',
    status: 'ativo',
  },
  {
    id: 2,
    titulo: 'Como Estruturar Rotinas Visuais em Casa',
    corpo: '<p>Um guia para pais sobre rotinas visuais...</p>',
    imagemUrl: '',
    plano: 'premium',
    status: 'ativo',
  },
];

function emptyArtigo(): Artigo {
  return { id: 0, titulo: '', corpo: '', imagemUrl: '', plano: 'free', status: 'ativo' };
}

function matchesSearch(row: Artigo, term: string): boolean {
  return row.titulo.toLowerCase().includes(term) || stripHtml(row.corpo).toLowerCase().includes(term);
}

const columns: DataTableColumn<Artigo>[] = [
  { key: 'titulo', header: 'Título', render: (row) => row.titulo },
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
];

export function ArticlesScreen() {
  return (
    <EntityCrudScreen<Artigo>
      title="Artigos"
      newLabel="Novo Artigo"
      formTitle={(isEditing) => (isEditing ? 'Editar Artigo' : 'Novo Artigo')}
      columns={columns}
      initialRows={MOCK_ARTIGOS}
      matchesSearch={matchesSearch}
      emptyItem={emptyArtigo}
      searchPlaceholder="Buscar por título ou conteúdo..."
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
