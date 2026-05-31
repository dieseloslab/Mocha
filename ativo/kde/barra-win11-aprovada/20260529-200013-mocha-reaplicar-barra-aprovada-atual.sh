#!/usr/bin/env bash
set -Eeuo pipefail

BASE="/media/mochafast/MochaArch"
ACTIVE="$BASE/ativo"
SRC="$ACTIVE/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual"
DST="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc.backup-$TS"

if [ ! -f "$SRC" ]; then
  echo "ERRO: snapshot aprovado atual nao encontrado: $SRC"
  exit 1
fi

cp -a "$DST" "$BACKUP" 2>/dev/null || true

if command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 plasmashell || true
else
  killall plasmashell 2>/dev/null || true
fi

sleep 2
cp -a "$SRC" "$DST"

if command -v kstart6 >/dev/null 2>&1; then
  kstart6 plasmashell >/dev/null 2>&1 &
else
  nohup plasmashell >/dev/null 2>&1 &
fi

echo "Barra Mocha aprovada reaplicada."
echo "Backup anterior: $BACKUP"
