#!/usr/bin/env bash
# Общие функции для скриптов в server/. Подключается через `source`.

if [[ -t 1 ]]; then
  C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_ERR=$'\033[31m'; C_B=$'\033[1m'; C_0=$'\033[0m'
else
  C_OK=""; C_WARN=""; C_ERR=""; C_B=""; C_0=""
fi

log()  { printf '%s==>%s %s\n' "$C_OK" "$C_0" "$*"; }
warn() { printf '%s[!]%s %s\n' "$C_WARN" "$C_0" "$*" >&2; }
die()  { printf '%s[x]%s %s\n' "$C_ERR" "$C_0" "$*" >&2; exit 1; }
bold() { printf '%s%s%s\n' "$C_B" "$*" "$C_0"; }

require_root() {
  [[ ${EUID:-$(id -u)} -eq 0 ]] || die "Запусти от root: sudo bash $0"
}

require_supported_os() {
  [[ -r /etc/os-release ]] || die "Не найден /etc/os-release — неизвестная ОС."
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian) ;;
    *) die "Поддерживаются только Ubuntu 22.04/24.04 и Debian 12. У тебя: ${PRETTY_NAME:-unknown}" ;;
  esac
}

apt_install() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold "$@" >/dev/null
}

# Публичный IPv4 сервера: сначала внешний сервис, потом маршрут по умолчанию.
detect_public_ip() {
  local ip=""
  ip=$(curl -4 -fsS --max-time 5 https://api.ipify.org 2>/dev/null || true)
  if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')
  fi
  printf '%s' "$ip"
}
