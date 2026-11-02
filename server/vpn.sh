#!/usr/bin/env bash
# Управление VPN (Xray, VLESS + Reality). Устанавливается как /usr/local/bin/vpn.
#
#   sudo vpn add iphone        добавить устройство, показать ссылку и QR-код
#   sudo vpn show iphone       снова показать ссылку и QR-код
#   sudo vpn link iphone       только ссылка (удобно копировать)
#   sudo vpn list              список устройств
#   sudo vpn remove iphone     отключить устройство (остальные продолжают работать)
#   sudo vpn status            состояние сервиса и параметры сервера
#   sudo vpn init              создать ключи и конфиг (вызывается из 02-vpn.sh)
#
# У каждого устройства свой UUID: потерял телефон — удалил одно устройство,
# остальные 9 перенастраивать не нужно.
set -euo pipefail

XRAY_BIN=${XRAY_BIN:-/usr/local/bin/xray}
XRAY_CONFIG=${XRAY_CONFIG:-/usr/local/etc/xray/config.json}
VPN_STATE=${VPN_STATE:-/usr/local/etc/xray/reality.env}
VPN_NO_RESTART=${VPN_NO_RESTART:-0}
INBOUND_TAG=vless-reality

die()  { printf '[x] %s\n' "$*" >&2; exit 1; }
warn() { printf '[!] %s\n' "$*" >&2; }

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

require_root() {
  [[ $VPN_NO_RESTART == 1 || ${EUID:-$(id -u)} -eq 0 ]] || die "Нужен root: sudo vpn $*"
}

load_state() {
  [[ -r $VPN_STATE ]] || die "Нет $VPN_STATE — сначала выполни: sudo vpn init"
  # shellcheck disable=SC1090
  source "$VPN_STATE"
  : "${PRIVATE_KEY:?}" "${PUBLIC_KEY:?}" "${SHORT_ID:?}" "${SNI:?}" "${PORT:?}" "${SERVER_ADDR:?}"
}

valid_name() {
  [[ $1 =~ ^[A-Za-z0-9_-]{1,32}$ ]] || die "Имя устройства: латиница, цифры, _ и -, до 32 символов (например iphone, mac-work)."
}

# Пишем конфиг атомарно и только после проверки самим Xray.
apply_config() {
  local tmp=$1
  "$XRAY_BIN" run -test -config "$tmp" >/dev/null 2>&1 \
    || { "$XRAY_BIN" run -test -config "$tmp" >&2 || true; rm -f "$tmp"; die "Xray отклонил новый конфиг — изменения не применены."; }
  if getent group xray >/dev/null 2>&1; then
    chown root:xray "$tmp"; chmod 640 "$tmp"
  else
    chmod 644 "$tmp"
  fi
  mv -f "$tmp" "$XRAY_CONFIG"
  if [[ $VPN_NO_RESTART != 1 ]]; then
    systemctl restart xray
    sleep 1
    systemctl is-active --quiet xray || die "Xray не запустился: journalctl -u xray -n 50"
  fi
}

new_tmp() { mktemp "${XRAY_CONFIG}.XXXXXX"; }

client_uuid() {
  jq -r --arg tag "$INBOUND_TAG" --arg n "$1" \
    '.inbounds[] | select(.tag==$tag) | .settings.clients[] | select(.email==$n) | .id' "$XRAY_CONFIG"
}

make_link() {
  local name=$1 uuid=$2
  printf 'vless://%s@%s:%s?encryption=none&flow=xtls-rprx-vision&security=reality&sni=%s&fp=chrome&pbk=%s&sid=%s&type=tcp&headerType=none#%s\n' \
    "$uuid" "$SERVER_ADDR" "$PORT" "$SNI" "$PUBLIC_KEY" "$SHORT_ID" "$name"
}

print_device() {
  local name=$1 uuid link
  uuid=$(client_uuid "$name")
  [[ -n $uuid ]] || die "Устройство '$name' не найдено. Список: sudo vpn list"
  link=$(make_link "$name" "$uuid")
  echo
  echo "Устройство: $name"
  echo "Ссылка (импортируй в клиент через «Добавить из буфера/по ссылке»):"
  echo
  echo "$link"
  echo
  if command -v qrencode >/dev/null; then
    echo "Или отсканируй QR-код клиентом на телефоне:"
    qrencode -t ANSIUTF8 -m 2 "$link"
  fi
}

