-- ============================================================
-- migration-23: "Como responder" por pergunta
--
-- Cada pergunta inicial e de triagem tem a própria orientação (texto e/ou
-- link do YouTube), mostrada no mesmo sheet do "Como responder" global das
-- atividades (migration-19). Mesmos limites daquela tabela.
-- As policies de questions já cobrem as colunas novas: leitura para
-- autenticados, escrita só para admin.
-- ============================================================

ALTER TABLE questions
  ADD COLUMN como_responder_texto TEXT
    CHECK (char_length(como_responder_texto) <= 5000),
  ADD COLUMN como_responder_video_url TEXT
    CHECK (char_length(como_responder_video_url) <= 500);

COMMENT ON COLUMN questions.como_responder_texto IS
  'Orientação "Como responder" desta pergunta (texto).';
COMMENT ON COLUMN questions.como_responder_video_url IS
  'Orientação "Como responder" desta pergunta (link do YouTube).';
