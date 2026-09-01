# Docs de domínio

Como as skills de engenharia devem consumir a documentação de domínio deste
repo ao explorar o código.

## Antes de explorar, leia

- **`CONTEXT.md`** na raiz do repo;
- **`docs/adr/`** — leia os ADRs que tocam a área em que você vai mexer.

Se algum desses arquivos não existir, **siga em silêncio**. Não sinalize a
ausência e não sugira criá-los de antemão. A skill `/domain-modeling` (alcançada
por `/grill-with-docs` e `/improve-codebase-architecture`) cria os arquivos de
forma preguiçosa, quando um termo ou uma decisão realmente aparece para ser
resolvida.

## Estrutura de arquivos

Contexto único — é o caso deste repo:

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-faixas-etarias-contiguas.md
│   └── 0002-progressao-aquisicao-generalizacao-manutencao.md
└── apps/, supabase/, scripts/
```

Se um dia o repo virar multi-contexto, o sinal é um `CONTEXT-MAP.md` na raiz
apontando para um `CONTEXT.md` por contexto, com `docs/adr/` na raiz guardando
as decisões que valem para o sistema inteiro.

## Use o vocabulário do glossário

Quando a sua saída nomear um conceito de domínio — título de issue, proposta de
refatoração, hipótese, nome de teste — use o termo como o `CONTEXT.md` o define.
Não escorregue para sinônimos que o glossário evita de propósito.

Se o conceito que você precisa ainda não está no glossário, isso é um sinal: ou
você está inventando linguagem que o projeto não usa (reconsidere), ou existe
uma lacuna real (anote para a `/domain-modeling`).

## Sinalize conflito com ADR

Se a sua saída contradiz um ADR existente, diga isso explicitamente em vez de
passar por cima em silêncio:

> _Contradiz o ADR-0007 (progressão por código) — mas vale reabrir porque…_
