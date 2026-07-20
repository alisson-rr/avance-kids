# Graph Report - avance-kids-code  (2026-07-20)

## Corpus Check
- 136 files · ~85,059 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 725 nodes · 1758 edges · 70 communities (30 shown, 40 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.71)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2fdb2a1e`
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
- expo
- PerguntasScreen.tsx
- Plano de Implementação do Backend — Avance Kids
- package.json
- devDependencies
- DashboardScreen.tsx
- react-dom
- recharts
- @tiptap/extension-image
- @tiptap/pm
- @expo-google-fonts/mulish
- expo-linear-gradient
- expo-splash-screen
- expo-status-bar
- react
- react-dom
- react-native
- react-native-safe-area-context
- react-native-screens
- react-native-web
- @react-navigation/native-stack
- @supabase/supabase-js
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
- `matchesSearch()` --calls--> `getSkill()`  [EXTRACTED]
  apps/backoffice/src/screens/QuestionCrudScreen.tsx → apps/backoffice/src/constants/aba.ts
- `TriagemScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/TriagemScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `Backoffice HTML Entry Point (index.html)` --references--> `Backoffice Favicon (purple beveled diamond icon)`  [EXTRACTED]
  apps/backoffice/index.html → apps/backoffice/public/favicon.svg
- `RequireAdmin()` --calls--> `useAuth()`  [EXTRACTED]
  apps/backoffice/src/App.tsx → apps/backoffice/src/auth/AuthContext.tsx

## Import Cycles
- None detected.

## Communities (70 total, 40 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.06
Nodes (87): BottomSheetSelect(), BottomSheetSelectProps, styles, Button(), ButtonProps, styles, Checkbox(), CheckboxProps (+79 more)

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
Cohesion: 0.21
Nodes (10): columns, FETCHERS, filters, matchesSearch(), QuestionCrudScreen(), QuestionCrudScreenProps, QuestionKind, savePergunta() (+2 more)

### Community 9 - "App.tsx"
Cohesion: 0.06
Nodes (64): QuestionScreenLayout(), QuestionScreenLayoutProps, styles, supabase, ActivityHistoryScreen(), ActivityPlanScreen(), planDescription(), styles (+56 more)

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.21
Nodes (23): AccessPlan, supabase, supabaseAnonKey, supabaseUrl, AdminRow, ArticleRow, saveArtigo(), ExerciseRow (+15 more)

### Community 11 - "package.json"
Cohesion: 0.20
Nodes (9): main, name, private, scripts, android, ios, start, web (+1 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.21
Nodes (14): AgeBracketCode, HabilidadeKey, saveAtividade(), countRows(), fetchDashboardStats(), fetchSignupsByMonth(), MONTH_LABELS, fetchPerguntas() (+6 more)

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
Cohesion: 0.18
Nodes (11): RequireAdmin(), useAuth(), AdminLayout(), initialsOf(), navItems, DashboardScreen(), formatCount(), InitialQuestionsScreen() (+3 more)

### Community 20 - "imports"
Cohesion: 0.18
Nodes (11): SkillActivityCard(), SkillActivityCardProps, styles, getSkillColor(), Habilidade, HABILIDADE_STYLES, HabilidadeKey, HABILIDADES (+3 more)

### Community 21 - "react"
Cohesion: 0.22
Nodes (18): ACCESS_PLANS, AGE_BRACKETS, AgeBracket, Atividade, AtividadeStatus, buildProgramaLabel(), EXERCISE_LEVELS, ExerciseLevel (+10 more)

### Community 23 - "GamesScreen.tsx"
Cohesion: 0.27
Nodes (7): columns, filters, GamesScreen(), MEDIA_TYPE_OPTIONS, fetchBrincadeiras(), saveBrincadeira(), toggleArchiveBrincadeira()

### Community 24 - "HomeScreen.tsx"
Cohesion: 0.38
Nodes (6): AuthContext, AuthContextValue, AuthProvider(), CurrentAdmin, loadAdmin(), AdminRole

### Community 26 - "OnboardingLayout.tsx"
Cohesion: 0.06
Nodes (33): App(), Stack, AnimatedSplash(), styles, BottomTabBar(), BottomTabBarProps, styles, CurvedHeader() (+25 more)

### Community 27 - "Backoffice Favicon (purple beveled diamond icon)"
Cohesion: 0.67
Nodes (3): Backoffice HTML Entry Point (index.html), Backoffice Favicon (purple beveled diamond icon), Vite Logo Asset (purple recolor, light/dark parenthesis)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 43 - "AuthContext.tsx"
Cohesion: 0.26
Nodes (8): useEntityList(), AdminUsersScreen(), columns, ROLE_OPTIONS, roleLabel(), fetchAdmins(), saveAdmin(), toggleArchiveAdmin()

### Community 46 - "PerguntasScreen.tsx"
Cohesion: 0.13
Nodes (15): dependencies, lucide-react, react-router-dom, @supabase/supabase-js, @tiptap/extension-link, @tiptap/react, @tiptap/starter-kit, zustand (+7 more)

### Community 48 - "Plano de Implementação do Backend — Avance Kids"
Cohesion: 0.13
Nodes (14): 1. Estado atual, 2. Divergências: schema legado × frontend novo, 3. Decisões de design (assumidas — revisar se discordar), 4. Plano de execução, 5. Pontos em aberto (confirmar com o time), 6. Pré-requisitos operacionais, Fase 1 — Novo schema (migração baseline), Fase 2 — Edge Functions refeitas (+6 more)

### Community 52 - "package.json"
Cohesion: 0.20
Nodes (9): name, private, scripts, build, dev, lint, preview, type (+1 more)

### Community 55 - "devDependencies"
Cohesion: 0.29
Nodes (7): devDependencies, react-native-svg-transformer, @types/react, typescript, @types/react, typescript, react-native-svg-transformer

### Community 57 - "DashboardScreen.tsx"
Cohesion: 0.07
Nodes (37): Badge(), BadgeProps, BadgeVariant, ConfirmDialog(), ConfirmDialogProps, buildPageList(), DataTable(), DataTableColumn (+29 more)

## Knowledge Gaps
- **283 isolated node(s):** `$schema`, `typescript`, `oxc`, `react/rules-of-hooks`, `warn` (+278 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **40 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `App.tsx` to `App.tsx`, `AuthContext.tsx`, `plugins`, `imports`, `imports`, `react`, `HomeScreen.tsx`, `DashboardScreen.tsx`, `OnboardingLayout.tsx`?**
  _High betweenness centrality (0.236) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `OnboardingLayout.tsx`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **What connects `$schema`, `typescript`, `oxc` to the rest of the system?**
  _283 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App.tsx` be split into smaller, more focused modules?**
  _Cohesion score 0.05937031484257871 - nodes in this community are weakly interconnected._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._