-- Testes das decisões da cliente (migration-11) e da progressão por atividade
-- (migration-12).
--
-- Cobre, na ordem: faixas etárias sem lacuna, NV fora das médias de idade,
-- plano começando em Aquisição, Generalização exigindo 3 dias distintos,
-- rebaixamento automático de faixa com piso em F01A e a travessia A→G→M
-- casando pela mesma atividade, com o filtro de plano só na virada.
--
-- Roda dentro de scripts/validate_migrations.sh, depois das migrations.
-- Tudo dentro de uma transação com ROLLBACK: nenhum dado sobrevive ao teste.
--
-- Identificadores (hex legível, sem significado além do teste):
--   f1.. usuário    91.. criança do teste de NV    92.. criança do rebaixamento
--   93.. criança da Generalização    94.. criança da progressão
--   aa.. planos    bb.. sessões

\set ON_ERROR_STOP on

BEGIN;

INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
  ('f1111111-1111-1111-1111-111111111111', 'logica@exemplo.test', '{"nome":"Conta Lógica"}'::jsonb);

-- ============================================================
-- 1. FAIXAS ETÁRIAS (D4) — contíguas de 12 a 143 meses
-- ============================================================

DO $$
DECLARE
  v_codigo TEXT;
  v_mes INTEGER;
  v_sem_faixa INTEGER;
  v_esperado TEXT;
BEGIN
  -- Os limites exatos decididos pela cliente.
  FOR v_mes, v_esperado IN
    SELECT * FROM (VALUES
      (12,'F01A'::text), (24,'F01A'),
      (25,'F02A'), (36,'F02A'),
      (37,'F03A'), (48,'F03A'),
      (49,'F04A'), (60,'F04A'),
      (61,'F05A'), (71,'F05A'), (95,'F05A'),
      (96,'F06A'), (143,'F06A')
    ) t(mes, codigo)
  LOOP
    SELECT codigo INTO v_codigo FROM age_brackets WHERE id = resolve_age_bracket(v_mes);
    IF v_codigo IS DISTINCT FROM v_esperado THEN
      RAISE EXCEPTION 'FALHA: % meses resolveu % (esperava %)', v_mes, v_codigo, v_esperado;
    END IF;
  END LOOP;

  -- Clamp nas duas pontas. 144 é o caso que o clamp antigo (LEAST(144,...))
  -- jogava no ramo de lacuna: 12 anos exatos precisa cair em F06A pelo
  -- caminho normal.
  FOR v_mes, v_esperado IN
    SELECT * FROM (VALUES (0,'F01A'::text), (11,'F01A'), (144,'F06A'), (200,'F06A')) t(mes, codigo)
  LOOP
    SELECT codigo INTO v_codigo FROM age_brackets WHERE id = resolve_age_bracket(v_mes);
    IF v_codigo IS DISTINCT FROM v_esperado THEN
      RAISE EXCEPTION 'FALHA: clamp de % meses resolveu % (esperava %)', v_mes, v_codigo, v_esperado;
    END IF;
  END LOOP;

  -- Nenhum mês entre 12 e 143 depende do ramo de fallback de lacuna: todos
  -- casam com alguma faixa por [meses_min, meses_max].
  SELECT count(*) INTO v_sem_faixa
  FROM generate_series(12, 143) m
  WHERE NOT EXISTS (
    SELECT 1 FROM age_brackets b WHERE m BETWEEN b.meses_min AND b.meses_max
  );
  IF v_sem_faixa <> 0 THEN
    RAISE EXCEPTION 'FALHA: % meses entre 12 e 143 sem faixa (lacuna reaberta)', v_sem_faixa;
  END IF;

  RAISE NOTICE 'faixas: 12..143 contíguas, clamp em 143, sem lacuna';
END $$;

-- ============================================================
-- 2. NV FORA DAS MÉDIAS DE IDADE (D2)
-- ============================================================

INSERT INTO children (id, user_id, nome, data_nascimento, idade_biologica_meses)
VALUES ('91111111-1111-1111-1111-111111111111',
        'f1111111-1111-1111-1111-111111111111', 'Criança NV', '2022-01-10', 48);

