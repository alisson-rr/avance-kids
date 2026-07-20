# Plano de Implementação do Backend — Avance Kids

> Gerado em 2026-07-18 a partir da análise do Graphify + leitura do schema legado
> (`supabase/migrations/20260716000000_foundation.sql`), das 8 Edge Functions existentes
> e do contrato de dados que o frontend novo (mobile + backoffice) espera.

---

## 1. Estado atual

### O que existe
| Camada | Situação |
|---|---|
| **Mobile** (`apps/mobile`, Expo RN) | Telas completas, mas 100% mockadas (`useProfileStore` com dados fixos, `MOCK_PERGUNTAS`, sem `@supabase/supabase-js` instalado). |
| **Backoffice** (`apps/backoffice`, React/Vite) | CRUDs completos de Atividades, Perguntas (Iniciais/Triagem), Brincadeiras, Artigos e Admins — todos operando sobre arrays mock em memória (`EntityCrudScreen` + `useArchivableList`). |
| **Schema SQL** | 1 arquivo "foundation" com 13 blocos de migração concatenados: 17 tabelas, RLS, triggers, seeds e 5 funções PL/pgSQL. **Desatualizado** em relação ao frontend novo. |
| **Edge Functions** | 8 functions Deno + `_shared` (auth, cors, response, schemas Zod): `register-child`, `submit-initial-answers`, `submit-screening-answers`, `generate-activity-plan`, `start-exercise-session`, `register-attempt`, `create-checkout-session`, `handle-stripe-webhook`. Escritas contra o schema legado. |

### Fonte da verdade do novo modelo
O contrato novo está nos tipos do backoffice — `apps/backoffice/src/constants/aba.ts`,
`apps/backoffice/src/types/entities.ts` e `apps/backoffice/src/types/common.ts` — e nas
telas do mobile.

---

## 2. Divergências: schema legado × frontend novo

Estas são as razões pelas quais o SQL precisa ser refeito, não só ajustado:

