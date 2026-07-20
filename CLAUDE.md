## Migrations (Supabase)

- Toda migration nova é incremental e numerada em sequência: `<timestamp>_migration-NN_descricao.sql` (ex.: `20260719120000_migration-02_add_campo_x.sql`). O baseline `20260718000000_baseline.sql` conta como migration-01.
- O prefixo timestamp `YYYYMMDDHHMMSS` é obrigatório (ordem de aplicação do Supabase CLI); o `migration-NN` dá a leitura sequencial.
- Nunca editar uma migration já aplicada — sempre criar a próxima `migration-NN`.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
