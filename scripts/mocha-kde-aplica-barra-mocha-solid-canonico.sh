#!/usr/bin/env bash
set -u

TARGET_USER="${1:-hal}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_UID="$(id -u "$TARGET_USER")"
THEME_NAME="MochaPanelSolidCanonico"
COLOR_NAME="MochaSolidCanonico"

as_user() {
  sudo -u "$TARGET_USER" env \
    HOME="$TARGET_HOME" \
    USER="$TARGET_USER" \
    LOGNAME="$TARGET_USER" \
    XDG_RUNTIME_DIR="/run/user/${TARGET_UID}" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${TARGET_UID}/bus" \
    DISPLAY="${DISPLAY:-:0}" \
    WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}" \
    "$@"
}

as_user kwriteconfig6 --file kdeglobals --group General --key ColorScheme "$COLOR_NAME" || true
as_user kwriteconfig6 --file plasmarc --group Theme --key name "$THEME_NAME" || true

command -v plasma-apply-colorscheme >/dev/null 2>&1 && as_user plasma-apply-colorscheme "$COLOR_NAME" || true
command -v plasma-apply-desktoptheme >/dev/null 2>&1 && as_user plasma-apply-desktoptheme "$THEME_NAME" || true

as_user rm -f \
  "$TARGET_HOME"/.cache/plasma_theme_*.kcache \
  "$TARGET_HOME"/.cache/plasma-svgelements-* \
  "$TARGET_HOME"/.cache/plasmashell/qmlcache/* 2>/dev/null || true

as_user kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
as_user kquitapp6 plasmashell >/dev/null 2>&1 || true
sleep 2
as_user nohup plasmashell --replace >/tmp/mocha-plasmashell-replace.log 2>&1 &
