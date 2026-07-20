import { Badge, EntityCrudScreen, FormField, Select } from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import { useEntityList } from '../hooks/useEntityList';
import { fetchAdmins, saveAdmin, toggleArchiveAdmin } from '../services/admins';
import type { AdminUser, AdminRole } from '../types/entities';

const ROLE_OPTIONS: { value: AdminRole; label: string }[] = [
  { value: 'admin', label: 'Administrador' },
  { value: 'super_admin', label: 'Super Administrador' },
];

function roleLabel(role: AdminRole): string {
  return ROLE_OPTIONS.find((r) => r.value === role)?.label ?? role;
}

function emptyAdminUser(): AdminUser {
  return { id: '', nome: '', email: '', role: 'admin', status: 'ativo', password: '' };
}

function matchesSearch(row: AdminUser, term: string): boolean {
  return row.nome.toLowerCase().includes(term) || row.email.toLowerCase().includes(term);
}

const columns: DataTableColumn<AdminUser>[] = [
  { key: 'nome', header: 'Nome', render: (row) => row.nome },
  { key: 'email', header: 'Email', render: (row) => row.email },
  {
    key: 'role',
    header: 'Papel',
    render: (row) => <Badge variant={row.role === 'super_admin' ? 'info' : 'neutral'}>{roleLabel(row.role)}</Badge>,
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

export function AdminUsersScreen() {
  const { rows, loading, error, refresh } = useEntityList(fetchAdmins);

  return (
    <EntityCrudScreen<AdminUser>
      title="Usuários Admin"
      newLabel="Novo Usuário"
      formTitle={(isEditing) => (isEditing ? 'Editar Usuário Admin' : 'Novo Usuário Admin')}
      columns={columns}
      rows={rows}
      loading={loading}
      errorMessage={error}
      matchesSearch={matchesSearch}
      emptyItem={emptyAdminUser}
      searchPlaceholder="Buscar por nome ou email..."
      onSave={async (item, isEditing) => {
        await saveAdmin(item, isEditing);
        await refresh();
      }}
      onToggleArchive={async (row) => {
        await toggleArchiveAdmin(row);
        await refresh();
      }}
      renderForm={(item, update) => {
        // id vazio = registro ainda não salvo (criação via edge function)
        const isNew = item.id === '';
        return (
          <>
            <FormField label="Nome" required>
              <input type="text" value={item.nome} onChange={(e) => update('nome', e.target.value)} />
            </FormField>

            <FormField
              label="Email"
              required
              hint={isNew ? undefined : 'O e-mail de login não pode ser alterado por aqui.'}
            >
              <input
                type="email"
                value={item.email}
                disabled={!isNew}
                onChange={(e) => update('email', e.target.value)}
              />
            </FormField>

            {isNew && (
              <FormField label="Senha Inicial" required hint="Mínimo de 8 caracteres. O admin pode trocá-la depois.">
                <input
                  type="password"
                  value={item.password ?? ''}
                  autoComplete="new-password"
                  onChange={(e) => update('password', e.target.value)}
                />
              </FormField>
            )}

            <FormField label="Papel">
              <Select value={item.role} onChange={(v) => update('role', v as AdminRole)} options={ROLE_OPTIONS} />
            </FormField>

            <FormField label="Status">
              <Select
                value={item.status}
                onChange={(v) => update('status', v as AdminUser['status'])}
                options={[
                  { value: 'ativo', label: 'Ativo' },
                  { value: 'arquivado', label: 'Arquivado' },
                ]}
              />
            </FormField>
          </>
        );
      }}
    />
  );
}
