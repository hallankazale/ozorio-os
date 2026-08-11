#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_MANIFEST="$ROOT_DIR/configs/system/packages-base.txt"
LIVE_MANIFEST="$ROOT_DIR/configs/system/packages-live.txt"
DEV_MANIFEST="$ROOT_DIR/configs/system/packages-development.txt"
SEC_MANIFEST="$ROOT_DIR/configs/system/packages-security-optional.txt"

usage() {
  cat <<'EOF'
Uso: sudo ./scripts/install-packages.sh [--live] [--development] [--security]

Sem opções, instala apenas os pacotes-base.
--live         instala kernel, live-boot e desktop leve da ISO.
--development  instala ferramentas de desenvolvimento.
--security     instala ferramentas opcionais de segurança para laboratório autorizado/CTF.
EOF
}

read_manifest() {
  grep -Ev '^[[:space:]]*(#|$)' "$1" | tr '\n' ' '
}

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Erro: execute como root/sudo." >&2
  exit 1
fi

install_live=false
install_dev=false
install_security=false

for arg in "$@"; do
  case "$arg" in
    --live) install_live=true ;;
    --development) install_dev=true ;;
    --security) install_security=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opção desconhecida: $arg" >&2; usage; exit 2 ;;
  esac
done

packages="$(read_manifest "$BASE_MANIFEST")"
$install_live && packages+=" $(read_manifest "$LIVE_MANIFEST")"
$install_dev && packages+=" $(read_manifest "$DEV_MANIFEST")"
$install_security && packages+=" $(read_manifest "$SEC_MANIFEST")"

export DEBIAN_FRONTEND=noninteractive
apt-get update
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends $packages
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Pacotes instalados com sucesso."
