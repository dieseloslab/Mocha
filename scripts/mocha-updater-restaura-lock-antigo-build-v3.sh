#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
VM_AUD="/media/vmstore/MochaArch/auditorias"
OUT="${1:-$VM_AUD/mocha-updater-restaura-lock-antigo-build-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

[ -d "$APP" ] || fail "App ausente: $APP"
mkdir -p "$OUT"

echo "============================================================"
echo " Mocha Updater — restaurar Cargo.lock antigo e build"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup do estado atual quebrado..."
cp -a "$APP/Cargo.toml" "$OUT/Cargo.toml.broken-current" 2>/dev/null || true
cp -a "$APP/Cargo.lock" "$OUT/Cargo.lock.broken-current" 2>/dev/null || true
cp -a "$APP/src/main.rs" "$OUT/main.rs.current" 2>/dev/null || true

echo
echo "2) Procurando Cargo.lock anterior que não tenha linux-raw-sys 0.12.1..."
LOCK_CANDIDATE=""

while IFS= read -r f; do
  if [ -s "$f" ] && ! grep -q 'name = "linux-raw-sys"' "$f"; then
    LOCK_CANDIDATE="$f"
    break
  fi

  if [ -s "$f" ] && ! grep -A2 'name = "linux-raw-sys"' "$f" | grep -q 'version = "0.12.1"'; then
    LOCK_CANDIDATE="$f"
    break
  fi
done < <(
  find "$VM_AUD" -type f -name 'Cargo.lock.before' -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | awk '{ $1=""; sub(/^ /,""); print }'
)

if [ -z "$LOCK_CANDIDATE" ]; then
  fail "Nenhum Cargo.lock.before aproveitável encontrado em $VM_AUD"
fi

echo "Cargo.lock escolhido:"
echo "$LOCK_CANDIDATE"
cp -a "$LOCK_CANDIDATE" "$OUT/Cargo.lock.restored-from"
cp -a "$LOCK_CANDIDATE" "$APP/Cargo.lock"
ok "Cargo.lock antigo restaurado"

echo
echo "3) Ajustando Cargo.toml para não forçar lock novo..."
cat > "$APP/Cargo.toml" <<'CARGO'
[package]
name = "mocha-updater"
version = "0.1.0"
edition = "2021"

[dependencies]
eframe = "0.31"
egui = "0.31"
CARGO

ok "Cargo.toml voltou para versão 0.1.0 compatível com lock anterior"

echo
echo "4) Verificando lock restaurado..."
grep -A3 'name = "mocha-updater"' "$APP/Cargo.lock" || true
echo
grep -A2 'name = "linux-raw-sys"' "$APP/Cargo.lock" || true

echo
echo "5) Instalando helper atual já corrigido..."
[ -f "$APP/scripts/mocha-updater-action-v1.sh" ] || fail "Helper fonte ausente: $APP/scripts/mocha-updater-action-v1.sh"
sudo mkdir -p /usr/local/lib/mocha/mocha-updater
sudo install -m 755 "$APP/scripts/mocha-updater-action-v1.sh" /usr/local/lib/mocha/mocha-updater/mocha-updater-action
ok "Helper instalado"

echo
echo "6) Build com lock antigo, offline, sem paralelismo..."
cd "$APP"

export CARGO_NET_OFFLINE=true
export CARGO_BUILD_JOBS=1
export CARGO_INCREMENTAL=0
export RUST_BACKTRACE=1

cargo build --release --locked -j 1

echo
echo "7) Instalando binário novo..."
[ -x "$APP/target/release/mocha-updater" ] || fail "Binário release não foi gerado"
sudo install -m 755 "$APP/target/release/mocha-updater" /usr/local/bin/mocha-updater
ok "Binário instalado: /usr/local/bin/mocha-updater"

echo
echo "8) Reinstalando ícone e atalhos..."
if [ -f "$APP/assets/mocha-updater.svg" ]; then
  sudo mkdir -p /usr/share/icons/hicolor/scalable/apps
  sudo install -m 644 "$APP/assets/mocha-updater.svg" /usr/share/icons/hicolor/scalable/apps/mocha-updater.svg
  timeout 10 sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi

write_desktop() {
  local dst="$1"
  sudo mkdir -p "$(dirname "$dst")"
  sudo tee "$dst" >/dev/null <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Mocha Updater
Name[pt_BR]=Mocha Updater
Name[pt]=Mocha Updater
Name[fr]=Mocha Updater
Name[es]=Mocha Updater
Comment=Real Mocha system, Flatpak, kernel and driver updater
Comment[pt_BR]=Atualizador real de sistema, Flatpak, kernel e driver do Mocha
Comment[pt]=Atualizador real de sistema, Flatpak, kernel e driver do Mocha
Comment[fr]=Outil réel de mise à jour système, Flatpak, noyau et pilote pour Mocha
Comment[es]=Actualizador real de sistema, Flatpak, kernel y controlador para Mocha
Exec=/usr/local/bin/mocha-updater
Icon=mocha-updater
Terminal=false
Categories=System;Settings;
StartupNotify=true
DESKTOP
  sudo chmod 755 "$dst"
}

write_desktop /usr/share/applications/mocha-updater.desktop
write_desktop /etc/skel/Desktop/mocha-updater.desktop
write_desktop "/etc/skel/Área de Trabalho/mocha-updater.desktop"

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  USER_ID="$(id -u "$SUDO_USER")"
  USER_GID="$(id -g "$SUDO_USER")"
else
  USER_HOME="$HOME"
  USER_ID="$(id -u)"
  USER_GID="$(id -g)"
fi

if [ -d "$USER_HOME/Desktop" ]; then
  write_desktop "$USER_HOME/Desktop/mocha-updater.desktop"
  sudo chown "$USER_ID:$USER_GID" "$USER_HOME/Desktop/mocha-updater.desktop"
fi

if [ -d "$USER_HOME/Área de Trabalho" ]; then
  write_desktop "$USER_HOME/Área de Trabalho/mocha-updater.desktop"
  sudo chown "$USER_ID:$USER_GID" "$USER_HOME/Área de Trabalho/mocha-updater.desktop"
fi

echo
echo "9) Validação sem alterar sistema..."
/usr/local/lib/mocha/mocha-updater/mocha-updater-action system-check | tee "$OUT/system-check.txt"

echo
echo "10) Estado final:"
echo
echo "Binário:"
ls -lh /usr/local/bin/mocha-updater
echo
echo "Helper:"
ls -lh /usr/local/lib/mocha/mocha-updater/mocha-updater-action
echo
echo "Atalhos:"
find /usr/share/applications /etc/skel/Desktop "/etc/skel/Área de Trabalho" "$USER_HOME/Desktop" "$USER_HOME/Área de Trabalho" \
  -maxdepth 1 -type f -name 'mocha-updater.desktop' \
  -printf '%m %u:%g %p\n' 2>/dev/null | sort || true
echo
echo "Git status:"
git -C "$PUB" status --short || true

ok "Build com lock antigo concluído"
