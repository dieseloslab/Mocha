#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
      break
    fi
  done

  if [ -n "$src" ]; then
    cp -a "$src" "$target"
  else
    cat > "$target" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
EOINNER
  fi

  if grep -q '^Hidden=' "$target"; then
    sed -i 's/^Hidden=.*/Hidden=true/' "$target"
  else
    printf '\nHidden=true\n' >> "$target"
  fi
}

write_hidden_desktop_skel() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local skel_dir="/etc/skel/.config/autostart"
  local target="$skel_dir/$name"
  local tmp

  $SUDO mkdir -p "$skel_dir"
  tmp="$(mktemp)"

  cat > "$tmp" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
Hidden=true
EOINNER

  $SUDO install -m 0644 "$tmp" "$target"
  rm -f "$tmp"
}

apply_hidden_desktop_user \
  "blueman.desktop" \
  "blueman-applet" \
  "Mocha KDE: disabled because KDE/Bluedevil already provides Bluetooth in the system tray"

apply_hidden_desktop_user \
  "kmix_autostart.desktop" \
  "kmix --keepvisibility" \
  "Mocha KDE: disabled because Plasma volume applet already provides volume control in the system tray"

write_hidden_desktop_skel \
  "blueman.desktop" \
  "blueman-applet" \
  "Mocha KDE: disabled because KDE/Bluedevil already provides Bluetooth in the system tray"

write_hidden_desktop_skel \
  "kmix_autostart.desktop" \
  "kmix --keepvisibility" \
  "Mocha KDE: disabled because Plasma volume applet already provides volume control in the system tray"

systemctl --user stop app-blueman@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix_autostart@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x blueman-applet 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "Mocha KDE: autostarts redundantes de Blueman e KMix desativados."
echo "Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume."