DO $$
DECLARE
  v_faixa UUID;
  v_skill UUID;
  v_idade INTEGER;
BEGIN
  SELECT id INTO v_faixa FROM age_brackets WHERE codigo = 'F03A';   -- 37-48 meses
  SELECT id INTO v_skill FROM skills WHERE key = 'comunicacao';

  -- Cenário A: TODAS as perguntas iniciais respondidas como NV.
  INSERT INTO child_question_answers (child_id, question_id, valor_numerico, nao_observado)
  SELECT '91111111-1111-1111-1111-111111111111', q.id, 0, true
    FROM questions q
   WHERE q.kind = 'inicial' AND q.age_bracket_id = v_faixa;

  v_idade := calculate_general_age('91111111-1111-1111-1111-111111111111');
  IF v_idade <> 48 THEN
    RAISE EXCEPTION 'FALHA: só NV deveria devolver a idade biológica (48), devolveu %', v_idade;
  END IF;

  -- Cenário B: uma resposta "C" (valor 2) e o resto NV. A média das linhas
  -- observadas é 2, então não há regressão nenhuma. Com NV entrando como 0
  -- (comportamento anterior) a média cairia e a idade despencaria.
  UPDATE child_question_answers
     SET valor_numerico = 2, nao_observado = false
   WHERE child_id = '91111111-1111-1111-1111-111111111111'
     AND question_id = (
       SELECT id FROM questions
        WHERE kind = 'inicial' AND age_bracket_id = v_faixa
        ORDER BY ordem, id LIMIT 1
     );

  v_idade := calculate_general_age('91111111-1111-1111-1111-111111111111');
  IF v_idade <> 48 THEN
    RAISE EXCEPTION 'FALHA: NV ainda pesa na média geral (idade %, esperava 48)', v_idade;
  END IF;

  -- Mesma prova para a idade por habilidade.
  UPDATE children SET idade_geral_meses = 48
   WHERE id = '91111111-1111-1111-1111-111111111111';

  INSERT INTO child_question_answers (child_id, question_id, valor_numerico, nao_observado)
  SELECT '91111111-1111-1111-1111-111111111111', q.id, 0, true
    FROM questions q
   WHERE q.kind = 'triagem' AND q.age_bracket_id = v_faixa AND q.skill_id = v_skill;

  v_idade := calculate_skill_age('91111111-1111-1111-1111-111111111111', v_skill);
  IF v_idade <> 48 THEN
    RAISE EXCEPTION 'FALHA: habilidade só com NV deveria manter a idade base (48), devolveu %', v_idade;
  END IF;

  -- E o contraste: uma resposta "A" de verdade (valor 0 observado) rebaixa.
  UPDATE child_question_answers cqa
     SET valor_numerico = 0, nao_observado = false
    FROM questions q
   WHERE q.id = cqa.question_id
     AND cqa.child_id = '91111111-1111-1111-1111-111111111111'
     AND q.kind = 'triagem' AND q.age_bracket_id = v_faixa AND q.skill_id = v_skill;

  v_idade := calculate_skill_age('91111111-1111-1111-1111-111111111111', v_skill);
  IF v_idade >= 48 THEN
    RAISE EXCEPTION 'FALHA: respostas "A" observadas deveriam rebaixar a idade (devolveu %)', v_idade;
  END IF;

  RAISE NOTICE 'NV: fora das médias; "A" observado continua pesando';
END $$;

-- ============================================================
-- 3. O PLANO COMEÇA EM AQUISIÇÃO (D1)
-- ============================================================
-- generate-activity-plan monta o plano ordenando por (nivel, ordem) e ativa a
-- primeira atividade que a conta consegue abrir. A condição que faz isso
-- resultar em Aquisição é de DADO, não de código: em toda combinação
-- (habilidade, faixa) a primeira atividade acessível tem de ser de aquisição.
-- Se alguém marcar uma aquisição como premium (item 1.8), este teste falha
-- antes de um usuário free receber um plano que começa em Generalização.

