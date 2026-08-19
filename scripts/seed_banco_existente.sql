-- Carga que simula um banco já em uso, aplicada ANTES das migrations 09 e 10.
--
-- Serve ao modo `upgrade` de validate_migrations.sh: a migration-09 troca FKs
-- simples por FKs compostas em tabelas que, num banco real, já têm linhas. Sem
-- este cenário a validação só provaria que as migrations rodam do zero.
--
-- Só dados coerentes: uma conta, uma criança, um plano concluído com sessão
-- fechada e 10 tentativas, e um segundo plano ativo. Dado cruzado entre contas
-- faria a migration-09 abortar de propósito (é a checagem 0 dela).

INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
  ('9e9e9e9e-0000-0000-0000-00000000e001', 'existente@exemplo.test', '{"nome":"Conta Existente"}'::jsonb);

INSERT INTO children (id, user_id, nome, data_nascimento) VALUES
  ('9e9e9e9e-0000-0000-0000-00000000c001', '9e9e9e9e-0000-0000-0000-00000000e001', 'Criança Existente', '2021-05-04');

INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem, started_at, completed_at)
SELECT '9e9e9e9e-0000-0000-0000-00000000a001', '9e9e9e9e-0000-0000-0000-00000000c001',
       e.skill_id, e.id, 'concluido', 0, now() - interval '10 days', now() - interval '3 days'
  FROM exercises e WHERE e.status = 'ativo' AND e.nivel = 'aquisicao' ORDER BY e.codigo LIMIT 1;

INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem, started_at)
SELECT '9e9e9e9e-0000-0000-0000-00000000a002', '9e9e9e9e-0000-0000-0000-00000000c001',
       e.skill_id, e.id, 'ativo', 1, now() - interval '3 days'
  FROM exercises e WHERE e.status = 'ativo' AND e.nivel = 'generalizacao' ORDER BY e.codigo LIMIT 1;

INSERT INTO exercise_sessions (id, plan_id, child_id, total_repetitions, successful_count, is_completed)
VALUES ('9e9e9e9e-0000-0000-0000-00000000b001', '9e9e9e9e-0000-0000-0000-00000000a001',
        '9e9e9e9e-0000-0000-0000-00000000c001', 10, 9, true);

INSERT INTO exercise_attempts (session_id, plan_id, child_id, repeticao_numero, resultado)
SELECT '9e9e9e9e-0000-0000-0000-00000000b001', '9e9e9e9e-0000-0000-0000-00000000a001',
       '9e9e9e9e-0000-0000-0000-00000000c001', g,
       CASE WHEN g <= 9 THEN 'sem_ajuda' ELSE 'ajuda_total' END::attempt_result
  FROM generate_series(1, 10) g;

INSERT INTO payment_history (user_id, stripe_payment_intent_id, amount_cents, status, paid_at)
VALUES ('9e9e9e9e-0000-0000-0000-00000000e001', 'pi_existente', 2990, 'succeeded', now() - interval '5 days');
