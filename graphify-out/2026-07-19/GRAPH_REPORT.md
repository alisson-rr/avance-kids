# Graph Report - avance-kids-code  (2026-07-18)

## Corpus Check
- 112 files · ~86,275 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 589 nodes · 1034 edges · 52 communities (38 shown, 14 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.6)
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
- imports
- imports
- imports
- imports
- imports
- imports
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
- Button.tsx
- Onboarding2Screen.tsx
- PerguntasScreen.tsx
- options.ts
- Plano de Implementação do Backend — Avance Kids
- react
- QuestionScreenLayout.tsx
- DashboardScreen.tsx

## God Nodes (most connected - your core abstractions)
1. `react` - 48 edges
2. `theme` - 27 edges
3. `compilerOptions` - 18 edges
4. `compilerOptions` - 15 edges
5. `useProfileStore` - 13 edges
6. `expo` - 12 edges
7. `getUser()` - 10 edges
8. `jsonResponse()` - 10 edges
9. `errorResponse()` - 10 edges
10. `DataTableColumn` - 9 edges

## Surprising Connections (you probably didn't know these)
- `Graphify Knowledge Graph Rules (root CLAUDE.md)` --conceptually_related_to--> `Mobile CLAUDE.md (includes AGENTS.md)`  [INFERRED]
  CLAUDE.md → apps/mobile/CLAUDE.md
- `Backoffice HTML Entry Point (index.html)` --references--> `Backoffice Favicon (purple beveled diamond icon)`  [EXTRACTED]
  apps/backoffice/index.html → apps/backoffice/public/favicon.svg
- `EntityCrudScreenProps` --references--> `DataTableColumn`  [EXTRACTED]
  apps/backoffice/src/components/ui/EntityCrudScreen/EntityCrudScreen.tsx → apps/backoffice/src/components/ui/DataTable/DataTable.tsx
- `matchesSearch()` --calls--> `getSkill()`  [EXTRACTED]
  apps/backoffice/src/screens/QuestionCrudScreen.tsx → apps/backoffice/src/constants/aba.ts
- `ActivitiesScreen()` --calls--> `useArchivableList()`  [EXTRACTED]
  apps/backoffice/src/screens/ActivitiesScreen.tsx → apps/backoffice/src/hooks/useArchivableList.ts

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Android Adaptive Icon Layer Set** — apps_mobile_assets_android_icon_background, apps_mobile_assets_android_icon_foreground, apps_mobile_assets_android_icon_monochrome, apps_mobile_assets_icon [EXTRACTED 0.85]

## Communities (52 total, 14 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.16
Nodes (24): BottomSheetSelect(), BottomSheetSelectProps, styles, FormScreen(), GhostButton(), PhotoPicker(), PhotoPickerProps, styles (+16 more)

### Community 1 - "dependencies"
Cohesion: 0.05
Nodes (43): dependencies, expo, expo-font, @expo-google-fonts/inter, @expo-google-fonts/mulish, expo-image, expo-image-picker, expo-linear-gradient (+35 more)

### Community 2 - "devDependencies"
Cohesion: 0.08
Nodes (24): devDependencies, oxlint, @types/node, @types/react, @types/react-dom, typescript, vite, @vitejs/plugin-react (+16 more)

### Community 3 - "schemas.ts"
Cohesion: 0.14
Nodes (24): stripe, InputSchema, stripe, getServiceClient(), getSupabaseClient(), getUser(), corsHeaders, errorResponse() (+16 more)

### Community 5 - "expo"
Cohesion: 0.08
Nodes (24): backgroundColor, backgroundImage, foregroundImage, monochromeImage, adaptiveIcon, predictiveBackGestureEnabled, expo, android (+16 more)

### Community 6 - "compilerOptions"
Cohesion: 0.08
Nodes (23): compilerOptions, allowArbitraryExtensions, allowImportingTsExtensions, erasableSyntaxOnly, jsx, lib, module, moduleDetection (+15 more)

### Community 7 - "compilerOptions"
Cohesion: 0.10
Nodes (19): compilerOptions, allowImportingTsExtensions, erasableSyntaxOnly, lib, module, moduleDetection, noEmit, noFallthroughCasesInSwitch (+11 more)

### Community 8 - "BottomTabBar.tsx"
Cohesion: 0.17
Nodes (11): Checkbox(), CheckboxProps, styles, CurvedHeader(), CurvedHeaderProps, styles, GhostButtonProps, styles (+3 more)

### Community 9 - "App.tsx"
Cohesion: 0.18
Nodes (7): Select(), SelectOption, SelectProps, columns, GamesScreen(), MEDIA_TYPE_OPTIONS, MOCK_BRINCADEIRAS

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.15
Nodes (19): AccessPlan, AgeBracketCode, HabilidadeKey, InitialQuestionsScreen(), MOCK_PERGUNTAS_INICIAIS, columns, filters, QuestionCrudScreen() (+11 more)

