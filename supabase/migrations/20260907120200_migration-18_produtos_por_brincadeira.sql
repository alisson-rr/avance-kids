-- ============================================================
-- Produtos recomendados por brincadeira
--
-- Cada produto é opcional. O aplicativo omite o carrossel quando uma
-- brincadeira não tem recomendações ativas.
-- ============================================================

CREATE TABLE play_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  play_id UUID NOT NULL REFERENCES plays(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL CHECK (length(btrim(titulo)) > 0),
  descricao TEXT NOT NULL CHECK (length(btrim(descricao)) > 0),
  imagem_url TEXT NOT NULL CHECK (length(btrim(imagem_url)) > 0),
  link_url TEXT NOT NULL CHECK (
    lower(link_url) ~ '^https://([a-z0-9-]+\.)*shopee\.com\.br(/|$)'
  ),
  ordem INTEGER NOT NULL DEFAULT 1 CHECK (ordem > 0),
  status record_status NOT NULL DEFAULT 'ativo',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_play_products_play_order
  ON play_products (play_id, ordem, created_at);

CREATE TRIGGER trg_play_products_updated_at
  BEFORE UPDATE ON play_products
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE play_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated read available play products"
  ON play_products FOR SELECT
  TO authenticated
  USING (
    status = 'ativo'
    AND EXISTS (
      SELECT 1
      FROM plays p
      WHERE p.id = play_products.play_id
        AND p.status = 'ativo'
        AND (p.plano = 'free' OR has_premium_access())
    )
  );

CREATE POLICY "Admins manage play products"
  ON play_products FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

COMMENT ON TABLE play_products IS
  'Cards opcionais de produtos da Shopee exibidos dentro de cada brincadeira.';
