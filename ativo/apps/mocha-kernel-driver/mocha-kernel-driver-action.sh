#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ACTION="${1:-scan}"
TMP_CONF=""
SUDO_KEEPALIVE_PID=""

cleanup_backend() {
  set +e
  [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
  [ -n "${TMP_CONF:-}" ] && rm -f "$TMP_CONF" >/dev/null 2>&1 || true
}
trap cleanup_backend EXIT

need_sudo() {
  sudo -v
  (
    while true; do
      sudo -n true || exit
      sleep 30
    done
  ) &
  SUDO_KEEPALIVE_PID="$!"
}

add_repo_if_possible() {
  local conf="$1"
  local repo="$2"
  local include_file="$3"

  grep -Eq "^[[:space:]]*\[$repo\]" "$conf" && return 0
  [ -f "$include_file" ] || return 0

  {
    echo
    echo "[$repo]"
    echo "Include = $include_file"
  } >> "$conf"
}

make_tmpconf() {
  TMP_CONF="$(mktemp /tmp/mocha-pacman-cachy-transitorio-XXXXXX.conf)"
  cp /etc/pacman.conf "$TMP_CONF"

  add_repo_if_possible "$TMP_CONF" "cachyos-v3"       "/etc/pacman.d/cachyos-v3-mirrorlist"
  add_repo_if_possible "$TMP_CONF" "cachyos-core-v3"  "/etc/pacman.d/cachyos-v3-mirrorlist"
  add_repo_if_possible "$TMP_CONF" "cachyos-extra-v3" "/etc/pacman.d/cachyos-v3-mirrorlist"
  add_repo_if_possible "$TMP_CONF" "cachyos"          "/etc/pacman.d/cachyos-mirrorlist"

  printf '%s\n' "$TMP_CONF"
}

pkg_exists() {
  local conf="$1"
  local pkg="$2"
  pacman --config "$conf" -Si "$pkg" >/dev/null 2>&1
}

pkg_ver() {
  local conf="$1"
  local pkg="$2"
  local ver=""
  ver="$(pacman --config "$conf" -Si "$pkg" 2>/dev/null | awk -F: '/^Version/ {gsub(/^[ \t]+/, "", $2); print $2; exit}' || true)"
  if [ -n "$ver" ]; then
    printf '%s %s\n' "$pkg" "$ver"
  else
    printf '%s indisponivel/no-cache\n' "$pkg"
  fi
}

gpu_vendor() {
  local g
  g="$(lspci -nn 2>/dev/null | grep -Ei 'VGA|3D|Display' || true)"
  if printf '%s\n' "$g" | grep -Eqi 'NVIDIA'; then
    echo "NVIDIA"
  elif printf '%s\n' "$g" | grep -Eqi 'AMD|ATI|Advanced Micro Devices'; then
    echo "AMD"
  elif printf '%s\n' "$g" | grep -Eqi 'Intel'; then
    echo "Intel"
  else
    echo "desconhecido"
  fi
}

cpu_vendor() {
  lscpu 2>/dev/null | awk -F: '/Vendor ID/ {gsub(/^[ \t]+/, "", $2); print $2; exit}'
}

microcode_pkg() {
  case "$(cpu_vendor)" in
    AuthenticAMD) echo "amd-ucode" ;;
    GenuineIntel) echo "intel-ucode" ;;
    *) echo "" ;;
  esac
}

x86_level() {
  if /lib64/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v4.*supported'; then
    echo "x86-64-v4"
  elif /lib64/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v3.*supported'; then
    echo "x86-64-v3"
  elif /lib64/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v2.*supported'; then
    echo "x86-64-v2"
  else
    echo "x86-64"
  fi
}

add_pkg_if_exists() {
  local conf="$1"
  local pkg="$2"
  shift 2
  if pkg_exists "$conf" "$pkg"; then
    printf '%s\n' "$pkg"
  fi
}

detect_stack_pkgs() {
  local conf="$1"
  local vendor micro
  vendor="$(gpu_vendor)"
  micro="$(microcode_pkg)"

  {
    echo "linux-cachyos"
    echo "linux-cachyos-headers"

    if [ -n "$micro" ] && pkg_exists "$conf" "$micro"; then
      echo "$micro"
    fi

    case "$vendor" in
      NVIDIA)
        if pkg_exists "$conf" "linux-cachyos-nvidia-open"; then
          echo "linux-cachyos-nvidia-open"
        elif pkg_exists "$conf" "linux-cachyos-nvidia"; then
          echo "linux-cachyos-nvidia"
        elif pkg_exists "$conf" "nvidia-open-dkms"; then
          echo "nvidia-open-dkms"
        elif pkg_exists "$conf" "nvidia-dkms"; then
          echo "nvidia-dkms"
        fi

        for p in nvidia-utils lib32-nvidia-utils nvidia-settings opencl-nvidia egl-wayland libxnvctrl; do
          add_pkg_if_exists "$conf" "$p"
        done
        ;;

      AMD)
        for p in mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver mesa-vdpau xf86-video-amdgpu; do
          add_pkg_if_exists "$conf" "$p"
        done
        ;;

      Intel)
        for p in mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver; do
          add_pkg_if_exists "$conf" "$p"
        done
        ;;

      *)
        for p in mesa lib32-mesa; do
          add_pkg_if_exists "$conf" "$p"
        done
        ;;
    esac
  } | awk 'NF && !seen[$0]++'
}

