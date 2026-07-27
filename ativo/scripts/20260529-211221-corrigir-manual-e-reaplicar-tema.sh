#!/usr/bin/env bash
set -Eeuo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
ACTIVE="$BASE/ativo"

MANUAL="$ACTIVE/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
DOC_DIR="$ACTIVE/documentacao"
SCRIPT_DIR="$ACTIVE/scripts"
BACKUP_DIR="$ACTIVE/backups/manual-e-tema"
LOG_DIR="$ACTIVE/logs"
LOG="$LOG_DIR/${TS}-corrigir-manual-e-reaplicar-tema.log"

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

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "comando obrigatório não encontrado: $1"
}

append_line() {
  printf '%s\n' "$1" >> "$DOC"
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

backup_dir_keep_two() {
  local src="$1"
  local label="$2"

  [ -d "$src" ] || return 0

  mkdir -p "$BACKUP_DIR"
  cp -a "$src" "$BACKUP_DIR/${TS}-${label}.bak"

  find "$BACKUP_DIR" -maxdepth 1 -type d -name "*-${label}.bak" -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | awk 'NR>2 {print substr($0, index($0,$2))}' \
    | while IFS= read -r old; do
        [ -n "$old" ] && rm -rf -- "$old"
      done
}

find_one_file() {
  local name="$1"
  shift

  find "$@" \
    \( -path '*/XU' -o -path '*/XU/*' \) -prune -o \
    -type f -name "$name" -print 2>/dev/null | sort | head -n 1 || true
}

find_one_dir() {
  local name="$1"
  shift

  find "$@" \
    \( -path '*/XU' -o -path '*/XU/*' \) -prune -o \
    -type d -name "$name" -print 2>/dev/null | sort | head -n 1 || true
}

remove_entrada_errada_manual() {
  [ -f "$MANUAL" ] || {
    info "Manual vivo não existe em $MANUAL; nada a remover nele."
    return 0
  }

  say "Corrigindo manual vivo: removendo entrada errada"

  backup_file_keep_two "$MANUAL" "MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"

  local tmp removed
  tmp="$(mktemp)"
  removed="$(mktemp)"

  awk -v removed_file="$removed" '
    BEGIN {
      skip=0
      removed_any=0
    }

    /^## [0-9]{8}-[0-9]{6} - Tema Mocha aprovado reaplicado[[:space:]]*$/ {
      skip=1
      removed_any=1
      print $0 >> removed_file
      next
    }

    /^## / && skip==1 {
      skip=0
    }

    skip==1 {
      print $0 >> removed_file
      next
    }

    {
      print $0
    }

    END {
      if (removed_any==0) {
        print "__NENHUMA_ENTRADA_ERRADA_ENCONTRADA__" >> removed_file
      }
    }
  ' "$MANUAL" > "$tmp"

  if grep -Fx "__NENHUMA_ENTRADA_ERRADA_ENCONTRADA__" "$removed" >/dev/null 2>&1; then
    rm -f "$tmp" "$removed"
    info "Nenhuma entrada antiga com título exato 'Tema Mocha aprovado reaplicado' foi encontrada."
  else
    cp -a "$tmp" "$MANUAL"
    mkdir -p "$ACTIVE/quarentena/manual"
    mv "$removed" "$ACTIVE/quarentena/manual/${TS}-entrada-errada-removida-tema-mocha.md"
    rm -f "$tmp"
    ok "Entrada errada removida do manual e movida para quarentena/manual."
  fi
}

restart_plasma_shell() {
  say "Reiniciando plasmashell para aplicar visual"

  if systemctl --user list-unit-files 2>/dev/null | grep -q '^plasma-plasmashell\.service'; then
    systemctl --user restart plasma-plasmashell.service || true
    sleep 2
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

  sleep 3
  pgrep -x plasmashell >/dev/null 2>&1 && ok "plasmashell reiniciado" || fail "plasmashell não voltou; use Alt+F2 e rode: plasmashell"
}

mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$BACKUP_DIR" "$LOG_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Pré-checagem"

