#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build}"
ROOTFS_DIR="$BUILD_DIR/rootfs"
ISO_TREE="$BUILD_DIR/iso-tree"
OUTPUT_DIR="$BUILD_DIR/output"
OUTPUT_ISO="$OUTPUT_DIR/ozorio-os-0.1-amd64.iso"

log() { printf '[ozorio-live] %s\n' "$*"; }
fatal() { printf 'Erro: %s\n' "$*" >&2; exit 1; }
require() { command -v "$1" >/dev/null 2>&1 || fatal "comando ausente: $1"; }

read_manifest() {
  grep -Ev '^[[:space:]]*(#|$)' "$1" | tr '\n' ' '
}

cleanup() {
  set +e
  mountpoint -q "$ROOTFS_DIR/dev" && umount -lf "$ROOTFS_DIR/dev"
  mountpoint -q "$ROOTFS_DIR/proc" && umount -lf "$ROOTFS_DIR/proc"
  mountpoint -q "$ROOTFS_DIR/sys" && umount -lf "$ROOTFS_DIR/sys"
  mountpoint -q "$ROOTFS_DIR/run" && umount -lf "$ROOTFS_DIR/run"
}
trap cleanup EXIT

[[ ${EUID:-$(id -u)} -eq 0 ]] || fatal "execute com sudo/root"
for cmd in chroot mount umount mksquashfs xorriso rsync; do require "$cmd"; done
[[ -f "$ROOTFS_DIR/etc/debian_version" ]] || fatal "rootfs ausente. Execute scripts/build-rootfs.sh primeiro."

LIVE_MANIFEST="$ROOT_DIR/configs/system/packages-live.txt"
BASE_MANIFEST="$ROOT_DIR/configs/system/packages-base.txt"
[[ -f "$LIVE_MANIFEST" && -f "$BASE_MANIFEST" ]] || fatal "manifestos de pacotes ausentes"

log "Montando pseudo-filesystems do chroot..."
mkdir -p "$ROOTFS_DIR"/{dev,proc,sys,run}
mount --bind /dev "$ROOTFS_DIR/dev"
mount -t proc /proc "$ROOTFS_DIR/proc"
mount -t sysfs /sys "$ROOTFS_DIR/sys"
mount --bind /run "$ROOTFS_DIR/run"

log "Instalando pacotes base + perfil Live..."
packages="$(read_manifest "$BASE_MANIFEST") $(read_manifest "$LIVE_MANIFEST")"
chroot "$ROOTFS_DIR" /bin/bash -c "export DEBIAN_FRONTEND=noninteractive; apt-get update; apt-get install -y --no-install-recommends $packages; apt-get clean; rm -rf /var/lib/apt/lists/*"

log "Configurando identidade do sistema..."
ROOTFS_DIR="$ROOTFS_DIR" bash "$ROOT_DIR/scripts/configure-system.sh"

log "Configurando usuário Live e autologin..."
ROOTFS_DIR="$ROOTFS_DIR" bash "$ROOT_DIR/scripts/configure-live-user.sh"

log "Aplicando branding Aurora..."
ROOTFS_DIR="$ROOTFS_DIR" bash "$ROOT_DIR/scripts/install-branding.sh"

log "Instalando Central de Desenvolvimento..."
ROOTFS_DIR="$ROOTFS_DIR" bash "$ROOT_DIR/scripts/install-dev-center.sh"

log "Instalando assistente de primeiro uso..."
ROOTFS_DIR="$ROOTFS_DIR" bash "$ROOT_DIR/scripts/install-first-run.sh"

cleanup
trap - EXIT

log "Preparando árvore da ISO..."
rm -rf "$ISO_TREE"
mkdir -p "$ISO_TREE/live" "$ISO_TREE/isolinux" "$OUTPUT_DIR"

kernel_path="$(find "$ROOTFS_DIR/boot" -maxdepth 1 -type f -name 'vmlinuz-*' | sort -V | tail -n1)"
initrd_path="$(find "$ROOTFS_DIR/boot" -maxdepth 1 -type f -name 'initrd.img-*' | sort -V | tail -n1)"
[[ -n "$kernel_path" && -n "$initrd_path" ]] || fatal "kernel/initrd não encontrados no rootfs"
cp "$kernel_path" "$ISO_TREE/live/vmlinuz"
cp "$initrd_path" "$ISO_TREE/live/initrd.img"

log "Criando filesystem squashfs..."
mksquashfs "$ROOTFS_DIR" "$ISO_TREE/live/filesystem.squashfs" -comp xz -e boot

cp "$ROOT_DIR/configs/boot/isolinux.cfg" "$ISO_TREE/isolinux/isolinux.cfg"
cp /usr/lib/ISOLINUX/isolinux.bin "$ISO_TREE/isolinux/"
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$ISO_TREE/isolinux/"
cp /usr/lib/syslinux/modules/bios/vesamenu.c32 "$ISO_TREE/isolinux/"
cp /usr/lib/syslinux/modules/bios/libcom32.c32 "$ISO_TREE/isolinux/"
cp /usr/lib/syslinux/modules/bios/libutil.c32 "$ISO_TREE/isolinux/"
cp /usr/lib/syslinux/modules/bios/reboot.c32 "$ISO_TREE/isolinux/"

log "Gerando ISO BIOS inicializável..."
xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso9660-filenames \
  -volid "OZORIO_0_1" \
  -eltorito-boot isolinux/isolinux.bin \
  -eltorito-catalog isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -output "$OUTPUT_ISO" \
  "$ISO_TREE"

sha256sum "$OUTPUT_ISO" > "$OUTPUT_ISO.sha256"
log "ISO criada: $OUTPUT_ISO"
log "SHA256: $OUTPUT_ISO.sha256"
