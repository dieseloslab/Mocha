#!/usr/bin/env bash
set -Eeuo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
ACTIVE="$BASE/ativo"

APPLET_SRC="$ACTIVE/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"

DOC_DIR="$ACTIVE/documentacao"
SCRIPT_DIR="$ACTIVE/scripts"
BACKUP_DIR="$ACTIVE/backups/wallpaper-e-barra"
LOG_DIR="$ACTIVE/logs"
LOG="$LOG_DIR/${TS}-aplicar-wallpaper-e-barra-mocha.log"

COLOR_NAME="MochaSolidCanonico"
STYLE_NAME="MochaPanelSolidCanonico"

say() {
  printf '\n== %s ==\n' "$*"
}

ok() {
  printf '%s\n' "[OK] $*"
}

info() {
  printf '%s\n' "[INFO] $*"
}

warn() {
  printf '%s\n' "[PENDENTE] $*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "comando obrigatório não encontrado: $1"
}

backup_file_keep_two() {
  local src="$1"
  local label="$2"

  [ -f "$src" ] || return 0

  mkdir -p "$BACKUP_DIR"
  cp -a "$src" "$BACKUP_DIR/${TS}-${label}.bak"

  find "$BACKUP_DIR" -maxdepth 1 -type f -name "*-${label}.bak" -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | awk 'NR>2 {print substr($0, index($0,$2))}' \
    | while IFS= read -r old; do
        [ -n "$old" ] && rm -f -- "$old"
      done
}

restart_plasma_shell() {
  say "Reiniciando plasmashell"

  if systemctl --user list-unit-files 2>/dev/null | grep -q '^plasma-plasmashell\.service'; then
    systemctl --user restart plasma-plasmashell.service || true
    sleep 3
    if pgrep -x plasmashell >/dev/null 2>&1; then
      ok "plasmashell reiniciado via systemd do usuário"
      return 0
    fi
  fi

  if command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 plasmashell >/dev/null 2>&1 || true
  else
    pkill -x plasmashell >/dev/null 2>&1 || true
  fi

  sleep 2

  if command -v kstart6 >/dev/null 2>&1; then
    kstart6 plasmashell >/dev/null 2>&1 &
  else
    nohup plasmashell >/dev/null 2>&1 &
  fi

  sleep 4
  pgrep -x plasmashell >/dev/null 2>&1 || fail "plasmashell não voltou; use Alt+F2 e rode: plasmashell"
  ok "plasmashell reiniciado"
}

apply_wallpaper() {
  local wallpaper="$1"
  local wallpaper_uri="file://$wallpaper"

  say "Aplicando wallpaper Mocha"

  if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
    plasma-apply-wallpaperimage "$wallpaper" || true
  fi

  if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
      var allDesktops = desktops();
      for (i = 0; i < allDesktops.length; i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
        d.writeConfig('Image', '$wallpaper_uri');
      }
    " >/dev/null 2>&1 || true
  fi

  ok "Wallpaper aplicado: $wallpaper"
}

mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$BACKUP_DIR" "$LOG_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Pré-checagem"

findmnt /media/mochafast >/dev/null 2>&1 || fail "/media/mochafast não está montado."
findmnt /media/vmstore >/dev/null 2>&1 || fail "/media/vmstore não está montado."
[ -d "$ACTIVE" ] || fail "pasta ativa não encontrada: $ACTIVE"
[ -f "$APPLET_SRC" ] || fail "arquivo aprovado da barra não encontrado: $APPLET_SRC"

need_cmd find
need_cmd grep
need_cmd cp
need_cmd kreadconfig6
need_cmd kwriteconfig6

if [ "${XDG_SESSION_TYPE:-}" != "wayland" ]; then
  fail "sessão atual não é Wayland; não vou aplicar visual fora do caminho aprovado."
fi

say "Conferindo tema já aplicado"

CURRENT_COLOR="$(kreadconfig6 --file kdeglobals --group General --key ColorScheme 2>/dev/null || true)"
CURRENT_STYLE="$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null || true)"

info "ColorScheme atual: ${CURRENT_COLOR:-desconhecido}"
info "Plasma Style atual: ${CURRENT_STYLE:-desconhecido}"

if [ "${CURRENT_COLOR:-}" != "$COLOR_NAME" ]; then
  warn "ColorScheme atual não é $COLOR_NAME; vou fixar novamente no final."
fi

if [ "${CURRENT_STYLE:-}" != "$STYLE_NAME" ]; then
  warn "Plasma Style atual não é $STYLE_NAME; vou fixar novamente no final."
fi

say "Localizando wallpaper Mocha aprovado sem tocar XU"

WALLPAPER_CANDIDATES_FILE="$(mktemp)"

{
  find "$ACTIVE" \
    \( -path '*/XU' -o -path '*/XU/*' \) -prune -o \
    -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    \( -ipath '*wallpaper*' -o -iname '*mocha*' -o -iname '*arch*' \) \
    -printf '%T@ %p\n' 2>/dev/null || true

  if [ -d "/media/mochafast/Legacy/kdePCan/assets/branding/wallpaper" ]; then
    find "/media/mochafast/Legacy/kdePCan/assets/branding/wallpaper" \
      -type f \
      \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
      -printf '%T@ %p\n' 2>/dev/null || true
  fi
} | sort -nr | awk '{print substr($0, index($0,$2))}' > "$WALLPAPER_CANDIDATES_FILE"

if [ ! -s "$WALLPAPER_CANDIDATES_FILE" ]; then
  fail "nenhum wallpaper candidato encontrado no ativo nem no caminho Legacy/kdePCan."
