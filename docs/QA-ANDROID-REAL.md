# QA em Android real

Nada deste checklist foi executado. O SDK Android não está instalado na máquina
de desenvolvimento (`apps/mobile/android/local.properties` aponta para um
caminho que não existe mais), então até aqui só foi possível gerar o bundle com
`expo export --platform android`. Bundle que empacota **não** é app que
funciona: tudo abaixo continua sem verificação.

Executar quando houver SDK e um aparelho.

## Preparação

```bash
cd apps/mobile && npx expo run:android --variant release
```

- Aparelho de referência: **360 × 640 dp** (o menor comum em Android). Se só
  houver aparelho grande, use um emulador nesse tamanho — vários itens abaixo só
  falham em tela pequena.
- Backend apontando para o projeto Supabase de teste, não o de produção.
- Stripe em modo de teste (cartão `4242 4242 4242 4242`).
- Duas contas: uma criada durante o teste e uma "antiga" (preparada no item 6).

Marque cada item com o aparelho na mão. Item não executado fica em branco — não
marque por dedução.

## Layout e entrada

| # | O que fazer | Passa quando |
|---|---|---|
| 1 | Percorrer as telas de onboarding (Onboarding1 → Perguntas → Onboarding2 → Triagem → Onboarding3) | Nenhum texto cortado, nenhum botão fora da tela, nada exige zoom |
| 2 | Conferir topo e base em todas as telas, com e sem barra de gestos | Conteúdo nunca fica sob a status bar nem sob a barra de navegação do sistema |
| 3 | Abrir cada formulário e tocar no último campo | O teclado não cobre o campo em foco nem o botão de envio; dá para rolar até eles |
| 4 | Rolar Home, Plano, Histórico e Configurações até o fim | Sem corte, sem sobreposição, sem rolagem horizontal indevida |
| 5 | Tocar em ícones pequenos: voltar, fechar modal, checkbox, itens do menu | Todo alvo é acertável de primeira; nenhum menor que ~44 dp |

## Termos

| # | O que fazer | Passa quando |
|---|---|---|
| 6 | Criar conta com o checkbox de termos marcado | Cadastro conclui e vai para o cadastro da criança **sem** pedir os termos de novo |
| 7 | Confirmar no banco: `select * from terms_acceptances where user_id = '<novo usuário>'` | Existe 1 linha, com `versao`, `aceito_em` e `ip` preenchidos pelo servidor |
| 8 | **Conta antiga:** apagar a linha do item 7 (`delete from terms_acceptances where user_id = '<usuário>'`) e reabrir o app | O app bloqueia na tela de termos antes de mostrar qualquer conteúdo |
| 9 | Ainda bloqueado: apertar o botão voltar do Android; fechar o app pelo multitarefa e reabrir | Continua bloqueado nas duas situações |
| 10 | Ainda bloqueado: ativar modo avião e tocar em "Li e aceito os termos" | Mostra erro, **não** libera o app, e permite tentar de novo |
| 11 | Desativar o modo avião e aceitar | Libera o app e grava a linha em `terms_acceptances` |
| 12 | **Versão nova:** `update terms_documents set vigente = false where vigente;` e inserir um documento novo com `vigente = true` **e `url` preenchida**. Reabrir o app | Pede o aceite outra vez, mesmo com a linha antiga preservada; mostra o aviso de versão e o link para o texto vigente |
| 13 | Repetir o item 12 com `url` NULL | O botão de aceite **não** aparece; a tela pede para atualizar o aplicativo (o app não pode coletar aceite de um texto que não exibe) |
| 14 | Com o gate aberto na versão antiga, publicar a nova em outro terminal e só então tocar em aceitar | Recusa com aviso de que os termos mudaram e recarrega mostrando a versão nova |
| 15 | Conta que também está em `admin_users`, com aceites de outras contas no banco | Entra normalmente se tiver o próprio aceite; bloqueia se não tiver — nunca erro nem liberação pelo aceite alheio |

## Fluxo principal

| # | O que fazer | Passa quando |
|---|---|---|
| 16 | Cadastrar a criança (com foto e sem foto) | Salva nos dois casos; a foto aparece depois no perfil |
| 17 | Abrir a Home | Criança ativa correta, habilidades carregadas, sem tela vazia nem spinner infinito |
| 18 | Fazer a avaliação/triagem inteira | Conclui e gera plano; as respostas ficam gravadas |
| 19 | Abrir uma atividade e registrar as 10 repetições | Cada toque registra; o resultado bate com o que foi tocado |
| 20 | Observar a barra de progresso durante o item 19 | Avança a cada repetição e chega ao fim exatamente na 10ª |
| 21 | Usar a barra inferior entre Home, Plano, Histórico e Perfil | Troca de tela sem empilhar histórico e sem piscar |

## Assinatura

| # | O que fazer | Passa quando |
|---|---|---|
| 22 | Abrir a tela de Planos | Aparece **um** card mensal. Nenhuma menção a plano anual, em nenhum lugar |
| 23 | Comparar o preço na tela com o Price configurado no Stripe | Valor idêntico, incluindo centavos e moeda |
| 24 | Conferir o período de teste exibido | Bate com `STRIPE_TRIAL_DAYS`; para conta que já assinou uma vez, o teste não é anunciado |
| 25 | Tocar em assinar e completar o checkout com o cartão de teste | Abre o Stripe, cobra o mesmo valor da tela e aplica o mesmo período de teste |
| 26 | Voltar do checkout para o app | Retorna sozinho para o app; o status premium aparece sem precisar reiniciar |
| 27 | Cancelar o checkout no meio e voltar | Volta ao app sem travar e sem marcar assinatura |

## Conta

| # | O que fazer | Passa quando |
|---|---|---|
| 28 | Abrir o Perfil | Dados do responsável corretos; a foto carrega |
| 29 | Sair da conta | Vai para o Login e não dá para voltar com o botão voltar |
| 29b | Sair da conta em modo avião | Sai mesmo assim: cai no Login e, ao voltar a rede, não reentra sozinho na conta |
| 30 | Entrar de novo | Entra direto, sem pedir os termos (já aceitos) |
| 31 | Excluir a conta pelo Perfil | Exige duas confirmações e explica que a ação é permanente |
| 32 | Depois da exclusão | Cai na tela de Login, sem sessão e sem dado da conta anterior em tela |
| 33 | Tentar entrar com o mesmo e-mail e senha | Falha — a conta não existe mais |
| 34 | Conferir no banco após o item 31 | `children`, `activity_plans` e `terms_acceptances` do usuário sumiram; `payment_history` continua (retenção fiscal) |

## Quando algo falhar

Anote o número do item, o aparelho, o tamanho da tela e o passo exato. Itens
1–5 e 21 tendem a falhar só em tela pequena; itens 8–15 e 31–34 dependem do
estado do banco, então registre também o que havia nas tabelas.
