#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PACMAN_CONF="/etc/pacman.conf"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/etc/pacman.conf.bak-mocha-saneia-cachyos-$STAMP"

[ -f "$PACMAN_CONF" ] || {
  echo "[ERRO] Não existe $PACMAN_CONF" >&2
  exit 1
}

cp -a "$PACMAN_CONF" "$BACKUP"
echo "[OK] Backup criado: $BACKUP"

python - "$PACMAN_CONF" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
lines = path.read_text().splitlines(keepends=True)

repo_header_re = re.compile(r'^(\s*)\[(cachyos[^\]]*)\](\s*(?:#.*)?)$')
any_header_re = re.compile(r'^\s*\[[^\]]+\]\s*(?:#.*)?$')
ignorepkg_target = "IgnorePkg = linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open"

out = []
in_cachy_section = False
seen_ignorepkg_target = False

for line in lines:
    stripped = line.strip()

    # Remove duplicidade exata do IgnorePkg canônico.
    if stripped == ignorepkg_target:
        if seen_ignorepkg_target:
            continue
        seen_ignorepkg_target = True
        out.append(line)
        continue

    # Comenta qualquer header CachyOS ativo.
    if repo_header_re.match(line):
        in_cachy_section = True
        if line.lstrip().startswith("#"):
            out.append(line)
        else:
            out.append("# Mocha desativado temporariamente: " + line)
        continue

    # Outro repo ativo encerra seção CachyOS.
    if any_header_re.match(line):
        in_cachy_section = False
        out.append(line)
        continue

    # Comenta corpo de repo CachyOS ativo.
    if in_cachy_section:
        if line.lstrip().startswith("#") or stripped == "":
            out.append(line)
        else:
            out.append("# Mocha desativado temporariamente: " + line)
        continue

    out.append(line)

path.write_text("".join(out))
PY

echo
echo "Validação de repositórios CachyOS ativos:"
if grep -nE '^\s*\[cachyos[^\]]*\]' "$PACMAN_CONF"; then
  echo "[ERRO] Ainda existe repo CachyOS ativo." >&2
  exit 1
else
  echo "[OK] Nenhum repo CachyOS ativo."
fi

echo
echo "Validação de IgnorePkg canônico:"
COUNT="$(grep -cE '^IgnorePkg = linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open$' "$PACMAN_CONF" || true)"
if [ "$COUNT" = "1" ]; then
  echo "[OK] IgnorePkg canônico aparece uma única vez."
else
  echo "[ERRO] IgnorePkg canônico aparece $COUNT vez(es)." >&2
  exit 1
fi

echo
echo "Kernel ativo:"
uname -r

echo
echo "Pacotes kernel/driver preservados:"
pacman -Q linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open 2>/dev/null || true
pacman -Q linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open 2>/dev/null || true
