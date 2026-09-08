-- ============================================================
-- Programas Básicos de Engajamento (AT) como brincadeiras gratuitas
--
-- Decisão da cliente em 07/09/2026:
--   * os 24 códigos AT aparecem em "Brincadeiras educativas";
--   * todos são gratuitos;
--   * não entram no plano individual da criança.
--
-- Há três níveis em screening_programs. Para não repetir o mesmo programa em
-- 72 cards, a apresentação pública usa a versão de Aquisição de cada código.
-- ============================================================

ALTER TABLE plays
  ADD COLUMN IF NOT EXISTS codigo TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS uq_plays_codigo
  ON plays (codigo)
  WHERE codigo IS NOT NULL;

COMMENT ON COLUMN plays.codigo IS
  'Código oficial de origem quando a brincadeira vem dos Programas Básicos de Engajamento (AT).';

-- Remove do feed somente as quatro brincadeiras genéricas criadas pelo seed do
-- MVP. Conteúdos cadastrados pela equipe no backoffice não são afetados.
UPDATE plays
SET status = 'arquivado'
WHERE codigo IS NULL
  AND titulo IN (
    'Caça ao tesouro sensorial',
    'Quem imita primeiro?',
    'Circuito de almofadas',
    'Panela vira tambor'
  );

INSERT INTO plays (
  codigo,
  titulo,
  descricao,
  instrucoes,
  media_type,
  media_url,
  plano,
  status
)
SELECT
  sp.codigo,
  sp.titulo,
  sp.objetivo,
  concat_ws(
    E'\n\n',
    CASE WHEN sp.procedimento IS NOT NULL THEN 'Como fazer' || E'\n' || sp.procedimento END,
    CASE WHEN sp.materiais IS NOT NULL THEN 'Materiais' || E'\n' || sp.materiais END,
    CASE WHEN sp.brincadeiras IS NOT NULL THEN 'Brincadeiras sugeridas' || E'\n' || sp.brincadeiras END,
    CASE WHEN sp.frequencia IS NOT NULL THEN 'Frequência' || E'\n' || sp.frequencia END
  ),
  'imagem'::media_type,
  NULL,
  'free'::subscription_plan,
  'ativo'::record_status
FROM screening_programs sp
WHERE sp.nivel = 'aquisicao'
  AND sp.status = 'ativo'
ON CONFLICT (codigo) WHERE codigo IS NOT NULL DO UPDATE
SET
  titulo = EXCLUDED.titulo,
  descricao = EXCLUDED.descricao,
  instrucoes = EXCLUDED.instrucoes,
  plano = 'free',
  status = 'ativo';

-- Mantém o contrato do feed e inclui o código para ordenação F01AT001..F06AT004.
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
  media_type,
  codigo
FROM plays
WHERE status = 'ativo';

COMMENT ON VIEW plays_feed IS
  'Listagem de brincadeiras; os programas AT aparecem gratuitamente e ordenáveis pelo código oficial.';

REVOKE ALL ON plays_feed FROM PUBLIC, anon;
GRANT SELECT ON plays_feed TO authenticated;

DO $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT count(*) INTO v_total
  FROM plays
  WHERE codigo ~ '^F(0[1-6])AT00[1-4]$'
    AND plano = 'free'
    AND status = 'ativo';

  IF v_total <> 24 THEN
    RAISE EXCEPTION 'esperava 24 programas AT gratuitos em plays, encontrei %', v_total;
  END IF;
END $$;
