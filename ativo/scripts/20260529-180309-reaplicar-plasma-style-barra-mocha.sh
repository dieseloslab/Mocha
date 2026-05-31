#!/usr/bin/env bash
set -Eeuo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
THEME_ID="MochaPanelSolidCanonico"
SRC="/media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico"
DST="$HOME/.local/share/plasma/desktoptheme/$THEME_ID"
mkdir -p "$DST"
cp -a "$SRC/." "$DST/"
if command -v plasma-apply-desktoptheme >/dev/null 2>&1; then
  plasma-apply-desktoptheme "$THEME_ID" || true
fi
kwriteconfig6 --file plasmarc --group Theme --key name "$THEME_ID"
if command -v qdbus6 >/dev/null 2>&1; then
  qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi
if command -v kquitapp6 >/dev/null 2>&1 && command -v plasmashell >/dev/null 2>&1; then
  kquitapp6 plasmashell 2>/dev/null || true
  sleep 2
  nohup plasmashell >/tmp/mocha-reaplicar-plasma-style-barra.log 2>&1 &
fi
echo "Tema Plasma reaplicado: $THEME_ID"
