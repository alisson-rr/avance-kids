# Dependências e pendências — branch `feat/nonblocking-core-prep`

Registro do que **não** foi implementado nesta branch e por quê. Cada item traz
a evidência no código, para que a decisão possa ser tomada sem reabrir a
investigação.

---

## 1. Bloqueado por decisão da cliente

### 1.1 Escala A/B/C/NV do checklist

O checklist oficial usa quatro respostas — **A** (nunca/raramente, 1 em 5),
**B** (pouca frequência, 2–3 em 5), **C** (muito frequentemente, 4–5 em 5) e
**NV** (não verificado). O banco usa uma escala de três valores numéricos
(`0/1/2`) mais um booleano `nao_observado`.

- Escala do banco: `supabase/functions/_shared/schemas.ts:29-35`
  (`valor_numerico` 0–2, `nao_observado`)
- Escala oficial: coluna "Registro de Dados (detalhado)" da planilha e as
  tabelas do `.docx`

**Pendente:** a correspondência exata A/B/C → `valor_numerico`, e o que NV
significa no cálculo (ignora a pergunta? conta como A? bloqueia o resultado?).

**Consequência de não decidir:** as perguntas do checklist oficial **não foram
importadas**. As 150 perguntas em `questions` continuam sendo o texto genérico
do `migration-03`. As atividades (exercises) foram trocadas pelo conteúdo
oficial porque não dependem dessa escala; as perguntas dependem.

### 1.2 Como A/B/C determina Aquisição / Generalização / Manutenção

O enum `exercise_level` existe e a progressão está implementada, mas nada no
schema diz o que cada nível significa nem qual critério move a criança entre
eles. O único critério codificado é o mesmo para os três níveis:
`successful_count >= 8`.

- `supabase/migrations/20260811000000_migration-05_gating_premium.sql:228`

**Consequência:** `check_exercise_completion` não foi alterada. Com o conteúdo
oficial ela produz a travessia **A → G → M do mesmo código, depois o próximo
código** (ver secção 3.1). Se a intenção pedagógica for outra (todos os códigos
em Aquisição antes de qualquer Generalização, por exemplo), é mudança de
algoritmo.

### 1.3 Faixa etária 61–71 meses (e as outras duas lacunas)

Limites cadastrados hoje (`baseline.sql:868-874`), todos em meses:

| Código | Rótulo | `meses_min` | `meses_max` |
| --- | --- | --- | --- |
| F01A | 12 a 24 meses | 12 | 24 |
| F02A | 25 a 36 meses | 25 | 36 |
| F03A | 37 a 48 meses | 37 | 48 |
| F04A | 49 a 60 meses | 49 | 60 |
| F05A | 6 a 8 anos | 72 | 96 |
| F06A | 9 a 12 anos | 108 | 144 |

Aritmética pura, sem interpretação:

- F01A→F04A são **contíguas**, sem lacuna nem sobreposição.
- **61–71 meses** (5a1m a 5a11m): nenhuma faixa cobre.
- **97–107 meses** (8a1m a 8a11m): nenhuma faixa cobre.
- Acima de 144 meses (12 anos): não há faixa; o código faz *clamp* para 144.

As três situações são **a mesma pergunta**: quando o rótulo diz "a 8 anos", o
limite é o 8º aniversário (96 meses) ou o fim dos 8 anos (107 meses)? A
resposta que resolve 61–71 resolve 97–107 e o teto de 144 junto.

**Nenhum limite foi alterado.** Não existe erro *objetivo* a corrigir: sob a
leitura literal ("a 8 anos" = até 96 meses) o banco está coerente com os
próprios rótulos, e sob a outra leitura os três limites mudam ao mesmo tempo.
Escolher entre as duas é decidir a faixa 61–71. `scripts/validate_migrations.sh`
tem uma asserção que **falha** se alguém alterar as 6 linhas sem essa decisão.

### 1.4 Rebaixamento de faixa

Hoje já existe um rebaixamento silencioso: quando a idade cai numa lacuna,
`resolve_age_bracket` usa a **faixa anterior**.

