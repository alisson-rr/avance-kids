# Rótulos de triagem

As skills falam em cinco papéis canônicos de triagem. Esta tabela mapeia cada
papel para o rótulo real usado no issue tracker deste repo (Linear, time
Devnoflow).

| Papel na skill | Rótulo no nosso tracker | Significado |
| --- | --- | --- |
| `needs-triage` | `needs-triage` | Precisa ser avaliada por um mantenedor |
| `needs-info` | `needs-info` | Esperando mais informação de quem reportou |
| `ready-for-agent` | `ready-for-agent` | Especificada por completo, pronta para um agente rodar sozinho |
| `ready-for-human` | `ready-for-human` | Exige implementação humana |
| `wontfix` | `wontfix` | Não será feita |

Quando uma skill mencionar um papel ("aplique o rótulo de pronto-para-agente"),
use a string da coluna do meio.

Para mudar o vocabulário, edite a coluna do meio — não a da esquerda.

## Estado no Linear

**Nenhum dos cinco existe ainda no workspace.** Os rótulos presentes hoje são
`Bug`, `Feature`, `Improvement` e os grupos de prospecção (`sinal`, `nicho`,
`canal`, `funil`).

Crie o que faltar com `create_issue_label` (`name`, opcionalmente `teamId` para
escopo de time em vez de workspace). Criar na primeira vez que for usar é
suficiente — não vale criar os cinco por antecipação.

## Duas armadilhas do Linear

- **`labels` no `save_issue` substitui o conjunto inteiro.** Para adicionar um
  rótulo de triagem sem apagar `Bug` ou `Feature`, leia os atuais com
  `get_issue` e envie a lista completa. Detalhe em
  [`issue-tracker.md`](issue-tracker.md).
- **Rótulo não é estado.** O Linear tem estados próprios (Backlog, Todo, In
  Progress, In Review, Done, Canceled). `wontfix` é rótulo *e* costuma vir
  junto de mover a issue para `Canceled`; os outros quatro são só rótulo e não
  mexem no estado.
