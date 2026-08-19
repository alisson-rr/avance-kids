# Graph Report - AVANCE-Kids  (2026-08-19)

## Corpus Check
- 177 files · ~263,042 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 937 nodes · 1830 edges · 111 communities (55 shown, 56 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 13 edges (avg confidence: 0.7)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `201b7ddf`
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
- ActivityPlanScreen.tsx
- activities.ts
- HomeScreen.tsx
- BottomSheetSelect.tsx
- billing-config/index.ts
- HomeScreen.tsx
- validate_migrations.sh
- 20260819130000_migration-09_integridade_multi_tenant.sql
- FormScreen.tsx
- dashboard.ts

## God Nodes (most connected - your core abstractions)
1. `react` - 57 edges
2. `theme` - 23 edges
3. `useProfileStore` - 21 edges
4. `RecordStatus` - 21 edges
5. `showError()` - 20 edges
6. `compilerOptions` - 18 edges
7. `errorMessage()` - 17 edges
8. `showDialog()` - 16 edges
9. `compilerOptions` - 15 edges
10. `EditChildProfileScreen()` - 14 edges

## Surprising Connections (you probably didn't know these)
- `Graphify Knowledge Graph Rules (root CLAUDE.md)` --conceptually_related_to--> `Mobile CLAUDE.md (includes AGENTS.md)`  [INFERRED]
  CLAUDE.md → apps/mobile/CLAUDE.md
- `CurrentAdmin` --references--> `AdminRole`  [EXTRACTED]
  apps/backoffice/src/auth/AuthContext.tsx → apps/backoffice/src/types/entities.ts
- `matchesSearch()` --calls--> `getSkill()`  [EXTRACTED]
  apps/backoffice/src/screens/QuestionCrudScreen.tsx → apps/backoffice/src/constants/aba.ts
- `PlansScreen()` --indirect_call--> `createBillingPortalSession()`  [INFERRED]
  apps/mobile/src/screens/PlansScreen.tsx → apps/mobile/src/services/subscription.ts
- `PlansScreen()` --indirect_call--> `createCheckoutSession()`  [INFERRED]
  apps/mobile/src/screens/PlansScreen.tsx → apps/mobile/src/services/subscription.ts

## Import Cycles
- None detected.

## Communities (111 total, 56 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.19
Nodes (21): BottomSheetSelect(), PhotoPicker(), DISORDER_OPTIONS, GENDER_OPTIONS, supabase, ChildRegisterScreen(), styles, EditChildProfileScreen() (+13 more)

### Community 1 - "dependencies"
Cohesion: 0.15
Nodes (13): dependencies, @expo-google-fonts/inter, expo-image, @expo/metro-runtime, @react-native-async-storage/async-storage, react-native-svg, @react-navigation/native, @expo-google-fonts/inter (+5 more)

### Community 2 - "devDependencies"
Cohesion: 0.13
Nodes (15): devDependencies, oxlint, @types/node, @types/react, @types/react-dom, typescript, vite, @vitejs/plugin-react (+7 more)

### Community 3 - "schemas.ts"
Cohesion: 0.10
Nodes (27): stripe, stripe, getServiceClient(), getSupabaseClient(), getUser(), BillingError, handleBillingError(), priceIdFor() (+19 more)

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
Nodes (29): BottomSheetSelectProps, styles, Button(), ButtonProps, styles, CheckboxProps, styles, GhostButton() (+21 more)

### Community 9 - "App.tsx"
Cohesion: 0.13
Nodes (23): styles, TermsModal(), TermsModalProps, SecaoTermos, TERMOS_SECOES, ParentRegisterScreen(), styles, SettingsScreen() (+15 more)

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.16
Nodes (19): AgeBracketCode, HabilidadeKey, useEntityList(), columns, FETCHERS, filters, matchesSearch(), QuestionCrudScreen() (+11 more)

### Community 11 - "package.json"
Cohesion: 0.20
Nodes (9): main, name, private, scripts, android, ios, start, web (+1 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.36
Nodes (10): formatarPreco(), PlansScreen(), styles, BillingConfig, createBillingPortalSession(), createCheckoutSession(), fetchBillingConfig(), fetchSubscription() (+2 more)

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
Cohesion: 0.21
Nodes (18): ACCESS_PLANS, AGE_BRACKETS, AgeBracket, Atividade, AtividadeStatus, buildProgramaLabel(), EXERCISE_LEVELS, ExerciseLevel (+10 more)

### Community 20 - "imports"
Cohesion: 0.07
Nodes (28): 1.1 Escala A/B/C/NV do checklist, 1.2 Como A/B/C determina Aquisição / Generalização / Manutenção, 1.3 Faixa etária 61–71 meses (e as outras duas lacunas), 1.4 Rebaixamento de faixa, 1.5 Tratamento de NV, 1.6 Definição de contexto da Generalização, 1.7 Códigos de Triagem (AT) — 24 códigos, 72 registros — ✅ conteúdo importado, 1.8 Quais atividades são premium (+20 more)

### Community 21 - "react"
Cohesion: 0.12
Nodes (17): App(), Stack, AnimatedSplash(), styles, CurvedHeader(), CurvedHeaderProps, styles, OnboardingLayout() (+9 more)

### Community 23 - "GamesScreen.tsx"
Cohesion: 0.06
Nodes (55): QuestionScreenLayout(), Habilidade, HABILIDADE_STYLES, HabilidadeKey, HABILIDADES, HabilidadeStyle, MOCK_PERGUNTAS, SKILL_COLORS (+47 more)

### Community 26 - "OnboardingLayout.tsx"
Cohesion: 0.14
Nodes (15): RequireAdmin(), AuthContext, AuthContextValue, AuthProvider(), CurrentAdmin, loadAdmin(), useAuth(), AdminLayout() (+7 more)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 35 - "Backoffice Social/UI Icon Sprite (bluesky, discord, docs, github, social, x)"
Cohesion: 0.22
Nodes (17): supabase, supabaseAnonKey, supabaseUrl, ArticlesScreen(), GamesScreen(), fetchArtigos(), saveArtigo(), toggleArchiveArtigo() (+9 more)

### Community 44 - "AdminUsersScreen.tsx"
Cohesion: 0.25
Nodes (10): AdminUsersScreen(), columns, ROLE_OPTIONS, roleLabel(), AdminRow, fetchAdmins(), saveAdmin(), toggleArchiveAdmin() (+2 more)

### Community 45 - "expo"
Cohesion: 0.10
Nodes (19): Assinatura, Build Android (APK) — Avance Kids, Gerar o APK, Identidade do app, Instalar no dispositivo, Keystore anterior: comprometido e substituído, Limite de 260 caracteres no Windows, Notas (+11 more)

### Community 46 - "PerguntasScreen.tsx"
Cohesion: 0.13
Nodes (15): dependencies, lucide-react, react-router-dom, @supabase/supabase-js, @tiptap/extension-link, @tiptap/react, @tiptap/starter-kit, zustand (+7 more)

### Community 47 - "HomeScreen.tsx"
Cohesion: 0.17
Nodes (14): ConfirmDialog(), ConfirmDialogProps, buildPageList(), DataTable(), DataTableColumn, DataTableProps, SortDirection, EntityCrudScreen() (+6 more)

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
Cohesion: 0.08
Nodes (25): Badge(), BadgeProps, BadgeVariant, EntityFilterConfig, FormField(), FormFieldProps, ImageUploadField(), ImageUploadFieldProps (+17 more)

### Community 60 - "PlansScreen.tsx"
Cohesion: 0.32
Nodes (11): AccessPlan, ArticleRow, ExerciseRow, PlayRow, QuestionRow, MediaType, RecordStatus, Artigo (+3 more)

### Community 63 - "Instruções do projeto"
Cohesion: 0.22
Nodes (8): Comunicação, Contexto, Definição de pronto, Forma de trabalhar, Graphify: contexto antes de arquivos, Instruções do projeto, Limites e segurança, Simplicidade com Ponytail

### Community 64 - "Deploy da assinatura (Stripe + bloqueio premium)"
Cohesion: 0.25
Nodes (7): 1. Banco, 2. Secrets das Edge Functions, 3. Edge Functions, 4. Painel do Stripe, 5. App, 6. Verificação, Deploy da assinatura (Stripe + bloqueio premium)

### Community 66 - "Arquitetura padrão para Claude Code"
Cohesion: 0.29
Nodes (6): Adotar em um projeto, Arquitetura padrão para Claude Code, Estrutura, Graphify, Manutenção, Ponytail

### Community 69 - "handoff/SKILL.md"
Cohesion: 0.29
Nodes (6): Arquivos e comandos relevantes, Concluído, Decisões e motivos, Objetivo, Pendente ou bloqueado, Próximo passo exato

### Community 70 - "mobile/src/screens/LoginScreen.tsx"
Cohesion: 0.23
Nodes (9): SkillActivityCard(), SkillActivityCardProps, styles, ActivityHistoryScreen(), styles, ActivityPlanScreen(), isPremiumLocked(), planDescription() (+1 more)

### Community 97 - "handle-stripe-webhook/index.ts"
Cohesion: 0.29
Nodes (4): ACCESS_STATUSES, STATUS_MAP, stripe, SubscriptionStatus

### Community 99 - "ActivityPlanScreen.tsx"
Cohesion: 0.21
Nodes (15): ChangePasswordScreen(), styles, LoginScreen(), DialogButton, DialogHost(), DialogOptions, DialogState, DialogVariant (+7 more)

### Community 102 - "BottomSheetSelect.tsx"
Cohesion: 0.20
Nodes (6): BottomTabBar(), BottomTabBarProps, styles, ContentDetailParams, ContentDetailScreen(), styles

### Community 105 - "HomeScreen.tsx"
Cohesion: 0.29
Nodes (7): ActivityCardProps, HomeScreen(), styles, fetchArticles(), fetchPlays(), ArticleRow, PlayRow

### Community 107 - "20260819130000_migration-09_integridade_multi_tenant.sql"
Cohesion: 0.83
Nodes (3): activity_plans, exercise_attempts, exercise_sessions

### Community 109 - "FormScreen.tsx"
Cohesion: 0.29
Nodes (6): FormScreen(), FormScreenProps, styles, ScreenHeader(), ScreenHeaderProps, styles

### Community 110 - "dashboard.ts"
Cohesion: 0.47
Nodes (5): countRows(), DashboardStats, fetchDashboardStats(), fetchSignupsByMonth(), MONTH_LABELS

## Knowledge Gaps
- **366 isolated node(s):** `Resolvido na integração`, `1.1 Escala A/B/C/NV do checklist`, `1.2 Como A/B/C determina Aquisição / Generalização / Manutenção`, `1.3 Faixa etária 61–71 meses (e as outras duas lacunas)`, `1.4 Rebaixamento de faixa` (+361 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **56 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `BottomTabBar.tsx` to `App.tsx`, `ActivityPlanScreen.tsx`, `BottomSheetSelect.tsx`, `mobile/src/screens/LoginScreen.tsx`, `App.tsx`, `HomeScreen.tsx`, `HomeScreen.tsx`, `LoginScreen.tsx`, `FormScreen.tsx`, `plugins`, `HomeScreen.tsx`, `imports`, `react`, `GamesScreen.tsx`, `DashboardScreen.tsx`, `OnboardingLayout.tsx`?**
  _High betweenness centrality (0.159) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `react`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **What connects `Resolvido na integração`, `1.1 Escala A/B/C/NV do checklist`, `1.2 Como A/B/C determina Aquisição / Generalização / Manutenção` to the rest of the system?**
  _366 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `schemas.ts` be split into smaller, more focused modules?**
  _Cohesion score 0.1024390243902439 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.07692307692307693 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._