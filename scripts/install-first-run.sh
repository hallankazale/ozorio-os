#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"

fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }
[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs não encontrado em $ROOTFS_DIR"

install -d \
  "$ROOTFS_DIR/usr/lib/ozorio" \
  "$ROOTFS_DIR/etc/xdg/autostart" \
  "$ROOTFS_DIR/usr/share/applications"

install -m 0755 "$ROOT_DIR/apps/first-run/ozorio-first-run.py" \
  "$ROOTFS_DIR/usr/lib/ozorio/ozorio-first-run.py"

cat > "$ROOTFS_DIR/etc/xdg/autostart/ozorio-first-run.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Primeiros passos do Ozorio OS
Comment=Criar seu usuário e concluir a configuração inicial
Exec=/usr/bin/python3 /usr/lib/ozorio/ozorio-first-run.py
Terminal=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=LXDE;
EOF

cat > "$ROOTFS_DIR/usr/share/applications/ozorio-first-run.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Criar usuário
Comment=Criar um usuário no Ozorio OS
Exec=/usr/bin/python3 /usr/lib/ozorio/ozorio-first-run.py
Terminal=false
Icon=system-users
Categories=System;Settings;
EOF

printf 'Assistente de primeiro uso instalado.\n'
