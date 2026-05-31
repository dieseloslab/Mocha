#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
fi

if [ ! -f "$APPROVED" ]; then
  echo "ERRO: appletsrc aprovado não encontrado:"
  echo "  $APPROVED"
  exit 1
fi

if [ ! -f "$CFG" ]; then
  echo "ERRO: appletsrc atual não encontrado:"
  echo "  $CFG"
  exit 1
fi

if ! grep -q 'plugin=org.kde.plasma.panelspacer' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem panelspacer. Abortando."
  exit 1
fi

if ! grep -Eq 'plugin=org\.kde\.plasma\.(icontasks|taskmanager)' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem icontasks/taskmanager. Abortando."
  exit 1
fi

BACKUP="$BACKUP_DIR/${TS}-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11"
cp -a "$CFG" "$BACKUP"

find "$BACKUP_DIR" -maxdepth 1 -type f -name '*plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11*' \
  -printf '%T@ %p\n' 2>/dev/null \
  | sort -nr \
  | awk 'NR>2 {sub(/^[^ ]+ /,""); print}' \
  | while IFS= read -r old; do
      [ -n "$old" ] && rm -f -- "$old"
    done || true

echo "Backup salvo em:"
echo "  $BACKUP"

echo "Parando Plasma Shell..."
if command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 plasmashell >/dev/null 2>&1 || true
else
  pkill -x plasmashell >/dev/null 2>&1 || true
fi

sleep 2

echo "Aplicando appletsrc aprovado..."
cp -a "$APPROVED" "$CFG"

echo "Reiniciando Plasma Shell..."
if command -v kstart6 >/dev/null 2>&1; then
  nohup kstart6 plasmashell >/tmp/mocha-plasmashell-${TS}.log 2>&1 &
elif command -v kstart >/dev/null 2>&1; then
  nohup kstart plasmashell >/tmp/mocha-plasmashell-${TS}.log 2>&1 &
elif command -v plasmashell >/dev/null 2>&1; then
  nohup plasmashell >/tmp/mocha-plasmashell-${TS}.log 2>&1 &
else
  echo "ERRO: não encontrei plasmashell para reiniciar."
  echo "Restaure manualmente com:"
  echo "  cp -a '$BACKUP' '$CFG'"
  exit 1
fi

sleep 3

echo
echo "Validação:"
grep -nE 'AppletOrder=|plugin=org\.kde\.plasma\.panelspacer|expanding=true|plugin=org\.kde\.plasma\.kickoff|plugin=org\.kde\.plasma\.icontasks|plugin=org\.kde\.plasma\.taskmanager|plugin=org\.kde\.plasma\.systemtray|plugin=org\.kde\.plasma\.digitalclock' "$CFG" || true

echo
echo "Barra Win11/Mocha aprovada restaurada."
echo "Log:"
echo "  $LOG"
echo "Backup:"
echo "  $BACKUP"
