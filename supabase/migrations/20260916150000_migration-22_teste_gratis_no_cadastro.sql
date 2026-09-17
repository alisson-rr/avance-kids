-- ============================================================
-- migration-22: teste grátis de 15 dias começa no cadastro
--
-- O teste deixa de passar pelo Stripe: toda conta nova ganha premium até o
-- fim do 15º dia (meia-noite de Brasília), sem cartão. Assinar durante ou
-- depois do teste cobra na hora (STRIPE_TRIAL_DAYS=0).
--
-- O prazo fica numa coluna própria, e não em plano/status: assim a conta em
-- teste continua 'free' e create-checkout-session aceita a assinatura.
-- ============================================================

ALTER TABLE subscriptions ADD COLUMN teste_gratis_ate TIMESTAMPTZ;

COMMENT ON COLUMN subscriptions.teste_gratis_ate IS
  'Fim do teste grátis do cadastro (exclusivo). Acesso premium enquanto now() < teste_gratis_ate.';

-- Início no dia D (Brasília) -> acesso até o fim do dia D+14 (15 dias).
CREATE OR REPLACE FUNCTION fim_do_teste_gratis(p_inicio TIMESTAMPTZ)
RETURNS TIMESTAMPTZ
LANGUAGE sql STABLE AS $$
  SELECT (((p_inicio AT TIME ZONE 'America/Sao_Paulo')::date + 15)::timestamp)
         AT TIME ZONE 'America/Sao_Paulo';
$$;

-- Mesmo corpo da migration-02, com o prazo do teste na assinatura criada.
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_nascimento TEXT;
BEGIN
  v_nascimento := NEW.raw_user_meta_data->>'data_nascimento';
  IF v_nascimento IS NULL OR v_nascimento !~ '^\d{4}-\d{2}-\d{2}$' THEN
    v_nascimento := NULL;
  END IF;

  INSERT INTO public.profiles (id, nome, cpf, data_nascimento, genero, telefone, termos_aceitos)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nome', NEW.raw_user_meta_data->>'full_name', ''),
    NULLIF(COALESCE(NEW.raw_user_meta_data->>'cpf', ''), ''),
    v_nascimento::DATE,
    NULLIF(COALESCE(NEW.raw_user_meta_data->>'genero', ''), ''),
    NULLIF(COALESCE(NEW.raw_user_meta_data->>'telefone', ''), ''),
    COALESCE((NEW.raw_user_meta_data->>'termos_aceitos')::BOOLEAN, false)
  );

  -- Excluir a conta e se cadastrar de novo com o mesmo e-mail não renova o
  -- teste (mesmo hash que delete-account grava em account_deletions).
  INSERT INTO public.subscriptions (user_id, plano, status, teste_gratis_ate)
  VALUES (
    NEW.id,
    'free',
    'active',
    CASE
      WHEN EXISTS (
        SELECT 1 FROM public.account_deletions d
        WHERE d.email_hash = encode(sha256(convert_to(lower(NEW.email), 'UTF8')), 'hex')
      ) THEN NULL
      ELSE fim_do_teste_gratis(now())
    END
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Acesso premium = assinatura paga OU teste grátis em andamento.
-- Espelhado em isPremiumActive()/emTesteGratis() no app.
CREATE OR REPLACE FUNCTION has_premium_access()
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM subscriptions
    WHERE user_id = auth.uid()
      AND (
        (plano = 'premium' AND status IN ('active', 'trialing'))
        OR teste_gratis_ate > now()
      )
  );
$$;

CREATE OR REPLACE FUNCTION child_has_premium_access(p_child_id UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1
    FROM children c
    JOIN subscriptions s ON s.user_id = c.user_id
    WHERE c.id = p_child_id
      AND (
        (s.plano = 'premium' AND s.status IN ('active', 'trialing'))
        OR s.teste_gratis_ate > now()
      )
  );
$$;

-- Contas de cliente que já existem: 15 dias a partir de hoje. Administradores
-- ficam de fora.
UPDATE subscriptions s
SET teste_gratis_ate = fim_do_teste_gratis(now())
WHERE NOT EXISTS (SELECT 1 FROM admin_users a WHERE a.id = s.user_id);

-- Premium entrou para essas contas: libera a próxima atividade de quem estava
-- sem nenhuma ativa (mesma regra que o webhook aplica quando a assinatura entra).
SELECT unlock_available_plans(s.user_id)
FROM subscriptions s
WHERE NOT EXISTS (SELECT 1 FROM admin_users a WHERE a.id = s.user_id);
