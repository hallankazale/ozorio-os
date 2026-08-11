#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build}"
ROOTFS_DIR="$BUILD_DIR/rootfs"
SUITE="${SUITE:-stable}"
MIRROR="${MIRROR:-https://deb.debian.org/debian}"
ARCH="${ARCH:-amd64}"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Erro: execute como root/sudo." >&2
  exit 1
fi

for cmd in debootstrap chroot mount umount; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Dependência ausente: $cmd" >&2
    exit 1
  }
done

mkdir -p "$BUILD_DIR"

if [[ -e "$ROOTFS_DIR/etc/debian_version" ]]; then
  echo "Rootfs já existe em $ROOTFS_DIR. Remova-o conscientemente para recriar." >&2
  exit 1
fi

mkdir -p "$ROOTFS_DIR"
deBootstrapLog="$BUILD_DIR/debootstrap.log"
echo "Criando rootfs Debian ($SUITE/$ARCH)..."
debootstrap --arch="$ARCH" --variant=minbase "$SUITE" "$ROOTFS_DIR" "$MIRROR" | tee "$deBootstrapLog"

cp /etc/resolv.conf "$ROOTFS_DIR/etc/resolv.conf"
mkdir -p "$ROOTFS_DIR/opt/ozorio"
cat > "$ROOTFS_DIR/etc/os-release" <<'EOF'
PRETTY_NAME="Ozorio OS 0.1"
NAME="Ozorio OS"
VERSION_ID="0.1"
VERSION="0.1 (Prototype)"
ID=ozorio
ID_LIKE=debian
HOME_URL="https://github.com/hallankazale/ozorio-os"
SUPPORT_URL="https://github.com/hallankazale/ozorio-os/issues"
BUG_REPORT_URL="https://github.com/hallankazale/ozorio-os/issues"
EOF

echo "Ozorio OS" > "$ROOTFS_DIR/etc/hostname"

echo "Rootfs criado em: $ROOTFS_DIR"
