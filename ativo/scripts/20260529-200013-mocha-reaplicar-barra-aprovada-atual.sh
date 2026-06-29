#!/usr/bin/env bash
set -Eeuo pipefail

export LC_ALL=C.UTF-8

trap 'echo "[ERRO] linha $LINENO: $BASH_COMMAND" >&2; exit 1' ERR

TS="$(date +%Y%m%d-%H%M%S)"
HOME_DIR="${HOME:?HOME não definido}"

FAST="/media/mochafast"
BASE="$FAST/MochaArch"
ATIVO="$BASE/ativo"
BARRA_DIR="$ATIVO/kde/barra-win11-aprovada"
APPROVED="$BARRA_DIR/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual"
CURRENT="$HOME_DIR/.config/plasma-org.kde.plasma.desktop-appletsrc"

ALTURA_CANONICA="${MOCHA_ALTURA_BARRA:-50}"

if [ "$ALTURA_CANONICA" != "50" ] && [ "$ALTURA_CANONICA" != "48" ]; then
  echo "[FALHA] MOCHA_ALTURA_BARRA inválida: $ALTURA_CANONICA"
  echo "Use 50 ou 48."
  exit 1
fi

mkdir -p "$HOME_DIR/.config"

if [ ! -f "$APPROVED" ]; then
  echo "[FALHA] Layout aprovado não encontrado:"
  echo "       $APPROVED"
  exit 1
fi

if command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 plasmashell >/dev/null 2>&1 || true
elif command -v kquitapp5 >/dev/null 2>&1; then
  kquitapp5 plasmashell >/dev/null 2>&1 || true
else
  pkill plasmashell >/dev/null 2>&1 || true
fi

sleep 2

if [ -f "$CURRENT" ]; then
  cp -a "$CURRENT" "$CURRENT.backup-$TS"
fi

TMP="$(mktemp)"
cp -a "$APPROVED" "$TMP"

sed -i \
  -e "s|/home/hal|$HOME_DIR|g" \
  -e "s|/home/mocha|$HOME_DIR|g" \
  "$TMP" || true

python - "$TMP" "$ALTURA_CANONICA" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
altura = sys.argv[2].strip()

text = path.read_text(errors="surrogateescape").splitlines()

sections = {}
current = None
for i, line in enumerate(text):
    s = line.strip()
    if s.startswith("[") and s.endswith("]"):
        current = s[1:-1]
        sections[current] = []
    elif current is not None:
        sections[current].append((i, line))

panel_sections = []
for sec, lines in sections.items():
    for _, line in lines:
        if line.strip() == "plugin=org.kde.panel":
            panel_sections.append(sec)

if not panel_sections:
    raise SystemExit("Nenhuma seção org.kde.panel encontrada.")

panel = panel_sections[0]
general = f"{panel}[General]"

def set_key(lines, section, key, value):
    header = f"[{section}]"
    out = []
    in_sec = False
    found_section = False
    key_done = False

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            if in_sec and not key_done:
                out.append(f"{key}={value}")
                key_done = True
            in_sec = stripped == header
            if in_sec:
                found_section = True

        if in_sec and stripped.startswith(f"{key}="):
            out.append(f"{key}={value}")
            key_done = True
            continue

        out.append(line)

    if in_sec and not key_done:
        out.append(f"{key}={value}")
        key_done = True

    if not found_section:
        if out and out[-1].strip():
            out.append("")
        out.append(header)
        out.append(f"{key}={value}")

    return out

for key in ("height", "thickness", "panelHeight"):
    text = set_key(text, panel, key, altura)

for key in ("height", "thickness", "panelHeight"):
    text = set_key(text, general, key, altura)

path.write_text("\n".join(text) + "\n", errors="surrogateescape")
print(f"Altura da barra Mocha aplicada: {altura}")
PY

cp -a "$TMP" "$CURRENT"
rm -f "$TMP"

rm -f "$HOME_DIR/.cache/plasma_theme_"* 2>/dev/null || true
rm -f "$HOME_DIR/.cache/plasmashell/qmlcache/"* 2>/dev/null || true
rm -f "$HOME_DIR/.cache/ksycoca6_"* 2>/dev/null || true
rm -f "$HOME_DIR/.cache/ksycoca5_"* 2>/dev/null || true

if command -v kstart6 >/dev/null 2>&1; then
  kstart6 plasmashell >/dev/null 2>&1 || nohup plasmashell >/dev/null 2>&1 &
elif command -v kstart5 >/dev/null 2>&1; then
  kstart5 plasmashell >/dev/null 2>&1 || nohup plasmashell >/dev/null 2>&1 &
else
  nohup plasmashell >/dev/null 2>&1 &
fi

sleep 3

echo "Barra Mocha aprovada reaplicada."
echo "Altura canônica: $ALTURA_CANONICA"
echo "Layout: $APPROVED"
echo "Config: $CURRENT"
