#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
FAST_BASE="/media/mochafast/MochaArch/ativo"

if [[ -d "$FAST_BASE" && -w "$FAST_BASE" ]]; then
  BASE="$FAST_BASE"
else
  BASE="$HOME/.local/share/MochaArch-ativo"
fi

THEME_DIR="$BASE/vivaldi/temas"
REPORT_DIR="$BASE/relatorios"
DOC_DIR="$BASE/documentacao"
SCRIPT_DIR="$BASE/scripts"

mkdir -p "$THEME_DIR" "$REPORT_DIR" "$DOC_DIR" "$SCRIPT_DIR"

LOG="$REPORT_DIR/${TS}-vivaldi-tema-importavel-canonico.log"
DOC="$DOC_DIR/${TS}-vivaldi-tema-importavel-canonico.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-vivaldi-tema-importavel-canonico.sh"

exec > >(tee -a "$LOG") 2>&1

step() {
  printf '\n==> %s\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  printf 'Log: %s\n' "$LOG" >&2
  exit 1
}

step "Validando ferramenta única necessária"
command -v python3 >/dev/null 2>&1 || fail "python3 não encontrado."

step "Limpando somente arquivos de tema Vivaldi gerados pelas tentativas anteriores"
DELETED_LIST="$REPORT_DIR/${TS}-vivaldi-temas-antigos-apagados.txt"
: > "$DELETED_LIST"

for dir in \
  "$THEME_DIR" \
  "$HOME/Downloads" \
  "$HOME/Transferências"
do
  [[ -d "$dir" ]] || continue

  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    printf '%s\n' "$f" | tee -a "$DELETED_LIST"
    rm -f -- "$f"
  done < <(
    find "$dir" -maxdepth 1 -type f \( \
      -name '*Mocha-KDE-Vivaldi*.zip' -o \
      -name '*Mocha-KDE-Vivaldi*.json' -o \
      -name '*Mocha-KDE-Importavel*.zip' -o \
      -name '*Mocha-KDE-Importavel*.json' -o \
      -name '*Mocha KDE Direto*.zip' -o \
      -name '*Mocha KDE Direto*.json' -o \
      -name '*Mocha-Vivaldi-tentativa*.zip' -o \
      -name '*Mocha-Vivaldi-tentativa*.json' \
    \) 2>/dev/null | sort
  )
done

if [[ ! -s "$DELETED_LIST" ]]; then
  printf 'Nenhum arquivo antigo de tema Mocha/Vivaldi encontrado para apagar.\n'
fi

step "Lendo esquema KDE ativo"
KDEGLOBALS="$HOME/.config/kdeglobals"

ACTIVE_SCHEME="$(
python3 - "$KDEGLOBALS" <<'PY'
import sys
import configparser
from pathlib import Path

p = Path(sys.argv[1])
if not p.exists():
    print("")
    raise SystemExit(0)

cp = configparser.ConfigParser(interpolation=None, strict=False)
cp.optionxform = str

try:
    cp.read(p, encoding="utf-8")
    print(cp.get("General", "ColorScheme", fallback="").strip())
except Exception:
    print("")
PY
)"

printf 'Esquema KDE ativo: %s\n' "${ACTIVE_SCHEME:-não identificado}"

step "Localizando arquivo .colors do Mocha/KDE"
CANDIDATES_FILE="$(mktemp)"
WORKDIR="$(mktemp -d)"
trap 'rm -f "$CANDIDATES_FILE"; rm -rf "$WORKDIR"' EXIT

add_if_file() {
  local f="$1"
  [[ -n "$f" && -f "$f" ]] && printf '%s\n' "$f" >> "$CANDIDATES_FILE"
}

if [[ -n "$ACTIVE_SCHEME" ]]; then
  add_if_file "$HOME/.local/share/color-schemes/${ACTIVE_SCHEME}.colors"
  add_if_file "/usr/share/color-schemes/${ACTIVE_SCHEME}.colors"
fi

for dir in \
  "$HOME/.local/share/color-schemes" \
  "/usr/share/color-schemes" \
  "$FAST_BASE" \
  "$BASE"
