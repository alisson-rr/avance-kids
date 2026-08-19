-- ============================================================
-- migration-05: bloqueio real do conteúdo premium
--
-- Antes desta migration as policies de leitura de exercises, plays e
-- articles filtravam só por `status = 'ativo'`. A coluna `plano` existia mas
-- nunca era consultada, então qualquer usuário autenticado conseguia ler o
-- conteúdo pago direto pela API — não havia o que vender.
--
-- Estratégia:
--   * exercises  -> a linha some para quem não assina (o app mostra um card
--                   "atividade premium" quando o join volta nulo).
--   * plays/articles -> a linha continua visível pelas views *_feed, mas o
--                   corpo/instruções/mídia vêm nulos e a view marca
--                   `bloqueado = true`, para o app desenhar o cadeado.
-- ============================================================

-- SECURITY DEFINER: lê subscriptions sem depender da policy da própria tabela.
CREATE OR REPLACE FUNCTION has_premium_access()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM subscriptions
    WHERE user_id = auth.uid()
      AND plano = 'premium'
      AND status IN ('active', 'trialing')
  );
$$;

COMMENT ON FUNCTION has_premium_access() IS
  'Fonte única de "tem acesso pago". Espelhada em isPremiumActive() no app.';

-- ── exercises ───────────────────────────────────────────────
DROP POLICY IF EXISTS "Authenticated read active exercises" ON exercises;

CREATE POLICY "Authenticated read available exercises"
  ON exercises FOR SELECT
  TO authenticated
  USING (
    is_admin()
    OR (status = 'ativo' AND (plano = 'free' OR has_premium_access()))
  );

-- ── plays ───────────────────────────────────────────────────
DROP POLICY IF EXISTS "Authenticated read active plays" ON plays;

CREATE POLICY "Authenticated read available plays"
  ON plays FOR SELECT
  TO authenticated
  USING (
    is_admin()
    OR (status = 'ativo' AND (plano = 'free' OR has_premium_access()))
  );

-- ── articles ────────────────────────────────────────────────
DROP POLICY IF EXISTS "Authenticated read active articles" ON articles;

CREATE POLICY "Authenticated read available articles"
  ON articles FOR SELECT
  TO authenticated
  USING (
    is_admin()
    OR (status = 'ativo' AND (plano = 'free' OR has_premium_access()))
  );

-- ── Views do feed ───────────────────────────────────────────
-- Sem security_invoker: rodam com os direitos do owner e ignoram a RLS acima
-- de propósito, para listar o item pago sem entregar o conteúdo pago. Todo o
-- filtro está no corpo da view.

CREATE OR REPLACE VIEW plays_feed AS
SELECT
  id,
  titulo,
  plano,
  created_at,
  plano = 'premium' AND NOT has_premium_access() AS bloqueado,
  CASE WHEN plano = 'free' OR has_premium_access() THEN descricao END  AS descricao,
  CASE WHEN plano = 'free' OR has_premium_access() THEN instrucoes END AS instrucoes,
  CASE WHEN plano = 'free' OR has_premium_access() THEN media_url END  AS media_url,
  media_type
FROM plays
WHERE status = 'ativo';

CREATE OR REPLACE VIEW articles_feed AS
SELECT
  id,
  titulo,
  plano,
  created_at,
  imagem_url,
  plano = 'premium' AND NOT has_premium_access() AS bloqueado,
  CASE WHEN plano = 'free' OR has_premium_access() THEN corpo END AS corpo
FROM articles
WHERE status = 'ativo';

COMMENT ON VIEW plays_feed IS
  'Listagem de brincadeiras: item premium aparece com bloqueado = true e sem conteúdo.';
COMMENT ON VIEW articles_feed IS
  'Listagem de artigos: item premium aparece com bloqueado = true e sem corpo.';

-- As views rodam com direitos do owner e não têm RLS própria, então o único
-- filtro é o corpo delas. O REVOKE é obrigatório: dependendo da idade do
-- projeto, o Supabase concede SELECT em objetos novos de `public` para anon
-- por default privileges — e aí o catálogo vazaria sem nenhum login.
REVOKE ALL ON plays_feed, articles_feed FROM PUBLIC, anon;
GRANT SELECT ON plays_feed, articles_feed TO authenticated;

-- ── Sessões de exercício ────────────────────────────────────
-- Esconder a linha do exercício não bastava: a policy antiga deixava criar
-- sessão direto pela API para qualquer plano da criança, então dava para
-- avançar numa atividade premium sem assinar (e destravar a próxima).
--
-- A trava é RESTRICTIVE e só em INSERT — de propósito. Numa policy FOR ALL o
-- WITH CHECK também roda em UPDATE, e register-attempt atualiza os contadores
-- da sessão com o client do usuário: uma atividade arquivada no backoffice (ou
-- uma assinatura que vence no meio das 10 repetições) deixaria a sessão em
-- andamento impossível de fechar. Começar exige acesso; terminar o que já
-- começou, não.
CREATE OR REPLACE FUNCTION plan_is_accessible(p_plan_id UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1
    FROM activity_plans ap
    JOIN exercises e ON e.id = ap.exercise_id
    WHERE ap.id = p_plan_id
      AND (e.plano = 'free' OR has_premium_access())
  );
