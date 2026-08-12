#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"
LIVE_USER="${LIVE_USER:-ozorio}"
LIVE_NAME="${LIVE_NAME:-Ozorio Live}"

fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }

[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs não encontrado em $ROOTFS_DIR"

existing_groups=()
for group in sudo audio video plugdev netdev; do
  if chroot "$ROOTFS_DIR" getent group "$group" >/dev/null 2>&1; then
    existing_groups+=("$group")
  fi
done

groups_csv=""
if ((${#existing_groups[@]} > 0)); then
  groups_csv="$(IFS=,; echo "${existing_groups[*]}")"
fi

if ! chroot "$ROOTFS_DIR" id "$LIVE_USER" >/dev/null 2>&1; then
  useradd_args=(
    --create-home
    --shell /bin/bash
    --comment "$LIVE_NAME"
  )
  if [[ -n "$groups_csv" ]]; then
    useradd_args+=(--groups "$groups_csv")
  fi
  chroot "$ROOTFS_DIR" useradd "${useradd_args[@]}" "$LIVE_USER"
fi

# O usuário temporário Live não possui senha e entra automaticamente.
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

# O assistente gráfico pode criar/remover usuários sem pedir a senha do usuário
# temporário. A permissão é limitada aos três utilitários necessários.
install -d -m 0750 "$ROOTFS_DIR/etc/sudoers.d"
cat > "$ROOTFS_DIR/etc/sudoers.d/ozorio-first-run" <<EOF
$LIVE_USER ALL=(root) NOPASSWD: /usr/sbin/useradd, /usr/sbin/chpasswd, /usr/sbin/userdel
EOF
chmod 0440 "$ROOTFS_DIR/etc/sudoers.d/ozorio-first-run"

chroot "$ROOTFS_DIR" chown -R "$LIVE_USER:$LIVE_USER" "/home/$LIVE_USER"

printf 'Usuário Live %s configurado com autologin e grupos disponíveis: %s\n' "$LIVE_USER" "${groups_csv:-nenhum adicional}"