findmnt /media/mochafast >/dev/null 2>&1 || fail "/media/mochafast não está montado."
findmnt /media/vmstore >/dev/null 2>&1 || fail "/media/vmstore não está montado."
[ -d "$ACTIVE" ] || fail "pasta ativa não encontrada: $ACTIVE"

need_cmd awk
need_cmd grep
need_cmd find
need_cmd cp
need_cmd kreadconfig6
need_cmd kwriteconfig6

if [ "${XDG_SESSION_TYPE:-}" != "wayland" ]; then
  fail "sessão atual não é Wayland; não vou aplicar tema fora do caminho aprovado."
fi

say "Estado atual antes da correção"

CURRENT_COLOR="$(kreadconfig6 --file kdeglobals --group General --key ColorScheme 2>/dev/null || true)"
CURRENT_STYLE="$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null || true)"

info "ColorScheme atual: ${CURRENT_COLOR:-desconhecido}"
info "Plasma Style atual: ${CURRENT_STYLE:-desconhecido}"

remove_entrada_errada_manual

say "Localizando arquivos aprovados do tema sem tocar XU"

COLOR_SRC="$(find_one_file "${COLOR_NAME}.colors" \
  "$ACTIVE" \
  "$HOME/.local/share/color-schemes" \
  "/usr/share/color-schemes")"

STYLE_SRC="$(find_one_dir "$STYLE_NAME" \
  "$ACTIVE" \
  "$HOME/.local/share/plasma/desktoptheme" \
  "/usr/share/plasma/desktoptheme")"

[ -n "$COLOR_SRC" ] || fail "não encontrei ${COLOR_NAME}.colors no ativo/local/sistema."
[ -n "$STYLE_SRC" ] || fail "não encontrei diretório do Plasma Style ${STYLE_NAME} no ativo/local/sistema."

info "ColorScheme fonte: $COLOR_SRC"
info "Plasma Style fonte: $STYLE_SRC"

if [ ! -f "$STYLE_SRC/metadata.json" ] && [ ! -f "$STYLE_SRC/metadata.desktop" ]; then
  fail "o diretório encontrado para $STYLE_NAME não parece ser um Plasma Style válido: $STYLE_SRC"
fi

say "Instalando tema aprovado no usuário atual"

COLOR_DEST_DIR="$HOME/.local/share/color-schemes"
COLOR_DEST="$COLOR_DEST_DIR/${COLOR_NAME}.colors"
STYLE_DEST_DIR="$HOME/.local/share/plasma/desktoptheme"
STYLE_DEST="$STYLE_DEST_DIR/$STYLE_NAME"

mkdir -p "$COLOR_DEST_DIR" "$STYLE_DEST_DIR"

backup_file_keep_two "$HOME/.config/kdeglobals" "kdeglobals"
backup_file_keep_two "$HOME/.config/plasmarc" "plasmarc"
backup_file_keep_two "$COLOR_DEST" "${COLOR_NAME}.colors"
backup_dir_keep_two "$STYLE_DEST" "$STYLE_NAME"

cp -a "$COLOR_SRC" "$COLOR_DEST"

TMP_STYLE="${STYLE_DEST}.tmp.${TS}"
rm -rf -- "$TMP_STYLE"
mkdir -p "$TMP_STYLE"
cp -a "$STYLE_SRC"/. "$TMP_STYLE"/
rm -rf -- "$STYLE_DEST"
mv "$TMP_STYLE" "$STYLE_DEST"

ok "Arquivos do tema aprovados reinstalados"

say "Aplicando ColorScheme e Plasma Style"

if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
  plasma-apply-colorscheme "$COLOR_NAME" || kwriteconfig6 --file kdeglobals --group General --key ColorScheme "$COLOR_NAME"
else
  kwriteconfig6 --file kdeglobals --group General --key ColorScheme "$COLOR_NAME"
fi

if command -v plasma-apply-desktoptheme >/dev/null 2>&1; then
  plasma-apply-desktoptheme "$STYLE_NAME" || kwriteconfig6 --file plasmarc --group Theme --key name "$STYLE_NAME"
