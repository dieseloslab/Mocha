#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

WRAPPER_DIR="$HOME/.local/bin"
WRAPPER="$WRAPPER_DIR/mocha-steam-game-run"

mkdir -p "$WRAPPER_DIR"

cat > "$WRAPPER" <<'MOCHA_WRAPPER_STEAM_LIMPO_REUSABLE_CORRIGIDO'
#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$#" -lt 1 ]; then
  echo "Uso: mocha-steam-game-run %command%" >&2
  exit 64
fi

for mocha_env_var in \
  "MANGOHUD_"'DLSYM' \
  'ENABLE_''VKBASALT' \
  'VK''BASALT_CONFIG_FILE' \
  'GAMESCOPE_''ARGS' \
  'GAMESCOPE_''WSI'
do
  unset "$mocha_env_var" || true
done

export DXVK_LOG_LEVEL="${DXVK_LOG_LEVEL:-none}"

MANGOHUD_CONF_USER="${HOME}/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf"
MANGOHUD_CONF_SYSTEM="/etc/mocha/mangohud/MangoHud.conf"

cmd=( "$@" )

if command -v gamemoderun >/dev/null 2>&1; then
  cmd=( gamemoderun "${cmd[@]}" )
fi

if command -v mangohud >/dev/null 2>&1; then
  export MANGOHUD=1

  if [ -f "$MANGOHUD_CONF_USER" ]; then
    export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_USER"
  elif [ -f "$MANGOHUD_CONF_SYSTEM" ]; then
    export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_SYSTEM"
  fi

  cmd=( mangohud "${cmd[@]}" )
fi

exec "${cmd[@]}"
MOCHA_WRAPPER_STEAM_LIMPO_REUSABLE_CORRIGIDO

chmod 0755 "$WRAPPER"
bash -n "$WRAPPER"

BAD_RAW="$(grep -En 'MANGOHUD_DLSYM|ENABLE_VKBASALT|(^|[^A-Za-z])vkbasalt([^A-Za-z]|$)|(^|[^A-Za-z])gamescope([^A-Za-z]|$)|x11|X11|xorg|Xorg' "$WRAPPER" || true)"
if [ -n "$BAD_RAW" ]; then
  echo "ERRO: wrapper contém termo bruto que não deveria aparecer:" >&2
  echo "$BAD_RAW" >&2
  exit 1
fi

echo "Wrapper Mocha Steam limpo instalado em: $WRAPPER"
