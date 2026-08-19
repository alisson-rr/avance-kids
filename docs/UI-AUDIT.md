# Auditoria de UI/Layout — Avance Kids (mobile)

Branch: `fix/mobile-ui-audit` · Worktree: `C:/tmp/avance-kids-ui-audit` · Data: 19/08/2026
Escopo: `apps/mobile/src/**` + `apps/mobile/App.tsx`. Nada em `supabase/**`, migrations, Edge Functions ou schema foi tocado.

---

## Resumo

| Item | Número |
|---|---|
| Telas auditadas | 23 (todas as rotas do `App.tsx`) |
| Componentes compartilhados auditados | 18 |
| Achados brutos levantados | 221 |
| Achados P0/P1 submetidos a verificação adversarial | 52 |
| Refutados na verificação (falso-positivo) | 3 |
| Rebaixados de P1 para P2 na verificação | 30 |
| **Defeitos distintos após deduplicação** | **73** |
| P0 | 0 |
| P1 | 15 (14 corrigidos · 1 pendente) |
| P2 | 44 (41 corrigidos · 3 pendentes) |
| P3 | 14 (7 corrigidos · 7 pendentes) |
| **Corrigidos** | **62** |
| **Restantes (decisão de produto/design)** | **11** |

Os 221 achados brutos vêm de 11 agentes que auditaram os mesmos arquivos por ângulos diferentes; a
mesma causa raiz aparecia até 4 vezes (o `SafeAreaView` do `FormScreen`, por exemplo). Os 73 acima
são as causas distintas depois de agrupar.

Nenhum P0 sobreviveu à verificação: não há tela impossível de usar. Os P1 são quebras visuais reais em
telas Android de 360dp, sobreposição de controles e um indicador que nunca renderizava.

### Como a auditoria foi feita

1. **Leitura completa** dos 41 arquivos de UI, com 11 agentes de auditoria em paralelo (um por fluxo +
   dois cortes transversais: safe-area/teclado e consistência de componentes).
2. **Verificação adversarial** de cada P0/P1 por um segundo revisor cético, que reabriu o arquivo e
   tentou refutar o achado. Isso derrubou 3 achados e rebaixou 30.
3. **Auditoria visual real**: o app foi executado (Expo Web / react-native-web) e cada tela foi medida
   no DOM (`getBoundingClientRect`) e fotografada em **360x640**, **393x851** e **412x915**, com um
   harness temporário que permitia abrir qualquer tela direto e injetar nome longo de criança/responsável.
   O harness foi removido antes do commit.

### Limitações registradas

- **Android nativo não foi executado.** A máquina não tem Android SDK, `adb` nem emulador
  (`ANDROID_HOME` vazio). A validação visual foi feita no build web. Consequência: `insets.top`/
  `insets.bottom`, teclado nativo, `elevation`/recorte de filhos com `borderRadius` no Android e
  `StatusBar` não puderam ser observados na tela — foram analisados no código e conferidos contra o
  fonte do React Native 0.86 em `node_modules`. **Todas as telas devem ser reconferidas em um
  aparelho Android real antes do lançamento**, em especial: Onboarding, Perguntas/Habilidade,
  Activity (bottom sheet) e todos os formulários com teclado aberto.
- **Telas que dependem de sessão autenticada** (Plano de atividades, Atividade, Histórico, Triagem)
  só puderam ser exercitadas nos estados de *loading* e *erro*: criar conta para logar está fora do
  que posso fazer. Os estados com dados foram validados renderizando os componentes isoladamente
  (`SkillActivityCard`, `QuestionScreenLayout`) com dados de teste.
- **Lint e testes não existem no projeto**: não há configuração de ESLint/Prettier nem framework de
  teste em `apps/mobile`. Validação executada: `tsc --noEmit` e `expo export --platform web`.

### Contexto técnico que orienta várias correções

