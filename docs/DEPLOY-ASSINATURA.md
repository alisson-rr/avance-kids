# Deploy da assinatura (Stripe + bloqueio premium)

Passos manuais para colocar no ar as migrations 05-08 e o fluxo de assinatura.
A ordem importa: **banco → secrets → functions → app**.

Assinatura: **mensal apenas, sem plano anual**. Preco e periodo de teste sao
configuracao de servidor (secrets), nunca literais no codigo.

## 1. Banco

```bash
supabase db push
```

Aplica, em ordem:

| Migration | O que faz |
| --- | --- |
| `migration-05_gating_premium` | `has_premium_access()`, policies por `plano`, views `plays_feed`/`articles_feed` |
| `migration-06_termos_auditavel` | `terms_documents` + `terms_acceptances` (trilha de aceite) |
| `migration-07_exclusao_de_conta` | `account_deletions`, `payment_history.user_id` passa a `ON DELETE SET NULL` |
| `migration-08_conteudo_oficial` | 378 atividades oficiais; aposenta o conteudo placeholder |

Antes de aplicar em producao, rode a validacao local (sobe um Postgres
descartavel, aplica tudo e testa aceite/exclusao):

```bash
bash scripts/validate_migrations.sh
```

## 2. Secrets das Edge Functions

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_live_... STRIPE_WEBHOOK_SECRET=whsec_... STRIPE_PRICE_MONTHLY=price_...
```

| Secret | Obrigatorio | Default | O que controla |
| --- | --- | --- | --- |
| `STRIPE_SECRET_KEY` | sim | — | chave da conta Stripe |
| `STRIPE_WEBHOOK_SECRET` | sim | — | validacao da assinatura do webhook |
| `STRIPE_PRICE_MONTHLY` | sim | — | preco da assinatura mensal |
| `STRIPE_TRIAL_DAYS` | nao | `15` | dias de teste gratis; `0` desliga |
| `CHECKOUT_SUCCESS_URL` / `CHECKOUT_CANCEL_URL` | nao | pagina da propria function | retorno do checkout |

O price ID sai de **Stripe → Products** depois de criar o plano mensal com o
valor definitivo. Enquanto nao existir, o app mostra "Plano indisponivel no
momento".

Para mudar o periodo de teste **nao e preciso deploy**, so trocar o secret:

```bash
supabase secrets set STRIPE_TRIAL_DAYS=15
```

`STRIPE_PRICE_ANNUAL` **nao existe mais**: nao ha plano anual. Se o secret
estiver setado na conta, pode ser removido (`supabase secrets unset
STRIPE_PRICE_ANNUAL`).

Opcionais, só quando `avancekids.com.br` estiver no ar — sem eles o retorno
usa a página servida pela própria função `checkout-return`:

```bash
supabase secrets set CHECKOUT_SUCCESS_URL=https://avancekids.com.br/assinatura/sucesso CHECKOUT_CANCEL_URL=https://avancekids.com.br/assinatura/cancelado
```

## 3. Edge Functions

```bash
supabase functions deploy checkout-return create-billing-portal-session create-checkout-session handle-stripe-webhook start-exercise-session generate-activity-plan accept-terms delete-account
```

`accept-terms` e `delete-account` sao novas e estao com `verify_jwt = true` no
`config.toml`: as duas exigem usuario logado sempre.

## 4. Painel do Stripe

1. **Developers → Webhooks → Add endpoint**
   URL: `https://<project-ref>.supabase.co/functions/v1/handle-stripe-webhook`
   Eventos: `checkout.session.completed`, `invoice.paid`,
   `invoice.payment_failed`, `customer.subscription.updated`,
   `customer.subscription.deleted`.
   Copie o signing secret para `STRIPE_WEBHOOK_SECRET`.
2. **Settings → Billing → Customer portal → Activate.**
   Sem isso o botão "Gerenciar assinatura" retorna erro. Habilite cancelar
   assinatura e atualizar forma de pagamento.

## 5. App

`app.json` ganhou `"scheme": "avancekids"` — é configuração nativa, então
precisa de build novo (`npx expo prebuild --clean` + `expo run:android`), não
basta recarregar o bundle.

## 6. Verificação

Com o Stripe em modo teste (cartão `4242 4242 4242 4242`):

- [ ] Assinar → paga → a página de retorno devolve para o app → a tela de planos mostra "Assinatura premium ativa".
- [ ] Marcar uma atividade como **Premium** no backoffice → conta sem assinatura vê o card "Atividade premium"; conta assinante abre normalmente.
- [ ] Marcar um artigo como **Premium** → aparece na Home com cadeado e sem o texto.
- [ ] "Gerenciar assinatura" abre o portal do Stripe e cancela.
- [ ] Depois de cancelar, o conteúdo premium volta a ficar bloqueado.
- [ ] Assinar de novo depois de ter cancelado: o checkout **não** oferece novo teste grátis (o teste é uma vez por conta).
- [ ] Criança que já concluiu todas as atividades gratuitas de uma habilidade: ao assinar, uma atividade premium vira "ativa" sozinha (`unlock_available_plans`).
- [ ] Sem login, `curl "$SUPABASE_URL/rest/v1/plays_feed?select=*" -H "apikey: <anon_key>"` responde vazio ou 401 — nunca a lista de conteúdo.

Hoje **todo o conteúdo do seed está marcado como gratuito**
(`migration-03`), então o cadeado só aparece depois que alguém marcar
conteúdo como Premium no backoffice.

## 7. Aceite dos termos e exclusao de conta

Duas functions novas, ambas exigindo usuario logado:

| Function | Metodo | Body | O que faz |
| --- | --- | --- | --- |
| `accept-terms` | POST | `{}` (ou `{"tipos":["termos_e_privacidade"]}`) | grava usuario + documento + versao + data + IP em `terms_acceptances`. Idempotente. |
| `delete-account` | POST | `{"confirmacao":"EXCLUIR"}` | cancela a assinatura no Stripe, apaga os avatares do Storage, registra em `account_deletions` e remove o usuario do Auth (cascata). |

O documento vigente e semeado pela migration-06 com a versao `2026-08-17`
(data de atualizacao do proprio PDF). Ao publicar uma versao nova:

```sql
UPDATE terms_documents SET vigente = false WHERE tipo = 'termos_e_privacidade';
INSERT INTO terms_documents (tipo, versao, titulo, url, conteudo_hash)
VALUES ('termos_e_privacidade', '<nova-data>', '<titulo>', '<url publica>', '<sha256>');
```

O app volta a pedir o aceite porque nao existe linha em `terms_acceptances`
para o documento novo. Nenhum aceite antigo e alterado.

Verificacao:

- [ ] `accept-terms` chamada duas vezes gera **uma** linha, com o `aceito_em` da primeira.
- [ ] `delete-account` sem `confirmacao` responde 400.
- [ ] Depois de `delete-account`, a assinatura aparece cancelada no Stripe e o arquivo do avatar nao abre mais.
- [ ] `payment_history` do usuario excluido continua existindo, com `user_id` nulo.
