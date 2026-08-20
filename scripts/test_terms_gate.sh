#!/usr/bin/env bash
# Cenários do bloqueio de reaceite dos termos.
#
# Não há runner de teste no projeto e não faz sentido adicionar um por causa de
# um módulo: o tsc que já está instalado em apps/mobile compila os casos para
# JS e o Node roda. Se um dia entrar Jest/Vitest, este arquivo vira um
# `*.test.ts` sem mudar os casos.
#
# A saída vai para dentro de apps/mobile (e não para /tmp) porque o módulo sob
# teste importa `zustand`: o Node resolve node_modules subindo a partir do
# arquivo, então compilar fora da árvore quebraria o require.
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAIDA="$RAIZ/apps/mobile/.test-build"
trap 'rm -rf "$SAIDA"' EXIT
rm -rf "$SAIDA"

echo "== compilando =="
"$RAIZ/apps/mobile/node_modules/.bin/tsc" \
  "$RAIZ/scripts/test_terms_gate.ts" \
  --outDir "$SAIDA" \
  --rootDir "$RAIZ" \
  --module node18 \
  --target es2020 \
  --lib es2020,dom \
  --strict \
  --skipLibCheck

echo "== cenários do gate de termos =="
node "$SAIDA/scripts/test_terms_gate.js"
