#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

MODE="${1:-run}"

PROJECT="/media/mochafast/MochaArch"
SCRIPT_PATH="$PROJECT/scripts/mocha-testa-cachyos-nvidia-open-casado-v1.sh"

TS="$(date +%Y%m%d-%H%M%S)"
WORK="$HOME/.local/share/mocha/cachyos-nvidia-open-casado-$TS"
LOG="$WORK/run.log"
ROLLBACK="$WORK/rollback-cachyos-nvidia-open.sh"

mkdir -p "$WORK"
exec > >(tee -a "$LOG") 2>&1

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
fail() { printf '[ERRO] %s\n' "$*"; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Comando ausente: $1"
}

pkg_installed() {
  pacman -Qq "$1" >/dev/null 2>&1
}

pkg_sync_version() {
  pacman -Si "$1" 2>/dev/null | awk -F: '/^Version/ {gsub(/^[ \t]+/, "", $2); print $2; exit}'
}

save_state() {
  ok "Salvando estado atual em: $WORK"
  pacman -Q > "$WORK/pacman-Q-before.txt" || true
  pacman -Qqe > "$WORK/pacman-Qqe-before.txt" || true
  pacman -Qqn > "$WORK/pacman-Qqn-before.txt" || true
  pacman -Qqm > "$WORK/pacman-Qqm-before.txt" || true
  uname -a > "$WORK/uname-before.txt" || true
  cat /proc/cmdline > "$WORK/cmdline-before.txt" || true
  cp -a /etc/pacman.conf "$WORK/pacman.conf.before" 2>/dev/null || true
  cp -a /etc/default/grub "$WORK/grub.before" 2>/dev/null || true
  ls -la /boot > "$WORK/boot-ls-before.txt" 2>/dev/null || true
}

make_rollback_script() {
  {
    printf '#!/usr/bin/env bash\n'
    printf 'set -Eeuo pipefail\n'
    printf 'export LC_ALL=C\n'
    printf 'sudo -v\n'
    printf 'SCRIPT=%q\n' "$SCRIPT_PATH"
    printf 'if [ -x "$SCRIPT" ]; then\n'
    printf '  "$SCRIPT" rollback\n'
    printf 'else\n'
    printf '  echo "Script canonico nao encontrado: $SCRIPT" >&2\n'
    printf '  exit 1\n'
    printf 'fi\n'
  } > "$ROLLBACK"
  chmod +x "$ROLLBACK"
  ok "Rollback salvo em: $ROLLBACK"
}

make_grub_menu_visible() {
  if [ -f /etc/default/grub ] && command -v grub-mkconfig >/dev/null 2>&1 && [ -d /boot/grub ]; then
    sudo cp -a /etc/default/grub "/etc/default/grub.bak-$TS"

    if grep -q '^GRUB_TIMEOUT_STYLE=' /etc/default/grub; then
      sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
    else
      printf 'GRUB_TIMEOUT_STYLE=menu\n' | sudo tee -a /etc/default/grub >/dev/null
    fi

    if grep -q '^GRUB_TIMEOUT=' /etc/default/grub; then
      sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub
    else
      printf 'GRUB_TIMEOUT=10\n' | sudo tee -a /etc/default/grub >/dev/null
    fi

    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ok "GRUB configurado para mostrar menu por 10 segundos."
  else
    warn "GRUB não detectado em /boot/grub; pulando ajuste de menu."
  fi
}

rebuild_boot() {
  ok "Regenerando initramfs."
  sudo mkinitcpio -P

  if command -v grub-mkconfig >/dev/null 2>&1 && [ -d /boot/grub ]; then
    ok "Regenerando GRUB."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi

  if command -v bootctl >/dev/null 2>&1 && bootctl is-installed >/dev/null 2>&1; then
    ok "Atualizando systemd-boot."
    sudo bootctl update || true
  fi
}

