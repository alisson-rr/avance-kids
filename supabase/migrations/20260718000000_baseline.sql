-- ============================================================
-- BASELINE V2 — Avance Kids
-- Substitui o schema legado (20260716000000_foundation.sql).
-- Alinhado ao contrato do frontend novo:
--   apps/backoffice/src/constants/aba.ts
--   apps/backoffice/src/types/{common,entities}.ts
-- Decisões de design: docs/BACKEND_PLAN.md (seções 2 e 3).
--
-- Principais mudanças vs. legado:
--   * Perguntas: tabela única `questions` (kind inicial/triagem) com
--     habilidade + faixa etária e escala de resposta FIXA (0/1/2).
--     As tabelas *_question_options deixam de existir; respostas gravam
--     valor_numerico direto em `child_question_answers`.
--   * Exercises: campos ABA estruturados + media_type/media_url +
--     plano (free/premium) + status (ativo/arquivado).
--   * `ativo BOOLEAN` -> `status record_status` (arquivamento reversível).
--   * `is_premium BOOLEAN` -> `plano subscription_plan`.
--   * skills ganham `key` (slug usado pelo frontend).
--   * admin_users agora referencia auth.users (sem password_hash próprio);
--     escrita de conteúdo via policies is_admin().
--   * profiles.cpf vira nullable com índice único parcial (o índice único
--     legado sobre '' quebrava o signup do 2º usuário sem CPF).
-- ============================================================

-- ============================================================
-- 1. ENUMS E FUNÇÕES BASE
-- ============================================================

CREATE TYPE record_status AS ENUM ('ativo', 'arquivado');
CREATE TYPE media_type AS ENUM ('imagem', 'video');
CREATE TYPE question_kind AS ENUM ('inicial', 'triagem');
CREATE TYPE exercise_level AS ENUM ('aquisicao', 'generalizacao', 'manutencao');
CREATE TYPE attempt_result AS ENUM ('sem_ajuda', 'ajuda_parcial', 'ajuda_total');
CREATE TYPE plan_status AS ENUM ('ativo', 'concluido', 'bloqueado');
CREATE TYPE subscription_plan AS ENUM ('free', 'premium');
CREATE TYPE subscription_status AS ENUM ('active', 'canceled', 'past_due', 'trialing');
CREATE TYPE admin_role AS ENUM ('admin', 'super_admin');

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 2. ADMIN (Supabase Auth + role)
-- ============================================================

CREATE TABLE admin_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  role admin_role NOT NULL DEFAULT 'admin',
  status record_status NOT NULL DEFAULT 'ativo',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_admin_users_updated_at
  BEFORE UPDATE ON admin_users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- SECURITY DEFINER: bypassa RLS de admin_users para evitar recursão nas policies.
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM admin_users
    WHERE id = auth.uid() AND status = 'ativo'
  );
$$;

CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM admin_users
    WHERE id = auth.uid() AND status = 'ativo' AND role = 'super_admin'
  );
$$;

ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view admin users"
  ON admin_users FOR SELECT
  TO authenticated
  USING (is_admin());

CREATE POLICY "Super admins manage admin users"
  ON admin_users FOR ALL
  TO authenticated
  USING (is_super_admin())
  WITH CHECK (is_super_admin());

-- Bootstrap do primeiro admin: o usuário deve existir em auth.users
-- (criado via Dashboard ou Auth API). Executar via SQL Editor/service_role:
--   SELECT promote_to_admin('<auth_user_uuid>', 'Nome', 'email@x.com', 'super_admin');
CREATE OR REPLACE FUNCTION promote_to_admin(
  p_user_id UUID,
  p_nome TEXT,
  p_email TEXT,
  p_role admin_role DEFAULT 'admin'
)
RETURNS void
LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  INSERT INTO admin_users (id, nome, email, role, status)
  VALUES (p_user_id, p_nome, p_email, p_role, 'ativo')
  ON CONFLICT (id) DO UPDATE
    SET nome = EXCLUDED.nome,
        email = EXCLUDED.email,
        role = EXCLUDED.role,
        status = 'ativo';
$$;

REVOKE EXECUTE ON FUNCTION promote_to_admin(UUID, TEXT, TEXT, admin_role) FROM PUBLIC, anon, authenticated;

