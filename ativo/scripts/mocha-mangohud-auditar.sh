#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v
SUDO_KEEPALIVE_PID=""
(
  while true; do
    sudo -n true || exit
    sleep 30
  done
) &
SUDO_KEEPALIVE_PID="$!"

cleanup() {
  set +e
  [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "===== MOCHA MANGOHUD AUDITORIA ====="
date '+%F %T %z'
echo

echo "===== CONFIGS ATIVAS ====="
for f in \
  /usr/local/share/mocha/mangohud/MangoHud.conf \
  "$HOME/.config/MangoHud/MangoHud.conf" \
  /etc/skel/.config/MangoHud/MangoHud.conf
do
  echo "--- $f ---"
  if [ -f "$f" ]; then
    ls -l "$f"
    sha256sum "$f"
    grep -nE '^(font_size|table_columns|time|time_no_label|time_format|fps|frametime|cpu_|gpu_|vram|ram|gamemode)' "$f" || true
  else
    echo "AUSENTE"
  fi
  echo
done

echo "===== WRAPPER ====="
for f in /usr/local/bin/mocha-steam-game-run "$HOME/.local/bin/mocha-steam-game-run" /etc/skel/.local/bin/mocha-steam-game-run; do
  echo "--- $f ---"
  if [ -e "$f" ] || [ -L "$f" ]; then
    ls -l "$f"
    grep -nE 'MANGOHUD_CONFIG|MANGOHUD_CONFIGFILE|MANGOHUD=|exec ' "$f" 2>/dev/null || true
  else
    echo "AUSENTE"
  fi
  echo
done

echo "===== PROCESSOS COM MANGOHUD ====="
for envfile in /proc/[0-9]*/environ; do
  pid="${envfile#/proc/}"
  pid="${pid%/environ}"
  [ -r "$envfile" ] || continue
  envtxt="$(sudo tr '\0' '\n' < "$envfile" 2>/dev/null || true)"
  printf '%s\n' "$envtxt" | grep -q '^MANGOHUD=1' || continue
  cmd="$(sudo tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | sed 's/[[:space:]]*$//')"
  echo "--- PID $pid ---"
  echo "$cmd"
  printf '%s\n' "$envtxt" | grep -E '^(SteamAppId|SteamGameId|MANGOHUD|MANGOHUD_CONFIG|MANGOHUD_CONFIGFILE)=' || true
done

echo
echo "===== RESULTADO ESPERADO ====="
echo "OK: MANGOHUD=1"
echo "OK: MANGOHUD_CONFIGFILE=/home/hal/.config/MangoHud/MangoHud.conf ou equivalente do usuario"
echo "OK: sem MANGOHUD_CONFIG inline"
echo "OK: font_size=18"
echo "OK: sem table_columns"
echo "OK: time_format=\"%H:%M\""
