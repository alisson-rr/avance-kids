# Graph Report - avance-kids-code  (2026-07-20)

## Corpus Check
- 139 files · ~85,655 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 738 nodes · 1769 edges · 72 communities (31 shown, 41 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.71)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b79e4033`
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
- HomeScreen.tsx
- Plano de Implementação do Backend — Avance Kids
- BottomTabBar.tsx
- recharts
- package.json
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
- `ActivityScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/ActivityScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `HabilidadeScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/HabilidadeScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `HomeScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/HomeScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `PerguntasScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/PerguntasScreen.tsx → apps/mobile/src/store/useProfileStore.ts

## Import Cycles
- None detected.

## Communities (72 total, 41 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.08
Nodes (64): BottomSheetSelect(), BottomSheetSelectProps, styles, Button(), ButtonProps, styles, FormScreen(), GhostButton() (+56 more)

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
Cohesion: 0.33
Nodes (9): ActivityHistoryScreen(), styles, ActivityPlanScreen(), planDescription(), styles, fetchActivityPlans(), findOpenSession(), successRate() (+1 more)

### Community 9 - "App.tsx"
Cohesion: 0.27
Nodes (13): ActivityScreen(), RESULT_OPTIONS, styles, fetchPlan(), generateActivityPlan(), registerAttempt(), RegisterAttemptResult, startExerciseSession() (+5 more)

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.05
Nodes (93): AuthContext, AuthContextValue, AuthProvider(), CurrentAdmin, loadAdmin(), EntityCrudScreen(), ACCESS_PLANS, AccessPlan (+85 more)

### Community 11 - "package.json"
Cohesion: 0.20
Nodes (9): main, name, private, scripts, android, ios, start, web (+1 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.13
Nodes (15): Checkbox(), CheckboxProps, styles, FormScreenProps, styles, GoogleButton(), GoogleButtonProps, styles (+7 more)

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
Cohesion: 0.36
Nodes (10): PerguntasScreen(), styles, TriagemScreen(), fetchAgeBrackets(), fetchSkills(), resolveBracketForMonths(), fetchQuestions(), fetchScreeningAnsweredCounts() (+2 more)

### Community 20 - "imports"
Cohesion: 0.18
Nodes (11): SkillActivityCard(), SkillActivityCardProps, styles, getSkillColor(), Habilidade, HABILIDADE_STYLES, HabilidadeKey, HABILIDADES (+3 more)

### Community 21 - "react"
Cohesion: 0.07
Nodes (31): App(), Stack, AnimatedSplash(), styles, CurvedHeader(), CurvedHeaderProps, styles, OnboardingLayout() (+23 more)

### Community 23 - "GamesScreen.tsx"
Cohesion: 0.16
Nodes (16): QuestionScreenLayout(), QuestionScreenLayoutProps, styles, HabilidadeScreen(), OPTION_LABELS, stateStyles, OPTION_LABELS, styles (+8 more)

### Community 26 - "OnboardingLayout.tsx"
Cohesion: 0.39
Nodes (7): DashboardScreen(), formatCount(), countRows(), DashboardStats, fetchDashboardStats(), fetchSignupsByMonth(), MONTH_LABELS

### Community 27 - "Backoffice Favicon (purple beveled diamond icon)"
Cohesion: 0.67
Nodes (3): Backoffice HTML Entry Point (index.html), Backoffice Favicon (purple beveled diamond icon), Vite Logo Asset (purple recolor, light/dark parenthesis)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 45 - "expo"
Cohesion: 0.18
Nodes (10): Assinatura, Build Android (APK) — Avance Kids, Gerar o APK, Identidade do app, Instalar no dispositivo, Limite de 260 caracteres no Windows, Notas, Pré-requisitos (já presentes nesta máquina) (+2 more)

### Community 46 - "PerguntasScreen.tsx"
Cohesion: 0.13
Nodes (15): dependencies, lucide-react, react-router-dom, @supabase/supabase-js, @tiptap/extension-link, @tiptap/react, @tiptap/starter-kit, zustand (+7 more)

### Community 47 - "HomeScreen.tsx"
Cohesion: 0.14
Nodes (16): ActivityCardProps, HomeScreen(), styles, fetchArticles(), fetchPlays(), AgeBracketRow, ArticleRow, ExerciseLevel (+8 more)

### Community 48 - "Plano de Implementação do Backend — Avance Kids"
Cohesion: 0.13
Nodes (14): 1. Estado atual, 2. Divergências: schema legado × frontend novo, 3. Decisões de design (assumidas — revisar se discordar), 4. Plano de execução, 5. Pontos em aberto (confirmar com o time), 6. Pré-requisitos operacionais, Fase 1 — Novo schema (migração baseline), Fase 2 — Edge Functions refeitas (+6 more)

### Community 49 - "BottomTabBar.tsx"
Cohesion: 0.20
Nodes (6): BottomTabBar(), BottomTabBarProps, styles, ContentDetailParams, ContentDetailScreen(), styles

### Community 52 - "package.json"
Cohesion: 0.20
Nodes (9): name, private, scripts, build, dev, lint, preview, type (+1 more)

### Community 55 - "devDependencies"
Cohesion: 0.29
Nodes (7): devDependencies, react-native-svg-transformer, @types/react, typescript, @types/react, typescript, react-native-svg-transformer

### Community 57 - "DashboardScreen.tsx"
Cohesion: 0.06
Nodes (38): RequireAdmin(), useAuth(), AdminLayout(), initialsOf(), navItems, Badge(), BadgeProps, BadgeVariant (+30 more)

## Knowledge Gaps
- **293 isolated node(s):** `rewrites`, `Pré-requisitos (já presentes nesta máquina)`, `Identidade do app`, `Assinatura`, `Limite de 260 caracteres no Windows` (+288 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **41 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `DashboardScreen.tsx` to `App.tsx`, `BottomTabBar.tsx`, `App.tsx`, `HomeScreen.tsx`, `LoginScreen.tsx`, `plugins`, `HomeScreen.tsx`, `BottomTabBar.tsx`, `imports`, `imports`, `react`, `GamesScreen.tsx`, `OnboardingLayout.tsx`?**
  _High betweenness centrality (0.227) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `react`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **What connects `rewrites`, `Pré-requisitos (já presentes nesta máquina)`, `Identidade do app` to the rest of the system?**
  _293 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App.tsx` be split into smaller, more focused modules?**
  _Cohesion score 0.08126169473402833 - nodes in this community are weakly interconnected._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._