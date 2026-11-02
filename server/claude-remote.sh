#!/usr/bin/env bash
# claude-remote — Claude Code в режиме Remote Control внутри tmux-сессии "claude-remote".
# Управляй им из приложения Claude (iOS/Android) или с claude.ai/code.
#
#   claude-remote            запустить (если ещё не запущен) и подключиться
#   claude-remote --detach   запустить в фоне (так стартует сервис claude-remote)
#
# Отключиться от tmux, не останавливая Claude: Ctrl+B, затем D.
# Показать QR-код для телефона: внутри сессии нажми пробел.
set -euo pipefail

SESSION=claude-remote
DIR=${PROJECTS_DIR:-$HOME/projects}
CLAUDE=${CLAUDE_BIN:-$HOME/.local/bin/claude}

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "Запускай от своего пользователя, не от root (без sudo)." >&2
  exit 1
fi
if [[ ! -x $CLAUDE ]]; then
  CLAUDE=$(command -v claude) || { echo "Claude Code не найден. Установи: server/04-claude-code.sh" >&2; exit 1; }
fi
mkdir -p "$DIR"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  # Цикл перезапускает Remote Control, если процесс завершился (обновление, сбой сети).
  tmux new-session -d -s "$SESSION" -c "$DIR" \
    "while :; do $(printf '%q' "$CLAUDE") remote-control; echo; echo 'Remote Control остановлен. Перезапуск через 30 с (Ctrl+C — выйти).'; sleep 30 || break; done"
fi

[[ ${1:-} == --detach ]] && exit 0

if [[ -n ${TMUX:-} ]]; then
  exec tmux switch-client -t "$SESSION"
else
  exec tmux attach -t "$SESSION"
fi