do
  if [[ -d "$dir" ]]; then
    find "$dir" -maxdepth 8 -type f \( \
      -iname 'MochaSolidCanonico.colors' -o \
      -iname 'Mocha*.colors' -o \
      -iname '*Mocha*.colors' -o \
      -iname '*mocha*.colors' \
    \) 2>/dev/null >> "$CANDIDATES_FILE" || true
  fi
done

mapfile -t COLOR_FILES < <(awk '!seen[$0]++' "$CANDIDATES_FILE")

if (( ${#COLOR_FILES[@]} == 0 )); then
  fail "não encontrei arquivo .colors do tema KDE/Mocha."
fi

COLOR_FILE="${COLOR_FILES[0]}"
printf 'Arquivo de cores usado:\n%s\n' "$COLOR_FILE"

step "Gerando tema Vivaldi canônico, sem usar Downloads e sem editar Preferences"
THEME_NAME="Mocha KDE Canonico ${TS}"
SETTINGS_JSON="$WORKDIR/settings.json"
FINAL_JSON="$THEME_DIR/${TS}-Mocha-KDE-Canonico-settings.json"
FINAL_ZIP="$THEME_DIR/${TS}-Mocha-KDE-Canonico.zip"
SHA_FILE="$FINAL_ZIP.sha256"

python3 - "$COLOR_FILE" "$SETTINGS_JSON" "$THEME_NAME" "$FINAL_ZIP" <<'PY'
import sys
import json
import re
import uuid
import zipfile
import hashlib
import configparser
from pathlib import Path

color_file = Path(sys.argv[1])
settings_json = Path(sys.argv[2])
theme_name = sys.argv[3]
final_zip = Path(sys.argv[4])

cp = configparser.ConfigParser(interpolation=None, strict=False)
cp.optionxform = str

with color_file.open("r", encoding="utf-8", errors="replace") as f:
    cp.read_file(f)

def to_hex(value):
    if not value:
        return None

    value = str(value).strip()

    m = re.match(r"^#?([0-9a-fA-F]{6})$", value)
    if m:
        return "#" + m.group(1).lower()

    m = re.match(r"^\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})", value)
    if not m:
        return None

    vals = [max(0, min(255, int(x))) for x in m.groups()]
    return "#" + "".join(f"{v:02x}" for v in vals)

def pick(*pairs):
    for sec, opt in pairs:
        if cp.has_option(sec, opt):
            h = to_hex(cp.get(sec, opt))
            if h:
                return h
    return None

background = pick(
    ("Colors:Window", "BackgroundNormal"),
    ("Colors:View", "BackgroundNormal"),
    ("WM", "inactiveBackground"),
) or "#2b211c"

foreground = pick(
    ("Colors:Window", "ForegroundNormal"),
    ("Colors:View", "ForegroundNormal"),
    ("WM", "activeForeground"),
) or "#f1dfcf"

highlight = pick(
    ("Colors:Selection", "BackgroundNormal"),
    ("General", "AccentColor"),
    ("WM", "activeBackground"),
) or "#b87949"

accent = pick(
    ("General", "AccentColor"),
    ("Colors:Selection", "BackgroundNormal"),
    ("WM", "activeBackground"),
) or "#b87949"

theme = {
    "accentFromPage": False,
    "accentOnWindow": True,
    "accentSaturationLimit": 1,
    "alpha": 1,
    "blur": 0,
    "colorAccentBg": accent,
    "colorBg": background,
    "colorFg": foreground,
    "colorHighlightBg": highlight,
    "colorWindowBg": background,
    "contrast": 1,
    "dimBlurred": False,
    "engineVersion": 1,
    "id": str(uuid.uuid4()),
    "name": theme_name,
    "preferSystemAccent": False,
    "radius": 8,
    "simpleScrollbar": True,
    "transparencyTabBar": False,
    "transparencyTabs": False,
    "url": "",
    "version": 1
}

settings_json.write_text(
    json.dumps(theme, indent=2, ensure_ascii=False) + "\n",
    encoding="utf-8"
)

json.loads(settings_json.read_text(encoding="utf-8"))

with zipfile.ZipFile(final_zip, "w", compression=zipfile.ZIP_DEFLATED) as z:
    z.write(settings_json, "settings.json")

with zipfile.ZipFile(final_zip, "r") as z:
    names = z.namelist()
    if names != ["settings.json"]:
        raise SystemExit(f"ZIP inválido; conteúdo inesperado: {names}")
    json.loads(z.read("settings.json").decode("utf-8"))

digest = hashlib.sha256(final_zip.read_bytes()).hexdigest()

print("Tema gerado:")
print(f"  Nome       : {theme_name}")
print(f"  Fundo      : {background}")
print(f"  Texto      : {foreground}")
print(f"  Destaque   : {highlight}")
print(f"  Acento     : {accent}")
print(f"  ZIP        : {final_zip}")
print(f"  SHA256     : {digest}")
PY

cp -f "$SETTINGS_JSON" "$FINAL_JSON"
sha256sum "$FINAL_ZIP" > "$SHA_FILE"

step "Validando ZIP final com Python"
python3 - "$FINAL_ZIP" <<'PY'
import sys
import json
import zipfile
from pathlib import Path

p = Path(sys.argv[1])

with zipfile.ZipFile(p, "r") as z:
    print("Conteúdo do ZIP:")
    for info in z.infolist():
        print(f"  {info.filename}  {info.file_size} bytes")
    if "settings.json" not in z.namelist():
        raise SystemExit("settings.json não encontrado na raiz do ZIP.")
    json.loads(z.read("settings.json").decode("utf-8"))

print("ZIP válido para importação.")
PY

step "Copiando caminho canônico para a área de transferência, se possível"
if command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$FINAL_ZIP" | wl-copy
  printf 'Caminho copiado com wl-copy.\n'
elif command -v xclip >/dev/null 2>&1; then
  printf '%s' "$FINAL_ZIP" | xclip -selection clipboard
  printf 'Caminho copiado com xclip.\n'
else
  printf 'Sem wl-copy/xclip; copie o caminho manualmente.\n'
fi

step "Documentando"
cat > "$DOC" <<EOF
# Vivaldi - tema Mocha/KDE canônico importável

Data: $TS

Arquivo KDE usado:
$COLOR_FILE

Tema JSON canônico:
$FINAL_JSON

ZIP canônico importável:
$FINAL_ZIP

SHA256:
$(cat "$SHA_FILE")

Arquivos antigos removidos:
$(cat "$DELETED_LIST")

Aplicação manual no Vivaldi:
1. Abrir Vivaldi.
2. Ir em Settings > Themes > Library.
3. Clicar em Open Theme.
4. Selecionar o ZIP canônico:
   $FINAL_ZIP
5. Confirmar Install no pop-up de prévia.

Observação:
Este procedimento não edita Preferences e não usa Downloads como área de tema.
EOF

cp -f "${BASH_SOURCE[0]}" "$SCRIPT_COPY"

step "Abrindo pasta canônica do tema e tela de temas do Vivaldi"
xdg-open "$THEME_DIR" >/dev/null 2>&1 || true

if command -v vivaldi-stable >/dev/null 2>&1; then
  nohup vivaldi-stable 'vivaldi://settings/themes/' >/dev/null 2>&1 &
elif command -v vivaldi >/dev/null 2>&1; then
  nohup vivaldi 'vivaldi://settings/themes/' >/dev/null 2>&1 &
elif command -v vivaldi-snapshot >/dev/null 2>&1; then
  nohup vivaldi-snapshot 'vivaldi://settings/themes/' >/dev/null 2>&1 &
else
  printf 'Vivaldi não encontrado no PATH. Abra manualmente: vivaldi://settings/themes/\n'
fi

printf '\nPRONTO.\n'
printf 'Importe este ZIP no Vivaldi:\n%s\n' "$FINAL_ZIP"
printf '\nNo Vivaldi: Settings > Themes > Library > Open Theme > selecione o ZIP > Install.\n'
printf 'Log: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
