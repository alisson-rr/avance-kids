-- ============================================================
-- migration-11: ajustes de lógica respondidos pela cliente
--
-- Fecha os itens 1.2 a 1.6 de docs/DEPENDENCIAS-E-PENDENCIAS.md. Cada bloco
-- abaixo implementa uma decisão explícita; nada aqui é interpretação.
--
--   D1  Toda criança percorre Aquisição -> Generalização -> Manutenção. A
--       resposta A/B/C do checklist NÃO escolhe o nível de entrada.
--   D2  Habilidade marcada como NV (Não Verificado) entra no plano começando
--       em Aquisição — logo, NV não pode pesar como "nunca" em média nenhuma.
--   D3  Rebaixamento de faixa é automático, sem perguntar ao responsável, e
--       repete enquanto o critério se repetir (piso em F01A).
--   D4  Faixas corretas em meses: F05A 61-95 ("5 a 7 anos") e F06A 96-143
--       ("8 a 11 anos"). Não existe mais lacuna entre faixas.
--   D5  Generalização não pede detalhamento de contexto: bastam três
--       situações/dias diferentes.
--
-- Nenhuma linha de criança, sessão ou tentativa é apagada. As faixas são
-- referenciadas por `id` em questions/exercises/child_skill_ages, então mudar
-- meses_min/meses_max não remaneja conteúdo já cadastrado.
-- ============================================================

-- ============================================================
-- 1. Faixas etárias (D4)
-- ============================================================
-- Os rótulos "6 a 8 anos" e "9 a 12 anos" estavam errados no baseline, e é
-- deles que vinham as três lacunas descritas em 1.3 (61-71, 97-107 e o teto
-- de 144). Com os limites corretos as seis faixas ficam contíguas de 12 a 143.

UPDATE age_brackets
   SET meses_min = 61, meses_max = 95, nome = '5 a 7 anos'
 WHERE codigo = 'F05A';

UPDATE age_brackets
   SET meses_min = 96, meses_max = 143, nome = '8 a 11 anos'
 WHERE codigo = 'F06A';

-- Contiguidade é o que garante que resolve_age_bracket nunca caia no ramo de
-- lacuna. Falhar aqui é melhor do que descobrir em produção que uma idade não
-- resolve faixa nenhuma.
DO $$
DECLARE
  v_lacunas INTEGER;
  v_min INTEGER;
  v_max INTEGER;
BEGIN
  SELECT min(meses_min), max(meses_max) INTO v_min, v_max FROM age_brackets;
  IF v_min <> 12 OR v_max <> 143 THEN
    RAISE EXCEPTION 'faixas deveriam cobrir 12..143 meses, cobrem %..%', v_min, v_max;
  END IF;

  SELECT count(*) INTO v_lacunas FROM (
    SELECT meses_max, lead(meses_min) OVER (ORDER BY ordem) AS proximo_min
      FROM age_brackets
  ) q
  WHERE proximo_min IS NOT NULL AND proximo_min <> meses_max + 1;

  IF v_lacunas > 0 THEN
    RAISE EXCEPTION '% lacuna(s)/sobreposição(ões) entre faixas etárias', v_lacunas;
  END IF;
END $$;

-- O clamp seguia 144 (o teto antigo de F06A). Com o teto em 143, uma criança
-- de 12 anos exatos entrava com 144, não casava com nenhuma faixa e ia parar
-- no ramo de fallback — que devolve a faixa certa por acidente, mas por um
-- caminho que só existe para lacuna. O ramo de lacuna continua no corpo da
-- função de propósito: ele é a rede se alguém editar os limites de novo.
CREATE OR REPLACE FUNCTION resolve_age_bracket(idade_meses INTEGER)
RETURNS UUID AS $$
DECLARE
  bracket_id UUID;
  clamped INTEGER;
BEGIN
  clamped := GREATEST(12, LEAST(143, idade_meses));

  SELECT id INTO bracket_id
  FROM age_brackets
  WHERE clamped >= meses_min AND clamped <= meses_max
  ORDER BY ordem ASC
  LIMIT 1;

  -- Rede de segurança: sem lacunas cadastradas, isto não roda.
  IF bracket_id IS NULL THEN
    SELECT id INTO bracket_id
    FROM age_brackets
    WHERE meses_min <= clamped
    ORDER BY meses_min DESC
    LIMIT 1;
  END IF;

  RETURN bracket_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================
-- 2. NV deixa de contar como "nunca" (D2)
-- ============================================================
-- `nao_observado = true` era gravado junto com valor_numerico = 0, ou seja,
-- NV e "quase nunca" eram o mesmo número em qualquer média — o que rebaixava
-- a idade da criança sem nenhuma evidência de falha. As duas funções passam a
-- ignorar essas linhas. Se TODAS forem NV, `AVG` volta NULL e o ramo que já
-- existia devolve a idade base sem regressão nenhuma: a habilidade entra no
-- plano pela faixa da criança, começando em Aquisição, como pede D2.

