-- migration-04: foto de perfil da criança (upload no bucket avatars,
-- pasta do responsável — mesma policy de dono já existente no baseline).

ALTER TABLE children ADD COLUMN avatar_url TEXT;
