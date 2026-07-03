#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ACTION="${1:-}"

ok()   { printf '[OK] %s\n' "$*"; }
info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

as_root() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

print_header() {
  printf '\n===== %s =====\n' "$1"
}

kernel_ignore_args() {
  local pkgs=(
    linux linux-headers
    linux-lts linux-lts-headers
    linux-zen linux-zen-headers
    linux-hardened linux-hardened-headers
    linux-lqx linux-lqx-headers
    nvidia-open-dkms
    nvidia-dkms
    nvidia-utils lib32-nvidia-utils
    opencl-nvidia lib32-opencl-nvidia
    nvidia-settings libxnvctrl egl-wayland
    linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open
    linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open
  )

  local args=()
  local p
  for p in "${pkgs[@]}"; do
    args+=(--ignore "$p")
  done

  printf '%s\n' "${args[@]}"
}

has_nvidia_gpu() {
  lspci -nn 2>/dev/null | grep -Eiq 'nvidia'
}

show_pkg_candidate() {
  local pkg="$1"
  local repo spec
  local repos=(
    mocha-lqx
    mocha-liquorix
    mocha-kernel-liquorix
    mocha-local-lqx
    mocha
    core
    extra
    multilib
  )

  for repo in "${repos[@]}"; do
    spec="${repo}/${pkg}"
    if pacman -Si "$spec" >/dev/null 2>&1; then
      pacman -Si "$spec" 2>/dev/null | awk -F': ' '/^(Repository|Name|Version|Architecture)/ {print}'
      return 0
    fi
  done

  if pacman -Si "$pkg" >/dev/null 2>&1; then
    pacman -Si "$pkg" 2>/dev/null | awk -F': ' '/^(Repository|Name|Version|Architecture)/ {print}'
    return 0
  fi

  warn "Pacote nao encontrado nos repos configurados: $pkg"
  return 1
}

pkg_spec() {
  local pkg="$1"
  local repo spec
  local repos=(
    mocha-lqx
    mocha-liquorix
    mocha-kernel-liquorix
    mocha-local-lqx
    mocha
    core
    extra
    multilib
  )

  for repo in "${repos[@]}"; do
    spec="${repo}/${pkg}"
    if pacman -Si "$spec" >/dev/null 2>&1; then
      printf '%s\n' "$spec"
      return 0
    fi
  done

  if pacman -Si "$pkg" >/dev/null 2>&1; then
    printf '%s\n' "$pkg"
    return 0
  fi

  return 1
}

detect_x86_64_levels() {
  if [ -x /lib/ld-linux-x86-64.so.2 ]; then
    /lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -E 'x86-64-v[234].*supported' || true
  fi
}

action_system_check() {
  print_header "diagnostico geral"

  echo "Sistema:"
  printf '  Host: %s\n' "$(hostnamectl --static 2>/dev/null || hostname)"
  printf '  Kernel atual: %s\n' "$(uname -r)"
  printf '  Data: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"

  echo
  echo "CPU:"
  lscpu 2>/dev/null | grep -E '^(Model name|Architecture|CPU\(s\)|Vendor ID)' || true

  echo
  echo "GPU:"
  lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display|nvidia|amd|intel' || true

  echo
  echo "Pacman lock:"
  if [ -e /var/lib/pacman/db.lck ]; then
    ls -l /var/lib/pacman/db.lck
    warn "Ha lock do pacman. Nao rode update enquanto existir."
  else
    ok "Sem lock do pacman"
  fi

  echo
  echo "Pacotes kernel/NVIDIA:"
  pacman -Q \
    linux linux-headers \
    linux-lqx linux-lqx-headers \
    nvidia-open-dkms nvidia-utils lib32-nvidia-utils opencl-nvidia lib32-opencl-nvidia nvidia-settings \
    2>/dev/null || true

  echo
  echo "Atualizacoes pacman:"
  if have checkupdates; then
    checkupdates 2>/dev/null || true
  else
    pacman -Qu 2>/dev/null || true
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
  timeout 8 nvidia-smi 2>/dev/null || warn "nvidia-smi indisponivel"
}

action_system_update() {
  print_header "update geral conservador"
  echo "Update geral NAO troca kernel/driver NVIDIA."
  echo "Kernel e driver ficam bloqueados aqui e sao tratados na guia Kernel / Driver."

  mapfile -t IGN < <(kernel_ignore_args)
  as_root pacman -Syu --needed --noconfirm "${IGN[@]}" || fail "pacman -Syu conservador falhou"

  if have flatpak; then
    flatpak update -y || fail "flatpak update falhou"
  else
    warn "flatpak ausente"
  fi

  ok "Update geral concluido sem trocar kernel/driver"
}

action_kernel_check() {
  print_header "diagnostico kernel/driver"

  echo "Kernel atual:"
  uname -r

  echo
  echo "CPU:"
  lscpu 2>/dev/null | grep -E '^(Model name|Architecture|CPU\(s\)|Vendor ID)' || true

  echo
  echo "Niveis x86-64 suportados:"
  detect_x86_64_levels || true

  echo
  echo "GPU:"
  lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display|nvidia|amd|intel' || true

  echo
  echo "NVIDIA runtime:"
  timeout 8 nvidia-smi 2>/dev/null || true

  echo
  echo "Pacotes instalados:"
  pacman -Q \
    linux linux-headers \
    linux-lqx linux-lqx-headers \
    nvidia-open-dkms nvidia-utils lib32-nvidia-utils opencl-nvidia lib32-opencl-nvidia nvidia-settings \
    2>/dev/null || true

  echo
  echo "Candidatos recomendados LQX/DKMS:"
  show_pkg_candidate linux-lqx || true
  show_pkg_candidate linux-lqx-headers || true
  if has_nvidia_gpu; then
    show_pkg_candidate nvidia-open-dkms || true
    show_pkg_candidate nvidia-utils || true
    show_pkg_candidate lib32-nvidia-utils || true
  fi

  echo
  echo "Modulos NVIDIA/Nouveau:"
  lsmod | grep -E '^nvidia|^nouveau' || true

  echo
  echo "Bootloader:"
  if [ -d /boot/grub ]; then
    echo "GRUB detectado em /boot/grub"
    grep -E '^GRUB_DEFAULT=|^GRUB_SAVEDEFAULT=' /etc/default/grub 2>/dev/null || true
  else
    warn "GRUB nao detectado em /boot/grub"
  fi
}

