#!/usr/bin/env bash
# ============================================================================
# watch.sh - Watcher dos estudos/sermões do Segundo Cérebro.
#
# Alternativa ao LaunchAgent (que exige liberar TCC/FDA no macOS). Este watcher
# roda NA SUA SESSÃO AUTORIZADA (nohup), então consegue ler as pastas do iCloud.
# A cada mudança nos arquivos .md de 08 - Sermões e 09 - Estudos, chama
# scripts/sync.sh (regenera data.js, commit + push).
#
# Iniciar:  nohup bash scripts/watch.sh >/dev/null 2>&1 &
# Parar:    kill "$(cat "$HOME/ricardo_estudos/.watch.pid")"
# Obs: precisa reiniciar após reboot/logout (limitação do modo sessão).
# ============================================================================
set -uo pipefail

VAULT="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Segundo_Cerebro"
REPO="$HOME/ricardo_estudos"
DIRS=("$VAULT/09 - Estudos" "$VAULT/08 - Sermões")
PIDFILE="$REPO/.watch.pid"
STATE="$REPO/.watch.state"
INTERVAL="${WATCH_INTERVAL:-5}"

# evita instâncias duplicadas
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; then
  echo "watch.sh ja esta rodando (pid $(cat "$PIDFILE"))" >&2
  exit 1
fi
echo "$$" > "$PIDFILE"

fingerprint() {
  local f=""
  for d in "${DIRS[@]}"; do
    [[ -d "$d" ]] || continue
    f+="$(find "$d" -name '*.md' -type f -exec stat -f '%m %N' {} + 2>/dev/null | sort)"
  done
  printf '%s' "$f" | md5
}

last="$(cat "$STATE" 2>/dev/null || echo)"
echo "watch.sh iniciado (pid $$) em $(date '+%F %T')" >> "$HOME/ricardo_estudos_sync.log"

while true; do
  current="$(fingerprint)"
  if [[ "$current" != "$last" ]]; then
    echo "$current" > "$STATE"
    sleep "${SYNC_DEBOUNCE:-10}"
    bash "$REPO/scripts/sync.sh"
    last="$(fingerprint)"   # re-snapshot pós-publicação
  fi
  sleep "$INTERVAL"
done