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

REPORT_DIR="$BASE/relatorios"
DOC_DIR="$BASE/documentacao"
SCRIPT_DIR="$BASE/scripts"
mkdir -p "$REPORT_DIR" "$DOC_DIR" "$SCRIPT_DIR"

LOG="$REPORT_DIR/${TS}-vivaldi-tema-direto-preferences.log"
DOC="$DOC_DIR/${TS}-vivaldi-tema-direto-preferences.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-aplicar-tema-direto-vivaldi-preferences.sh"

exec > >(tee -a "$LOG") 2>&1

step() {
  printf '\n==> %s\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  printf 'Log: %s\n' "$LOG" >&2
  exit 1
}

step "Verificando se o Vivaldi está fechado"
if pgrep -u "$USER" -a -f '(^|/)(vivaldi|vivaldi-bin|vivaldi-stable|vivaldi-snapshot)( |$)' >/tmp/mocha-vivaldi-processos-"$TS".txt 2>/dev/null; then
  cat /tmp/mocha-vivaldi-processos-"$TS".txt
  fail "feche o Vivaldi completamente e rode este mesmo comando de novo. Não vou editar Preferences com o navegador aberto."
fi

step "Validando ferramentas"
command -v python3 >/dev/null 2>&1 || fail "python3 não encontrado."

step "Localizando perfil nativo do Vivaldi"
PROFILE_ROOTS=()
[[ -d "$HOME/.config/vivaldi" ]] && PROFILE_ROOTS+=("$HOME/.config/vivaldi")
[[ -d "$HOME/.config/vivaldi-snapshot" ]] && PROFILE_ROOTS+=("$HOME/.config/vivaldi-snapshot")