else
  kwriteconfig6 --file plasmarc --group Theme --key name "$STYLE_NAME"
fi

kwriteconfig6 --file kdeglobals --group General --key ColorScheme "$COLOR_NAME"
kwriteconfig6 --file plasmarc --group Theme --key name "$STYLE_NAME"

restart_plasma_shell

say "Validação final"

AFTER_COLOR="$(kreadconfig6 --file kdeglobals --group General --key ColorScheme 2>/dev/null || true)"
AFTER_STYLE="$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null || true)"

info "ColorScheme depois: ${AFTER_COLOR:-desconhecido}"
info "Plasma Style depois: ${AFTER_STYLE:-desconhecido}"

[ "$AFTER_COLOR" = "$COLOR_NAME" ] || fail "ColorScheme não ficou como $COLOR_NAME."
[ "$AFTER_STYLE" = "$STYLE_NAME" ] || fail "Plasma Style não ficou como $STYLE_NAME."

ok "Tema Mocha aprovado aplicado e validado"

say "Documentando entrada correta"

REUSABLE="$SCRIPT_DIR/${TS}-corrigir-manual-e-reaplicar-tema.sh"
cp -a "$0" "$REUSABLE"
chmod +x "$REUSABLE"

DOC="$DOC_DIR/${TS}-tema-mocha-aprovado-validado-e-manual-corrigido.md"
: > "$DOC"

append_line "# Tema Mocha aprovado validado e manual corrigido"
append_line ""
append_line "Data: $TS"
append_line ""
append_line "Estado antes:"
append_line ""
append_line "- ColorScheme: ${CURRENT_COLOR:-desconhecido}"
append_line "- Plasma Style: ${CURRENT_STYLE:-desconhecido}"
append_line ""
append_line "Estado validado depois:"
append_line ""
append_line "- ColorScheme: $AFTER_COLOR"
append_line "- Plasma Style: $AFTER_STYLE"
append_line ""
append_line "Correção do manual:"
append_line ""
append_line "- Foi removida do manual vivo a entrada antiga com título exato: Tema Mocha aprovado reaplicado, caso existisse."
append_line "- A entrada removida foi movida para quarentena/manual quando encontrada."
append_line "- A entrada correta só foi registrada depois da validação real."
append_line ""
append_line "Arquivos:"
append_line ""
append_line "- Fonte do esquema de cores: $COLOR_SRC"
append_line "- Fonte do Plasma Style: $STYLE_SRC"
append_line "- Script reutilizável: $REUSABLE"
append_line "- Log: $LOG"
append_line ""
append_line "Restrições preservadas:"
append_line ""
append_line "- Não alterou teclado."
append_line "- Não usou X11."
append_line "- Não removeu programas."
append_line "- Não tocou na pasta XU."
append_line "- Não mexeu em kernel, NVIDIA, bootloader, mounts ou performance."

if [ -f "$MANUAL" ]; then
  {
    printf '\n'
    printf '%s\n' "## $TS - Tema Mocha aprovado aplicado e validado"
    printf '\n'
    printf '%s\n' "- ColorScheme antes: ${CURRENT_COLOR:-desconhecido}"
    printf '%s\n' "- Plasma Style antes: ${CURRENT_STYLE:-desconhecido}"
    printf '%s\n' "- ColorScheme validado depois: $AFTER_COLOR"
    printf '%s\n' "- Plasma Style validado depois: $AFTER_STYLE"
    printf '%s\n' "- Entrada errada antiga removida quando encontrada."
    printf '%s\n' "- Script reutilizável: $REUSABLE"
    printf '%s\n' "- Log: $LOG"
  } >> "$MANUAL"
  ok "Manual vivo corrigido e atualizado: $MANUAL"
else
  info "Manual vivo não encontrado; documentação individual criada em: $DOC"
fi

say "Finalizado"
printf '%s\n' "[OK] Documento: $DOC"
printf '%s\n' "[OK] Script reutilizável: $REUSABLE"
printf '%s\n' "[OK] Log: $LOG"
