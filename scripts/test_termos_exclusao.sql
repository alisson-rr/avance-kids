-- Testes das garantias de banco que sustentam accept-terms e delete-account.
--
-- Rodam dentro de scripts/validate_migrations.sh, depois das migrations, em um
-- Postgres descartável. O que está testado aqui é o que o banco garante mesmo
-- que a Edge Function tenha bug: unicidade, isolamento por RLS, ausência de
-- privilégio de escrita, cascata da exclusão e retenção do histórico financeiro.

\set ON_ERROR_STOP on

BEGIN;

-- ── Cenário: dois responsáveis, cada um com uma criança e um pagamento ──
-- O trigger on_auth_user_created (migration-02) já cria profile e subscription
-- a partir do metadata; inserir profile à mão aqui colidiria com ele.
INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
  ('11111111-1111-1111-1111-111111111111', 'a@exemplo.test', '{"nome":"Responsável A"}'::jsonb),
  ('22222222-2222-2222-2222-222222222222', 'b@exemplo.test', '{"nome":"Responsável B"}'::jsonb);

UPDATE subscriptions SET plano = 'premium', status = 'active'
 WHERE user_id = '11111111-1111-1111-1111-111111111111';

INSERT INTO children (id, user_id, nome, data_nascimento) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Criança A', '2022-01-10'),
  ('bbbbbbbb-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'Criança B', '2022-01-10');

INSERT INTO payment_history (user_id, stripe_payment_intent_id, amount_cents, status, paid_at) VALUES
  ('11111111-1111-1111-1111-111111111111', 'pi_teste_a', 2990, 'succeeded', now()),
  ('22222222-2222-2222-2222-222222222222', 'pi_teste_b', 2990, 'succeeded', now());

-- Plano + sessão + tentativa da criança A, para provar a cascata profunda.
INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem)
SELECT 'cccccccc-0000-0000-0000-000000000003',
       'aaaaaaaa-0000-0000-0000-000000000001', e.skill_id, e.id, 'ativo', 0
FROM exercises e WHERE e.status = 'ativo' ORDER BY e.codigo, e.nivel LIMIT 1;

INSERT INTO exercise_sessions (id, plan_id, child_id)
VALUES ('dddddddd-0000-0000-0000-000000000004',
        'cccccccc-0000-0000-0000-000000000003',
        'aaaaaaaa-0000-0000-0000-000000000001');

INSERT INTO exercise_attempts (session_id, plan_id, child_id, repeticao_numero, resultado)
VALUES ('dddddddd-0000-0000-0000-000000000004',
        'cccccccc-0000-0000-0000-000000000003',
        'aaaaaaaa-0000-0000-0000-000000000001', 1, 'sem_ajuda');

-- ============================================================
-- ACEITE DOS TERMOS
-- ============================================================

DO $$
DECLARE
  v_doc UUID;
  v_int INTEGER;
  v_primeiro TIMESTAMPTZ;
  v_depois TIMESTAMPTZ;
BEGIN
  SELECT id INTO v_doc FROM terms_documents WHERE tipo = 'termos_e_privacidade' AND vigente;
  IF v_doc IS NULL THEN RAISE EXCEPTION 'documento vigente não encontrado'; END IF;

  -- 1. Aceite gravado com versão, data e IP (o que a Edge Function faz).
  INSERT INTO terms_acceptances (user_id, document_id, tipo, versao, ip, user_agent)
  VALUES ('11111111-1111-1111-1111-111111111111', v_doc, 'termos_e_privacidade',
          '2026-08-17', '203.0.113.7'::inet, 'AvanceKids/1.0');

  SELECT aceito_em INTO v_primeiro FROM terms_acceptances
   WHERE user_id = '11111111-1111-1111-1111-111111111111';

  -- 2. Idempotência: reenviar não duplica nem reescreve a data do primeiro aceite.
  INSERT INTO terms_acceptances (user_id, document_id, tipo, versao, ip)
  VALUES ('11111111-1111-1111-1111-111111111111', v_doc, 'termos_e_privacidade',
          '2026-08-17', '198.51.100.9'::inet)
  ON CONFLICT (user_id, document_id) DO NOTHING;

  SELECT count(*), max(aceito_em) INTO v_int, v_depois
    FROM terms_acceptances WHERE user_id = '11111111-1111-1111-1111-111111111111';

  IF v_int <> 1 THEN RAISE EXCEPTION 'reenvio duplicou o aceite (% linhas)', v_int; END IF;
  IF v_depois <> v_primeiro THEN RAISE EXCEPTION 'reenvio reescreveu aceito_em'; END IF;

  -- 3. Só pode haver uma versão vigente por tipo.
  BEGIN
    INSERT INTO terms_documents (tipo, versao, titulo, vigente)
    VALUES ('termos_e_privacidade', '2027-01-01', 'Versão nova', true);
    RAISE EXCEPTION 'aceitou duas versões vigentes do mesmo tipo';
  EXCEPTION WHEN unique_violation THEN
    NULL;  -- esperado
  END;

  -- 4. Aceite de outro usuário, para o teste de isolamento abaixo.
  INSERT INTO terms_acceptances (user_id, document_id, tipo, versao)
  VALUES ('22222222-2222-2222-2222-222222222222', v_doc, 'termos_e_privacidade', '2026-08-17');

  RAISE NOTICE 'aceite: unicidade, idempotência e vigência OK';
END $$;

-- 5. RLS: o usuário logado enxerga só o próprio aceite.
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';

