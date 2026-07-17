-- ============================================================
-- MIGRATION 001: Tipos ENUM e Função de Timestamps
-- ============================================================

-- ENUMs
CREATE TYPE exercise_level AS ENUM ('aquisicao', 'generalizacao', 'manutencao');
CREATE TYPE attempt_result AS ENUM ('sem_ajuda', 'ajuda_parcial', 'ajuda_total');
CREATE TYPE plan_status AS ENUM ('ativo', 'concluido', 'bloqueado');
CREATE TYPE subscription_plan AS ENUM ('free', 'premium');
CREATE TYPE subscription_status AS ENUM ('active', 'canceled', 'past_due', 'trialing');
CREATE TYPE media_type AS ENUM ('imagem', 'video');
CREATE TYPE admin_role AS ENUM ('admin', 'super_admin');

-- Trigger genérico para updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- MIGRATION 002: Profiles
-- ============================================================

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  data_nascimento DATE,
  genero TEXT,
  cpf TEXT NOT NULL,
  telefone TEXT,
  avatar_url TEXT,
  termos_aceitos BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice para busca por CPF (único)
CREATE UNIQUE INDEX idx_profiles_cpf ON profiles(cpf);

-- Trigger updated_at
CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Trigger: auto-criar profile ao registrar
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nome, cpf)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nome', NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'cpf', '')
  );
  
  -- Cria assinatura free automática
  INSERT INTO public.subscriptions (user_id, plano, status)
  VALUES (NEW.id, 'free', 'active');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- MIGRATION 003: Estrutura Base
-- ============================================================

-- Faixas Etárias
CREATE TABLE age_brackets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT NOT NULL UNIQUE,       -- F01A, F02A, etc.
  nome TEXT NOT NULL,                -- "12 a 24 meses"
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

-- Habilidades
CREATE TABLE skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL UNIQUE,          -- Comunicação, Social, etc.
  cor_hex TEXT NOT NULL,              -- #3B82F6
  icone TEXT,                         -- emoji ou nome do ícone
  ordem INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE skills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can read skills"
  ON skills FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- MIGRATION 004: Crianças
-- ============================================================

CREATE TABLE children (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  data_nascimento DATE NOT NULL,
  genero TEXT,
  cpf TEXT,                            -- opcional
  condicoes JSONB DEFAULT '[]'::jsonb, -- ["TEA", "TDAH", "Down"]
  idade_biologica_meses INTEGER,       -- calculada
  idade_geral_meses INTEGER,           -- resultado perguntas iniciais
  triagem_completa BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_children_user_id ON children(user_id);

CREATE TRIGGER trg_children_updated_at
  BEFORE UPDATE ON children
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE children ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own children"
  ON children FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own children"
  ON children FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own children"
  ON children FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own children"
  ON children FOR DELETE
  USING (auth.uid() = user_id);

-- Idades por Habilidade
CREATE TABLE child_skill_ages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  skill_id UUID NOT NULL REFERENCES skills(id),
  idade_meses INTEGER NOT NULL,
  faixa_id UUID REFERENCES age_brackets(id),
  evaluated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE(child_id, skill_id)   -- 1 idade por habilidade por criança
);

CREATE INDEX idx_child_skill_ages_child_id ON child_skill_ages(child_id);

ALTER TABLE child_skill_ages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own children skill ages"
  ON child_skill_ages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_skill_ages.child_id AND c.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own children skill ages"
  ON child_skill_ages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_skill_ages.child_id AND c.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own children skill ages"
  ON child_skill_ages FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_skill_ages.child_id AND c.user_id = auth.uid()
    )
  );

-- ============================================================
-- MIGRATION 005: Perguntas Iniciais
-- ============================================================

CREATE TABLE initial_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  texto TEXT NOT NULL,
  ordem INTEGER NOT NULL DEFAULT 0,
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_initial_questions_updated_at
  BEFORE UPDATE ON initial_questions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE initial_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can read active initial questions"
  ON initial_questions FOR SELECT
  TO authenticated
  USING (ativo = true);

-- Opções de resposta
CREATE TABLE initial_question_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES initial_questions(id) ON DELETE CASCADE,
  texto TEXT NOT NULL,
  valor_numerico INTEGER NOT NULL DEFAULT 0,  -- 0=nunca, 1=às vezes, 2=sempre, 3=não observou(=0)
  ordem INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_initial_q_options_question ON initial_question_options(question_id);

ALTER TABLE initial_question_options ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can read initial question options"
  ON initial_question_options FOR SELECT
  TO authenticated
  USING (true);

-- Respostas do usuário
CREATE TABLE child_initial_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES initial_questions(id),
  option_id UUID NOT NULL REFERENCES initial_question_options(id),
  answered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE(child_id, question_id)  -- 1 resposta por pergunta por criança
);