-- ============================================================
-- 3. PROFILES
-- ============================================================

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  data_nascimento DATE,
  genero TEXT,
  cpf TEXT,
  telefone TEXT,
  avatar_url TEXT,
  termos_aceitos BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Único apenas quando informado (admins e contas sociais podem não ter CPF).
CREATE UNIQUE INDEX idx_profiles_cpf ON profiles(cpf) WHERE cpf IS NOT NULL AND cpf <> '';

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (is_admin());

-- ============================================================
-- 4. ESTRUTURA BASE (skills, age_brackets)
-- ============================================================

CREATE TABLE skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL UNIQUE,           -- slug usado pelo frontend (HabilidadeKey)
  nome TEXT NOT NULL UNIQUE,
  cor_hex TEXT NOT NULL,
  icone TEXT,
  ordem INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE skills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can read skills"
  ON skills FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins manage skills"
  ON skills FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE TABLE age_brackets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT NOT NULL UNIQUE,        -- F01A..F06A (AgeBracketCode)
  nome TEXT NOT NULL,
  meses_min INTEGER NOT NULL,
  meses_max INTEGER NOT NULL,
  descricao TEXT,
  ordem INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE age_brackets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can read age_brackets"
  ON age_brackets FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins manage age_brackets"
  ON age_brackets FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ============================================================
-- 5. CRIANÇAS
-- ============================================================

CREATE TABLE children (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  data_nascimento DATE NOT NULL,
  genero TEXT,
  cpf TEXT,
  condicoes JSONB NOT NULL DEFAULT '[]'::jsonb,  -- ["TEA", "TDAH", "Down"]
  idade_biologica_meses INTEGER,
  idade_geral_meses INTEGER,                     -- resultado das perguntas iniciais
  triagem_completa BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_children_user_id ON children(user_id);

CREATE TRIGGER trg_children_updated_at
  BEFORE UPDATE ON children
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE children ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own children"
  ON children FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all children"
  ON children FOR SELECT
  TO authenticated
  USING (is_admin());

CREATE TABLE child_skill_ages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  skill_id UUID NOT NULL REFERENCES skills(id),
  idade_meses INTEGER NOT NULL,
  faixa_id UUID REFERENCES age_brackets(id),
  evaluated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(child_id, skill_id)
);

CREATE INDEX idx_child_skill_ages_child_id ON child_skill_ages(child_id);

ALTER TABLE child_skill_ages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own children skill ages"
  ON child_skill_ages FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_skill_ages.child_id AND c.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_skill_ages.child_id AND c.user_id = auth.uid()
    )
  );

-- ============================================================
-- 6. PERGUNTAS (iniciais + triagem, forma única)
-- ============================================================
-- Escala de resposta FIXA para toda pergunta (ANSWER_SCALE do frontend):
--   0 = Nunca / Não observei | 1 = Às vezes | 2 = Sempre
-- Não existem mais opções por pergunta.

CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kind question_kind NOT NULL,
  skill_id UUID NOT NULL REFERENCES skills(id),
  age_bracket_id UUID NOT NULL REFERENCES age_brackets(id),
  texto TEXT NOT NULL,
  ordem INTEGER NOT NULL DEFAULT 0,
  status record_status NOT NULL DEFAULT 'ativo',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_questions_lookup ON questions(kind, age_bracket_id, skill_id, ordem);

CREATE TRIGGER trg_questions_updated_at
  BEFORE UPDATE ON questions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read active questions"
  ON questions FOR SELECT
  TO authenticated
  USING (status = 'ativo' OR is_admin());

CREATE POLICY "Admins manage questions"
  ON questions FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Respostas (iniciais e triagem na mesma tabela; o tipo vem da pergunta).
-- "Não observei" grava valor_numerico = 0 com nao_observado = true
-- (conta como 0 no cálculo, igual ao legado; o flag preserva o dado bruto).
CREATE TABLE child_question_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id),
  valor_numerico SMALLINT NOT NULL CHECK (valor_numerico >= 0 AND valor_numerico <= 2),
  nao_observado BOOLEAN NOT NULL DEFAULT false,
  answered_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(child_id, question_id)
);

CREATE INDEX idx_child_question_answers_child ON child_question_answers(child_id);
CREATE INDEX idx_child_question_answers_question ON child_question_answers(question_id);