DO $$
DECLARE v_int INTEGER;
BEGIN
  SELECT count(*) INTO v_int FROM (
    SELECT DISTINCT ON (e.skill_id, e.age_bracket_id) e.nivel
      FROM exercises e
     WHERE e.status = 'ativo' AND e.plano = 'free'
     ORDER BY e.skill_id, e.age_bracket_id, e.nivel, e.ordem
  ) primeiro
  WHERE primeiro.nivel <> 'aquisicao';

  IF v_int <> 0 THEN
    RAISE EXCEPTION 'FALHA: % combinações (habilidade, faixa) cuja 1ª atividade acessível não é de aquisição', v_int;
  END IF;

  -- Toda faixa/habilidade com conteúdo tem aquisição disponível.
  SELECT count(*) INTO v_int FROM (
    SELECT skill_id, age_bracket_id FROM exercises WHERE status = 'ativo'
    GROUP BY skill_id, age_bracket_id
    HAVING count(*) FILTER (WHERE nivel = 'aquisicao') = 0
  ) q;
  IF v_int <> 0 THEN
    RAISE EXCEPTION 'FALHA: % combinações sem nenhuma atividade de aquisição', v_int;
  END IF;

  RAISE NOTICE 'plano: primeira atividade acessível é sempre de aquisição';
END $$;

-- ============================================================
-- 4. GENERALIZAÇÃO EXIGE 3 DIAS DISTINTOS (D5)
-- ============================================================

INSERT INTO children (id, user_id, nome, data_nascimento, idade_biologica_meses)
VALUES ('93333333-3333-3333-3333-333333333333',
        'f1111111-1111-1111-1111-111111111111', 'Criança G', '2022-01-10', 48);

-- Três planos do mesmo código (A, G, M), como generate-activity-plan monta.
INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem)
SELECT 'aa000001-0000-0000-0000-000000000001', '93333333-3333-3333-3333-333333333333',
       e.skill_id, e.id, 'ativo', 0
  FROM exercises e WHERE e.status = 'ativo' AND e.nivel = 'aquisicao' ORDER BY e.codigo LIMIT 1;

INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem)
SELECT 'aa000002-0000-0000-0000-000000000002', '93333333-3333-3333-3333-333333333333',
       ap.skill_id, e.id, 'bloqueado', 1
  FROM activity_plans ap
  JOIN exercises base ON base.id = ap.exercise_id
  JOIN exercises e ON e.codigo = base.codigo AND e.nivel = 'generalizacao'
 WHERE ap.id = 'aa000001-0000-0000-0000-000000000001';

INSERT INTO activity_plans (id, child_id, skill_id, exercise_id, status, ordem)
SELECT 'aa000003-0000-0000-0000-000000000003', '93333333-3333-3333-3333-333333333333',
       ap.skill_id, e.id, 'bloqueado', 2
  FROM activity_plans ap
  JOIN exercises base ON base.id = ap.exercise_id
  JOIN exercises e ON e.codigo = base.codigo AND e.nivel = 'manutencao'
 WHERE ap.id = 'aa000001-0000-0000-0000-000000000001';

DO $$
DECLARE
  v_status plan_status;
  v_completa BOOLEAN;
BEGIN
  -- ── Aquisição: uma sessão basta ──
  INSERT INTO exercise_sessions (id, plan_id, child_id, total_repetitions, successful_count, started_at)
  VALUES ('bb000001-0000-0000-0000-000000000001', 'aa000001-0000-0000-0000-000000000001',
          '93333333-3333-3333-3333-333333333333', 10, 8, TIMESTAMPTZ '2026-08-20 10:00-03');

  IF check_exercise_completion('bb000001-0000-0000-0000-000000000001') IS NOT TRUE THEN
    RAISE EXCEPTION 'FALHA: aquisição deveria concluir com uma sessão de 8 acertos';
  END IF;

  SELECT status INTO v_status FROM activity_plans WHERE id = 'aa000001-0000-0000-0000-000000000001';
  IF v_status IS DISTINCT FROM 'concluido' THEN
    RAISE EXCEPTION 'FALHA: plano de aquisição está %, esperava concluido', v_status;
  END IF;

  -- D1: o que abre depois da Aquisição é a Generalização do mesmo código.
  SELECT status INTO v_status FROM activity_plans WHERE id = 'aa000002-0000-0000-0000-000000000002';
  IF v_status IS DISTINCT FROM 'ativo' THEN
    RAISE EXCEPTION 'FALHA: generalização deveria ter sido liberada, está %', v_status;
  END IF;
  SELECT status INTO v_status FROM activity_plans WHERE id = 'aa000003-0000-0000-0000-000000000003';
  IF v_status IS DISTINCT FROM 'bloqueado' THEN
    RAISE EXCEPTION 'FALHA: manutenção não pode abrir antes da generalização (está %)', v_status;
  END IF;
