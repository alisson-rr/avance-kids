# Graph Report - avance-kids-code  (2026-07-20)

## Corpus Check
- 136 files · ~84,281 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 727 nodes · 1709 edges · 79 communities (41 shown, 38 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.69)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c0f97d46`
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
- AuthContext.tsx
- useArchivableList.ts
- Checkbox.tsx
- GoogleButton.tsx
- PlansScreen.tsx
- Button.tsx
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
- App.tsx
- lucide-react
- expo
- PerguntasScreen.tsx
- options.ts
- Plano de Implementação do Backend — Avance Kids
- react
- QuestionScreenLayout.tsx
- HomeScreen.tsx
- package.json
- ArticlesScreen.tsx
- QuestionCrudScreen.tsx
- devDependencies
- DashboardScreen.tsx
- react-dom
- recharts
- @tiptap/extension-image
- @tiptap/pm
- expo-font
- @expo-google-fonts/mulish
- expo-linear-gradient
- expo-splash-screen
- expo-status-bar
- @expo/vector-icons
- react
- react-dom
- react-native
- react-native-safe-area-context
- react-native-screens
- react-native-web
- @react-navigation/native-stack
- @supabase/supabase-js
- zustand
- habilidades.ts
- @tiptap/extension-text-align
- expo-image-picker

## God Nodes (most connected - your core abstractions)
1. `react` - 56 edges
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
- `QuestionCrudScreenProps` --references--> `Pergunta`  [EXTRACTED]
  apps/backoffice/src/screens/QuestionCrudScreen.tsx → apps/backoffice/src/types/entities.ts
- `ActivityScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/ActivityScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `HomeScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/HomeScreen.tsx → apps/mobile/src/store/useProfileStore.ts

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Android Adaptive Icon Layer Set** — apps_mobile_assets_android_icon_background, apps_mobile_assets_android_icon_foreground, apps_mobile_assets_android_icon_monochrome, apps_mobile_assets_icon [EXTRACTED 0.85]

## Communities (79 total, 38 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.10
Nodes (54): BottomSheetSelect(), Button(), FormScreen(), GhostButton(), Logo(), styles, PhotoPicker(), PhotoPickerProps (+46 more)

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
Cohesion: 0.09
Nodes (22): backgroundColor, foregroundImage, adaptiveIcon, predictiveBackGestureEnabled, expo, android, icon, ios (+14 more)

### Community 6 - "compilerOptions"
Cohesion: 0.08
Nodes (23): compilerOptions, allowArbitraryExtensions, allowImportingTsExtensions, erasableSyntaxOnly, jsx, lib, module, moduleDetection (+15 more)

### Community 7 - "compilerOptions"
Cohesion: 0.10
Nodes (19): compilerOptions, allowImportingTsExtensions, erasableSyntaxOnly, lib, module, moduleDetection, noEmit, noFallthroughCasesInSwitch (+11 more)

### Community 8 - "BottomTabBar.tsx"
Cohesion: 0.13
Nodes (13): BottomSheetSelectProps, styles, GhostButtonProps, styles, GoogleButton(), GoogleButtonProps, styles, Input() (+5 more)

### Community 9 - "App.tsx"
Cohesion: 0.20
Nodes (6): ImageUploadField(), ImageUploadFieldProps, columns, GamesScreen(), MEDIA_TYPE_OPTIONS, MOCK_BRINCADEIRAS

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.08
Nodes (53): AuthContext, AuthContextValue, AuthProvider(), CurrentAdmin, loadAdmin(), AccessPlan, AgeBracketCode, HabilidadeKey (+45 more)

### Community 11 - "package.json"
Cohesion: 0.20
Nodes (9): main, name, private, scripts, android, ios, start, web (+1 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.21
Nodes (18): ACCESS_PLANS, AGE_BRACKETS, AgeBracket, Atividade, AtividadeStatus, buildProgramaLabel(), EXERCISE_LEVELS, ExerciseLevel (+10 more)

### Community 13 - "TriagemBaseScreen.tsx"
Cohesion: 0.27
Nodes (7): SkillActivityCard(), SkillActivityCardProps, styles, getSkillColor(), styles, planDescription(), styles

### Community 14 - "plugins"
Cohesion: 0.22
Nodes (8): plugins, rules, react/only-export-components, react/rules-of-hooks, $schema, oxc, typescript, warn

### Community 15 - "Android Adaptive Icon - Foreground Layer (blue 'A' chevron mark)"
Cohesion: 0.33
Nodes (6): Android Adaptive Icon - Background Layer (construction guide), Android Adaptive Icon - Foreground Layer (blue 'A' chevron mark), Android Adaptive Icon - Monochrome Layer (gray 'A' chevron mark), Mobile Web Favicon (blue 'A' chevron mark), Mobile App Master Icon (blue 'A' chevron, construction guide), Mobile Splash Icon (gray 'A' chevron mark)

### Community 16 - "tsconfig.json"
Cohesion: 0.40
Nodes (4): compilerOptions, strict, extends, expo/tsconfig.base

### Community 17 - "Backoffice Full Logo (Avance Kids wordmark, blue/green mark)"
Cohesion: 0.67
Nodes (3): Backoffice Full Logo (Avance Kids wordmark, blue/green mark), Backoffice Hero Image (3D purple beveled tile), Mobile Logo + Wordmark (identical to backoffice logo)

### Community 19 - "imports"
Cohesion: 0.24
Nodes (8): RequireAdmin(), useAuth(), AdminLayout(), initialsOf(), navItems, DashboardScreen(), data, LoginScreen()

### Community 20 - "imports"
Cohesion: 0.14
Nodes (21): ActivityScreen(), RESULT_OPTIONS, styles, fetchPlan(), findOpenSession(), registerAttempt(), RegisterAttemptResult, startExerciseSession() (+13 more)

### Community 21 - "AuthContext.tsx"
Cohesion: 0.23
Nodes (10): App(), Stack, AnimatedSplash(), styles, ActivityHistoryScreen(), ActivityPlanScreen(), HabilidadeScreen(), Onboarding1Screen() (+2 more)

### Community 22 - "useArchivableList.ts"
Cohesion: 0.21
Nodes (7): OnboardingLayout(), OnboardingLayoutProps, styles, Onboarding2Screen(), Onboarding3Screen(), *.svg, react

### Community 23 - "Checkbox.tsx"
Cohesion: 0.50
Nodes (3): Checkbox(), CheckboxProps, styles

### Community 24 - "GoogleButton.tsx"
Cohesion: 0.20
Nodes (6): BottomTabBar(), BottomTabBarProps, styles, ContentDetailParams, ContentDetailScreen(), styles

### Community 25 - "PlansScreen.tsx"
Cohesion: 0.28
Nodes (6): FormScreenProps, styles, ScreenHeader(), ScreenHeaderProps, styles, styles

### Community 27 - "Backoffice Favicon (purple beveled diamond icon)"
Cohesion: 0.67
Nodes (3): Backoffice HTML Entry Point (index.html), Backoffice Favicon (purple beveled diamond icon), Vite Logo Asset (purple recolor, light/dark parenthesis)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 42 - "ActivityHistoryScreen.tsx"
Cohesion: 0.18
Nodes (8): Select(), SelectOption, SelectProps, AdminUsersScreen(), columns, MOCK_ADMIN_USERS, ROLE_OPTIONS, roleLabel()

### Community 43 - "App.tsx"
Cohesion: 0.13
Nodes (16): supabase, ChildrenListScreen(), styles, fetchProfile(), listChildren(), RegisterChildInput, CheckoutPlan, createCheckoutSession() (+8 more)

### Community 46 - "PerguntasScreen.tsx"
Cohesion: 0.13
Nodes (15): dependencies, react, react-router-dom, @supabase/supabase-js, @tiptap/extension-link, @tiptap/react, @tiptap/starter-kit, zustand (+7 more)

### Community 47 - "options.ts"
Cohesion: 0.20
Nodes (11): ConfirmDialog(), ConfirmDialogProps, DataTable(), DataTableColumn, DataTableProps, EntityCrudScreen(), EntityCrudScreenProps, EntityFilterConfig (+3 more)

### Community 48 - "Plano de Implementação do Backend — Avance Kids"
Cohesion: 0.13
Nodes (14): 1. Estado atual, 2. Divergências: schema legado × frontend novo, 3. Decisões de design (assumidas — revisar se discordar), 4. Plano de execução, 5. Pontos em aberto (confirmar com o time), 6. Pré-requisitos operacionais, Fase 1 — Novo schema (migração baseline), Fase 2 — Edge Functions refeitas (+6 more)

### Community 49 - "react"
Cohesion: 0.21
Nodes (10): CurvedHeader(), CurvedHeaderProps, styles, styles, TermsModal(), TermsModalProps, SettingsScreen(), styles (+2 more)

### Community 50 - "QuestionScreenLayout.tsx"
Cohesion: 0.20
Nodes (14): QuestionScreenLayout(), OPTION_LABELS, stateStyles, OPTION_LABELS, styles, invokeFunction(), AnswerInput, QUESTION_OPTIONS (+6 more)

### Community 51 - "HomeScreen.tsx"
Cohesion: 0.26
Nodes (9): ActivityCardProps, HomeScreen(), styles, fetchActivityPlans(), fetchArticles(), fetchPlays(), ArticleRow, PlayRow (+1 more)

### Community 52 - "package.json"
Cohesion: 0.20
Nodes (9): name, private, scripts, build, dev, lint, preview, type (+1 more)

### Community 53 - "ArticlesScreen.tsx"
Cohesion: 0.33
Nodes (5): ArticlesScreen(), columns, matchesSearch(), MOCK_ARTIGOS, stripHtml()

### Community 54 - "QuestionCrudScreen.tsx"
Cohesion: 0.16
Nodes (10): InitialQuestionsScreen(), MOCK_PERGUNTAS_INICIAIS, columns, filters, matchesSearch(), QuestionCrudScreen(), QuestionCrudScreenProps, MOCK_PERGUNTAS_TRIAGEM (+2 more)

### Community 55 - "devDependencies"
Cohesion: 0.29
Nodes (7): devDependencies, react-native-svg-transformer, @types/react, typescript, @types/react, typescript, react-native-svg-transformer

### Community 57 - "DashboardScreen.tsx"
Cohesion: 0.16
Nodes (12): Badge(), BadgeProps, BadgeVariant, FormField(), FormFieldProps, RichTextEditor(), RichTextEditorProps, TabItem (+4 more)

### Community 80 - "habilidades.ts"
Cohesion: 0.17
Nodes (17): Habilidade, HABILIDADE_STYLES, HabilidadeKey, HABILIDADES, HabilidadeStyle, MOCK_PERGUNTAS, SKILL_COLORS, PerguntasScreen() (+9 more)

## Knowledge Gaps
- **286 isolated node(s):** `$schema`, `typescript`, `oxc`, `react/rules-of-hooks`, `warn` (+281 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **38 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `useArchivableList.ts` to `App.tsx`, `BottomTabBar.tsx`, `App.tsx`, `HomeScreen.tsx`, `LoginScreen.tsx`, `TriagemBaseScreen.tsx`, `plugins`, `imports`, `imports`, `AuthContext.tsx`, `Checkbox.tsx`, `GoogleButton.tsx`, `PlansScreen.tsx`, `Button.tsx`, `App.tsx`, `options.ts`, `react`, `QuestionScreenLayout.tsx`, `HomeScreen.tsx`, `DashboardScreen.tsx`, `habilidades.ts`?**
  _High betweenness centrality (0.235) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `AuthContext.tsx`?**
  _High betweenness centrality (0.038) - this node is a cross-community bridge._
- **What connects `$schema`, `typescript`, `oxc` to the rest of the system?**
  _286 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App.tsx` be split into smaller, more focused modules?**
  _Cohesion score 0.10359964881474978 - nodes in this community are weakly interconnected._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._