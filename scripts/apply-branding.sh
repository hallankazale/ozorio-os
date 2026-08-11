#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"

fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }
[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs não encontrado: $ROOTFS_DIR"

THEME_SRC="$ROOT_DIR/branding/theme/aurora/openbox/themerc"
COLORS_SRC="$ROOT_DIR/branding/theme/aurora/colors.conf"
PANEL_SRC="$ROOT_DIR/branding/desktop/panel.conf"
SHORTCUTS_SRC="$ROOT_DIR/branding/desktop/shortcuts.list"

for file in "$THEME_SRC" "$COLORS_SRC" "$PANEL_SRC" "$SHORTCUTS_SRC"; do
  [[ -f "$file" ]] || fatal "arquivo de branding ausente: $file"
done

install -d "$ROOTFS_DIR/usr/share/themes/Ozorio-Aurora/openbox-3"
install -m 0644 "$THEME_SRC" "$ROOTFS_DIR/usr/share/themes/Ozorio-Aurora/openbox-3/themerc"

install -d "$ROOTFS_DIR/usr/share/ozorio/branding"
install -m 0644 "$COLORS_SRC" "$ROOTFS_DIR/usr/share/ozorio/branding/colors.conf"
install -m 0644 "$PANEL_SRC" "$ROOTFS_DIR/usr/share/ozorio/branding/panel.conf"
install -m 0644 "$SHORTCUTS_SRC" "$ROOTFS_DIR/usr/share/ozorio/branding/shortcuts.list"

cat > "$ROOTFS_DIR/usr/share/ozorio/branding/README" <<'EOF'
Ozorio OS Aurora branding

This directory stores lightweight design tokens and desktop defaults.
Heavy blur/transparency effects are intentionally excluded for compatibility
with old GPUs and low-memory PCs.
EOF

printf 'Branding Aurora aplicado em %s\n' "$ROOTFS_DIR"
