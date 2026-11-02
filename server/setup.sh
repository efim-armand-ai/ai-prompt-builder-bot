#!/usr/bin/env bash
# Полная установка одной командой: защита сервера → VPN (VLESS) → AmneziaWG → Claude Code.
#
#   sudo bash setup.sh
#
# Переменные (необязательные), например:
#   ADMIN_USER=dev VPN_DEVICES="iphone1 ipad1 laptop" AWG_PEERS="home-router" bash setup.sh
#
#   ADMIN_USER    пользователь-администратор (по умолчанию dev)
#   SSH_PORT      порт SSH (по умолчанию 22)
#   VPN_PORT      порт VPN (по умолчанию 443)
#   VPN_DEVICES   устройства для VPN через пробел (по умолчанию device1)
#   REALITY_SNI   сайт для маскировки (по умолчанию www.microsoft.com)
#   AWG_PEERS     пиры AmneziaWG для роутеров (по умолчанию home-router)
#   AWG_PORT      UDP-порт AmneziaWG (по умолчанию случайный)
#   SKIP_AWG=1    не ставить AmneziaWG
#   CLONE_REPO    git-репозиторий, который склонировать в ~/projects
#   SKIP_CLAUDE=1 не ставить Claude Code
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=lib.sh
source ./lib.sh

require_root
require_supported_os

export ADMIN_USER=${ADMIN_USER:-dev}
export SSH_PORT=${SSH_PORT:-22}
export VPN_PORT=${VPN_PORT:-443}
export VPN_DEVICES=${VPN_DEVICES:-device1}
export REALITY_SNI=${REALITY_SNI:-}
export CLONE_REPO=${CLONE_REPO:-}
export AWG_PEERS=${AWG_PEERS:-home-router}
export AWG_PORT=${AWG_PORT:-}

# Копия скриптов для обслуживания: клон в /root не виден пользователю ADMIN_USER.
install -d -m 755 /opt/vps-setup
install -m 755 ./*.sh /opt/vps-setup/
install -m 644 ./README.md /opt/vps-setup/

bold "=== 1/4 Защита сервера ==="
bash ./01-harden.sh
echo
bold "=== 2/4 VPN (VLESS + Reality) ==="
bash ./02-vpn.sh
echo
if [[ ${SKIP_AWG:-0} != 1 ]]; then
  bold "=== 3/4 AmneziaWG (роутер) ==="
  bash ./03-amneziawg.sh
  echo
fi
if [[ ${SKIP_CLAUDE:-0} != 1 ]]; then
  bold "=== 4/4 Claude Code ==="
  bash ./04-claude-code.sh
fi

IP=$(detect_public_ip)
echo
bold "================ ГОТОВО ================"
echo "SSH:        ssh -p $SSH_PORT $ADMIN_USER@$IP"
[[ -f /root/.admin-password ]] && echo "sudo-пароль: $(cat /root/.admin-password)   ← сохрани в менеджер паролей"
echo "VPN:        sudo vpn add <имя> | sudo vpn show <имя> | sudo vpn list"
[[ ${SKIP_AWG:-0} != 1 ]] && echo "Роутер:     sudo vpn link home-router > home-router.conf  (UDP-порт: $(vpn awg-port 2>/dev/null))"
echo "Скрипты:    /opt/vps-setup (инструкция: /opt/vps-setup/README.md)"
echo "Claude:     claude (вход), затем claude-remote — и управляй с телефона"
warn "Проверь вход по SSH как $ADMIN_USER в НОВОМ окне, прежде чем закрывать это: вход под root уже отключён."
