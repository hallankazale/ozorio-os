#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"

fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs não encontrado em $ROOTFS_DIR"

APP_SRC="$ROOT_DIR/apps/dev-center/dev_center.py"
DESKTOP_SRC="$ROOT_DIR/apps/dev-center/ozorio-dev-center.desktop"
[[ -f "$APP_SRC" ]] || fatal "aplicação não encontrada: $APP_SRC"
[[ -f "$DESKTOP_SRC" ]] || fatal "launcher não encontrado: $DESKTOP_SRC"

install -d \
  "$ROOTFS_DIR/usr/lib/ozorio/dev-center" \
  "$ROOTFS_DIR/usr/local/bin" \
  "$ROOTFS_DIR/usr/share/applications"

install -m 0755 "$APP_SRC" "$ROOTFS_DIR/usr/lib/ozorio/dev-center/dev_center.py"
install -m 0644 "$DESKTOP_SRC" "$ROOTFS_DIR/usr/share/applications/ozorio-dev-center.desktop"

cat > "$ROOTFS_DIR/usr/local/bin/ozorio-dev-center" <<'EOF'
#!/usr/bin/env bash
exec python3 /usr/lib/ozorio/dev-center/dev_center.py "$@"
EOF
chmod 0755 "$ROOTFS_DIR/usr/local/bin/ozorio-dev-center"

printf 'Central de Desenvolvimento instalada em %s\n' "$ROOTFS_DIR"
