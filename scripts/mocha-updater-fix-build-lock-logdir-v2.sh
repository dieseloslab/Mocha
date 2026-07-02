#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
OUT="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-fix-build-lock-logdir-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

[ -d "$APP" ] || fail "App ausente: $APP"
mkdir -p "$OUT" "$APP/scripts"

echo "============================================================"
echo " Mocha Updater — fix build/Cargo.lock/logdir"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup do estado atual..."
cp -a "$APP/Cargo.toml" "$OUT/Cargo.toml.before" 2>/dev/null || true
cp -a "$APP/Cargo.lock" "$OUT/Cargo.lock.before" 2>/dev/null || true
cp -a "$APP/src/main.rs" "$OUT/main.rs.before" 2>/dev/null || true
cp -a "$APP/scripts/mocha-updater-action-v1.sh" "$OUT/mocha-updater-action-v1.before.sh" 2>/dev/null || true

echo
echo "2) Reescrevendo helper com logdir seguro para usuário/root..."
cat > "$APP/scripts/mocha-updater-action-v1.sh" <<'ACTION'
#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ACTION="${1:-}"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [ "$(id -u)" -eq 0 ]; then
  LOGDIR="/var/log/mocha-updater"
else
  BASE="${XDG_STATE_HOME:-$HOME/.local/state}"
  LOGDIR="$BASE/mocha-updater/logs"
fi

mkdir -p "$LOGDIR"
LOG="$LOGDIR/${ACTION:-acao-desconhecida}-$STAMP.log"

exec > >(tee -a "$LOG") 2>&1

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

need_root() {
  [ "$(id -u)" -eq 0 ] || fail "Esta ação precisa rodar como root."
}

have() { command -v "$1" >/dev/null 2>&1; }

print_header() {
  echo "============================================================"
  echo " Mocha Updater — $1"
  echo "============================================================"
  echo
  echo "Data: $(date -Is)"
  echo "Usuário: $(id -un)"
  echo "Log: $LOG"
  echo
}

kernel_ignore_args() {
  printf '%s\n' \
    --ignore linux \
    --ignore linux-headers \
    --ignore linux-cachyos \
    --ignore linux-cachyos-headers \
    --ignore linux-cachyos-nvidia-open \
    --ignore linux-cachyos-lts \
    --ignore linux-cachyos-lts-headers \
    --ignore linux-cachyos-lts-nvidia-open \
    --ignore nvidia \
    --ignore nvidia-open \
    --ignore nvidia-utils \
    --ignore lib32-nvidia-utils \
    --ignore opencl-nvidia \
    --ignore lib32-opencl-nvidia \
    --ignore nvidia-settings
}

detect_cpu_level() {
  if /lib64/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v4.*supported'; then
    echo "x86-64-v4"
  elif /lib64/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v3.*supported'; then
    echo "x86-64-v3"
  elif grep -qm1 ' avx2 ' /proc/cpuinfo 2>/dev/null; then
    echo "x86-64-v3-provavel"
  else
    echo "x86-64-v2-ou-basico"
  fi
}

has_nvidia_gpu() {
  lspci -nn 2>/dev/null | grep -Eiq 'nvidia'
}

confirm_kernel_action() {
  echo
  echo "Esta ação mexe em kernel/driver."
  echo "Ela é separada do update geral para evitar conversão ou troca acidental."
  echo
  printf "Digite SIM para continuar: "
  read -r ans
  [ "$ans" = "SIM" ] || fail "Cancelado pelo usuário."
}

regen_boot() {
  echo
  echo "Regenerando initramfs/GRUB quando disponível..."
  if have mkinitcpio; then
    mkinitcpio -P || fail "mkinitcpio falhou"
  fi
  if have grub-mkconfig && [ -d /boot/grub ]; then
    grub-mkconfig -o /boot/grub/grub.cfg || fail "grub-mkconfig falhou"
  fi
  ok "Boot regenerado"
}

