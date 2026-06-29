#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ROOT="${1:-${CALAMARES_ROOT:-/}}"
[ -d "$ROOT" ] || ROOT="/"
ROOT="$(cd "$ROOT" && pwd -P)"

p() {
  printf "%s/%s" "$ROOT" "${1#/}"
}

log() {
  printf "[mocha-finalizer] %s\n" "$*"
}

read_regular_users() {
  awk -F: '($3 >= 1000 && $3 < 60000 && $1 != "nobody") { print $1 ":" $3 ":" $6 }' "$(p /etc/passwd)" 2>/dev/null || true
}

copy_one_if_present() {
  src="$1"
  dst="$2"

  [ -e "$src" ] || return 0
  mkdir -p "$(dirname "$dst")"

  if command -v rsync >/dev/null 2>&1; then
    if [ -d "$src" ]; then
      mkdir -p "$dst"
      rsync -a --delete "$src"/ "$dst"/
    else
      rsync -a "$src" "$dst"
    fi
  else
    rm -rf "$dst"
    cp -a "$src" "$dst"
  fi
}

copy_mocha_profile_to_user() {
  user="$1"
  home="$2"

  [ -n "$user" ] || return 0
  [ -n "$home" ] || return 0
  [ "$home" != "/" ] || return 0

  target_home="$(p "$home")"
  mkdir -p "$target_home"

  for source_home in \
    "$(p /etc/skel)" \
    "$(p /etc/mocha/skel)" \
    "$(p /usr/share/mocha/skel)" \
    "$(p /home/mocha)"
  do
    [ -d "$source_home" ] || continue

    for rel in \
      ".config/kdeglobals" \
      ".config/kwinrc" \
      ".config/ksmserverrc" \
      ".config/kscreenlockerrc" \
      ".config/kaccessrc" \
      ".config/kcminitrc" \
      ".config/plasmarc" \
      ".config/plasma-org.kde.plasma.desktop-appletsrc" \
      ".config/plasma-localerc" \
      ".config/plasma-welcomerc" \
      ".config/gtk-3.0" \
      ".config/gtk-4.0" \
      ".config/Kvantum" \
      ".config/mimeapps.list" \
      ".local/share/color-schemes" \
      ".local/share/icons" \
      ".local/share/plasma" \
      ".local/share/wallpapers" \
      ".local/share/konsole" \
      ".themes" \
      ".icons" \
      ".gtkrc-2.0" \
      ".face" \
      ".face.icon"
    do
      [ -e "$source_home/$rel" ] || continue
      copy_one_if_present "$source_home/$rel" "$target_home/$rel"
    done
  done

  if getent passwd "$user" >/dev/null 2>&1 && [ "$ROOT" = "/" ]; then
    group="$(id -gn "$user" 2>/dev/null || printf "%s" "$user")"
    chown -R "$user:$group" "$target_home" || true
  else
    uid_gid="$(awk -F: -v u="$user" '$1 == u { print $3 ":" $4 }' "$(p /etc/passwd)" 2>/dev/null | head -n1)"
    [ -n "$uid_gid" ] && chown -R "$uid_gid" "$target_home" || true
  fi

  chmod -R u+rwX "$target_home/.config" "$target_home/.local" 2>/dev/null || true
}

log "Aplicando tema/permissões Mocha aos usuários reais"
read_regular_users | while IFS=: read -r user uid home; do
  [ -n "$user" ] || continue
  [ "$user" = "mocha" ] && continue
  [ "$user" = "live" ] && continue
  [ "$user" = "arch" ] && continue
  copy_mocha_profile_to_user "$user" "$home"
done

log "Removendo autologin residual do usuário live"
if [ -d "$(p /etc/sddm.conf.d)" ]; then
  find "$(p /etc/sddm.conf.d)" -type f -name "*.conf" -print0 2>/dev/null | while IFS= read -r -d "" f; do
    sed -i \
      -e '/^[[:space:]]*User[[:space:]]*=[[:space:]]*mocha[[:space:]]*$/d' \
      -e '/^[[:space:]]*Session[[:space:]]*=[[:space:]]*plasma[[:alnum:]._-]*[[:space:]]*$/d' \
      -e '/^[[:space:]]*Relogin[[:space:]]*=/d' \
      "$f" || true
  done
fi

if [ -f "$(p /etc/sddm.conf)" ]; then
  sed -i \
    -e '/^[[:space:]]*User[[:space:]]*=[[:space:]]*mocha[[:space:]]*$/d' \
    -e '/^[[:space:]]*Session[[:space:]]*=[[:space:]]*plasma[[:alnum:]._-]*[[:space:]]*$/d' \
    -e '/^[[:space:]]*Relogin[[:space:]]*=/d' \
    "$(p /etc/sddm.conf)" || true
fi

log "Forçando NetworkManager DHCP no sistema instalado"
if [ -d "$(p /etc/NetworkManager/system-connections)" ]; then
  find "$(p /etc/NetworkManager/system-connections)" -type f -name "*.nmconnection" -print0 2>/dev/null | while IFS= read -r -d "" f; do
    sed -i \
      -e 's/^[[:space:]]*method=manual[[:space:]]*$/method=auto/' \
      -e '/^[[:space:]]*addresses[[:space:]]*=/d' \
      -e '/^[[:space:]]*gateway[[:space:]]*=/d' \
      -e '/^[[:space:]]*dns[[:space:]]*=/d' \
      -e '/^[[:space:]]*dns-search[[:space:]]*=/d' \
      "$f" || true
    chmod 600 "$f" || true
  done
fi

log "Removendo usuário live mocha somente se houver outro usuário real instalado"
if awk -F: '($3 >= 1000 && $3 < 60000 && $1 != "nobody" && $1 != "mocha") { found=1 } END { exit found ? 0 : 1 }' "$(p /etc/passwd)" 2>/dev/null; then
  if awk -F: '$1 == "mocha" { found=1 } END { exit found ? 0 : 1 }' "$(p /etc/passwd)" 2>/dev/null; then
    if [ "$ROOT" = "/" ] && command -v userdel >/dev/null 2>&1; then
      userdel -r mocha >/dev/null 2>&1 || true
      groupdel mocha >/dev/null 2>&1 || true
    else
      for db in /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/subuid /etc/subgid; do
        [ -f "$(p "$db")" ] || continue
        sed -i '/^mocha:/d' "$(p "$db")" || true
      done
      rm -rf "$(p /home/mocha)" 2>/dev/null || true
    fi
  fi
fi

log "Habilitando serviços essenciais quando systemctl estiver disponível"
if command -v systemctl >/dev/null 2>&1; then
  if [ "$ROOT" = "/" ]; then
    systemctl enable NetworkManager.service >/dev/null 2>&1 || true
    systemctl enable sddm.service >/dev/null 2>&1 || true
  else
    systemctl --root="$ROOT" enable NetworkManager.service >/dev/null 2>&1 || true
    systemctl --root="$ROOT" enable sddm.service >/dev/null 2>&1 || true
  fi
fi

log "Finalizador Mocha concluído"
exit 0
