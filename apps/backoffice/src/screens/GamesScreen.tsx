import { ACCESS_PLANS } from '../constants/aba';
import { Badge, EntityCrudScreen, FormField, ImageUploadField, Select } from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import type { Brincadeira, MediaType } from '../types/entities';

const MEDIA_TYPE_OPTIONS: { value: MediaType; label: string }[] = [
  { value: 'imagem', label: 'Imagem' },
  { value: 'video', label: 'Vídeo' },
];

const MOCK_BRINCADEIRAS: Brincadeira[] = [
  {
    id: 1,
    titulo: 'Caça ao Tesouro dos Sons',
    descricao: 'Brincadeira para estimular a atenção auditiva.',
    instrucoes: 'Esconda objetos que fazem som e peça para a criança encontrá-los guiada pelo som.',
    mediaType: 'imagem',
    mediaUrl: '',
    plano: 'free',
    status: 'ativo',
  },
  {
    id: 2,
    titulo: 'Corrida dos Bichos',
    descricao: 'Brincadeira de coordenação motora imitando animais.',
    instrucoes: 'Peça para a criança imitar o jeito de andar de diferentes animais.',
    mediaType: 'video',
    mediaUrl: '',
    plano: 'premium',
    status: 'ativo',
  },
];

function emptyBrincadeira(): Brincadeira {
  return {
    id: 0,
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
  { key: 'titulo', header: 'Título', render: (row) => row.titulo },
  {
    key: 'mediaType',
    header: 'Mídia',
    render: (row) => <Badge variant="neutral">{row.mediaType === 'video' ? 'Vídeo' : 'Imagem'}</Badge>,
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
];

export function GamesScreen() {
  return (
    <EntityCrudScreen<Brincadeira>
      title="Brincadeiras"
      newLabel="Nova Brincadeira"
      formTitle={(isEditing) => (isEditing ? 'Editar Brincadeira' : 'Nova Brincadeira')}
      columns={columns}
      initialRows={MOCK_BRINCADEIRAS}
      matchesSearch={matchesSearch}
      emptyItem={emptyBrincadeira}
      searchPlaceholder="Buscar por título ou descrição..."
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
