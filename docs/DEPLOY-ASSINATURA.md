# Deploy da assinatura (Stripe + bloqueio premium)

Passos manuais para colocar no ar a migration-05 e o fluxo de assinatura.
A ordem importa: **banco → secrets → functions → app**. Publicar o app antes
das functions quebra o checkout (o contrato mudou de `price_id` para `plan`).

## 1. Banco

```bash
supabase db push
```

Aplica `20260811000000_migration-05_gating_premium.sql`: a função
`has_premium_access()`, as policies que passam a olhar a coluna `plano` e as
views `plays_feed` / `articles_feed`.

## 2. Secrets das Edge Functions

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_live_... STRIPE_WEBHOOK_SECRET=whsec_... STRIPE_PRICE_MONTHLY=price_... STRIPE_PRICE_ANNUAL=price_...
```

Os price IDs saem de **Stripe → Products** depois de criar os dois planos com
os valores definitivos. Enquanto não existirem, o app mostra "Plano
indisponível no momento".

Opcionais, só quando `avancekids.com.br` estiver no ar — sem eles o retorno
usa a página servida pela própria função `checkout-return`:

```bash
supabase secrets set CHECKOUT_SUCCESS_URL=https://avancekids.com.br/assinatura/sucesso CHECKOUT_CANCEL_URL=https://avancekids.com.br/assinatura/cancelado
```

## 3. Edge Functions

```bash
supabase functions deploy checkout-return create-billing-portal-session create-checkout-session handle-stripe-webhook start-exercise-session generate-activity-plan
```

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
