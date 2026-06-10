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

LOG="$REPORT_DIR/${TS}-vivaldi-tema-escuro-ajustado.log"
DOC="$DOC_DIR/${TS}-vivaldi-tema-escuro-ajustado.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-vivaldi-tema-escuro-ajustado.sh"

exec > >(tee -a "$LOG") 2>&1

step() {
  printf '\n==> %s\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  printf 'Log: %s\n' "$LOG" >&2
  exit 1
}

step "Validando ferramenta necessária"
command -v python3 >/dev/null 2>&1 || fail "python3 não encontrado."

step "Usando pasta canônica do Vivaldi"
printf 'BASE: %s\n' "$BASE"
printf 'THEME_DIR: %s\n' "$THEME_DIR"

step "Apagando apenas arquivos de temas Mocha/Vivaldi das tentativas anteriores"
DELETED_LIST="$REPORT_DIR/${TS}-vivaldi-temas-antigos-apagados.txt"
: > "$DELETED_LIST"

if [[ -d "$THEME_DIR" ]]; then
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    printf 'Apagando: %s\n' "$f" | tee -a "$DELETED_LIST"
    rm -f -- "$f"
  done < <(
    find "$THEME_DIR" -maxdepth 1 -type f \( \
      -name '*Mocha-KDE-Vivaldi*.zip' -o \
      -name '*Mocha-KDE-Vivaldi*.json' -o \
      -name '*Mocha-KDE-Importavel*.zip' -o \
      -name '*Mocha-KDE-Importavel*.json' -o \
      -name '*Mocha-KDE-Canonico*.zip' -o \
      -name '*Mocha-KDE-Canonico*.json' -o \
      -name '*Mocha KDE Direto*.zip' -o \
      -name '*Mocha KDE Direto*.json' -o \
      -name '*Mocha-Vivaldi-tentativa*.zip' -o \
      -name '*Mocha-Vivaldi-tentativa*.json' \
    \) 2>/dev/null | sort
  )
fi

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

step "Localizando arquivo .colors do tema KDE/Mocha"
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
  "$BASE" \
  "$FAST_BASE"
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
printf 'Arquivo de cores escolhido: %s\n' "$COLOR_FILE"
printf '\nLista de candidatos encontrados:\n'
printf '%s\n' "${COLOR_FILES[@]}"

step "Gerando tema novo, mais escuro e com acento mais discreto"
THEME_NAME="Mocha KDE Escuro Ajustado ${TS}"
SETTINGS_JSON="$WORKDIR/settings.json"
FINAL_JSON="$THEME_DIR/${TS}-Mocha-KDE-Escuro-Ajustado-settings.json"
FINAL_ZIP="$THEME_DIR/${TS}-Mocha-KDE-Escuro-Ajustado.zip"
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

def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb):
    vals = []
    for c in rgb:
        c = int(round(c))
        c = max(0, min(255, c))
        vals.append(c)
    return "#" + "".join(f"{v:02x}" for v in vals)

def blend(a, b, wa):
    ra = hex_to_rgb(a)
    rb = hex_to_rgb(b)
    return rgb_to_hex(tuple(ra[i] * wa + rb[i] * (1.0 - wa) for i in range(3)))

win_bg = pick(
    ("Colors:Window", "BackgroundNormal"),
    ("Colors:View", "BackgroundNormal"),
    ("WM", "inactiveBackground"),
) or "#241c18"

view_bg = pick(
    ("Colors:View", "BackgroundNormal"),
    ("Colors:Window", "BackgroundNormal"),
) or "#1e1714"

fg = pick(
    ("Colors:Window", "ForegroundNormal"),
    ("Colors:View", "ForegroundNormal"),
    ("WM", "activeForeground"),
) or "#e8d7c7"

selection = pick(
    ("Colors:Selection", "BackgroundNormal"),
    ("General", "AccentColor"),
    ("WM", "activeBackground"),
) or "#a86836"

accent_raw = pick(
    ("General", "AccentColor"),
    ("Colors:Selection", "BackgroundNormal"),
    ("WM", "activeBackground"),
) or "#a86836"

# Ajuste para evitar laranja excessivo na moldura.
toolbar_bg = blend(view_bg, win_bg, 0.55)
window_bg = blend(win_bg, "#000000", 0.88)
accent_ui = blend(accent_raw, win_bg, 0.52)
highlight_ui = blend(selection, win_bg, 0.68)

theme = {
    "accentFromPage": False,
    "accentOnWindow": False,
    "accentSaturationLimit": 0.45,
    "alpha": 1,
    "blur": 0,
    "colorAccentBg": accent_ui,
    "colorBg": toolbar_bg,
    "colorFg": fg,
    "colorHighlightBg": highlight_ui,
    "colorWindowBg": window_bg,
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

print("Cores-base lidas do KDE:")
print(f"  Window BG bruto : {win_bg}")
print(f"  View BG bruto   : {view_bg}")
print(f"  Foreground      : {fg}")
print(f"  Accent bruto    : {accent_raw}")
print(f"  Selection bruto : {selection}")

print("\nCores ajustadas para o Vivaldi:")
print(f"  Window BG       : {window_bg}")
print(f"  Toolbar BG      : {toolbar_bg}")
print(f"  Accent UI       : {accent_ui}")
print(f"  Highlight UI    : {highlight_ui}")

print("\nTema gerado:")
print(f"  Nome            : {theme_name}")
print(f"  ZIP             : {final_zip}")
print(f"  SHA256          : {digest}")
PY

cp -f "$SETTINGS_JSON" "$FINAL_JSON"
sha256sum "$FINAL_ZIP" > "$SHA_FILE"

step "Validando ZIP final"
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

step "Copiando caminho do ZIP para a área de transferência, se possível"
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
# Vivaldi - tema Mocha/KDE escuro ajustado

Data: $TS

Arquivo KDE usado:
$COLOR_FILE

Tema JSON:
$FINAL_JSON

ZIP importável:
$FINAL_ZIP

SHA256:
$(cat "$SHA_FILE")

Arquivos antigos removidos:
$(cat "$DELETED_LIST")

Observação importante:
Este tema foi ajustado para evitar que o acento pinte a moldura inteira do Vivaldi.
O fundo da janela ficou escuro, e o acento foi deixado apenas como detalhe.

Aplicação:
1. Abrir Vivaldi.
2. Ir em Settings > Themes > Library.
3. Clicar em Importar Tema.
4. Selecionar:
   $FINAL_ZIP
5. Confirmar Install.
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
printf '\nNo Vivaldi: Settings > Themes > Library > Importar Tema > selecione o ZIP > Install.\n'
printf 'Log: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
