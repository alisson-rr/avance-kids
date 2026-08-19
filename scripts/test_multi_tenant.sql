-- Testes da correção de tenant crossing (migration-09).
--
-- Cenário: duas contas independentes, cada uma com criança, plano e sessão
-- próprios. Os testes negativos tentam, do lado da conta A, gravar linhas que
-- apontem para entidades da conta B — exatamente o que a RLS baseada só em
-- `child_id` deixava passar. Os positivos provam que o fluxo legítimo continua
-- funcionando: sessão, tentativa, conclusão do exercício e cascata.
--
-- Roda dentro de scripts/validate_migrations.sh, depois das migrations.
--
-- Identificadores (hex legível, sem significado além do teste):
--   a1.. usuário A   c1.. criança A   d1.. plano A   e1.. sessão A
--   b2.. usuário B   c2.. criança B   d2.. plano B   e2.. sessão B
--                                     d3.. 2º plano da conta A

\set ON_ERROR_STOP on

BEGIN;

INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
  ('a1111111-1111-1111-1111-111111111111', 'tenant-a@exemplo.test', '{"nome":"Conta A"}'::jsonb),
  ('b2222222-2222-2222-2222-222222222222', 'tenant-b@exemplo.test', '{"nome":"Conta B"}'::jsonb);

INSERT INTO children (id, user_id, nome, data_nascimento) VALUES
  ('c1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'Criança A', '2022-01-10'),
  ('c2222222-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'Criança B', '2022-01-10');

-- Planos apontando para atividades oficiais 'free': o gate premium de
-- migration-05 não interfere, então o que sobra sendo testado é autorização.
INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem)
SELECT 'd1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111',
       e.skill_id, e.id, 'ativo', 0
  FROM exercises e WHERE e.status = 'ativo' AND e.nivel = 'aquisicao' ORDER BY e.codigo LIMIT 1;

INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem)
SELECT 'd2222222-2222-2222-2222-222222222222', 'c2222222-2222-2222-2222-222222222222',
       e.skill_id, e.id, 'ativo', 0
  FROM exercises e WHERE e.status = 'ativo' AND e.nivel = 'aquisicao' ORDER BY e.codigo LIMIT 1;

-- Segundo plano da própria conta A: cobre a mistura de dois planos legítimos
-- do mesmo tenant, que também corrompia o histórico.
INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem)
SELECT 'd3333333-3333-3333-3333-333333333333', 'c1111111-1111-1111-1111-111111111111',
       e.skill_id, e.id, 'bloqueado', 1
  FROM exercises e WHERE e.status = 'ativo' AND e.nivel = 'generalizacao' ORDER BY e.codigo LIMIT 1;

INSERT INTO exercise_sessions (id, plan_id, child_id) VALUES
  ('e1111111-1111-1111-1111-111111111111', 'd1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111'),
  ('e2222222-2222-2222-2222-222222222222', 'd2222222-2222-2222-2222-222222222222', 'c2222222-2222-2222-2222-222222222222');

-- ============================================================
-- NEGATIVOS — conta A tentando atravessar para a conta B
-- ============================================================

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a1111111-1111-1111-1111-111111111111';

DO $$
DECLARE v_int INTEGER;
BEGIN
  -- 1. Sessão com a própria criança apontando para o PLANO DA VÍTIMA.
  --    Era o vetor mais grave: com 8 acertos, check_exercise_completion
  --    (service_role) concluía o plano da outra conta.
  BEGIN
    INSERT INTO exercise_sessions (plan_id, child_id)
    VALUES ('d2222222-2222-2222-2222-222222222222', 'c1111111-1111-1111-1111-111111111111');
    RAISE EXCEPTION 'FALHA: criou sessao apontando para plano de outra conta';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  -- 2. Sessão diretamente na criança da outra conta: barrado pela RLS.
  BEGIN
    INSERT INTO exercise_sessions (plan_id, child_id)
    VALUES ('d2222222-2222-2222-2222-222222222222', 'c2222222-2222-2222-2222-222222222222');
    RAISE EXCEPTION 'FALHA: criou sessao para crianca de outra conta';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;

  -- 3. Tentativa apontando para sessão E plano da vítima (INSERT direto na
  --    Data API, sem passar por register-attempt).
  BEGIN
    INSERT INTO exercise_attempts (session_id, plan_id, child_id, repeticao_numero, resultado)
    VALUES ('e2222222-2222-2222-2222-222222222222', 'd2222222-2222-2222-2222-222222222222',
            'c1111111-1111-1111-1111-111111111111', 1, 'sem_ajuda');
    RAISE EXCEPTION 'FALHA: gravou tentativa na sessao de outra conta';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  -- 4. Tentativa na própria sessão, mas com o plano da vítima.
  BEGIN
    INSERT INTO exercise_attempts (session_id, plan_id, child_id, repeticao_numero, resultado)
    VALUES ('e1111111-1111-1111-1111-111111111111', 'd2222222-2222-2222-2222-222222222222',
            'c1111111-1111-1111-1111-111111111111', 1, 'sem_ajuda');
    RAISE EXCEPTION 'FALHA: gravou tentativa com plano de outra conta';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  -- 5. Mesma conta, mas plano diferente do plano da sessão: também é lixo.
  BEGIN
    INSERT INTO exercise_attempts (session_id, plan_id, child_id, repeticao_numero, resultado)
    VALUES ('e1111111-1111-1111-1111-111111111111', 'd3333333-3333-3333-3333-333333333333',
            'c1111111-1111-1111-1111-111111111111', 1, 'sem_ajuda');
    RAISE EXCEPTION 'FALHA: gravou tentativa misturando dois planos do mesmo usuario';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  -- 6. Leitura e escrita na sessão alheia continuam invisíveis pela RLS.
  SELECT count(*) INTO v_int FROM exercise_sessions;
  IF v_int <> 1 THEN RAISE EXCEPTION 'FALHA: conta A enxerga % sessoes (esperado 1)', v_int; END IF;

  UPDATE exercise_sessions SET total_repetitions = 9
   WHERE id = 'e2222222-2222-2222-2222-222222222222';
  GET DIAGNOSTICS v_int = ROW_COUNT;
  IF v_int <> 0 THEN RAISE EXCEPTION 'FALHA: conta A atualizou a sessao de outra conta'; END IF;

  SELECT count(*) INTO v_int FROM exercise_attempts;
  IF v_int <> 0 THEN RAISE EXCEPTION 'FALHA: conta A enxerga tentativa alheia'; END IF;

  RAISE NOTICE 'multi-tenant: 5 travessias bloqueadas + isolamento de leitura/escrita OK';
