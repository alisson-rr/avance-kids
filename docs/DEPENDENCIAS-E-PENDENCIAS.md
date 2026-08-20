# Dependências e pendências

Registro do que **não** foi implementado e por quê. Cada item traz a evidência
no código, para que a decisão possa ser tomada sem reabrir a investigação.

> **Atualizado na branch `integration/pre-client-response`.** O documento nasceu
> em `feat/nonblocking-core-prep`; a integração resolveu parte dos itens. O
> status de cada um está marcado abaixo.

## Resolvido na integração

| Item | O que mudou |
| --- | --- |
| 1.7 Códigos AT | Importados para `screening_programs` (migration-10). Conteúdo existe; regra de uso continua pendente. |
| 2.1 Plano anual | Removido da `PlansScreen`. Backend já recusava; a tela era o único lugar que ainda oferecia. |
| 2.2 Preço e trial do servidor | Nova function `billing-config`; a tela não tem mais valor escrito no código. |
| 2.3 `accept-terms` no cadastro | Chamado após o signup; se falhar, o gate da 5.3 assume e bloqueia até haver prova. |
| 2.4 Texto real dos termos | `constants/termos.ts` com a transcrição do PDF oficial; versão vem do servidor. |
| 2.5 Exclusão de conta | Fluxo em `SettingsScreen` com dupla confirmação e limpeza de sessão. |
| 2.7 `.env.example` | `STRIPE_PRICE_ANNUAL` fora; aponta `STRIPE_TRIAL_DAYS` e `billing-config`. |
| 4.1 Keystore versionado | Keystore novo, histórico local e remoto purgados e verificados — [SEGURANCA-KEYSTORE.md](SEGURANCA-KEYSTORE.md). |
| 4.2 Tenant crossing | Fechado por FKs compostas (migration-09) + `scripts/test_multi_tenant.sql`. |
| 5.3 Aceite de contas antigas | Gate na entrada do app (`TermsGate`); a prova é a linha em `terms_acceptances`, não um booleano. |

Continuam abertos: **1.1–1.6, 1.8, 1.9, 2.6, 4.3–4.6, 5.1 e 5.2**.

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

### 1.7 Códigos de Triagem (AT) — 24 códigos, 72 registros — ✅ conteúdo importado

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

**Continua pendente da cliente:** a regra de disparo ("marcar NÃO para 2 ou mais
itens → iniciar com programas básicos") e a habilidade de cada código. Quando
existirem, o vínculo entra em uma migration nova; nada precisa ser reimportado.

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
habilidade, então isso nunca ficou visível. Ver 1.2 se a intenção for outra.

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

### 5.1 ⬜ CPF da criança — aguardando a cliente

O app coleta CPF da criança (`ChildRegisterScreen.tsx:97`,
`EditChildProfileScreen.tsx:117`), o schema tem `children.cpf`
(`baseline.sql:218`) e `RegisterChildSchema` aceita o campo como opcional
(`_shared/schemas.ts:25`).

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