scan() {
  local conf vendor micro flags
  conf="$(make_tmpconf)"
  vendor="$(gpu_vendor)"
  micro="$(microcode_pkg)"
  flags="$(lscpu 2>/dev/null | awk -F: '/Flags/ {print $2; exit}' || true)"

  echo "Mocha - Kernel e Driver"
  echo "Interface Mocha/KDE com CachyOS transitorio"
  echo

  echo "[CPU]"
  echo "Modelo: $(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
  echo "Vendor: $(cpu_vendor)"
  echo "Nivel x86-64: $(x86_level)"
  echo "Microcode recomendado: ${micro:-desconhecido}"
  printf 'AVX: %s | AVX2: %s | AVX512: %s | FMA: %s | AES: %s\n' \
    "$(printf '%s\n' "$flags" | grep -qw avx && echo sim || echo nao)" \
    "$(printf '%s\n' "$flags" | grep -qw avx2 && echo sim || echo nao)" \
    "$(printf '%s\n' "$flags" | grep -qw avx512f && echo sim || echo nao)" \
    "$(printf '%s\n' "$flags" | grep -qw fma && echo sim || echo nao)" \
    "$(printf '%s\n' "$flags" | grep -qw aes && echo sim || echo nao)"

  echo
  echo "[Kernel atual]"
  echo "uname -r: $(uname -r)"
  pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers 2>/dev/null | sed 's/^/Pacote: /' || true

  echo
  echo "[GPU/driver atual]"
  echo "Vendor detectado: $vendor"
  echo "Modulos carregados:"
  lsmod | awk '/^nvidia|^nouveau|^amdgpu|^i915|^xe/ {print "  " $1}' || true
  lspci -k 2>/dev/null | awk '
    /VGA|3D|Display/ {print $0; show=1; next}
    show && /Kernel driver in use|Kernel modules/ {print "  " $0}
    show && NF==0 {show=0}
  ' | sed -n '1,12p'

  echo
  echo "[Pacotes de video instalados]"
  pacman -Q \
    linux-cachyos-nvidia-open linux-cachyos-nvidia \
    nvidia-open-dkms nvidia-dkms nvidia-utils lib32-nvidia-utils \
    mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-intel lib32-vulkan-intel \
    intel-media-driver 2>/dev/null | sed 's/^/Pacote: /' || true

  echo
  echo "[Disponivel no canal transitorio]"
  for p in \
    linux-cachyos linux-cachyos-headers \
    linux-cachyos-nvidia-open linux-cachyos-nvidia \
    nvidia-open-dkms nvidia-dkms nvidia-utils \
    mesa vulkan-radeon vulkan-intel
  do
    pkg_ver "$conf" "$p"
  done

  echo
  echo "[Stack que sera usado]"
  detect_stack_pkgs "$conf" | sed 's/^/  /'

  echo
  echo "[Acoes]"
  echo "Instalar: instala pacotes ausentes do stack detectado."
  echo "Reinstalar: reinstala kernel, headers e driver detectado."
  echo "O canal CachyOS e usado por config temporaria, sem gravar em /etc/pacman.conf."
}

run_stack_action() {
  local mode="$1"
  local conf
  conf="$(make_tmpconf)"

  need_sudo

  echo
  echo "============================================================"
  echo " Mocha - Kernel/Driver: $mode"
  echo "============================================================"
  echo

  echo "[1] Sincronizando bancos pelo canal transitorio"
  sudo pacman --config "$conf" -Syy --noconfirm

  mapfile -t PKGS < <(detect_stack_pkgs "$conf")

  if [ "${#PKGS[@]}" -eq 0 ]; then
    echo "[FALHA] Nenhum pacote detectado para instalacao."
    exit 1
  fi

  echo
  echo "[2] Pacotes selecionados"
  printf '  %s\n' "${PKGS[@]}"

  echo
  if [ "$mode" = "install" ]; then
    echo "[3] Instalando apenas o que estiver ausente"
    sudo pacman --config "$conf" -S --needed --noconfirm "${PKGS[@]}"
  else
    echo "[3] Reinstalando o stack completo"
    sudo pacman --config "$conf" -S --noconfirm "${PKGS[@]}"
  fi

  echo
  echo "[4] Recriando initramfs"
  if command -v mkinitcpio >/dev/null 2>&1; then
    sudo mkinitcpio -P
  else
    echo "[AVISO] mkinitcpio nao encontrado."
  fi

  echo
  echo "[5] Atualizando GRUB, se existir"
  if command -v grub-mkconfig >/dev/null 2>&1 && [ -d /boot/grub ]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  else
    echo "[AVISO] GRUB nao detectado ou grub-mkconfig ausente; pulando."
  fi

  echo
  echo "[6] Resultado instalado"
  pacman -Q "${PKGS[@]}" 2>/dev/null | sed 's/^/  /' || true

  echo
  echo "[OK] Acao concluida."
  echo "Reinicie antes de validar o novo kernel/driver."
}

case "$ACTION" in
  scan)
    scan
    ;;
  install)
    run_stack_action install
    ;;
  reinstall)
    run_stack_action reinstall
    ;;
  *)
    echo "[FALHA] Acao desconhecida: $ACTION"
    exit 2
    ;;
esac
