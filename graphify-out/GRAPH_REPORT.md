# Graph Report - avance-kids-code  (2026-07-18)

## Corpus Check
- 83 files · ~81,153 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 435 nodes · 662 edges · 42 communities (28 shown, 14 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 7 edges (avg confidence: 0.61)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e4d18b6c`
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

## God Nodes (most connected - your core abstractions)
1. `react` - 36 edges
2. `theme` - 29 edges
3. `compilerOptions` - 18 edges
4. `compilerOptions` - 15 edges
5. `expo` - 12 edges
6. `useProfileStore` - 11 edges
7. `Button()` - 9 edges
8. `maskCpf()` - 9 edges
9. `maskDate()` - 9 edges
10. `getUser()` - 9 edges

## Surprising Connections (you probably didn't know these)
- `Graphify Knowledge Graph Rules (root CLAUDE.md)` --conceptually_related_to--> `Mobile CLAUDE.md (includes AGENTS.md)`  [INFERRED]
  CLAUDE.md → apps/mobile/CLAUDE.md
- `Backoffice HTML Entry Point (index.html)` --references--> `Backoffice Favicon (purple beveled diamond icon)`  [EXTRACTED]
  apps/backoffice/index.html → apps/backoffice/public/favicon.svg
- `EditChildProfileScreen()` --calls--> `useProfileStore`  [EXTRACTED]
  apps/mobile/src/screens/EditChildProfileScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `EditParentProfileScreen()` --calls--> `useProfileStore`  [EXTRACTED]
  apps/mobile/src/screens/EditParentProfileScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `Backoffice Hero Image (3D purple beveled tile)` --conceptually_related_to--> `Backoffice Full Logo (Avance Kids wordmark, blue/green mark)`  [INFERRED]
  apps/backoffice/src/assets/hero.png → apps/backoffice/public/logo.svg

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Android Adaptive Icon Layer Set** — apps_mobile_assets_android_icon_background, apps_mobile_assets_android_icon_foreground, apps_mobile_assets_android_icon_monochrome, apps_mobile_assets_icon [EXTRACTED 0.85]

## Communities (42 total, 14 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.11
Nodes (36): BottomSheetSelect(), BottomSheetSelectProps, styles, Button(), ButtonProps, styles, Checkbox(), CheckboxProps (+28 more)

### Community 1 - "dependencies"
Cohesion: 0.05
Nodes (43): dependencies, expo, expo-font, @expo-google-fonts/inter, @expo-google-fonts/mulish, expo-image, expo-image-picker, expo-linear-gradient (+35 more)

### Community 2 - "devDependencies"
Cohesion: 0.05
Nodes (37): dependencies, lucide-react, react, react-dom, react-router-dom, recharts, zustand, devDependencies (+29 more)

### Community 3 - "schemas.ts"
Cohesion: 0.16
Nodes (20): stripe, InputSchema, stripe, getServiceClient(), getSupabaseClient(), getUser(), corsHeaders, errorResponse() (+12 more)

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
Cohesion: 0.12
Nodes (13): BottomTabBar(), BottomTabBarProps, styles, ActivityPlanScreen(), MOCK_ACTIVE, MOCK_LOCKED, SKILL_COLORS, styles (+5 more)

### Community 9 - "App.tsx"
Cohesion: 0.14
Nodes (10): AdminLayout(), navItems, ActivitiesScreen(), mockData, CrudScreen(), CrudScreenProps, mockData, DashboardScreen() (+2 more)

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.07
Nodes (28): App(), Stack, ActivityHistoryScreen(), MOCK_HISTORY, SKILL_COLORS, styles, ChangePasswordScreen(), ChildrenListScreen() (+20 more)

### Community 11 - "package.json"
Cohesion: 0.12
Nodes (16): devDependencies, react-native-svg-transformer, @types/react, typescript, @types/react, typescript, main, name (+8 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.18
Nodes (10): GoogleButton(), GoogleButtonProps, styles, Input(), InputProps, styles, Logo(), styles (+2 more)

### Community 13 - "TriagemBaseScreen.tsx"
Cohesion: 0.31
Nodes (8): styles, TriagemBaseScreen(), TriagemBaseScreenProps, HABILIDADE_STYLES, HabilidadeKey, HabilidadeStyle, MOCK_PERGUNTAS, HabilidadeScreen()

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

## Knowledge Gaps
- **220 isolated node(s):** `$schema`, `typescript`, `oxc`, `react/rules-of-hooks`, `warn` (+215 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `App.tsx` to `BottomTabBar.tsx`, `App.tsx`, `HomeScreen.tsx`, `LoginScreen.tsx`, `TriagemBaseScreen.tsx`, `plugins`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `LoginScreen.tsx`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **What connects `$schema`, `typescript`, `oxc` to the rest of the system?**
  _220 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App.tsx` be split into smaller, more focused modules?**
  _Cohesion score 0.11294117647058824 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.046511627906976744 - nodes in this community are weakly interconnected._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.05263157894736842 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._