END $$;

DO $$
DECLARE
  v_status plan_status;
  v_completa BOOLEAN;
BEGIN
  -- ── Generalização: 3 sessões NO MESMO DIA não concluem ──
  -- A terceira é às 23:30 de Brasília, que em UTC já é o dia seguinte: se a
  -- contagem usasse UTC, esta sessão inventaria um segundo dia.
  INSERT INTO exercise_sessions (id, plan_id, child_id, total_repetitions, successful_count, started_at) VALUES
    ('bb000002-0000-0000-0000-000000000001', 'aa000002-0000-0000-0000-000000000002',
     '93333333-3333-3333-3333-333333333333', 10, 8, TIMESTAMPTZ '2026-08-20 09:00-03'),
    ('bb000002-0000-0000-0000-000000000002', 'aa000002-0000-0000-0000-000000000002',
     '93333333-3333-3333-3333-333333333333', 10, 8, TIMESTAMPTZ '2026-08-20 15:00-03'),
    ('bb000002-0000-0000-0000-000000000003', 'aa000002-0000-0000-0000-000000000002',
     '93333333-3333-3333-3333-333333333333', 10, 8, TIMESTAMPTZ '2026-08-20 23:30-03');

  IF check_exercise_completion('bb000002-0000-0000-0000-000000000001') IS NOT FALSE THEN
    RAISE EXCEPTION 'FALHA: generalização concluiu no 1º dia';
  END IF;
  IF check_exercise_completion('bb000002-0000-0000-0000-000000000002') IS NOT FALSE THEN
    RAISE EXCEPTION 'FALHA: generalização concluiu na 2ª sessão do mesmo dia';
  END IF;
  IF check_exercise_completion('bb000002-0000-0000-0000-000000000003') IS NOT FALSE THEN
    RAISE EXCEPTION 'FALHA: 3 sessões no mesmo dia concluíram a generalização';
  END IF;

  -- Sessões fechadas (para start-exercise-session abrir uma nova) e plano
  -- ainda ativo (para a atividade continuar na tela do responsável).
  SELECT bool_and(is_completed) INTO v_completa FROM exercise_sessions
   WHERE plan_id = 'aa000002-0000-0000-0000-000000000002';
  IF v_completa IS NOT TRUE THEN
    RAISE EXCEPTION 'FALHA: sessões de generalização deveriam ficar concluídas';
  END IF;

  SELECT status INTO v_status FROM activity_plans WHERE id = 'aa000002-0000-0000-0000-000000000002';
  IF v_status IS DISTINCT FROM 'ativo' THEN
    RAISE EXCEPTION 'FALHA: plano de generalização deveria seguir ativo, está %', v_status;
  END IF;

  SELECT status INTO v_status FROM activity_plans WHERE id = 'aa000003-0000-0000-0000-000000000003';
  IF v_status IS DISTINCT FROM 'bloqueado' THEN
    RAISE EXCEPTION 'FALHA: manutenção abriu sem os 3 dias de generalização';
  END IF;

  -- ── 2º dia: ainda não conclui ──
  -- 23:00 de Brasília = 02:00 UTC do dia seguinte. Somando com a sessão das
  -- 23:30 acima, uma contagem em UTC já veria TRÊS datas aqui e concluiria
  -- errado; em horário de Brasília são dois dias. É este INSERT que separa as
  -- duas implementações.
  INSERT INTO exercise_sessions (id, plan_id, child_id, total_repetitions, successful_count, started_at)
  VALUES ('bb000002-0000-0000-0000-000000000004', 'aa000002-0000-0000-0000-000000000002',
          '93333333-3333-3333-3333-333333333333', 10, 8, TIMESTAMPTZ '2026-08-21 23:00-03');

  IF check_exercise_completion('bb000002-0000-0000-0000-000000000004') IS NOT FALSE THEN
    RAISE EXCEPTION 'FALHA: generalização concluiu com 2 dias distintos (contagem em UTC?)';
  END IF;

  -- ── 3º dia: conclui e libera a Manutenção ──
  INSERT INTO exercise_sessions (id, plan_id, child_id, total_repetitions, successful_count, started_at)
  VALUES ('bb000002-0000-0000-0000-000000000005', 'aa000002-0000-0000-0000-000000000002',
          '93333333-3333-3333-3333-333333333333', 10, 8, TIMESTAMPTZ '2026-08-22 10:00-03');

  IF check_exercise_completion('bb000002-0000-0000-0000-000000000005') IS NOT TRUE THEN
    RAISE EXCEPTION 'FALHA: generalização não concluiu com 3 dias distintos';
  END IF;

  SELECT status INTO v_status FROM activity_plans WHERE id = 'aa000002-0000-0000-0000-000000000002';
  IF v_status IS DISTINCT FROM 'concluido' THEN
    RAISE EXCEPTION 'FALHA: plano de generalização está %, esperava concluido', v_status;
  END IF;

  SELECT status INTO v_status FROM activity_plans WHERE id = 'aa000003-0000-0000-0000-000000000003';
  IF v_status IS DISTINCT FROM 'ativo' THEN
    RAISE EXCEPTION 'FALHA: manutenção não foi liberada depois dos 3 dias (está %)', v_status;
  END IF;

  -- ── Manutenção: volta a ser uma sessão só ──
  INSERT INTO exercise_sessions (id, plan_id, child_id, total_repetitions, successful_count, started_at)
  VALUES ('bb000003-0000-0000-0000-000000000001', 'aa000003-0000-0000-0000-000000000003',
          '93333333-3333-3333-3333-333333333333', 10, 8, TIMESTAMPTZ '2026-08-23 10:00-03');

  IF check_exercise_completion('bb000003-0000-0000-0000-000000000001') IS NOT TRUE THEN
    RAISE EXCEPTION 'FALHA: manutenção deveria concluir com uma sessão de 8 acertos';
  END IF;

  RAISE NOTICE 'generalização: 3 dias distintos (fuso de Brasília); A e M com 1 sessão';
