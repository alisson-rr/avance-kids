# Modelos de importação de conteúdo

Formato dos arquivos que a cliente preenche para importar **perguntas** e
**atividades**, e o que existe hoje para consumir cada um.

- Planilha-modelo: [`modelos-importacao.xlsx`](modelos-importacao.xlsx)
- Gerador: `scripts/gerar_modelos_importacao.py`
  (`--self-check` valida sem escrever; roda junto do `--out` também)

O modelo não é digitado à mão em lugar nenhum: o cabeçalho da aba **Atividades**
é lido de `scripts/import_programas.py`, e as faixas etárias são conferidas
contra a asserção de `scripts/validate_migrations.sh`. Se qualquer um dos dois
mudar sem o modelo mudar junto, o `--self-check` falha.

---

## 1. Atividades → `exercises`

**Formato:** as mesmas 17 colunas da planilha oficial já importada em
migration-08. Nada foi inventado — se a cliente atualizar o arquivo original,
ele serve como está.

| Coluna da planilha | Coluna de `exercises` |
| --- | --- |
| Código | `codigo` |
| Habilidade | `titulo` |
| Programa ABA | `programa_aba` |
| Função | `funcao` |
| Nível | `nivel` (`aquisicao` / `generalizacao` / `manutencao`) |
| Objetivo | `objetivo` |
| Materiais | `materiais` |
| Recursos | `recursos_extras` |
| Exemplos de Brincadeiras | `brincadeiras` |
| Frequência | `frequencia` |
| Hierarquia de Dicas | `hierarquia_dicas` |
| Procedimento | `procedimento` |
| Resposta Esperada | `resposta_esperada` |
| Procedimento de Correção | `procedimento_correcao` |
| Critério de Avanço | `criterio_avanco` |
| Registro de Dados (detalhado) | `registro_dados` |
| Exemplos de Reforços | `reforcos` |

Colunas de `exercises` que **não** vêm da planilha:

| Coluna | De onde vem |
| --- | --- |
| `skill_id` | da letra do código (`C`→comunicação, `S`→social, `G`→cognitiva, `M`→motora, `F`→funcional) |
| `age_bracket_id` | do prefixo do código (`F01A`..`F06A`) |
| `ordem` | do número sequencial do código; **igual nos três níveis**, que é o que mantém a travessia A→G→M do mesmo código |
| `media_type`, `media_url` | cadastro de atividade no backoffice (imagem é upload; vídeo é URL) |
| `plano` | cadastro de atividade no backoffice (Gratuito / Premium) |
| `status` | cadastro de atividade no backoffice (ativo / arquivado) |

Mídia, plano e status ficam fora da planilha de propósito: os três já são campos
do formulário do backoffice, e mídia envolve upload de arquivo. Duplicar aqui
criaria duas fontes de verdade para o mesmo dado.

**Validações que `import_programas.py` já aplica** (falha e não grava nada):

- cabeçalho idêntico, coluna por coluna, na ordem;
- código no padrão `F0[1-6]A[CSGMFT]\d{3}`;
- exatamente 3 níveis por código, sem `(código, nível)` repetido;
- habilidade coerente entre os três níveis do mesmo código;
- nenhuma célula vazia nas 17 colunas;
- contagem total conferida contra o esperado.

Códigos `AT` (`F0nAT00n`) continuam indo para `screening_programs`, não para
`exercises` — ver 1.7 em [DEPENDENCIAS-E-PENDENCIAS.md](DEPENDENCIAS-E-PENDENCIAS.md).

**Estado:** importador pronto. Gera uma migration nova; nada é aplicado direto
no banco.

---

## 2. Perguntas → `questions`

**Formato:** aba `Perguntas` da planilha-modelo.

| Coluna | Coluna de `questions` | Regra |
| --- | --- | --- |
| Tipo | `kind` | `Inicial` → `inicial`, `Triagem` → `triagem` |
| Faixa | `age_bracket_id` | código `F01A`..`F06A` |
| Habilidade | `skill_id` | uma das cinco; **obrigatória também no tipo Inicial** (`skill_id` é `NOT NULL`) |
| Ordem | `ordem` | inteiro, sem repetir dentro de (Tipo, Faixa, Habilidade) |
| Pergunta | `texto` | texto exibido ao responsável |

`status` não vem do arquivo: entra como `ativo` e é alternado no backoffice.

**Regra de negócio que depende deste arquivo:** as perguntas de tipo `Inicial`
são os pré-requisitos da faixa, e duas respostas "A" entre elas rebaixam a
criança uma faixa (D3, seção 1.4 de DEPENDENCIAS-E-PENDENCIAS.md). Duas
consequências práticas:

- a quantidade de perguntas `Inicial` deveria ser parecida entre as faixas,
  senão o rebaixamento fica mais fácil numa faixa do que na outra;
- toda faixa precisa ter perguntas `Inicial`, inclusive F01A — que é o piso e
  nunca rebaixa, mas ainda assim é avaliada.

**Estado:** **não existe importador.** Quando o arquivo chegar, é um script no
mesmo molde do `import_programas.py` (ler, validar, gerar migration) — o
trabalho está na validação, não no INSERT.

O que a importação vai precisar decidir na hora, e não antes:

- **substituir ou somar?** As 150 perguntas atuais são o texto genérico do
  migration-03. Trocar significa apagar linhas de `questions`, e
  `child_question_answers` tem FK para elas — respostas de crianças que já
  responderam a triagem seriam afetadas. O caminho seguro é o mesmo da
  migration-08 com as atividades: **arquivar** as antigas em vez de apagar.
- **crianças com plano já gerado** precisam refazer a triagem para o plano
  refletir as perguntas novas (mesma consequência descrita em 3.2).

---

## 3. Como enviar

1. Preencher a planilha-modelo (ou atualizar o arquivo oficial de 17 colunas,
   no caso das atividades).
2. Apagar as linhas de exemplo — elas são recusadas pela validação de propósito,
   então uma linha esquecida derruba a importação em vez de virar conteúdo.
3. Enviar o `.xlsx`. O importador roda contra uma cópia descartável primeiro
   (`scripts/validate_migrations.sh`) e só depois vira migration.
