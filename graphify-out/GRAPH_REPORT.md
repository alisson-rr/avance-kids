# Graph Report - .  (2026-07-18)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 465 nodes · 696 edges · 40 communities (31 shown, 9 thin omitted)
- Extraction: 97% EXTRACTED · 2% INFERRED · 1% AMBIGUOUS · INFERRED: 17 edges (avg confidence: 0.66)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `d14f57e3`
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
- `Cognitiva Domain Avatar (girl, purple shirt with gear icon)` --conceptually_related_to--> `ABA Checklist & Programs Logic Specification`  [INFERRED]
  apps/mobile/assets/Cognitiva.png → AvanceKids-DOCUMENTACAO/extracted_logica.txt
- `Coordenacao/Motora Domain Avatar (boy, orange shirt, footprint icon)` --conceptually_related_to--> `ABA Checklist & Programs Logic Specification`  [INFERRED]
  apps/mobile/assets/Coordenacao.png → AvanceKids-DOCUMENTACAO/extracted_logica.txt
- `Funcional Domain Avatar (girl, pink dress, holding card)` --conceptually_related_to--> `ABA Checklist & Programs Logic Specification`  [INFERRED]
  apps/mobile/assets/Funcional.png → AvanceKids-DOCUMENTACAO/extracted_logica.txt
- `Social Domain Avatar (boy, green shirt, holding emoji cards)` --conceptually_related_to--> `ABA Checklist & Programs Logic Specification`  [INFERRED]
  apps/mobile/assets/Social.png → AvanceKids-DOCUMENTACAO/extracted_logica.txt
- `Comunicacao Domain Avatar (girl, yellow dress, waving)` --conceptually_related_to--> `ABA Checklist & Programs Logic Specification`  [INFERRED]
  apps/mobile/assets/Comunicacao.png → AvanceKids-DOCUMENTACAO/extracted_logica.txt

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **ABA Developmental Domain Avatars & Checklist Structure** — apps_mobile_assets_cognitiva, apps_mobile_assets_comunicacao, apps_mobile_assets_coordenacao, apps_mobile_assets_funcional, apps_mobile_assets_social, avancekids_documentacao_extracted_logica_document [INFERRED 0.70]
- **Android Adaptive Icon Layer Set** — apps_mobile_assets_android_icon_background, apps_mobile_assets_android_icon_foreground, apps_mobile_assets_android_icon_monochrome, apps_mobile_assets_icon [EXTRACTED 0.85]
- **Freemium Feature-Gating Architecture Decision** — avancekids_documentacao_mensagens_relevantes_sobre_a_arquitetura_do_projeto, avancekids_documentacao_mensagens_freemium_model_decision, avancekids_documentacao_mensagens_admin_portal_free_premium_toggle, avancekids_documentacao_extracted_logica_document [INFERRED 0.60]
- **AvanceKids Brand & Marketing Assets** — avancekids_documentacao_imagens_e_logo_logo, avancekids_documentacao_imagens_e_logo_logo_texto, avancekids_documentacao_imagens_e_logo_social, avancekids_documentacao_imagens_e_logo_whisk_20b1a4674d9af4a8ca240956d8cd7412dr_1 [INFERRED 0.55]
- **ABA Therapy Worksheet Documents** — avancekids_documentacao_outros_documentos_3_folha_de_registro_aba, avancekids_documentacao_outros_documentos_5_folha_do_programa_de_pareamento, avancekids_documentacao_outros_documentos_folha_de_registro [AMBIGUOUS 0.40]

## Communities (40 total, 9 thin omitted)

### Community 0 - "App.tsx"
Cohesion: 0.07
Nodes (52): App(), Stack, BottomSheetSelect(), BottomSheetSelectProps, styles, Button(), ButtonProps, styles (+44 more)

### Community 1 - "dependencies"
Cohesion: 0.05
Nodes (43): dependencies, expo, expo-font, @expo-google-fonts/inter, @expo-google-fonts/mulish, expo-image, expo-image-picker, expo-linear-gradient (+35 more)

### Community 2 - "devDependencies"
Cohesion: 0.05
Nodes (37): dependencies, lucide-react, react, react-dom, react-router-dom, recharts, zustand, devDependencies (+29 more)

### Community 3 - "schemas.ts"
Cohesion: 0.16
Nodes (20): stripe, InputSchema, stripe, getServiceClient(), getSupabaseClient(), getUser(), corsHeaders, errorResponse() (+12 more)

