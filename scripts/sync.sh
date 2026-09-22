#!/usr/bin/env bash
# ============================================================================
# sync.sh - Regenera o data.js a partir do vault e publica no GitHub Pages
# quando houver mudanças. Projetado para ser chamado por um LaunchAgent que
# vigia as pastas 08 - Sermões e 09 - Estudos do Segundo Cérebro.
#
# Comportamento:
#   - Serializa execuções simultâneas (mkdir lock)
#   - Regenera data.js (gerar.py)
#   - Só comita/publica se data.js mudou (evita pushs desnecessários)
#   - Loga tudo em ~/ricardo_estudos_sync.log
# ============================================================================
set -uo pipefail

REPO="$HOME/ricardo_estudos"
LOCK="$REPO/.sync.lock"
LOG="$HOME/ricardo_estudos_sync.log"

mkdir -p "$(dirname "$LOG")"
exec >>"$LOG" 2>&1
echo "=== $(date '+%F %T') sync.sh disparado ==="

# lock (sem flock no macOS)
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "$(date '+%T') ja existe outro processo em execucao, saindo"
  exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

# pequena espera para o arquivo novo terminar de ser gravado / eventos agruparem
sleep "${SYNC_DEBOUNCE:-15}"

cd "$REPO" || { echo "ERRO: repo nao encontrado"; exit 1; }

if ! python3 "$REPO/scripts/gerar.py"; then
  echo "$(date '+%T') ERRO: gerar.py falhou"
  exit 1
fi

if git diff --quiet data.js; then
  echo "$(date '+%T') data.js sem alteracoes, nada a publicar"
  exit 0
fi

git add data.js
git commit -m "sync: atualizar estudos/sermoes do vault ($(date +%F))" >/dev/null 2>&1 || true
if git push --quiet origin main; then
  echo "$(date '+%T') publicado no GitHub Pages com sucesso"
else
  echo "$(date '+%T') FALHA ao fazer push (verifique rede/credenciais)"
  exit 1
fi