END $$;

-- ============================================================
-- 5. REBAIXAMENTO AUTOMÁTICO DE FAIXA (D3)
-- ============================================================

INSERT INTO children (id, user_id, nome, data_nascimento, idade_biologica_meses)
VALUES ('92222222-2222-2222-2222-222222222222',
        'f1111111-1111-1111-1111-111111111111', 'Criança Rebaixa', '2021-01-10', 60);

DO $$
DECLARE
  v_f01 UUID; v_f02 UUID; v_f03 UUID; v_f04 UUID; v_f05 UUID;
  v_resultado UUID;
  v_codigo TEXT;
BEGIN
  SELECT id INTO v_f01 FROM age_brackets WHERE codigo = 'F01A';
  SELECT id INTO v_f02 FROM age_brackets WHERE codigo = 'F02A';
  SELECT id INTO v_f03 FROM age_brackets WHERE codigo = 'F03A';
  SELECT id INTO v_f04 FROM age_brackets WHERE codigo = 'F04A';
  SELECT id INTO v_f05 FROM age_brackets WHERE codigo = 'F05A';

  -- ── Sem rebaixamento: 1 "A" observado + NV no resto ──
  -- NV não é evidência de falha, então não entra na contagem dos dois "A".
  INSERT INTO child_question_answers (child_id, question_id, valor_numerico, nao_observado)
  SELECT '92222222-2222-2222-2222-222222222222', q.id, 0, true
    FROM questions q WHERE q.kind = 'inicial' AND q.age_bracket_id = v_f05;

  UPDATE child_question_answers cqa SET nao_observado = false
   WHERE cqa.child_id = '92222222-2222-2222-2222-222222222222'
     AND cqa.question_id = (
       SELECT id FROM questions WHERE kind = 'inicial' AND age_bracket_id = v_f05
        ORDER BY ordem, id LIMIT 1);

  v_resultado := resolve_bracket_after_prerequisites('92222222-2222-2222-2222-222222222222', v_f05);
  IF v_resultado IS DISTINCT FROM v_f05 THEN
    SELECT codigo INTO v_codigo FROM age_brackets WHERE id = v_resultado;
    RAISE EXCEPTION 'FALHA: 1 "A" + NV rebaixou para % (não deveria rebaixar)', v_codigo;
  END IF;

  -- Um segundo "A" observado passa a valer o critério: F05A -> F04A.
  UPDATE child_question_answers cqa SET nao_observado = false
   WHERE cqa.child_id = '92222222-2222-2222-2222-222222222222'
     AND cqa.question_id = (
       SELECT id FROM questions WHERE kind = 'inicial' AND age_bracket_id = v_f05
        ORDER BY ordem DESC, id DESC LIMIT 1);

  v_resultado := resolve_bracket_after_prerequisites('92222222-2222-2222-2222-222222222222', v_f05);
  IF v_resultado IS DISTINCT FROM v_f04 THEN
    SELECT codigo INTO v_codigo FROM age_brackets WHERE id = v_resultado;
    RAISE EXCEPTION 'FALHA: 2 "A" em F05A deveriam levar a F04A, levaram a %', v_codigo;
  END IF;

  -- ── Rebaixamento em cadeia: F04A -> F03A -> F02A ──
  INSERT INTO child_question_answers (child_id, question_id, valor_numerico, nao_observado)
  SELECT '92222222-2222-2222-2222-222222222222', q.id, 0, false
    FROM questions q WHERE q.kind = 'inicial' AND q.age_bracket_id = v_f04;

  v_resultado := resolve_bracket_after_prerequisites('92222222-2222-2222-2222-222222222222', v_f04);
  IF v_resultado IS DISTINCT FROM v_f03 THEN
    SELECT codigo INTO v_codigo FROM age_brackets WHERE id = v_resultado;
    RAISE EXCEPTION 'FALHA: 2ª descida deveria chegar em F03A, chegou em %', v_codigo;
  END IF;

  INSERT INTO child_question_answers (child_id, question_id, valor_numerico, nao_observado)
  SELECT '92222222-2222-2222-2222-222222222222', q.id, 0, false
    FROM questions q WHERE q.kind = 'inicial' AND q.age_bracket_id = v_f03;

  v_resultado := resolve_bracket_after_prerequisites('92222222-2222-2222-2222-222222222222', v_f03);
  IF v_resultado IS DISTINCT FROM v_f02 THEN
    SELECT codigo INTO v_codigo FROM age_brackets WHERE id = v_resultado;
    RAISE EXCEPTION 'FALHA: 3ª descida deveria chegar em F02A, chegou em %', v_codigo;
  END IF;

  -- ── Piso: F01A não desce mais ──
  INSERT INTO child_question_answers (child_id, question_id, valor_numerico, nao_observado)
  SELECT '92222222-2222-2222-2222-222222222222', q.id, 0, false
    FROM questions q WHERE q.kind = 'inicial' AND q.age_bracket_id = v_f01;

  v_resultado := resolve_bracket_after_prerequisites('92222222-2222-2222-2222-222222222222', v_f01);
  IF v_resultado IS DISTINCT FROM v_f01 THEN
    SELECT codigo INTO v_codigo FROM age_brackets WHERE id = v_resultado;
    RAISE EXCEPTION 'FALHA: F01A é o piso, mas o resultado foi % (id %)', COALESCE(v_codigo, 'NULL'), v_resultado;
  END IF;

  -- A faixa resultante é persistível: é isso que faz o rebaixamento
  -- sobreviver a fechar e reabrir o app.
  UPDATE children SET faixa_id = v_f02 WHERE id = '92222222-2222-2222-2222-222222222222';
  IF (SELECT faixa_id FROM children WHERE id = '92222222-2222-2222-2222-222222222222') <> v_f02 THEN
    RAISE EXCEPTION 'FALHA: children.faixa_id não guardou a faixa';
  END IF;

  RAISE NOTICE 'rebaixamento: NV não conta, desce em cadeia, piso em F01A, faixa persistida';
