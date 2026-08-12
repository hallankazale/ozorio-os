#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  "$ROOT_DIR/scripts/configure-live-user.sh"
  "$ROOT_DIR/scripts/install-first-run.sh"
  "$ROOT_DIR/apps/first-run/ozorio-first-run.py"
)

for file in "${required[@]}"; do
  [[ -f "$file" ]] || { echo "Arquivo ausente: $file" >&2; exit 1; }
done

python3 -m py_compile "$ROOT_DIR/apps/first-run/ozorio-first-run.py"

grep -q 'autologin-user=' "$ROOT_DIR/scripts/configure-live-user.sh"
grep -q 'passwd -d' "$ROOT_DIR/scripts/configure-live-user.sh"
grep -q 'NOPASSWD: /usr/sbin/useradd, /usr/sbin/chpasswd, /usr/sbin/userdel' "$ROOT_DIR/scripts/configure-live-user.sh"
grep -q 'configure-live-user.sh' "$ROOT_DIR/scripts/build-live-iso.sh"
grep -q 'install-first-run.sh' "$ROOT_DIR/scripts/build-live-iso.sh"

if grep -R --line-number -E 'shell=True|os\.system\(' "$ROOT_DIR/apps/first-run"; then
  echo "Execução insegura detectada no assistente." >&2
  exit 1
fi

echo "Configuração Live/autologin/first-run validada."
