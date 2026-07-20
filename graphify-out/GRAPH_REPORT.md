# Graph Report - avance-kids-code  (2026-07-20)

## Corpus Check
- 139 files · ~84,894 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 736 nodes · 1767 edges · 75 communities (33 shown, 42 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.71)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6af34195`
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
- @tiptap/extension-image
- @tiptap/pm
- expo-linear-gradient
- expo-splash-screen
- react
- react-dom
- react-native
- react-native-safe-area-context
- react-native-screens
- react-native-web
- @react-navigation/native-stack
- zustand
- expo-image-picker
- Android Adaptive Icon - Monochrome Layer (gray 'A' chevron mark)
- Mobile Splash Icon (gray 'A' chevron mark)

## God Nodes (most connected - your core abstractions)
1. `react` - 57 edges
2. `theme` - 32 edges
3. `useProfileStore` - 29 edges
4. `errorMessage()` - 27 edges
5. `showError()` - 26 edges
6. `showDialog()` - 22 edges
7. `RecordStatus` - 21 edges
8. `compilerOptions` - 18 edges
9. `compilerOptions` - 15 edges
10. `selectActiveChild()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Graphify Knowledge Graph Rules (root CLAUDE.md)` --conceptually_related_to--> `Mobile CLAUDE.md (includes AGENTS.md)`  [INFERRED]
  CLAUDE.md → apps/mobile/CLAUDE.md
- `CurrentAdmin` --references--> `AdminRole`  [EXTRACTED]
  apps/backoffice/src/auth/AuthContext.tsx → apps/backoffice/src/types/entities.ts
- `matchesSearch()` --calls--> `getSkill()`  [EXTRACTED]
  apps/backoffice/src/screens/QuestionCrudScreen.tsx → apps/backoffice/src/constants/aba.ts
- `ActivitiesScreen()` --indirect_call--> `fetchAtividades()`  [INFERRED]
  apps/backoffice/src/screens/ActivitiesScreen.tsx → apps/backoffice/src/services/atividades.ts
- `QuestionRow` --references--> `RecordStatus`  [EXTRACTED]
  apps/backoffice/src/services/perguntas.ts → apps/backoffice/src/types/common.ts

## Import Cycles
- None detected.

## Communities (75 total, 42 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.07
Nodes (77): BottomSheetSelect(), BottomSheetSelectProps, styles, Button(), ButtonProps, styles, Checkbox(), CheckboxProps (+69 more)

### Community 1 - "dependencies"
Cohesion: 0.15
Nodes (13): dependencies, @expo-google-fonts/inter, expo-image, @expo/metro-runtime, @react-native-async-storage/async-storage, react-native-svg, @react-navigation/native, @expo-google-fonts/inter (+5 more)

### Community 2 - "devDependencies"
Cohesion: 0.13
Nodes (15): devDependencies, oxlint, @types/node, @types/react, @types/react-dom, typescript, vite, @vitejs/plugin-react (+7 more)

### Community 3 - "schemas.ts"
Cohesion: 0.15
Nodes (24): stripe, InputSchema, stripe, getServiceClient(), getSupabaseClient(), getUser(), corsHeaders, errorResponse() (+16 more)

### Community 5 - "expo"
Cohesion: 0.08
Nodes (24): backgroundColor, foregroundImage, adaptiveIcon, package, predictiveBackGestureEnabled, versionCode, expo, android (+16 more)

### Community 6 - "compilerOptions"
Cohesion: 0.08
Nodes (23): compilerOptions, allowArbitraryExtensions, allowImportingTsExtensions, erasableSyntaxOnly, jsx, lib, module, moduleDetection (+15 more)

### Community 7 - "compilerOptions"
Cohesion: 0.10
Nodes (19): compilerOptions, allowImportingTsExtensions, erasableSyntaxOnly, lib, module, moduleDetection, noEmit, noFallthroughCasesInSwitch (+11 more)

### Community 8 - "BottomTabBar.tsx"
Cohesion: 0.18
Nodes (15): ScreenHeader(), ScreenHeaderProps, styles, SkillActivityCard(), SkillActivityCardProps, styles, getSkillColor(), ActivityHistoryScreen() (+7 more)

### Community 9 - "App.tsx"
Cohesion: 0.13
Nodes (24): supabase, ActivityScreen(), RESULT_OPTIONS, styles, fetchPlan(), registerAttempt(), RegisterAttemptResult, startExerciseSession() (+16 more)

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.15
Nodes (19): AgeBracketCode, HabilidadeKey, useEntityList(), columns, FETCHERS, filters, matchesSearch(), QuestionCrudScreen() (+11 more)

### Community 11 - "package.json"
Cohesion: 0.20
Nodes (9): main, name, private, scripts, android, ios, start, web (+1 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.18
Nodes (17): supabase, supabaseAnonKey, supabaseUrl, ArticlesScreen(), columns, filters, matchesSearch(), stripHtml() (+9 more)

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
Cohesion: 0.23
Nodes (17): ACCESS_PLANS, AGE_BRACKETS, AgeBracket, Atividade, AtividadeStatus, buildProgramaLabel(), EXERCISE_LEVELS, ExerciseLevel (+9 more)

### Community 20 - "imports"
Cohesion: 0.25
Nodes (7): Habilidade, HABILIDADE_STYLES, HabilidadeKey, HABILIDADES, HabilidadeStyle, MOCK_PERGUNTAS, SKILL_COLORS

### Community 21 - "react"
Cohesion: 0.11
Nodes (22): App(), Stack, AnimatedSplash(), styles, CurvedHeader(), CurvedHeaderProps, styles, ChildrenListScreen() (+14 more)

### Community 23 - "GamesScreen.tsx"
Cohesion: 0.13
Nodes (27): QuestionScreenLayout(), QuestionScreenLayoutProps, styles, HabilidadeScreen(), OPTION_LABELS, stateStyles, OPTION_LABELS, PerguntasScreen() (+19 more)

### Community 26 - "OnboardingLayout.tsx"
Cohesion: 0.07
Nodes (31): RequireAdmin(), AuthContext, AuthContextValue, AuthProvider(), CurrentAdmin, loadAdmin(), useAuth(), AdminLayout() (+23 more)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 35 - "Backoffice Social/UI Icon Sprite (bluesky, discord, docs, github, social, x)"
Cohesion: 0.23
Nodes (15): AccessPlan, STATUS_FILTER_OPTIONS, StatusFilter, ArticleRow, ExerciseRow, PlayRow, ANSWER_SCALE, MediaType (+7 more)

### Community 44 - "AdminUsersScreen.tsx"
Cohesion: 0.23
Nodes (11): AdminUsersScreen(), columns, ROLE_OPTIONS, roleLabel(), AdminRow, fetchAdmins(), saveAdmin(), toggleArchiveAdmin() (+3 more)

### Community 45 - "expo"
Cohesion: 0.18
Nodes (10): Assinatura, Build Android (APK) — Avance Kids, Gerar o APK, Identidade do app, Instalar no dispositivo, Limite de 260 caracteres no Windows, Notas, Pré-requisitos (já presentes nesta máquina) (+2 more)

### Community 46 - "PerguntasScreen.tsx"
Cohesion: 0.13
Nodes (15): dependencies, lucide-react, react-router-dom, @supabase/supabase-js, @tiptap/extension-link, @tiptap/react, @tiptap/starter-kit, zustand (+7 more)

### Community 47 - "HomeScreen.tsx"
Cohesion: 0.27
Nodes (8): ActivityCardProps, HomeScreen(), styles, fetchArticles(), fetchPlays(), ArticleRow, PlayRow, formatAgeFromIso()

### Community 48 - "Plano de Implementação do Backend — Avance Kids"
Cohesion: 0.13
Nodes (14): 1. Estado atual, 2. Divergências: schema legado × frontend novo, 3. Decisões de design (assumidas — revisar se discordar), 4. Plano de execução, 5. Pontos em aberto (confirmar com o time), 6. Pré-requisitos operacionais, Fase 1 — Novo schema (migração baseline), Fase 2 — Edge Functions refeitas (+6 more)

### Community 49 - "BottomTabBar.tsx"
Cohesion: 0.20
Nodes (6): BottomTabBar(), BottomTabBarProps, styles, ContentDetailParams, ContentDetailScreen(), styles

### Community 51 - "GamesScreen.tsx"
Cohesion: 0.19
Nodes (9): FormField(), FormFieldProps, columns, filters, GamesScreen(), MEDIA_TYPE_OPTIONS, fetchBrincadeiras(), saveBrincadeira() (+1 more)

### Community 52 - "package.json"
Cohesion: 0.20
Nodes (9): name, private, scripts, build, dev, lint, preview, type (+1 more)

### Community 55 - "devDependencies"
Cohesion: 0.29
Nodes (7): devDependencies, react-native-svg-transformer, @types/react, typescript, @types/react, typescript, react-native-svg-transformer

### Community 57 - "DashboardScreen.tsx"
Cohesion: 0.10
Nodes (24): Badge(), BadgeProps, BadgeVariant, ConfirmDialog(), ConfirmDialogProps, buildPageList(), DataTable(), DataTableColumn (+16 more)

## Knowledge Gaps
- **292 isolated node(s):** `rewrites`, `Pré-requisitos (já presentes nesta máquina)`, `Identidade do app`, `Assinatura`, `Limite de 260 caracteres no Windows` (+287 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **42 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `OnboardingLayout.tsx` to `App.tsx`, `Backoffice Social/UI Icon Sprite (bluesky, discord, docs, github, social, x)`, `BottomTabBar.tsx`, `App.tsx`, `HomeScreen.tsx`, `plugins`, `HomeScreen.tsx`, `BottomTabBar.tsx`, `GamesScreen.tsx`, `imports`, `react`, `GamesScreen.tsx`, `DashboardScreen.tsx`?**
  _High betweenness centrality (0.229) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `react`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **What connects `rewrites`, `Pré-requisitos (já presentes nesta máquina)`, `Identidade do app` to the rest of the system?**
  _292 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App.tsx` be split into smaller, more focused modules?**
  _Cohesion score 0.06529602132114982 - nodes in this community are weakly interconnected._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._