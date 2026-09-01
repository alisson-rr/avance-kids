# Issue tracker: Linear

Issues e specs deste repo ficam no **Linear**, workspace `devnoflow`, time
**Devnoflow**. Não existe CLI para o Linear: todo acesso é pelas ferramentas
MCP do servidor Linear conectado à sessão.

## Antes de qualquer operação

As ferramentas do Linear chegam **deferred** — só o nome aparece na lista, sem
schema, e chamá-las direto falha. Carregue em **uma única** chamada de
ToolSearch todas as que você vai usar:

```
ToolSearch  select:mcp__<servidor>__save_issue,mcp__<servidor>__get_issue,mcp__<servidor>__list_issues,mcp__<servidor>__list_comments,mcp__<servidor>__save_comment
```

O prefixo `mcp__<servidor>__` é um UUID que **muda por sessão**. Localize-o
procurando por um dos nomes acima na lista de ferramentas deferred. Não carregue
uma por vez: cada ToolSearch é um round-trip inteiro.

## Onde as issues nascem

- **Time:** `Devnoflow` (único do workspace)
- **Projeto:** `Avance Kids — Validação e encerramento`
  <https://linear.app/devnoflow/project/avance-kids-validacao-e-encerramento-83d94629da3c>

Passe **sempre** `team` e `project` ao criar. Sem `project` a issue cai solta no
backlog do time, misturada com FaceMob, MVCore e Prospecção.

## Convenções

| Operação | Como |
| --- | --- |
| Criar issue | `save_issue` com `team`, `project`, `title`, `description`. **Não** passe `id` ao criar. |
| Atualizar issue | `save_issue` com `id` (o identificador que o Linear mostra na issue) |
| Ler issue | `get_issue` com `id`; adicione `includeRelations: true` quando bloqueios/duplicatas importarem |
| Ler comentários | `list_comments` com `issueId` |
| Listar issues | `list_issues`, filtrando por `team`, `project`, `label` e `state` |
| Comentar | `save_comment` |
| Rotular | `save_issue` com `labels` — **leia a advertência abaixo** |
| Fechar | `save_issue` com `state: "Done"` (ou `"Canceled"`) |

`description` é Markdown **literal**: use quebras de linha reais, não `\n`
escapado.

### `labels` substitui o conjunto inteiro

Este é o erro fácil de cometer. O campo `labels` do `save_issue` **troca todos
os rótulos da issue** pela lista enviada — os que ficaram de fora são removidos.

Para *adicionar* um rótulo sem perder os outros:

1. `get_issue` para ler os rótulos atuais;
2. `save_issue` com a lista completa — os atuais **mais** o novo.

Omitir `labels` deixa os rótulos como estão, que é o que você quer em qualquer
`save_issue` que não seja sobre rotular.

## Estados do time Devnoflow

```
Backlog → Todo → In Progress → In Review → Done
```

Fora do fluxo: `Canceled` e `Duplicate`.

**Não existe "fechar" no Linear.** Fechar é mover para `Done` (resolvido) ou
`Canceled` (não vamos fazer). Nunca apague uma issue para encerrá-la.

## Quando uma skill disser "publicar no issue tracker"

Criar uma issue no time `Devnoflow`, projeto `Avance Kids — Validação e
encerramento`.

## Quando uma skill disser "buscar o ticket relevante"

`get_issue` com o identificador, seguido de `list_comments` com o mesmo id — o
`get_issue` sozinho não traz a discussão.

## Wayfinding

Usado pelo `/wayfinder`. O **mapa** é uma issue e os **tickets** são sub-issues
dela.

- **Mapa:** uma issue com o corpo de Notas / Decisões-até-aqui / Névoa, marcada
  com o rótulo `wayfinder:map`.
- **Ticket filho:** `save_issue` com `parentId` apontando para o mapa. Rótulo
  `wayfinder:<tipo>` (`research` / `prototype` / `grilling` / `task`).
- **Bloqueio:** relações nativas do Linear — `blockedBy` e `blocks` no
  `save_issue`. São **append-only**; para desfazer use `removeBlockedBy` /
  `removeBlocks`. `get_issue` com `includeRelations: true` mostra as arestas.
- **Fronteira:** filhos do mapa em estado não concluído, sem nenhum bloqueador
  ainda aberto e sem `assignee`. O primeiro na ordem do mapa vence.
- **Reivindicar:** `save_issue` com `assignee: "me"` — a primeira escrita da
  sessão.
- **Resolver:** `save_comment` com a resposta, `save_issue` com `state: "Done"`,
  e então acrescentar o ponteiro da decisão ao corpo do mapa.