- `supabase/migrations/20260718000000_baseline.sql:677-702`
- Espelhado no app em `apps/mobile/src/services/catalog.ts:20-34` (duas
  implementações do mesmo algoritmo — unificar depois que a política for
  definida)

Efeito atual: criança de 5a1m–5a11m recebe conteúdo de F04A (4–5 anos);
criança de 8a1m–8a11m recebe conteúdo de F05A (6–8 anos).

**Não alterado.**

### 1.5 Tratamento de NV

`NV` **não existe em lugar nenhum** do repositório — nem coluna, nem enum, nem
constante. O mais próximo é `child_question_answers.nao_observado`, que hoje é
gravado junto com `valor_numerico = 0`, ou seja, NV e "nunca" são o mesmo
número para qualquer cálculo.

- `supabase/functions/_shared/schemas.ts:31-35`

### 1.6 Definição de contexto da Generalização

Nada no schema representa "contexto". A coluna `exercises.brincadeiras` e o
texto oficial de generalização descrevem contextos em prosa, mas não há campo
estruturado. **Não alterado.**

### 1.7 Códigos de Triagem (AT) — 24 códigos, 72 registros

Os códigos `F01AT001`..`F06AT004` são os "Programas Básicos de Engajamento" da
Triagem Inicial. **Não foram importados.** Dois motivos, os dois dependentes da
cliente:

1. A regra de disparo ("marcar NÃO para 2 ou mais itens → iniciar com programas
   básicos") não existe no código e não pode ser inventada.
2. Não dá para derivar a qual das 5 habilidades cada um pertence. A coluna
   `Função` não resolve: `Atenção conjunta` aparece tanto em códigos AC
   (comunicação) quanto em códigos AG (cognitiva) no próprio arquivo oficial.

O importador conta e reporta esses registros a cada execução. Assim que a
cliente definir os dois pontos, basta ajustar `CATEGORIA_SKILL` /
`CATEGORIA_TRIAGEM` em `scripts/import_programas.py` e regerar a migration.

### 1.8 Quais atividades são premium

As 378 atividades oficiais entraram todas como `plano = 'free'` — igual ao seed
anterior, para não mudar o que o assinante recebe. Hoje **nenhuma atividade é
premium**, então o gating de `exercises` (migration-05) não tem o que bloquear.

**Pendente:** decisão comercial de qual conteúdo é pago. É um `UPDATE` em
`exercises.plano`, sem migration de schema.

### 1.9 Bloqueio de trial após exclusão de conta

Excluir a conta apaga `subscriptions`, que é onde mora o marcador anti-reabuso
do teste grátis (`stripe_subscription_id`,
`create-checkout-session/index.ts:55-59`). Ou seja: excluir a conta e cadastrar
de novo devolve 15 dias grátis.

A `delete-account` **registra** `stripe_customer_id` e `teve_assinatura_paga`
em `account_deletions`, então a informação para bloquear existe — mas o
bloqueio **não foi implementado**, porque negar o teste a quem exercitou o
direito de exclusão é decisão de produto e tem leitura jurídica.

---

## 2. Patches pendentes para o agente de UI

Nada em `apps/mobile/src/screens/**` nem `apps/mobile/src/components/**` foi
tocado. Estes pontos precisam de alteração visual para fechar o que o backend
já entrega:

### 2.1 Remover o plano anual da tela de planos

- `apps/mobile/src/screens/PlansScreen.tsx:12` — `useState<'monthly' | 'annual'>('annual')`
  (o **anual vem selecionado por padrão**)
- `apps/mobile/src/screens/PlansScreen.tsx:82-97` — card "Anual", `R$ 299,00/ano`
- `apps/mobile/src/services/subscription.ts:14` — `export type CheckoutPlan = 'monthly' | 'annual'`

**Estado do backend:** `plan` virou opcional e o servidor resolve o preço
mensal sozinho. Enviar `plan: 'monthly'` ou não enviar nada funciona; enviar
`'annual'` recebe 400 com *"No momento a assinatura é apenas mensal."* — erro
explícito de propósito, para não cobrar mensal em quem clicou em anual.

### 2.2 Preço e período do teste vindos do servidor

`PlansScreen.tsx` escreve o valor e o período à mão. Como o preço real está no
Stripe e o trial no secret `STRIPE_TRIAL_DAYS`, a tela pode divergir da
cobrança sem ninguém perceber.

### 2.3 Chamar `accept-terms` no cadastro

Hoje o checkbox de aceite é decorativo: `apps/mobile/src/services/auth.ts:41`
envia `termos_aceitos: true` fixo no metadata do signup, independentemente do
checkbox (`ParentRegisterScreen.tsx:30,41,155`).

**A fazer:** depois do signup (ou no primeiro login com sessão), chamar
`accept-terms`. Sem isso as tabelas novas ficam vazias e a prova de
consentimento continua sendo só o booleano.

### 2.4 Texto real dos termos no modal

`apps/mobile/src/components/TermsModal.tsx` mostra texto de exemplo. O
documento real existe
(`AvanceKids-DOCUMENTACAO/Termos_e_Privacidade_Avance_Kids_Final.pdf`,
versão `2026-08-17`) e já está catalogado em `terms_documents`, com `url` a
preencher no deploy. O app deve ler a versão vigente dessa tabela.

### 2.5 Tela de exclusão de conta

`delete-account` está pronta. Falta o botão (provavelmente em
`SettingsScreen.tsx`), com confirmação, enviando
`{"confirmacao":"EXCLUIR"}` e fazendo logout na resposta.

### 2.6 Campos novos no backoffice

`exercises` ganhou `programa_aba` e `funcao` (as duas colunas da planilha
oficial que não tinham destino). O formulário do backoffice não as exibe.

### 2.7 `apps/mobile/.env.example`

Contém `EXPO_PUBLIC_STRIPE_PRICE_ANNUAL`, que não é mais usado. Arquivo em
alteração pelo outro agente — não tocado aqui.

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
habilidade, então isso nunca ficou visível. Ver 1.2 se a intenção for outra.

### 3.2 Crianças com plano já gerado

`migration-08` **arquiva** (não apaga) as atividades placeholder ainda
referenciadas por algum `activity_plans`, para não violar FK nem apagar
histórico. Como a RLS esconde atividade arquivada, essas crianças precisam
refazer a triagem para receber o plano oficial — e refazer a triagem apaga o
histórico de sessões por cascata. Em ambiente pré-lançamento é irrelevante;
se houver dados reais, avaliar antes de aplicar.

---

## 4. Riscos confirmados que **não** foram corrigidos

### 4.1 🔴 Keystore de release e senha versionados no git

- `apps/mobile/credentials/avancekids-release.keystore` — rastreado desde o
  commit `77a3f5b`
- A senha estava em texto puro em `docs/BUILD-ANDROID.md`

Esta branch remove o arquivo do índice e apaga a senha do documento, mas **o
histórico do git continua com os dois**. Quem tiver acesso ao repositório
consegue assinar um APK como Avance Kids.

**Remediação (irreversível, não aplicada aqui):** gerar keystore novo — o app
ainda não foi publicado, então trocar agora custa zero e depois da publicação
na Play Store deixa de ser possível sem Play App Signing. Detalhes em
`docs/BUILD-ANDROID.md`.

### 4.2 🔴 Tenant crossing em `exercise_sessions` / `exercise_attempts`

A policy de `exercise_attempts` (`baseline.sql:499-510`) valida apenas
`child_id`. As colunas `session_id` e `plan_id` (`baseline.sql:484-485`) são
FKs soltas, sem FK composta, sem trigger e sem CHECK correlacionando-as. Um
usuário autenticado pode registrar tentativas apontando para o `plan_id` de
outra criança e concluir o plano dela.

**Não corrigido de propósito:** a instrução desta branch congela o *session
engine*. A correção é uma policy `WITH CHECK` correlacionando
`session_id`/`plan_id` ao `child_id` do próprio usuário — mudança pequena, mas
dentro da área congelada.

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
subir o SDK; as duas mexem no comportamento de cobrança. `delete-account`
(nova) já usa `"2023-08-16"` e passa no check.
