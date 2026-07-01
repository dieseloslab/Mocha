#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

ROOT="/media/mochafast/MochaArch"
BIN="/usr/local/bin/mocha-updater"
SYSTEM_DESKTOP="/usr/share/applications/mocha-updater.desktop"
APP_DIR="$ROOT/apps/mocha-updater"
ICON="/usr/local/share/icons/hicolor/scalable/apps/mocha-updater.svg"

[ -x "$BIN" ] || { echo "[ERRO] Não achei executável: $BIN" >&2; exit 1; }

DESKTOP_DIR=""
if command -v xdg-user-dir >/dev/null 2>&1; then
  DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
fi
[ -n "$DESKTOP_DIR" ] || DESKTOP_DIR="$HOME/Desktop"
mkdir -p "$DESKTOP_DIR"

DESKTOP_LINK="$DESKTOP_DIR/Mocha Updater.desktop"

cat > /tmp/mocha-updater.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Version=1.0
Name=Mocha Updater
Name[pt_BR]=Mocha Updater
Name[pt_PT]=Mocha Updater
Name[fr]=Mocha Updater
Name[es]=Mocha Updater
GenericName=System Updater
GenericName[pt_BR]=Atualizador do Sistema
GenericName[pt_PT]=Atualizador do Sistema
GenericName[fr]=Gestionnaire de mises à jour système
GenericName[es]=Actualizador del sistema
Comment=Smart system, kernel and driver updater for Mocha
Comment[pt_BR]=Atualizador inteligente de sistema, kernel e driver do Mocha
Comment[pt_PT]=Atualizador inteligente de sistema, kernel e driver do Mocha
Comment[fr]=Gestionnaire intelligent de mises à jour système, noyau et pilote pour Mocha
Comment[es]=Actualizador inteligente de sistema, kernel y controlador para Mocha
Exec=/usr/local/bin/mocha-updater
Icon=mocha-updater
Terminal=false
Categories=System;Settings;X-KDE-System;
Keywords=Mocha;Update;Updater;System;Kernel;Driver;Pacman;Flatpak;
Keywords[pt_BR]=Mocha;Atualização;Atualizador;Sistema;Kernel;Driver;Pacman;Flatpak;
StartupNotify=true
DESKTOP

sudo install -Dm644 /tmp/mocha-updater.desktop "$SYSTEM_DESKTOP"
install -m 755 /tmp/mocha-updater.desktop "$DESKTOP_LINK"

if [ -f "$APP_DIR/assets/mocha-updater.svg" ]; then
  sudo install -Dm644 "$APP_DIR/assets/mocha-updater.svg" "$ICON"
fi

if command -v gio >/dev/null 2>&1; then
  gio set "$DESKTOP_LINK" metadata::trusted true >/dev/null 2>&1 || true
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 >/dev/null 2>&1 || true
fi

echo "[OK] Mocha Updater garantido no menu Sistema e na área de trabalho"
echo "[OK] Menu: $SYSTEM_DESKTOP"
echo "[OK] Desktop: $DESKTOP_LINK"