`apps/mobile/android/gradle.properties` tem `edgeToEdgeEnabled=true` e o tema define
`statusBarColor`/`navigationBarColor` transparentes. No Android isso significa que **as barras do
sistema ficam por cima do conteúdo**. Três consequências aparecem repetidamente abaixo:

- `SafeAreaView` importado de `react-native` é **no-op no Android** (só funciona no iOS);
- `backgroundColor` do `StatusBar` do `react-native` é ignorado;
- rodapés fixos precisam somar `insets.bottom`, que chega a 48dp na navegação por 3 botões.

---

# P1 — Corrigidos

## SkillActivityCard (Plano de atividades e Histórico)

**Problema** — A barra de progresso do card renderizava com **largura 0**: o usuário via só o texto
“45%” e nenhuma barra. Valia para as duas variantes (normal e `compactProgress`).

**Severidade** P1

**Causa** — `progressRow` não tinha largura própria, então o contêiner “abraçava” o conteúdo; o
`progressTrack` com `flex: 1` (flexBasis 0) não tinha espaço livre para crescer e ficava com 0px. Na
variante compacta, `flex: 0` zerava o `flexBasis` e anulava o `width: 60`.

**Correção** — `progressRow` ganhou `flex: 1` + `justifyContent: 'flex-end'`; `progressTrackCompact`
passou a usar `flexGrow/flexShrink/flexBasis` explícitos; `progressFill` usa `height: '100%'` em vez
do hack `height: 7` + `marginTop: -0.5`. Medido no DOM: track 124.4px / fill 56px (45%), track 60 /
fill 48 (80%).

**Arquivos** `src/components/SkillActivityCard.tsx`

**Status** CORRIGIDO — confirmado por medição e screenshot antes/depois.

---

## BottomSheetSelect (Cadastro da criança, Editar criança)

**Problema** — Com 2+ transtornos selecionados, o texto do valor quebrava em 4 linhas e vazava do
pill de 52dp, cobrindo o campo de cima e o checkbox de baixo.

**Severidade** P1

**Causa** — `getDisplayText()` junta os valores com `, ` e o `<Text>` não tinha `numberOfLines`,
dentro de um contêiner de `height: 52` fixa.

**Correção** — `numberOfLines={1}` no texto do valor. Medido: contêiner volta a 52dp de altura.

**Arquivos** `src/components/BottomSheetSelect.tsx`

**Status** CORRIGIDO — confirmado por screenshot antes/depois.

---

## OnboardingLayout (Onboarding 1, 2 e 3)

**Problema** — Em 360x640 a ilustração cobria a saudação (“Olá, Ali…” cortado pela imagem) e o
subtítulo era renderizado **por baixo** do botão “Começar”.

**Severidade** P1

**Causa** — O corpo somava 568dp (ilustração 404 + título + subtítulo) num espaço disponível de
403dp. `body` tinha `flex: 1`, mas os filhos não encolhem (`flexShrink` 0 no RN) e transbordavam a
partir do centro, para cima e para baixo.

**Correção** — O corpo virou `ScrollView` com `contentContainerStyle` `flexGrow: 1` +
`justifyContent: center`: em telas altas continua centralizado, em telas curtas rola. O botão fica
sempre visível, fora do scroll. Também: saudação com `numberOfLines={1}`, alvo do botão voltar de
~38dp para 44x44dp, `lineHeight` de 29/30 para 32 nos textos Mulish 24 (evita corte de acento no
Android).

**Arquivos** `src/components/OnboardingLayout.tsx`

**Status** CORRIGIDO — screenshot antes/depois em 360x640.

---

## ActivityScreen — rodapé fixo por cima da tab bar

**Problema** — O rodapé branco com o botão “Começar” ficava sobreposto à `BottomTabBar`, engolindo
os toques nos ícones “Plano de Atividades” e “Meu perfil”.

**Severidade** P1

**Causa** — `fixedFooter` usava `position: 'absolute'; bottom: 85; zIndex: 40`, com 85 chumbado
“para ficar acima da tab bar”. A altura real da tab bar é `71 + max(insets.bottom, 16)`: 95dp na
navegação por gestos e **119dp na navegação por 3 botões** — 34dp de sobreposição.

