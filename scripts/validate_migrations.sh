#!/usr/bin/env bash
# Aplica todas as migrations em um Postgres descartável e confere o resultado.
#
# Por que não `supabase db reset`: o CLI sobe a stack inteira em portas fixas
# (54321-54324) e a máquina de desenvolvimento costuma ter outro projeto
# ocupando essas portas. Aqui sobe só um Postgres em porta aleatória, com um
# prelúdio que recria o mínimo que o Supabase fornece (auth.users, auth.uid(),
# storage.*, roles). É o suficiente para validar DDL, RLS, funções e os seeds.
#
# Uso:  bash scripts/validate_migrations.sh            # banco do zero
#       bash scripts/validate_migrations.sh upgrade    # banco já em uso
#
# No modo `upgrade` as migrations até a 08 são aplicadas, o banco recebe uma
# carga que simula produção (scripts/seed_banco_existente.sql) e só então
# entram a 09 e a 10 — é o cenário em que a 09 troca FKs de tabelas com dados.
#
# Requer: docker.

set -euo pipefail

MODO="${1:-zero}"
CORTE="20260819130000_migration-09_integridade_multi_tenant.sql"

CONTAINER="avance-kids-migration-check-$$"
IMAGE="postgres:17-alpine"
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

limpar() { docker rm -f "$CONTAINER" >/dev/null 2>&1 || true; }
trap limpar EXIT

echo "==> subindo $IMAGE"
docker run -d --name "$CONTAINER" -e POSTGRES_PASSWORD=postgres "$IMAGE" >/dev/null

for _ in $(seq 1 60); do
  if docker exec "$CONTAINER" pg_isready -U postgres >/dev/null 2>&1; then break; fi
  sleep 1
done
docker exec "$CONTAINER" pg_isready -U postgres >/dev/null

psql_exec() { docker exec -i "$CONTAINER" psql -v ON_ERROR_STOP=1 -q -U postgres -d postgres; }

echo "==> prelúdio (stubs do que o Supabase fornece)"
psql_exec <<'SQL'
CREATE ROLE anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE service_role NOLOGIN;

CREATE SCHEMA auth;
CREATE TABLE auth.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT,
  raw_user_meta_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- No Supabase real vem do JWT. Aqui é uma variável de sessão, o que permite
-- testar as policies trocando o "usuário logado".
CREATE FUNCTION auth.uid() RETURNS UUID
LANGUAGE sql STABLE AS $$
  SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;

CREATE SCHEMA storage;
CREATE TABLE storage.buckets (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  public BOOLEAN NOT NULL DEFAULT false
);
CREATE TABLE storage.objects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id TEXT REFERENCES storage.buckets(id),
  name TEXT NOT NULL,
  owner UUID
);
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

CREATE FUNCTION storage.foldername(name TEXT) RETURNS TEXT[]
LANGUAGE sql IMMUTABLE AS $$
  SELECT string_to_array(name, '/');
$$;

-- O Supabase concede acesso aos roles da Data API por default privileges. Sem
-- isto, `SET ROLE authenticated` esbarraria em "permission denied" e os testes
-- de RLS não testariam RLS coisa nenhuma. Precisa vir ANTES das migrations
-- para que os REVOKE delas (migration-06/07) tenham o que revogar.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON TABLES TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA public, auth, storage TO anon, authenticated, service_role;
SQL