if (( ${#PROFILE_ROOTS[@]} == 0 )); then
  fail "não encontrei perfil nativo em ~/.config/vivaldi nem ~/.config/vivaldi-snapshot."
fi

PREFS_CANDIDATES=()
for root in "${PROFILE_ROOTS[@]}"; do
  while IFS= read -r prefs; do
    PREFS_CANDIDATES+=("$prefs")
  done < <(
    find "$root" -maxdepth 2 -type f -name Preferences \
      ! -path '*/System Profile/*' \
      ! -path '*/Guest Profile/*' \
      2>/dev/null | sort
  )
done

if (( ${#PREFS_CANDIDATES[@]} == 0 )); then
  fail "não encontrei nenhum arquivo Preferences nos perfis nativos do Vivaldi."
fi

printf 'Preferences encontrados:\n'
printf '%s\n' "${PREFS_CANDIDATES[@]}"

step "Lendo esquema de cores KDE ativo"
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

printf 'Esquema KDE ativo: %s\n' "${ACTIVE_SCHEME:-não identificado}"

step "Localizando arquivo .colors do Mocha/KDE"
CANDIDATE_LIST="$(mktemp)"
trap 'rm -f "$CANDIDATE_LIST" /tmp/mocha-vivaldi-processos-"$TS".txt 2>/dev/null || true' EXIT

add_if_file() {
  local f="$1"
  [[ -n "$f" && -f "$f" ]] && printf '%s\n' "$f" >> "$CANDIDATE_LIST"
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
    \) 2>/dev/null >> "$CANDIDATE_LIST" || true
  fi
done

mapfile -t COLOR_FILES < <(awk '!seen[$0]++' "$CANDIDATE_LIST")

if (( ${#COLOR_FILES[@]} == 0 )); then
  fail "não encontrei arquivo .colors do tema KDE/Mocha."
fi

COLOR_FILE="${COLOR_FILES[0]}"
printf 'Arquivo de cores escolhido:\n%s\n' "$COLOR_FILE"

step "Extraindo cores e aplicando direto nos Preferences"
python3 - "$TS" "$COLOR_FILE" "${PREFS_CANDIDATES[@]}" <<'PY'
import sys, json, re, shutil, configparser
from pathlib import Path
from datetime import datetime

ts = sys.argv[1]
color_file = Path(sys.argv[2])
prefs_files = [Path(p) for p in sys.argv[3:]]

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

# Derivações seguras para o Vivaldi 8/UI nova.
page = background
tab = background
toolbar = background

theme_name = f"Mocha KDE Direto {ts}"

theme_obj = {
    "name": theme_name,
    "id": theme_name,
    "version": 1,
    "colors": {
        "accentBg": accent,
        "baseBg": background,
        "baseFg": foreground,
        "highlightBg": highlight,
        "highlightFg": foreground,
        "buttonBg": background,
        "buttonFg": foreground,
        "tabBg": tab,
        "tabFg": foreground,
        "toolbarBg": toolbar,
        "toolbarFg": foreground,
        "pageBg": page,
        "pageFg": foreground,
    },
    "settings": {
        "accentFromPage": False,
        "accentOnWindow": True,
        "borderRadius": 8,
        "colorAccentBg": True,
        "colorWindowBg": False,
        "contrast": 0,
        "dimBlurred": False,
        "preferSystemAccent": False,
        "transparency": 0,
    }
}

legacy_theme_obj = {
    "themeName": theme_name,
    "themeBg": background.lstrip("#"),
    "themeFg": foreground.lstrip("#"),
    "themeHi": highlight.lstrip("#"),
    "themeAc": accent.lstrip("#"),
    "themePage": 0,
    "themeWin": 1,
    "themeTabs": 0,
    "themeRound": "8",
}

def ensure_dict(parent, key):
    if not isinstance(parent.get(key), dict):
        parent[key] = {}
    return parent[key]

def ensure_list(parent, key):
    if not isinstance(parent.get(key), list):
        parent[key] = []
    return parent[key]

for prefs in prefs_files:
    print(f"\nEditando: {prefs}")

    raw = prefs.read_text(encoding="utf-8", errors="replace")
    data = json.loads(raw)

    backup = prefs.with_name(f"Preferences.backup-mocha-vivaldi-tema-{ts}")
    shutil.copy2(prefs, backup)
    print(f"Backup: {backup}")

    vivaldi = ensure_dict(data, "vivaldi")
    themes = ensure_dict(vivaldi, "themes")

    # Formato novo/observado em instalações recentes: vivaldi.themes.user
    user_themes = ensure_list(themes, "user")
    user_themes = [
        t for t in user_themes
        if not (
            isinstance(t, dict)
            and str(t.get("name", t.get("id", ""))).startswith("Mocha KDE Direto")
        )
    ]
    user_themes.append(theme_obj)
    themes["user"] = user_themes

    themes["current"] = theme_name
    themes["selected"] = theme_name
    themes["theme"] = theme_name
    themes["currentId"] = theme_name
    themes["private"] = theme_name

    # Compatibilidade com formatos antigos/legados.
    custom = ensure_list(themes, "custom")
    custom = [
        t for t in custom
        if not (
            isinstance(t, dict)
            and str(t.get("themeName", "")).startswith("Mocha KDE Direto")
        )
    ]
    custom.append(legacy_theme_obj)
    themes["custom"] = custom

    # Algumas versões mantêm preferências visuais fora da lista de temas.
    settings = ensure_dict(themes, "settings")
    settings["accentFromPage"] = False
    settings["accentOnWindow"] = True
    settings["colorAccentBg"] = True
    settings["preferSystemAccent"] = False

    # Força modo escuro no perfil, sem tocar em websites.
    browser = ensure_dict(data, "browser")
    browser["custom_chrome_frame"] = True

    # Escreve de forma atômica.
    tmp = prefs.with_name(f"Preferences.mocha-tmp-{ts}")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2, sort_keys=False) + "\n", encoding="utf-8")
    tmp.replace(prefs)

    print("Tema aplicado neste Preferences.")
    print(f"  Nome       : {theme_name}")
    print(f"  Background : {background}")
    print(f"  Foreground : {foreground}")
    print(f"  Highlight  : {highlight}")
    print(f"  Accent     : {accent}")

print("\nConcluído.")
PY

step "Gravando documentação"
cat > "$DOC" <<EOF
# Vivaldi — tema Mocha/KDE aplicado direto em Preferences

Data: $TS

Arquivo de cores KDE usado:
$COLOR_FILE

Perfis Preferences alterados:
$(printf '%s\n' "${PREFS_CANDIDATES[@]}")

Backups criados ao lado de cada Preferences:
Preferences.backup-mocha-vivaldi-tema-$TS

Observação:
Este método edita o perfil nativo do Vivaldi diretamente, portanto o Vivaldi precisa estar fechado durante a alteração.
EOF

cp -f "${BASH_SOURCE[0]}" "$SCRIPT_COPY"

step "Abrindo Vivaldi"
if command -v vivaldi-stable >/dev/null 2>&1; then
  nohup vivaldi-stable 'vivaldi://settings/themes/' >/dev/null 2>&1 &
elif command -v vivaldi >/dev/null 2>&1; then
  nohup vivaldi 'vivaldi://settings/themes/' >/dev/null 2>&1 &
elif command -v vivaldi-snapshot >/dev/null 2>&1; then
  nohup vivaldi-snapshot 'vivaldi://settings/themes/' >/dev/null 2>&1 &
else
  printf 'Vivaldi não encontrado no PATH. Abra manualmente.\n'
fi

printf '\nPRONTO.\n'
printf 'Se o Vivaldi abrir igual, vá em Configurações > Temas > Biblioteca e selecione o tema "Mocha KDE Direto %s".\n' "$TS"
printf 'Log: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
