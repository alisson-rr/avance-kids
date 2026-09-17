-- ============================================================
-- migration-19: ajuda global "Como responder"
--
-- Um único conteúdo (texto e/ou link do YouTube) mostrado no sheet de
-- repetição de todas as atividades. Não é personalizado por atividade.
-- A tabela tem exatamente uma linha: a PK booleana só aceita `true`.
-- ============================================================

CREATE TABLE how_to_answer (
  id BOOLEAN PRIMARY KEY DEFAULT true CHECK (id),
  texto TEXT CHECK (char_length(texto) <= 5000),
  video_url TEXT CHECK (char_length(video_url) <= 500),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO how_to_answer (id) VALUES (true);

CREATE TRIGGER trg_how_to_answer_updated_at
  BEFORE UPDATE ON how_to_answer
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE how_to_answer ENABLE ROW LEVEL SECURITY;

-- Sem policy de INSERT/DELETE: a linha é criada aqui e só é editada.
CREATE POLICY "Authenticated read how to answer"
  ON how_to_answer FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins update how to answer"
  ON how_to_answer FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

COMMENT ON TABLE how_to_answer IS
  'Ajuda global "Como responder" (texto e link do YouTube) exibida no sheet de repetição das atividades.';