DO $$
DECLARE v_int INTEGER;
BEGIN
  SELECT count(*) INTO v_int FROM terms_acceptances;
  IF v_int <> 1 THEN
    RAISE EXCEPTION 'RLS de terms_acceptances vazou: usuário vê % linhas (esperado 1)', v_int;
  END IF;

  SELECT count(*) INTO v_int FROM terms_acceptances
   WHERE user_id = '22222222-2222-2222-2222-222222222222';
  IF v_int <> 0 THEN RAISE EXCEPTION 'usuário conseguiu ler o aceite de outra conta'; END IF;

  -- 6. Escrever o aceite tem que ser impossível pelo client: é isso que obriga
  --    a passar pela Edge Function, onde versão, data e IP são do servidor.
  --    Checado pelo privilégio, não por um INSERT que poderia falhar por outro
  --    motivo (a linha do usuário já existe e daria unique_violation).
  IF has_table_privilege('authenticated', 'terms_acceptances', 'INSERT')
     OR has_table_privilege('authenticated', 'terms_acceptances', 'UPDATE')
     OR has_table_privilege('authenticated', 'terms_acceptances', 'DELETE') THEN
    RAISE EXCEPTION 'authenticated ainda tem privilégio de escrita em terms_acceptances';
  END IF;

  IF has_table_privilege('authenticated', 'account_deletions', 'INSERT') THEN
    RAISE EXCEPTION 'authenticated ainda tem privilégio de escrita em account_deletions';
  END IF;

  BEGIN
    INSERT INTO terms_acceptances (user_id, document_id, tipo, versao)
    SELECT '11111111-1111-1111-1111-111111111111', id, tipo, 'forjada'
      FROM terms_documents WHERE vigente;
    RAISE EXCEPTION 'client conseguiu inserir aceite direto na tabela';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;  -- esperado
  END;

  RAISE NOTICE 'aceite: isolamento por RLS e bloqueio de escrita OK';
END $$;

RESET ROLE;
RESET request.jwt.claim.sub;

-- ============================================================
-- EXCLUSÃO DE CONTA
-- ============================================================

DO $$
DECLARE
  v_usuario UUID := '11111111-1111-1111-1111-111111111111';
  v_outro UUID := '22222222-2222-2222-2222-222222222222';
  v_int INTEGER;
BEGIN
  -- O que a Edge Function grava antes de apagar.
  INSERT INTO account_deletions (user_id, email_hash, stripe_customer_id, teve_assinatura_paga, arquivos_removidos)
  VALUES (v_usuario, 'hash_do_email', 'cus_teste', true, 2);

  -- Equivalente a auth.admin.deleteUser().
  DELETE FROM auth.users WHERE id = v_usuario;

  -- 1. Cascata completa dos dados pessoais.
  SELECT count(*) INTO v_int FROM profiles WHERE id = v_usuario;
  IF v_int <> 0 THEN RAISE EXCEPTION 'profile sobreviveu à exclusão'; END IF;

  SELECT count(*) INTO v_int FROM children WHERE user_id = v_usuario;
  IF v_int <> 0 THEN RAISE EXCEPTION 'criança sobreviveu à exclusão'; END IF;

  SELECT count(*) INTO v_int FROM activity_plans
   WHERE child_id = 'aaaaaaaa-0000-0000-0000-000000000001';
  IF v_int <> 0 THEN RAISE EXCEPTION 'plano sobreviveu à exclusão'; END IF;

  SELECT count(*) INTO v_int FROM exercise_sessions
   WHERE child_id = 'aaaaaaaa-0000-0000-0000-000000000001';
  IF v_int <> 0 THEN RAISE EXCEPTION 'sessão sobreviveu à exclusão'; END IF;

  SELECT count(*) INTO v_int FROM exercise_attempts
   WHERE child_id = 'aaaaaaaa-0000-0000-0000-000000000001';
  IF v_int <> 0 THEN RAISE EXCEPTION 'tentativa sobreviveu à exclusão'; END IF;

  SELECT count(*) INTO v_int FROM subscriptions WHERE user_id = v_usuario;
  IF v_int <> 0 THEN RAISE EXCEPTION 'assinatura sobreviveu à exclusão'; END IF;

  SELECT count(*) INTO v_int FROM terms_acceptances WHERE user_id = v_usuario;
  IF v_int <> 0 THEN RAISE EXCEPTION 'aceite sobreviveu à exclusão'; END IF;

  -- 2. Histórico financeiro retido e anonimizado (não apagado).
  SELECT count(*) INTO v_int FROM payment_history
   WHERE stripe_payment_intent_id = 'pi_teste_a' AND user_id IS NULL;
  IF v_int <> 1 THEN
    RAISE EXCEPTION 'payment_history deveria continuar existindo com user_id NULL';
  END IF;

  -- 3. O registro da exclusão sobrevive ao usuário.
  SELECT count(*) INTO v_int FROM account_deletions WHERE user_id = v_usuario;
  IF v_int <> 1 THEN RAISE EXCEPTION 'account_deletions foi apagado junto com o usuário'; END IF;

  -- 4. Nada da outra conta foi tocado.
  SELECT count(*) INTO v_int FROM children WHERE user_id = v_outro;
  IF v_int <> 1 THEN RAISE EXCEPTION 'exclusão atingiu dados de outro usuário'; END IF;

  SELECT count(*) INTO v_int FROM payment_history
   WHERE stripe_payment_intent_id = 'pi_teste_b' AND user_id = v_outro;
  IF v_int <> 1 THEN RAISE EXCEPTION 'pagamento de outro usuário foi alterado'; END IF;

  SELECT count(*) INTO v_int FROM terms_acceptances WHERE user_id = v_outro;
  IF v_int <> 1 THEN RAISE EXCEPTION 'aceite de outro usuário foi apagado'; END IF;

  RAISE NOTICE 'exclusão: cascata, retenção fiscal e isolamento OK';
END $$;

ROLLBACK;