ALTER TABLE child_question_answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own children answers"
  ON child_question_answers FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_question_answers.child_id AND c.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_question_answers.child_id AND c.user_id = auth.uid()
    )
  );

-- ============================================================
-- 7. ATIVIDADES (exercises — Programa ABA)
-- ============================================================

CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id UUID NOT NULL REFERENCES skills(id),
  age_bracket_id UUID NOT NULL REFERENCES age_brackets(id),
  codigo TEXT,                          -- padrão FXAYZZZ (guia visual, não gerado)
  titulo TEXT NOT NULL,
  media_type media_type NOT NULL DEFAULT 'imagem',
  media_url TEXT,                       -- imagem: Storage `media`; video: URL externa
  nivel exercise_level NOT NULL DEFAULT 'aquisicao',
  ordem INTEGER NOT NULL DEFAULT 0,
  plano subscription_plan NOT NULL DEFAULT 'free',
  status record_status NOT NULL DEFAULT 'ativo',

  -- Campos do Programa ABA (form do backoffice, 3 abas)
  objetivo TEXT,
  procedimento TEXT,
  materiais TEXT,
  recursos_extras TEXT,
  frequencia TEXT,
  brincadeiras TEXT,
  hierarquia_dicas TEXT,
  resposta_esperada TEXT,
  procedimento_correcao TEXT,
  criterio_avanco TEXT,
  registro_dados TEXT,
  reforcos TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_exercises_skill_bracket ON exercises(skill_id, age_bracket_id, nivel, ordem);
CREATE INDEX idx_exercises_codigo ON exercises(codigo) WHERE codigo IS NOT NULL;

CREATE TRIGGER trg_exercises_updated_at
  BEFORE UPDATE ON exercises
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read active exercises"
  ON exercises FOR SELECT
  TO authenticated
  USING (status = 'ativo' OR is_admin());

CREATE POLICY "Admins manage exercises"
  ON exercises FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ============================================================
-- 8. PLANOS DE ATIVIDADE E TENTATIVAS
-- ============================================================

CREATE TABLE activity_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  skill_id UUID NOT NULL REFERENCES skills(id),
  exercise_id UUID NOT NULL REFERENCES exercises(id),
  status plan_status NOT NULL DEFAULT 'bloqueado',
  ordem INTEGER NOT NULL DEFAULT 0,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_activity_plans_child_id ON activity_plans(child_id);
CREATE INDEX idx_activity_plans_child_skill ON activity_plans(child_id, skill_id);
CREATE INDEX idx_activity_plans_status ON activity_plans(child_id, status) WHERE status = 'ativo';

CREATE TRIGGER trg_activity_plans_updated_at
  BEFORE UPDATE ON activity_plans
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE activity_plans ENABLE ROW LEVEL SECURITY;

-- INSERT/DELETE de planos acontece apenas via Edge Function (service_role).
CREATE POLICY "Users can view own children plans"
  ON activity_plans FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = activity_plans.child_id AND c.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own children plans"
  ON activity_plans FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = activity_plans.child_id AND c.user_id = auth.uid()
    )
  );

-- Sessões de exercício (janela de 7 dias, até 10 repetições)
CREATE TABLE exercise_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES activity_plans(id) ON DELETE CASCADE,
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  total_repetitions INTEGER NOT NULL DEFAULT 0,
  successful_count INTEGER NOT NULL DEFAULT 0,    -- COUNT de "sem_ajuda"
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '7 days'),
  is_completed BOOLEAN NOT NULL DEFAULT false,

  CHECK (total_repetitions >= 0 AND total_repetitions <= 10),
  CHECK (successful_count >= 0 AND successful_count <= 10)
);

CREATE INDEX idx_exercise_sessions_plan_id ON exercise_sessions(plan_id);
CREATE INDEX idx_exercise_sessions_expires ON exercise_sessions(expires_at) WHERE NOT is_completed;

ALTER TABLE exercise_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own sessions"
  ON exercise_sessions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = exercise_sessions.child_id AND c.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = exercise_sessions.child_id AND c.user_id = auth.uid()
    )
  );

