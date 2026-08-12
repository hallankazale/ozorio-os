#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "$ROOT_DIR/scripts/configure-live-user.sh"
  "$ROOT_DIR/scripts/install-first-run.sh"
  "$ROOT_DIR/apps/first-run/ozorio-first-run.py"
  "$ROOT_DIR/apps/system/ozorio-power.py"
  "$ROOT_DIR/branding/icons/ozorio-dev.svg"
  "$ROOT_DIR/branding/icons/ozorio-security.svg"
  "$ROOT_DIR/branding/icons/ozorio-power.svg"
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "Arquivo ausente: $file" >&2; exit 1; }
done

bash -n "$ROOT_DIR/scripts/configure-live-user.sh"
bash -n "$ROOT_DIR/scripts/install-first-run.sh"
python3 -m py_compile "$ROOT_DIR/apps/first-run/ozorio-first-run.py"
python3 -m py_compile "$ROOT_DIR/apps/system/ozorio-power.py"

grep -q 'autologin-user=\$LIVE_USER' "$ROOT_DIR/scripts/configure-live-user.sh"
grep -q 'Icon=/usr/share/icons/ozorio/ozorio-logo.svg' "$ROOT_DIR/scripts/install-first-run.sh"
grep -q 'ozorio-power.desktop' "$ROOT_DIR/scripts/install-first-run.sh"
grep -q 'Energia-Ozorio.desktop' "$ROOT_DIR/scripts/install-first-run.sh"
grep -q 'ozorio-power' "$ROOT_DIR/branding/desktop/shortcuts.list"

if grep -R -nE 'shell=True|os\.system\(' \
  "$ROOT_DIR/apps/first-run" "$ROOT_DIR/apps/system"; then
  echo "Execução insegura detectada nos utilitários Ozorio." >&2
  exit 1
fi

printf 'Testes Live/UX concluídos com sucesso.\n'
