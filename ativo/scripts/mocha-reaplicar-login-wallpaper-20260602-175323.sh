#!/usr/bin/env bash
set -Eeuo pipefail

sudo -v

PLASMA_CFG="${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc"
RAW_WALLPAPER="$(
  awk -F= '
    $1=="Image" || $1=="PreviewImage" {
      val=$0
      sub(/^[^=]*=/, "", val)
      if (val != "") print val
    }
  ' "$PLASMA_CFG" | tail -n 1
)"

WALLPAPER="${RAW_WALLPAPER#file://}"
WALLPAPER="${WALLPAPER/#\~/$HOME}"

if [[ -d "$WALLPAPER" ]]; then
  WALLPAPER="$(
    find "$WALLPAPER" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
      | sort \
      | tail -n 1
  )"
fi

[[ -f "$WALLPAPER" ]] || {
  printf '%s\n' "ERRO: wallpaper não encontrado: ${WALLPAPER}"
  exit 1
}

THEME_SRC="/usr/share/sddm/themes/breeze"
THEME_DST="/usr/share/sddm/themes/mocha-login"
TS="$(date +%Y%m%d-%H%M%S)"
THEME_WALLPAPER="${THEME_DST}/mocha-login-wallpaper-${TS}.${WALLPAPER##*.}"

sudo mkdir -p "$THEME_DST"
sudo rsync -a --delete "$THEME_SRC"/ "$THEME_DST"/
sudo install -m 0644 "$WALLPAPER" "$THEME_WALLPAPER"

sudo tee "${THEME_DST}/theme.conf.user" >/dev/null <<EOF
[General]
background=${THEME_WALLPAPER}
type=image
color=#1b1410
fontSize=12
needsFullUserModel=false
EOF

sudo tee /etc/sddm.conf.d/99-mocha-login-wallpaper-wayland.conf >/dev/null <<EOF
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Theme]
Current=mocha-login
ThemeDir=/usr/share/sddm/themes

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1 --inputmethod qt6-virtualkeyboard
EOF

printf '%s\n' "Login SDDM Mocha reaplicado com wallpaper: ${WALLPAPER}"
