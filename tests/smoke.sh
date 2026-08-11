#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"

failures=0

check() {
  local description="$1"
  shift
  if "$@"; then
    printf '[OK] %s\n' "$description"
  else
    printf '[FALHA] %s\n' "$description" >&2
    failures=$((failures + 1))
  fi
}

check "estrutura apps/dev-center" test -f "$ROOT_DIR/apps/dev-center/README.md"
check "estrutura apps/hacker-center" test -f "$ROOT_DIR/apps/hacker-center/README.md"
check "manifesto base" test -s "$ROOT_DIR/configs/system/packages-base.txt"
check "script de rootfs" test -s "$ROOT_DIR/scripts/build-rootfs.sh"

if [[ -d "$ROOTFS_DIR" ]]; then
  check "rootfs possui os-release" test -s "$ROOTFS_DIR/etc/os-release"
  check "rootfs identificado como Ozorio" grep -q '^ID=ozorio$' "$ROOTFS_DIR/etc/os-release"
else
  printf '[INFO] rootfs ainda não foi criado; testes de imagem ignorados.\n'
fi

if (( failures > 0 )); then
  printf '%d teste(s) falharam.\n' "$failures" >&2
  exit 1
fi

echo "Smoke tests concluídos."
