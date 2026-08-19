-- ============================================================
-- migration-06: trilha de auditoria do aceite dos termos
--
-- Antes desta migration a única prova de consentimento era
-- `profiles.termos_aceitos BOOLEAN`, preenchida por handle_new_user a partir
-- de `raw_user_meta_data->>'termos_aceitos'` (migration-02:25) — ou seja, um
-- valor que o próprio client escolhe no signup. Não havia versão do documento,
-- data do aceite, IP nem identificação de qual texto foi aceito, então o
-- booleano não sustenta uma alegação de consentimento sob a LGPD.
--
-- Estratégia:
--   * terms_documents   -> catálogo versionado dos documentos (fonte da
--                          verdade do servidor sobre "qual versão está
--                          vigente"). O client nunca escolhe a versão.
--   * terms_acceptances -> log append-only: um registro por (usuário,
--                          documento), com timestamp, IP e user agent
--                          gravados pela Edge Function `accept-terms`.
--
-- `profiles.termos_aceitos` continua existindo e continua sendo atualizado —
-- vira apenas o flag de UX ("já mostrei o modal?"); a prova é o log.
-- ============================================================

-- ============================================================
-- 1. CATÁLOGO DE DOCUMENTOS
-- ============================================================

CREATE TABLE terms_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo TEXT NOT NULL,                 -- 'termos_e_privacidade', ...
  versao TEXT NOT NULL,               -- data de atualização do documento (ISO)
  titulo TEXT NOT NULL,
  url TEXT,                           -- onde o texto público está publicado
  conteudo_hash TEXT,                 -- sha256 do arquivo exato que foi aceito
  publicado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  vigente BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT uq_terms_documents_tipo_versao UNIQUE (tipo, versao),
  CONSTRAINT ck_terms_documents_tipo CHECK (tipo ~ '^[a-z0-9_]+$'),
  CONSTRAINT ck_terms_documents_versao CHECK (length(btrim(versao)) > 0)
);

-- Só uma versão vigente por tipo: é ela que a Edge Function registra.
CREATE UNIQUE INDEX uq_terms_documents_vigente
  ON terms_documents (tipo) WHERE vigente;

COMMENT ON TABLE terms_documents IS
  'Documentos legais versionados. O servidor decide qual versão está vigente; o app apenas exibe.';

-- ============================================================
-- 2. LOG DE ACEITE (append-only)
-- ============================================================

CREATE TABLE terms_acceptances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  document_id UUID NOT NULL REFERENCES terms_documents(id),
  -- Desnormalizado de propósito: se o documento for corrigido ou o catálogo
  -- reorganizado, o registro continua dizendo o que foi aceito.
  tipo TEXT NOT NULL,
  versao TEXT NOT NULL,
  conteudo_hash TEXT,
  aceito_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  ip INET,
  user_agent TEXT,
  origem TEXT NOT NULL DEFAULT 'app',

  -- Idempotência: reenviar o aceite da mesma versão não duplica o registro
  -- nem reescreve o timestamp original.
  CONSTRAINT uq_terms_acceptances_user_doc UNIQUE (user_id, document_id)
);

CREATE INDEX idx_terms_acceptances_user ON terms_acceptances (user_id, aceito_em DESC);

COMMENT ON TABLE terms_acceptances IS
  'Prova de consentimento: quem, qual documento, qual versão, quando e de qual IP. Append-only.';
COMMENT ON COLUMN terms_acceptances.ip IS
  'IP de origem resolvido server-side (x-forwarded-for na Edge Function). NULL quando o proxy não informa.';

-- ============================================================
-- 3. RLS
-- ============================================================

ALTER TABLE terms_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE terms_acceptances ENABLE ROW LEVEL SECURITY;

-- O app precisa ler o documento vigente para exibi-lo antes do aceite —
-- inclusive no cadastro, quando ainda não há sessão.
CREATE POLICY "Anyone can read current terms"
  ON terms_documents FOR SELECT
  TO anon, authenticated
  USING (vigente);

CREATE POLICY "Admins manage terms documents"
  ON terms_documents FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Leitura do próprio aceite (a tela de perfil mostra o que foi aceito e quando).
CREATE POLICY "Users read own acceptances"
  ON terms_acceptances FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Admins read all acceptances"
  ON terms_acceptances FOR SELECT
  TO authenticated
  USING (is_admin());

-- Sem policy de INSERT/UPDATE/DELETE de propósito: gravar é exclusividade da
-- Edge Function `accept-terms` (service_role), que é quem resolve versão e IP.
-- Um INSERT vindo do client poderia forjar versão, data e IP — exatamente o
-- problema que esta migration existe para resolver.
REVOKE INSERT, UPDATE, DELETE ON terms_acceptances FROM authenticated, anon;

-- ============================================================
-- 4. SEED DO DOCUMENTO ATUAL
--
-- Origem: AvanceKids-DOCUMENTACAO/Termos_e_Privacidade_Avance_Kids_Final.pdf
-- Título e data extraídos do próprio arquivo:
--   "TERMOS DE USO E POLÍTICA DE PRIVACIDADE — AVANCE KIDS"
--   "Data de Atualização: 17 de agosto de 2026"
-- `conteudo_hash` é o sha256 desse PDF. `url` fica NULL até o documento ser
-- publicado em um endereço público (preencher no deploy).
-- ============================================================

INSERT INTO terms_documents (tipo, versao, titulo, url, conteudo_hash, publicado_em, vigente)
VALUES (
  'termos_e_privacidade',
  '2026-08-17',
  'Termos de Uso e Política de Privacidade — Avance Kids',
  NULL,
  '2952dfd40ce41e50e05274749035e52564f70e357f523f0b21ef80235c3a484e',
  '2026-08-17T00:00:00Z',
  true
)
ON CONFLICT (tipo, versao) DO NOTHING;

-- ============================================================
-- 5. COMPATIBILIDADE COM O QUE JÁ EXISTE
-- ============================================================

COMMENT ON COLUMN profiles.termos_aceitos IS
  'Flag de UX (já aceitou a versão vigente?). NÃO é prova de consentimento — a prova está em terms_acceptances.';

-- Contas criadas antes desta migration marcaram termos_aceitos = true sem
-- registro auditável. Elas ficam sem linha em terms_acceptances de propósito:
-- inventar um timestamp e um IP para um aceite que não foi registrado seria
-- fabricar a prova que esta tabela existe para guardar. A Edge Function grava
-- o registro real no próximo aceite (o app pede o aceite de novo quando não há
-- linha para a versão vigente).
