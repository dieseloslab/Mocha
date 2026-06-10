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

LOG="$REPORT_DIR/${TS}-vivaldi-tema-firefox-certo.log"
DOC="$DOC_DIR/${TS}-vivaldi-tema-firefox-certo.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-vivaldi-tema-firefox-certo.sh"

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

step "Removendo temas Mocha/Vivaldi ruins anteriores somente da pasta canônica"
DELETED_LIST="$REPORT_DIR/${TS}-vivaldi-temas-ruins-removidos.txt"
: > "$DELETED_LIST"

if [[ -d "$THEME_DIR" ]]; then
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    printf 'Removendo: %s\n' "$f" | tee -a "$DELETED_LIST"
    rm -f -- "$f"
  done < <(
    find "$THEME_DIR" -maxdepth 1 -type f \( \
      -name '*Mocha-KDE-Vivaldi*.zip' -o \
      -name '*Mocha-KDE-Vivaldi*.json' -o \
      -name '*Mocha-KDE-Importavel*.zip' -o \
      -name '*Mocha-KDE-Importavel*.json' -o \
      -name '*Mocha-KDE-Canonico*.zip' -o \
      -name '*Mocha-KDE-Canonico*.json' -o \
      -name '*Mocha-KDE-Escuro-Ajustado*.zip' -o \
      -name '*Mocha-KDE-Escuro-Ajustado*.json' -o \
      -name '*Mocha-Firefox-Vivaldi*.zip' -o \
      -name '*Mocha-Firefox-Vivaldi*.json' -o \
      -name '*Mocha-Vivaldi-Firefox-Certo*.zip' -o \
      -name '*Mocha-Vivaldi-Firefox-Certo*.json' \
    \) 2>/dev/null | sort
  )
fi

step "Removendo somente cópias erradas antigas em Downloads/Transferências, se existirem"
for lixo_dir in "$HOME/Downloads" "$HOME/Transferências"; do
  [[ -d "$lixo_dir" ]] || continue
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    printf 'Removendo cópia errada: %s\n' "$f" | tee -a "$DELETED_LIST"
    rm -f -- "$f"
  done < <(
    find "$lixo_dir" -maxdepth 1 -type f \( \
      -name '*Mocha-KDE-Importavel*.zip' -o \
      -name '*Mocha-KDE-Canonico*.zip' -o \
      -name '*Mocha-KDE-Escuro-Ajustado*.zip' -o \
      -name '*Mocha-Firefox-Vivaldi*.zip' -o \
      -name '*Mocha-Vivaldi-Firefox-Certo*.zip' \
    \) 2>/dev/null | sort
  )
done

step "Gerando tema no mesmo formato que abriu a prévia do Vivaldi"
THEME_NAME="Mocha Vivaldi Firefox Certo ${TS}"
FINAL_JSON="$THEME_DIR/${TS}-Mocha-Vivaldi-Firefox-Certo-settings.json"
FINAL_ZIP="$THEME_DIR/${TS}-Mocha-Vivaldi-Firefox-Certo.zip"
SHA_FILE="$FINAL_ZIP.sha256"

python3 - "$THEME_NAME" "$FINAL_JSON" "$FINAL_ZIP" <<'PY'
import sys
import json
import zipfile
import hashlib
from pathlib import Path

theme_name = sys.argv[1]
json_path = Path(sys.argv[2])
zip_path = Path(sys.argv[3])