rollback() {
  sudo -v
  ok "Iniciando rollback para NVIDIA open DKMS + fallback Arch LTS."

  local prebuilt=(
    linux-cachyos-nvidia-open
    linux-cachyos-bore-nvidia-open
    linux-cachyos-eevdf-nvidia-open
    linux-cachyos-lts-nvidia-open
    linux-cachyos-lto-nvidia-open
    linux-cachyos-bore-lto-nvidia-open
    linux-cachyos-eevdf-lto-nvidia-open
  )

  local installed_prebuilt=()
  local p
  for p in "${prebuilt[@]}"; do
    if pkg_installed "$p"; then
      installed_prebuilt+=("$p")
    fi
  done

  if [ "${#installed_prebuilt[@]}" -gt 0 ]; then
    warn "Removendo módulos NVIDIA precompilados do CachyOS: ${installed_prebuilt[*]}"
    sudo pacman -R --noconfirm "${installed_prebuilt[@]}" || warn "Remoção automática falhou; pode haver conflito manual."
  fi

  ok "Instalando fallback Arch LTS + nvidia-open-dkms."
  sudo pacman -S --needed linux-lts linux-lts-headers dkms nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

  rebuild_boot

  ok "Rollback aplicado. Reinicie e escolha linux-lts no menu, se necessário."
  ok "Log: $LOG"
}

check_after_reboot() {
  sudo -v

  printf '\n============================================================\n'
  printf ' Mocha — validação CachyOS NVIDIA open casado\n'
  printf '============================================================\n\n'

  echo "Kernel ativo:"
  uname -r || true

  echo
  echo "Pkgbase do kernel ativo:"
  cat "/usr/lib/modules/$(uname -r)/pkgbase" 2>/dev/null || true

  echo
  echo "Pacotes relevantes:"
  pacman -Q \
    linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open \
    linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open \
    nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings \
    2>/dev/null || true

  echo
  echo "Módulos NVIDIA carregados:"
  lsmod | grep -E '^(nvidia|nvidia_drm|nvidia_modeset|nvidia_uvm)' || true

  echo
  echo "modinfo nvidia:"
  timeout 10 modinfo nvidia 2>/dev/null | sed -n '1,35p' || true

  echo
  echo "nvidia-smi:"
  timeout 10 nvidia-smi || true

  echo
  echo "DRM modeset:"
  cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || true

  echo
  echo "SDDM:"
  timeout 10 systemctl is-active sddm 2>/dev/null || true
  timeout 10 systemctl is-enabled sddm 2>/dev/null || true

  echo
  echo "Erros relevantes do boot atual:"
  timeout 10 journalctl -b -p err --no-pager 2>/dev/null | grep -Ei 'nvidia|drm|kwin|sddm|plasma|wayland' | tail -80 || true

  echo
  echo "Validação concluída."
}

