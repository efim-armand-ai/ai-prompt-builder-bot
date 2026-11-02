#!/usr/bin/env bash
# Управление VPN. Устанавливается как /usr/local/bin/vpn.
#   sudo vpn add iphone1          устройство VLESS+Reality: ссылка и QR-код
#   sudo vpn add-awg home-router  пир AmneziaWG (для роутера): .conf и QR-код
#   sudo vpn show <имя>           снова показать ссылку/конфиг и QR-код
#   sudo vpn link <имя>           только ссылка/конфиг (sudo vpn link home-router > home-router.conf)
#   sudo vpn list                 все устройства
#   sudo vpn remove <имя>         отключить устройство (остальные продолжают работать)
#   sudo vpn status               состояние сервисов и параметры сервера
#   sudo vpn init | awg-init      создать ключи и конфиги (вызывается из 02-vpn.sh / 03-amneziawg.sh)
#
# У каждого устройства свой ключ: потерял телефон — удалил одно устройство,
# остальные перенастраивать не нужно.
set -euo pipefail

XRAY_BIN=${XRAY_BIN:-/usr/local/bin/xray}
XRAY_CONFIG=${XRAY_CONFIG:-/usr/local/etc/xray/config.json}
VPN_STATE=${VPN_STATE:-/usr/local/etc/xray/reality.env}
VPN_NO_RESTART=${VPN_NO_RESTART:-0}
INBOUND_TAG=vless-reality

AWG_BIN=${AWG_BIN:-awg}
AWG_IF=${AWG_IF:-awg0}
AWG_NET=${AWG_NET:-10.66.66}      # подсеть /24, сервер — .1

die()  { printf '[x] %s\n' "$*" >&2; exit 1; }
warn() { printf '[!] %s\n' "$*" >&2; }

usage() {
  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
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

vless_uuid_safe() {
  [[ -r $XRAY_CONFIG ]] || return 0
  client_uuid "$1" 2>/dev/null || true
}

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
  if awg_ready && awg_has_peer "$name"; then die "Имя '$name' уже занято пиром AmneziaWG."; fi
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
  valid_name "$name"
  if awg_ready && awg_has_peer "$name"; then cmd_awg_remove "$name"; return; fi
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
  if [[ -r $VPN_STATE && -r $XRAY_CONFIG ]]; then
    local n
    n=$(jq --arg tag "$INBOUND_TAG" '[.inbounds[] | select(.tag==$tag) | .settings.clients[]] | length' "$XRAY_CONFIG")
    echo "VLESS+Reality (телефоны, планшеты, компьютеры): $n"
    jq -r --arg tag "$INBOUND_TAG" '.inbounds[] | select(.tag==$tag) | .settings.clients[] | "  - \(.email)"' "$XRAY_CONFIG"
  fi
  awg_list
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
  if awg_ready; then
    # shellcheck disable=SC1090
    source "$AWG_ENV"
    echo "AmneziaWG:   $AWG_ADDR:$AWG_PORT/udp"
    if [[ $VPN_NO_RESTART != 1 ]]; then
      printf 'awg-quick:   '; systemctl is-active "awg-quick@$AWG_IF" || true
      "$AWG_BIN" show "$AWG_IF" latest-handshakes 2>/dev/null \
        | while read -r key ts; do
            if [[ $ts == 0 ]]; then echo "  последний handshake ${key:0:8}…: ещё не было"
            else echo "  последний handshake ${key:0:8}…: $(date -d "@$ts" '+%F %T')"; fi
          done || true
    fi
  fi
  cmd_list
}

# ============================ AmneziaWG ======================================
# Каталог конфигов awg-quick: берём из самого awg-quick, иначе стандартный.
awg_dir() {
  if [[ -n ${AWG_DIR:-} ]]; then printf '%s' "$AWG_DIR"; return; fi
  local q d=""
  q=$(command -v awg-quick 2>/dev/null || true)
  [[ -n $q ]] && d=$(grep -oE 'CONFIG_SEARCH_PATHS=\( *[^ )]+' "$q" 2>/dev/null | head -1 | sed 's/.*( *//')
  printf '%s' "${d:-/etc/amnezia/amneziawg}"
}

awg_paths() {
  AWG_DIR=$(awg_dir)
  AWG_CONF=$AWG_DIR/$AWG_IF.conf
  AWG_CLIENTS=$AWG_DIR/clients
  AWG_ENV=$AWG_DIR/server.env
}

awg_ready() { awg_paths; [[ -r $AWG_CONF && -r $AWG_ENV ]]; }

awg_load() {
  awg_ready || die "AmneziaWG не настроен — выполни: sudo bash /opt/vps-setup/03-amneziawg.sh"
  # shellcheck disable=SC1090
  source "$AWG_ENV"
  : "${AWG_ADDR:?}" "${AWG_PORT:?}" "${AWG_SERVER_PUB:?}"
}

