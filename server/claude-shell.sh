#!/usr/bin/env bash
# claude-shell — интерактивный Claude Code в tmux-сессии "claude" для работы по SSH.
# Связь оборвалась (метро, смена сети) — подключись снова и набери claude-shell:
# сессия и Claude продолжают работать на сервере.
#
#   claude-shell            подключиться к сессии (или создать её в ~/projects)
#   claude-shell <папка>    создать сессию в указанной папке
#
# Отключиться, не останавливая: Ctrl+B, затем D.
set -euo pipefail

SESSION=claude
DIR=${1:-${PROJECTS_DIR:-$HOME/projects}}

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "Запускай от своего пользователя, не от root (без sudo)." >&2
  exit 1
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  mkdir -p "$DIR"
  tmux new-session -d -s "$SESSION" -c "$DIR"
  tmux send-keys -t "$SESSION" 'claude' Enter
fi

if [[ -n ${TMUX:-} ]]; then
  exec tmux switch-client -t "$SESSION"
else
  exec tmux attach -t "$SESSION"
fi
