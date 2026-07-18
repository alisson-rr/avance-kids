import { Badge, EntityCrudScreen, FormField, Select } from '../components/ui';
import type { DataTableColumn } from '../components/ui';
import type { AdminUser, AdminRole } from '../types/entities';

const ROLE_OPTIONS: { value: AdminRole; label: string }[] = [
  { value: 'admin', label: 'Administrador' },
  { value: 'super_admin', label: 'Super Administrador' },
];

function roleLabel(role: AdminRole): string {
  return ROLE_OPTIONS.find((r) => r.value === role)?.label ?? role;
}

const MOCK_ADMIN_USERS: AdminUser[] = [
  { id: 1, nome: 'Alisson Rosa', email: 'alisson@avancekids.com', role: 'super_admin', status: 'ativo' },
  { id: 2, nome: 'Equipe Pedagógica', email: 'pedagogico@avancekids.com', role: 'admin', status: 'ativo' },
];

function emptyAdminUser(): AdminUser {
  return { id: 0, nome: '', email: '', role: 'admin', status: 'ativo' };
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
  return (
    <EntityCrudScreen<AdminUser>
      title="Usuários Admin"
      newLabel="Novo Usuário"
      formTitle={(isEditing) => (isEditing ? 'Editar Usuário Admin' : 'Novo Usuário Admin')}
      columns={columns}
      initialRows={MOCK_ADMIN_USERS}
      matchesSearch={matchesSearch}
      emptyItem={emptyAdminUser}
      searchPlaceholder="Buscar por nome ou email..."
      renderForm={(item, update) => (
        <>
          <FormField label="Nome" required>
            <input type="text" value={item.nome} onChange={(e) => update('nome', e.target.value)} />
          </FormField>

          <FormField label="Email" required>
            <input type="email" value={item.email} onChange={(e) => update('email', e.target.value)} />
          </FormField>

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
      )}
    />
  );
}