install_mocha_stable_core() {
  CPU_LEVEL="$(detect_cpu_level)"
  echo "CPU detectada: $CPU_LEVEL"

  case "$CPU_LEVEL" in
    x86-64-v3*|x86-64-v4*) ok "CPU compatível com pacote v3/provável" ;;
    *) fail "CPU não parece compatível com x86-64-v3. Abortando para segurança." ;;
  esac

  echo
  echo "Backup pré-transação:"
  BK="/var/backups/mocha-updater/kernel-driver-pre-$STAMP"
  mkdir -p "$BK"
  pacman -Q > "$BK/pacman-Q.txt"
  pacman -Qqe > "$BK/pacman-Qqe.txt"
  cp -a /boot "$BK/boot-copy" 2>/dev/null || warn "Não foi possível copiar /boot inteiro"
  ok "Backup salvo em $BK"

  echo
  echo "Validando repo Mocha..."
  pacman -Si mocha/linux-cachyos mocha/linux-cachyos-headers >/dev/null || fail "Repo/pacotes Mocha linux-cachyos indisponíveis"

  PKGS=(mocha/linux-cachyos mocha/linux-cachyos-headers)

  if has_nvidia_gpu; then
    echo "GPU NVIDIA detectada: instalando driver casado do kernel Mocha."
    pacman -Si mocha/linux-cachyos-nvidia-open >/dev/null || fail "mocha/linux-cachyos-nvidia-open indisponível"
    PKGS+=(mocha/linux-cachyos-nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings opencl-nvidia lib32-opencl-nvidia egl-wayland libxnvctrl)
  else
    warn "GPU NVIDIA não detectada. Instalando apenas kernel/headers."
  fi

  echo
  echo "Instalando:"
  printf '  %s\n' "${PKGS[@]}"
  echo

  pacman -S --needed --noconfirm "${PKGS[@]}" || fail "Instalação kernel/driver falhou"

  regen_boot

  echo
  echo "Estado final:"
  uname -r || true
  pacman -Q linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open nvidia-utils 2>/dev/null || true
  timeout 8 nvidia-smi 2>/dev/null || true

  ok "Kernel/driver Mocha estável aplicado. Reinicie antes de validar FPS."
}

action_system_check() {
  print_header "verificação geral sem alterações"

  echo "Sistema:"
  uname -a || true
  cat /etc/os-release 2>/dev/null || true
  echo

  echo "Pacman lock:"
  if [ -e /var/lib/pacman/db.lck ]; then
    ls -l /var/lib/pacman/db.lck
    warn "Há lock do pacman. Não rode update enquanto existir."
  else
    ok "Sem lock do pacman"
  fi
  echo

  echo "Pacotes instalados relevantes:"
  pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open nvidia-utils lib32-nvidia-utils opencl-nvidia nvidia-settings 2>/dev/null || true
  echo

  echo "Atualizações pendentes:"
  if have checkupdates; then
    checkupdates || true
  else
    pacman -Qu || true
  fi
  echo

  echo "Flatpak:"
  if have flatpak; then
    flatpak remote-ls --updates 2>/dev/null || true
  else
    warn "flatpak ausente"
  fi
  echo

  echo "NVIDIA:"
  timeout 8 nvidia-smi 2>/dev/null || warn "nvidia-smi indisponível"
  echo

  echo "Kernel atual:"
  uname -r
  echo

  ok "Verificação concluída sem alterar o sistema"
}

action_system_update() {
  need_root
  print_header "update geral conservador"

  echo "Update geral NÃO troca kernel/driver NVIDIA."
  echo "Pacotes de kernel/driver serão ignorados e tratados na guia própria."
  echo

  mapfile -t IGN < <(kernel_ignore_args)
  pacman -Syu --needed "${IGN[@]}" || fail "pacman -Syu conservador falhou"

  if have flatpak; then
    flatpak update -y || fail "flatpak update falhou"
  else
    warn "flatpak ausente"
  fi

  ok "Update geral conservador concluído"
}

action_kernel_check() {
  print_header "diagnóstico kernel/driver"

  echo "CPU:"
  lscpu 2>/dev/null || true
  echo
  echo "Nível detectado:"
  detect_cpu_level
  echo

  echo "GPU:"
  lspci -nnk 2>/dev/null | grep -EA4 -i 'vga|3d|display' || true
  echo

  echo "NVIDIA runtime:"
  timeout 8 nvidia-smi 2>/dev/null || true
  echo

  echo "Pacotes instalados:"
  pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open nvidia-utils lib32-nvidia-utils opencl-nvidia nvidia-settings 2>/dev/null || true
  echo

  echo "Candidatos do repo Mocha:"
  pacman -Si mocha/linux-cachyos mocha/linux-cachyos-headers mocha/linux-cachyos-nvidia-open 2>/dev/null | grep -E '^(Repository|Name|Version|Architecture)' || warn "Pacotes mocha/linux-cachyos não encontrados via pacman -Si"
  echo

  echo "Módulos carregados:"
  lsmod | grep -E '^nvidia|^nouveau' || true
  echo

  ok "Diagnóstico concluído"
}

