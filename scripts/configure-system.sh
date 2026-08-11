#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Erro: execute como root/sudo." >&2
  exit 1
fi

if [[ ! -f "$ROOTFS_DIR/etc/debian_version" ]]; then
  echo "Rootfs não encontrado em $ROOTFS_DIR. Execute build-rootfs.sh primeiro." >&2
  exit 1
fi

mkdir -p "$ROOTFS_DIR/etc/ozorio" "$ROOTFS_DIR/usr/share/ozorio"

cat > "$ROOTFS_DIR/etc/ozorio/release.conf" <<'EOF'
OZORIO_VERSION=0.1
OZORIO_CHANNEL=prototype
OZORIO_DESKTOP=lxde
OZORIO_THEME=aurora
EOF

cat > "$ROOTFS_DIR/etc/motd" <<'EOF'
Ozorio OS 0.1
Leve. Rápido. Completo.
EOF

ln -sf /usr/share/zoneinfo/America/Sao_Paulo "$ROOTFS_DIR/etc/localtime" || true

# O branding visual será aplicado em uma etapa separada para manter
# a configuração do sistema independente do desktop.
echo "Configuração base aplicada ao rootfs."
