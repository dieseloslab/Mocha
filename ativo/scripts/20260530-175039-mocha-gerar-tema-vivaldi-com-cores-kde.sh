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

LOG="$REPORT_DIR/${TS}-vivaldi-tema-kde-mocha.log"
DOC="$DOC_DIR/${TS}-vivaldi-tema-kde-mocha.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-gerar-tema-vivaldi-com-cores-kde.sh"

exec > >(tee -a "$LOG") 2>&1

step() {
  printf '\n==> %s\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

step "Validando ferramentas"
command -v python3 >/dev/null 2>&1 || fail "python3 não encontrado."

VIVALDI_BIN=""
for bin in vivaldi-stable vivaldi vivaldi-snapshot; do
  if command -v "$bin" >/dev/null 2>&1; then
    VIVALDI_BIN="$(command -v "$bin")"
    break
  fi
done

printf 'Vivaldi detectado: %s\n' "${VIVALDI_BIN:-não encontrado no PATH; ainda vou gerar o tema ZIP}"

step "Lendo esquema KDE ativo"
KDEGLOBALS="$HOME/.config/kdeglobals"
ACTIVE_SCHEME="$(
python3 - "$KDEGLOBALS" <<'PY'
import sys, configparser
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

printf 'Esquema KDE ativo informado por kdeglobals: %s\n' "${ACTIVE_SCHEME:-não identificado}"

step "Procurando arquivo .colors do tema Mocha/KDE"
tmp_candidates="$(mktemp)"
trap 'rm -f "$tmp_candidates"' EXIT

add_candidate() {
  local f="$1"
  [[ -n "$f" && -f "$f" ]] && printf '%s\n' "$f" >> "$tmp_candidates"
}

if [[ -n "$ACTIVE_SCHEME" ]]; then
  add_candidate "$HOME/.local/share/color-schemes/${ACTIVE_SCHEME}.colors"
  add_candidate "$HOME/.local/share/color-schemes/${ACTIVE_SCHEME}.color"
  add_candidate "/usr/share/color-schemes/${ACTIVE_SCHEME}.colors"
  add_candidate "/usr/share/color-schemes/${ACTIVE_SCHEME}.color"
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
    \) 2>/dev/null >> "$tmp_candidates" || true
  fi
done

mapfile -t CANDIDATES < <(awk '!seen[$0]++' "$tmp_candidates")