CREATE INDEX idx_child_initial_answers_child ON child_initial_answers(child_id);

ALTER TABLE child_initial_answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own children answers"
  ON child_initial_answers FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_initial_answers.child_id AND c.user_id = auth.uid()
    )
  );

-- ============================================================
-- MIGRATION 006: Perguntas de Triagem
-- ============================================================

CREATE TABLE screening_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id UUID NOT NULL REFERENCES skills(id),
  age_bracket_id UUID NOT NULL REFERENCES age_brackets(id),
  texto TEXT NOT NULL,
  codigo TEXT,                         -- FXAYZZZ (ex: F01AC004)
  ordem INTEGER NOT NULL DEFAULT 0,
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_screening_q_skill_bracket ON screening_questions(skill_id, age_bracket_id);

CREATE TRIGGER trg_screening_questions_updated_at
  BEFORE UPDATE ON screening_questions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE screening_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can read active screening questions"
  ON screening_questions FOR SELECT
  TO authenticated
  USING (ativo = true);

-- Opções (mesmas 4 opções fixas, mas vinculadas)
CREATE TABLE screening_question_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES screening_questions(id) ON DELETE CASCADE,
  texto TEXT NOT NULL,
  valor_numerico INTEGER NOT NULL DEFAULT 0,
  ordem INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_screening_q_options_question ON screening_question_options(question_id);

ALTER TABLE screening_question_options ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can read screening question options"
  ON screening_question_options FOR SELECT
  TO authenticated
  USING (true);

-- Respostas da triagem
CREATE TABLE child_screening_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES screening_questions(id),
  option_id UUID NOT NULL REFERENCES screening_question_options(id),
  skill_id UUID NOT NULL REFERENCES skills(id),
  answered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE(child_id, question_id)  -- 1 resposta por pergunta por criança
);

CREATE INDEX idx_child_screening_answers_child_skill ON child_screening_answers(child_id, skill_id);

ALTER TABLE child_screening_answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own children screening answers"
  ON child_screening_answers FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = child_screening_answers.child_id AND c.user_id = auth.uid()
    )
  );

-- ============================================================
-- MIGRATION 007: Exercícios
-- ============================================================

CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id UUID NOT NULL REFERENCES skills(id),
  age_bracket_id UUID NOT NULL REFERENCES age_brackets(id),
  codigo TEXT,                          -- FXAYZZZ
  titulo TEXT NOT NULL,
  descricao TEXT,
  instrucoes TEXT,
  video_url TEXT,                       -- YouTube/Vimeo link (opcional)
  nivel exercise_level NOT NULL DEFAULT 'aquisicao',
  ordem INTEGER NOT NULL DEFAULT 0,
  is_premium BOOLEAN NOT NULL DEFAULT false,
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_exercises_skill_bracket ON exercises(skill_id, age_bracket_id, nivel, ordem);
CREATE INDEX idx_exercises_codigo ON exercises(codigo) WHERE codigo IS NOT NULL;

CREATE TRIGGER trg_exercises_updated_at
  BEFORE UPDATE ON exercises
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can read active exercises"
  ON exercises FOR SELECT
  TO authenticated
  USING (ativo = true);

-- ============================================================
-- MIGRATION 008: Planos e Tentativas
-- ============================================================

-- Plano de atividades (1 exercício ativo por habilidade)
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

-- Sessões de exercício (janela de 7 dias)
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

CREATE POLICY "Users can manage own sessions"
  ON exercise_sessions FOR ALL
  USING (
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
  repeticao_numero INTEGER NOT NULL,    -- 1 a 10
  resultado attempt_result NOT NULL,
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  CHECK (repeticao_numero >= 1 AND repeticao_numero <= 10)
);

CREATE INDEX idx_exercise_attempts_session ON exercise_attempts(session_id);
CREATE INDEX idx_exercise_attempts_plan_id ON exercise_attempts(plan_id);

ALTER TABLE exercise_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own attempts"
  ON exercise_attempts FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM children c WHERE c.id = exercise_attempts.child_id AND c.user_id = auth.uid()
    )
  );

-- ============================================================
-- MIGRATION 009: Brincadeiras e Artigos
-- ============================================================

CREATE TABLE plays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo TEXT NOT NULL,
  descricao TEXT,
  instrucoes TEXT,
  media_type media_type,               -- 'imagem' ou 'video'
  media_url TEXT,                       -- URL da mídia
  is_premium BOOLEAN NOT NULL DEFAULT false,
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_plays_updated_at
  BEFORE UPDATE ON plays
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE plays ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can read active plays"
  ON plays FOR SELECT
  TO authenticated
  USING (ativo = true);