END $$;

-- ============================================================
-- 6. PROGRESSÃO CASA PELA MESMA ATIVIDADE (migration-12)
-- ============================================================
-- Fixture com TRÊS atividades da mesma (habilidade, faixa) — a seção 4 usa uma
-- só, e com uma atividade o bug "desbloqueia por posição" é indistinguível do
-- comportamento correto.
--
-- Layout dos planos, igual ao que generate-activity-plan grava:
--   activity_plans.ordem 0,1,2 = Aquisição das atividades 1,2,3
--                        3,4,5 = Generalização das atividades 1,2,3
--                        6,7,8 = Manutenção das atividades 1,2,3
-- Então "primeira bloqueada do nível alvo por posição" e "próximo nível desta
-- atividade" só coincidem enquanto nada fura a fila.

INSERT INTO children (id, user_id, nome, data_nascimento, idade_biologica_meses)
VALUES ('94444444-4444-4444-4444-444444444444',
        'f1111111-1111-1111-1111-111111111111', 'Criança P', '2025-01-10', 18);

INSERT INTO activity_plans (child_id, skill_id, exercise_id, status, ordem)
SELECT '94444444-4444-4444-4444-444444444444',
       e.skill_id,
       e.id,
       (CASE WHEN e.nivel = 'aquisicao' AND e.ordem = 1 THEN 'ativo' ELSE 'bloqueado' END)::plan_status,
       (row_number() OVER (ORDER BY e.nivel, e.ordem))::int - 1
  FROM exercises e
  JOIN skills s       ON s.id = e.skill_id       AND s.key    = 'comunicacao'
  JOIN age_brackets b ON b.id = e.age_bracket_id AND b.codigo = 'F01A'
 WHERE e.status = 'ativo' AND e.ordem <= 3;

