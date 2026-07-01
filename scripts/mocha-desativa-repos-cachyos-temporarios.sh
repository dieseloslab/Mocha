#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PACMAN_CONF="/etc/pacman.conf"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/etc/pacman.conf.bak-mocha-desativa-cachyos-$STAMP"

[ -f "$PACMAN_CONF" ] || {
  echo "[ERRO] Não existe $PACMAN_CONF" >&2
  exit 1
}

cp -a "$PACMAN_CONF" "$BACKUP"

python - "$PACMAN_CONF" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
lines = text.splitlines(keepends=True)

repo_header_re = re.compile(r'^(\s*)\[(cachyos[^\]]*)\](\s*(?:#.*)?)$')
any_header_re = re.compile(r'^\s*\[[^\]]+\]\s*(?:#.*)?$')

out = []
in_mocha_marked_block = False
in_cachy_section = False
changed = False

def comment_line(line, reason):
    global changed
    stripped = line.lstrip()
    if stripped.startswith("#") or stripped.strip() == "":
        return line
    changed = True
    return "# Mocha desativado temporariamente: " + line

for line in lines:
    stripped = line.strip()

    if stripped == "# --- Mocha teste CachyOS v3 NVIDIA casado: inicio ---":
        in_mocha_marked_block = True
        out.append(line)
        continue

    if stripped == "# --- Mocha teste CachyOS v3 NVIDIA casado: fim ---":
        in_mocha_marked_block = False
        in_cachy_section = False
        out.append(line)
        continue

    if in_mocha_marked_block:
        out.append(comment_line(line, "marked-block"))
        continue

    if repo_header_re.match(line):
        in_cachy_section = True
        out.append(comment_line(line, "repo-header"))
        continue

    if any_header_re.match(line):
        in_cachy_section = False
        out.append(line)
        continue

    if in_cachy_section:
        out.append(comment_line(line, "repo-body"))
        continue

    out.append(line)

new = "".join(out)
path.write_text(new)
PY

# Segurança: não deixa Include ativo imediatamente abaixo de headers Cachy comentados no bloco Mocha.
# Não remove pacotes, não remove mirrorlists, não remove keyring.
echo "[OK] Backup criado: $BACKUP"

echo
echo "Repos CachyOS ainda ativos no pacman.conf:"
if grep -nE '^\s*\[cachyos[^\]]*\]' "$PACMAN_CONF"; then
  echo "[ERRO] Ainda há repositório CachyOS ativo em $PACMAN_CONF" >&2
  exit 1
else
  echo "[OK] Nenhum repositório CachyOS ativo."
fi

echo
echo "Pacotes CachyOS instalados permanecem instalados:"
pacman -Q linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open 2>/dev/null || true
pacman -Q linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open 2>/dev/null || true

echo
echo "Kernel em uso:"
uname -r

echo
echo "Trecho CachyOS no pacman.conf:"
grep -nEi 'Mocha teste CachyOS|Mocha desativado temporariamente|^\s*#?\s*\[cachyos|cachyos-v3-mirrorlist|cachyos|IgnorePkg' "$PACMAN_CONF" || true
