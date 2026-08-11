#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
ROOTFS_DIR="${BUILD_DIR}/rootfs"
ISO_DIR="${BUILD_DIR}/iso"

log() {
  printf '[ozorio-build] %s\n' "$*"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Erro: comando obrigatório não encontrado: %s\n' "$1" >&2
    exit 1
  }
}

main() {
  require_command debootstrap
  require_command rsync
  require_command chroot

  mkdir -p "${ROOTFS_DIR}" "${ISO_DIR}"

  log "Estrutura de build preparada."
  log "Próxima etapa: criar rootfs Debian/Q4OS e aplicar configurações Ozorio."
}

main "$@"