-- Artigos
CREATE TABLE articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo TEXT NOT NULL,
  corpo TEXT NOT NULL,                  -- rich text / markdown
  imagem_url TEXT,
  is_premium BOOLEAN NOT NULL DEFAULT false,
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_articles_updated_at
  BEFORE UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can read active articles"
  ON articles FOR SELECT
  TO authenticated
  USING (ativo = true);

-- ============================================================
-- MIGRATION 010: Assinaturas e Pagamentos
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
  
  UNIQUE(user_id)  -- 1 assinatura por usuário
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe ON subscriptions(stripe_customer_id);

CREATE TRIGGER trg_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Histórico de pagamentos
CREATE TABLE payment_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  stripe_payment_intent_id TEXT,
  amount_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'brl',
  status TEXT NOT NULL,                 -- succeeded, failed, pending
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE payment_history ADD CONSTRAINT uq_payment_intent UNIQUE (stripe_payment_intent_id);
CREATE INDEX idx_payment_history_user_id ON payment_history(user_id);

ALTER TABLE payment_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own payments"
  ON payment_history FOR SELECT
  USING (auth.uid() = user_id);

-- ============================================================
-- MIGRATION 011: Admin Users
-- ============================================================

CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  nome TEXT NOT NULL,
  password_hash TEXT NOT NULL,          -- bcrypt hash
  role admin_role NOT NULL DEFAULT 'admin',
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_admin_users_updated_at
  BEFORE UPDATE ON admin_users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Admin NÃO usa RLS — acessado via service_role key
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
-- Nenhuma policy pública — apenas service_role tem acesso

-- ============================================================
-- MIGRATION 012: Seed Data
-- ============================================================

-- Faixas Etárias
INSERT INTO age_brackets (codigo, nome, meses_min, meses_max, descricao, ordem) VALUES
  ('F01A', '12 a 24 meses',  12,  24, 'Bebê (1 a 2 anos)',        1),
  ('F02A', '25 a 36 meses',  25,  36, 'Criança pequena (2 a 3 anos)', 2),
  ('F03A', '37 a 48 meses',  37,  48, 'Pré-escolar (3 a 4 anos)', 3),
  ('F04A', '49 a 60 meses',  49,  60, 'Pré-escolar (4 a 5 anos)', 4),
  ('F05A', '6 a 8 anos',     72,  96, 'Escolar inicial',          5),
  ('F06A', '9 a 12 anos',   108, 144, 'Escolar avançado',         6);

-- Habilidades
INSERT INTO skills (nome, cor_hex, icone, ordem) VALUES
  ('Comunicação',        '#3B82F6', '📘', 1),
  ('Social',             '#22C55E', '👥', 2),
  ('Cognitiva',          '#F59E0B', '🧠', 3),
  ('Coordenação Motora', '#8B5CF6', '🧩', 4),
  ('Funcional',          '#EC4899', '🏡', 5);

-- O Trigger que depende das subscriptions
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- MIGRATION 013: Funções de Cálculo
-- ============================================================

-- Calcula idade biológica em meses
CREATE OR REPLACE FUNCTION calculate_biological_age(birth_date DATE)
RETURNS INTEGER AS $$
BEGIN
  RETURN EXTRACT(YEAR FROM age(CURRENT_DATE, birth_date)) * 12
       + EXTRACT(MONTH FROM age(CURRENT_DATE, birth_date));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Resolve faixa etária a partir de meses
CREATE OR REPLACE FUNCTION resolve_age_bracket(idade_meses INTEGER)
RETURNS UUID AS $$
DECLARE
  bracket_id UUID;
  clamped INTEGER;
BEGIN
  -- Clamp: mínimo 12, máximo 144
  clamped := GREATEST(12, LEAST(144, idade_meses));
  
  SELECT id INTO bracket_id
  FROM age_brackets
  WHERE clamped >= meses_min AND clamped <= meses_max
  ORDER BY ordem ASC
  LIMIT 1;
  
  -- Fallback: se caiu num gap (ex: 61-71 meses, entre F04A e F05A)
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

-- Calcula idade geral baseada nas perguntas iniciais
CREATE OR REPLACE FUNCTION calculate_general_age(p_child_id UUID)
RETURNS INTEGER AS $$
DECLARE
  bio_age INTEGER;
  avg_score NUMERIC;
  max_score NUMERIC;
  result_age INTEGER;
BEGIN
  -- Pegar idade biológica
  SELECT idade_biologica_meses INTO bio_age
  FROM children WHERE id = p_child_id;
  
  -- Média das respostas (valor_numerico)
  SELECT 
    AVG(iqo.valor_numerico),
    MAX(iqo.valor_numerico)
  INTO avg_score, max_score
  FROM child_initial_answers cia
  JOIN initial_question_options iqo ON iqo.id = cia.option_id
  WHERE cia.child_id = p_child_id;
  
  -- Se não há respostas, retorna biológica
  IF avg_score IS NULL THEN
    RETURN bio_age;
  END IF;
  
  -- Lógica: score 2 = na faixa, score < 2 = regride proporcionalmente
  -- Cada ponto abaixo de 2 regride ~12 meses (1 faixa)
  result_age := bio_age - ROUND((2.0 - avg_score) * 12)::INTEGER;
  
  -- Clamp mínimo em 12 meses
  RETURN GREATEST(12, result_age);
