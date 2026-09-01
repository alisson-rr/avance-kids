-- migration-12: a progressão A→G→M passa a casar pela MESMA atividade, e o
-- filtro de plano só vale ao selecionar atividade nova.
--
-- Duas correções em check_exercise_completion, ambas na mesma causa: o
-- desbloqueio escolhia "a primeira bloqueada da habilidade no próximo nível",
-- por POSIÇÃO no plano (`activity_plans.ordem`), e não a próxima etapa da
-- atividade que acabou de ser concluída.
--
-- 1. Casar por atividade. `exercises.ordem` é igual nos três níveis do mesmo
--    código — asserção em scripts/validate_migrations.sh — e identifica a
--    atividade dentro de (habilidade, faixa) mesmo quando `codigo` é NULL
--    (atividade criada pelo backoffice). Hoje funcionava por coincidência: a
--    trilha anda em fila indiana, então a menor posição do nível alvo era
--    sempre a atividade certa. Deixa de funcionar assim que algo fura a fila.
--
-- 2. Filtro de plano só na virada de atividade. Regra do produto: a validação
--    free/premium acontece ao SELECIONAR uma atividade nova; quem já está numa
--    atividade a conclui, mesmo que ela vire premium no meio do caminho.
--    A migration-11 aplicava o filtro em todo desbloqueio, inclusive na virada
--    Aquisição→Generalização da mesma atividade. Consequência: marcar a
--    Generalização da atividade 1 como premium fazia a conta free pular para a
--    Generalização da atividade 2 — uma atividade cuja Aquisição a criança
--    nunca fez.
--
-- unlock_available_plans (migration-05) não muda: ela só dispara quando a
-- habilidade ficou sem nenhum plano ativo, e aí a menor posição bloqueada já é
-- a Aquisição mais antiga que o filtro havia pulado.

CREATE OR REPLACE FUNCTION check_exercise_completion(p_session_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_plan_id UUID;
  v_child_id UUID;
  v_skill_id UUID;
  v_nivel exercise_level;
  v_ordem INTEGER;
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

  SELECT ap.skill_id, e.nivel, e.ordem
  INTO v_skill_id, v_nivel, v_ordem
  FROM activity_plans ap
  JOIN exercises e ON e.id = ap.exercise_id
  WHERE ap.id = v_plan_id;

  -- Generalização: só conclui no 3º dia distinto com sessão de 8+ acertos (D5).
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

  -- ── Próxima etapa DESTA atividade ──────────────────────────
  -- Sem filtro de plano: a atividade já está em curso.
  IF v_nivel <> 'manutencao' THEN
    v_next_nivel := CASE v_nivel
      WHEN 'aquisicao' THEN 'generalizacao'::exercise_level
      ELSE 'manutencao'::exercise_level
    END;

    SELECT ap.id INTO v_next_plan_id
    FROM activity_plans ap
    JOIN exercises e ON e.id = ap.exercise_id
    WHERE ap.child_id = v_child_id
      AND ap.skill_id = v_skill_id
      AND ap.status = 'bloqueado'
      AND e.nivel = v_next_nivel
      AND e.ordem = v_ordem
    LIMIT 1;
  END IF;

  -- ── Próxima ATIVIDADE da habilidade ────────────────────────
  -- Vale para a Manutenção concluída e como rede para um catálogo em que falte
  -- o nível seguinte. Aqui sim o filtro de plano se aplica: é o único momento
  -- em que se seleciona atividade nova. Sem `ordem > v_ordem` de propósito —
  -- assim uma Aquisição premium pulada volta a ser candidata quando a
  -- assinatura entra, em vez de ficar para trás para sempre.
  IF v_next_plan_id IS NULL THEN
    v_premium := child_has_premium_access(v_child_id);

    SELECT ap.id INTO v_next_plan_id
    FROM activity_plans ap
    JOIN exercises e ON e.id = ap.exercise_id
    WHERE ap.child_id = v_child_id
      AND ap.skill_id = v_skill_id
      AND ap.status = 'bloqueado'
      AND e.nivel = 'aquisicao'
      AND (v_premium OR e.plano = 'free')
    ORDER BY e.ordem ASC
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
  'Fecha a sessão com 8+ acertos. Aquisição/Manutenção concluem na hora; Generalização só no 3º dia distinto (America/Sao_Paulo). Avança para o próximo nível DA MESMA atividade sem olhar free/premium; o filtro de plano só entra ao abrir a próxima atividade.';
