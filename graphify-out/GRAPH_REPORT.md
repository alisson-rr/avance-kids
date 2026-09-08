# Graph Report - AVANCE-Kids  (2026-09-08)

## Corpus Check
- 209 files · ~297,074 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1243 nodes · 2540 edges · 136 communities (60 shown, 59 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 22 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b00d9f5e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- react
- dependencies
- devDependencies
- schemas.ts
- Comunicacao Domain Avatar (girl, yellow dress, waving)
- web
- compilerOptions
- compilerOptions
- mobile/App.tsx
- PerguntasScreen.tsx
- dashboard.ts
- mobile/package.json
- QuestionCrudScreen.tsx
- react
- plugins
- Android Adaptive Icon - Background Layer (construction guide)
- tsconfig.json
- Backoffice Full Logo (Avance Kids wordmark, blue/green mark)
- Cognitiva Domain Avatar (girl, purple shirt with gear icon)
- ActivitiesScreen.tsx
- 1. Bloqueado por decisão da cliente
- manifest.json
- @tiptap/extension-text-align
- import_perguntas.py
- vercel.json
- @expo/vector-icons
- src/App.tsx
- Backoffice HTML Entry Point (index.html)
- tsconfig.json
- Mobile CLAUDE.md (includes AGENTS.md)
- Coordenacao/Motora Domain Avatar (boy, orange shirt, footprint icon)
- theme.ts
- Onboarding Illustration 3 - Kids Playing Outdoors
- metro.config.js
- Funcional Domain Avatar (girl, pink dress, holding card)
- ArticlesScreen.tsx
- Backoffice README (Vite+React+TS Template Docs)
- React Logo Asset
- Avance Kids Root README (placeholder, garbled encoding)
- Onboarding Screenshot 1 - 'Perguntas Iniciais' Initial Screening Question UI
- Social Domain Avatar (boy, green shirt, holding emoji cards)
- expo-font
- P1 — Corrigidos
- Login com Google — configuração final
- Build Android (APK) — Avance Kids
- dependencies
- atividades.ts
- Plano de Implementação do Backend — Avance Kids
- 20260718000000_baseline.sql
- recharts
- import_programas.py
- backoffice/package.json
- Vite Logo Asset (purple recolor, light/dark parenthesis)
- @expo-google-fonts/mulish
- devDependencies
- TriagemScreen.tsx
- ui/index.ts
- habilidades.ts
- terms.ts
- scripts
- @tiptap/extension-image
- @tiptap/pm
- Instruções do projeto
- Deploy da assinatura (Stripe + bloqueio premium)
- expo-image
- Arquitetura padrão para Claude Code
- expo-linear-gradient
- expo-splash-screen
- handoff/SKILL.md
- check_exercise_completion
- react
- react-dom
- react-native
- @expo/metro-runtime
- react-native-screens
- react-native-web
- @react-navigation/native-stack
- checkout-return/index.ts
- zustand
- api-conventions.md
- code-style.md
- database.md
- security.md
- expo-web-browser
- testing.md
- typescript.md
- Android Adaptive Icon - Monochrome Layer (gray 'A' chevron mark)
- Mobile Splash Icon (gray 'A' chevron mark)
- db.ts
- test_terms_gate.sh script
- @react-native-async-storage/async-storage
- useProfileStore.ts
- 20260907120200_migration-18_produtos_por_brincadeira.sql
- mobile/vercel.json
- entities.ts
- validate_migrations.sh
- plays_feed
- terms_acceptances
- 20260819120100_migration-07_exclusao_de_conta.sql
- Exception
- Path
- expo-crypto
- react-native-svg
- @react-navigation/native
- PlansScreen.tsx
- 2. Remediação aplicada
- Dependências e pendências
- HomeScreen.tsx
- react-dom
- QA em Android real
- 4. Riscos levantados (com status)
- test_logica_cliente.sql
- Issue tracker: Linear
- Contexto — Avance Kids
- Docs de domínio
- DEPENDENCIAS-E-PENDENCIAS.md
- 3. Propagação para o remoto — executada
- 5. Aberto desde a integração
- 20260902120000_migration-14_webhook_idempotente.sql

## God Nodes (most connected - your core abstractions)
1. `react` - 62 edges
2. `theme` - 36 edges
3. `errorMessage()` - 34 edges
4. `useProfileStore` - 34 edges
5. `showError()` - 32 edges
6. `showDialog()` - 26 edges
7. `compilerOptions` - 18 edges
8. `web` - 15 edges
9. `RecordStatus` - 15 edges
10. `ParentRegisterScreen()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Graphify Knowledge Graph Rules (root CLAUDE.md)` --conceptually_related_to--> `Mobile CLAUDE.md (includes AGENTS.md)`  [INFERRED]
  CLAUDE.md → apps/mobile/CLAUDE.md
- `QuestionRow` --references--> `RecordStatus`  [EXTRACTED]
  apps/backoffice/src/services/perguntas.ts → apps/backoffice/src/types/common.ts
- `HomeScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/HomeScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `ActivityPlanScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/ActivityPlanScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `ActivityScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/ActivityScreen.tsx → apps/mobile/src/store/useProfileStore.ts

## Import Cycles
- None detected.

## Communities (136 total, 59 thin omitted)

### Community 0 - "react"
Cohesion: 0.05
Nodes (93): BottomSheetSelect(), BottomSheetSelectProps, styles, Button(), ButtonProps, styles, Checkbox(), CheckboxProps (+85 more)

### Community 1 - "dependencies"
Cohesion: 0.13
Nodes (15): dependencies, expo, expo-auth-session, @expo-google-fonts/inter, expo-image-picker, expo-status-bar, react-native-safe-area-context, @supabase/supabase-js (+7 more)

### Community 2 - "devDependencies"
Cohesion: 0.13
Nodes (15): devDependencies, oxlint, @types/node, @types/react, @types/react-dom, typescript, vite, @vitejs/plugin-react (+7 more)

### Community 3 - "schemas.ts"
Cohesion: 0.08
Nodes (39): InputSchema, InputSchema, stripeKey, InputSchema, LEVELS, ACCESS_STATUSES, STATUS_MAP, SubscriptionStatus (+31 more)

### Community 5 - "web"
Cohesion: 0.05
Nodes (36): backgroundColor, foregroundImage, adaptiveIcon, package, predictiveBackGestureEnabled, softwareKeyboardLayoutMode, versionCode, expo (+28 more)

### Community 6 - "compilerOptions"
Cohesion: 0.08
Nodes (23): compilerOptions, allowArbitraryExtensions, allowImportingTsExtensions, erasableSyntaxOnly, jsx, lib, module, moduleDetection (+15 more)

### Community 7 - "compilerOptions"
Cohesion: 0.10
Nodes (19): compilerOptions, allowImportingTsExtensions, erasableSyntaxOnly, lib, module, moduleDetection, noEmit, noFallthroughCasesInSwitch (+11 more)

### Community 8 - "mobile/App.tsx"
Cohesion: 0.05
Nodes (48): App(), Stack, AnimatedSplash(), styles, OnboardingLayout(), OnboardingLayoutProps, styles, BeforeInstallPromptEvent (+40 more)

### Community 9 - "PerguntasScreen.tsx"
Cohesion: 0.17
Nodes (17): QuestionScreenLayout(), QuestionScreenLayoutProps, styles, HabilidadeScreen(), OPTION_LABELS, stateStyles, OPTION_LABELS, styles (+9 more)

### Community 10 - "dashboard.ts"
Cohesion: 0.39
Nodes (7): DashboardScreen(), formatCount(), countRows(), DashboardStats, fetchDashboardStats(), fetchSignupsByMonth(), MONTH_LABELS

### Community 11 - "mobile/package.json"
Cohesion: 0.29
Nodes (6): engines, node, main, name, private, version

### Community 12 - "QuestionCrudScreen.tsx"
Cohesion: 0.14
Nodes (20): AgeBracketCode, HabilidadeKey, InitialQuestionsScreen(), columns, FETCHERS, filters, QuestionCrudScreen(), QuestionCrudScreenProps (+12 more)

### Community 14 - "plugins"
Cohesion: 0.22
Nodes (8): plugins, rules, react/only-export-components, react/rules-of-hooks, $schema, oxc, typescript, warn

### Community 16 - "tsconfig.json"
Cohesion: 0.40
Nodes (4): compilerOptions, strict, extends, expo/tsconfig.base

### Community 17 - "Backoffice Full Logo (Avance Kids wordmark, blue/green mark)"
Cohesion: 0.67
Nodes (3): Backoffice Full Logo (Avance Kids wordmark, blue/green mark), Backoffice Hero Image (3D purple beveled tile), Mobile Logo + Wordmark (identical to backoffice logo)

### Community 19 - "ActivitiesScreen.tsx"
Cohesion: 0.12
Nodes (23): AGE_BRACKETS, AgeBracket, Atividade, AtividadeStatus, buildProgramaLabel(), EXERCISE_LEVELS, ExerciseLevel, getAgeBracket() (+15 more)

### Community 20 - "1. Bloqueado por decisão da cliente"
Cohesion: 0.20
Nodes (10): 1.1 Escala A/B/C/NV do checklist — ✅ perguntas oficiais importadas, 1.2 Como A/B/C determina Aquisição / Generalização / Manutenção — ✅ resolvido, 1.3 Faixa etária 61–71 meses (e as outras duas lacunas) — ✅ resolvido, 1.4 Rebaixamento de faixa — ✅ resolvido, 1.5 Tratamento de NV — ✅ resolvido, 1.6 Definição de contexto da Generalização — ✅ resolvido, 1.7 Códigos de Triagem (AT) — 24 códigos, 72 registros — ✅ expostos como brincadeiras, 1.8 Quais atividades são premium — ✅ resolvido (controle no backoffice) (+2 more)

### Community 21 - "manifest.json"
Cohesion: 0.11
Nodes (17): background_color, categories, description, dir, display, icons, id, lang (+9 more)

### Community 23 - "import_perguntas.py"
Cohesion: 0.21
Nodes (23): Exception, Path, converter_ordem(), criar_xlsx_sintetico(), eh_linha_de_exemplo(), ErroDeValidacao, gerar_sql(), ler_docx() (+15 more)

### Community 26 - "src/App.tsx"
Cohesion: 0.14
Nodes (16): App(), RequireAdmin(), AuthContext, AuthContextValue, AuthProvider(), CurrentAdmin, loadAdmin(), useAuth() (+8 more)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 35 - "ArticlesScreen.tsx"
Cohesion: 0.13
Nodes (14): ACCESS_PLANS, useEntityList(), AdminUsersScreen(), columns, ROLE_OPTIONS, ArticlesScreen(), columns, filters (+6 more)

### Community 43 - "P1 — Corrigidos"
Cohesion: 0.07
Nodes (26): Achados refutados na verificação (não são problema), ActivityScreen — rodapé fixo por cima da tab bar, Arquivos alterados, Auditoria de UI/Layout — Avance Kids (mobile), BottomSheetSelect (Cadastro da criança, Editar criança), Como a auditoria foi feita, Contexto técnico que orienta várias correções, FormScreen — safe area e teclado (6 telas) (+18 more)

### Community 44 - "Login com Google — configuração final"
Cohesion: 0.40
Nodes (4): 1. Google Cloud Console, 2. Supabase, 3. Validação, Login com Google — configuração final

### Community 45 - "Build Android (APK) — Avance Kids"
Cohesion: 0.18
Nodes (11): Assinatura, Build Android (APK) — Avance Kids, Gerar o APK, Identidade do app, Instalar no dispositivo, Keystore anterior: comprometido e substituído, Limite de 260 caracteres no Windows, Notas (+3 more)

### Community 46 - "dependencies"
Cohesion: 0.13
Nodes (15): dependencies, lucide-react, react-router-dom, @supabase/supabase-js, @tiptap/extension-link, @tiptap/react, @tiptap/starter-kit, zustand (+7 more)

### Community 47 - "atividades.ts"
Cohesion: 0.16
Nodes (26): supabase, supabaseAnonKey, supabaseUrl, handleConfirmArchive(), handleSave(), AdminRow, toggleArchiveAdmin(), ArticleRow (+18 more)

### Community 48 - "Plano de Implementação do Backend — Avance Kids"
Cohesion: 0.13
Nodes (14): 1. Estado atual, 2. Divergências: schema legado × frontend novo, 3. Decisões de design (assumidas — revisar se discordar), 4. Plano de execução, 5. Pontos em aberto (confirmar com o time), 6. Pré-requisitos operacionais, Fase 1 — Novo schema (migração baseline), Fase 2 — Edge Functions refeitas (+6 more)

### Community 49 - "20260718000000_baseline.sql"
Cohesion: 0.07
Nodes (49): handle_new_user, activity_plans, admin_users, age_brackets, articles, calculate_general_age(), calculate_skill_age(), check_exercise_completion() (+41 more)

### Community 51 - "import_programas.py"
Cohesion: 0.16
Nodes (22): carregar_faixas_do_validador(), gerar(), main(), Path, Lê os limites que scripts/validate_migrations.sh trava, para comparar., self_check(), ErroDeValidacao, gerar_sql() (+14 more)

### Community 52 - "backoffice/package.json"
Cohesion: 0.20
Nodes (9): name, private, scripts, build, dev, lint, preview, type (+1 more)

### Community 55 - "devDependencies"
Cohesion: 0.29
Nodes (7): devDependencies, react-native-svg-transformer, @types/react, typescript, react-native-svg-transformer, @types/react, typescript

### Community 56 - "TriagemScreen.tsx"
Cohesion: 0.29
Nodes (11): ActivityHistoryScreen(), PerguntasScreen(), styles, TriagemScreen(), successRate(), fetchAgeBrackets(), fetchSkills(), resolveBracketForMonths() (+3 more)

### Community 57 - "ui/index.ts"
Cohesion: 0.07
Nodes (25): Badge(), BadgeProps, BadgeVariant, ConfirmDialog(), ConfirmDialogProps, buildPageList(), DataTable(), DataTableColumn (+17 more)

### Community 58 - "habilidades.ts"
Cohesion: 0.20
Nodes (10): getSkillColor(), Habilidade, HABILIDADE_STYLES, HabilidadeKey, HABILIDADES, HabilidadeStyle, MOCK_PERGUNTAS, normalizeSkillName() (+2 more)

### Community 59 - "terms.ts"
Cohesion: 0.18
Nodes (10): PrivateAvatar(), PrivateAvatarProps, supabase, AVATAR_URL_REFRESH_MS, AVATAR_URL_TTL_SECONDS, CachedSignedUrl, getSignedAvatarUrl(), pendingSignedUrls (+2 more)

### Community 60 - "scripts"
Cohesion: 0.33
Nodes (6): scripts, android, build, ios, start, web

### Community 63 - "Instruções do projeto"
Cohesion: 0.22
Nodes (8): Comunicação, Contexto, Definição de pronto, Forma de trabalhar, Graphify: contexto antes de arquivos, Instruções do projeto, Limites e segurança, Simplicidade com Ponytail

### Community 64 - "Deploy da assinatura (Stripe + bloqueio premium)"
Cohesion: 0.22
Nodes (8): 1. Banco, 2. Secrets das Edge Functions, 3. Edge Functions, 4. Painel do Stripe, 5. App, 6. Verificação, 7. Aceite dos termos e exclusao de conta, Deploy da assinatura (Stripe + bloqueio premium)

### Community 66 - "Arquitetura padrão para Claude Code"
Cohesion: 0.29
Nodes (6): Adotar em um projeto, Arquitetura padrão para Claude Code, Estrutura, Graphify, Manutenção, Ponytail

### Community 69 - "handoff/SKILL.md"
Cohesion: 0.29
Nodes (6): Arquivos e comandos relevantes, Concluído, Decisões e motivos, Objetivo, Pendente ou bloqueado, Próximo passo exato

### Community 70 - "check_exercise_completion"
Cohesion: 0.40
Nodes (4): activity_plans, exercise_sessions, exercises, check_exercise_completion()

### Community 97 - "db.ts"
Cohesion: 0.15
Nodes (21): ActivityScreen(), RESULT_OPTIONS, styles, fetchPlan(), generateActivityPlan(), registerAttempt(), RegisterAttemptResult, startExerciseSession() (+13 more)

### Community 100 - "useProfileStore.ts"
Cohesion: 0.23
Nodes (13): ChildrenListScreen(), styles, Onboarding1Screen(), fetchProfile(), listChildren(), avatarPathFromReference(), Child, EMPTY_STATE (+5 more)

### Community 102 - "20260907120200_migration-18_produtos_por_brincadeira.sql"
Cohesion: 0.40
Nodes (4): set_updated_at, play_products, plays, trg_play_products_updated_at

### Community 103 - "mobile/vercel.json"
Cohesion: 0.50
Nodes (3): buildCommand, outputDirectory, $schema

### Community 105 - "entities.ts"
Cohesion: 0.16
Nodes (14): AccessPlan, columns, emptyProduto(), filters, GamesScreen(), MEDIA_TYPE_OPTIONS, fetchBrincadeiras(), PlayRow (+6 more)

### Community 110 - "terms_acceptances"
Cohesion: 0.50
Nodes (4): auth, auth.users, terms_acceptances, terms_documents

### Community 123 - "PlansScreen.tsx"
Cohesion: 0.36
Nodes (10): formatarPreco(), PlansScreen(), styles, BillingConfig, createBillingPortalSession(), createCheckoutSession(), fetchBillingConfig(), fetchSubscription() (+2 more)

### Community 124 - "2. Remediação aplicada"
Cohesion: 0.20
Nodes (8): 1. O achado, 2.1 Keystore novo (o que realmente resolve), 2.2 `.gitignore` na raiz, 2.3 Reescrita do histórico local, 2. Remediação aplicada, 4. Como conferir que a limpeza funcionou, Keystore de release comprometido — o que aconteceu e o que foi feito, Onde estava o backup

### Community 125 - "Dependências e pendências"
Cohesion: 0.22
Nodes (9): 2.6 Campos novos no backoffice — ⬜ aberto, 2. Patches de UI — ✅ aplicados na integração, 3.1 O plano da criança fica ~4x maior, 3.2 Crianças com plano já gerado, 3. Consequências conhecidas das mudanças desta branch, 6. Perguntas em aberto para a cliente, Dependências e pendências, Resolvido com as respostas da cliente (migration-11) (+1 more)

### Community 126 - "HomeScreen.tsx"
Cohesion: 0.08
Nodes (29): BottomTabBar(), BottomTabBarProps, styles, CURVE_MAX_HEIGHT, CURVE_TOP, CurvedHeader(), CurvedHeaderProps, HEADER_MAX_HEIGHT (+21 more)

### Community 130 - "QA em Android real"
Cohesion: 0.22
Nodes (8): Assinatura, Conta, Fluxo principal, Layout e entrada, Preparação, QA em Android real, Quando algo falhar, Termos

### Community 132 - "4. Riscos levantados (com status)"
Cohesion: 0.29
Nodes (7): 4.1 ✅ Keystore de release e senha versionados no git — resolvido, 4.2 ✅ Tenant crossing em `exercise_sessions` / `exercise_attempts` — resolvido, 4.3 🟠 Bucket `avatars` é público, 4.4 🟠 `verify_jwt = false` em 9 functions, 4.5 🟡 Webhook do Stripe sem idempotência por evento, 4.6 🟡 `apiVersion` do Stripe não passa em `deno check`, 4. Riscos levantados (com status)

### Community 134 - "Issue tracker: Linear"
Cohesion: 0.14
Nodes (12): Antes de qualquer operação, Convenções, Estados do time Devnoflow, Issue tracker: Linear, `labels` substitui o conjunto inteiro, Onde as issues nascem, Quando uma skill disser "buscar o ticket relevante", Quando uma skill disser "publicar no issue tracker" (+4 more)

### Community 136 - "Contexto — Avance Kids"
Cohesion: 0.22
Nodes (8): Atividade, Contexto — Avance Kids, Exercício, Faixa, Habilidade (ou área), Não Verificado (NV), Nível, Trilha

### Community 138 - "Docs de domínio"
Cohesion: 0.33
Nodes (5): Antes de explorar, leia, Docs de domínio, Estrutura de arquivos, Sinalize conflito com ADR, Use o vocabulário do glossário

### Community 139 - "DEPENDENCIAS-E-PENDENCIAS.md"
Cohesion: 0.25
Nodes (5): Mensagem para a cliente — pontos em aberto, 1. Atividades → `exercises`, 2. Perguntas → `questions`, 3. Como enviar, Modelos de importação de conteúdo

### Community 140 - "3. Propagação para o remoto — executada"
Cohesion: 0.40
Nodes (5): 3. Propagação para o remoto — executada, Levantamento antes do push, O push, O que isso não resolve, Verificação depois do push

### Community 141 - "5. Aberto desde a integração"
Cohesion: 0.50
Nodes (4): 5.1 ⬜ CPF da criança — NÃO respondido, continua aberto, 5.2 ⬜ Exportação de relatório — direito previsto nos Termos, sem tela, 5.3 ✅ Aceite dos termos para contas antigas — resolvido, 5. Aberto desde a integração

## Knowledge Gaps
- **487 isolated node(s):** `Stack`, `name`, `slug`, `version`, `scheme` (+482 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 602 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **59 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `react` to `db.ts`, `ArticlesScreen.tsx`, `useProfileStore.ts`, `mobile/App.tsx`, `PerguntasScreen.tsx`, `dashboard.ts`, `PlansScreen.tsx`, `plugins`, `ActivitiesScreen.tsx`, `TriagemScreen.tsx`, `ui/index.ts`, `src/App.tsx`, `terms.ts`, `HomeScreen.tsx`?**
  _High betweenness centrality (0.132) - this node is a cross-community bridge._
- **What connects `Stack`, `name`, `slug` to the rest of the system?**
  _487 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `react` be split into smaller, more focused modules?**
  _Cohesion score 0.05468135326514555 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `schemas.ts` be split into smaller, more focused modules?**
  _Cohesion score 0.08065268065268065 - nodes in this community are weakly interconnected._
- **Should `web` be split into smaller, more focused modules?**
  _Cohesion score 0.05405405405405406 - nodes in this community are weakly interconnected._