cmd_init() {
  require_root init
  local regen=0
  [[ ${1:-} == --regen-keys ]] && regen=1
  [[ -x $XRAY_BIN ]] || die "Не найден $XRAY_BIN — сначала установи Xray (02-vpn.sh)."
  command -v jq >/dev/null || die "Нужен jq: apt install jq"

  local sni=${REALITY_SNI:-} port=${VPN_PORT:-} addr=${SERVER_ADDR:-}
  local priv="" pub="" sid=""
  if [[ -r $VPN_STATE ]]; then
    # shellcheck disable=SC1090
    source "$VPN_STATE"
    sni=${REALITY_SNI:-$SNI}; port=${VPN_PORT:-$PORT}; addr=${addr:-$SERVER_ADDR}
    if [[ $regen == 0 ]]; then
      priv=$PRIVATE_KEY; pub=$PUBLIC_KEY; sid=$SHORT_ID
    fi
  fi
  sni=${sni:-www.microsoft.com}
  port=${port:-443}
  [[ -n $addr ]] || die "Не задан SERVER_ADDR (публичный IP или домен сервера)."
  if ! [[ $port =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then die "Некорректный порт: $port"; fi
  [[ $sni =~ ^[A-Za-z0-9.-]+$ ]] || die "Некорректный REALITY_SNI: $sni"
  [[ $addr =~ ^[A-Za-z0-9.:-]+$ ]] || die "Некорректный SERVER_ADDR: $addr"

  if [[ -z $priv ]]; then
    local out
    out=$("$XRAY_BIN" x25519)
    # Формат вывода менялся между версиями Xray:
    #   старый: "Private key: …" / "Public key: …"
    #   новый:  "PrivateKey: …"  / "Password (PublicKey): …"
    priv=$(awk -F': *' 'tolower($1) ~ /^private ?key$/ {print $2; exit}' <<<"$out")
    pub=$(awk -F': *' 'tolower($1) ~ /^(public ?key|password.*)$/ {print $2; exit}' <<<"$out")
    [[ -n $priv && -n $pub ]] || die "Не смог разобрать вывод 'xray x25519':
$out"
    sid=$(openssl rand -hex 8)
  fi

  umask 077
  mkdir -p "$(dirname "$VPN_STATE")"
  cat > "$VPN_STATE" <<EOF
# Параметры VPN-сервера. PRIVATE_KEY — секрет, никому не показывай.
PRIVATE_KEY='$priv'
PUBLIC_KEY='$pub'
SHORT_ID='$sid'
SNI='$sni'
PORT='$port'
SERVER_ADDR='$addr'
EOF
  chmod 600 "$VPN_STATE"

  # Сохраняем уже созданные устройства при повторном запуске.
  local clients='[]'
  if [[ -r $XRAY_CONFIG ]]; then
    clients=$(jq -c --arg tag "$INBOUND_TAG" \
      '[.inbounds[]? | select(.tag==$tag) | .settings.clients[]?] // []' "$XRAY_CONFIG" 2>/dev/null || echo '[]')
  fi

  local tmp
  tmp=$(new_tmp)
  jq -n \
    --arg tag "$INBOUND_TAG" --argjson port "$port" --arg sni "$sni" \
    --arg priv "$priv" --arg sid "$sid" --argjson clients "$clients" '
  {
    log: { loglevel: "warning" },
    inbounds: [{
      tag: $tag,
      port: $port,
      protocol: "vless",
      settings: { clients: $clients, decryption: "none" },
      streamSettings: {
        network: "tcp",
        security: "reality",
        realitySettings: {
          show: false,
          dest: ($sni + ":443"),
          xver: 0,
          serverNames: [$sni],
          privateKey: $priv,
          shortIds: [$sid]
        }
      },
      sniffing: { enabled: true, destOverride: ["http", "tls", "quic"], routeOnly: true }
    }],
    outbounds: [
      { tag: "direct", protocol: "freedom" },
      { tag: "block",  protocol: "blackhole" }
    ],
    routing: {
      domainStrategy: "AsIs",
      rules: [
        { type: "field", outboundTag: "block",
          ip: ["0.0.0.0/8", "10.0.0.0/8", "100.64.0.0/10", "127.0.0.0/8", "169.254.0.0/16",
               "172.16.0.0/12", "192.168.0.0/16", "::1/128", "fc00::/7", "fe80::/10"] },
        { type: "field", outboundTag: "block", protocol: ["bittorrent"] }
      ]
    }
  }' > "$tmp"
  apply_config "$tmp"
  echo "VPN настроен: $addr:$port, маскировка под $sni, устройств: $(jq length <<<"$clients")."
}

cmd_add() {
  require_root add
  local name=${1:-}
  [[ -n $name ]] || die "Укажи имя: sudo vpn add iphone"
  valid_name "$name"
  load_state
  [[ -z $(client_uuid "$name") ]] || die "Устройство '$name' уже есть. Показать: sudo vpn show $name"
  local uuid tmp
  uuid=$("$XRAY_BIN" uuid)
  tmp=$(new_tmp)
  jq --arg tag "$INBOUND_TAG" --arg n "$name" --arg id "$uuid" \
    '(.inbounds[] | select(.tag==$tag) | .settings.clients) += [{id: $id, email: $n, flow: "xtls-rprx-vision"}]' \
    "$XRAY_CONFIG" > "$tmp"
  apply_config "$tmp"
  print_device "$name"
}

cmd_remove() {
  require_root remove
  local name=${1:-}
  [[ -n $name ]] || die "Укажи имя: sudo vpn remove iphone"
  load_state
  [[ -n $(client_uuid "$name") ]] || die "Устройство '$name' не найдено."
  local tmp
  tmp=$(new_tmp)
  jq --arg tag "$INBOUND_TAG" --arg n "$name" \
    '(.inbounds[] | select(.tag==$tag) | .settings.clients) |= map(select(.email != $n))' \
    "$XRAY_CONFIG" > "$tmp"
  apply_config "$tmp"
  echo "Устройство '$name' отключено."
}

cmd_list() {
  load_state
  local n
  n=$(jq --arg tag "$INBOUND_TAG" '[.inbounds[] | select(.tag==$tag) | .settings.clients[]] | length' "$XRAY_CONFIG")
  echo "Устройств: $n"
  jq -r --arg tag "$INBOUND_TAG" '.inbounds[] | select(.tag==$tag) | .settings.clients[] | "  - \(.email)"' "$XRAY_CONFIG"
}

cmd_status() {
  load_state
  echo "Сервер:      $SERVER_ADDR:$PORT"
  echo "Маскировка:  $SNI"
  echo "Public key:  $PUBLIC_KEY"
  echo "Short ID:    $SHORT_ID"
  if [[ $VPN_NO_RESTART != 1 ]]; then
    printf 'Xray:        '; systemctl is-active xray || true
    "$XRAY_BIN" version 2>/dev/null | head -1 | sed 's/^/Версия:      /'
  fi
  cmd_list
}

main() {
  local cmd=${1:-}
  shift || true
  case "$cmd" in
    init)          cmd_init "$@" ;;
    add)           cmd_add "$@" ;;
    remove|rm|del) cmd_remove "$@" ;;
    list|ls)       require_root list; cmd_list ;;
    show|qr)       require_root show; [[ -n ${1:-} ]] || die "Укажи имя: sudo vpn show iphone"; load_state; print_device "$1" ;;
    link)          require_root link; [[ -n ${1:-} ]] || die "Укажи имя: sudo vpn link iphone"; load_state
                   local uuid; uuid=$(client_uuid "$1"); [[ -n $uuid ]] || die "Устройство '$1' не найдено."
                   make_link "$1" "$uuid" ;;
    status)        require_root status; cmd_status ;;
    -h|--help|help|"") usage 0 ;;
    *) warn "Неизвестная команда: $cmd"; usage 1 ;;
  esac
}

main "$@"
