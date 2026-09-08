-- migration-13: bucket de avatares privado
--
-- `media` guarda conteúdo de catálogo e continua público. `avatars` contém
-- fotos pessoais e só pode ser acessado pelo usuário autenticado dono da
-- primeira pasta do objeto (`{auth.uid()}/...`).
--
-- Se o projeto hospedado restringir DDL em storage.objects, reproduzir as
-- policies abaixo no Dashboard (Storage > Policies). A alteração do bucket e
-- a DDL ficam em blocos separados para que uma restrição nas policies não
-- reverta a tentativa de tornar o bucket privado.

DO $$
BEGIN
  INSERT INTO storage.buckets (id, name, public)
  VALUES ('avatars', 'avatars', false)
  ON CONFLICT (id) DO UPDATE SET public = false;
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'Sem privilégio para tornar avatars privado via migration — alterar o bucket pelo Dashboard.';
END $$;

DO $$
BEGIN
  -- A policy antiga incluía `avatars` e anulava a privacidade do bucket para
  -- downloads autenticados. O catálogo público passa a ter policy exclusiva.
  DROP POLICY IF EXISTS "Public read app buckets" ON storage.objects;
  DROP POLICY IF EXISTS "Public read media bucket" ON storage.objects;
  CREATE POLICY "Public read media bucket"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'media');

  DROP POLICY IF EXISTS "Users manage own avatar folder" ON storage.objects;
  CREATE POLICY "Users manage own avatar folder"
    ON storage.objects FOR ALL
    TO authenticated
    USING (
      bucket_id = 'avatars'
      AND (storage.foldername(name))[1] = auth.uid()::text
    )
    WITH CHECK (
      bucket_id = 'avatars'
      AND (storage.foldername(name))[1] = auth.uid()::text
    );
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'Sem privilégio para configurar policies de Storage via migration — criar pelo Dashboard.';
END $$;
