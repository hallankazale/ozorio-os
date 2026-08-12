#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"
LIVE_USER="${LIVE_USER:-ozorio}"
LIVE_NAME="${LIVE_NAME:-Ozorio Live}"

fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs não encontrado em $ROOTFS_DIR"

# Cria um usuário Live previsível para evitar bloqueio no LightDM.
if ! chroot "$ROOTFS_DIR" id "$LIVE_USER" >/dev/null 2>&1; then
  chroot "$ROOTFS_DIR" useradd \
    --create-home \
    --shell /bin/bash \
    --groups sudo,audio,video,plugdev,netdev \
    --comment "$LIVE_NAME" \
    "$LIVE_USER"
fi

# Sem senha apenas na sessão Live. A criação de usuário persistente terá senha própria.
chroot "$ROOTFS_DIR" passwd -d "$LIVE_USER" >/dev/null

install -d "$ROOTFS_DIR/etc/lightdm/lightdm.conf.d"
cat > "$ROOTFS_DIR/etc/lightdm/lightdm.conf.d/50-ozorio-live.conf" <<EOF
[Seat:*]
autologin-user=$LIVE_USER
autologin-user-timeout=0
user-session=LXDE
allow-guest=false
greeter-hide-users=false
EOF

# Garante permissões corretas para o diretório pessoal.
chroot "$ROOTFS_DIR" chown -R "$LIVE_USER:$LIVE_USER" "/home/$LIVE_USER"

printf 'Usuário Live %s configurado com autologin.\n' "$LIVE_USER"
