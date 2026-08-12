#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"

fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs não encontrado em $ROOTFS_DIR"

THEME_SRC="$ROOT_DIR/branding/theme/aurora/openbox/themerc"
COLORS_SRC="$ROOT_DIR/branding/theme/aurora/colors.conf"
PANEL_SRC="$ROOT_DIR/branding/desktop/panel.conf"
SHORTCUTS_SRC="$ROOT_DIR/branding/desktop/shortcuts.list"
LOGO_SRC="$ROOT_DIR/branding/logo/ozorio-logo.svg"
DEV_ICON_SRC="$ROOT_DIR/branding/icons/ozorio-dev.svg"
SECURITY_ICON_SRC="$ROOT_DIR/branding/icons/ozorio-security.svg"
POWER_ICON_SRC="$ROOT_DIR/branding/icons/ozorio-power.svg"
WALLPAPER_SRC="$ROOT_DIR/branding/wallpaper/ozorio-aurora.svg"
LOGIN_SRC="$ROOT_DIR/configs/desktop/lightdm-gtk-greeter.conf"
MENU_SRC="$ROOT_DIR/configs/desktop/ozorio-menu.desktop"

for file in \
  "$THEME_SRC" "$COLORS_SRC" "$PANEL_SRC" "$SHORTCUTS_SRC" \
  "$LOGO_SRC" "$DEV_ICON_SRC" "$SECURITY_ICON_SRC" "$POWER_ICON_SRC" \
  "$WALLPAPER_SRC" "$LOGIN_SRC" "$MENU_SRC"; do
  [[ -f "$file" ]] || fatal "arquivo de branding ausente: $file"
done

install -d \
  "$ROOTFS_DIR/usr/share/themes/Ozorio-Aurora/openbox-3" \
  "$ROOTFS_DIR/usr/share/ozorio/branding" \
  "$ROOTFS_DIR/usr/share/icons/ozorio" \
  "$ROOTFS_DIR/usr/share/backgrounds/ozorio" \
  "$ROOTFS_DIR/etc/lightdm" \
  "$ROOTFS_DIR/usr/share/applications"

install -m 0644 "$THEME_SRC" "$ROOTFS_DIR/usr/share/themes/Ozorio-Aurora/openbox-3/themerc"
install -m 0644 "$COLORS_SRC" "$ROOTFS_DIR/usr/share/ozorio/branding/colors.conf"
install -m 0644 "$PANEL_SRC" "$ROOTFS_DIR/usr/share/ozorio/branding/panel.conf"
install -m 0644 "$SHORTCUTS_SRC" "$ROOTFS_DIR/usr/share/ozorio/branding/shortcuts.list"
install -m 0644 "$LOGO_SRC" "$ROOTFS_DIR/usr/share/icons/ozorio/ozorio-logo.svg"
install -m 0644 "$DEV_ICON_SRC" "$ROOTFS_DIR/usr/share/icons/ozorio/ozorio-dev.svg"
install -m 0644 "$SECURITY_ICON_SRC" "$ROOTFS_DIR/usr/share/icons/ozorio/ozorio-security.svg"
install -m 0644 "$POWER_ICON_SRC" "$ROOTFS_DIR/usr/share/icons/ozorio/ozorio-power.svg"
install -m 0644 "$WALLPAPER_SRC" "$ROOTFS_DIR/usr/share/backgrounds/ozorio/ozorio-aurora.svg"
install -m 0644 "$LOGIN_SRC" "$ROOTFS_DIR/etc/lightdm/lightdm-gtk-greeter.conf"
install -m 0644 "$MENU_SRC" "$ROOTFS_DIR/usr/share/applications/ozorio-menu.desktop"

cat > "$ROOTFS_DIR/usr/share/ozorio/branding/README" <<'EOF'
Ozorio OS Aurora branding

Camada visual leve e desacoplada do core.
Blur e transparências pesadas são evitados para preservar compatibilidade
com GPUs antigas e computadores com pouca memória.
EOF

cat > "$ROOTFS_DIR/usr/share/ozorio/branding.conf" <<'EOF'
BRAND_NAME="Ozorio OS"
BRAND_THEME="Aurora"
BRAND_PRIMARY="#5B2BE0"
BRAND_NAVY="#07111F"
BRAND_BLUE="#1647A8"
BRAND_GREEN="#12A57A"
EOF

printf 'Branding Aurora instalado no rootfs: %s\n' "$ROOTFS_DIR"
