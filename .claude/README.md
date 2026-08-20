# Arquitetura padrão para Claude Code

Este diretório representa o conteúdo de `.claude/` de um projeto. Ele mantém instruções sempre carregadas curtas e move procedimentos longos para skills, economizando contexto.

## Estrutura

```text
.claude/
|-- CLAUDE.md
|-- agents/
|   |-- code-reviewer.md
|   `-- debugger.md
|-- commands/
|   |-- check.md
|   `-- review.md
|-- rules/
|   |-- api-conventions.md
|   |-- code-style.md
|   |-- database.md
|   |-- security.md
|   |-- testing.md
|   `-- typescript.md
`-- skills/
    |-- handoff/SKILL.md
    `-- security-review/SKILL.md
```

`commands/` foi mantido para atalhos manuais curtos. Novos fluxos reutilizáveis devem ser skills: comandos personalizados agora são tratados como skills pelo Claude Code, mas o formato antigo continua compatível.

## Adotar em um projeto

1. Crie `.claude/` na raiz do projeto.
2. Copie `CLAUDE.md`, `agents/`, `commands/`, `rules/` e `skills/` para ela.
3. Copie `.claudeignore.example` para a raiz do projeto com o nome `.claudeignore` e ajuste as pastas geradas pela stack.
4. Preencha apenas o bloco `Contexto` de `.claude/CLAUDE.md`.
5. No Claude Code, execute `/context` e confirme que o `CLAUDE.md` e as regras foram carregados.

Não copie este `README.md` para o projeto; ele documenta o template.

## Graphify

O Graphify instalado na máquina continua sendo a fonte de verdade. O template apenas define quando consultá-lo.

- Primeiro mapa: `/graphify . --no-viz`
- Pergunta sobre o projeto: `graphify query "<pergunta>"`
- Relação entre conceitos: `graphify path "<A>" "<B>"`
- Atualização após mudança estrutural: `graphify update .`
- Sincronização automática opcional em repositórios Git: `graphify hook install`

Os artefatos do Graphify ficam no disco e são consultados por comando; `.claudeignore` evita que alterações neles invalidem o cache de prompt.

## Ponytail

Instale como plugin do Claude Code em dois prompts separados:

```text
/plugin marketplace add DietrichGebert/ponytail
```

```text
/plugin install ponytail@ponytail
```

O modo padrão `full` é adequado para o dia a dia. Use `/ponytail-review` para o diff e `/ponytail-audit` apenas para uma auditoria deliberada do repositório inteiro.

## Manutenção

- Mantenha `CLAUDE.md` abaixo de 200 linhas.
- Coloque fatos sempre necessários no `CLAUDE.md`, regras condicionais em `rules/` e procedimentos em `skills/`.
- Só crie um agente quando o mesmo trabalho especializado for delegado repetidamente.
- Revise o template quando o Claude Code, Graphify ou Ponytail mudarem de formato.

Fontes: [Claude Code](https://code.claude.com/docs/en/overview), [Graphify](https://github.com/Graphify-Labs/graphify) e [Ponytail](https://github.com/DietrichGebert/ponytail).
