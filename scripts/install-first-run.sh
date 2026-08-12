#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$ROOT_DIR/build/rootfs}"
LIVE_USER="${LIVE_USER:-ozorio}"

fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }
[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs não encontrado em $ROOTFS_DIR"

install -d \
  "$ROOTFS_DIR/usr/lib/ozorio" \
  "$ROOTFS_DIR/usr/local/bin" \
  "$ROOTFS_DIR/etc/xdg/autostart" \
  "$ROOTFS_DIR/usr/share/applications" \
  "$ROOTFS_DIR/etc/skel/Desktop"

install -m 0755 "$ROOT_DIR/apps/first-run/ozorio-first-run.py" \
  "$ROOTFS_DIR/usr/lib/ozorio/ozorio-first-run.py"
install -m 0755 "$ROOT_DIR/apps/system/ozorio-power.py" \
  "$ROOTFS_DIR/usr/lib/ozorio/ozorio-power.py"

cat > "$ROOTFS_DIR/usr/local/bin/ozorio-power" <<'EOF'
#!/usr/bin/env bash
exec python3 /usr/lib/ozorio/ozorio-power.py "$@"
EOF
chmod 0755 "$ROOTFS_DIR/usr/local/bin/ozorio-power"

cat > "$ROOTFS_DIR/etc/xdg/autostart/ozorio-first-run.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Primeiros passos do Ozorio OS
Comment=Criar seu usuário e concluir a configuração inicial
Exec=/usr/bin/python3 /usr/lib/ozorio/ozorio-first-run.py
Terminal=false
Icon=/usr/share/icons/ozorio/ozorio-logo.svg
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
Icon=/usr/share/icons/ozorio/ozorio-logo.svg
Categories=System;Settings;
EOF

cat > "$ROOTFS_DIR/usr/share/applications/ozorio-power.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Sair, Reiniciar ou Desligar
Comment=Encerrar a sessão ou desligar o Ozorio OS
Exec=ozorio-power
Terminal=false
Icon=/usr/share/icons/ozorio/ozorio-power.svg
Categories=System;
EOF

for desktop_file in ozorio-first-run.desktop ozorio-power.desktop; do
  cp "$ROOTFS_DIR/usr/share/applications/$desktop_file" "$ROOTFS_DIR/etc/skel/Desktop/$desktop_file"
done
chmod 0755 "$ROOTFS_DIR/etc/skel/Desktop/ozorio-first-run.desktop" "$ROOTFS_DIR/etc/skel/Desktop/ozorio-power.desktop"

if chroot "$ROOTFS_DIR" id "$LIVE_USER" >/dev/null 2>&1; then
  install -d "$ROOTFS_DIR/home/$LIVE_USER/Desktop"
  cp "$ROOTFS_DIR/etc/skel/Desktop/ozorio-first-run.desktop" "$ROOTFS_DIR/home/$LIVE_USER/Desktop/Criar-usuario.desktop"
  cp "$ROOTFS_DIR/etc/skel/Desktop/ozorio-power.desktop" "$ROOTFS_DIR/home/$LIVE_USER/Desktop/Energia-Ozorio.desktop"
  chmod 0755 "$ROOTFS_DIR/home/$LIVE_USER/Desktop/Criar-usuario.desktop" "$ROOTFS_DIR/home/$LIVE_USER/Desktop/Energia-Ozorio.desktop"
  chroot "$ROOTFS_DIR" chown -R "$LIVE_USER:$LIVE_USER" "/home/$LIVE_USER/Desktop"
fi

printf 'Assistente de primeiro uso e Central de Energia instalados.\n'