CREATE OR REPLACE FUNCTION calculate_general_age(p_child_id UUID)
RETURNS INTEGER AS $$
DECLARE
  bio_age INTEGER;
  avg_score NUMERIC;
  result_age INTEGER;
BEGIN
  SELECT idade_biologica_meses INTO bio_age
  FROM children WHERE id = p_child_id;

  SELECT AVG(cqa.valor_numerico) INTO avg_score
  FROM child_question_answers cqa
  JOIN questions q ON q.id = cqa.question_id
  WHERE cqa.child_id = p_child_id
    AND q.kind = 'inicial'
    AND cqa.nao_observado = false;

  IF avg_score IS NULL THEN
    RETURN bio_age;
  END IF;

  result_age := bio_age - ROUND((2.0 - avg_score) * 12)::INTEGER;

  RETURN GREATEST(12, result_age);
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION calculate_skill_age(p_child_id UUID, p_skill_id UUID)
RETURNS INTEGER AS $$
DECLARE
  base_age INTEGER;
  avg_score NUMERIC;
  result_age INTEGER;
BEGIN
  SELECT COALESCE(idade_geral_meses, idade_biologica_meses) INTO base_age
  FROM children WHERE id = p_child_id;

  SELECT AVG(cqa.valor_numerico) INTO avg_score
  FROM child_question_answers cqa
  JOIN questions q ON q.id = cqa.question_id
  WHERE cqa.child_id = p_child_id
    AND q.kind = 'triagem'
    AND q.skill_id = p_skill_id
    AND cqa.nao_observado = false;

  IF avg_score IS NULL THEN
    RETURN base_age;
  END IF;

  result_age := base_age - ROUND((2.0 - avg_score) * 12)::INTEGER;

  RETURN GREATEST(12, result_age);
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION calculate_general_age(UUID) IS
  'Média das perguntas iniciais na escala 0-2, ignorando NV (nao_observado). Só NV => idade biológica.';
COMMENT ON FUNCTION calculate_skill_age(UUID, UUID) IS
  'Média das perguntas de triagem da habilidade, ignorando NV (nao_observado). Só NV => idade base.';

-- ============================================================
-- 3. Generalização exige 3 dias diferentes (D5)
-- ============================================================
-- Os três níveis usavam o mesmo critério (successful_count >= 8 numa sessão).
-- Em Generalização a decisão é praticar em três situações/dias distintos, sem
-- campo de contexto: o dia é o proxy da situação.
--
-- O dia sai de America/Sao_Paulo, não de UTC: uma sessão às 22h de sábado
-- (01h UTC de domingo) seria contada como outro dia e a criança "ganharia" um
-- dia que não existiu.
--
-- Enquanto faltam dias a função marca a SESSÃO como concluída, deixa o PLANO
-- 'ativo' e devolve false. Sessão fechada é o que faz start-exercise-session
-- abrir uma sessão nova no dia seguinte (ele procura sessão com
-- is_completed = false); plano ativo é o que mantém a atividade na tela.