fi

info "Candidatos encontrados:"
cat "$WALLPAPER_CANDIDATES_FILE"

WALLPAPER="$(grep -Ei '/(ativo|MochaArch)/.*(wallpaper|mocha|arch).*\.(png|jpg|jpeg|webp)$' "$WALLPAPER_CANDIDATES_FILE" | head -n 1 || true)"

if [ -z "$WALLPAPER" ]; then
  WALLPAPER="$(head -n 1 "$WALLPAPER_CANDIDATES_FILE")"
  warn "Não encontrei candidato preferencial dentro do ativo; usando o primeiro candidato disponível."
fi

[ -n "$WALLPAPER" ] || fail "não foi possível selecionar wallpaper."
[ -f "$WALLPAPER" ] || fail "wallpaper selecionado não existe: $WALLPAPER"

info "Wallpaper selecionado: $WALLPAPER"

say "Aplicando barra Win11/Mocha aprovada"

TARGET_APPLET="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

backup_file_keep_two "$TARGET_APPLET" "plasma-org.kde.plasma.desktop-appletsrc"
backup_file_keep_two "$HOME/.config/kdeglobals" "kdeglobals"
backup_file_keep_two "$HOME/.config/plasmarc" "plasmarc"

if pgrep -x plasmashell >/dev/null 2>&1; then
  if command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 plasmashell >/dev/null 2>&1 || true
  else
    pkill -x plasmashell >/dev/null 2>&1 || true
  fi
  sleep 2
fi

cp -a "$APPLET_SRC" "$TARGET_APPLET"
ok "Appletsrc aprovado aplicado: $APPLET_SRC"

say "Fixando esquema e Plasma Style Mocha no KDE"

kwriteconfig6 --file kdeglobals --group General --key ColorScheme "$COLOR_NAME"
kwriteconfig6 --file plasmarc --group Theme --key name "$STYLE_NAME"

restart_plasma_shell
apply_wallpaper "$WALLPAPER"

say "Validação final"

AFTER_COLOR="$(kreadconfig6 --file kdeglobals --group General --key ColorScheme 2>/dev/null || true)"
AFTER_STYLE="$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null || true)"

info "ColorScheme depois: ${AFTER_COLOR:-desconhecido}"
info "Plasma Style depois: ${AFTER_STYLE:-desconhecido}"

[ "$AFTER_COLOR" = "$COLOR_NAME" ] || fail "ColorScheme não ficou como $COLOR_NAME."
[ "$AFTER_STYLE" = "$STYLE_NAME" ] || fail "Plasma Style não ficou como $STYLE_NAME."
[ -f "$TARGET_APPLET" ] || fail "appletsrc final não existe."

ok "Barra Mocha e tema Mocha validados"
ok "Wallpaper Mocha aplicado"

say "Documentando passo aprovado"

REUSABLE="$SCRIPT_DIR/${TS}-aplicar-wallpaper-e-barra-mocha.sh"
cp -a "$0" "$REUSABLE"
chmod +x "$REUSABLE"

DOC="$DOC_DIR/${TS}-wallpaper-e-barra-mocha-aplicados.md"
: > "$DOC"

{
  printf '%s\n' "# Wallpaper e barra Mocha aplicados"
  printf '%s\n' ""
  printf '%s\n' "Data: $TS"
  printf '%s\n' ""
  printf '%s\n' "Resultado:"
  printf '%s\n' ""
  printf '%s\n' "- Wallpaper aplicado: $WALLPAPER"
  printf '%s\n' "- Barra aplicada a partir de: $APPLET_SRC"
  printf '%s\n' "- ColorScheme validado: $AFTER_COLOR"
  printf '%s\n' "- Plasma Style validado: $AFTER_STYLE"
  printf '%s\n' "- Script reutilizável: $REUSABLE"
  printf '%s\n' "- Log: $LOG"
  printf '%s\n' ""
  printf '%s\n' "Restrições preservadas:"
  printf '%s\n' ""
  printf '%s\n' "- Não alterou teclado."
  printf '%s\n' "- Não usou X11."
  printf '%s\n' "- Não removeu programas."
  printf '%s\n' "- Não tocou na pasta XU."
  printf '%s\n' "- Não mexeu em kernel, NVIDIA, bootloader, mounts ou performance."
} >> "$DOC"

MANUAL="$ACTIVE/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
if [ -f "$MANUAL" ]; then
  {
    printf '\n'
    printf '%s\n' "## $TS - Wallpaper e barra Mocha aplicados"
    printf '\n'
    printf '%s\n' "- Wallpaper aplicado: $WALLPAPER"
    printf '%s\n' "- Barra aplicada a partir do appletsrc aprovado: $APPLET_SRC"
    printf '%s\n' "- ColorScheme validado: $AFTER_COLOR"
    printf '%s\n' "- Plasma Style validado: $AFTER_STYLE"
    printf '%s\n' "- Script reutilizável: $REUSABLE"
    printf '%s\n' "- Log: $LOG"
  } >> "$MANUAL"
  ok "Manual vivo atualizado: $MANUAL"
else
  warn "Manual vivo não encontrado; documentação individual criada em: $DOC"
fi

rm -f "$WALLPAPER_CANDIDATES_FILE"

say "Finalizado"
printf '%s\n' "[OK] Documento: $DOC"
printf '%s\n' "[OK] Script reutilizável: $REUSABLE"
printf '%s\n' "[OK] Log: $LOG"