awg_param() { awk -F' *= *' -v k="$1" '$1==k {print $2; exit}' "$AWG_CONF"; }

awg_has_peer() { [[ -f $AWG_CLIENTS/$1.conf ]]; }

awg_apply() {
  [[ $VPN_NO_RESTART == 1 ]] && return 0
  # Без разрыва текущих соединений, если получится; иначе — перезапуск интерфейса.
  if ip link show "$AWG_IF" &>/dev/null \
     && "$AWG_BIN" syncconf "$AWG_IF" <(awg-quick strip "$AWG_IF") 2>/dev/null; then
    return 0
  fi
  systemctl restart "awg-quick@$AWG_IF" || die "AmneziaWG не запустился: journalctl -u awg-quick@$AWG_IF -n 50"
}

cmd_awg_init() {
  require_root awg-init
  command -v "$AWG_BIN" >/dev/null || die "Не найден $AWG_BIN — установи AmneziaWG (03-amneziawg.sh)."
  awg_paths
  local addr=${SERVER_ADDR:-} port=${AWG_PORT:-}
  if [[ -r $AWG_ENV ]]; then
    # shellcheck disable=SC1090
    source "$AWG_ENV"
    addr=${SERVER_ADDR:-$AWG_ADDR}
  fi
  [[ -n $addr ]] || die "Не задан SERVER_ADDR (публичный IP или домен сервера)."
  [[ $addr =~ ^[A-Za-z0-9.:-]+$ ]] || die "Некорректный SERVER_ADDR: $addr"

  umask 077
  mkdir -p "$AWG_DIR" "$AWG_CLIENTS"

  if [[ -f $AWG_CONF ]]; then
    port=$(awg_param ListenPort)
    echo "Конфиг $AWG_CONF уже есть — ключи и параметры сохраняю."
  else
    port=${port:-$(shuf -i 20000-60000 -n 1)}
    if ! [[ $port =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then die "Некорректный AWG_PORT: $port"; fi
    local wan priv jc s1 s2 h
    wan=${WAN_IF:-$(ip -4 route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')}
    [[ -n $wan ]] || die "Не удалось определить внешний интерфейс. Задай WAN_IF=eth0."
    priv=$("$AWG_BIN" genkey)
    # Параметры маскировки AmneziaWG 1.0 — их понимает любая реализация AWG (1.0 … 3.x).
    jc=$(shuf -i 4-8 -n 1)
    s1=$(shuf -i 15-150 -n 1)
    while :; do s2=$(shuf -i 15-150 -n 1); (( s1 + 56 != s2 )) && break; done
    mapfile -t h < <(shuf -i 5-2147483647 -n 4)
    local private_nets="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16,100.64.0.0/10"
    cat > "$AWG_CONF" <<EOF
# Generated by "vpn awg-init". Secret: contains the server private key.
[Interface]
PrivateKey = $priv
Address = $AWG_NET.1/24
ListenPort = $port
Jc = $jc
Jmin = 40
Jmax = 70
S1 = $s1
S2 = $s2
H1 = ${h[0]}
H2 = ${h[1]}
H3 = ${h[2]}
H4 = ${h[3]}
# Peers may reach the internet through the server, but not private/provider networks.
PostUp = iptables -I FORWARD 1 -i %i -j ACCEPT
PostUp = iptables -I FORWARD 1 -i %i -d $private_nets -j DROP
PostUp = iptables -I FORWARD 1 -o %i -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -s $AWG_NET.0/24 -o $wan -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -D FORWARD -i %i -d $private_nets -j DROP
PostDown = iptables -D FORWARD -o %i -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -s $AWG_NET.0/24 -o $wan -j MASQUERADE
EOF
    chmod 600 "$AWG_CONF"
  fi

  local pub
  pub=$("$AWG_BIN" pubkey <<<"$(awg_param PrivateKey)")
  cat > "$AWG_ENV" <<EOF
AWG_ADDR='$addr'
AWG_PORT='$port'
AWG_SERVER_PUB='$pub'
EOF
  chmod 600 "$AWG_ENV"
  echo "AmneziaWG: $addr:$port/udp, подсеть $AWG_NET.0/24."
}

awg_next_ip() {
  local used n
  used=$(grep -hoE "^AllowedIPs = $AWG_NET\.[0-9]+" "$AWG_CONF" | awk -F. '{print $4}')
  for n in $(seq 2 254); do
    grep -qx "$n" <<<"$used" || { printf '%s' "$n"; return; }
  done
  die "В подсети $AWG_NET.0/24 закончились адреса."
}

print_awg() {
  local name=$1 f=$AWG_CLIENTS/$1.conf
  echo
  echo "Пир AmneziaWG: $name"
  echo "Импортируй в роутер/приложение AmneziaWG как файл .conf. Сохранить в файл:"
  echo "  sudo vpn link $name > $name.conf"
  echo
  cat "$f"
  echo
  if command -v qrencode >/dev/null; then
    echo "Или отсканируй QR-код (приложение AmneziaVPN/AmneziaWG):"
    qrencode -t ANSIUTF8 -m 2 < "$f"
  fi
}

cmd_awg_add() {
  require_root add-awg
  local name=${1:-}
  [[ -n $name ]] || die "Укажи имя: sudo vpn add-awg home-router"
  valid_name "$name"
  awg_load
  awg_has_peer "$name" && die "Пир '$name' уже есть. Показать: sudo vpn show $name"
  [[ -n $(vless_uuid_safe "$name") ]] && die "Имя '$name' уже занято устройством VLESS."
  local ip cpriv cpub psk k
  ip=$AWG_NET.$(awg_next_ip)
  cpriv=$("$AWG_BIN" genkey)
  cpub=$("$AWG_BIN" pubkey <<<"$cpriv")
  psk=$("$AWG_BIN" genpsk)

  cat >> "$AWG_CONF" <<EOF

### peer $name
[Peer]
PublicKey = $cpub
PresharedKey = $psk
AllowedIPs = $ip/32
### end $name
EOF

  {
    echo "[Interface]"
    echo "PrivateKey = $cpriv"
    echo "Address = $ip/32"
    echo "DNS = 1.1.1.1, 8.8.8.8"
    echo "MTU = 1280"
    for k in Jc Jmin Jmax S1 S2 H1 H2 H3 H4; do echo "$k = $(awg_param "$k")"; done
    echo
    echo "[Peer]"
    echo "PublicKey = $AWG_SERVER_PUB"
    echo "PresharedKey = $psk"
    echo "Endpoint = $AWG_ADDR:$AWG_PORT"
    echo "AllowedIPs = 0.0.0.0/0"
    echo "PersistentKeepalive = 25"
  } > "$AWG_CLIENTS/$name.conf"
  chmod 600 "$AWG_CLIENTS/$name.conf"

  awg_apply
  print_awg "$name"
}

cmd_awg_remove() {
  local name=$1
  awg_load
  sed -i "/^### peer $name\$/,/^### end $name\$/d" "$AWG_CONF"
  sed -i '/^$/N;/^\n$/D' "$AWG_CONF"   # схлопываем пустые строки на месте удалённого блока
  # Конфиг клиента не удаляем, а переносим в revoked/: ключ уже недействителен на сервере.
  mkdir -p "$AWG_CLIENTS/revoked"
  mv -f -- "$AWG_CLIENTS/$name.conf" "$AWG_CLIENTS/revoked/$name.$(date +%Y%m%d%H%M%S).conf"
  awg_apply
  echo "Пир AmneziaWG '$name' отключён."
}

awg_list() {
  awg_ready || return 0
  local names
  names=$(sed -n 's/^### peer //p' "$AWG_CONF")
  echo "AmneziaWG (роутер): $(grep -c . <<<"$names" || true)"
  local n
  while IFS= read -r n; do [[ -n $n ]] && echo "  - $n"; done <<<"$names"
  return 0
}

main() {
  local cmd=${1:-}
  shift || true
  case "$cmd" in
    init)          cmd_init "$@" ;;
    awg-init)      cmd_awg_init "$@" ;;
    awg-port)      awg_load; echo "$AWG_PORT" ;;   # служебная: для 03-amneziawg.sh
    add)           cmd_add "$@" ;;
    add-awg)       cmd_awg_add "$@" ;;
    remove|rm|del) cmd_remove "$@" ;;
    list|ls)       require_root list; cmd_list ;;
    show|qr)       require_root show; [[ -n ${1:-} ]] || die "Укажи имя: sudo vpn show iphone1"; valid_name "$1"
                   if awg_ready && awg_has_peer "$1"; then print_awg "$1"; else load_state; print_device "$1"; fi ;;
    link)          require_root link; [[ -n ${1:-} ]] || die "Укажи имя: sudo vpn link iphone1"; valid_name "$1"
                   if awg_ready && awg_has_peer "$1"; then cat "$AWG_CLIENTS/$1.conf"; return; fi
                   load_state
                   local uuid; uuid=$(client_uuid "$1"); [[ -n $uuid ]] || die "Устройство '$1' не найдено."
                   make_link "$1" "$uuid" ;;
    status)        require_root status; cmd_status ;;
    -h|--help|help|"") usage 0 ;;
    *) warn "Неизвестная команда: $cmd"; usage 1 ;;
  esac
}

main "$@"
