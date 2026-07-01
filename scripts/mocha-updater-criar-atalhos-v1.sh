#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

ROOT="/media/mochafast/MochaArch"
BIN="$ROOT/tools/mocha-updater-rs/target/release/mocha-updater"
APP_SYSTEM="/usr/share/applications/mocha-updater.desktop"

[ -x "$BIN" ] || {
  echo "[ERRO] Binário não encontrado ou não executável: $BIN" >&2
  exit 1
}

DESKTOP_FILE_CONTENT='[Desktop Entry]
Type=Application
Name=Mocha Updater
GenericName=Atualizador Mocha
Comment=Inventário seguro do sistema, kernel e driver; modo dry-run
Exec=konsole --hold -e bash -lc '\''/media/mochafast/MochaArch/tools/mocha-updater-rs/target/release/mocha-updater inventario; echo; read -rp "Pressione Enter para fechar..." _'\''
Icon=system-software-update
Terminal=false
Categories=System;Settings;
StartupNotify=true
Keywords=mocha;update;kernel;driver;nvidia;cachyos;zen;inventario;
'

printf '%s\n' "$DESKTOP_FILE_CONTENT" | sudo tee "$APP_SYSTEM" >/dev/null
sudo chmod 0644 "$APP_SYSTEM"

if command -v update-desktop-database >/dev/null 2>&1; then
  sudo update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

if [ -z "$REAL_HOME" ] || [ ! -d "$REAL_HOME" ]; then
  echo "[WARN] Não consegui detectar HOME do usuário real; menu foi criado, área de trabalho não."
  exit 0
fi

DESKTOP_DIR=""
if command -v xdg-user-dir >/dev/null 2>&1; then
  DESKTOP_DIR="$(sudo -u "$REAL_USER" XDG_CONFIG_HOME="$REAL_HOME/.config" HOME="$REAL_HOME" xdg-user-dir DESKTOP 2>/dev/null || true)"
fi

if [ -z "$DESKTOP_DIR" ] || [ "$DESKTOP_DIR" = "$REAL_HOME" ]; then
  if [ -d "$REAL_HOME/Área de Trabalho" ]; then
    DESKTOP_DIR="$REAL_HOME/Área de Trabalho"
  else
    DESKTOP_DIR="$REAL_HOME/Desktop"
  fi
fi

mkdir -p "$DESKTOP_DIR"
install -m 0755 "$APP_SYSTEM" "$DESKTOP_DIR/mocha-updater.desktop"
chown "$REAL_USER:$REAL_USER" "$DESKTOP_DIR/mocha-updater.desktop"

echo "[OK] Entrada criada no menu: $APP_SYSTEM"
echo "[OK] Atalho criado na área de trabalho: $DESKTOP_DIR/mocha-updater.desktop"
