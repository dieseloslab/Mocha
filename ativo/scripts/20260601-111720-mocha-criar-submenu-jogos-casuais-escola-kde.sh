#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"

FAST_BASE="/media/mochafast/MochaArch/ativo"
if [[ -d "$FAST_BASE" && -w "$FAST_BASE" ]]; then
  BASE="$FAST_BASE"
else
  BASE="$HOME/MochaArch-ativo-local"
fi

REPORT_DIR="$BASE/relatorios"
DOC_DIR="$BASE/documentacao"
SCRIPT_DIR="$BASE/scripts"
PROFILE_DIR="$BASE/perfis"
mkdir -p "$REPORT_DIR" "$DOC_DIR" "$SCRIPT_DIR" "$PROFILE_DIR/gamer" "$PROFILE_DIR/escola"

LOG="$REPORT_DIR/${TS}-criar-submenu-jogos-casuais-escola-kde.log"
DOC="$DOC_DIR/${TS}-submenu-jogos-casuais-escola-kde.md"

exec > >(tee -a "$LOG") 2>&1

echo "== MOCHAARCH — criar submenu Jogos casuais / Escola no KDE =="
echo "Timestamp: $TS"
echo "Base: $BASE"
echo "Log: $LOG"
echo

if ! command -v pacman >/dev/null 2>&1; then
  echo "ERRO: pacman não encontrado. Este script é para a base Arch/MochaArch."
  exit 1
fi

MENU_DIR="$HOME/.config/menus/applications-merged"
DESKTOP_DIR="$HOME/.local/share/desktop-directories"
MENU_FILE="$MENU_DIR/mocha-jogos-casuais-escola.menu"
DIR_FILE="$DESKTOP_DIR/mocha-jogos-casuais-escola.directory"

mkdir -p "$MENU_DIR" "$DESKTOP_DIR"

