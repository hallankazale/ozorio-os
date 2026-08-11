#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"

fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs não encontrado em $ROOTFS_DIR"

install -d \
  "$ROOTFS_DIR/usr/share/icons/ozorio" \
  "$ROOTFS_DIR/usr/share/backgrounds/ozorio" \
  "$ROOTFS_DIR/etc/lightdm" \
  "$ROOTFS_DIR/usr/share/applications"

install -m 0644 "$ROOT_DIR/branding/logo/ozorio-logo.svg" \
  "$ROOTFS_DIR/usr/share/icons/ozorio/ozorio-logo.svg"

install -m 0644 "$ROOT_DIR/branding/wallpaper/ozorio-aurora.svg" \
  "$ROOTFS_DIR/usr/share/backgrounds/ozorio/ozorio-aurora.svg"

install -m 0644 "$ROOT_DIR/configs/desktop/lightdm-gtk-greeter.conf" \
  "$ROOTFS_DIR/etc/lightdm/lightdm-gtk-greeter.conf"

install -m 0644 "$ROOT_DIR/configs/desktop/ozorio-menu.desktop" \
  "$ROOTFS_DIR/usr/share/applications/ozorio-menu.desktop"

cat > "$ROOTFS_DIR/usr/share/ozorio/branding.conf" <<'EOF'
BRAND_NAME="Ozorio OS"
BRAND_THEME="Aurora"
BRAND_PRIMARY="#5B2BE0"
BRAND_NAVY="#07111F"
BRAND_BLUE="#1647A8"
BRAND_GREEN="#12A57A"
EOF

printf 'Branding Aurora instalado no rootfs.\n'
