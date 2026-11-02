#!/usr/bin/env bash
# $HOME в одинарных кавычках ниже намеренно: раскрывается в оболочке ADMIN_USER.
# shellcheck disable=SC2016
# Шаг 3. Claude Code на сервере + управление с телефона.
#
# Как это работает:
#   - Claude Code ставится официальным установщиком для пользователя ADMIN_USER
#     (не root) и сам обновляется в фоне;
#   - `claude-remote` запускает Claude Code в режиме Remote Control внутри tmux:
#     ты управляешь им из приложения Claude (iOS/Android) или claude.ai/code,
#     а код выполняется здесь, на сервере. SSH с телефона для этого не нужен;
#   - `claude-shell` — обычный интерактивный Claude Code в tmux для работы по SSH;
#     после обрыва связи просто снова набери `claude-shell`.
#   - сервис claude-remote поднимает Remote Control после перезагрузки сервера.
#
# Remote Control требует входа через подписку Claude (Pro/Max/…); API-ключ не подходит.
#
# Переменные (необязательные):
#   ADMIN_USER=dev        под каким пользователем ставить
#   PROJECTS_DIR=~/projects
#   CLONE_REPO=https://github.com/<user>/<repo>.git   склонировать проект в PROJECTS_DIR
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=lib.sh
source ./lib.sh

ADMIN_USER=${ADMIN_USER:-dev}
CLONE_REPO=${CLONE_REPO:-}

require_root
require_supported_os
id "$ADMIN_USER" &>/dev/null || die "Нет пользователя $ADMIN_USER — сначала выполни 01-harden.sh."
ADMIN_HOME=$(getent passwd "$ADMIN_USER" | cut -d: -f6)
PROJECTS_DIR=${PROJECTS_DIR:-$ADMIN_HOME/projects}

MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
if (( MEM_KB < 3500000 )); then
  warn "RAM меньше 4 ГБ ($((MEM_KB / 1024)) МБ). Claude Code официально требует 4 ГБ+ — возможны тормоза и падения."
fi

apt_install git tmux curl ca-certificates

as_user() { sudo -u "$ADMIN_USER" -H bash -lc "$1"; }

# --- Claude Code -------------------------------------------------------------
if as_user 'command -v claude >/dev/null || [ -x "$HOME/.local/bin/claude" ]'; then
  log "Claude Code уже установлен — обновляю…"
  as_user '"$HOME/.local/bin/claude" update >/dev/null 2>&1 || claude update >/dev/null 2>&1 || true'
else
  log "Устанавливаю Claude Code (официальный установщик claude.ai/install.sh)…"
  as_user 'curl -fsSL https://claude.ai/install.sh | bash' || die "Установка Claude Code не удалась."
fi
CLAUDE_BIN=$ADMIN_HOME/.local/bin/claude
[[ -x $CLAUDE_BIN ]] || die "Не найден $CLAUDE_BIN после установки."

BASHRC=$ADMIN_HOME/.bashrc
if ! grep -qs 'HOME/.local/bin' "$BASHRC"; then
  printf '\n# Claude Code\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$BASHRC"
  chown "$ADMIN_USER:$ADMIN_USER" "$BASHRC"
fi

install -d -m 755 -o "$ADMIN_USER" -g "$ADMIN_USER" "$PROJECTS_DIR"
if [[ -n $CLONE_REPO ]]; then
  name=$(basename "$CLONE_REPO" .git)
  if [[ -d $PROJECTS_DIR/$name/.git ]]; then
    log "Репозиторий $name уже склонирован."
  else
    log "Клонирую $CLONE_REPO…"
    sudo -u "$ADMIN_USER" -H git clone -q "$CLONE_REPO" "$PROJECTS_DIR/$name" || warn "Не удалось склонировать $CLONE_REPO."
  fi
fi

# --- tmux: прокрутка пальцем/мышью и длинная история ---------------------------
TMUX_CONF=$ADMIN_HOME/.tmux.conf
if [[ ! -f $TMUX_CONF ]]; then
  cat > "$TMUX_CONF" <<'CONF'
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
set -sg escape-time 10
CONF
  chown "$ADMIN_USER:$ADMIN_USER" "$TMUX_CONF"
fi

# --- Команды claude-remote и claude-shell -------------------------------------
install -m 755 ./claude-remote.sh /usr/local/bin/claude-remote
install -m 755 ./claude-shell.sh /usr/local/bin/claude-shell

# --- Автозапуск Remote Control после перезагрузки (включается вручную) ----------
cat > /etc/systemd/system/claude-remote.service <<UNIT
[Unit]
Description=Claude Code Remote Control (tmux session "claude-remote")
Wants=network-online.target
After=network-online.target

[Service]
Type=forking
User=$ADMIN_USER
Environment=HOME=$ADMIN_HOME
Environment=PATH=$ADMIN_HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
Environment=PROJECTS_DIR=$PROJECTS_DIR
WorkingDirectory=$PROJECTS_DIR
ExecStart=/usr/local/bin/claude-remote --detach
ExecStop=/usr/bin/tmux kill-session -t claude-remote
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload

echo
bold "Шаг 3 готов: Claude Code $(as_user '"$HOME/.local/bin/claude" --version' 2>/dev/null || echo '') установлен."
cat <<TXT
  Дальше (один раз), зайдя по SSH как $ADMIN_USER:
    1. claude                → /login, войди подпиской Claude (ссылку открой на телефоне/ноутбуке,
                               код вставь обратно в терминал), затем /exit
    2. claude-remote         → ответь y на «Enable Remote Control?» и «Trust …?»,
                               нажми пробел — появится QR-код, отсканируй его телефоном
                               (или найди сессию в приложении Claude → Code)
                               Отключиться от tmux, не останавливая Claude: Ctrl+B, затем D
    3. sudo systemctl enable claude-remote   → Remote Control будет подниматься после перезагрузки
TXT