1. **Perguntas mudaram de forma (maior quebra).**
   - Legado: `initial_questions` sem habilidade/faixa + tabelas de opções por pergunta
     (`initial_question_options`, `screening_question_options`); respostas gravam `option_id`.
   - Novo: `Pergunta` (mesma forma para inicial e triagem) tem `skill`, `age_bracket`,
     `ordem`, `status` e **escala fixa** `ANSWER_SCALE` (0 = Nunca/Não observei, 1 = Às vezes,
     2 = Sempre) — sem opções customizadas por pergunta e sem campo `codigo`.
   - Consequência: as tabelas de opções somem; respostas passam a gravar `valor_numerico`
     diretamente; as functions `submit-*-answers` e as funções de cálculo
     (`calculate_general_age`, `calculate_skill_age`) precisam ser reescritas.
   - Obs. mobile: `PerguntasScreen` exibe 4 alternativas — a 4ª ("Não observei essa situação
     ainda") mapeia para valor 0, mas vale registrar num flag `nao_observado` para não
     contaminar médias no futuro.

2. **Exercises → Atividades (Programa ABA).**
   - Legado: `titulo`, `descricao`, `instrucoes`, `video_url`.
   - Novo (`Atividade` em `constants/aba.ts`): `media_type`+`media_url` (imagem via upload
     **ou** URL de vídeo → exige bucket no Storage) e 12 campos ABA estruturados:
     `objetivo`, `procedimento`, `materiais`, `recursos_extras`, `frequencia`,
     `brincadeiras`, `hierarquia_dicas`, `resposta_esperada`, `procedimento_correcao`,
     `criterio_avanco`, `registro_dados`, `reforcos`.

3. **Arquivamento em vez de boolean `ativo`.**
   - Todo o backoffice usa `RecordStatus = 'ativo' | 'arquivado'` (arquivar preserva
     histórico e permite reativar). Trocar `ativo BOOLEAN` por `status record_status` em
     `exercises`, `plays`, `articles` e perguntas.

4. **`is_premium BOOLEAN` → `plano access_plan ('free'|'premium')`** em `exercises`,
   `plays`, `articles` (o enum `subscription_plan` já existe e pode ser reutilizado).

5. **Skills precisam de slug.** O frontend usa `HabilidadeKey`
   (`comunicacao|social|cognitiva|motora|funcional`) como chave natural; a tabela `skills`
   só tem `nome`. Adicionar coluna `key TEXT UNIQUE`.

6. **Admin com auth caseira.** `admin_users` legado guarda `password_hash` bcrypt próprio.
   Recomendação: usar **Supabase Auth** também para admins — `admin_users(id → auth.users)`
   com `role` e `status` — e uma função `is_admin()` usada nas policies de escrita das
   tabelas de conteúdo. Evita manter fluxo de senha/reset/bcrypt manual e permite que o
   backoffice use o client normal (sem expor service key).

7. **Backoffice não tem caminho de escrita hoje.** No schema legado, conteúdo
   (perguntas, exercises, plays, articles) só tem policy de SELECT — nenhuma policy de
   INSERT/UPDATE para admins. Precisa das policies `is_admin()` (item 6) ou de Edge
   Functions admin dedicadas.

---

## 3. Decisões de design (assumidas — revisar se discordar)

| # | Decisão | Justificativa |
|---|---|---|
| D1 | **Recriar o baseline**: substituir `20260716000000_foundation.sql` por uma nova migração baseline única, em vez de migrações incrementais sobre o legado. | O banco ainda não tem dados de produção; o legado nunca foi consumido por app real (frontends mockados). Migrar incrementalmente só acumularia ruído. |
| D2 | **Tabela única `questions`** com coluna `kind ('inicial'\|'triagem')`, em vez de duas tabelas gêmeas. | O backoffice já trata os dois tipos com o MESMO componente/forma (`QuestionCrudScreen`); evita duplicar policies, índices e CRUD. |
| D3 | **Tabela única `child_question_answers`** gravando `valor_numerico SMALLINT (0-2)` + `nao_observado BOOLEAN`. | Escala é fixa; opções por pergunta deixaram de existir. |
| D4 | Admin via Supabase Auth + `is_admin()` (item 6 acima). | Segurança e simplicidade. |
| D5 | Manter Stripe (checkout + webhook) como está estruturado, só revisando nomes/URLs. | `subscriptions`/`payment_history` já estão adequados. |
| D6 | Media de Atividades/Brincadeiras: bucket público-leitura `media` no Storage (upload só admin); vídeo continua URL externa (YouTube/Vimeo). | Espelha `MediaType` do frontend (`imagem` = upload, `video` = URL). |

---

## 4. Plano de execução

### Fase 1 — Novo schema (migração baseline)
Criar `supabase/migrations/<ts>_baseline_v2.sql` (e apagar a foundation antiga) com:

1. **Enums**: `record_status`, `media_type`, `exercise_level`, `attempt_result`,
   `plan_status`, `subscription_plan`, `subscription_status`, `admin_role`,
   `question_kind ('inicial','triagem')`.
2. **Núcleo mantido (revisado)**: `profiles`, `children`, `child_skill_ages`,
   `activity_plans`, `exercise_sessions`, `exercise_attempts`, `subscriptions`,
   `payment_history`, `age_brackets` — mesmos moldes do legado, que continuam corretos.
3. **Refeitos**:
   - `skills` + coluna `key` (slug) única.
   - `questions` (kind, skill_id, age_bracket_id, texto, ordem, status) — substitui
     `initial_questions` + `screening_questions` + as 2 tabelas de opções.
   - `child_question_answers` (child_id, question_id, valor_numerico 0-2,
     nao_observado, UNIQUE(child_id, question_id)) — substitui
     `child_initial_answers` + `child_screening_answers`.
   - `exercises` com campos ABA (item 2 da seção 2), `media_type`/`media_url`,
     `plano`, `status record_status`.
   - `plays` e `articles` com `plano` + `status record_status`.
   - `admin_users(id UUID PK → auth.users, nome, email, role, status)`.
4. **RLS**:
   - Manter as policies de dono (user vê/gerencia os próprios filhos/respostas/planos).
   - `is_admin()` SECURITY DEFINER (existe linha ativa em `admin_users` para `auth.uid()`).
   - Policies de escrita admin em `skills`, `age_brackets`, `questions`, `exercises`,
     `plays`, `articles`, `admin_users` (esta última só `super_admin` gerencia).
   - Leitura de conteúdo para `authenticated` continua filtrando `status = 'ativo'`;
     admins enxergam tudo (inclusive arquivados).
5. **Funções PL/pgSQL refeitas**:
   - `calculate_biological_age`, `resolve_age_bracket` — manter (revisar gap 61–71 meses).
   - `calculate_general_age`, `calculate_skill_age` — reescrever lendo
     `child_question_answers.valor_numerico` (escala 0–2, `nao_observado` fora da média —
     confirmar regra de negócio).
   - `check_exercise_completion` — revisar (critério ≥8/10 sem ajuda, progressão
     aquisição → generalização → manutenção → próximo exercício).
   - Trigger `handle_new_user` — manter (profile + subscription free automáticos).
6. **Storage**: buckets `media` (conteúdo, escrita admin) e `avatars` (escrita do dono).
7. **Seeds**: `age_brackets` (F01A–F06A) e `skills` com os slugs/cores de
   `constants/aba.ts`.

### Fase 2 — Edge Functions refeitas
Atualizar `_shared/schemas.ts` para o contrato novo e reescrever:

| Function | Mudança |
|---|---|
| `register-child` | Revisar (cálculo de idade biológica no insert). |
| `submit-initial-answers` | Receber `{question_id, valor_numerico, nao_observado}`; recalcular idade geral. |
| `submit-screening-answers` | Idem, por habilidade; gravar `child_skill_ages`. |
| `generate-activity-plan` | Revisar: filtrar exercícios `status='ativo'`, respeitar `plano` free/premium do assinante ao ativar plano. |
| `start-exercise-session` / `register-attempt` | Revisar contra o schema novo + `check_exercise_completion`. |
| `create-checkout-session` / `handle-stripe-webhook` | Manter; revisar env vars e eventos (subscription updated/deleted → downgrade). |
| **Nova**: `admin-*` (se necessário) | Só se alguma operação admin não puder ser feita via RLS direto (ex.: criar admin com convite por e-mail via Auth Admin API). |

Regra de gating premium: usuário `free` só recebe exercícios/brincadeiras/artigos com
`plano='free'`; premium recebe tudo. Aplicar na geração do plano e/ou em views filtradas.

### Fase 3 — Integração dos frontends
1. Gerar tipos: `supabase gen types typescript` → pacote compartilhado (ou copiado por app).
2. **Backoffice**: instalar `@supabase/supabase-js`; login admin via Supabase Auth;
   trocar mocks por uma camada de dados (hooks por entidade sobre o
   `EntityCrudScreen` — CRUDs de Atividades, Perguntas, Brincadeiras, Artigos, Admins;
   Dashboard com contagens reais).
3. **Mobile**: instalar client; auth (e-mail/senha + Google); substituir
   `useProfileStore` mock por dados reais; fluxos: cadastro pai/filho → perguntas
   iniciais → triagem por habilidade → plano de atividades → sessão/tentativas →
   histórico; tela de planos → checkout Stripe.

### Fase 4 — Carga de conteúdo
Seed/import das perguntas e atividades reais (via backoffice ou script SQL de seed),
substituindo os mocks (`MOCK_PERGUNTAS`, `MOCK_ATIVIDADES`).

### Fase 5 — Qualidade e verificação
- Rodar advisors do Supabase (segurança/performance) e revisar RLS de ponta a ponta
  (em especial: nenhum caminho de escrita anônimo, admin não vazando para `authenticated`).
- Testar funções de cálculo com casos extremos (sem respostas, tudo 0, gap de faixa etária).
- Fluxo E2E: registrar usuário → filho → respostas → plano gerado → 10 tentativas →
  desbloqueio do próximo exercício.
- `graphify update .` ao final de cada fase.

---

## 5. Pontos em aberto (confirmar com o time)

1. ~~"Não observei" deve ficar **fora da média** ou contar como 0?~~ **DECIDIDO (2026-07-19): conta como 0** (comportamento já implementado; o flag `nao_observado` preserva o dado bruto caso a regra mude).
2. A fórmula de regressão de idade (`(2 - média) × 12` meses) segue válida com a escala 0–2?
3. Admins entram pelo mesmo projeto Supabase Auth do app (com `is_admin()`), ok?
4. Perguntas iniciais têm mesmo habilidade + faixa (como o backoffice novo define), ou são
   genéricas por faixa apenas? Hoje `entities.ts` exige `skillKey` para ambas.
5. Upload de imagem no backoffice hoje gera data-URL — vai para o bucket `media` na Fase 3.

## 6. Pré-requisitos operacionais

- O conector MCP do **Supabase** (e Vercel/GitHub, se usados) precisa ser autorizado
  pelo usuário nas configurações de conectores do claude.ai ou via `/mcp` numa sessão
  interativa — sem isso não é possível aplicar migrações/deploy de functions por aqui.
  Alternativa: CLI local `supabase` (`supabase db push`, `supabase functions deploy`).
- Env vars das functions: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, price IDs.
