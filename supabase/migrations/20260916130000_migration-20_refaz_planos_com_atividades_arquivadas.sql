-- ============================================================
-- migration-20: refaz o plano das crianças que apontam para atividades
-- arquivadas
--
-- A migration-08 arquivou as atividades provisórias que ainda estavam em
-- algum plano. A RLS de `exercises` só mostra atividade ativa, então o app
-- recebe essas linhas sem atividade e as exibe como "Atividade premium"
-- bloqueada: a criança fica sem nada para fazer.
--
-- Para cada criança nessa situação (e com resultado de triagem), o plano é
-- apagado e gerado de novo com a MESMA regra de
-- supabase/functions/generate-activity-plan/index.ts: todas as atividades
-- ativas da faixa de cada habilidade, ordem das atividades sorteada uma vez
-- por habilidade e reaproveitada em A/G/M, e a primeira Aquisição que a conta
-- consegue abrir começa ativa.
--
-- Destrutivo: apagar o plano derruba as tentativas e repetições (cascata).
-- Recuperação: as linhas afetadas são copiadas antes para o schema `backup`,
-- que não é exposto pela API.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS backup;
REVOKE ALL ON SCHEMA backup FROM PUBLIC, anon, authenticated;

CREATE TABLE backup.m20_activity_plans AS
SELECT ap.*
FROM activity_plans ap
WHERE ap.child_id IN (
  SELECT p.child_id
  FROM activity_plans p
  JOIN exercises e ON e.id = p.exercise_id
  WHERE e.status = 'arquivado'
);

CREATE TABLE backup.m20_exercise_sessions AS
SELECT es.*
FROM exercise_sessions es
WHERE es.child_id IN (SELECT DISTINCT child_id FROM backup.m20_activity_plans);

CREATE TABLE backup.m20_exercise_attempts AS
SELECT ea.*
FROM exercise_attempts ea
WHERE ea.child_id IN (SELECT DISTINCT child_id FROM backup.m20_activity_plans);

DO $$
DECLARE
  v_child_id UUID;
  v_skill RECORD;
  v_premium BOOLEAN;
  v_refeitas INTEGER := 0;
  v_sem_triagem INTEGER := 0;
BEGIN
  FOR v_child_id IN
    SELECT DISTINCT child_id FROM backup.m20_activity_plans
  LOOP
    -- Sem atividade disponível para as faixas da triagem, a função de geração
    -- também não mexe no plano: a criança fica como está.
    IF NOT EXISTS (
      SELECT 1
      FROM child_skill_ages s
      JOIN exercises e
        ON e.skill_id = s.skill_id
       AND e.age_bracket_id = s.faixa_id
       AND e.status = 'ativo'
      WHERE s.child_id = v_child_id
    ) THEN
      v_sem_triagem := v_sem_triagem + 1;
      CONTINUE;
    END IF;

    v_premium := child_has_premium_access(v_child_id);

    DELETE FROM activity_plans WHERE child_id = v_child_id;

    FOR v_skill IN
      SELECT skill_id, faixa_id FROM child_skill_ages WHERE child_id = v_child_id
    LOOP
      INSERT INTO activity_plans (child_id, skill_id, exercise_id, status, ordem, started_at)
      WITH atividades AS (
        SELECT d.ordem, row_number() OVER (ORDER BY random()) AS posicao
        FROM (
          SELECT DISTINCT e.ordem
          FROM exercises e
          WHERE e.skill_id = v_skill.skill_id
            AND e.age_bracket_id = v_skill.faixa_id
            AND e.status = 'ativo'
        ) d
      ),
      ordenadas AS (
        SELECT e.id, e.nivel, e.plano,
               row_number() OVER (
                 ORDER BY array_position(
                   ARRAY['aquisicao', 'generalizacao', 'manutencao']::exercise_level[], e.nivel
                 ), a.posicao, e.id
               ) - 1 AS idx
        FROM exercises e
        JOIN atividades a ON a.ordem = e.ordem
        WHERE e.skill_id = v_skill.skill_id
          AND e.age_bracket_id = v_skill.faixa_id
          AND e.status = 'ativo'
      ),
      primeira AS (
        SELECT min(idx) AS idx
        FROM ordenadas
        WHERE nivel = 'aquisicao' AND (v_premium OR plano = 'free')
      )
      SELECT v_child_id, v_skill.skill_id, o.id,
             CASE WHEN o.idx = p.idx THEN 'ativo'::plan_status ELSE 'bloqueado'::plan_status END,
             o.idx,
             CASE WHEN o.idx = p.idx THEN now() END
      FROM ordenadas o
      CROSS JOIN primeira p;
    END LOOP;

    v_refeitas := v_refeitas + 1;
  END LOOP;

  RAISE NOTICE 'migration-20: % criança(s) com plano refeito; % sem atividade disponível para a triagem (não alteradas)',
    v_refeitas, v_sem_triagem;
END $$;

COMMENT ON SCHEMA backup IS
  'Cópias de segurança de migrations destrutivas. Não exposto pela API; pode ser removido depois de validado.';