-- Tentativas individuais (cada repetição)
CREATE TABLE exercise_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES exercise_sessions(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES activity_plans(id) ON DELETE CASCADE,
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  repeticao_numero INTEGER NOT NULL,
  resultado attempt_result NOT NULL,
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CHECK (repeticao_numero >= 1 AND repeticao_numero <= 10)
);

CREATE INDEX idx_exercise_attempts_session ON exercise_attempts(session_id);
CREATE INDEX idx_exercise_attempts_plan_id ON exercise_attempts(plan_id);

ALTER TABLE exercise_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own attempts"
  ON exercise_attempts FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = exercise_attempts.child_id AND c.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = exercise_attempts.child_id AND c.user_id = auth.uid()
    )
  );

-- ============================================================
-- 9. BRINCADEIRAS E ARTIGOS
-- ============================================================

CREATE TABLE plays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo TEXT NOT NULL,
  descricao TEXT,
  instrucoes TEXT,
  media_type media_type NOT NULL DEFAULT 'imagem',
  media_url TEXT,
  plano subscription_plan NOT NULL DEFAULT 'free',
  status record_status NOT NULL DEFAULT 'ativo',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_plays_updated_at
  BEFORE UPDATE ON plays
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE plays ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read active plays"
  ON plays FOR SELECT
  TO authenticated
  USING (status = 'ativo' OR is_admin());

CREATE POLICY "Admins manage plays"
  ON plays FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE TABLE articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo TEXT NOT NULL,
  corpo TEXT NOT NULL,                  -- rich text / markdown
  imagem_url TEXT,
  plano subscription_plan NOT NULL DEFAULT 'free',
  status record_status NOT NULL DEFAULT 'ativo',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_articles_updated_at
  BEFORE UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read active articles"
  ON articles FOR SELECT
  TO authenticated
  USING (status = 'ativo' OR is_admin());

CREATE POLICY "Admins manage articles"
  ON articles FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ============================================================
-- 10. ASSINATURAS E PAGAMENTOS (Stripe)
-- ============================================================

CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  plano subscription_plan NOT NULL DEFAULT 'free',
  status subscription_status NOT NULL DEFAULT 'active',
  trial_start TIMESTAMPTZ,
  trial_end TIMESTAMPTZ,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(user_id)
);

CREATE INDEX idx_subscriptions_stripe ON subscriptions(stripe_customer_id);

CREATE TRIGGER trg_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all subscriptions"
  ON subscriptions FOR SELECT
  TO authenticated
  USING (is_admin());

CREATE TABLE payment_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  stripe_payment_intent_id TEXT,
  amount_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'brl',
  status TEXT NOT NULL,                 -- succeeded, failed, pending
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT uq_payment_intent UNIQUE (stripe_payment_intent_id)
);

CREATE INDEX idx_payment_history_user_id ON payment_history(user_id);

ALTER TABLE payment_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own payments"
  ON payment_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all payments"
  ON payment_history FOR SELECT
  TO authenticated
  USING (is_admin());

-- ============================================================
-- 11. TRIGGER DE SIGNUP (profile + assinatura free)
-- ============================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nome, cpf)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nome', NEW.raw_user_meta_data->>'full_name', ''),
    NULLIF(COALESCE(NEW.raw_user_meta_data->>'cpf', ''), '')
  );

  INSERT INTO public.subscriptions (user_id, plano, status)
  VALUES (NEW.id, 'free', 'active');

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- 12. FUNÇÕES DE CÁLCULO
-- ============================================================

-- Idade biológica em meses
CREATE OR REPLACE FUNCTION calculate_biological_age(birth_date DATE)
RETURNS INTEGER AS $$
BEGIN
  RETURN EXTRACT(YEAR FROM age(CURRENT_DATE, birth_date)) * 12
       + EXTRACT(MONTH FROM age(CURRENT_DATE, birth_date));
END;
$$ LANGUAGE plpgsql STABLE;

-- Resolve faixa etária a partir de meses (com clamp 12..144 e fallback p/ gaps)
CREATE OR REPLACE FUNCTION resolve_age_bracket(idade_meses INTEGER)
RETURNS UUID AS $$
DECLARE
  bracket_id UUID;
  clamped INTEGER;
BEGIN
  clamped := GREATEST(12, LEAST(144, idade_meses));

  SELECT id INTO bracket_id
  FROM age_brackets
  WHERE clamped >= meses_min AND clamped <= meses_max
  ORDER BY ordem ASC
  LIMIT 1;

  -- Gap entre faixas (ex.: 61-71 meses, entre F04A e F05A): usa a faixa anterior
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

