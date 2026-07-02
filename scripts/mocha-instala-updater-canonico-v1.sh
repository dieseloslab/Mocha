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

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
BIN="/usr/local/bin/mocha-updater"
DESKTOP_SYS="/usr/share/applications/mocha-updater.desktop"

[ -d "$APP" ] || fail "App não encontrado em $APP"

echo
echo "============================================================"
echo " Mocha — instalar Mocha Updater canônico"
echo "============================================================"
echo

if [ -f "$APP/Cargo.toml" ]; then
  command -v cargo >/dev/null 2>&1 || fail "cargo não encontrado"
  cd "$APP"
  cargo build --release
  CANDIDATE="$(find "$APP/target/release" -maxdepth 1 -type f -executable -printf '%f\n' | grep -E 'mocha.*updater|updater' | head -n1 || true)"
  [ -n "$CANDIDATE" ] || fail "Não encontrei binário executável em target/release"
  sudo install -Dm755 "$APP/target/release/$CANDIDATE" "$BIN"
  ok "Binário instalado em $BIN"
elif [ -x "$APP/mocha-updater" ]; then
  sudo install -Dm755 "$APP/mocha-updater" "$BIN"
  ok "Binário/script instalado em $BIN"
else
  fail "Não encontrei Cargo.toml nem executável $APP/mocha-updater"
fi

ICON=""
for candidate in \
  "$APP/assets/mocha-updater.png" \
  "$APP/assets/mocha.png" \
  "$PUB/assets/mocha.png" \
  "$PUB/branding/mocha.png" \
  "/usr/share/pixmaps/mocha.png"
do
  if [ -f "$candidate" ]; then
    ICON="$candidate"
    break
  fi
done

[ -n "$ICON" ] || ICON="system-software-update"

TMP_DESKTOP="$(mktemp)"
cat > "$TMP_DESKTOP" <<EOF_DESKTOP
[Desktop Entry]
Type=Application
Name=Mocha Updater
Name[pt_BR]=Atualizador Mocha
Name[pt]=Atualizador Mocha
Name[es]=Actualizador Mocha
Name[fr]=Mise à jour Mocha
Comment=Update Mocha system, Flatpaks, kernels and video drivers
Comment[pt_BR]=Atualiza o sistema Mocha, Flatpaks, kernels e drivers de vídeo
Comment[pt]=Atualiza o sistema Mocha, Flatpaks, kernels e drivers de vídeo
Comment[es]=Actualiza el sistema Mocha, Flatpaks, kernels y controladores de video
Comment[fr]=Met à jour le système Mocha, les Flatpaks, les noyaux et les pilotes vidéo
Exec=$BIN
Icon=$ICON
Terminal=false
Categories=System;Settings;
StartupNotify=true
EOF_DESKTOP

sudo install -Dm644 "$TMP_DESKTOP" "$DESKTOP_SYS"
rm -f "$TMP_DESKTOP"
ok "Atalho canônico instalado no menu Sistema: $DESKTOP_SYS"

sudo find /usr/share/applications -maxdepth 1 -type f \
  \( -iname '*mocha*updat*.desktop' -o -iname '*mocha*atualiz*.desktop' -o -iname '*updater*mocha*.desktop' \) \
  ! -name 'mocha-updater.desktop' \
  -print -delete || true

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
DESKTOP_DIR="$REAL_HOME/Desktop"

if [ -d "$DESKTOP_DIR" ]; then
  find "$DESKTOP_DIR" -maxdepth 1 -type f \
    \( -iname '*mocha*updat*.desktop' -o -iname '*mocha*atualiz*.desktop' -o -iname '*updater*mocha*.desktop' \) \
    ! -name 'mocha-updater.desktop' \
    -print -delete || true

  install -Dm644 "$DESKTOP_SYS" "$DESKTOP_DIR/mocha-updater.desktop"
  chmod +x "$DESKTOP_DIR/mocha-updater.desktop"
  chown "$REAL_USER:$REAL_USER" "$DESKTOP_DIR/mocha-updater.desktop"
  ok "Atalho canônico instalado na área de trabalho: $DESKTOP_DIR/mocha-updater.desktop"
else
  warn "Área de trabalho não encontrada para $REAL_USER: $DESKTOP_DIR"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  sudo update-desktop-database /usr/share/applications || true
fi

echo
ok "Instalação canônica do Mocha Updater concluída"
