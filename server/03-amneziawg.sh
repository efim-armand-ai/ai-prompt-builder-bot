#!/usr/bin/env bash
# Шаг 3. AmneziaWG — туннель для домашнего роутера.
#
# Зачем отдельно от VLESS: роутер с поддержкой AmneziaWG заводит в туннель
# устройства, на которые клиент не поставить (ТВ-приставки), и любые другие
# устройства дома — по правилам маршрутизации на роутере.
#
# Параметры маскировки — уровня AmneziaWG 1.0 (Jc/Jmin/Jmax/S1/S2/H1-H4):
# их понимает любая реализация AWG, включая прошивки с поддержкой 3.x.
# Серверная часть — официальный модуль ядра из PPA Amnezia.
#
# Переменные (необязательные):
#   AWG_PEERS="home-router"   пиры, которые создать сразу
#   AWG_PORT=<случайный>      UDP-порт (по умолчанию случайный 20000–60000, запоминается)
#   SERVER_ADDR=1.2.3.4       публичный IP/домен (по умолчанию определяется сам)
#
# Повторный запуск безопасен: ключи, порт и пиры сохраняются.
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=lib.sh
source ./lib.sh

AWG_PEERS=${AWG_PEERS:-home-router}
AWG_PORT=${AWG_PORT:-}
SERVER_ADDR=${SERVER_ADDR:-$(detect_public_ip)}

require_root
require_supported_os
# shellcheck disable=SC1091
. /etc/os-release
[[ $ID == ubuntu ]] || die "AmneziaWG ставится из PPA Amnezia — поддерживается только Ubuntu 22.04/24.04."
[[ -n $SERVER_ADDR ]] || die "Не удалось определить публичный IP. Задай вручную: SERVER_ADDR=1.2.3.4 bash $0"

# --- Пакеты ------------------------------------------------------------------
log "Устанавливаю AmneziaWG (PPA amnezia/ppa, модуль ядра через DKMS)…"
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a
KREL=$(uname -r)
FLAVOUR=${KREL#*-*-}                       # 6.8.0-45-generic → generic
apt_install software-properties-common python3-launchpadlib gnupg2 iptables qrencode "linux-headers-$KREL"
# Мета-пакет заголовков: чтобы DKMS пересобирал модуль и для будущих ядер.
if apt-cache show "linux-headers-$FLAVOUR" &>/dev/null; then
  apt_install "linux-headers-$FLAVOUR" || warn "Не удалось поставить linux-headers-$FLAVOUR — после обновления ядра перезапусти этот скрипт."
fi
if ! grep -rqs 'amnezia/ppa' /etc/apt/sources.list /etc/apt/sources.list.d/; then
  add-apt-repository -y ppa:amnezia/ppa >/dev/null
fi
apt-get update -qq
apt_install amneziawg

if ! command -v awg >/dev/null || ! command -v awg-quick >/dev/null; then
  die "После установки не найдены awg/awg-quick."
fi
if ! modprobe amneziawg 2>/dev/null; then
  die "Модуль ядра amneziawg не загрузился (ядро $KREL).
    Обычно это значит, что на шаге 1 обновилось ядро: выполни  sudo reboot
    и после перезагрузки запусти этот скрипт снова:  sudo bash /opt/vps-setup/03-amneziawg.sh"
fi

# --- Маршрутизация -----------------------------------------------------------
echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/90-awg-forward.conf
sysctl -q -p /etc/sysctl.d/90-awg-forward.conf

# --- systemd-юнит (если пакет его не принёс) -----------------------------------
if ! systemctl cat awg-quick@.service &>/dev/null; then
  AWGQ=$(command -v awg-quick)
  cat > /etc/systemd/system/awg-quick@.service <<UNIT
[Unit]
Description=AmneziaWG via awg-quick for %I
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$AWGQ up %i
ExecStop=$AWGQ down %i

[Install]
WantedBy=multi-user.target
UNIT
  systemctl daemon-reload
fi

# --- Конфиг, сервис, файрвол, пиры ----------------------------------------------
install -m 755 ./vpn.sh /usr/local/bin/vpn
SERVER_ADDR=$SERVER_ADDR AWG_PORT=$AWG_PORT vpn awg-init
PORT=$(vpn awg-port)

systemctl enable awg-quick@awg0 >/dev/null 2>&1
systemctl restart awg-quick@awg0
systemctl is-active --quiet awg-quick@awg0 || die "AmneziaWG не запустился: journalctl -u awg-quick@awg0 -n 50"

if command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
  ufw allow "$PORT/udp" comment 'AmneziaWG' >/dev/null
fi

for peer in $AWG_PEERS; do
  if vpn link "$peer" &>/dev/null; then
    log "Пир $peer уже есть — пропускаю."
  else
    vpn add-awg "$peer"
  fi
done

echo
bold "Шаг 3 готов: AmneziaWG работает на $SERVER_ADDR:$PORT/udp."
echo "  Конфиг для роутера:   sudo vpn link home-router > home-router.conf"
echo "  Ещё пир / удалить:    sudo vpn add-awg <имя>  /  sudo vpn remove <имя>"
warn "Если у провайдера VPS есть облачный файрвол — открой в нём $PORT/udp."