**Correção** — O rodapé deixou de ser absoluto e virou filho normal da coluna, entre a `ScrollView`
e a `BottomTabBar`. O `paddingBottom: 120` da ScrollView (que existia só para compensar) caiu para 24.

**Arquivos** `src/screens/ActivityScreen.tsx`

**Status** CORRIGIDO — verificado no código; **reconferir em aparelho Android com 3 botões**.

---

## HomeScreen — larguras fixas do frame de 393dp

**Problema** — Em 360dp as seções vazavam 33dp para fora da tela e o botão “ver todos” era cortado
(o chevron ficava inteiro fora do viewport).

**Severidade** P1

**Causa** — Larguras copiadas do Figma: `section: {width: 393}`, `sectionHeaderContainer: {width: 345}`,
`mainCard: {width: 345}`, `mainCardHeader/profileSection/primaryButton: {width: 297}`.

**Correção** — Todas viraram `width: '100%'` / `alignSelf: 'stretch'` + `marginHorizontal: 24`; o card
principal usa `maxWidth: 345` e `alignItems: 'stretch'` no wrapper (para alinhar com os títulos de
seção em 24dp também nas telas de 412dp). O botão “Acessar” foi de 40 para 48dp de altura, igual ao
componente `Button`.

**Medição antes** `ver todos` em l:299 r:369 (viewport 360) · chevron inteiro em 355..369.
**Medição depois** `ver todos` termina em 318; `overflowX` da tela: 0 elementos.

**Arquivos** `src/screens/HomeScreen.tsx`

**Status** CORRIGIDO — medido em 360x640 e 412x915.

---

## HomeScreen — nome longo estourando o header compacto

**Problema** — Com nome de criança longo, o avatar do header compacto ia parar em **x = −51dp**
(fora da tela pela esquerda) e o nome vazava pelos dois lados.

**Severidade** P1

**Causa** — `compactProfile` é `position: absolute; left: 0; right: 0` com `flexDirection: row`; os
filhos não encolhiam e o nome não tinha `numberOfLines`.

**Correção** — Bloco de textos com `flexShrink: 1` e `numberOfLines={1}` no nome e na idade.

**Arquivos** `src/screens/HomeScreen.tsx`

**Status** CORRIGIDO — `overflowX` zerado na medição.

---

## FormScreen — safe area e teclado (6 telas)

**Problema** — `SafeAreaView` do `react-native` não reserva nada no Android: com edge-to-edge o
header (“Alterar Senha”, “Editar Perfil”, “Editar Criança”) e o topo do conteúdo ficavam por baixo do
relógio/status bar. Além disso, com o teclado aberto o **primeiro toque em “Salvar” era descartado**
(só fechava o teclado), e `behavior="height"` no Android encolhe o layout uma segunda vez, já que o
manifesto declara `windowSoftInputMode="adjustResize"`.

**Severidade** P1 (safe area) / P2 (teclado)

**Causa** — Import errado de `SafeAreaView`; falta de `keyboardShouldPersistTaps`; `behavior` errado
para Android; `paddingBottom: 40` fixo sem `insets.bottom`.

**Correção** — `SafeAreaView` agora vem de `react-native-safe-area-context` com
`edges={['top','bottom']}` (resolve topo e rodapé de uma vez); `keyboardShouldPersistTaps="handled"`
e `keyboardDismissMode="on-drag"` na ScrollView; `behavior={Platform.OS === 'ios' ? 'padding' : undefined}`.

**Telas afetadas** Login, Cadastro do responsável, Cadastrar criança, Alterar senha, Editar perfil,
Editar criança.

**Arquivos** `src/components/FormScreen.tsx`

**Status** CORRIGIDO — **a mudança de `behavior` precisa de conferência em aparelho Android real**
(não pôde ser exercitada no build web).

---

## PlansScreen — safe area, selo recortado e estado de verificação