### Community 4 - "ABA Checklist & Programs Logic Specification"
Cohesion: 0.08
Nodes (27): Cognitiva Domain Avatar (girl, purple shirt with gear icon), Comunicacao Domain Avatar (girl, yellow dress, waving), Coordenacao/Motora Domain Avatar (boy, orange shirt, footprint icon), Funcional Domain Avatar (girl, pink dress, holding card), Onboarding Screenshot 1 - 'Perguntas Iniciais' Initial Screening Question UI, Onboarding Screenshot 2 - Stacked Question UI Mockups, Social Domain Avatar (boy, green shirt, holding emoji cards), Age-Band Regression Triage Logic (pre-checklist screening) (+19 more)

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
Cohesion: 0.16
Nodes (12): ActivityHistoryScreen(), MOCK_HISTORY, SKILL_COLORS, styles, ChildrenListScreen(), styles, ActivityCardProps, HomeScreen() (+4 more)

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
Cohesion: 0.50
Nodes (4): Backoffice Full Logo (Avance Kids wordmark, blue/green mark), Backoffice Hero Image (3D purple beveled tile), Mobile Logo + Wordmark (identical to backoffice logo), Reduced Logo Icon (blue rounded-square, green pixel mark)

### Community 18 - "AvanceKids Logo (Icon Mark)"
Cohesion: 0.50
Nodes (4): AvanceKids Logo (Icon Mark), AvanceKids Logo with Wordmark, App Mascot Character Holding Phone (Social Promo Image), Illustration of Diverse Children Playing Together

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

### Community 30 - "Folha de Registro - ABA (Registration Sheet)"
Cohesion: 0.67
Nodes (3): Folha de Registro - ABA (Registration Sheet), Folha do Programa de Pareamento (Pairing Program Sheet), Folha de Registro (Registration Sheet, generic)

## Ambiguous Edges - Review These
- `WhatsApp Chat: Project Architecture & Contract Discussion` → `Roadmap Horizontal (PDF, content unextracted/empty)`  [AMBIGUOUS]
  AvanceKids-DOCUMENTACAO/Roadmap_horizontal.pdf · relation: conceptually_related_to
- `WhatsApp Chat: Project Architecture & Contract Discussion` → `Avance Kids Styleguide (PDF, content unextracted/empty)`  [AMBIGUOUS]
  AvanceKids-DOCUMENTACAO/Styleguide Avance Kids.pdf · relation: conceptually_related_to
- `Admin Portal Free/Premium Feature Toggle (descoped from initial proposal)` → `ABA Checklist & Programs Logic Specification`  [AMBIGUOUS]
  AvanceKids-DOCUMENTACAO/Mensagens relevantes sobre a arquitetura do projeto.txt · relation: conceptually_related_to
- `AvanceKids Logo (Icon Mark)` → `App Mascot Character Holding Phone (Social Promo Image)`  [AMBIGUOUS]
  AvanceKids-DOCUMENTACAO/Imagens e logo/Social.png · relation: conceptually_related_to
- `Folha de Registro - ABA (Registration Sheet)` → `Folha de Registro (Registration Sheet, generic)`  [AMBIGUOUS]
  AvanceKids-DOCUMENTACAO/Outros Documentos/3.Folha--de--Registro---ABA.pdf · relation: references
- `Folha de Registro - ABA (Registration Sheet)` → `Folha do Programa de Pareamento (Pairing Program Sheet)`  [AMBIGUOUS]
  AvanceKids-DOCUMENTACAO/Outros Documentos/5.Folha--do--Programa--de--Pareamento.pdf · relation: conceptually_related_to

## Knowledge Gaps
- **231 isolated node(s):** `$schema`, `typescript`, `oxc`, `react/rules-of-hooks`, `warn` (+226 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `WhatsApp Chat: Project Architecture & Contract Discussion` and `Roadmap Horizontal (PDF, content unextracted/empty)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `WhatsApp Chat: Project Architecture & Contract Discussion` and `Avance Kids Styleguide (PDF, content unextracted/empty)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Admin Portal Free/Premium Feature Toggle (descoped from initial proposal)` and `ABA Checklist & Programs Logic Specification`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `AvanceKids Logo (Icon Mark)` and `App Mascot Character Holding Phone (Social Promo Image)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Folha de Registro - ABA (Registration Sheet)` and `Folha de Registro (Registration Sheet, generic)`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **What is the exact relationship between `Folha de Registro - ABA (Registration Sheet)` and `Folha do Programa de Pareamento (Pairing Program Sheet)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **Why does `react` connect `App.tsx` to `BottomTabBar.tsx`, `App.tsx`, `HomeScreen.tsx`, `LoginScreen.tsx`, `TriagemBaseScreen.tsx`, `plugins`?**
  _High betweenness centrality (0.065) - this node is a cross-community bridge._