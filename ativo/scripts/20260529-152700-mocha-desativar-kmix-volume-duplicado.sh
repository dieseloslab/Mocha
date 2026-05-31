#!/usr/bin/env bash
set -Eeuo pipefail

AUTO_USER="$HOME/.config/autostart/kmix_autostart.desktop"
mkdir -p "$HOME/.config/autostart"

SRC=""
for candidate in \
  "/etc/xdg/autostart/kmix_autostart.desktop" \
  "/usr/etc/xdg/autostart/kmix_autostart.desktop" \
  "/usr/share/applications/org.kde.kmix.desktop" \
  "/usr/share/applications/kmix.desktop"
do
  if [ -f "$candidate" ]; then
    SRC="$candidate"
    break
  fi
done

if [ -n "$SRC" ]; then
  cp -a "$SRC" "$AUTO_USER"
else
  cat > "$AUTO_USER" <<'EOINNER'
[Desktop Entry]
Type=Application
Name=KMix
Comment=Disabled by Mocha KDE because Plasma volume applet already provides volume control in the system tray
Exec=kmix --keepvisibility
OnlyShowIn=KDE;
EOINNER
fi

if grep -q '^Hidden=' "$AUTO_USER"; then
  sed -i 's/^Hidden=.*/Hidden=true/' "$AUTO_USER"
else
  printf '\nHidden=true\n' >> "$AUTO_USER"
fi

systemctl --user stop app-kmix_autostart@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "KMix autostart desativado para o usuário atual."
