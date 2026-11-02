#!/usr/bin/env bash
# Шаг 1. Базовая защита свежего VPS (Ubuntu 22.04/24.04, Debian 12).
#
#  - пользователь-администратор с sudo ПО ПАРОЛЮ (Claude Code не сможет
#    молча выполнить sudo — пароль он не знает);
#  - вход по SSH только по ключу, root-вход запрещён;
#  - файрвол UFW: открыт только SSH и 443/tcp (VPN); UDP-порт AmneziaWG
#    открывает 03-amneziawg.sh;
#  - fail2ban против перебора SSH;
#  - автоматические обновления безопасности;
#  - BBR (быстрее VPN на мобильных сетях) и swap, если его нет.
#
# Переменные (необязательные):
#   ADMIN_USER=dev     имя пользователя-администратора
#   SSH_PORT=22        порт SSH
#   VPN_PORT=443       порт VPN, который нужно открыть в файрволе
#
# Скрипт можно запускать повторно.
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=lib.sh
source ./lib.sh

ADMIN_USER=${ADMIN_USER:-dev}
SSH_PORT=${SSH_PORT:-22}
VPN_PORT=${VPN_PORT:-443}

require_root
require_supported_os

[[ $ADMIN_USER =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || die "Некорректное имя пользователя: $ADMIN_USER"
if ! [[ $SSH_PORT =~ ^[0-9]+$ ]] || (( SSH_PORT < 1 || SSH_PORT > 65535 )); then
  die "Некорректный SSH_PORT: $SSH_PORT"
fi
[[ $SSH_PORT != "$VPN_PORT" ]] || die "SSH_PORT и VPN_PORT не могут совпадать."

# --- Защита от потери доступа: без SSH-ключа пароли не отключаем ---------------
# Ключи берём у root и у пользователя, который запустил скрипт через sudo
# (у некоторых провайдеров вход сразу под ubuntu/debian, а не под root).
KEY_RE='^(ssh-|ecdsa-|sk-)'   # строки без опций: forced-command "login as ubuntu" не копируем
KEY_SOURCES=(/root/.ssh/authorized_keys)
if [[ -n ${SUDO_USER:-} && $SUDO_USER != root && $SUDO_USER != "$ADMIN_USER" ]]; then
  KEY_SOURCES+=("$(getent passwd "$SUDO_USER" | cut -d: -f6)/.ssh/authorized_keys")
fi
ADMIN_HOME=/home/$ADMIN_USER
ADMIN_KEYS=$ADMIN_HOME/.ssh/authorized_keys
if ! grep -qsE "$KEY_RE" "${KEY_SOURCES[@]}" "$ADMIN_KEYS"; then
  die "Не найден SSH-ключ (${KEY_SOURCES[*]} $ADMIN_KEYS).
    Добавь публичный ключ при создании сервера (или: ssh-copy-id root@IP) и запусти снова.
    Без ключа отключение входа по паролю заблокирует тебя на сервере."
fi

# --- Пакеты ------------------------------------------------------------------
log "Обновляю систему (может занять пару минут)…"
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a
apt-get update -qq
apt-get upgrade -y -qq -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold >/dev/null
apt_install ufw fail2ban python3-systemd unattended-upgrades \
  curl ca-certificates jq qrencode openssl unzip tmux git sudo

# --- Пользователь-администратор ----------------------------------------------
PASS_FILE=/root/.admin-password
if id "$ADMIN_USER" &>/dev/null; then
  log "Пользователь $ADMIN_USER уже существует — пароль не меняю."
else
  log "Создаю пользователя $ADMIN_USER…"
  useradd -m -s /bin/bash "$ADMIN_USER"
  ADMIN_PASS=$(openssl rand -base64 18 | tr -d '/+=' | cut -c1-20)
  echo "$ADMIN_USER:$ADMIN_PASS" | chpasswd
  (umask 077; printf '%s\n' "$ADMIN_PASS" > "$PASS_FILE")
fi
usermod -aG sudo "$ADMIN_USER"

install -d -m 700 -o "$ADMIN_USER" -g "$ADMIN_USER" "$ADMIN_HOME/.ssh"
touch "$ADMIN_KEYS"
for src in "${KEY_SOURCES[@]}"; do
  [[ -s $src ]] || continue
  # Добавляем ключи, не дублируя уже существующие строки.
  while IFS= read -r line; do
    [[ $line =~ $KEY_RE ]] || continue
    grep -qxF -- "$line" "$ADMIN_KEYS" || printf '%s\n' "$line" >> "$ADMIN_KEYS"
  done < "$src"
done
chown "$ADMIN_USER:$ADMIN_USER" "$ADMIN_KEYS"
chmod 600 "$ADMIN_KEYS"
grep -qsE "$KEY_RE" "$ADMIN_KEYS" || die "У $ADMIN_USER не оказалось SSH-ключей — прерываюсь, чтобы не потерять доступ."

# --- Файрвол (до смены настроек SSH, чтобы новый порт уже был открыт) ---------
log "Настраиваю файрвол UFW (SSH $SSH_PORT/tcp, VPN $VPN_PORT/tcp)…"
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null
ufw allow "$SSH_PORT/tcp" comment 'SSH' >/dev/null
ufw allow "$VPN_PORT/tcp" comment 'VPN (VLESS Reality)' >/dev/null
ufw --force enable >/dev/null

# --- SSH ---------------------------------------------------------------------
# Файл с префиксом 00-, потому что в sshd_config.d побеждает ПЕРВОЕ значение,
# а облачные образы кладут 50-cloud-init.conf с PasswordAuthentication yes.
log "Закрываю SSH: только ключи, без root, порт $SSH_PORT…"
cat > /etc/ssh/sshd_config.d/00-hardening.conf <<CONF
# Создано server/01-harden.sh
Port $SSH_PORT
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
AllowUsers $ADMIN_USER
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
ClientAliveInterval 60
ClientAliveCountMax 3
CONF
grep -qE '^\s*Include\s+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config \
  || sed -i '1i Include /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config
mkdir -p /run/sshd
sshd -t || die "Ошибка в конфигурации sshd — изменения не применены."

# Ubuntu 24.04 запускает SSH через ssh.socket: порт берётся генератором из sshd_config.
systemctl daemon-reload
if systemctl is-active --quiet ssh.socket; then
  systemctl restart ssh.socket
  systemctl restart ssh.service 2>/dev/null || true
elif systemctl cat ssh.service &>/dev/null; then
  systemctl restart ssh.service
else
  systemctl restart sshd.service
fi
# Текущая SSH-сессия при этом не обрывается.

# --- fail2ban ----------------------------------------------------------------
log "Включаю fail2ban для SSH…"
cat > /etc/fail2ban/jail.local <<CONF
# Создано server/01-harden.sh
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd

[sshd]
enabled = true
port    = $SSH_PORT
CONF
systemctl enable --now fail2ban >/dev/null 2>&1
systemctl restart fail2ban

# --- Автообновления безопасности ---------------------------------------------
log "Включаю автоматические обновления безопасности…"
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'CONF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
CONF
systemctl enable --now unattended-upgrades >/dev/null 2>&1 || true

# --- Сеть: BBR ---------------------------------------------------------------
cat > /etc/sysctl.d/90-vpn-bbr.conf <<'CONF'
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
CONF
sysctl --system >/dev/null 2>&1 || warn "Не удалось применить sysctl (BBR) — не критично."

# --- Swap (Claude Code нужно 4 ГБ RAM; swap страхует от OOM) -------------------
if [[ -z $(swapon --show --noheadings) ]]; then
  log "Создаю swap 2 ГБ…"
  if fallocate -l 2G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none; then
    chmod 600 /swapfile
    mkswap /swapfile >/dev/null
    swapon /swapfile
    grep -q '^/swapfile ' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo 'vm.swappiness = 10' > /etc/sysctl.d/90-swappiness.conf
    sysctl -q -p /etc/sysctl.d/90-swappiness.conf || true
  else
    warn "Не удалось создать swap — не критично."
  fi
fi

# --- Итог --------------------------------------------------------------------
echo
bold "Шаг 1 готов: сервер защищён."
echo "  Вход:      ssh -p $SSH_PORT $ADMIN_USER@$(detect_public_ip)"
echo "  root-вход по SSH и пароли отключены."
if [[ -f $PASS_FILE ]]; then
  echo "  Пароль для sudo пользователя $ADMIN_USER: $(cat "$PASS_FILE")"
  echo "  (копия лежит в $PASS_FILE — сохрани в менеджер паролей)"
fi
warn "НЕ закрывай текущее окно, пока не проверишь вход новым пользователем в другом окне."
