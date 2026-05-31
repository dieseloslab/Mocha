#!/usr/bin/env bash
set -Eeuo pipefail

WRAPPER="$HOME/.local/bin/mocha-steam-game-run"
mkdir -p "$HOME/.local/bin"

cat > "$WRAPPER" <<'EOS'
#!/usr/bin/env bash
set -Eeuo pipefail

MANGOHUD_CONF_USER="${HOME}/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf"
MANGOHUD_CONF_SYSTEM="/etc/mocha/mangohud/MangoHud.conf"

export DXVK_LOG_LEVEL="${DXVK_LOG_LEVEL:-none}"
export MANGOHUD=1

if [ -f "$MANGOHUD_CONF_USER" ]; then
  export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_USER"
elif [ -f "$MANGOHUD_CONF_SYSTEM" ]; then
  export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_SYSTEM"
fi

if command -v gamemoderun >/dev/null 2>&1; then
  exec gamemoderun "$@"
fi

exec "$@"
EOS

chmod 0755 "$WRAPPER"

if grep -Eiq 'MANGOHUD_DLSYM|vkbasalt|gamescope' "$WRAPPER"; then
  echo "ERRO: wrapper contem string proibida."
  exit 1
fi

echo "Wrapper Steam Mocha limpo aplicado: $WRAPPER"
