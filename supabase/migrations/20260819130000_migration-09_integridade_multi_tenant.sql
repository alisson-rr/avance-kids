-- ============================================================
-- migration-09: integridade multi-tenant da cadeia plano → sessão → tentativa
--
-- PROBLEMA (vulnerabilidade de autorização, não decisão pedagógica)
--
-- As policies de exercise_sessions e exercise_attempts validam apenas
-- `child_id` (baseline.sql:466-509):
--
--     EXISTS (SELECT 1 FROM children c
--              WHERE c.id = <tabela>.child_id AND c.user_id = auth.uid())
--
-- `session_id` e `plan_id` não são checados contra nada. Um usuário
-- autenticado podia então gravar linhas que apontam para entidades de outra
-- conta, usando o próprio child_id para passar pela RLS:
--
--   1. INSERT em exercise_sessions {child_id: criança-do-atacante,
--      plan_id: plano-da-vítima} — a policy passa;
--   2. register-attempt sobre essa sessão chega a 8/10 e chama
--      check_exercise_completion(session_id) como service_role, que faz
--      `UPDATE activity_plans SET status='concluido' WHERE id = es.plan_id`
--      (migration-05) — ou seja, conclui o plano DA VÍTIMA;
--   3. INSERT direto em exercise_attempts (PostgREST, sem passar por Edge
--      Function) {child_id: próprio, session_id/plan_id: da vítima} —
--      contamina a contagem de repetições de outra conta.
--
-- ESTRATÉGIA: chaves estrangeiras compostas, não predicado de RLS.
--
-- RLS só protege o caminho do usuário. As Edge Functions rodam com
-- service_role e ignoram RLS por definição, então um bug ali reabriria o
-- mesmo buraco. Constraint de FK vale para TODO mundo, inclusive service_role
-- e psql. Depois desta migration a travessia entre contas deixa de ser
-- "negada por policy" e passa a ser inexpressável no schema.
--
-- Garantia resultante, combinada com a RLS de child_id que já existe:
--   attempt.child_id  ∈ crianças do usuário          (RLS, inalterada)
--   attempt.(session,plan,child) = sessão real       (FK composta nova)
--   session.(plan,child)         = plano real        (FK composta nova)
--   ⇒ criança, plano e sessão são obrigatoriamente do mesmo tenant.
--
-- Nenhuma regra pedagógica é tocada: progressão, níveis A/G/M, faixas etárias
-- e gating premium continuam exatamente como estavam.
-- ============================================================

-- ── 0. Dados legados inconsistentes ─────────────────────────
-- Se o banco já tiver linha cruzada, as constraints abaixo falhariam com uma
-- mensagem genérica de FK. Aqui a migration para antes, dizendo quantas linhas
-- e onde — a limpeza é decisão de quem opera o banco, não deste arquivo.
DO $$
DECLARE
  v_sessoes INTEGER;
  v_tentativas INTEGER;
BEGIN
  SELECT count(*) INTO v_sessoes
    FROM exercise_sessions es
    JOIN activity_plans ap ON ap.id = es.plan_id
   WHERE ap.child_id <> es.child_id;

  SELECT count(*) INTO v_tentativas
    FROM exercise_attempts ea
    JOIN exercise_sessions es ON es.id = ea.session_id
   WHERE es.child_id <> ea.child_id OR es.plan_id <> ea.plan_id;

  IF v_sessoes > 0 OR v_tentativas > 0 THEN
    RAISE EXCEPTION
      'dados inconsistentes antes de aplicar migration-09: % sessões com plano de outra criança, % tentativas divergentes da sessão. Inspecione e resolva antes de reaplicar.',
      v_sessoes, v_tentativas;
  END IF;
END $$;

-- ── 1. Alvos das FKs compostas ──────────────────────────────
-- `id` já é PK, então (id, child_id) e (id, plan_id, child_id) são
-- naturalmente únicos; o UNIQUE existe só para poder ser referenciado.
ALTER TABLE activity_plans
  ADD CONSTRAINT uq_activity_plans_id_child UNIQUE (id, child_id);

ALTER TABLE exercise_sessions
  ADD CONSTRAINT uq_exercise_sessions_id_plan_child UNIQUE (id, plan_id, child_id);

-- ── 2. exercise_sessions.plan_id → plano da MESMA criança ───
ALTER TABLE exercise_sessions
  DROP CONSTRAINT exercise_sessions_plan_id_fkey;

ALTER TABLE exercise_sessions
  ADD CONSTRAINT exercise_sessions_plan_child_fkey
  FOREIGN KEY (plan_id, child_id) REFERENCES activity_plans (id, child_id)
  ON DELETE CASCADE;

-- ── 3. exercise_attempts → sessão real da MESMA criança ─────
-- Uma constraint de 3 colunas cobre os dois vetores de uma vez: a sessão tem
-- de ser da criança da tentativa E o plano informado tem de ser o plano
-- daquela sessão (antes dava para misturar dois planos legítimos do mesmo
-- usuário e embaralhar o próprio histórico).
ALTER TABLE exercise_attempts
  DROP CONSTRAINT exercise_attempts_session_id_fkey;

ALTER TABLE exercise_attempts
  DROP CONSTRAINT exercise_attempts_plan_id_fkey;

ALTER TABLE exercise_attempts
  ADD CONSTRAINT exercise_attempts_session_plan_child_fkey
  FOREIGN KEY (session_id, plan_id, child_id)
  REFERENCES exercise_sessions (id, plan_id, child_id)
  ON DELETE CASCADE;

-- Cascatas preservadas: apagar um plano derruba as sessões, que derrubam as
-- tentativas; apagar a criança continua derrubando as três pelas FKs de
-- child_id, que seguem intactas. Os índices existentes
-- (idx_exercise_sessions_plan_id, idx_exercise_attempts_session) são prefixo
-- das colunas das novas FKs, então a cascata continua indexada.

COMMENT ON CONSTRAINT exercise_sessions_plan_child_fkey ON exercise_sessions IS
  'Impede sessão apontando para plano de outra criança/conta. Vale também para service_role.';
COMMENT ON CONSTRAINT exercise_attempts_session_plan_child_fkey ON exercise_attempts IS
  'Impede tentativa apontando para sessão/plano de outra criança/conta. Vale também para service_role.';