run_install() {
  sudo -v

  need_cmd pacman
  need_cmd awk
  need_cmd grep
  need_cmd sed
  need_cmd mkinitcpio

  save_state
  make_rollback_script

  printf '\n============================================================\n'
  printf ' Mocha — teste linux-cachyos + nvidia-open casado\n'
  printf '============================================================\n\n'

  if pgrep -x steam >/dev/null 2>&1 || pgrep -x steamwebhelper >/dev/null 2>&1; then
    warn "Steam parece estar aberto. Feche antes de reiniciar; a instalação pode continuar."
  fi

  ok "Sincronizando base de pacotes."
  sudo pacman -Sy

  local target_kernel="linux-cachyos"
  local target_headers="linux-cachyos-headers"
  local target_nvidia="linux-cachyos-nvidia-open"

  local fallback_kernel="linux-cachyos-lts"
  local fallback_headers="linux-cachyos-lts-headers"
  local fallback_nvidia="linux-cachyos-lts-nvidia-open"

  local target_kernel_ver
  local target_nvidia_ver
  local fallback_kernel_ver
  local fallback_nvidia_ver

  target_kernel_ver="$(pkg_sync_version "$target_kernel")"
  target_nvidia_ver="$(pkg_sync_version "$target_nvidia")"
  fallback_kernel_ver="$(pkg_sync_version "$fallback_kernel")"
  fallback_nvidia_ver="$(pkg_sync_version "$fallback_nvidia")"

  [ -n "$target_kernel_ver" ] || fail "Pacote não encontrado no syncdb: $target_kernel"
  [ -n "$target_nvidia_ver" ] || fail "Pacote não encontrado no syncdb: $target_nvidia"
  [ -n "$fallback_kernel_ver" ] || fail "Pacote não encontrado no syncdb: $fallback_kernel"
  [ -n "$fallback_nvidia_ver" ] || fail "Pacote não encontrado no syncdb: $fallback_nvidia"

  [ "$target_kernel_ver" = "$target_nvidia_ver" ] || fail "Versões não casam: $target_kernel=$target_kernel_ver / $target_nvidia=$target_nvidia_ver"
  [ "$fallback_kernel_ver" = "$fallback_nvidia_ver" ] || fail "Versões fallback não casam: $fallback_kernel=$fallback_kernel_ver / $fallback_nvidia=$fallback_nvidia_ver"

  ok "Kernel principal casado: $target_kernel $target_kernel_ver + $target_nvidia $target_nvidia_ver"
  ok "Fallback casado: $fallback_kernel $fallback_kernel_ver + $fallback_nvidia $fallback_nvidia_ver"

  local targets=(
    "$fallback_kernel"
    "$fallback_headers"
    "$fallback_nvidia"
    "$target_kernel"
    "$target_headers"
    "$target_nvidia"
    nvidia-utils
    lib32-nvidia-utils
    nvidia-settings
  )

  ok "Baixando pacotes antes de alterar módulos."
  sudo pacman -Sw --needed --noconfirm "${targets[@]}"

  local conflicts=(
    nvidia
    nvidia-dkms
    nvidia-open
    nvidia-open-dkms
    nvidia-lts
    nvidia-open-lts
    linux-cachyos-nvidia
    linux-cachyos-lts-nvidia
    linux-cachyos-bore-nvidia
    linux-cachyos-bore-nvidia-open
    linux-cachyos-eevdf-nvidia
    linux-cachyos-eevdf-nvidia-open
  )

  local installed_conflicts=()
  local c
  for c in "${conflicts[@]}"; do
    if pkg_installed "$c"; then
      case "$c" in
        "$target_nvidia"|"$fallback_nvidia")
          ;;
        *)
          installed_conflicts+=("$c")
          ;;
      esac
    fi
  done

  if [ "${#installed_conflicts[@]}" -gt 0 ]; then
    warn "Removendo módulos NVIDIA conflitantes antes da instalação casada: ${installed_conflicts[*]}"
    sudo pacman -R --noconfirm "${installed_conflicts[@]}"
  fi

  ok "Instalando fallback primeiro e módulo NVIDIA casado do CachyOS."
  if ! sudo pacman -S --needed --noconfirm "${targets[@]}"; then
    warn "Instalação falhou. Tentando rollback automático."
    rollback || true
    fail "Instalação do conjunto CachyOS NVIDIA open casado falhou."
  fi

  make_grub_menu_visible
  rebuild_boot

  printf '\n============================================================\n'
  printf ' RESULTADO\n'
  printf '============================================================\n\n'
  ok "Instalação concluída."
  ok "Principal de teste: $target_kernel + $target_nvidia"
  ok "Fallback instalado: $fallback_kernel + $fallback_nvidia"
  ok "Nenhum manual foi alterado."
  ok "Rollback: $ROLLBACK"
  ok "Log: $LOG"

  printf '\nDepois de reiniciar, valide com:\n'
  printf '  %s check\n' "$SCRIPT_PATH"
  printf '\nSe der ruim, no GRUB escolha o fallback linux-cachyos-lts. Se precisar reverter pacotes, rode:\n'
  printf '  %s\n' "$ROLLBACK"
}

case "$MODE" in
  run)
    run_install
    ;;
  check)
    check_after_reboot
    ;;
  rollback)
    rollback
    ;;
  *)
    fail "Modo inválido. Use: run, check ou rollback."
    ;;
esac
