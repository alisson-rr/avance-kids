# Keystore de release comprometido — o que aconteceu e o que foi feito

## 1. O achado

Duas credenciais de assinatura do app estiveram versionadas neste repositório:

| Segredo | Caminho | Entrou em | Saiu do índice em |
| --- | --- | --- | --- |
| Keystore de release (binário, 2.752 bytes) | `apps/mobile/credentials/avancekids-release.keystore` | `77a3f5b` | `b9a0cde` |
| Senha do store e da chave, em texto puro | `docs/BUILD-ANDROID.md`, seção "Assinatura" | `b79e403` | `b9a0cde` |

`apps/mobile/.gitignore` já listava `credentials/` e `*.keystore`, mas
`.gitignore` não afeta arquivo que já entrou no índice — por isso a regra
existia e o arquivo estava versionado assim mesmo.

O commit `b9a0cde` tirou os dois do índice. Isso **não** os tira do histórico:
qualquer clone anterior, e o próprio `origin`, continuavam com os objetos
íntegros e recuperáveis com um `git show`.

Confirmação do escopo, feita antes da remediação:

```bash
# blobs de todo o repositório que contêm a senha
git rev-list --objects --all | while read sha rest; do
  [ "$(git cat-file -t "$sha")" = blob ] &&
  git cat-file blob "$sha" | grep -qF "$SENHA" && echo "$sha -> $rest"
done
# resultado: 1 blob (docs/BUILD-ANDROID.md)

# commits cuja árvore contém o keystore
git rev-list --all | while read c; do
  git ls-tree -r --name-only "$c" | grep -q avancekids-release.keystore && echo "$c"
done
# resultado: 13 commits (77a3f5b e todos os descendentes até as branches de trabalho)
```

## 2. Remediação aplicada

### 2.1 Keystore novo (o que realmente resolve)

Reescrever o histórico não "descompromete" uma chave que já circulou. O que
resolve é trocar a chave — e o app **ainda não foi publicado na Play Store**,
então a troca custou zero. Depois do primeiro envio, trocar só seria possível
com Play App Signing.

O keystore novo foi gerado com `keytool` (RSA 4096, PKCS12, validade 10.000
dias, alias `avancekids`), com senha aleatória de 32 caracteres criada em
runtime. Detalhes e fingerprint em [BUILD-ANDROID.md](BUILD-ANDROID.md).

- Arquivo: `apps/mobile/credentials/avancekids-release.keystore` — coberto por
  `credentials/` e `*.keystore` em dois `.gitignore`.
- Senha: apenas em `apps/mobile/android/gradle.properties`, coberto pela regra
  `/android`. **Não** foi escrita em nenhum documento versionado.
- O keystore antigo deve ser tratado como público e nunca mais usado.

### 2.2 `.gitignore` na raiz

As regras de material de assinatura viviam só em `apps/mobile/.gitignore` e
valiam apenas abaixo daquele diretório. A raiz passou a barrar `*.keystore`,
`*.jks`, `*.p12`, `*.pfx`, `*.p8`, `*.pem`, `*.key`, `credentials/`, `.env` e
`service-account*.json` em qualquer ponto do monorepo.

### 2.3 Reescrita do histórico local

**Isto é destrutivo: todo hash de commit do repositório muda.**

Antes de rodar, foram criados dois pontos de retorno:

1. Espelho completo do repositório (todas as refs e objetos):
   ```bash
   git clone --mirror . <backup>/repo-pre-purge.git
   ```
2. `refs/original/**`, criado automaticamente pelo `git filter-branch`.

Branches afetadas (todas continham os objetos):

- `main`
- `fix/mobile-ui-audit`
- `feat/nonblocking-core-prep`
- `integration/pre-client-response`
- tags `safety/main-pre-integration`, `safety/ui-dc6009b`, `safety/be-44a8db6`

Comando executado (`git filter-repo` não está instalado nesta máquina; o
`filter-branch` com `--index-filter` não precisa de checkout e é rápido em um
repositório deste tamanho — 49 commits, ~12 MB):

```bash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f \
  --index-filter "sh <script de purga>" -- --branches --tags
```

Sem `--prune-empty`: nenhum commit fica vazio depois da purga (os que tocavam o
keystore mexiam em mais arquivos), e manter os nós evita ter de reconferir o
grafo inteiro.

