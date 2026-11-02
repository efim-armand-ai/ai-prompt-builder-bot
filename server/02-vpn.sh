#!/usr/bin/env bash
# Шаг 2. VPN: Xray (VLESS + Reality) на 443/tcp.
#
# Почему не WireGuard/OpenVPN: их легко распознать по трафику, и в ряде стран
# их режут. VLESS + Reality для внешнего наблюдателя выглядит как обычный
# HTTPS-заход на крупный сайт (REALITY_SNI) и работает и там, где блокировок нет.
#
# Переменные (необязательные):
#   VPN_DEVICES="iphone mac"     устройства, которые создать сразу (по умолчанию: device1)
#   VPN_PORT=443                 порт VPN
#   REALITY_SNI=www.microsoft.com сайт, под который маскируется трафик
#                                (нужны TLS 1.3 и HTTP/2; скрипт проверит)
#   SERVER_ADDR=1.2.3.4          публичный IP/домен (по умолчанию определяется сам)
#
# Повторный запуск безопасен: ключи и устройства сохраняются.
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck source=lib.sh
source ./lib.sh

VPN_PORT=${VPN_PORT:-443}
REALITY_SNI=${REALITY_SNI:-}
VPN_DEVICES=${VPN_DEVICES:-device1}
SERVER_ADDR=${SERVER_ADDR:-$(detect_public_ip)}

require_root
require_supported_os
[[ -n $SERVER_ADDR ]] || die "Не удалось определить публичный IP. Задай вручную: SERVER_ADDR=1.2.3.4 bash $0"

apt_install curl ca-certificates jq qrencode openssl unzip

# --- Xray --------------------------------------------------------------------
log "Устанавливаю/обновляю Xray (официальный установщик XTLS/Xray-install)…"
INSTALLER=$(mktemp)
trap 'rm -f "$INSTALLER"' EXIT
curl -fsSL https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh -o "$INSTALLER" \
  || die "Не удалось скачать установщик Xray (нет доступа к GitHub?)."
bash "$INSTALLER" install >/dev/null || die "Установка Xray завершилась ошибкой."
[[ -x /usr/local/bin/xray ]] || die "После установки не найден /usr/local/bin/xray."
/usr/local/bin/xray version | head -1

install -m 755 ./vpn.sh /usr/local/bin/vpn

# --- Проверка сайта для маскировки -------------------------------------------
STATE=/usr/local/etc/xray/reality.env
if [[ -z $REALITY_SNI && -r $STATE ]]; then
  # shellcheck disable=SC1090
  REALITY_SNI=$(. "$STATE"; printf '%s' "$SNI")
fi
REALITY_SNI=${REALITY_SNI:-www.microsoft.com}
log "Проверяю, что $REALITY_SNI отдаёт TLS 1.3 + HTTP/2…"
HTTP_VER=$(curl -sS -o /dev/null --max-time 10 --tlsv1.3 --http2 -w '%{http_version}' "https://$REALITY_SNI/" 2>/dev/null || true)
if [[ $HTTP_VER != 2 ]]; then
  die "$REALITY_SNI не подходит (TLS 1.3 + HTTP/2 недоступны с этого сервера, получено: '${HTTP_VER:-ошибка}').
    Выбери другой сайт: REALITY_SNI=www.apple.com bash $0"
fi

# --- Конфиг и устройства -----------------------------------------------------
log "Создаю ключи и конфиг…"
REALITY_SNI=$REALITY_SNI VPN_PORT=$VPN_PORT SERVER_ADDR=$SERVER_ADDR vpn init

systemctl enable xray >/dev/null 2>&1
systemctl restart xray
sleep 1
systemctl is-active --quiet xray || die "Xray не запустился: journalctl -u xray -n 50"

if command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
  ufw allow "$VPN_PORT/tcp" comment 'VPN (VLESS Reality)' >/dev/null
fi

existing=$(vpn list | sed -n 's/^  - //p')
for dev in $VPN_DEVICES; do
  if grep -qxF -- "$dev" <<<"$existing"; then
    log "Устройство $dev уже есть — пропускаю."
  else
    vpn add "$dev"
  fi
done

echo
bold "Шаг 2 готов: VPN работает на $SERVER_ADDR:$VPN_PORT."
echo "  Добавить устройство:   sudo vpn add <имя>     (например: sudo vpn add ipad)"
echo "  Показать QR/ссылку:    sudo vpn show <имя>"
echo "  Список / удалить:      sudo vpn list  /  sudo vpn remove <имя>"