**Problema** — (a) `SafeAreaView` do `react-native`: header “Meu Plano” por baixo da status bar no
Android. (b) O selo “Mais vantajoso” usava `position: absolute; top: -12` dentro de um card com
`borderRadius: 16` — no Android o card recorta os filhos e o selo aparecia cortado ao meio. (c)
`subscription === null` significava ao mesmo tempo “ainda verificando” e “sem assinatura”: um
assinante via “Assinar agora” por alguns instantes. (d) `paddingBottom: 40` sem `insets.bottom`.

**Severidade** P1

**Correção** — `SafeAreaView` de `react-native-safe-area-context` com `edges={['top','bottom']}`;
selo virou elemento normal no topo do card (`alignSelf: 'flex-start'`), sem risco de recorte; novo
estado `checking` que mostra “Verificando assinatura…” com o botão desabilitado; `paddingBottom`
somando `insets.bottom`. Os cartões ganharam `accessibilityRole="radio"`.

**Arquivos** `src/screens/PlansScreen.tsx`

**Status** CORRIGIDO — screenshot em 360x640.

---

## QuestionScreenLayout — alvo de toque das respostas (Perguntas e Habilidade)

**Problema** — Cada opção de resposta tinha **20dp de altura de toque**, com 40dp de zona morta
entre elas. É a interação principal de toda a avaliação.

**Severidade** P1

**Causa** — `optionRow` sem padding vertical; o espaçamento vinha de `gap: 20` no contêiner e de
`marginTop: 20` no divisor — espaço que não recebe toque.

**Correção** — `paddingVertical: 12` na linha (alvo passa a 44dp), `gap: 0` na lista e divisor sem
margem. Medido depois: alvos de 44 a 59dp.

**Arquivos** `src/components/QuestionScreenLayout.tsx`

**Status** CORRIGIDO — medido no DOM.

---

## GoogleButton — ícone que não renderiza no Android

**Problema** — O logo do Google era um `<Image>` apontando para um **SVG remoto da Wikimedia**. O
`Image` do React Native não decodifica SVG: no Android o botão ficava sem ícone, e ainda dependia de
rede para desenhar um elemento de interface.

**Severidade** P1 (no Android) / P2 no geral

**Correção** — Substituído por `<FontAwesome name="google" />` de `@expo/vector-icons`, dependência
que o projeto já usa. Sem dependência nova, sem rede.

**Arquivos** `src/components/GoogleButton.tsx`

**Status** CORRIGIDO.

---

## TermsModal — botão “Fechar” empurrado para fora

**Problema** — Com o texto real dos termos (longo), o conteúdo do card somaria ~554dp contra um
`maxHeight` de 80% da tela (512dp em 360x640): o botão “Fechar” ficaria cortado. Hoje não aparece
porque o texto é curto (Lorem ipsum).

**Severidade** P1 (latente — dispara no dia em que o texto real entrar)

**Causa** — `modalScrollView` com `maxHeight: 400` fixo brigando com `maxHeight: '80%'` do card; no
RN os filhos não encolhem por padrão.

**Correção** — `maxHeight: 400` trocado por `flexShrink: 1`: a área de texto encolhe e o botão nunca
sai do card.

**Arquivos** `src/components/TermsModal.tsx`

**Status** CORRIGIDO.

---

## TriagemScreen — “Concluir” ativo durante carregamento e após erro

**Problema** — O botão “Concluir” ficava habilitado enquanto a tela carregava e depois de um erro de
carga. Com a lista de habilidades vazia, a checagem de pendências não encontra nada pendente e o
fluxo segue como se a triagem estivesse completa.

**Severidade** P1

**Correção** — `disabled={loading || skills.length === 0}` no botão (o componente `Button` ganhou
estado visual de desabilitado). **Nenhuma regra de triagem foi alterada** — só o estado do controle
na interface. Também: erro de carga agora aparece na tela com botão “Tentar novamente”, em vez de
deixar a tela vazia.

**Arquivos** `src/screens/TriagemScreen.tsx`, `src/components/Button.tsx`