action_kernel_install_mocha_stable() {
  need_root
  print_header "instalar/restaurar kernel Mocha estável casado"
  confirm_kernel_action
  install_mocha_stable_core
}

action_rollback_mocha_stable() {
  need_root
  print_header "rollback para kernel Mocha estável"
  confirm_kernel_action

  echo "Este rollback reinstala o trio estável do repo Mocha:"
  echo "  mocha/linux-cachyos"
  echo "  mocha/linux-cachyos-headers"
  echo "  mocha/linux-cachyos-nvidia-open, se houver NVIDIA"
  echo

  install_mocha_stable_core
}

action_logs() {
  print_header "logs recentes"

  echo "Logs do usuário:"
  find "${XDG_STATE_HOME:-$HOME/.local/state}/mocha-updater/logs" -maxdepth 1 -type f -printf '%TY-%Tm-%Td %TH:%TM %p\n' 2>/dev/null | sort | tail -n 40 || true
  echo

  echo "Logs root:"
  find /var/log/mocha-updater -maxdepth 1 -type f -printf '%TY-%Tm-%Td %TH:%TM %p\n' 2>/dev/null | sort | tail -n 40 || true
  echo

  echo "Pacman kernel/driver recente:"
  grep -Ei 'linux-cachyos|nvidia|kernel|mkinitcpio|grub' /var/log/pacman.log 2>/dev/null | tail -n 120 || true
  echo

  echo "Boots disponíveis:"
  find /boot -maxdepth 2 -type f \( -name 'vmlinuz-*' -o -name 'initramfs-*' -o -name 'grub.cfg' \) -printf '%p\n' 2>/dev/null | sort || true
  echo

  ok "Coleta de logs concluída"
}

case "$ACTION" in
  system-check) action_system_check ;;
  system-update) action_system_update ;;
  kernel-check) action_kernel_check ;;
  kernel-install-mocha-stable) action_kernel_install_mocha_stable ;;
  rollback-mocha-stable) action_rollback_mocha_stable ;;
  logs) action_logs ;;
  *)
    echo "Uso: $0 {system-check|system-update|kernel-check|kernel-install-mocha-stable|rollback-mocha-stable|logs}"
    exit 2
    ;;
esac
ACTION

chmod +x "$APP/scripts/mocha-updater-action-v1.sh"

echo
echo "3) Garantindo Cargo.toml v0.2.0..."
cat > "$APP/Cargo.toml" <<'CARGO'
[package]
name = "mocha-updater"
version = "0.2.0"
edition = "2021"

[dependencies]
eframe = "0.31"
egui = "0.31"
CARGO

echo
echo "4) Instalando helper corrigido..."
sudo mkdir -p /usr/local/lib/mocha/mocha-updater
sudo install -m 755 "$APP/scripts/mocha-updater-action-v1.sh" /usr/local/lib/mocha/mocha-updater/mocha-updater-action
ok "Helper instalado"

echo
echo "5) Atualizando Cargo.lock sem rede e compilando..."
cd "$APP"

if cargo generate-lockfile --offline; then
  ok "Cargo.lock atualizado offline"
else
  warn "generate-lockfile offline falhou; tentando modo normal"
  cargo generate-lockfile
fi

if cargo build --release --offline; then
  ok "Build release offline concluído"
else
  warn "Build offline falhou; tentando build release normal"
  cargo build --release
fi

echo
echo "6) Instalando binário..."
sudo install -m 755 "$APP/target/release/mocha-updater" /usr/local/bin/mocha-updater
ok "Binário instalado: /usr/local/bin/mocha-updater"

echo
echo "7) Reinstalando ícone e atalhos canônicos..."
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
echo "8) Validação sem alteração de sistema..."
/usr/local/lib/mocha/mocha-updater/mocha-updater-action system-check | tee "$OUT/system-check.txt"

echo
echo "9) Estado final:"
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

ok "Fix concluído"