echo "==> aplicando migrations (modo: $MODO)"
for arquivo in "$RAIZ"/supabase/migrations/*.sql; do
  base="$(basename "$arquivo")"
  if [ "$MODO" = "upgrade" ] && [ "$base" = "$CORTE" ]; then
    echo "    -- carga de banco em uso, antes da 09 --"
    psql_exec < "$RAIZ/scripts/seed_banco_existente.sql"
  fi
  printf '    %s ... ' "$base"
  psql_exec < "$arquivo"
  echo "ok"
done

if [ "$MODO" = "upgrade" ]; then
  echo "==> conferindo que os dados anteriores sobreviveram"
  psql_exec <<'SQL'
DO $$
DECLARE v_int INTEGER;
BEGIN
  SELECT count(*) INTO v_int FROM exercise_attempts
   WHERE session_id = '9e9e9e9e-0000-0000-0000-00000000b001';
  IF v_int <> 10 THEN RAISE EXCEPTION 'tentativas anteriores sumiram (achei %)', v_int; END IF;

  SELECT count(*) INTO v_int FROM exercise_sessions
   WHERE plan_id = '9e9e9e9e-0000-0000-0000-00000000a001';
  IF v_int <> 1 THEN RAISE EXCEPTION 'sessão anterior sumiu'; END IF;

  SELECT count(*) INTO v_int FROM activity_plans
   WHERE child_id = '9e9e9e9e-0000-0000-0000-00000000c001';
  IF v_int <> 2 THEN RAISE EXCEPTION 'planos anteriores sumiram (achei %)', v_int; END IF;

  -- As FKs novas passam a valer para os dados que já estavam lá.
  BEGIN
    INSERT INTO exercise_attempts (session_id, plan_id, child_id, repeticao_numero, resultado)
    VALUES ('9e9e9e9e-0000-0000-0000-00000000b001', '9e9e9e9e-0000-0000-0000-00000000a002',
            '9e9e9e9e-0000-0000-0000-00000000c001', 1, 'sem_ajuda');
    RAISE EXCEPTION 'FK composta não pegou em linha pré-existente';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;

  RAISE NOTICE 'upgrade: dados anteriores intactos e constraints ativas';
END $$;
SQL
fi

echo "==> conferências"
psql_exec <<'SQL'
DO $$
DECLARE
  v_int INTEGER;
BEGIN
  -- migration-06: catálogo e log de aceite
  SELECT count(*) INTO v_int FROM terms_documents WHERE vigente;
  IF v_int <> 1 THEN RAISE EXCEPTION 'terms_documents vigentes: esperava 1, achei %', v_int; END IF;

  SELECT count(*) INTO v_int FROM pg_policies
   WHERE tablename = 'terms_acceptances' AND cmd IN ('INSERT','UPDATE','DELETE');
  IF v_int <> 0 THEN
    RAISE EXCEPTION 'terms_acceptances não pode ter policy de escrita (achei %)', v_int;
  END IF;

  -- migration-07: retenção do histórico financeiro
  SELECT count(*) INTO v_int
    FROM information_schema.columns
   WHERE table_name = 'payment_history' AND column_name = 'user_id' AND is_nullable = 'YES';
  IF v_int <> 1 THEN RAISE EXCEPTION 'payment_history.user_id deveria ser nullable'; END IF;

  SELECT count(*) INTO v_int
    FROM pg_constraint
   WHERE conname = 'payment_history_user_id_fkey' AND confdeltype = 'n';  -- 'n' = SET NULL
  IF v_int <> 1 THEN RAISE EXCEPTION 'payment_history_user_id_fkey deveria ser ON DELETE SET NULL'; END IF;

  -- migration-08: conteúdo oficial
  SELECT count(*) INTO v_int FROM exercises WHERE status = 'ativo';
  IF v_int <> 378 THEN RAISE EXCEPTION 'exercises ativos: esperava 378, achei %', v_int; END IF;

  SELECT count(*) INTO v_int FROM exercises WHERE codigo ~ '^F0[1-6]A-';
  IF v_int <> 0 THEN
    RAISE EXCEPTION 'placeholders deveriam ter sido removidos (sem plano referenciando): achei %', v_int;
  END IF;

  SELECT count(DISTINCT codigo) INTO v_int FROM exercises WHERE status = 'ativo';
  IF v_int <> 126 THEN RAISE EXCEPTION 'códigos oficiais: esperava 126, achei %', v_int; END IF;

  -- migration-10: os 24 códigos AT existem, mas fora de `exercises`.
  SELECT count(*) INTO v_int FROM exercises WHERE codigo ~ '^F0[1-6]AT\d{3}$';
  IF v_int <> 0 THEN RAISE EXCEPTION 'códigos AT não podem estar em exercises (achei %)', v_int; END IF;

  SELECT count(*) INTO v_int FROM screening_programs;
  IF v_int <> 72 THEN RAISE EXCEPTION 'screening_programs: esperava 72 linhas, achei %', v_int; END IF;

  SELECT count(DISTINCT codigo) INTO v_int FROM screening_programs;
  IF v_int <> 24 THEN RAISE EXCEPTION 'screening_programs: esperava 24 códigos, achei %', v_int; END IF;

  SELECT count(*) INTO v_int FROM (
    SELECT codigo FROM screening_programs GROUP BY codigo HAVING count(DISTINCT nivel) <> 3
  ) q;
  IF v_int <> 0 THEN RAISE EXCEPTION '% códigos AT sem os 3 níveis', v_int; END IF;

  -- Total do material oficial: 450 registros / 150 códigos (378+72 e 126+24).
  SELECT (SELECT count(*) FROM exercises WHERE status = 'ativo')
       + (SELECT count(*) FROM screening_programs) INTO v_int;
  IF v_int <> 450 THEN RAISE EXCEPTION 'total oficial: esperava 450 registros, achei %', v_int; END IF;

  SELECT (SELECT count(DISTINCT codigo) FROM exercises WHERE status = 'ativo')
       + (SELECT count(DISTINCT codigo) FROM screening_programs) INTO v_int;
  IF v_int <> 150 THEN RAISE EXCEPTION 'total oficial: esperava 150 códigos, achei %', v_int; END IF;

  -- screening_programs não pode ganhar vínculo com habilidade nem com plano
  -- enquanto a regra de utilização estiver pendente da cliente.
  SELECT count(*) INTO v_int FROM information_schema.columns
   WHERE table_name = 'screening_programs' AND column_name IN ('skill_id', 'plano');
  IF v_int <> 0 THEN
    RAISE EXCEPTION 'screening_programs não pode ter skill_id/plano antes da definição da cliente';
  END IF;

  -- migration-09: a cadeia plano→sessão→tentativa é fechada por FK composta.
  SELECT count(*) INTO v_int FROM pg_constraint
   WHERE conname IN ('exercise_sessions_plan_child_fkey', 'exercise_attempts_session_plan_child_fkey')
     AND contype = 'f' AND cardinality(conkey) >= 2;
  IF v_int <> 2 THEN RAISE EXCEPTION 'FKs compostas de migration-09 ausentes (achei %)', v_int; END IF;

  -- Cada código oficial tem exatamente 3 níveis.
  SELECT count(*) INTO v_int FROM (
    SELECT codigo FROM exercises WHERE status = 'ativo'
    GROUP BY codigo HAVING count(DISTINCT nivel) <> 3
  ) q;
  IF v_int <> 0 THEN RAISE EXCEPTION '% códigos oficiais sem os 3 níveis', v_int; END IF;

  -- `ordem` igual nos três níveis do mesmo código: é o que mantém a travessia
  -- A -> G -> M do mesmo código em check_exercise_completion.
  SELECT count(*) INTO v_int FROM (
    SELECT codigo FROM exercises WHERE status = 'ativo'
    GROUP BY codigo HAVING count(DISTINCT ordem) <> 1
  ) q;
  IF v_int <> 0 THEN RAISE EXCEPTION '% códigos com ordem divergente entre níveis', v_int; END IF;

  -- Nenhuma atividade oficial entrou como premium por engano.
  SELECT count(*) INTO v_int FROM exercises WHERE status = 'ativo' AND plano <> 'free';
  IF v_int <> 0 THEN RAISE EXCEPTION '% atividades oficiais marcadas como premium', v_int; END IF;

  -- Faixas etárias seguem exatamente como estavam (nenhuma decisão sobre 61-71).
  SELECT count(*) INTO v_int FROM age_brackets
   WHERE (codigo, meses_min, meses_max) IN (
     ('F01A',12,24),('F02A',25,36),('F03A',37,48),('F04A',49,60),('F05A',72,96),('F06A',108,144)
   );
  IF v_int <> 6 THEN RAISE EXCEPTION 'age_brackets foram alteradas (esperava as 6 originais, achei %)', v_int; END IF;

  RAISE NOTICE 'todas as conferências passaram';
END $$;
SQL

echo "==> testes de aceite e exclusão"
psql_exec < "$RAIZ/scripts/test_termos_exclusao.sql"

echo "==> testes de isolamento entre contas (multi-tenant)"
psql_exec < "$RAIZ/scripts/test_multi_tenant.sql"

# Não depende do Postgres, mas fecha o par com os cenários SQL do gate: o banco
# diz o que existe, este diz o que o app decide em cima disso.
echo "==> cenários do gate de reaceite dos termos"
bash "$RAIZ/scripts/test_terms_gate.sh"

echo "==> OK"