backup_keep_two() {
  local target="$1"
  if [[ -f "$target" ]]; then
    local bak="${target}.bak-${TS}"
    cp -a "$target" "$bak"
    echo "Backup criado: $bak"

    local prefix
    prefix="$(basename "$target")"
    local dir
    dir="$(dirname "$target")"

    mapfile -t old_baks < <(find "$dir" -maxdepth 1 -type f -name "${prefix}.bak-*" | sort -r)
    if (( ${#old_baks[@]} > 2 )); then
      echo "Limitando backups antigos de $target a 2 cópias..."
      for old in "${old_baks[@]:2}"; do
        rm -f "$old"
        echo "Backup excedente removido: $old"
      done
    fi
  fi
}

backup_keep_two "$MENU_FILE"
backup_keep_two "$DIR_FILE"

TMPDIR_LOCAL="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR_LOCAL"; }
trap cleanup EXIT

EXPLICIT="$TMPDIR_LOCAL/pacotes-explicitos.txt"
CASUAL_PKGS="$TMPDIR_LOCAL/pacotes-casuais.txt"
DESKTOPS="$TMPDIR_LOCAL/desktops-casuais.txt"
MISSING="$TMPDIR_LOCAL/pacotes-sem-desktop.txt"

pacman -Qqe | sort -u > "$EXPLICIT"
: > "$CASUAL_PKGS"
: > "$DESKTOPS"
: > "$MISSING"

KEEP_REGEX='(^|[-_])(mahjong|mahjongg|kajongg|shisen|kigo|gnugo|qgo|sabaki)([-_]|$)'

CASUAL_EXACT=(
  aisleriot
  atomix
  bomber
  bovo
  five-or-more
  four-in-a-row
  gnome-chess
  gnome-klotski
  gnome-mines
  gnome-nibbles
  gnome-robots
  gnome-sudoku
  gnome-taquin
  gnome-tetravex
  granatier
  hitori
  iagno
  kapman
  katomic
  kblackbox
  kblocks
  kbounce
  kbreakout
  kdiamond
  kfourinline
  kgoldrunner
  killbots
  kiriki
  kjumpingcube
  klickety
  klines
  kmines
  knavalbattle
  knetwalk
  knights
  kolf
  kollision
  konquest
  kpat
  kreversi
  ksirk
  ksnakeduel
  kspaceduel
  ksquares
  ksudoku
  ktuberling
  kubrick
  lightsoff
  lskat
  palapeli
  picmi
  quadrapassel
  swell-foop
  tali
)

echo "Etapa 1/5 — montando lista de jogos casuais que devem ir para a subpasta..."
for pkg in "${CASUAL_EXACT[@]}"; do
  if grep -Fxq -- "$pkg" "$EXPLICIT"; then
    if printf '%s\n' "$pkg" | grep -Eiq "$KEEP_REGEX"; then
      echo "Mantido fora da subpasta casual por regra Mahjong/Go: $pkg"
    else
      printf '%s\n' "$pkg" >> "$CASUAL_PKGS"
    fi
  fi
done

# Reaproveita a lista anterior, se ela existir.
PREV_LIST="$PROFILE_DIR/gamer/retirar-do-perfil-gamer-jogos-casuais-atual.pacmanlist"
if [[ -s "$PREV_LIST" ]]; then
  echo "Lista anterior encontrada: $PREV_LIST"
  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue
    if grep -Fxq -- "$pkg" "$EXPLICIT"; then
      if printf '%s\n' "$pkg" | grep -Eiq "$KEEP_REGEX"; then
        echo "Preservado fora da subpasta casual por regra Mahjong/Go: $pkg"
      else
        printf '%s\n' "$pkg" >> "$CASUAL_PKGS"
      fi
    fi
  done < "$PREV_LIST"
fi

sort -u "$CASUAL_PKGS" -o "$CASUAL_PKGS"

echo
echo "Pacotes casuais classificados para a subpasta: $(wc -l < "$CASUAL_PKGS")"
if [[ -s "$CASUAL_PKGS" ]]; then
  sed 's/^/- /' "$CASUAL_PKGS"
else
  echo "Nenhum pacote casual conhecido foi encontrado instalado como explícito."
fi
echo

echo "Etapa 2/5 — localizando arquivos .desktop desses pacotes..."
TOTAL="$(wc -l < "$CASUAL_PKGS" | tr -d ' ')"
N=0

while IFS= read -r pkg; do
  [[ -n "$pkg" ]] || continue
  N=$((N + 1))
  echo "Verificando $N/$TOTAL: $pkg"

  found=0
  while IFS= read -r desktop_path; do
    [[ -n "$desktop_path" ]] || continue
    if [[ -f "$desktop_path" ]]; then
      basename "$desktop_path" >> "$DESKTOPS"
      found=1
    fi
  done < <(pacman -Qlq "$pkg" 2>/dev/null | grep -E '^/usr/share/applications/.+\.desktop$' || true)

  if (( found == 0 )); then
    printf '%s\n' "$pkg" >> "$MISSING"
  fi
done < "$CASUAL_PKGS"

sort -u "$DESKTOPS" -o "$DESKTOPS"
sort -u "$MISSING" -o "$MISSING"

echo
echo "Arquivos .desktop encontrados: $(wc -l < "$DESKTOPS")"
if [[ -s "$DESKTOPS" ]]; then
  sed 's/^/- /' "$DESKTOPS"
else
  echo "Nenhum .desktop encontrado. Nada será alterado no menu."
fi
echo

if [[ ! -s "$DESKTOPS" ]]; then
  echo "Concluído sem alteração: não havia entradas .desktop para mover visualmente."
  exit 0
fi

echo "Etapa 3/5 — criando diretório visual do submenu..."
cat > "$DIR_FILE" <<'EOF'
[Desktop Entry]
Type=Directory
Name=Jogos casuais / Escola
Name[pt_BR]=Jogos casuais / Escola
Comment=Jogos casuais separados do perfil gamer principal do MochaArch
Comment[pt_BR]=Jogos casuais separados do perfil gamer principal do MochaArch
Icon=applications-games
EOF

echo "Arquivo de diretório criado: $DIR_FILE"

xml_escape() {
  sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/"/\&quot;/g' \
    -e "s/'/\&apos;/g"
}

echo
echo "Etapa 4/5 — criando regra XDG/KDE para submenu dentro de Jogos..."

{
  printf '%s\n' '<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN" "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">'
  printf '%s\n' '<Menu>'
  printf '%s\n' '  <Name>Applications</Name>'
  printf '%s\n' '  <Menu>'
  printf '%s\n' '    <Name>Games</Name>'

  printf '%s\n' '    <Exclude>'
  while IFS= read -r desktop; do
    safe="$(printf '%s\n' "$desktop" | xml_escape)"
    printf '%s\n' "      <Filename>${safe}</Filename>"
  done < "$DESKTOPS"
  printf '%s\n' '    </Exclude>'

  printf '%s\n' '    <Menu>'
  printf '%s\n' '      <Name>MochaJogosCasuaisEscola</Name>'
  printf '%s\n' '      <Directory>mocha-jogos-casuais-escola.directory</Directory>'
  printf '%s\n' '      <Include>'
  while IFS= read -r desktop; do
    safe="$(printf '%s\n' "$desktop" | xml_escape)"
    printf '%s\n' "        <Filename>${safe}</Filename>"
  done < "$DESKTOPS"
  printf '%s\n' '      </Include>'
  printf '%s\n' '    </Menu>'

  printf '%s\n' '  </Menu>'
  printf '%s\n' '</Menu>'
} > "$MENU_FILE"

echo "Arquivo de menu criado: $MENU_FILE"

echo
echo "Etapa 5/5 — atualizando cache do KDE..."
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
  kbuildsycoca5 --noincremental
else
  echo "AVISO: kbuildsycoca não encontrado. O menu pode atualizar só após logout/login."
fi

CURRENT_PKGS="$PROFILE_DIR/escola/${TS}-pacotes-submenu-jogos-casuais-escola.pacmanlist"
CURRENT_DESKTOPS="$PROFILE_DIR/escola/${TS}-desktops-submenu-jogos-casuais-escola.txt"
cp "$CASUAL_PKGS" "$CURRENT_PKGS"
cp "$DESKTOPS" "$CURRENT_DESKTOPS"
cp "$CASUAL_PKGS" "$PROFILE_DIR/escola/pacotes-submenu-jogos-casuais-escola-atual.pacmanlist"
cp "$DESKTOPS" "$PROFILE_DIR/escola/desktops-submenu-jogos-casuais-escola-atual.txt"

append_line() {
  printf '%s\n' "$1" >> "$DOC"
}

: > "$DOC"
append_line "# MochaArch — submenu Jogos casuais / Escola"
append_line ""
append_line "Timestamp: $TS"
append_line ""
append_line "## Decisão"
append_line ""
append_line "Os jogos que não são foco do perfil gamer principal devem ficar numa subpasta dentro de Jogos."
append_line ""
append_line "Subpasta criada no menu KDE: Jogos casuais / Escola."
append_line ""
append_line "Mahjong e Go permanecem fora dessa subpasta por serem exceções leves aprovadas para o perfil Gamer."
append_line ""
append_line "Nenhum pacote foi removido."
append_line ""
append_line "## Arquivos aplicados no usuário atual"
append_line ""
append_line "- Menu XDG/KDE: $MENU_FILE"
append_line "- Diretório visual: $DIR_FILE"
append_line "- Lista de pacotes: $CURRENT_PKGS"
append_line "- Lista de .desktop: $CURRENT_DESKTOPS"
append_line "- Log: $LOG"
append_line ""
append_line "## Pacotes classificados para a subpasta"
append_line ""
if [[ -s "$CASUAL_PKGS" ]]; then
  while IFS= read -r pkg; do append_line "- $pkg"; done < "$CASUAL_PKGS"
else
  append_line "- Nenhum pacote classificado."
fi
append_line ""
append_line "## Entradas .desktop movidas visualmente"
append_line ""
if [[ -s "$DESKTOPS" ]]; then
  while IFS= read -r desktop; do append_line "- $desktop"; done < "$DESKTOPS"
else
  append_line "- Nenhuma entrada .desktop encontrada."
fi
append_line ""
append_line "## Pacotes sem .desktop detectado"
append_line ""
if [[ -s "$MISSING" ]]; then
  while IFS= read -r pkg; do append_line "- $pkg"; done < "$MISSING"
else
  append_line "- Nenhum."
fi
append_line ""
append_line "## Regra para a ISO"
append_line ""
append_line "Na edição Gamer do MochaArch, manter o menu principal de Jogos limpo."
append_line ""
append_line "Jogos casuais que não são foco gamer entram em Jogos > Jogos casuais / Escola."
append_line ""
append_line "Mahjong/Go podem permanecer no nível principal de Jogos se estiverem instalados."

cp "$0" "$SCRIPT_DIR/${TS}-mocha-criar-submenu-jogos-casuais-escola-kde.sh"

echo
echo "== Resultado =="
echo "Submenu criado: Jogos > Jogos casuais / Escola"
echo "Pacotes na subpasta: $(wc -l < "$CASUAL_PKGS")"
echo "Entradas .desktop na subpasta: $(wc -l < "$DESKTOPS")"
echo "Menu: $MENU_FILE"
echo "Documento: $DOC"
echo "Script salvo: $SCRIPT_DIR/${TS}-mocha-criar-submenu-jogos-casuais-escola-kde.sh"
echo
echo "Se o lançador KDE ainda mostrar o layout antigo, reinicie o plasmashell ou faça logout/login."
