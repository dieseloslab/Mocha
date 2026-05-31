#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

WALLPAPER="/media/mochafast/MochaArch/ativo/assets/branding/wallpaper/mocha-wallpaper-kdePCan-20260529-163403.png"

if [[ ! -f "$WALLPAPER" ]]; then
  echo "ERRO: wallpaper não encontrado:"
  echo "$WALLPAPER"
  exit 1
fi

if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
  plasma-apply-wallpaperimage "$WALLPAPER"
  echo "Wallpaper aplicado com plasma-apply-wallpaperimage:"
  echo "$WALLPAPER"
  exit 0
fi

QDBUS_BIN=""
if command -v qdbus6 >/dev/null 2>&1; then
  QDBUS_BIN="$(command -v qdbus6)"
elif command -v qdbus >/dev/null 2>&1; then
  QDBUS_BIN="$(command -v qdbus)"
fi

if [[ -z "$QDBUS_BIN" ]]; then
  echo "ERRO: qdbus6/qdbus não encontrado."
  exit 1
fi

WALL_URI="file://$WALLPAPER"
JS_FILE="$(mktemp -t mocha-wallpaper-plasma-js.XXXXXX)"
cat > "$JS_FILE" <<EOS
var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
    var d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
    d.writeConfig("Image", "$WALL_URI");
    d.writeConfig("FillMode", 2);
}
EOS

"$QDBUS_BIN" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$JS_FILE")"
rm -f "$JS_FILE"

echo "Wallpaper aplicado via D-Bus Plasma:"
echo "$WALLPAPER"
