# Graph Report - avance-kids-code  (2026-07-20)

## Corpus Check
- 136 files · ~84,302 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 719 nodes · 1538 edges · 91 communities (38 shown, 53 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.71)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8706d746`
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
- api.ts
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
- FormScreen.tsx
- expo
- PerguntasScreen.tsx
- options.ts
- Plano de Implementação do Backend — Avance Kids
- react
- BottomTabBar.tsx
- Select.tsx
- package.json
- ArticlesScreen.tsx
- QuestionCrudScreen.tsx
- devDependencies
- Checkbox.tsx
- DashboardScreen.tsx
- GhostButton.tsx
- react-dom
- recharts
- @tiptap/extension-image
- @tiptap/pm
- GoogleButton.tsx
- expo-font
- Input.tsx
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
- PhotoPicker.tsx
- QuestionScreenLayout.tsx
- @tiptap/extension-text-align
- expo-image-picker
- ConfirmDialog.tsx
- AnimatedSplash.tsx
- options.ts
- cors.ts
- Android Adaptive Icon - Monochrome Layer (gray 'A' chevron mark)
- Mobile Splash Icon (gray 'A' chevron mark)

## God Nodes (most connected - your core abstractions)
1. `react` - 57 edges
2. `useProfileStore` - 29 edges
3. `errorMessage()` - 27 edges
4. `showError()` - 26 edges
5. `showDialog()` - 22 edges
6. `RecordStatus` - 21 edges
7. `compilerOptions` - 18 edges
8. `selectActiveChild()` - 15 edges
9. `compilerOptions` - 15 edges
10. `EditChildProfileScreen()` - 14 edges

## Surprising Connections (you probably didn't know these)
- `Graphify Knowledge Graph Rules (root CLAUDE.md)` --conceptually_related_to--> `Mobile CLAUDE.md (includes AGENTS.md)`  [INFERRED]
  CLAUDE.md → apps/mobile/CLAUDE.md
- `HabilidadeScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/HabilidadeScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `HomeScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/HomeScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `PerguntasScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/PerguntasScreen.tsx → apps/mobile/src/store/useProfileStore.ts
- `TriagemScreen()` --indirect_call--> `selectActiveChild()`  [INFERRED]
  apps/mobile/src/screens/TriagemScreen.tsx → apps/mobile/src/store/useProfileStore.ts

## Import Cycles
- None detected.

## Communities (91 total, 53 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.25
Nodes (24): SolidInput(), SolidInputProps, styles, ChildRegisterScreen(), styles, EditChildProfileScreen(), styles, EditParentProfileScreen() (+16 more)

### Community 1 - "dependencies"
Cohesion: 0.15
Nodes (13): dependencies, @expo-google-fonts/inter, expo-image, @expo/metro-runtime, @react-native-async-storage/async-storage, react-native-svg, @react-navigation/native, @expo-google-fonts/inter (+5 more)

### Community 2 - "devDependencies"
Cohesion: 0.13
Nodes (15): devDependencies, oxlint, @types/node, @types/react, @types/react-dom, typescript, vite, @vitejs/plugin-react (+7 more)

### Community 3 - "schemas.ts"
Cohesion: 0.15
Nodes (23): stripe, InputSchema, stripe, getServiceClient(), getSupabaseClient(), getUser(), errorResponse(), jsonResponse() (+15 more)

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
Cohesion: 0.39
Nodes (7): DashboardScreen(), formatCount(), countRows(), DashboardStats, fetchDashboardStats(), fetchSignupsByMonth(), MONTH_LABELS

### Community 9 - "App.tsx"
Cohesion: 0.15
Nodes (23): HabilidadeScreen(), OPTION_LABELS, stateStyles, OPTION_LABELS, PerguntasScreen(), styles, styles, TriagemScreen() (+15 more)

### Community 10 - "HomeScreen.tsx"
Cohesion: 0.06
Nodes (86): EntityCrudScreen(), EntityCrudScreenProps, EntityFilterConfig, ACCESS_PLANS, AccessPlan, AGE_BRACKETS, AgeBracket, AgeBracketCode (+78 more)

### Community 11 - "package.json"
Cohesion: 0.20
Nodes (9): main, name, private, scripts, android, ios, start, web (+1 more)

### Community 12 - "LoginScreen.tsx"
Cohesion: 0.18
Nodes (11): ChildrenListScreen(), styles, fetchProfile(), listChildren(), RegisterChildInput, Child, EMPTY_STATE, ProfileStore (+3 more)

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
Cohesion: 0.25
Nodes (8): RequireAdmin(), useAuth(), AdminLayout(), initialsOf(), navItems, InitialQuestionsScreen(), LoginScreen(), TriageQuestionsScreen()

### Community 20 - "imports"
Cohesion: 0.12
Nodes (29): ActivityHistoryScreen(), styles, ActivityPlanScreen(), planDescription(), styles, ActivityScreen(), RESULT_OPTIONS, styles (+21 more)

### Community 21 - "react"
Cohesion: 0.15
Nodes (6): ImageUploadFieldProps, RichTextEditorProps, Logo(), styles, *.svg, react

### Community 22 - "errorMessage"
Cohesion: 0.31
Nodes (10): ChangePasswordScreen(), styles, LoginScreen(), styles, errorMessage(), changePassword(), ParentSignUpInput, resetPassword() (+2 more)