$$;

CREATE POLICY "Premium gate on new sessions"
  ON exercise_sessions AS RESTRICTIVE FOR INSERT
  TO authenticated
  WITH CHECK (plan_is_accessible(plan_id));

-- ── Progressão do plano ─────────────────────────────────────
-- A policy do baseline expunha PATCH em activity_plans para o cliente sem
-- WITH CHECK nem restrição de coluna: dava para marcar um plano premium como
-- 'concluido' e o seguinte como 'ativo' direto pela API, sem sessão nenhuma.
-- Quem escreve status é check_exercise_completion (service_role); o app só lê.
DROP POLICY IF EXISTS "Users can update own children plans" ON activity_plans;
REVOKE UPDATE ON activity_plans FROM authenticated;

-- Desbloqueio da próxima atividade: agora o plano inclui atividades premium
-- (generate-activity-plan), então sem filtrar por `plano` uma conta free
-- receberia um exercício premium como 'ativo' — a seção "Atividades atuais"
-- ficaria vazia e a trilha da habilidade morreria, sem saída a não ser
-- refazer a triagem (que apaga o histórico).
CREATE OR REPLACE FUNCTION child_has_premium_access(p_child_id UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1
    FROM children c
    JOIN subscriptions s ON s.user_id = c.user_id
    WHERE c.id = p_child_id
      AND s.plano = 'premium'
      AND s.status IN ('active', 'trialing')
  );
$$;

-- Contrapartida do filtro acima: quem completou tudo que era free numa
-- habilidade fica sem plano 'ativo', e nada mais dispara o desbloqueio. Sem
-- isso o usuário pagaria a assinatura e continuaria sem nada para fazer. O
-- webhook chama esta função assim que a assinatura entra.
CREATE OR REPLACE FUNCTION unlock_available_plans(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_count INTEGER;
BEGIN
  WITH sem_ativo AS (
    SELECT ap.child_id, ap.skill_id
    FROM activity_plans ap
    JOIN children c ON c.id = ap.child_id
    WHERE c.user_id = p_user_id
    GROUP BY ap.child_id, ap.skill_id
    HAVING count(*) FILTER (WHERE ap.status = 'ativo') = 0
  ),
  proximo AS (
    SELECT DISTINCT ON (ap.child_id, ap.skill_id) ap.id
    FROM activity_plans ap
    JOIN sem_ativo sa ON sa.child_id = ap.child_id AND sa.skill_id = ap.skill_id
    WHERE ap.status = 'bloqueado'
    ORDER BY ap.child_id, ap.skill_id, ap.ordem ASC
  )
  UPDATE activity_plans SET status = 'ativo', started_at = now()
  WHERE id IN (SELECT id FROM proximo);

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

-- Privilégio mínimo: estas duas são SECURITY DEFINER e recebem um id como
-- parâmetro, então EXECUTE aberto deixaria qualquer usuário logado desbloquear
-- o plano de outra conta (unlock_available_plans) ou descobrir se um terceiro
-- é assinante (child_has_premium_access). Só o service_role chama as duas.
-- has_premium_access() e plan_is_accessible() ficam abertas de propósito:
-- rodam dentro das policies, avaliadas como o próprio usuário.
REVOKE ALL ON FUNCTION unlock_available_plans(UUID) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION child_has_premium_access(UUID) FROM PUBLIC, anon, authenticated;

-- Explícito depois do REVOKE FROM PUBLIC: o webhook chama unlock_available_plans
-- por RPC e check_exercise_completion (rodando como service_role) chama
-- child_has_premium_access. Sem isto, dependeria dos default privileges do
-- projeto e poderia falhar com permission denied.
GRANT EXECUTE ON FUNCTION unlock_available_plans(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION child_has_premium_access(UUID) TO service_role;

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
BEGIN
  SELECT es.plan_id, es.child_id, es.successful_count
  INTO v_plan_id, v_child_id, v_success_count
  FROM exercise_sessions es
  WHERE es.id = p_session_id;

  IF v_plan_id IS NULL OR v_success_count < 8 THEN
    RETURN false;
  END IF;

  UPDATE exercise_sessions SET is_completed = true WHERE id = p_session_id;

  UPDATE activity_plans SET status = 'concluido', completed_at = now()
  WHERE id = v_plan_id;

  SELECT ap.skill_id, e.nivel
  INTO v_skill_id, v_nivel
  FROM activity_plans ap
  JOIN exercises e ON e.id = ap.exercise_id
  WHERE ap.id = v_plan_id;

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
