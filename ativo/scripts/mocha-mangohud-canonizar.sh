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

TARGET_USER="${SUDO_USER:-${USER:-hal}}"
if [ "$TARGET_USER" = root ] && [ -d /home/hal ]; then
  TARGET_USER=hal
fi
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

tmpconf="$(mktemp)"
cat > "$tmpconf" <<'EOF_CONF'
# Mocha MangoHud canonical config
# Aprovado em jogo real em 2026-07-03.
# Regra bloqueante: relogio com minutos visiveis em HH:MM.
# Causa corrigida: fonte/layout cortava minutos quando font_size=22 e table_columns=20.

legacy_layout=false
horizontal
position=top-left
font_size=18
background_alpha=0.35
round_corners=8
toggle_hud=Shift_R+F12

time
time_no_label
time_format="%H:%M"

fps
frametime

cpu_stats
cpu_temp
cpu_mhz

gpu_stats
gpu_temp
gpu_core_clock
gpu_mem_clock

vram
ram
gamemode
EOF_CONF

sudo install -Dm644 "$tmpconf" /usr/local/share/mocha/mangohud/MangoHud.conf
install -Dm644 "$tmpconf" "$TARGET_HOME/.config/MangoHud/MangoHud.conf"
sudo install -Dm644 "$tmpconf" /etc/skel/.config/MangoHud/MangoHud.conf
sudo chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/MangoHud/MangoHud.conf"

tmpwrapper="$(mktemp)"
cat > "$tmpwrapper" <<'EOF_WRAP'
#!/usr/bin/env bash
set -Eeuo pipefail

MOCHA_MH_USER="${HOME}/.config/MangoHud/MangoHud.conf"
MOCHA_MH_SYSTEM="/usr/local/share/mocha/mangohud/MangoHud.conf"

# Fonte unica: arquivo MangoHud.conf. Nao usar MANGOHUD_CONFIG inline.
unset MANGOHUD_CONFIG || true

if [ -f "$MOCHA_MH_USER" ]; then
  export MANGOHUD_CONFIGFILE="$MOCHA_MH_USER"
else
  export MANGOHUD_CONFIGFILE="$MOCHA_MH_SYSTEM"
fi

export MANGOHUD=1
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
export WINE_FULLSCREEN_FSR=0
export MESA_VK_WSI_PRESENT_MODE=mailbox

exec "$@"
EOF_WRAP

sudo install -Dm755 "$tmpwrapper" /usr/local/bin/mocha-steam-game-run
mkdir -p "$TARGET_HOME/.local/bin"
ln -sfn /usr/local/bin/mocha-steam-game-run "$TARGET_HOME/.local/bin/mocha-steam-game-run"
sudo mkdir -p /etc/skel/.local/bin
sudo ln -sfn /usr/local/bin/mocha-steam-game-run /etc/skel/.local/bin/mocha-steam-game-run
sudo chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local/bin/mocha-steam-game-run"

rm -f "$tmpconf" "$tmpwrapper"

echo "[OK] MangoHud Mocha canonizado."
echo "[INFO] Feche e reabra o jogo para o novo ambiente entrar."