CREATE OR REPLACE FUNCTION check_exercise_completion(p_session_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_plan_id UUID;
  v_child_id UUID;
  v_skill_id UUID;
  v_nivel exercise_level;
  v_success_count INTEGER;
  v_next_nivel exercise_level;
  v_next_plan_id UUID;
  v_premium BOOLEAN;
  v_dias INTEGER;
BEGIN
  SELECT es.plan_id, es.child_id, es.successful_count
  INTO v_plan_id, v_child_id, v_success_count
  FROM exercise_sessions es
  WHERE es.id = p_session_id;

  IF v_plan_id IS NULL OR v_success_count < 8 THEN
    RETURN false;
  END IF;

  UPDATE exercise_sessions SET is_completed = true WHERE id = p_session_id;

  SELECT ap.skill_id, e.nivel
  INTO v_skill_id, v_nivel
  FROM activity_plans ap
  JOIN exercises e ON e.id = ap.exercise_id
  WHERE ap.id = v_plan_id;

  -- Generalização: só conclui no 3º dia distinto com sessão de 8+ acertos.
  IF v_nivel = 'generalizacao' THEN
    SELECT count(DISTINCT (es.started_at AT TIME ZONE 'America/Sao_Paulo')::date)
    INTO v_dias
    FROM exercise_sessions es
    WHERE es.plan_id = v_plan_id
      AND es.is_completed
      AND es.successful_count >= 8;

    IF v_dias < 3 THEN
      RETURN false;
    END IF;
  END IF;

  UPDATE activity_plans SET status = 'concluido', completed_at = now()
  WHERE id = v_plan_id;

  v_premium := child_has_premium_access(v_child_id);

  -- Nível alvo do desbloqueio (o legado comparava enum com texto sem cast,
  -- o que estourava em runtime — aqui o cast é explícito).
  v_next_nivel := CASE v_nivel
    WHEN 'aquisicao' THEN 'generalizacao'::exercise_level
    WHEN 'generalizacao' THEN 'manutencao'::exercise_level
    ELSE 'aquisicao'::exercise_level
  END;

  SELECT ap.id INTO v_next_plan_id
  FROM activity_plans ap
  JOIN exercises e ON e.id = ap.exercise_id
  WHERE ap.child_id = v_child_id
    AND ap.skill_id = v_skill_id
    AND ap.status = 'bloqueado'
    AND e.nivel = v_next_nivel
    AND (v_premium OR e.plano = 'free')
  ORDER BY ap.ordem ASC
  LIMIT 1;

  -- Fallback: se não há plano bloqueado no nível alvo, desbloqueia o próximo
  -- bloqueado da habilidade na ordem (evita travar a trilha).
  IF v_next_plan_id IS NULL THEN
    SELECT ap.id INTO v_next_plan_id
    FROM activity_plans ap
    JOIN exercises e ON e.id = ap.exercise_id
    WHERE ap.child_id = v_child_id
      AND ap.skill_id = v_skill_id
      AND ap.status = 'bloqueado'
      AND (v_premium OR e.plano = 'free')
    ORDER BY ap.ordem ASC
    LIMIT 1;
  END IF;

  IF v_next_plan_id IS NOT NULL THEN
    UPDATE activity_plans SET status = 'ativo', started_at = now()
    WHERE id = v_next_plan_id;
  END IF;

  RETURN true;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_exercise_completion(UUID) IS
  'Fecha a sessão com 8+ acertos. Aquisição/Manutenção concluem na hora; Generalização só no 3º dia distinto (America/Sao_Paulo), mantendo o plano ativo até lá.';

-- ============================================================
-- 4. Faixa de pré-requisitos persistida + rebaixamento (D3)
-- ============================================================
-- A faixa era recalculada da data de nascimento em dois lugares (o banco e
-- apps/mobile/src/services/catalog.ts), então um rebaixamento não tinha onde
-- morar: o próximo carregamento do app devolvia a faixa por idade. A coluna
-- passa a ser a fonte única da faixa de pré-requisitos; NULL continua
-- significando "ainda não avaliada", e aí o app cai no cálculo por idade.

ALTER TABLE children ADD COLUMN faixa_id UUID REFERENCES age_brackets(id);

COMMENT ON COLUMN children.faixa_id IS
  'Faixa das perguntas de pré-requisito, gravada por submit-initial-answers. NULL = nunca avaliada (o app resolve pela idade).';

-- Regra do rebaixamento, em um lugar só: 2 ou mais "A" (valor 0 com
-- nao_observado = false) nas perguntas iniciais DA FAIXA AVALIADA descem uma
-- faixa. NV não conta — não é evidência de falha (D2). Devolve a própria
-- faixa quando não há rebaixamento e quando já se está em F01A, que é o piso;
-- quem chama compara com o que enviou para saber se desceu.
--
-- Lê as respostas já gravadas em vez do payload da requisição: o upsert de
-- submit-initial-answers acabou de deixar a faixa inteira consistente ali, e
-- assim a regra fica testável em SQL puro, sem subir Edge Function.
CREATE OR REPLACE FUNCTION resolve_bracket_after_prerequisites(
  p_child_id UUID,
  p_bracket_id UUID
) RETURNS UUID AS $$
DECLARE
  v_falhas INTEGER;
  v_ordem INTEGER;
  v_anterior UUID;
BEGIN
  SELECT count(*) INTO v_falhas
  FROM child_question_answers cqa
  JOIN questions q ON q.id = cqa.question_id
  WHERE cqa.child_id = p_child_id
    AND q.kind = 'inicial'
    AND q.age_bracket_id = p_bracket_id
    AND cqa.valor_numerico = 0
    AND cqa.nao_observado = false;

  IF v_falhas < 2 THEN
    RETURN p_bracket_id;
  END IF;

  SELECT ordem INTO v_ordem FROM age_brackets WHERE id = p_bracket_id;
  IF v_ordem IS NULL THEN
    RETURN p_bracket_id;
  END IF;

  SELECT id INTO v_anterior
  FROM age_brackets
  WHERE ordem < v_ordem
  ORDER BY ordem DESC
  LIMIT 1;

  RETURN COALESCE(v_anterior, p_bracket_id);
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION resolve_bracket_after_prerequisites(UUID, UUID) IS
  'Rebaixamento automático (D3): 2+ respostas "A" nos pré-requisitos da faixa descem uma faixa. Piso em F01A. NV não conta.';