if (( ${#CANDIDATES[@]} == 0 )); then
  fail "não encontrei arquivo .colors do KDE/Mocha. Nada foi alterado."
fi

SCHEME_FILE="${CANDIDATES[0]}"

printf 'Arquivo de cores escolhido:\n%s\n' "$SCHEME_FILE"
printf '\nCandidatos encontrados:\n'
printf '%s\n' "${CANDIDATES[@]}"

THEME_JSON="$THEME_DIR/${TS}-Mocha-KDE-Vivaldi-theme.json"
THEME_ZIP="$THEME_DIR/${TS}-Mocha-KDE-Vivaldi.zip"
SHA_FILE="$THEME_ZIP.sha256"

step "Extraindo cores KDE e gerando theme.json do Vivaldi"
python3 - "$SCHEME_FILE" "$THEME_JSON" "$ACTIVE_SCHEME" "$TS" <<'PY'
import sys, json, re, configparser
from pathlib import Path

scheme_file = Path(sys.argv[1])
out = Path(sys.argv[2])
active_scheme = sys.argv[3].strip() or "KDE atual"
ts = sys.argv[4]

cp = configparser.ConfigParser(interpolation=None, strict=False)
cp.optionxform = str

with scheme_file.open("r", encoding="utf-8", errors="replace") as f:
    cp.read_file(f)

def to_hex(value):
    if not value:
        return None
    value = value.strip()
    m = re.match(r"^#?([0-9a-fA-F]{6})$", value)
    if m:
        return m.group(1).lower()
    m = re.match(r"^\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})", value)
    if not m:
        return None
    vals = [max(0, min(255, int(x))) for x in m.groups()]
    return "".join(f"{v:02x}" for v in vals)

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
)

foreground = pick(
    ("Colors:Window", "ForegroundNormal"),
    ("Colors:View", "ForegroundNormal"),
    ("WM", "activeForeground"),
)

highlight = pick(
    ("Colors:Selection", "BackgroundNormal"),
    ("General", "AccentColor"),
    ("WM", "activeBackground"),
)

accent = pick(
    ("General", "AccentColor"),
    ("Colors:Selection", "BackgroundNormal"),
    ("WM", "activeBackground"),
)

missing = [
    name for name, value in {
        "background": background,
        "foreground": foreground,
        "highlight": highlight,
        "accent": accent,
    }.items() if not value
]

if missing:
    raise SystemExit(f"Não consegui extrair estas cores do arquivo KDE: {', '.join(missing)}")

theme = {
    "themeName": f"Mocha KDE Vivaldi {ts}",
    "themeBg": background,
    "themeFg": foreground,
    "themeHi": highlight,
    "themeAc": accent,
    "themePage": 0,
    "themeWin": 1,
    "themeTabs": 0,
    "themeRound": "8"
}

out.write_text(json.dumps(theme, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

print("Cores extraídas para o Vivaldi:")
print(f"  Background/Fundo : #{background}")
print(f"  Foreground/Texto : #{foreground}")
print(f"  Highlight        : #{highlight}")
print(f"  Accent           : #{accent}")
print(f"  Tema KDE origem  : {active_scheme}")
PY

step "Gerando ZIP importável pelo Vivaldi"
python3 - "$THEME_JSON" "$THEME_ZIP" <<'PY'
import sys, zipfile
from pathlib import Path

theme_json = Path(sys.argv[1])
theme_zip = Path(sys.argv[2])

with zipfile.ZipFile(theme_zip, "w", compression=zipfile.ZIP_DEFLATED) as z:
    z.write(theme_json, "theme.json")
PY

sha256sum "$THEME_ZIP" > "$SHA_FILE"

step "Copiando caminho do tema para a área de transferência, se possível"
if command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$THEME_ZIP" | wl-copy
  printf 'Caminho copiado via wl-copy.\n'
elif command -v xclip >/dev/null 2>&1; then
  printf '%s' "$THEME_ZIP" | xclip -selection clipboard
  printf 'Caminho copiado via xclip.\n'
else
  printf 'Sem wl-copy/xclip; copie o caminho manualmente.\n'
fi

step "Documentando"
cat > "$DOC" <<EOF
# Vivaldi — tema Mocha/KDE gerado em $TS

Arquivo KDE usado:
$SCHEME_FILE

Tema Vivaldi gerado:
$THEME_JSON

ZIP importável:
$THEME_ZIP

SHA256:
$(cat "$SHA_FILE")

Aplicação:
1. Abrir Vivaldi.
2. Ir em Settings > Themes > Library.
3. Clicar em Open Theme.
4. Selecionar o ZIP acima.
5. Confirmar Install.

Observação:
Este procedimento não edita Preferences diretamente. Ele gera um tema importável pelo fluxo suportado do Vivaldi.
EOF

cp -f "${BASH_SOURCE[0]}" "$SCRIPT_COPY"

step "Abrindo a tela de temas do Vivaldi"
if [[ -n "$VIVALDI_BIN" ]]; then
  nohup "$VIVALDI_BIN" "vivaldi://settings/themes/" >/dev/null 2>&1 &
else
  printf 'Abra manualmente: vivaldi://settings/themes/\n'
fi

printf '\nPRONTO.\n'
printf 'Tema ZIP:\n%s\n' "$THEME_ZIP"
printf '\nNo Vivaldi: Themes > Library > Open Theme > selecione esse ZIP > Install.\n'
printf 'Log:\n%s\n' "$LOG"
printf 'Documento:\n%s\n' "$DOC"