END;
$$ LANGUAGE plpgsql STABLE;

-- Calcula idade por habilidade
CREATE OR REPLACE FUNCTION calculate_skill_age(p_child_id UUID, p_skill_id UUID)
RETURNS INTEGER AS $$
DECLARE
  general_age INTEGER;
  avg_score NUMERIC;
  result_age INTEGER;
BEGIN
  -- Pegar idade geral
  SELECT idade_geral_meses INTO general_age
  FROM children WHERE id = p_child_id;
  
  -- Se não tem idade geral, usa biológica
  IF general_age IS NULL THEN
    SELECT idade_biologica_meses INTO general_age
    FROM children WHERE id = p_child_id;
  END IF;
  
  -- Média das respostas da triagem para esta habilidade
  SELECT AVG(sqo.valor_numerico)
  INTO avg_score
  FROM child_screening_answers csa
  JOIN screening_question_options sqo ON sqo.id = csa.option_id
  WHERE csa.child_id = p_child_id AND csa.skill_id = p_skill_id;
  
  IF avg_score IS NULL THEN
    RETURN general_age;
  END IF;
  
  -- Mesma lógica: score < 2 regride
  result_age := general_age - ROUND((2.0 - avg_score) * 12)::INTEGER;
  
  RETURN GREATEST(12, result_age);
END;
$$ LANGUAGE plpgsql STABLE;

-- Verifica conclusão do exercício e desbloqueia próximo
CREATE OR REPLACE FUNCTION check_exercise_completion(p_session_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_plan_id UUID;
  v_child_id UUID;
  v_skill_id UUID;
  v_exercise_id UUID;
  v_nivel exercise_level;
  v_success_count INTEGER;
  v_total INTEGER;
  v_next_plan_id UUID;
BEGIN
  -- Buscar dados da sessão
  SELECT es.plan_id, es.child_id, es.successful_count, es.total_repetitions
  INTO v_plan_id, v_child_id, v_success_count, v_total
  FROM exercise_sessions es
  WHERE es.id = p_session_id;
  
  -- Verificar critério: ≥ 8 de 10 sem ajuda
  IF v_success_count < 8 THEN
    RETURN false;
  END IF;
  
  -- Marcar sessão como completa
  UPDATE exercise_sessions SET is_completed = true WHERE id = p_session_id;
  
  -- Marcar plano como concluído
  UPDATE activity_plans SET status = 'concluido', completed_at = now()
  WHERE id = v_plan_id;
  
  -- Buscar dados do exercício atual
  SELECT ap.skill_id, ap.exercise_id, e.nivel
  INTO v_skill_id, v_exercise_id, v_nivel
  FROM activity_plans ap
  JOIN exercises e ON e.id = ap.exercise_id
  WHERE ap.id = v_plan_id;
  
  -- Desbloquear próximo baseado no nível
  -- Se aquisição → próximo é mesmo exercício nível B (generalização)
  -- Se generalização → próximo é mesmo exercício nível C (manutenção)
  -- Se manutenção → próximo exercício da faixa nível A
  IF v_nivel = 'aquisicao' OR v_nivel = 'generalizacao' THEN
    -- Buscar próximo nível do MESMO exercício code
    SELECT ap.id INTO v_next_plan_id
    FROM activity_plans ap
    JOIN exercises e ON e.id = ap.exercise_id
    WHERE ap.child_id = v_child_id
      AND ap.skill_id = v_skill_id
      AND ap.status = 'bloqueado'
      AND e.nivel = (CASE WHEN v_nivel = 'aquisicao' THEN 'generalizacao' ELSE 'manutencao' END)
    ORDER BY ap.ordem ASC
    LIMIT 1;
  ELSE
    -- Manutenção concluída → próximo exercício A da mesma habilidade
    SELECT ap.id INTO v_next_plan_id
    FROM activity_plans ap
    JOIN exercises e ON e.id = ap.exercise_id
    WHERE ap.child_id = v_child_id
      AND ap.skill_id = v_skill_id
      AND ap.status = 'bloqueado'
      AND e.nivel = 'aquisicao'
    ORDER BY ap.ordem ASC
    LIMIT 1;
  END IF;
  
  -- Desbloquear o próximo
  IF v_next_plan_id IS NOT NULL THEN
    UPDATE activity_plans SET status = 'ativo', started_at = now()
    WHERE id = v_next_plan_id;
  END IF;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql;