DO $$
DECLARE
  v_child  CONSTANT UUID := '94444444-4444-4444-4444-444444444444';
  v_plan   UUID;
  v_sess   UUID;
  v_status plan_status;
  v_int    INTEGER;
  v_dia    DATE := DATE '2026-08-20';

BEGIN
  SELECT count(*) INTO v_int FROM activity_plans WHERE child_id = v_child;
  IF v_int <> 9 THEN
    RAISE EXCEPTION 'FALHA: fixture deveria ter 9 planos (3 atividades x 3 níveis), tem %', v_int;
  END IF;

  -- ── A. Generalização premium não pode trocar de atividade ──
  -- Regra do produto: o filtro free/premium vale ao selecionar atividade nova.
  -- Quem já está na atividade 1 continua nela mesmo que a Generalização dela
  -- vire premium. Com a migration-11 isto abria a Generalização da atividade 2.
  UPDATE exercises e SET plano = 'premium'
    FROM activity_plans ap
   WHERE ap.exercise_id = e.id AND ap.child_id = v_child
     AND e.nivel = 'generalizacao' AND e.ordem = 1;

  IF child_has_premium_access(v_child) THEN
    RAISE EXCEPTION 'FALHA: a criança do teste não pode ter acesso premium';
  END IF;

  SELECT ap.id INTO v_plan
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'aquisicao' AND e.ordem = 1;

  INSERT INTO exercise_sessions (plan_id, child_id, total_repetitions, successful_count, started_at)
  VALUES (v_plan, v_child, 10, 8, v_dia + TIME '10:00')
  RETURNING id INTO v_sess;

  IF check_exercise_completion(v_sess) IS NOT TRUE THEN
    RAISE EXCEPTION 'FALHA: aquisição da atividade 1 deveria concluir';
  END IF;

  SELECT ap.status INTO v_status
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'generalizacao' AND e.ordem = 1;
  IF v_status IS DISTINCT FROM 'ativo' THEN
    RAISE EXCEPTION 'FALHA: generalização da MESMA atividade deveria abrir (está %)', v_status;
  END IF;

  SELECT ap.status INTO v_status
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'generalizacao' AND e.ordem = 2;
  IF v_status IS DISTINCT FROM 'bloqueado' THEN
    RAISE EXCEPTION 'FALHA: abriu a generalização da atividade 2 (pulou de atividade); está %', v_status;
  END IF;

  SELECT ap.status INTO v_status
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'aquisicao' AND e.ordem = 2;
  IF v_status IS DISTINCT FROM 'bloqueado' THEN
    RAISE EXCEPTION 'FALHA: aquisição da atividade 2 abriu antes da hora (está %)', v_status;
  END IF;

  -- ── B. Manutenção casa pela mesma atividade ──
  SELECT ap.id INTO v_plan
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'generalizacao' AND e.ordem = 1;

  FOR v_int IN 1..3 LOOP
    INSERT INTO exercise_sessions (plan_id, child_id, total_repetitions, successful_count, started_at)
    VALUES (v_plan, v_child, 10, 9, (v_dia + v_int) + TIME '09:00')
    RETURNING id INTO v_sess;
    PERFORM check_exercise_completion(v_sess);
  END LOOP;

  SELECT ap.status INTO v_status
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'manutencao' AND e.ordem = 1;
  IF v_status IS DISTINCT FROM 'ativo' THEN
    RAISE EXCEPTION 'FALHA: manutenção da atividade 1 deveria abrir após 3 dias (está %)', v_status;
  END IF;

  SELECT ap.status INTO v_status
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'manutencao' AND e.ordem = 2;
  IF v_status IS DISTINCT FROM 'bloqueado' THEN
    RAISE EXCEPTION 'FALHA: abriu a manutenção da atividade 2 (pulou de atividade); está %', v_status;
  END IF;

  -- ── C. Virada de atividade: aí sim o filtro de plano vale ──
  -- Atividade 2 premium + conta free => a próxima aberta é a 3, não a 2.
  UPDATE exercises e SET plano = 'premium'
    FROM activity_plans ap
   WHERE ap.exercise_id = e.id AND ap.child_id = v_child
     AND e.nivel = 'aquisicao' AND e.ordem = 2;

  SELECT ap.id INTO v_plan
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'manutencao' AND e.ordem = 1;

  INSERT INTO exercise_sessions (plan_id, child_id, total_repetitions, successful_count, started_at)
  VALUES (v_plan, v_child, 10, 10, (v_dia + 5) + TIME '10:00')
  RETURNING id INTO v_sess;

  IF check_exercise_completion(v_sess) IS NOT TRUE THEN
    RAISE EXCEPTION 'FALHA: manutenção da atividade 1 deveria concluir';
  END IF;

  SELECT ap.status INTO v_status
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'aquisicao' AND e.ordem = 2;
  IF v_status IS DISTINCT FROM 'bloqueado' THEN
    RAISE EXCEPTION 'FALHA: conta free abriu uma aquisição premium (está %)', v_status;
  END IF;

  SELECT ap.status INTO v_status
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.nivel = 'aquisicao' AND e.ordem = 3;
  IF v_status IS DISTINCT FROM 'ativo' THEN
    RAISE EXCEPTION 'FALHA: depois da manutenção deveria abrir a aquisição da atividade 3 (está %)', v_status;
  END IF;

  -- Nenhuma etapa da atividade 1 ficou para trás.
  SELECT count(*) INTO v_int
    FROM activity_plans ap JOIN exercises e ON e.id = ap.exercise_id
   WHERE ap.child_id = v_child AND e.ordem = 1 AND ap.status <> 'concluido';
  IF v_int <> 0 THEN
    RAISE EXCEPTION 'FALHA: % etapas da atividade 1 não ficaram concluídas', v_int;
  END IF;

  RAISE NOTICE 'progressão: A→G→M casa pela mesma atividade; filtro de plano só na virada';
END $$;

ROLLBACK;
