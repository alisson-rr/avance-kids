-- ============================================================
-- migration-07: suporte à exclusão definitiva de conta
--
-- Mapa das dependências de auth.users no schema atual (todas verificadas no
-- baseline):
--
--   auth.users
--     └─ profiles (CASCADE)
--          ├─ children (CASCADE)
--          │    ├─ child_skill_ages        (CASCADE)
--          │    ├─ child_question_answers  (CASCADE)
--          │    ├─ activity_plans          (CASCADE)
--          │    ├─ exercise_sessions       (CASCADE)
--          │    └─ exercise_attempts       (CASCADE)
--          ├─ subscriptions   (CASCADE)
--          └─ payment_history (CASCADE)  <- alterado aqui
--     ├─ admin_users        (CASCADE)
--     └─ terms_acceptances  (CASCADE, migration-06)
--
-- Ou seja: `auth.admin.deleteUser()` já remove tudo em cascata. O que NÃO é
-- coberto por FK e precisa de tratamento explícito:
--   1. arquivos no bucket `avatars` (pasta `{user_id}/`) — removidos pela
--      Edge Function `delete-account`;
--   2. a assinatura viva no Stripe — cancelada pela mesma function, senão a
--      conta some do banco e o cartão continua sendo cobrado;
--   3. o histórico financeiro — tratado abaixo.
--
-- Sobre o histórico financeiro: o documento oficial de Termos e Privacidade
-- (Termos_e_Privacidade_Avance_Kids_Final.pdf, 17/08/2026) diz que na exclusão
-- da conta todos os dados são eliminados "ressalvadas as obrigações legais de
-- retenção de registros financeiros ou logs de acesso". Com o CASCADE atual,
-- payment_history sumiria junto com a conta e essa retenção seria impossível.
-- ============================================================

-- ============================================================
-- 1. RETENÇÃO ANONIMIZADA DO HISTÓRICO FINANCEIRO
-- ============================================================

ALTER TABLE payment_history
  ALTER COLUMN user_id DROP NOT NULL;

ALTER TABLE payment_history
  DROP CONSTRAINT payment_history_user_id_fkey;

ALTER TABLE payment_history
  ADD CONSTRAINT payment_history_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE SET NULL;

COMMENT ON COLUMN payment_history.user_id IS
  'NULL = conta excluída. A linha permanece anonimizada para a retenção fiscal; o vínculo com a transação fica em stripe_payment_intent_id.';

-- Com user_id NULL a linha deixa de casar com a policy "Users can view own
-- payments" (user_id = auth.uid()) e só o admin enxerga — que é o desejado:
-- o registro existe para obrigação legal, não para o titular excluído.

-- ============================================================
-- 2. LOG DE EXCLUSÕES
-- ============================================================

-- Sem FK para auth.users de propósito: a linha precisa sobreviver à remoção
-- do usuário — é justamente o registro de que a exclusão aconteceu.
CREATE TABLE account_deletions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,
  -- sha256 do e-mail em minúsculas: permite responder "a conta de fulano foi
  -- excluída?" a um pedido administrativo sem guardar o e-mail de quem pediu
  -- para ser esquecido.
  email_hash TEXT,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  teve_assinatura_paga BOOLEAN NOT NULL DEFAULT false,
  arquivos_removidos INTEGER NOT NULL DEFAULT 0,
  origem TEXT NOT NULL DEFAULT 'app',
  concluido_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE account_deletions IS
  'Registro pseudonimizado das exclusões de conta. Não contém dados pessoais além do UUID e do hash do e-mail.';

ALTER TABLE account_deletions ENABLE ROW LEVEL SECURITY;

-- Nenhuma policy para `authenticated`: só admin lê, só service_role escreve
-- (a Edge Function). Sem policy, a RLS nega tudo para os demais papéis.
CREATE POLICY "Admins read account deletions"
  ON account_deletions FOR SELECT
  TO authenticated
  USING (is_admin());

REVOKE INSERT, UPDATE, DELETE ON account_deletions FROM authenticated, anon;
