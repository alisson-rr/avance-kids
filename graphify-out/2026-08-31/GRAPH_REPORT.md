# Graph Report - AVANCE-Kids  (2026-08-31)

## Corpus Check
- 195 files · ~283,452 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1097 nodes · 2065 edges · 134 communities (69 shown, 65 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 19 edges (avg confidence: 0.7)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `11130916`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- App.tsx
- dependencies
- devDependencies
- schemas.ts
- ABA Checklist & Programs Logic Specification
- expo
- compilerOptions
- compilerOptions
- BottomTabBar.tsx
- App.tsx
- HomeScreen.tsx
- package.json
- LoginScreen.tsx
- TriagemBaseScreen.tsx
- plugins
- Android Adaptive Icon - Foreground Layer (blue 'A' chevron mark)
- tsconfig.json
- Backoffice Full Logo (Avance Kids wordmark, blue/green mark)
- AvanceKids Logo (Icon Mark)
- imports
- imports
- react
- errorMessage
- GamesScreen.tsx
- HomeScreen.tsx
- theme.ts
- OnboardingLayout.tsx
- Backoffice Favicon (purple beveled diamond icon)
- tsconfig.json
- Mobile CLAUDE.md (includes AGENTS.md)
- Folha de Registro - ABA (Registration Sheet)
- theme.ts
- Onboarding Illustration 3 - Kids Playing Outdoors
- metro.config.js
- iPhone Mockup - Screening Questionnaire Screen (Perguntas Iniciais)
- Backoffice Social/UI Icon Sprite (bluesky, discord, docs, github, social, x)
- Backoffice README (Vite+React+TS Template Docs)
- React Logo Asset
- Avance Kids Root README (placeholder, garbled encoding)
- Onboarding Screenshot 1 - 'Perguntas Iniciais' Initial Screening Question UI
- Social Domain Avatar (boy, green shirt, holding emoji cards)
- ActivityHistoryScreen.tsx
- AuthContext.tsx
- AdminUsersScreen.tsx
- expo
- PerguntasScreen.tsx
- HomeScreen.tsx
- Plano de Implementação do Backend — Avance Kids
- BottomTabBar.tsx
- recharts
- GamesScreen.tsx
- package.json
- Vite Logo Asset (purple recolor, light/dark parenthesis)
- @expo/metro-runtime
- devDependencies
- @react-native-async-storage/async-storage
- DashboardScreen.tsx
- @supabase/supabase-js
- react-dom
- PlansScreen.tsx
- @tiptap/extension-image
- @tiptap/pm
- Instruções do projeto
- Deploy da assinatura (Stripe + bloqueio premium)
- 20260811000000_migration-05_gating_premium.sql
- Arquitetura padrão para Claude Code
- expo-linear-gradient
- expo-splash-screen
- handoff/SKILL.md
- mobile/src/screens/LoginScreen.tsx
- react
- react-dom
- react-native
- react-native-safe-area-context
- react-native-screens
- react-native-web
- @react-navigation/native-stack
- checkout-return/index.ts
- zustand
- api-conventions.md
- code-style.md
- database.md
- security.md
- expo-image-picker
- testing.md
- typescript.md
- 20260720000002_migration-04_children_avatar.sql
- Android Adaptive Icon - Monochrome Layer (gray 'A' chevron mark)
- Mobile Splash Icon (gray 'A' chevron mark)
- handle-stripe-webhook/index.ts
- generate-activity-plan/index.ts
- activities.ts
- HomeScreen.tsx
- BottomSheetSelect.tsx
- mobile/src/screens/LoginScreen.tsx
- PerguntasScreen.tsx
- validate_migrations.sh
- 20260819130000_migration-09_integridade_multi_tenant.sql
- FormScreen.tsx
- dashboard.ts
- 20260819120100_migration-07_exclusao_de_conta.sql
- lucide-react
- @expo-google-fonts/inter
- 1.1_F01AC002_Programa_ABA_aabe9a99.md
- 1.F01AT001-004_Programas_Padrao17Colunas_b0cd6686.md
- exemplo-Planilha de registro_Meus Progressos2_41b32829.md
- HomeScreen.tsx
- PlansScreen.tsx
- TermsModal.tsx
- dialog.tsx
- BottomTabBar.tsx
- useProfileStore
- react-dom
- expo
- 20260828120000_migration-11_ajustes_logica_cliente.sql
- submit-initial-answers/index.ts

## God Nodes (most connected - your core abstractions)
1. `react` - 59 edges
2. `useProfileStore` - 27 edges
3. `theme` - 27 edges
4. `showError()` - 22 edges
5. `errorMessage()` - 21 edges
6. `RecordStatus` - 20 edges
7. `compilerOptions` - 18 edges
8. `showDialog()` - 18 edges
9. `selectActiveChild()` - 15 edges
10. `compilerOptions` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Graphify Knowledge Graph Rules (root CLAUDE.md)` --conceptually_related_to--> `Mobile CLAUDE.md (includes AGENTS.md)`  [INFERRED]
  CLAUDE.md → apps/mobile/CLAUDE.md
- `matchesSearch()` --calls--> `getSkill()`  [EXTRACTED]
  apps/backoffice/src/screens/QuestionCrudScreen.tsx → apps/backoffice/src/constants/aba.ts
- `ActivityScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/ActivityScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `ActivityHistoryScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/ActivityHistoryScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `ActivityPlanScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/ActivityPlanScreen.tsx → apps/mobile/src/store/useProfileStore.ts

## Import Cycles
- None detected.

## Communities (134 total, 65 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.18
Nodes (23): BottomSheetSelect(), FormScreen(), PhotoPicker(), SolidInput(), SolidInputProps, styles, DISORDER_OPTIONS, GENDER_OPTIONS (+15 more)

### Community 1 - "dependencies"
Cohesion: 0.15
Nodes (13): dependencies, @expo-google-fonts/inter, expo-image, @expo/metro-runtime, @react-native-async-storage/async-storage, react-native-svg, @react-navigation/native, @expo-google-fonts/inter (+5 more)

### Community 2 - "devDependencies"
Cohesion: 0.13
Nodes (15): devDependencies, oxlint, @types/node, @types/react, @types/react-dom, typescript, vite, @vitejs/plugin-react (+7 more)

### Community 3 - "schemas.ts"
Cohesion: 0.09
Nodes (35): stripe, stripe, stripe, InputSchema, stripeKey, InputSchema, ACCESS_STATUSES, STATUS_MAP (+27 more)

### Community 5 - "expo"
Cohesion: 0.08
Nodes (25): backgroundColor, foregroundImage, adaptiveIcon, package, predictiveBackGestureEnabled, versionCode, expo, android (+17 more)

### Community 6 - "compilerOptions"
Cohesion: 0.08
Nodes (23): compilerOptions, allowArbitraryExtensions, allowImportingTsExtensions, erasableSyntaxOnly, jsx, lib, module, moduleDetection (+15 more)

### Community 7 - "compilerOptions"
Cohesion: 0.10
Nodes (19): compilerOptions, allowImportingTsExtensions, erasableSyntaxOnly, lib, module, moduleDetection, noEmit, noFallthroughCasesInSwitch (+11 more)

### Community 8 - "BottomTabBar.tsx"
Cohesion: 0.08
Nodes (33): BottomSheetSelectProps, styles, Button(), ButtonProps, styles, CheckboxProps, styles, FormScreenProps (+25 more)

### Community 9 - "App.tsx"
Cohesion: 0.19
Nodes (11): ActivityHistoryScreen(), ActivityPlanScreen(), isPremiumLocked(), planDescription(), findOpenSession(), generateActivityPlan(), registerAttempt(), RegisterAttemptResult (+3 more)

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.15
Nodes (19): AgeBracketCode, HabilidadeKey, columns, FETCHERS, filters, matchesSearch(), QuestionCrudScreen(), QuestionCrudScreenProps (+11 more)

### Community 11 - "package.json"
Cohesion: 0.20
Nodes (9): main, name, private, scripts, android, ios, start, web (+1 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.06
Nodes (31): Sheet: CONSOLIDADO DE SESSÕES, Sheet: DIA 1, Sheet: DIA 10, Sheet: DIA 11, Sheet: DIA 12, Sheet: DIA 13, Sheet: DIA 14, Sheet: DIA 15 (+23 more)

### Community 14 - "plugins"
Cohesion: 0.22
Nodes (8): plugins, rules, react/only-export-components, react/rules-of-hooks, $schema, oxc, typescript, warn

### Community 16 - "tsconfig.json"
Cohesion: 0.40
Nodes (4): compilerOptions, strict, extends, expo/tsconfig.base

### Community 17 - "Backoffice Full Logo (Avance Kids wordmark, blue/green mark)"
Cohesion: 0.67
Nodes (3): Backoffice Full Logo (Avance Kids wordmark, blue/green mark), Backoffice Hero Image (3D purple beveled tile), Mobile Logo + Wordmark (identical to backoffice logo)

### Community 19 - "imports"
Cohesion: 0.22
Nodes (18): ACCESS_PLANS, AGE_BRACKETS, AgeBracket, Atividade, AtividadeStatus, buildProgramaLabel(), EXERCISE_LEVELS, ExerciseLevel (+10 more)

### Community 20 - "imports"
Cohesion: 0.06
Nodes (30): 1.1 Escala A/B/C/NV do checklist — 🟡 mapeamento definido, importação pendente, 1.2 Como A/B/C determina Aquisição / Generalização / Manutenção — ✅ resolvido, 1.3 Faixa etária 61–71 meses (e as outras duas lacunas) — ✅ resolvido, 1.4 Rebaixamento de faixa — ✅ resolvido, 1.5 Tratamento de NV — ✅ resolvido, 1.6 Definição de contexto da Generalização — ✅ resolvido, 1.7 Códigos de Triagem (AT) — 24 códigos, 72 registros — ✅ conteúdo importado, 1.8 Quais atividades são premium — ✅ resolvido (controle no backoffice) (+22 more)

### Community 21 - "react"
Cohesion: 0.32
Nodes (3): OnboardingLayout(), OnboardingLayoutProps, styles

### Community 23 - "GamesScreen.tsx"
Cohesion: 0.33
Nodes (11): HabilidadeScreen(), PerguntasScreen(), styles, TriagemScreen(), fetchAgeBrackets(), fetchSkills(), resolveBracketForMonths(), fetchQuestions() (+3 more)

### Community 26 - "OnboardingLayout.tsx"
Cohesion: 0.11
Nodes (20): RequireAdmin(), AuthContext, AuthContextValue, AuthProvider(), CurrentAdmin, loadAdmin(), useAuth(), AdminLayout() (+12 more)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 35 - "Backoffice Social/UI Icon Sprite (bluesky, discord, docs, github, social, x)"
Cohesion: 0.18
Nodes (26): AccessPlan, supabase, supabaseAnonKey, supabaseUrl, AdminRow, ArticleRow, ExerciseRow, saveAtividade() (+18 more)

### Community 43 - "AuthContext.tsx"
Cohesion: 0.07
Nodes (26): Achados refutados na verificação (não são problema), ActivityScreen — rodapé fixo por cima da tab bar, Arquivos alterados, Auditoria de UI/Layout — Avance Kids (mobile), BottomSheetSelect (Cadastro da criança, Editar criança), Como a auditoria foi feita, Contexto técnico que orienta várias correções, FormScreen — safe area e teclado (6 telas) (+18 more)

### Community 44 - "AdminUsersScreen.tsx"
Cohesion: 0.16
Nodes (22): PhotoPickerProps, styles, ChangePasswordScreen(), styles, LoginScreen(), SettingsScreen(), styles, errorMessage() (+14 more)

### Community 45 - "expo"
Cohesion: 0.08
Nodes (24): Assinatura, Build Android (APK) — Avance Kids, Gerar o APK, Identidade do app, Instalar no dispositivo, Keystore anterior: comprometido e substituído, Limite de 260 caracteres no Windows, Notas (+16 more)

### Community 46 - "PerguntasScreen.tsx"
Cohesion: 0.13
Nodes (15): dependencies, lucide-react, react-router-dom, @supabase/supabase-js, @tiptap/extension-link, @tiptap/react, @tiptap/starter-kit, zustand (+7 more)

### Community 47 - "HomeScreen.tsx"
Cohesion: 0.13
Nodes (17): EntityFilterConfig, useEntityList(), ArticlesScreen(), columns, filters, matchesSearch(), stripHtml(), columns (+9 more)

### Community 48 - "Plano de Implementação do Backend — Avance Kids"
Cohesion: 0.13
Nodes (14): 1. Estado atual, 2. Divergências: schema legado × frontend novo, 3. Decisões de design (assumidas — revisar se discordar), 4. Plano de execução, 5. Pontos em aberto (confirmar com o time), 6. Pré-requisitos operacionais, Fase 1 — Novo schema (migração baseline), Fase 2 — Edge Functions refeitas (+6 more)

### Community 49 - "BottomTabBar.tsx"
Cohesion: 0.12
Nodes (33): activity_plans, admin_users, age_brackets, articles, calculate_general_age(), calculate_skill_age(), check_exercise_completion(), child_question_answers (+25 more)

### Community 51 - "GamesScreen.tsx"
Cohesion: 0.25
Nodes (16): Exception, Path, ErroDeValidacao, gerar_sql(), gerar_sql_triagem(), ler_planilha(), main(), normalizar_nivel() (+8 more)

### Community 52 - "package.json"
Cohesion: 0.20
Nodes (9): name, private, scripts, build, dev, lint, preview, type (+1 more)

### Community 55 - "devDependencies"
Cohesion: 0.29
Nodes (7): devDependencies, react-native-svg-transformer, @types/react, typescript, @types/react, typescript, react-native-svg-transformer

### Community 57 - "DashboardScreen.tsx"
Cohesion: 0.09
Nodes (27): Badge(), BadgeProps, BadgeVariant, ConfirmDialog(), ConfirmDialogProps, buildPageList(), DataTable(), DataTableColumn (+19 more)

### Community 59 - "react-dom"
Cohesion: 0.06
Nodes (40): App(), Stack, Props, styles, TermsBody(), TermsHeader(), textoEhDoVigente(), Conteudo() (+32 more)

### Community 60 - "PlansScreen.tsx"
Cohesion: 0.18
Nodes (10): Sheet: Anamnese, Sheet: CONSOLIDADO, Sheet: CP, Sheet: Folha de Rosto, Sheet: INSTRUÇÕES, Sheet: Modelo Relatório, Sheet: mês 1, Sheet: mês 2 (+2 more)

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

### Community 102 - "BottomSheetSelect.tsx"
Cohesion: 0.40
Nodes (4): Aquisição (A), Generalização (B), Manutenção (C), Programa ABA – F01AC002 – Olha durante brincadeira

### Community 103 - "mobile/src/screens/LoginScreen.tsx"
Cohesion: 0.29
Nodes (7): AdminUsersScreen(), columns, ROLE_OPTIONS, roleLabel(), fetchAdmins(), saveAdmin(), toggleArchiveAdmin()

### Community 105 - "PerguntasScreen.tsx"
Cohesion: 0.21
Nodes (11): OPTION_LABELS, styles, AnswerInput, BracketRef, QUESTION_OPTIONS, submitInitialAnswers(), SubmitInitialResult, submitScreeningAnswers() (+3 more)

### Community 107 - "20260819130000_migration-09_integridade_multi_tenant.sql"
Cohesion: 0.83
Nodes (3): activity_plans, exercise_attempts, exercise_sessions

### Community 112 - "lucide-react"
Cohesion: 0.16
Nodes (12): QuestionScreenLayout(), QuestionScreenLayoutProps, styles, Habilidade, HABILIDADE_STYLES, HabilidadeKey, HABILIDADES, HabilidadeStyle (+4 more)

### Community 113 - "@expo-google-fonts/inter"
Cohesion: 0.13
Nodes (17): ActivityScreen(), RESULT_OPTIONS, styles, ActivityPlanRow, AgeBracketRow, AttemptResult, ExerciseLevel, ExerciseRow (+9 more)

### Community 122 - "HomeScreen.tsx"
Cohesion: 0.26
Nodes (9): ActivityCardProps, HomeScreen(), styles, fetchActivityPlans(), fetchArticles(), fetchPlays(), ArticleRow, PlayRow (+1 more)

### Community 123 - "PlansScreen.tsx"
Cohesion: 0.30
Nodes (11): supabase, formatarPreco(), PlansScreen(), styles, BillingConfig, createBillingPortalSession(), createCheckoutSession(), fetchBillingConfig() (+3 more)

### Community 125 - "dialog.tsx"
Cohesion: 0.28
Nodes (7): CurvedHeader(), CurvedHeaderProps, styles, ChildrenListScreen(), styles, Child, fromIsoDate()

### Community 126 - "BottomTabBar.tsx"
Cohesion: 0.20
Nodes (6): BottomTabBar(), BottomTabBarProps, styles, ContentDetailParams, ContentDetailScreen(), styles

### Community 128 - "useProfileStore"
Cohesion: 0.32
Nodes (5): Onboarding1Screen(), EMPTY_STATE, ProfileStore, useProfileStore, ChildRow

### Community 131 - "20260828120000_migration-11_ajustes_logica_cliente.sql"
Cohesion: 0.38
Nodes (3): calculate_general_age(), calculate_skill_age(), children

## Knowledge Gaps
- **466 isolated node(s):** `Habilidade`, `AgeBracket`, `styles`, `OPTION_LABELS`, `styles` (+461 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **65 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `BottomTabBar.tsx` to `App.tsx`, `useProfileStore`, `plugins`, `imports`, `react`, `GamesScreen.tsx`, `OnboardingLayout.tsx`, `AdminUsersScreen.tsx`, `HomeScreen.tsx`, `DashboardScreen.tsx`, `react-dom`, `mobile/src/screens/LoginScreen.tsx`, `PerguntasScreen.tsx`, `lucide-react`, `@expo-google-fonts/inter`, `HomeScreen.tsx`, `PlansScreen.tsx`, `dialog.tsx`, `BottomTabBar.tsx`?**
  _High betweenness centrality (0.136) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `react-dom`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **What connects `Habilidade`, `AgeBracket`, `styles` to the rest of the system?**
  _466 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `schemas.ts` be split into smaller, more focused modules?**
  _Cohesion score 0.09155844155844156 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.07692307692307693 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._