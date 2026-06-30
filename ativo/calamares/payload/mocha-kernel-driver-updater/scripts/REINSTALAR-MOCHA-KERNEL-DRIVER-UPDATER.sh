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
info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BACKEND_SRC="$DIR/src/mocha-kernel-driver-updater"
GUI_SRC="$DIR/src/mocha-kernel-driver-updater-gui"

BACKEND_BIN_BACKUP="$DIR/bin/mocha-kernel-driver-updater"
GUI_BIN_BACKUP="$DIR/bin/mocha-kernel-driver-updater-gui"
DESKTOP_BACKUP="$DIR/desktop/mocha-kernel-driver-updater.desktop"

BACKEND_BIN="/usr/local/sbin/mocha-kernel-driver-updater"
GUI_BIN="/usr/local/bin/mocha-kernel-driver-updater-gui"
DESKTOP_FILE="/usr/share/applications/mocha-kernel-driver-updater.desktop"

TS="$(date +%Y%m%d-%H%M%S)"
LOG="/tmp/mocha-reinstalar-kernel-driver-updater-$TS.log"

exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo " Mocha — reinstalar atualizador kernel/driver"
echo "============================================================"
echo "Origem: $DIR"
echo "Log:    $LOG"
echo

info "Instalando dependências mínimas..."
sudo pacman -S --needed --noconfirm rust cargo base-devel pkgconf git kdialog konsole polkit

if [ -d "$BACKEND_SRC" ] && [ -f "$BACKEND_SRC/Cargo.toml" ]; then
  info "Compilando backend Rust..."
  cd "$BACKEND_SRC"
  cargo build --release
  sudo install -Dm755 "$BACKEND_SRC/target/release/mocha-kernel-driver-updater" "$BACKEND_BIN"
  ok "Backend instalado em $BACKEND_BIN"
elif [ -x "$BACKEND_BIN_BACKUP" ]; then
  warn "Fonte do backend ausente. Restaurando binário salvo."
  sudo install -Dm755 "$BACKEND_BIN_BACKUP" "$BACKEND_BIN"
  ok "Backend restaurado por binário."
else
  fail "Não há fonte nem binário salvo do backend."
fi

if [ -d "$GUI_SRC" ] && [ -f "$GUI_SRC/Cargo.toml" ]; then
  info "Compilando GUI Rust..."
  cd "$GUI_SRC"
  cargo build --release
  sudo install -Dm755 "$GUI_SRC/target/release/mocha-kernel-driver-updater-gui" "$GUI_BIN"
  ok "GUI instalada em $GUI_BIN"
elif [ -x "$GUI_BIN_BACKUP" ]; then
  warn "Fonte da GUI ausente. Restaurando binário salvo."
  sudo install -Dm755 "$GUI_BIN_BACKUP" "$GUI_BIN"
  ok "GUI restaurada por binário."
else
  fail "Não há fonte nem binário salvo da GUI."
fi

if [ -f "$DESKTOP_BACKUP" ]; then
  info "Instalando atalho do sistema..."
  sudo install -Dm644 "$DESKTOP_BACKUP" "$DESKTOP_FILE"

  info "Instalando atalho em /etc/skel..."
  sudo install -Dm755 "$DESKTOP_BACKUP" "/etc/skel/Desktop/Atualizador Mocha Kernel e Driver.desktop" 2>/dev/null || true
  sudo install -Dm755 "$DESKTOP_BACKUP" "/etc/skel/Área de Trabalho/Atualizador Mocha Kernel e Driver.desktop" 2>/dev/null || true

  info "Instalando atalho para usuários existentes..."
  for HOME_DIR in /home/*; do
    [ -d "$HOME_DIR" ] || continue
    USER_NAME="$(basename "$HOME_DIR")"

    for DESK in "$HOME_DIR/Desktop" "$HOME_DIR/Área de Trabalho"; do
      if [ -d "$DESK" ]; then
        sudo install -m 0755 "$DESKTOP_BACKUP" "$DESK/Atualizador Mocha Kernel e Driver.desktop"
        sudo chown "$USER_NAME:$USER_NAME" "$DESK/Atualizador Mocha Kernel e Driver.desktop" 2>/dev/null || true
      fi
    done
  done

  sudo update-desktop-database /usr/share/applications 2>/dev/null || true
  ok "Atalho instalado."
else
  warn "Desktop salvo não encontrado. O binário foi instalado, mas sem atalho gráfico."
fi

echo
echo "============================================================"
echo " Verificação"
echo "============================================================"

command -v mocha-kernel-driver-updater-gui || true
ls -l "$BACKEND_BIN" "$GUI_BIN" 2>/dev/null || true
ls -l "$DESKTOP_FILE" 2>/dev/null || true

echo
ok "Reinstalação concluída."
echo
echo "Abrir GUI:"
echo "  /usr/local/bin/mocha-kernel-driver-updater-gui"
