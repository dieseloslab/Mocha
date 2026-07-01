#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

APP_DIR="/media/mochafast/MochaArch/apps/mocha-updater"
SRC="$APP_DIR/src/main.rs"
BIN_PATH="/usr/local/bin/mocha-updater"
DESKTOP_SYSTEM="/usr/share/applications/mocha-updater.desktop"
ICON_DIR="/usr/local/share/icons/hicolor/scalable/apps"
APP_ICON="$ICON_DIR/mocha-updater.svg"

[ -f "$SRC" ] || { echo "[ERRO] Não achei $SRC" >&2; exit 1; }

python - <<'PY'
from pathlib import Path
src = Path("/media/mochafast/MochaArch/apps/mocha-updater/src/main.rs")
text = src.read_text()
text = text.replace("fn t(self, key: &str) -> &'static str {", "fn t(self, key: &'static str) -> &'static str {")
text = text.replace("use std::path::Path;\n", "")
src.write_text(text)
PY

cd "$APP_DIR"
cargo fmt || true
cargo build --release
sudo install -Dm755 "$APP_DIR/target/release/mocha-updater" "$BIN_PATH"

if [ -f "$APP_DIR/assets/mocha-updater.svg" ]; then
  sudo install -Dm644 "$APP_DIR/assets/mocha-updater.svg" "$APP_ICON"
fi

cat > /tmp/mocha-updater.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Version=1.0
Name=Mocha Updater
Name[pt_BR]=Mocha Updater
Name[pt_PT]=Mocha Updater
Name[fr]=Mocha Updater
Name[es]=Mocha Updater
Comment=Smart system, kernel and driver updater for Mocha
Comment[pt_BR]=Atualizador inteligente de sistema, kernel e driver do Mocha
Comment[pt_PT]=Atualizador inteligente de sistema, kernel e driver do Mocha
Comment[fr]=Gestionnaire intelligent de mises à jour système, noyau et pilote pour Mocha
Comment[es]=Actualizador inteligente de sistema, kernel y controlador para Mocha
Exec=/usr/local/bin/mocha-updater
Icon=mocha-updater
Terminal=false
Categories=System;Settings;
StartupNotify=true
DESKTOP

sudo install -Dm644 /tmp/mocha-updater.desktop "$DESKTOP_SYSTEM"

DESKTOP_DIR=""
if command -v xdg-user-dir >/dev/null 2>&1; then
  DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
fi
[ -n "$DESKTOP_DIR" ] || DESKTOP_DIR="$HOME/Desktop"
mkdir -p "$DESKTOP_DIR"
install -m 755 /tmp/mocha-updater.desktop "$DESKTOP_DIR/Mocha Updater.desktop"

if command -v gio >/dev/null 2>&1; then
  gio set "$DESKTOP_DIR/Mocha Updater.desktop" metadata::trusted true >/dev/null 2>&1 || true
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 >/dev/null 2>&1 || true
fi

echo "[OK] Mocha Updater corrigido e instalado"