**Status** CORRIGIDO.

---

# P1 — Não corrigido

## TermsModal — texto legal é Lorem ipsum

**Problema** — O modal “Termos de Consentimento”, aberto no cadastro (onde o usuário marca “Concordo
com os Termos”) e no perfil, mostra **Lorem ipsum** como conteúdo legal.

**Severidade** P1

**Causa** — Texto placeholder nunca substituído. O documento real existe no repositório:
`AvanceKids-DOCUMENTACAO/Termos_e_Privacidade_Avance_Kids_Final.pdf`.

**Correção sugerida** — Substituir pelo texto do PDF (ou carregá-lo do banco/URL). O layout do modal
já foi corrigido para suportar texto longo.

**Arquivos** `src/components/TermsModal.tsx`

**Status** PRECISA DE DECISÃO — redigir/colar texto jurídico não é decisão de UI.

---

# P2 — Corrigidos

| # | Tela / componente | Problema | Correção | Arquivo |
|---|---|---|---|---|
| 1 | HomeScreen | Header azul com `paddingTop` chumbado (30dp) em vez do inset real | `paddingTop: Math.max(insets.top, 24)` + `minHeight` | `HomeScreen.tsx` |
| 2 | HomeScreen | Única tela sem declarar `<StatusBar>`, com faixa azul atrás da status bar | `<StatusBar barStyle="light-content" translucent />` | `HomeScreen.tsx` |
| 3 | HomeScreen | Card principal renderiza “Cada conquista de  é um passo…” (buraco) quando não há criança | Texto alternativo + fallback no avatar e no nome | `HomeScreen.tsx` |
| 4 | HomeScreen | Botão voltar do header chama `goBack()` numa tela que é a raiz da pilha — controle morto | Só renderiza se `navigation.canGoBack()` | `HomeScreen.tsx` |
| 5 | HomeScreen / SettingsScreen / ContentDetailScreen | Espaçador de 120dp no fim do scroll “para a tab bar”, mas a tab bar já ocupa espaço próprio | 120 → 24 | 3 arquivos |
| 6 | HomeScreen | Saudação com `left: 36` (fora do grid de 24dp) e nome longo sem limite | `left/right: 24` + `numberOfLines={1}` + `lineHeight` | `HomeScreen.tsx` |
| 7 | CurvedHeader (Perfil, Crianças) | `paddingTop` chumbado; título sem `numberOfLines` nem `flex` | inset real + título com `flex: 1` e 1 linha | `CurvedHeader.tsx` |
| 8 | BottomTabBar | Ícones desalinhados porque “Plano de Atividades” tem rótulo de 2 linhas | `alignItems: 'flex-start'` na barra | `BottomTabBar.tsx` |
| 9 | SkillActivityCard | Card bloqueado com texto `#AAAAAA` sobre branco (2.3:1, ilegível) | `#6B6B6B` | `SkillActivityCard.tsx` |
| 10 | Tags de habilidade (todo o app) | Texto das tags entre 1.5:1 e 3.1:1 de contraste — a tag “Comunicação” sumia | Tons escurecidos da mesma família (ver nota abaixo) | `data/habilidades.ts` |
| 11 | HabilidadeScreen | Barra de progresso das perguntas sem distinção entre cheio e vazio (1.2:1) | Removido `opacity: 0.6` do ativo, inativo de `#F0F0F0` para `#DCDCDC` | `HabilidadeScreen.tsx` |
| 12 | QuestionScreenLayout | Botão de avançar abaixo da dobra em 360dp e indicador de rolagem desligado | Indicador de rolagem ligado | `QuestionScreenLayout.tsx` |
| 13 | QuestionScreenLayout | `paddingBottom` fixo sem `insets.bottom` — navegação por baixo da barra do sistema | soma `insets.bottom` | `QuestionScreenLayout.tsx` |
| 14 | QuestionScreenLayout | Ação principal (“próxima”/“finalizar”) visualmente idêntica à secundária (“anterior”) | Principal em semibold/azul, secundária em cinza | `QuestionScreenLayout.tsx` |
| 15 | QuestionScreenLayout | Alvos de “anterior/próxima” abaixo de 44dp; dois azuis quase iguais (`#02349A`/`#02349C`) | `minHeight: 44` + azul único | `QuestionScreenLayout.tsx` |
| 16 | TriagemScreen | Card de habilidade com `height: 124` fixo — conteúdo cortado quando o nome quebra em 2 linhas | `minHeight: 124` + `numberOfLines={2}` no título | `TriagemScreen.tsx` |
| 17 | TriagemScreen | “Responder depois” com alvo de 27dp | `minHeight: 44` | `TriagemScreen.tsx` |
| 18 | TriagemScreen | Erro de carga deixava a tela vazia, sem mensagem nem forma de tentar de novo | Estado de erro + “Tentar novamente” | `TriagemScreen.tsx` |
| 19 | SettingsScreen | “Sair da conta” com o mesmo estilo dos itens de navegação (ação destrutiva indistinguível) | Cor destrutiva + ícone de saída, sem chevron nem divisor | `SettingsScreen.tsx` |
| 20 | ChildrenListScreen | Sem estado vazio (só o botão de adicionar aparecia) | `ListEmptyComponent` com título e explicação | `ChildrenListScreen.tsx` |
| 21 | ChildrenListScreen | Botão “Adicionar nova criança” com altura derivada de padding (≠ 48dp do `Button`) | `height: 48` | `ChildrenListScreen.tsx` |
| 22 | ChildrenListScreen | Nome longo sem limite de linhas | `numberOfLines={2}` | `ChildrenListScreen.tsx` |
| 23 | ActivityHistoryScreen | Estado vazio como uma linha de texto solta; erro sem ação de recuperação | Estado vazio com título + explicação; erro com “Tentar novamente” | `ActivityHistoryScreen.tsx` |
| 24 | ActivityPlanScreen | “Ver histórico” com alvo de ~17dp colado na borda | `paddingVertical: 12` + `paddingLeft` | `ActivityPlanScreen.tsx` |
| 25 | ContentDetailScreen | Botão voltar com alvo de 24x24dp | 44x44dp | `ContentDetailScreen.tsx` |
| 26 | BottomSheetSelect | O `TouchableOpacity` do fundo envolvia a própria sheet: tocar na alça ou no cabeçalho fechava sem querer | Backdrop separado, absoluto, atrás da sheet | `BottomSheetSelect.tsx` |
| 27 | BottomSheetSelect | Espaçador de rodapé era um `<SafeAreaView />` do `react-native` (no-op no Android) | Removido; o `paddingBottom` da lista já cobre (o `Modal` do RN 0.86 sem `navigationBarTranslucent` **não** passa por baixo da barra de navegação) | `BottomSheetSelect.tsx` |
| 28 | ActivityScreen | Bottom sheet sem altura máxima nem rolagem; toque dentro da sheet fechava a sheet | `maxHeight: '90%'` e `TouchableWithoutFeedback onPress` que bloqueia a propagação | `ActivityScreen.tsx` |
| 29 | PhotoPicker | Permissão negada usava `alert()` nativo, e falha de seleção só ia para o console | `showDialog`/`showError` — o diálogo próprio do app | `PhotoPicker.tsx` |
| 30 | PhotoPicker | Ícone de câmera em `theme.colors.border` (#D5D7DA) sobre #E5E7EB — quase invisível | `theme.colors.textLight` | `PhotoPicker.tsx` |
| 31 | App.tsx | `getSession()` sem `.catch()`: uma falha deixava o app preso na splash para sempre | `.catch()` + `.finally(() => setSessionLoaded(true))` | `App.tsx` |
| 32 | Button (todo o app) | Sem estado visual de desabilitado; `disabled` externo era ignorado | `disabled` respeitado + `opacity: 0.5` + `accessibilityState` | `Button.tsx` |
| 33–41 | Home, Activity, Triagem, ContentDetail, SkillActivityCard | 17 estilos declaravam `fontWeight` junto de `fontFamily` de peso explícito. No Android o `fontFamily` manda: o peso pedido é ignorado ou o texto cai para a fonte do sistema | `fontWeight` removido de todos | 5 arquivos |

**Nota sobre as cores das tags (item 10).** As cores de texto das habilidades foram escurecidas
mantendo a mesma família (ex.: `#FFBE25` → `#8A5A00`, `#9F67FF` → `#6B33CC`). Os fundos coloridos das
faixas (`background`) **não** mudaram. É a única alteração com efeito de marca neste trabalho, feita
porque o texto original era ilegível (1.5:1). Reverter é trivial: um arquivo, `src/data/habilidades.ts`.

---

# P3 — Corrigidos

| Tela / componente | Problema | Correção |
|---|---|---|
| OnboardingLayout | `lineHeight` menor que a caixa natural da Mulish 24 (corta acento no Android) | 29/30 → 32 |
| TriagemScreen / ContentDetailScreen | Mesmo problema em títulos de 24px | `lineHeight` 29 → 30 |
| SkillActivityCard | Barra de progresso com `height: 7` dentro de track de 6 e `marginTop: -0.5` | `height: '100%'` |
| SkillActivityCard | Nome de habilidade longo empurrava a barra de progresso para fora | `flexShrink` no badge + `numberOfLines={1}` |
| SettingsScreen | Nome longo do responsável sem limite | `numberOfLines={2}` |
| QuestionScreenLayout | Título do header (vem do banco) sem `numberOfLines` | `flex: 1` + 1 linha |
| habilidades.ts | Azul de fallback `#3678FD` hardcoded quando existe `theme.colors.primary` | usa o token |

---

# Não corrigidos — precisam de decisão

| # | Tela | Problema | Por que não foi corrigido |
|---|---|---|---|
| 1 | TermsModal | Lorem ipsum como texto legal (P1) | Texto jurídico; o PDF final existe no repositório e precisa ser inserido por quem responde por ele |
| 2 | HomeScreen | Botão “ver todos” nas 3 seções não tem `onPress` — controle morto | Não existe tela de listagem para onde levar. Ou se cria a tela, ou se remove o botão do design |
| 3 | HomeScreen | Seção “Conheça nossa loja” tem 2 cards mockados idênticos, hardcoded, sem imagem e sem ação | É conteúdo, não layout — e a loja provavelmente ainda não existe |
| 4 | HomeScreen | O header curvo é uma cópia literal do componente `CurvedHeader`, com versão animada própria | Unificar é refactor estrutural com risco de regressão na animação; fora do escopo de correção visual |
| 5 | Todo o app | 9 implementações diferentes do mesmo papel (CTA primário azul arredondado), com alturas 40/48/52dp | Já normalizei as alturas para 48 onde era trivial (Home, ChildrenList). Unificar as 9 no componente `Button` é refactor de UI amplo — recomendo fazer, mas em tarefa própria |
| 6 | Todo o app | Dois azuis convivem: `#0E5DFD` (token) e `#3678FD` (headers, links, barras) | Decisão de marca: qual é o azul do app. Depois disso a substituição é mecânica |
| 7 | QuestionScreenLayout | A moldura fixa (faixa colorida + área de imagem de 252dp) consome ~59% da tela em 360x640; a primeira opção nasce no rodapé | Reduzir a ilustração é decisão de design (Figma). Mitiguei com o indicador de rolagem |
| 8 | OnboardingLayout | Ilustração de 404dp é desproporcional em telas de 640dp: o título fica abaixo da dobra | Mesma razão. A quebra grave (sobreposição) foi corrigida; o tamanho da arte é decisão de design |
| 9 | PlansScreen | O CTA “Assinar agora” fica no fim de um scroll longo (título + banner + 2 planos + 5 benefícios) | Um rodapé fixo com o CTA resolveria, mas muda a estrutura da tela de conversão — decisão de produto |
| 10 | LoginScreen | O botão “Fazer login com o Google” abre um diálogo “Em breve” | Botão que promete o que não existe. Ou implementa, ou esconde até implementar |
| 11 | ActivityScreen | Ao retomar uma sessão já com 10 repetições, o sheet mostra “10/10” com todas as barras cheias e ainda pede o registro da repetição; e o botão diz sempre “Começar” mesmo com sessão em andamento | **Área travada** (lógica de sessão/repetições). Registrado, não alterado |

---

# Achados refutados na verificação (não são problema)

Registrados aqui para não voltarem em auditorias futuras:

1. **“Bottom sheets precisam somar `insets.bottom`”** — Falso no Android. O `Modal` do RN 0.86 sem
   `navigationBarTranslucent` chama `disableEdgeToEdge()` (`ReactModalHostView.kt`), então a janela do
   modal **não** passa por baixo da barra de navegação. Somar o inset criaria ~48dp de espaço morto.
   *(Eu mesmo tinha aplicado essa “correção” e a revertí depois da verificação.)*
2. **“`splash.image` está com proporção errada e vai distorcer”** — O plugin `expo-splash-screen` está
   declarado como string simples em `app.json`, sem opções; a configuração de splash usada é a do
   bloco `splash`, com `resizeMode: contain`. Não distorce.
3. **“O `<SafeAreaView />` vazio do BottomSheetSelect quebra o rodapé no Android”** — O componente é
   mesmo no-op no Android, mas o espaçamento efetivo vinha do `paddingBottom` da lista; removê-lo não
   muda nada no Android (no iOS reduz o respiro em ~34dp, aceitável para o alvo Android-first).

---

# Validação executada

| Verificação | Resultado |
|---|---|
| `tsc --noEmit` (strict) | **Passa**, 0 erros |
| `expo export --platform web` | **Passa**, bundle gerado (1.8MB) |
| Lint | **Não configurado no projeto** (sem ESLint/Prettier em `apps/mobile`) |
| Testes | **Não existem** no projeto (sem framework nem arquivos de teste) |
| Execução do app | Expo Web (react-native-web), servidor em `:8081` |
| Medição de layout | `getBoundingClientRect` em 360x640, 393x851 e 412x915 — 0 elementos com transbordo horizontal nas telas corrigidas |
| Screenshots antes/depois | Home, Onboarding 1, galeria de componentes, BottomSheetSelect, Planos, Perfil, Crianças, Alterar senha, Perguntas |
| Android nativo | **Não executado** — sem SDK/emulador na máquina |

---

# Arquivos alterados

```
App.tsx
src/components/BottomSheetSelect.tsx
src/components/BottomTabBar.tsx
src/components/Button.tsx
src/components/CurvedHeader.tsx
src/components/FormScreen.tsx
src/components/GoogleButton.tsx
src/components/OnboardingLayout.tsx
src/components/PhotoPicker.tsx
src/components/QuestionScreenLayout.tsx
src/components/SkillActivityCard.tsx
src/components/TermsModal.tsx
src/data/habilidades.ts
src/screens/ActivityHistoryScreen.tsx
src/screens/ActivityPlanScreen.tsx
src/screens/ActivityScreen.tsx
src/screens/ChildrenListScreen.tsx
src/screens/ContentDetailScreen.tsx
src/screens/HabilidadeScreen.tsx
src/screens/HomeScreen.tsx
src/screens/PlansScreen.tsx
src/screens/SettingsScreen.tsx
src/screens/TriagemScreen.tsx
```

Nenhuma regra de negócio foi alterada: classificação, faixa etária, pré-requisitos, NV,
aquisição/generalização/manutenção, critérios de avanço, lógica de sessão e recomendação de
exercícios estão intocados. As duas mudanças que encostam em comportamento são estados de controle na
interface (botão “Concluir” desabilitado enquanto carrega; botão de assinatura desabilitado enquanto
verifica), sem tocar nas regras por trás.
