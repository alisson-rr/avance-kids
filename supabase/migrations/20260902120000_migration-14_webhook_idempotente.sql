-- migration-14: processamento idempotente dos eventos do Stripe
--
-- O Stripe pode entregar o mesmo evento mais de uma vez. A chave primária
-- abaixo transforma o event.id no token de idempotência. A função RPC insere
-- esse token antes do efeito e executa ambos na mesma transação: qualquer erro
-- posterior também desfaz o INSERT, deixando o evento apto para um novo retry.

CREATE TABLE stripe_webhook_events (
  event_id TEXT PRIMARY KEY,
  received_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE stripe_webhook_events ENABLE ROW LEVEL SECURITY;

-- Sem policies, a RLS nega toda leitura e escrita a anon/authenticated. Os
-- REVOKEs também removem privilégios concedidos pelos defaults da Data API.
REVOKE ALL ON TABLE stripe_webhook_events FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON TABLE stripe_webhook_events TO service_role;

CREATE FUNCTION process_stripe_webhook_event(
  p_event_id TEXT,
  p_event_type TEXT,
  p_payload JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_customer_id TEXT;
  v_plan public.subscription_plan;
  v_status public.subscription_status;
  v_subscription_id TEXT;
  v_updated INTEGER := 0;
  v_user_id UUID;
BEGIN
  -- Deve ser a primeira escrita. Em duplicatas, a PK gera unique_violation;
  -- a Edge Function converte somente esse caso em 200 sem repetir o efeito.
  INSERT INTO public.stripe_webhook_events (event_id) VALUES (p_event_id);

  CASE p_event_type
    WHEN 'checkout.session.completed' THEN
      IF NULLIF(p_payload->>'user_id', '') IS NULL
         OR NULLIF(p_payload->>'subscription_id', '') IS NULL THEN
        RETURN jsonb_build_object(
          'updated_rows', 0,
          'warning', 'checkout.session.completed sem user_id ou subscription'
        );
      END IF;

      v_status := (p_payload->>'status')::public.subscription_status;
      v_plan := (p_payload->>'plano')::public.subscription_plan;

      UPDATE public.subscriptions
         SET stripe_customer_id = p_payload->>'customer_id',
             stripe_subscription_id = p_payload->>'subscription_id',
             plano = v_plan,
             status = v_status,
             trial_start = (p_payload->>'trial_start')::TIMESTAMPTZ,
             trial_end = (p_payload->>'trial_end')::TIMESTAMPTZ,
             current_period_start = (p_payload->>'current_period_start')::TIMESTAMPTZ,
             current_period_end = (p_payload->>'current_period_end')::TIMESTAMPTZ
       WHERE user_id = (p_payload->>'user_id')::UUID;

      GET DIAGNOSTICS v_updated = ROW_COUNT;
      IF v_updated > 0 AND v_status IN ('active', 'trialing') THEN
        PERFORM public.unlock_available_plans((p_payload->>'user_id')::UUID);
      END IF;

    WHEN 'invoice.paid' THEN
      v_customer_id := p_payload->>'customer_id';
      v_subscription_id := NULLIF(p_payload->>'subscription_id', '');

      BEGIN
        SELECT s.user_id
          INTO STRICT v_user_id
          FROM public.subscriptions AS s
         WHERE s.stripe_customer_id = v_customer_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN jsonb_build_object(
            'updated_rows', 0,
            'warning', 'invoice.paid para customer sem assinatura no banco'
          );
      END;

      IF NULLIF(p_payload->>'payment_intent_id', '') IS NOT NULL THEN
        INSERT INTO public.payment_history (
          user_id,
          stripe_payment_intent_id,
          amount_cents,
          currency,
          status,
          paid_at
        )
        VALUES (
          v_user_id,
          p_payload->>'payment_intent_id',
          (p_payload->>'amount_cents')::INTEGER,
          p_payload->>'currency',
          'succeeded',
          (p_payload->>'paid_at')::TIMESTAMPTZ
        )
        ON CONFLICT (stripe_payment_intent_id) DO UPDATE
          SET user_id = EXCLUDED.user_id,
              amount_cents = EXCLUDED.amount_cents,
              currency = EXCLUDED.currency,
              status = EXCLUDED.status,
              paid_at = EXCLUDED.paid_at;
      END IF;

      UPDATE public.subscriptions AS s
         SET current_period_start = (p_payload->>'current_period_start')::TIMESTAMPTZ,
             current_period_end = (p_payload->>'current_period_end')::TIMESTAMPTZ,
             plano = 'premium',
             status = 'active'
       WHERE s.stripe_customer_id = v_customer_id
         AND (
           v_subscription_id IS NULL
           OR s.stripe_subscription_id IS NULL
           OR s.stripe_subscription_id = v_subscription_id
         );

      GET DIAGNOSTICS v_updated = ROW_COUNT;
      IF v_updated > 0 THEN
        PERFORM public.unlock_available_plans(v_user_id);
      END IF;

    WHEN 'invoice.payment_failed' THEN
      v_customer_id := p_payload->>'customer_id';
      v_subscription_id := NULLIF(p_payload->>'subscription_id', '');

      UPDATE public.subscriptions AS s
         SET status = 'past_due'
       WHERE s.stripe_customer_id = v_customer_id
         AND (
           v_subscription_id IS NULL
           OR s.stripe_subscription_id IS NULL
           OR s.stripe_subscription_id = v_subscription_id
         );

      GET DIAGNOSTICS v_updated = ROW_COUNT;

    WHEN 'customer.subscription.updated' THEN
      v_customer_id := p_payload->>'customer_id';
      v_subscription_id := p_payload->>'subscription_id';

      UPDATE public.subscriptions AS s
         SET status = (p_payload->>'status')::public.subscription_status,
             plano = (p_payload->>'plano')::public.subscription_plan,
             current_period_start = (p_payload->>'current_period_start')::TIMESTAMPTZ,
             current_period_end = (p_payload->>'current_period_end')::TIMESTAMPTZ,
             trial_start = (p_payload->>'trial_start')::TIMESTAMPTZ,
             trial_end = (p_payload->>'trial_end')::TIMESTAMPTZ
       WHERE s.stripe_customer_id = v_customer_id
         AND (
           s.stripe_subscription_id IS NULL
           OR s.stripe_subscription_id = v_subscription_id
         );

      GET DIAGNOSTICS v_updated = ROW_COUNT;

    WHEN 'customer.subscription.deleted' THEN
      v_customer_id := p_payload->>'customer_id';
      v_subscription_id := p_payload->>'subscription_id';

      UPDATE public.subscriptions AS s
         SET status = 'canceled',
             plano = 'free'
       WHERE s.stripe_customer_id = v_customer_id
         AND (
           s.stripe_subscription_id IS NULL
           OR s.stripe_subscription_id = v_subscription_id
         );

      GET DIAGNOSTICS v_updated = ROW_COUNT;

    ELSE
      -- Eventos sem efeito conhecido também são considerados recebidos.
      v_updated := 0;
  END CASE;

  RETURN jsonb_build_object(
    'updated_rows', v_updated,
    'warning', CASE
      WHEN v_updated = 0 AND p_event_type IN (
        'checkout.session.completed',
        'invoice.paid',
        'invoice.payment_failed',
        'customer.subscription.updated',
        'customer.subscription.deleted'
      ) THEN format('[%s] nenhuma assinatura correspondente', p_event_type)
      ELSE NULL
    END
  );
END;
$$;

REVOKE ALL ON FUNCTION process_stripe_webhook_event(TEXT, TEXT, JSONB)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION process_stripe_webhook_event(TEXT, TEXT, JSONB)
  TO service_role;
