-- migration-15: a virada de atividade segue a ordem sorteada e persistida no
-- plano da criança, não a ordem fixa do catálogo.
--
-- `exercises.ordem` continua intacta e com a responsabilidade definida na
-- migration-12: casar Aquisição -> Generalização -> Manutenção da MESMA
-- atividade. Somente a seleção de uma atividade nova passa a ordenar por
-- `activity_plans.ordem`, gravada por generate-activity-plan.

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

  -- Próxima etapa DESTA atividade. `exercises.ordem` é a identidade comum
  -- aos três níveis e não participa do sorteio.
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

  -- Próxima ATIVIDADE da habilidade. Aqui o filtro free/premium continua
  -- valendo, mas a prioridade vem da trilha sorteada desta criança.
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
  'Fecha a sessão com 8+ acertos. A->G->M casa pela identidade exercises.ordem; a próxima atividade segue activity_plans.ordem, sorteada uma vez na geração do plano. O filtro free/premium só entra nessa virada.';
