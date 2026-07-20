-- migration-02: handle_new_user grava o perfil completo a partir dos
-- metadados do signup (data_nascimento, genero, telefone, termos_aceitos),
-- em vez de depender de um UPDATE pós-signup do client — que não roda
-- quando o projeto exige confirmação de e-mail (signup sem sessão).
-- Campos ausentes/inválidos viram NULL (signups via OAuth continuam ok).

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

  INSERT INTO public.subscriptions (user_id, plano, status)
  VALUES (NEW.id, 'free', 'active');

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