-- Idade geral: média das respostas iniciais na escala fixa 0-2.
-- Score 2 = na faixa biológica; cada ponto abaixo de 2 regride ~12 meses.
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
    AND q.kind = 'inicial';

  IF avg_score IS NULL THEN
    RETURN bio_age;
  END IF;

  result_age := bio_age - ROUND((2.0 - avg_score) * 12)::INTEGER;

  RETURN GREATEST(12, result_age);
END;
$$ LANGUAGE plpgsql STABLE;

-- Idade por habilidade: média das respostas de triagem da habilidade (0-2),
-- regredindo a partir da idade geral (ou biológica se a geral não existir).
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
    AND q.skill_id = p_skill_id;

  IF avg_score IS NULL THEN
    RETURN base_age;
  END IF;

  result_age := base_age - ROUND((2.0 - avg_score) * 12)::INTEGER;

  RETURN GREATEST(12, result_age);
END;
$$ LANGUAGE plpgsql STABLE;

-- Conclusão de exercício (≥8/10 sem ajuda) + desbloqueio do próximo:
--   aquisição -> generalização -> manutenção -> próximo exercício (aquisição)
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
  ORDER BY ap.ordem ASC
  LIMIT 1;

  -- Fallback: se não há plano bloqueado no nível alvo, desbloqueia o próximo
  -- bloqueado da habilidade na ordem (evita travar a trilha).
  IF v_next_plan_id IS NULL THEN
    SELECT ap.id INTO v_next_plan_id
    FROM activity_plans ap
    WHERE ap.child_id = v_child_id
      AND ap.skill_id = v_skill_id
      AND ap.status = 'bloqueado'
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

-- ============================================================
-- 13. STORAGE (buckets media e avatars)
-- ============================================================
-- Se o projeto hospedado restringir DDL em storage.objects, criar estas
-- policies pelo Dashboard (Storage > Policies) com as mesmas condições.

DO $$
BEGIN
  INSERT INTO storage.buckets (id, name, public)
  VALUES ('media', 'media', true), ('avatars', 'avatars', true)
  ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

  CREATE POLICY "Public read app buckets"
    ON storage.objects FOR SELECT
    USING (bucket_id IN ('media', 'avatars'));

  CREATE POLICY "Admins manage media bucket"
    ON storage.objects FOR ALL
    TO authenticated
    USING (bucket_id = 'media' AND public.is_admin())
    WITH CHECK (bucket_id = 'media' AND public.is_admin());

  CREATE POLICY "Users manage own avatar folder"
    ON storage.objects FOR ALL
    TO authenticated
    USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text)
    WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'Sem privilégio para configurar storage via migration — criar buckets/policies pelo Dashboard.';
END $$;

-- ============================================================
-- 14. SEED DATA
-- ============================================================

INSERT INTO age_brackets (codigo, nome, meses_min, meses_max, descricao, ordem) VALUES
  ('F01A', '12 a 24 meses',  12,  24, 'Bebê (1 a 2 anos)',            1),
  ('F02A', '25 a 36 meses',  25,  36, 'Criança pequena (2 a 3 anos)', 2),
  ('F03A', '37 a 48 meses',  37,  48, 'Pré-escolar (3 a 4 anos)',     3),
  ('F04A', '49 a 60 meses',  49,  60, 'Pré-escolar (4 a 5 anos)',     4),
  ('F05A', '6 a 8 anos',     72,  96, 'Escolar inicial',              5),
  ('F06A', '9 a 12 anos',   108, 144, 'Escolar avançado',             6);

-- keys espelham HabilidadeKey do frontend (constants/aba.ts)
INSERT INTO skills (key, nome, cor_hex, icone, ordem) VALUES
  ('comunicacao', 'Comunicação',        '#3B82F6', '📘', 1),
  ('social',      'Social',             '#22C55E', '👥', 2),
  ('cognitiva',   'Cognitiva',          '#F59E0B', '🧠', 3),
  ('motora',      'Coordenação Motora', '#8B5CF6', '🧩', 4),
  ('funcional',   'Funcional',          '#EC4899', '🏡', 5);