install_lqx_stack() {
  local stamp bk
  stamp="$(date +%Y%m%d-%H%M%S)"
  bk="/var/backups/mocha-updater/lqx-dkms-pre-${stamp}"

  print_header "instalar/restaurar kernel Mocha recomendado LQX + NVIDIA DKMS"

  echo "Esta acao mexe em kernel/driver."
  echo "Conjunto recomendado atual:"
  echo "  linux-lqx"
  echo "  linux-lqx-headers"
  echo "  nvidia-open-dkms + NVIDIA userspace, quando houver GPU NVIDIA"
  echo

  as_root mkdir -p "$bk"
  pacman -Q > "${bk}/pacman-Q.txt" 2>/dev/null || true
  pacman -Qqe > "${bk}/pacman-Qqe.txt" 2>/dev/null || true
  cp -a /etc/pacman.conf "${bk}/pacman.conf" 2>/dev/null || true
  cp -a /etc/default/grub "${bk}/grub-default" 2>/dev/null || true
  cp -a /boot/grub/grub.cfg "${bk}/grub.cfg" 2>/dev/null || true
  uname -a > "${bk}/uname-a.txt" 2>/dev/null || true
  timeout 8 nvidia-smi > "${bk}/nvidia-smi.txt" 2>&1 || true

  echo "Backup pre-kernel salvo em: $bk"

  local required optional pkg spec
  required=(linux-lqx linux-lqx-headers)

  if has_nvidia_gpu; then
    required+=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils)
    optional=(nvidia-settings opencl-nvidia lib32-opencl-nvidia egl-wayland libxnvctrl)
  else
    optional=()
    warn "GPU NVIDIA nao detectada. Instalando apenas kernel/headers LQX."
  fi

  local install_specs=()

  echo
  echo "Validando pacotes obrigatorios:"
  for pkg in "${required[@]}"; do
    spec="$(pkg_spec "$pkg")" || fail "Pacote obrigatorio indisponivel: $pkg"
    echo "  $pkg -> $spec"
    install_specs+=("$spec")
  done

  echo
  echo "Validando pacotes opcionais:"
  for pkg in "${optional[@]}"; do
    if spec="$(pkg_spec "$pkg")"; then
      echo "  $pkg -> $spec"
      install_specs+=("$spec")
    else
      warn "Opcional indisponivel: $pkg"
    fi
  done

  echo
  echo "Instalando conjunto:"
  printf '  %s\n' "${install_specs[@]}"

  as_root pacman -S --noconfirm "${install_specs[@]}" || fail "Instalacao LQX/DKMS falhou"

  if have dkms; then
    as_root dkms autoinstall || warn "dkms autoinstall retornou erro; verificar detalhes tecnicos"
  fi

  if have mkinitcpio; then
    as_root mkinitcpio -P || fail "mkinitcpio -P falhou"
  fi

  if have grub-mkconfig && [ -d /boot/grub ]; then
    as_root grub-mkconfig -o /boot/grub/grub.cfg || fail "grub-mkconfig falhou"
  fi

  if [ -x /media/mochafast/MochaArch/scripts/mocha-define-lqx-padrao-boot-v3.sh ]; then
    echo
    echo "Aplicando script canonico de boot LQX:"
    as_root bash /media/mochafast/MochaArch/scripts/mocha-define-lqx-padrao-boot-v3.sh || warn "Script de boot LQX retornou erro; verificar manualmente"
  else
    warn "Script de boot LQX v3 nao encontrado. O GRUB foi regenerado, mas o default pode precisar de ajuste manual."
  fi

  echo
  echo "Validacao pos-instalacao:"
  pacman -Q linux-lqx linux-lqx-headers nvidia-open-dkms nvidia-utils lib32-nvidia-utils 2>/dev/null || true
  timeout 8 nvidia-smi 2>/dev/null || true

  ok "Kernel Mocha recomendado LQX/DKMS instalado/restaurado"
  echo "Reinicie para validar o kernel ativo com: uname -r"
}

action_kernel_install_mocha_stable() {
  install_lqx_stack
}

action_rollback_mocha_stable() {
  print_header "rollback para conjunto Mocha recomendado"
  install_lqx_stack
}

action_logs() {
  print_header "logs tecnicos recentes"
  echo "Pacman kernel/driver recente:"
  grep -Ei 'linux-lqx|nvidia|kernel|dkms|mkinitcpio|grub' /var/log/pacman.log 2>/dev/null | tail -n 160 || true

  echo
  echo "DKMS:"
  dkms status 2>/dev/null || true

  echo
  echo "Boot:"
  find /boot -maxdepth 3 -type f 2>/dev/null | grep -Ei 'vmlinuz|initramfs|grub.cfg' | sort || true
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
