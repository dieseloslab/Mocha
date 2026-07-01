#!/usr/bin/env bash
set +e
export LC_ALL=C

LOG="/tmp/mocha-gamemode-oc-end.log"
exec >>"$LOG" 2>&1

echo
echo "============================================================"
echo "Mocha GameMode OC END — $(date -Is)"
echo "============================================================"

export DISPLAY="${DISPLAY:-:0}"

if [ -z "${XAUTHORITY:-}" ]; then
  UID_ATUAL="$(id -u)"
  for cand in "$HOME/.Xauthority" "/run/user/$UID_ATUAL/Xauthority" /run/user/"$UID_ATUAL"/xauth_*; do
    if [ -e "$cand" ]; then
      export XAUTHORITY="$cand"
      break
    fi
  done
fi

echo "USER=$(id -un) UID=$(id -u)"
echo "DISPLAY=${DISPLAY:-}"
echo "XAUTHORITY=${XAUTHORITY:-}"
echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-}"
echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-}"

sudo -n --preserve-env=DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR,DBUS_SESSION_BUS_ADDRESS,WAYLAND_DISPLAY,MOCHA_NVIDIA_CORE_OFFSET,MOCHA_NVIDIA_MEM_OFFSET /usr/local/lib/mocha/gamemode-nvidia-oc-root-helper.sh end

exit 0
