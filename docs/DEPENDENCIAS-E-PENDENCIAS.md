# Dependências e pendências

Registro do que **não** foi implementado e por quê. Cada item traz a evidência
no código, para que a decisão possa ser tomada sem reabrir a investigação.

> **Atualizado na branch `integration/pre-client-response`.** O documento nasceu
> em `feat/nonblocking-core-prep`; a integração resolveu parte dos itens e as
> respostas da cliente (28/08/2026 e 07/09/2026) resolveram o bloco 1.2–1.7. O
> status de cada
> um está marcado abaixo.

## Resolvido com as respostas da cliente (migration-11)

Decisões recebidas em 28/08/2026 e implementadas em
`supabase/migrations/20260828120000_migration-11_ajustes_logica_cliente.sql`,
com cenários executáveis em `scripts/test_logica_cliente.sql`.

| Item | Decisão | Onde ficou |
| --- | --- | --- |
| 1.2 A/B/C e os níveis | Toda criança percorre Aquisição → Generalização → Manutenção. A resposta A/B/C **não** escolhe o nível de entrada. | Já era o comportamento; agora tem asserção que falha se um plano começar fora da Aquisição. |
| 1.3 Faixas etárias | F05A = 61–95 meses ("5 a 7 anos"), F06A = 96–143 ("8 a 11 anos"). Os rótulos antigos estavam errados; não há mais lacuna. | `UPDATE age_brackets` + clamp de `resolve_age_bracket` em 143. |
| 1.4 Rebaixamento de faixa | 2 ou mais "A" nos pré-requisitos rebaixam **uma faixa, automaticamente**, sem confirmação, e repetem enquanto o critério se repetir. Piso em F01A. | `children.faixa_id` + `resolve_bracket_after_prerequisites()` + `submit-initial-answers`. |
| 1.5 Tratamento de NV | NV **entra no plano** começando em Aquisição e **não** conta como "nunca". | `calculate_general_age` e `calculate_skill_age` ignoram `nao_observado = true`. |
| 1.6 Contexto da Generalização | Não se pede detalhamento de contexto: bastam **3 dias diferentes**. | `check_exercise_completion` conta dias distintos em `America/Sao_Paulo`; a tela traz um texto fixo, sem campo novo. |

## Resolvido na integração

| Item | O que mudou |
| --- | --- |
| 1.7 Códigos AT | Os 24 programas aparecem como “Brincadeiras educativas”, gratuitos para todo usuário autenticado. Não entram no plano da criança. Implementado na migration-17. |
| 2.1 Plano anual | Removido da `PlansScreen`. Backend já recusava; a tela era o único lugar que ainda oferecia. |
| 2.2 Preço e trial do servidor | Nova function `billing-config`; a tela não tem mais valor escrito no código. |
| 2.3 `accept-terms` no cadastro | Chamado após o signup; se falhar, o gate da 5.3 assume e bloqueia até haver prova. |
| 2.4 Texto real dos termos | `constants/termos.ts` com a transcrição do PDF oficial; versão vem do servidor. |
| 2.5 Exclusão de conta | Fluxo em `SettingsScreen` com dupla confirmação e limpeza de sessão. |
| 2.7 `.env.example` | `STRIPE_PRICE_ANNUAL` fora; aponta `STRIPE_TRIAL_DAYS` e `billing-config`. |
| 4.1 Keystore versionado | Keystore novo, histórico local e remoto purgados e verificados — [SEGURANCA-KEYSTORE.md](SEGURANCA-KEYSTORE.md). |
| 4.2 Tenant crossing | Fechado por FKs compostas (migration-09) + `scripts/test_multi_tenant.sql`. |
| 5.3 Aceite de contas antigas | Gate na entrada do app (`TermsGate`); a prova é a linha em `terms_acceptances`, não um booleano. |