# Paleta baseada no Firefox da captura: escura, neutra, sem laranja dominante.
# Mantém o formato que o Vivaldi aceitou na prévia anterior.
theme = {
    "accentFromPage": False,
    "accentOnWindow": True,
    "accentSaturationLimit": 0.35,
    "alpha": 1,
    "blur": 0,

    # Acento escuro para a moldura não virar laranja.
    "colorAccentBg": "#211e1a",

    # Fundo principal de barras/áreas do navegador.
    "colorBg": "#1b1815",

    # Texto claro, parecido com o Firefox/KDE escuro.
    "colorFg": "#e8dfd4",

    # Destaque discreto para seleção/botões ativos.
    "colorHighlightBg": "#5a4a3e",

    # Fundo da janela/topo.
    "colorWindowBg": "#171512",

    "contrast": 1,
    "dimBlurred": False,
    "engineVersion": 1,
    "id": f"mocha-vivaldi-firefox-certo-{zip_path.stem}",
    "name": theme_name,
    "preferSystemAccent": False,
    "radius": 8,
    "simpleScrollbar": True,
    "transparencyTabBar": False,
    "transparencyTabs": False,
    "url": "",
    "version": 1
}

json_path.write_text(json.dumps(theme, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
json.loads(json_path.read_text(encoding="utf-8"))

with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as z:
    z.write(json_path, "settings.json")

with zipfile.ZipFile(zip_path, "r") as z:
    names = z.namelist()
    if names != ["settings.json"]:
        raise SystemExit(f"ZIP inválido: {names}")
    json.loads(z.read("settings.json").decode("utf-8"))

sha = hashlib.sha256(zip_path.read_bytes()).hexdigest()

print("Tema criado:")
print(f"  Nome             : {theme_name}")
print(f"  colorWindowBg    : {theme['colorWindowBg']}")
print(f"  colorBg          : {theme['colorBg']}")
print(f"  colorAccentBg    : {theme['colorAccentBg']}")
print(f"  colorFg          : {theme['colorFg']}")
print(f"  colorHighlightBg : {theme['colorHighlightBg']}")
print(f"  ZIP              : {zip_path}")
print(f"  SHA256           : {sha}")
PY

sha256sum "$FINAL_ZIP" > "$SHA_FILE"

step "Validando ZIP importável"
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
        raise SystemExit("settings.json não encontrado.")
    json.loads(z.read("settings.json").decode("utf-8"))

print("ZIP validado.")
PY

step "Copiando caminho canônico para a área de transferência"
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
# Vivaldi - tema Firefox/Mocha correto

Data: $TS

Tema ZIP:
$FINAL_ZIP

Tema JSON:
$FINAL_JSON

SHA256:
$(cat "$SHA_FILE")

Cores usadas:
- colorWindowBg: #171512
- colorBg: #1b1815
- colorAccentBg: #211e1a
- colorFg: #e8dfd4
- colorHighlightBg: #5a4a3e

Arquivos ruins removidos:
$(cat "$DELETED_LIST")

Aplicação:
1. Abrir Vivaldi.
2. Configurações > Temas > Biblioteca.
3. Importar Tema.
4. Selecionar:
   $FINAL_ZIP
5. Confirmar em Instalar.

Observação:
Este tema usa o mesmo tipo de pacote que abriu prévia no Vivaldi, mas com acento escuro para não pintar a janela de laranja.
Não edita Preferences e não usa Downloads.
EOF

cp -f "${BASH_SOURCE[0]}" "$SCRIPT_COPY"

step "Abrindo pasta canônica e tela de temas"
xdg-open "$THEME_DIR" >/dev/null 2>&1 || true

if command -v vivaldi-stable >/dev/null 2>&1; then
  nohup vivaldi-stable 'vivaldi://settings/themes/' >/dev/null 2>&1 &
elif command -v vivaldi >/dev/null 2>&1; then
  nohup vivaldi 'vivaldi://settings/themes/' >/dev/null 2>&1 &
elif command -v vivaldi-snapshot >/dev/null 2>&1; then
  nohup vivaldi-snapshot 'vivaldi://settings/themes/' >/dev/null 2>&1 &
else
  printf 'Abra manualmente: vivaldi://settings/themes/\n'
fi

printf '\nPRONTO.\n'
printf 'Importe este ZIP:\n%s\n' "$FINAL_ZIP"
printf '\nLog: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