### Community 23 - "api.ts"
Cohesion: 0.29
Nodes (8): supabase, PlansScreen(), styles, CheckoutPlan, createCheckoutSession(), fetchSubscription(), PRICE_IDS, SubscriptionRow

### Community 24 - "HomeScreen.tsx"
Cohesion: 0.27
Nodes (8): ActivityCardProps, HomeScreen(), styles, fetchArticles(), fetchPlays(), ArticleRow, PlayRow, formatAgeFromIso()

### Community 25 - "theme.ts"
Cohesion: 0.24
Nodes (5): BottomSheetSelectProps, styles, CurvedHeaderProps, styles, theme

### Community 26 - "OnboardingLayout.tsx"
Cohesion: 0.27
Nodes (4): OnboardingLayout(), OnboardingLayoutProps, styles, Onboarding1Screen()

### Community 27 - "Backoffice Favicon (purple beveled diamond icon)"
Cohesion: 0.67
Nodes (3): Backoffice HTML Entry Point (index.html), Backoffice Favicon (purple beveled diamond icon), Vite Logo Asset (purple recolor, light/dark parenthesis)

### Community 29 - "Mobile CLAUDE.md (includes AGENTS.md)"
Cohesion: 0.67
Nodes (3): Mobile AGENTS.md: Expo v57 Version Warning, Mobile CLAUDE.md (includes AGENTS.md), Graphify Knowledge Graph Rules (root CLAUDE.md)

### Community 42 - "ActivityHistoryScreen.tsx"
Cohesion: 0.31
Nodes (7): styles, TermsModal(), TermsModalProps, SettingsScreen(), styles, signOut(), showConfirm()

### Community 43 - "AuthContext.tsx"
Cohesion: 0.32
Nodes (7): AuthContext, AuthContextValue, AuthProvider(), CurrentAdmin, loadAdmin(), AdminRow, AdminRole

### Community 44 - "FormScreen.tsx"
Cohesion: 0.29
Nodes (5): FormScreenProps, styles, ScreenHeader(), ScreenHeaderProps, styles

### Community 46 - "PerguntasScreen.tsx"
Cohesion: 0.13
Nodes (15): dependencies, lucide-react, react-router-dom, @supabase/supabase-js, @tiptap/extension-link, @tiptap/react, @tiptap/starter-kit, zustand (+7 more)

### Community 48 - "Plano de Implementação do Backend — Avance Kids"
Cohesion: 0.13
Nodes (14): 1. Estado atual, 2. Divergências: schema legado × frontend novo, 3. Decisões de design (assumidas — revisar se discordar), 4. Plano de execução, 5. Pontos em aberto (confirmar com o time), 6. Pré-requisitos operacionais, Fase 1 — Novo schema (migração baseline), Fase 2 — Edge Functions refeitas (+6 more)

### Community 49 - "react"
Cohesion: 0.15
Nodes (13): App(), Stack, ContentDetailParams, ContentDetailScreen(), styles, DialogButton, DialogHost(), DialogOptions (+5 more)

### Community 52 - "package.json"
Cohesion: 0.20
Nodes (9): name, private, scripts, build, dev, lint, preview, type (+1 more)

### Community 55 - "devDependencies"
Cohesion: 0.29
Nodes (7): devDependencies, react-native-svg-transformer, @types/react, typescript, @types/react, typescript, react-native-svg-transformer

### Community 57 - "DashboardScreen.tsx"
Cohesion: 0.20
Nodes (6): Badge(), BadgeProps, BadgeVariant, FormField(), FormFieldProps, CURRENT_ADMIN

### Community 65 - "Input.tsx"
Cohesion: 0.50
Nodes (3): Input(), InputProps, styles

### Community 80 - "habilidades.ts"
Cohesion: 0.18
Nodes (11): SkillActivityCard(), SkillActivityCardProps, styles, getSkillColor(), Habilidade, HABILIDADE_STYLES, HabilidadeKey, HABILIDADES (+3 more)

### Community 82 - "QuestionScreenLayout.tsx"
Cohesion: 0.50
Nodes (3): QuestionScreenLayout(), QuestionScreenLayoutProps, styles

## Knowledge Gaps
- **287 isolated node(s):** `name`, `private`, `version`, `type`, `dev` (+282 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **53 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `react` to `App.tsx`, `BottomTabBar.tsx`, `App.tsx`, `HomeScreen.tsx`, `LoginScreen.tsx`, `plugins`, `imports`, `imports`, `errorMessage`, `api.ts`, `HomeScreen.tsx`, `theme.ts`, `OnboardingLayout.tsx`, `ActivityHistoryScreen.tsx`, `AuthContext.tsx`, `FormScreen.tsx`, `options.ts`, `react`, `BottomTabBar.tsx`, `QuestionCrudScreen.tsx`, `Checkbox.tsx`, `DashboardScreen.tsx`, `GhostButton.tsx`, `GoogleButton.tsx`, `Input.tsx`, `habilidades.ts`, `PhotoPicker.tsx`, `QuestionScreenLayout.tsx`, `AnimatedSplash.tsx`?**
  _High betweenness centrality (0.274) - this node is a cross-community bridge._
- **Why does `expo-splash-screen` connect `expo` to `react`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **What connects `name`, `private`, `version` to the rest of the system?**
  _287 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `schemas.ts` be split into smaller, more focused modules?**
  _Cohesion score 0.1495798319327731 - nodes in this community are weakly interconnected._
- **Should `expo` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._