### Community 11 - "package.json"
Cohesion: 0.12
Nodes (16): devDependencies, react-native-svg-transformer, @types/react, typescript, @types/react, typescript, main, name (+8 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.20
Nodes (19): AGE_BRACKETS, AgeBracket, Atividade, AtividadeStatus, buildProgramaLabel(), EXERCISE_LEVELS, ExerciseLevel, getAgeBracket() (+11 more)

### Community 13 - "TriagemBaseScreen.tsx"
Cohesion: 0.08
Nodes (25): BottomTabBar(), BottomTabBarProps, styles, SkillActivityCard(), SkillActivityCardProps, styles, getSkillColor(), Habilidade (+17 more)

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
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/server

### Community 20 - "imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/server

### Community 21 - "imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/server

### Community 22 - "imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/server

### Community 23 - "imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/server

### Community 24 - "imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/server

### Community 25 - "imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/server

### Community 26 - "imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/server

### Community 27 - "Backoffice Favicon (purple beveled diamond icon)"
Cohesion: 0.67
Nodes (3): Backoffice HTML Entry Point (index.html), Backoffice Favicon (purple beveled diamond icon), Vite Logo Asset (purple recolor, light/dark parenthesis)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 42 - "ActivityHistoryScreen.tsx"
Cohesion: 0.10
Nodes (20): Badge(), BadgeProps, BadgeVariant, EntityFilterConfig, FormField(), FormFieldProps, ImageUploadField(), ImageUploadFieldProps (+12 more)

### Community 43 - "App.tsx"
Cohesion: 0.11
Nodes (21): App(), Stack, OnboardingLayout(), OnboardingLayoutProps, styles, ActivityHistoryScreen(), MOCK_HISTORY, styles (+13 more)

### Community 44 - "Button.tsx"
Cohesion: 0.17
Nodes (11): Button(), ButtonProps, styles, FormScreenProps, styles, ScreenHeader(), ScreenHeaderProps, styles (+3 more)

### Community 45 - "Onboarding2Screen.tsx"
Cohesion: 0.25
Nodes (6): AdminUsersScreen(), columns, MOCK_ADMIN_USERS, ROLE_OPTIONS, roleLabel(), AdminRole

### Community 46 - "PerguntasScreen.tsx"
Cohesion: 0.08
Nodes (25): dependencies, lucide-react, react, react-dom, react-router-dom, recharts, @tiptap/extension-image, @tiptap/extension-link (+17 more)

### Community 47 - "options.ts"
Cohesion: 0.21
Nodes (11): ConfirmDialog(), ConfirmDialogProps, DataTable(), DataTableColumn, DataTableProps, EntityCrudScreen(), EntityCrudScreenProps, STATUS_FILTER_OPTIONS (+3 more)

### Community 48 - "Plano de Implementação do Backend — Avance Kids"
Cohesion: 0.13
Nodes (14): 1. Estado atual, 2. Divergências: schema legado × frontend novo, 3. Decisões de design (assumidas — revisar se discordar), 4. Plano de execução, 5. Pontos em aberto (confirmar com o time), 6. Pré-requisitos operacionais, Fase 1 — Novo schema (migração baseline), Fase 2 — Edge Functions refeitas (+6 more)

### Community 49 - "react"
Cohesion: 0.21
Nodes (10): GoogleButton(), GoogleButtonProps, styles, Input(), InputProps, styles, Logo(), styles (+2 more)

### Community 50 - "QuestionScreenLayout.tsx"
Cohesion: 0.33
Nodes (5): QuestionScreenLayout(), QuestionScreenLayoutProps, styles, PerguntasScreen(), QUESTIONS

### Community 57 - "DashboardScreen.tsx"
Cohesion: 0.23
Nodes (7): App(), AdminLayout(), navItems, ArticlesScreen(), DashboardScreen(), data, LoginScreen()

## Knowledge Gaps
- **271 isolated node(s):** `$schema`, `typescript`, `oxc`, `react/rules-of-hooks`, `warn` (+266 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `react` to `App.tsx`, `BottomTabBar.tsx`, `ActivityHistoryScreen.tsx`, `App.tsx`, `LoginScreen.tsx`, `TriagemBaseScreen.tsx`, `plugins`, `options.ts`, `Button.tsx`, `QuestionScreenLayout.tsx`, `DashboardScreen.tsx`?**
  _High betweenness centrality (0.163) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `App.tsx`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **What connects `$schema`, `typescript`, `oxc` to the rest of the system?**
  _271 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.046511627906976744 - nodes in this community are weakly interconnected._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `schemas.ts` be split into smaller, more focused modules?**
  _Cohesion score 0.13813813813813813 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._