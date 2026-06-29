#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

TARGET="${1:-/target}"
THEME_NAME="MochaPanelSolidCanonico"
COLOR_NAME="MochaSolidCanonico"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PAYLOAD="${MOCHA_TEMA_PAYLOAD:-"$SCRIPT_DIR/../payload/tema-completo"}"

fail() {
  echo "[FALHA] $*" >&2
  exit 1
}

log() {
  printf '\n[%s] %s\n' "$(date '+%F %T')" "$*"
}

[ -d "$TARGET" ] || fail "Target inexistente: $TARGET"
[ -d "$PAYLOAD" ] || fail "Payload inexistente: $PAYLOAD"

THEME_SRC="$PAYLOAD/plasma/desktoptheme/$THEME_NAME"
COLOR_SRC="$PAYLOAD/color-schemes/$COLOR_NAME.colors"
CONFIG_SRC="$PAYLOAD/config"
WALL_SRC_DIR="$PAYLOAD/wallpaper"

[ -d "$THEME_SRC" ] || fail "Plasma Style ausente no payload: $THEME_SRC"

log "Instalando Plasma Style no sistema instalado"
install -d "$TARGET/usr/share/plasma/desktoptheme"
rm -rf "$TARGET/usr/share/plasma/desktoptheme/$THEME_NAME"
cp -a "$THEME_SRC" "$TARGET/usr/share/plasma/desktoptheme/$THEME_NAME"

log "Instalando ColorScheme no sistema instalado"
install -d "$TARGET/usr/share/color-schemes"
if [ -f "$COLOR_SRC" ]; then
  cp -a "$COLOR_SRC" "$TARGET/usr/share/color-schemes/$COLOR_NAME.colors"
fi

log "Instalando wallpaper em local global"
install -d "$TARGET/usr/share/wallpapers/Mocha"
WALL_FILE=""
if [ -d "$WALL_SRC_DIR" ]; then
  WALL_FILE="$(find "$WALL_SRC_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort | head -n1 || true)"
fi

if [ -n "$WALL_FILE" ] && [ -f "$WALL_FILE" ]; then
  cp -a "$WALL_FILE" "$TARGET/usr/share/wallpapers/Mocha/$(basename "$WALL_FILE")"
fi

apply_to_home() {
  local home_dir="$1"
  local mode="$2"

  [ -d "$home_dir" ] || return 0

  log "Aplicando tema Mocha em $home_dir"

  install -d "$home_dir/.local/share/plasma/desktoptheme"
  rm -rf "$home_dir/.local/share/plasma/desktoptheme/$THEME_NAME"
  cp -a "$THEME_SRC" "$home_dir/.local/share/plasma/desktoptheme/$THEME_NAME"

  install -d "$home_dir/.local/share/color-schemes"
  if [ -f "$COLOR_SRC" ]; then
    cp -a "$COLOR_SRC" "$home_dir/.local/share/color-schemes/$COLOR_NAME.colors"
  fi

  install -d "$home_dir/.config"

  if [ -f "$CONFIG_SRC/plasmarc" ]; then
    cp -a "$CONFIG_SRC/plasmarc" "$home_dir/.config/plasmarc"
  else
    printf '[Theme]\nname=%s\n' "$THEME_NAME" > "$home_dir/.config/plasmarc"
  fi

  if [ -f "$CONFIG_SRC/kdeglobals" ]; then
    cp -a "$CONFIG_SRC/kdeglobals" "$home_dir/.config/kdeglobals"
  else
    printf '[General]\nColorScheme=%s\n' "$COLOR_NAME" > "$home_dir/.config/kdeglobals"
  fi

  for f in plasma-org.kde.plasma.desktop-appletsrc ksplashrc kscreenlockerrc plasma-localerc; do
    if [ -f "$CONFIG_SRC/$f" ]; then
      cp -a "$CONFIG_SRC/$f" "$home_dir/.config/$f"
    fi
  done

  rm -rf "$home_dir/.cache/ksvg-elements" 2>/dev/null || true
  rm -f "$home_dir/.cache/plasma_theme_${THEME_NAME}.kcache" 2>/dev/null || true

  if [ "$mode" = "real-user" ]; then
    uid_gid="$(stat -c '%u:%g' "$home_dir" 2>/dev/null || true)"
    if [ -n "$uid_gid" ]; then
      chown -R "$uid_gid" \
        "$home_dir/.config" \
        "$home_dir/.local/share/plasma" \
        "$home_dir/.local/share/color-schemes" \
        "$home_dir/.cache" 2>/dev/null || true
    fi
  fi
}

log "Aplicando em /etc/skel"
install -d "$TARGET/etc/skel"
apply_to_home "$TARGET/etc/skel" "skel"

log "Aplicando em usuários reais do target"
if [ -d "$TARGET/home" ]; then
  for home_dir in "$TARGET"/home/*; do
    [ -d "$home_dir" ] || continue
    case "$(basename "$home_dir")" in
      lost+found) continue ;;
    esac
    apply_to_home "$home_dir" "real-user"
  done
fi

log "Conferência"
echo "Tema sistema: $TARGET/usr/share/plasma/desktoptheme/$THEME_NAME"
echo "Cores sistema: $TARGET/usr/share/color-schemes/$COLOR_NAME.colors"
echo "Skel plasmarc: $TARGET/etc/skel/.config/plasmarc"

echo
echo "OK — tema completo Mocha aplicado no target, /etc/skel e usuários existentes."