O script de purga faz duas coisas em cada commit:

```sh
# 1. tira o keystore do índice, se estiver lá
git rm --cached --ignore-unmatch -q apps/mobile/credentials/avancekids-release.keystore

# 2. reescreve o blob do doc trocando a senha por um marcador
blob=$(git rev-parse -q --verify :docs/BUILD-ANDROID.md) || exit 0
novo=$(git cat-file blob "$blob" | sed "s/$SENHA/[SENHA REMOVIDA DO HISTORICO]/g" \
       | git hash-object -w --stdin)
[ "$novo" = "$blob" ] || git update-index --cacheinfo 100644,"$novo",docs/BUILD-ANDROID.md
```

Hashes antes e depois (todas as refs mudaram, como esperado):

| Ref | Antes | Depois |
| --- | --- | --- |
| `main` | `f1f1076` | `5eb0e1d` |
| `fix/mobile-ui-audit` | `dc6009b` | `c4a24ca` |
| `feat/nonblocking-core-prep` | `44a8db6` | `2901fe8` |
| `integration/pre-client-response` | `a91ced8` | `36782ba` |

Depois da reescrita, para que os objetos antigos deixem de ser alcançáveis
localmente:

```bash
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now
```

### Onde está o backup

`C:\Users\Alisson\CascadeProjects\AVANCE-Kids-backup-pre-purge.git` — espelho completo tirado **depois** da reescrita e **antes** da
limpeza, então contém as refs novas *e* `refs/original/**` com o histórico
antigo inteiro.

> ⚠️ **Esse espelho contém o keystore antigo e a senha.** Ele existe para
> reverter a reescrita se algo tiver saído errado. Apague-o assim que a
> integração estiver revisada e aceita.

## 3. O que continua pendente

**O `origin` (GitHub) ainda tem o histórico antigo.** A reescrita foi local. Só
um push forçado propaga a limpeza, e ele reescreve o repositório remoto para
todo mundo — por isso não foi executado aqui. Quando o responsável decidir:

```bash
git push --force-with-lease origin main
git push --force-with-lease origin fix/mobile-ui-audit
git push --force-with-lease origin feat/nonblocking-core-prep
```

Consequências de fazer o push forçado:

- todo clone existente fica divergente e precisa de `git fetch && git reset --hard`
  (ou de um clone novo); rebase por cima do histórico antigo reintroduz os objetos;
- Pull Requests abertos apontando para os commits antigos ficam órfãos;
- o GitHub mantém objetos "soltos" acessíveis por URL de commit durante algum
  tempo mesmo após o push — para apagá-los de vez é preciso abrir chamado no
  suporte do GitHub **ou** aceitar que o segredo antigo é público (que é a
  premissa correta aqui, já que a chave foi substituída).

Consequência de **não** fazer: o keystore antigo e a senha continuam
recuperáveis por qualquer pessoa com acesso ao repositório remoto. Como a chave
foi trocada, o impacto é histórico, não operacional — mas a senha antiga não
deve ser reutilizada em nenhum outro sistema.

## 4. Como conferir que a limpeza funcionou

```bash
# nenhum commit de branch/tag local deve listar o keystore
git rev-list --branches --tags | while read c; do
  git ls-tree -r --name-only "$c" | grep -q avancekids-release.keystore && echo "AINDA EM $c"
done

# nenhum blob alcançável por branch/tag deve conter a senha
git rev-list --objects --branches --tags | while read sha rest; do
  [ "$(git cat-file -t "$sha" 2>/dev/null)" = blob ] &&
  git cat-file blob "$sha" | grep -qF "$SENHA" && echo "AINDA EM $sha ($rest)"
done
```

Ambos devem sair vazios — e saíram, na conferência feita após a purga.

Uma varredura em `--all` (e não só em branches e tags) **ainda encontra** os dois
segredos. Isso é esperado e correto: a única ref que os alcança é
`refs/remotes/origin/main`, o espelho local do que o GitHub ainda tem. Ela é
substituída no primeiro `git fetch` depois do push forçado da seção 3.

```bash
git for-each-ref --format='%(refname)' refs/remotes
# refs/remotes/origin/HEAD
# refs/remotes/origin/main   <- f1f1076, o histórico antigo
```