END $$;

-- ============================================================
-- POSITIVOS — o fluxo legítimo da conta A continua funcionando
-- ============================================================

DO $$
DECLARE
  v_sessao UUID;
  v_int INTEGER;
BEGIN
  -- Sessão nova no próprio plano (é o que start-exercise-session faz).
  INSERT INTO exercise_sessions (plan_id, child_id)
  VALUES ('d1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111')
  RETURNING id INTO v_sessao;

  -- 10 repetições coerentes (é o que register-attempt faz).
  INSERT INTO exercise_attempts (session_id, plan_id, child_id, repeticao_numero, resultado)
  SELECT v_sessao, 'd1111111-1111-1111-1111-111111111111',
         'c1111111-1111-1111-1111-111111111111', g,
         CASE WHEN g <= 8 THEN 'sem_ajuda' ELSE 'ajuda_parcial' END::attempt_result
    FROM generate_series(1, 10) g;

  UPDATE exercise_sessions SET total_repetitions = 10, successful_count = 8
   WHERE id = v_sessao;
  GET DIAGNOSTICS v_int = ROW_COUNT;
  IF v_int <> 1 THEN RAISE EXCEPTION 'FALHA: conta A nao conseguiu atualizar a propria sessao'; END IF;

  SELECT count(*) INTO v_int FROM exercise_attempts WHERE session_id = v_sessao;
  IF v_int <> 10 THEN RAISE EXCEPTION 'FALHA: esperava 10 tentativas proprias, achei %', v_int; END IF;

  RAISE NOTICE 'multi-tenant: fluxo legitimo (sessao + 10 tentativas) OK';
END $$;

RESET ROLE;
RESET request.jwt.claim.sub;

-- ============================================================
-- SERVICE_ROLE / PROGRESSÃO — a trava não depende de RLS
-- ============================================================

DO $$
DECLARE
  v_sessao UUID;
  v_status plan_status;
  v_int INTEGER;
BEGIN
  -- 7. Quem ignora RLS (Edge Function, psql do operador) também não consegue
  --    cruzar as contas: a garantia é constraint, não policy.
  BEGIN
    INSERT INTO exercise_attempts (session_id, plan_id, child_id, repeticao_numero, resultado)
    VALUES ('e2222222-2222-2222-2222-222222222222', 'd2222222-2222-2222-2222-222222222222',
            'c1111111-1111-1111-1111-111111111111', 1, 'sem_ajuda');
    RAISE EXCEPTION 'FALHA: service_role conseguiu cruzar as contas';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  -- 8. Conclusão do exercício segue funcionando (progressão não foi tocada).
  SELECT id INTO v_sessao FROM exercise_sessions
   WHERE plan_id = 'd1111111-1111-1111-1111-111111111111' AND successful_count = 8
   ORDER BY started_at DESC LIMIT 1;

  IF check_exercise_completion(v_sessao) IS NOT TRUE THEN
    RAISE EXCEPTION 'FALHA: check_exercise_completion nao concluiu a sessao legitima';
  END IF;

  SELECT status INTO v_status FROM activity_plans
   WHERE id = 'd1111111-1111-1111-1111-111111111111';
  IF v_status <> 'concluido' THEN
    RAISE EXCEPTION 'FALHA: plano legitimo deveria estar concluido, esta %', v_status;
  END IF;

  -- 9. O plano da conta B não foi tocado por nada disso.
  SELECT status INTO v_status FROM activity_plans
   WHERE id = 'd2222222-2222-2222-2222-222222222222';
  IF v_status <> 'ativo' THEN
    RAISE EXCEPTION 'FALHA: plano da conta B mudou para %', v_status;
  END IF;

  -- 10. Cascata: apagar o plano derruba as sessões e as tentativas dele.
  DELETE FROM activity_plans WHERE id = 'd1111111-1111-1111-1111-111111111111';

  SELECT count(*) INTO v_int FROM exercise_sessions
   WHERE plan_id = 'd1111111-1111-1111-1111-111111111111';
  IF v_int <> 0 THEN RAISE EXCEPTION 'FALHA: % sessoes sobreviveram ao plano', v_int; END IF;

  SELECT count(*) INTO v_int FROM exercise_attempts
   WHERE plan_id = 'd1111111-1111-1111-1111-111111111111';
  IF v_int <> 0 THEN RAISE EXCEPTION 'FALHA: % tentativas sobreviveram ao plano', v_int; END IF;

  -- 11. E a cascata não passou por cima da outra conta.
  SELECT count(*) INTO v_int FROM exercise_sessions
   WHERE child_id = 'c2222222-2222-2222-2222-222222222222';
  IF v_int <> 1 THEN RAISE EXCEPTION 'FALHA: sessao da conta B sumiu'; END IF;

  RAISE NOTICE 'multi-tenant: bloqueio sob service_role, progressao e cascata OK';
END $$;

ROLLBACK;