Continuam abertos: **1.8, 1.9, 2.6,
4.3–4.6, 5.1 (CPF da criança) e 5.2**. A lista das perguntas que faltam para a
cliente está na [seção 6](#6-perguntas-em-aberto-para-a-cliente).

---

## 1. Bloqueado por decisão da cliente

### 1.1 Escala A/B/C/NV do checklist — ✅ perguntas oficiais importadas

O checklist oficial usa quatro respostas — **A** (nunca/raramente, 1 em 5),
**B** (pouca frequência, 2–3 em 5), **C** (muito frequentemente, 4–5 em 5) e
**NV** (não verificado). O banco usa uma escala de três valores numéricos
(`0/1/2`) mais um booleano `nao_observado`.

- Escala do banco: `supabase/functions/_shared/schemas.ts:29-35`
  (`valor_numerico` 0–2, `nao_observado`)
- Escala oficial: coluna "Registro de Dados (detalhado)" da planilha e as
  tabelas do `.docx`

**Mapeamento definido** (a partir da própria frequência da planilha, e da
resposta da cliente sobre NV):

| Checklist | Frequência | `valor_numerico` | `nao_observado` |
| --- | --- | --- | --- |
| A | quase nunca — ~1 em 5 | 0 | `false` |
| B | às vezes — ~2 a 3 em 5 | 1 | `false` |
| C | quase sempre — ~4 a 5 em 5 | 2 | `false` |
| NV | não verifiquei | 0 (ignorado) | `true` |

O contrato do banco não mudou: `AnswerItemSchema` continua aceitando 0–2 mais o
booleano. O que mudou é o **peso** do NV — ver 1.5. Os rótulos exibidos ao
responsável estão em `apps/mobile/src/services/questions.ts` (`QUESTION_OPTIONS`).

**Fonte oficial recebida em 07/09/2026:**
`AvanceKids-DOCUMENTACAO/LOGICA-ATUALIZADA/2026.08.18_Logica App para exercícios.docx`.
O importador validou 150 perguntas: 24 iniciais e 126 de triagem, com 25 por
faixa. A migration-16 arquiva o conteúdo genérico anterior e insere as perguntas
oficiais sem apagar respostas históricas.

### 1.2 Como A/B/C determina Aquisição / Generalização / Manutenção — ✅ resolvido

**Resposta da cliente:** toda criança percorre os três níveis na ordem
Aquisição → Generalização → Manutenção. A resposta A/B/C do checklist **não**
define o nível de entrada; ela alimenta a idade da habilidade e, por
consequência, a faixa de conteúdo — nunca o ponto de partida na trilha.

Nada no código usava A/B/C para escolher nível — foi conferido em
`generate-activity-plan` (ordena por `nivel`, depois `ordem`) e em
`check_exercise_completion` (avança aquisicao → generalizacao → manutencao). A
mudança foi **travar** o comportamento, não reescrevê-lo:

- `scripts/test_logica_cliente.sql` seção 3 falha se, em alguma combinação
  (habilidade, faixa), a primeira atividade que uma conta consegue abrir não
  for de aquisição — que é a condição sob a qual `generate-activity-plan`
  produz um plano começando em Aquisição. Conferido que o teste quebra quando
  as aquisições de uma faixa são marcadas como premium.
- `scripts/test_logica_cliente.sql` seção 4 prova a travessia completa:
  Aquisição concluída libera a Generalização do mesmo código, e a Manutenção
  não abre antes disso.

**Continua em aberto (menor):** se a ordem é *por código* (A→G→M do código 1,
depois o código 2 — comportamento atual, ver 3.1) ou *por faixa* (todos os
códigos em Aquisição antes de qualquer Generalização). Mantido o comportamento
atual; ver [seção 6](#6-perguntas-em-aberto-para-a-cliente).

### 1.3 Faixa etária 61–71 meses (e as outras duas lacunas) — ✅ resolvido

**Resposta da cliente:** os rótulos "6 a 8 anos" e "9 a 12 anos" estavam
errados. As faixas corretas, em meses:

| Código | Rótulo | `meses_min` | `meses_max` | Antes |
| --- | --- | --- | --- | --- |
| F01A | 12 a 24 meses | 12 | 24 | igual |
| F02A | 25 a 36 meses | 25 | 36 | igual |
| F03A | 37 a 48 meses | 37 | 48 | igual |
| F04A | 49 a 60 meses | 49 | 60 | igual |
| F05A | **5 a 7 anos** | **61** | **95** | 72–96, rótulo "6 a 8 anos" |
| F06A | **8 a 11 anos** | **96** | **143** | 108–144, rótulo "9 a 12 anos" |

Com isso as seis faixas ficam **contíguas de 12 a 143 meses**: as lacunas de
61–71 e 97–107 deixam de existir, e não há mais idade que dependa do ramo de
fallback.

O clamp de `resolve_age_bracket` passou de `LEAST(144, ...)` para
`LEAST(143, ...)`. Sem isso, uma criança de 12 anos exatos entraria com 144,
não casaria com nenhuma faixa e cairia no ramo de lacuna — devolveria F06A por
acidente, por um caminho que só existe para dados quebrados. O espelho no app
(`apps/mobile/src/services/catalog.ts`) foi ajustado junto.

Nenhuma linha de conteúdo mudou de faixa: `questions`, `exercises` e
`child_skill_ages` referenciam a faixa por `id`, não por meses.

A asserção de `scripts/validate_migrations.sh` continua travada — agora nos
limites novos — e `scripts/test_logica_cliente.sql` confere 12, 24, 25, 36, 37,
48, 49, 60, 61, 71, 95, 96 e 143 meses, mais o clamp nas duas pontas.

### 1.4 Rebaixamento de faixa — ✅ resolvido

**Resposta da cliente:** o rebaixamento é **automático**, sem perguntar ao
responsável, e pode descer mais de uma faixa se o critério se repetir.

Regra implementada: nas perguntas de pré-requisito da faixa
(`questions.kind = 'inicial'`), **2 ou mais respostas "A"** — `valor_numerico = 0`
com `nao_observado = false` — descem uma faixa. Aplicados os pré-requisitos da
faixa nova, se o critério se repetir, desce de novo. **F01A é o piso.**

O que precisou existir antes da regra: `children` não tinha coluna de faixa. A
faixa era recalculada da data de nascimento em dois lugares, então qualquer
rebaixamento se perdia no carregamento seguinte do app. Agora:

- `children.faixa_id` (migration-11) é a fonte única da faixa de pré-requisitos.
  `NULL` significa "nunca avaliada", e só nesse caso o app calcula pela idade.
- `resolve_bracket_after_prerequisites(child, faixa)` concentra a regra no
  banco — uma implementação só, testável em SQL puro.
- `submit-initial-answers` grava a faixa resultante e devolve ao app
  `faixa_atual`, `rebaixou` e `proxima_faixa`.
- `PerguntasScreen` recarrega os pré-requisitos da faixa nova com um aviso
  informativo (sem botão de recusar) e não repete a mesma faixa duas vezes.
  `PerguntasScreen` e `TriagemScreen` leem `children.faixa_id` quando existe.

**NV não conta** para os dois "A": não é evidência de falha (ver 1.5).

O rebaixamento silencioso por lacuna descrito antes **deixou de existir**: sem
lacunas (1.3), nenhuma idade entre 12 e 143 meses cai na faixa anterior.

### 1.5 Tratamento de NV — ✅ resolvido

**Resposta da cliente:** a habilidade marcada como NV **entra no plano**,
começando em Aquisição. Não fica de fora.

O problema concreto era outro, e vinha junto: NV era gravado como
`valor_numerico = 0` com `nao_observado = true`, ou seja, era **idêntico a
"quase nunca"** em qualquer média. Uma habilidade que o responsável apenas não
teve chance de observar rebaixava a idade da criança — e portanto a faixa de
conteúdo — sem nenhuma evidência de falha.

`calculate_general_age` e `calculate_skill_age` passaram a **excluir da média**
as respostas com `nao_observado = true`. Quando todas são NV, `AVG` volta `NULL`
e o ramo que já existia devolve a idade base sem regressão — que é exatamente o
comportamento pedido: a habilidade entra no plano pela faixa da criança,
começando em Aquisição.

O contrato de `AnswerItemSchema` não mudou (0–2 + booleano); mudou o peso.
Coberto por `scripts/test_logica_cliente.sql` seção 2, incluindo o contraste com
um "A" observado de verdade, que continua rebaixando.

### 1.6 Definição de contexto da Generalização — ✅ resolvido

**Resposta da cliente:** na Generalização **não se pede detalhamento de
contexto**. Três situações/dias diferentes bastam.

Antes, os três níveis usavam o mesmo critério: `successful_count >= 8` numa
sessão. Agora `check_exercise_completion` trata a Generalização à parte: só
conclui o plano depois de **3 sessões com 8+ acertos em 3 datas distintas**.

Detalhes que sustentam a implementação:

- O dia sai de `(started_at AT TIME ZONE 'America/Sao_Paulo')::date`. Em UTC,
  uma sessão às 22h de sábado viraria domingo e a criança ganharia um dia que
  não existiu. `scripts/test_logica_cliente.sql` tem um caso montado para
  quebrar se alguém trocar por UTC.
- Enquanto faltam dias, a **sessão** é marcada como concluída, o **plano**
  continua `ativo` e a função devolve `false`. Sessão fechada é o que faz
  `start-exercise-session` abrir uma sessão nova no dia seguinte (ele procura
  sessão com `is_completed = false`); plano ativo é o que mantém a atividade na
  tela do responsável.
- **Nenhum campo, tela ou pergunta de "contexto" foi criado.** Na tela do
  exercício de Generalização há um texto fixo explicando os 3 dias
  (`ActivityScreen.tsx`), e ao fechar o dia o app avisa que é preciso voltar em
  outro dia — sem isso o responsável tentaria registrar a 9ª repetição numa
  sessão já encerrada e receberia "sessão inválida".
- Aquisição e Manutenção seguem concluindo com uma sessão.

### 1.7 Códigos de Triagem (AT) — 24 códigos, 72 registros — ✅ expostos como brincadeiras

Os códigos `F01AT001`..`F06AT004` são os "Programas Básicos de Engajamento" da
Triagem Inicial. Eles têm as **mesmas 17 colunas preenchidas** dos demais 126
códigos: é conteúdo completo, e guardar conteúdo não depende de decisão
pedagógica. Na integração foram importados para a tabela `screening_programs`
(migration-10) — 72 registros, fechando os 450 do material oficial.

Não entraram em `exercises` porque há impedimento técnico verificado:

- `exercises.skill_id` é `NOT NULL REFERENCES skills(id)` (`baseline.sql:355`) e
  o catálogo tem exatamente 5 habilidades (`baseline.sql:877-882`), espelhadas
  em `HabilidadeKey` no app. Inserir AT ali obrigaria a inventar a habilidade.
- A coluna `Função` não resolve: `Atenção conjunta` aparece tanto em códigos AC
  (comunicação) quanto AG (cognitiva) no próprio arquivo oficial.
- Toda linha de `exercises` é elegível para `generate-activity-plan`, ou seja, o
  conteúdo entraria no plano da criança sem regra de disparo definida.

`screening_programs` não tem `skill_id`, não tem `plano` e não se liga a
`activity_plans` — checado no harness.

**Resposta da cliente em 07/09/2026:** os programas AT devem aparecer na seção
**“Brincadeiras educativas”** da tela inicial e serão gratuitos para todos, para
fomentar o tráfego no app.

Com isso, eles **não entram em `activity_plans`** e não precisam de habilidade ou
gatilho de triagem. A migration-17 cria um card gratuito por código no feed de
brincadeiras usando o conteúdo de Aquisição como apresentação pública, evitando
72 cards duplicados por etapa. As quatro brincadeiras genéricas do seed foram
arquivadas; conteúdos reais cadastrados no backoffice são preservados.

### 1.8 Quais atividades são premium — ✅ resolvido (controle no backoffice)

**Resposta da cliente:** a marcação tem de ser feita por uma tag no backoffice.

**A tag já existe** e funciona ponta a ponta — não foi preciso escrever código:

- campo **Plano** (Gratuito / Premium) no formulário de atividade —
  `apps/backoffice/src/screens/ActivitiesScreen.tsx:367`
- coluna com selo na listagem — `ActivitiesScreen.tsx:167`
- filtro "Todos os Planos" — `ActivitiesScreen.tsx:252`
- persistido em `exercises.plano` — `services/atividades.ts:92`
- bloqueio real por RLS desde a migration-05: a atividade premium some para
  quem não assina, e a assinatura libera na hora, sem regerar o plano.

As 378 atividades continuam `free`. O que muda a partir de agora é operacional:
a equipe de conteúdo marca no backoffice, atividade por atividade.

> **Uma regra a respeitar ao marcar.** A criança sempre começa em Aquisição
> (D1). Se **todas** as Aquisições de uma mesma habilidade + faixa forem
> marcadas como Premium, a conta gratuita ficaria com a trilha daquela
> habilidade começando em Generalização — o que contraria a decisão. Ou seja:
> **em cada habilidade e faixa, ao menos a primeira Aquisição precisa continuar
> gratuita.**
>
> `scripts/test_logica_cliente.sql` seção 3 pega isso, mas só roda contra o
> banco descartável do harness — ela protege o conteúdo que vem por migration,
> **não** o que for marcado pelo backoffice no banco real. Fechar essa brecha
> significa validar a regra no momento de salvar a atividade (backoffice) ou ao
> gerar o plano; não foi feito porque não foi pedido. Dá meia hora.

### 1.9 Bloqueio de trial após exclusão de conta — ✅ resolvido (fica como está)

**Resposta da cliente:** indiferente; escolher o caminho mais fácil.

O mais fácil é **não bloquear** — que é o comportamento atual e custa zero
linha de código. Quem exclui a conta e cadastra de novo recebe outros 15 dias
de teste.

Por que essa é de fato a opção mais barata, e não só a mais preguiçosa:
bloquear exigiria reconhecer a pessoa **depois** de ela ter apagado os próprios
dados. `account_deletions` guarda `stripe_customer_id` e
`teve_assinatura_paga`, mas quem nunca chegou ao Stripe não tem
`customer_id` — para esses, o único identificador seria o e-mail, que a
exclusão justamente remove. Guardar e-mail (ou hash) de conta excluída para
negar benefício futuro é retenção de dado pessoal com finalidade nova, o que
pede base legal e ajuste nos Termos.

**Consequência aceita:** o teste grátis é repetível por quem excluir e recriar
a conta. Se o abuso aparecer em volume, o caminho menos invasivo é limitar por
método de pagamento no próprio Stripe, não por identidade guardada aqui.

---

## 2. Patches de UI — ✅ aplicados na integração

Esta seção era a lista de pedidos para o agente de UI. Tudo, exceto o item 2.6,
foi aplicado em `integration/pre-client-response`.

| # | Pedido | Onde ficou |
| --- | --- | --- |
| 2.1 | Remover o plano anual | `PlansScreen.tsx` — card único mensal; sem selo, sem estilos e sem labels do anual |
| 2.2 | Preço e trial do servidor | `supabase/functions/billing-config/` + `services/subscription.ts` |
| 2.3 | `accept-terms` no cadastro | `ParentRegisterScreen.tsx` + `services/terms.ts` |
| 2.4 | Texto real dos termos | `constants/termos.ts` + `components/TermsModal.tsx` |
| 2.5 | Exclusão de conta | `SettingsScreen.tsx` + `services/auth.ts` (`deleteAccount`) |
| 2.7 | `.env.example` | `STRIPE_PRICE_ANNUAL` removido |

### 2.6 Campos novos no backoffice — ⬜ aberto

`exercises` ganhou `programa_aba` e `funcao` na migration-08 (as duas colunas da
planilha oficial que não tinham destino). O formulário do backoffice não as
exibe. `screening_programs` (migration-10) também não tem tela — a RLS dela hoje
é só de admin, então o conteúdo dos 24 códigos AT só é visível via SQL.

---

## 3. Consequências conhecidas das mudanças desta branch

### 3.1 O plano da criança fica ~4x maior

Antes: 1 atividade por (habilidade, faixa, nível) = **15 por faixa**.
Agora: 4–5 códigos por (habilidade, faixa), 3 níveis cada = **63 por faixa**.

A regra de recomendação não mudou. Com `ordem` igual nos três níveis do mesmo
código (garantido por asserção em `scripts/validate_migrations.sh`), a
travessia de `check_exercise_completion` fica:

```
A(código 1) → G(código 1) → M(código 1) → A(código 2) → G(código 2) → ...
```

que é o comportamento que a função já implementava — só havia um código por
habilidade, então isso nunca ficou visível.

A resposta da cliente confirmou a ordem A → G → M (ver 1.2), mas **não disse se
é por código ou por faixa**. Mantido o comportamento acima. A alternativa
— todos os códigos em Aquisição, depois todos em Generalização — é mudança de
algoritmo em `check_exercise_completion` e em `generate-activity-plan`. Está na
[seção 6](#6-perguntas-em-aberto-para-a-cliente).

### 3.2 Crianças com plano já gerado

`migration-08` **arquiva** (não apaga) as atividades placeholder ainda
referenciadas por algum `activity_plans`, para não violar FK nem apagar
histórico. Como a RLS esconde atividade arquivada, essas crianças precisam
refazer a triagem para receber o plano oficial — e refazer a triagem apaga o
histórico de sessões por cascata. Em ambiente pré-lançamento é irrelevante;
se houver dados reais, avaliar antes de aplicar.

---

## 4. Riscos levantados (com status)

### 4.1 ✅ Keystore de release e senha versionados no git — resolvido

Keystore novo gerado (RSA 4096, PKCS12, senha aleatória de 32 caracteres, fora
do git), `.gitignore` na raiz cobrindo material de assinatura no monorepo
inteiro e histórico local purgado. O detalhamento — escopo verificado,
procedimento executado e o push forçado que **continua pendente de decisão** —
está em [SEGURANCA-KEYSTORE.md](SEGURANCA-KEYSTORE.md).

O keystore antigo permanece comprometido e não deve assinar nada.

### 4.2 ✅ Tenant crossing em `exercise_sessions` / `exercise_attempts` — resolvido

Fechado pela migration-09 com chaves estrangeiras compostas:

```
exercise_sessions (plan_id, child_id)          -> activity_plans (id, child_id)
exercise_attempts (session_id, plan_id, child_id) -> exercise_sessions (id, plan_id, child_id)
```

Constraint em vez de policy de propósito: as Edge Functions rodam com
`service_role` e ignoram RLS, então uma correção só de RLS deixaria o caminho do
servidor aberto. `scripts/test_multi_tenant.sql` cobre 5 travessias negativas
entre duas contas, o bloqueio sob `service_role`, o fluxo legítimo, a progressão
e a cascata — e foi conferido que o teste falha quando a migration-09 é retirada.

### 4.3 🟠 Bucket `avatars` é público

`baseline.sql:841-848` cria `avatars` com `public = true` e a policy
`"Public read app buckets"` não tem cláusula `TO`. Fotos de crianças ficam
legíveis por qualquer pessoa que tenha a URL, sem login.

**Não corrigido:** tornar o bucket privado quebra `getPublicUrl()` em
`apps/mobile/src/services/storage.ts:24` e exige URL assinada — ou seja,
alteração no app, que está com o outro agente.

### 4.4 🟠 `verify_jwt = false` em 9 functions

Todas validam o usuário no código (`getUser(req)`), então não há brecha aberta
hoje; é a defesa em profundidade que falta. As duas functions novas
(`accept-terms`, `delete-account`) já entram com `verify_jwt = true`.
`handle-stripe-webhook` e `checkout-return` **precisam** continuar `false`.

### 4.5 🟡 Webhook do Stripe sem idempotência por evento

`handle-stripe-webhook` valida a assinatura corretamente e deduplica pagamentos
por `stripe_payment_intent_id` (constraint `uq_payment_intent`), mas não guarda
os `event.id` já processados. Um reenvio do Stripe reexecuta os efeitos
colaterais não-idempotentes.

**Não corrigido:** o webhook é trabalho em andamento vindo da `main`; mexer
nele aqui aumentaria o diff e o risco de conflito.

### 4.6 🟡 `apiVersion` do Stripe não passa em `deno check`

`create-checkout-session`, `create-billing-portal-session` e
`handle-stripe-webhook` passam `apiVersion: "2023-10-16"`, mas os tipos do
`stripe@13.11.0` declaram `LatestApiVersion = "2023-08-16"`. Erro `TS2322` —
só de tipo, sem efeito em runtime, mas trava um typecheck em CI.

```
deno check supabase/functions/create-checkout-session/index.ts
# TS2322: Type '"2023-10-16"' is not assignable to type '"2023-08-16"'.
```

**Não corrigido:** trocar a string muda a versão da API do Stripe usada pelo
checkout em produção. As opções são alinhar as três para `"2023-08-16"` ou
subir o SDK; as duas mexem no comportamento de cobrança. `delete-account` e
`billing-config` (as duas novas) já usam `"2023-08-16"` e passam no check.

> Não foi possível rodar `deno check` nesta máquina: o Deno e o binário do
> Supabase CLI com runtime embutido não estão instalados. O que se sabe sobre
> este item vem da leitura dos tipos do SDK.

---

## 5. Aberto desde a integração

### 5.1 ⬜ CPF da criança — NÃO respondido, continua aberto

**A resposta de 28/08/2026 não tratou deste item.** Nada foi alterado: o campo
não foi removido nem os Termos foram ajustados. A divergência abaixo segue
valendo.

O app coleta CPF da criança (`ChildRegisterScreen.tsx:97`,
`EditChildProfileScreen.tsx:117`), o schema tem `children.cpf`
(`baseline.sql:218`) e `RegisterChildSchema` aceita o campo como opcional
(`_shared/schemas.ts:25`). Já `apps/mobile/src/constants/termos.ts` declara
apenas o CPF do **responsável**.

O documento oficial de Termos e Privacidade (17/08/2026), seção 2, lista os
dados da criança como *"Nome ou apelido, data de nascimento, foto de perfil e
informações sensíveis de saúde e desenvolvimento"* — **CPF não aparece**.

Ou seja: há divergência entre o que o app coleta e o que os Termos declaram
coletar. **Nada foi alterado**: nem o campo foi removido, nem os Termos foram
ajustados. As duas saídas mexem em decisão da cliente.

- Remover o CPF da criança: exige migration (`children.cpf`), ajuste do schema
  de validação e das duas telas. Consequência: perde-se um identificador que
  pode ser usado para emissão fiscal ou integração com convênios.
- Manter o CPF: exige alterar os Termos para declará-lo, o que gera nova versão
  do documento em `terms_documents` e novo aceite de todos os usuários.

### 5.2 ⬜ Exportação de relatório — direito previsto nos Termos, sem tela

A seção 9 dos Termos garante ao titular *"Exportar um relatório com as
informações mantidas pela plataforma"*. Não existe esse fluxo no app.

Por instrução explícita, **nenhuma exportação self-service foi criada** nesta
integração. Enquanto não existir, o pedido tem de ser atendido manualmente pelo
e-mail de suporte — que é o que os próprios Termos permitem ("ou através do
e-mail de suporte institucional"), mas depende de alguém executar.

### 5.3 ✅ Aceite dos termos para contas antigas — resolvido

`accept-terms` era chamado só logo após o cadastro, que é onde o checkbox
existe. Dois casos ficavam sem registro auditável: contas criadas **antes** da
migration-06 e cadastros feitos com `auth.email.enable_confirmations = true`
(o signup não devolve sessão e a function exige JWT).

Fechado com um gate na entrada do app — `apps/mobile/src/components/TermsGate.tsx`,
acionado pelo efeito de sessão em `apps/mobile/App.tsx`. Depois da autenticação
e antes de liberar qualquer tela, o app consulta o documento vigente e verifica
se existe linha em `terms_acceptances` para **aquele** documento; se não existe,
bloqueia até o aceite ser gravado por `accept-terms`.

Detalhes que sustentam a decisão:

- A fonte da verdade é `terms_documents` + `terms_acceptances`.
  `profiles.termos_aceitos` continua sendo só flag de UX — nasce `true` no
  cadastro e ninguém o reseta quando uma versão nova passa a vigorar, então
  não serve de sinal.
- O client nunca escolhe versão: compara pelo `id` do documento que o servidor
  declarou vigente.
- Falha de consulta vira estado de erro com "Tentar novamente", nunca
  liberação. A regra está isolada em `apps/mobile/src/services/termsGate.ts`
  justamente para poder ser testada sem React nem rede.
- Não desloga, não exige cadastro novo e não navega — é um `Modal` sobre o
  navigator, então não há ciclo de navegação possível.
- Publicar uma versão nova em `terms_documents` volta a exigir aceite,
  automaticamente.

Pontos que uma revisão adversarial do gate mudou (todos com teste que falha
sem a correção):

- **A consulta do aceite filtra por `user_id` explicitamente.** Delegar o
  escopo à RLS estava errado: `terms_acceptances` tem duas policies permissivas
  de SELECT (a do próprio usuário e a de admin) e policies permissivas se somam
  com OR. Para quem está em `admin_users`, a consulta sem filtro enxergava o
  aceite de outras contas — liberava o app sem aceite nenhum (uma linha) ou
  travava a conta no gate (duas ou mais). O harness prova o fato: como admin,
  2 linhas sem o filtro e 0 com ele.
- **O aceite fixa o documento exibido.** `accept-terms` passou a aceitar
  `document_id` opcional e responder 409 quando ele não é mais o vigente. Sem
  isso, uma versão publicada enquanto a tela estava aberta era gravada como
  consentida sem nunca ter sido lida. No 409 o gate recarrega e mostra o texto
  novo. O client continua sem escolher versão — só afirma o que exibiu.
- **Não dá para aceitar um texto que o app não exibe.** O app só renderiza o
  texto embutido no binário; quando a versão vigente é outra e
  `terms_documents.url` está vazia, o botão de aceite some e a tela pede
  atualização do aplicativo. **Consequência operacional: toda versão nova
  precisa ser publicada com `url` preenchida**, senão quem estiver com build
  antiga fica sem caminho para aceitar.
- **O aceite respeita o sequenciamento.** Uma resposta atrasada não sobrescreve
  mais o estado de outra sessão — antes, um aceite que respondia depois da
  sessão cair reabria o bloqueio para um usuário inexistente (app inutilizável)
  ou liberava para a conta seguinte sem aceite.
- **"Sair da conta" sempre funciona.** `signOut()` passou a limpar a sessão
  local quando o POST /logout falha (era descartado, e o usuário continuava
  logado sem aviso), e o gate zera o próprio estado no `finally` em vez de
  esperar um evento de sessão que pode não vir.
- **Perder a sessão durante o bloqueio leva ao Login** em vez de só esconder o
  gate e deixar as telas autenticadas navegáveis.
- **O gate é overlay, não `Modal`.** O `DialogHost` já monta um `Modal` na
  mesma raiz; no iOS dois Modais irmãos disputam a apresentação do mesmo view
  controller e o segundo pode simplesmente não aparecer — o bloqueio ficaria
  invisível com o app navegável por baixo. O botão voltar do Android passou a
  ser tratado por `BackHandler`.

Cobertura: 19 cenários em `scripts/test_terms_gate.ts` — decisão (A–L) e
sequenciamento do store (M–S), com fakes injetados — e 4 cenários de banco em
`scripts/test_termos_exclusao.sql` (conta antiga sem registro, aceite da
vigente, versão nova com o aceite antigo preservado, e o escopo do admin). Os
dois entram no `scripts/validate_migrations.sh`. Cada correção acima foi
conferida reintroduzindo o defeito e vendo o teste correspondente falhar.

Riscos residuais aceitos conscientemente:

- `loadAll()` (perfil e crianças do próprio usuário) roda em paralelo à
  avaliação, antes da liberação. São dados do próprio titular e o app não fica
  acessível; separar exigiria acoplar o carregamento ao estado do gate.
- A suspensão do gate durante o cadastro é global e só é desfeita ao fim do
  fluxo. Se a chamada de cadastro nunca liquidar, o gate fica desligado até o
  timeout de rede da plataforma — janela curta, que se resolve sozinha, marcada
  com `ponytail:` no código.

---

## 6. Perguntas em aberto para a cliente

Rodada de 28/08/2026 respondida. Sobraram três — as demais viraram as seções
1.8, 1.9 e o modelo de importação.

**1. O CPF da criança deve continuar sendo pedido no cadastro?** *(aguardando)*
O aplicativo pede o CPF da criança, mas o documento de Termos e Privacidade não
menciona esse dado — lista só nome, data de nascimento, foto e informações de
desenvolvimento. Ou o campo sai do aplicativo, ou os Termos passam a declarar o
CPF (e aí todos os usuários precisam aceitar a nova versão do documento).
*Enquanto isso:* nada mudou — o campo continua sendo pedido e os Termos
continuam sem citá-lo.

**2. A criança termina uma atividade por vez, ou uma etapa por vez?**
*(pergunta reformulada — ver explicação abaixo)*
Cada atividade tem três etapas, na ordem: **Aquisição** (aprender a fazer),
**Generalização** (fazer em situações e dias diferentes) e **Manutenção**
(continuar fazendo depois de aprendido). São essas as três etapas confirmadas na
resposta anterior.
A dúvida que sobrou é a ordem entre atividades diferentes da mesma habilidade:

- **Como está hoje:** a criança faz a atividade 1 nas três etapas, do começo ao
  fim, e só então começa a atividade 2.
- **A alternativa:** a criança faz a Aquisição de *todas* as atividades da
  habilidade, depois a Generalização de todas, depois a Manutenção de todas.

*Enquanto isso:* mantido como está hoje — uma atividade por vez, do começo ao
fim.

**3. ✅ Programas Básicos de Engajamento — implementado em 07/09/2026**

Aparecem em **“Brincadeiras educativas”** e são gratuitos para todo usuário
autenticado. O conteúdo continua fora do plano da criança.
