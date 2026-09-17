-- migration-21: remove as cópias criadas pela migration-20. O banco é de
-- homologação e não precisa delas.
DROP SCHEMA IF EXISTS backup CASCADE;
