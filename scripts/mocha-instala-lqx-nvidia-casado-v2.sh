#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ok()   { printf '[OK] %s\n' "$*"; }
info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

MODE="${1:---check}"

if [ "$(id -u)" -ne 0 ]; then
  fail "Execute com sudo: sudo $0 --check ou sudo $0 --apply"
fi

AUDIT_ROOT="/media/vmstore/MochaArch/auditorias"
STAMP="$(date +%Y%m%d-%H%M%S)"
AUDIT_DIR="$AUDIT_ROOT/instala-lqx-nvidia-casado-v2-$STAMP"
mkdir -p "$AUDIT_DIR"

exec > >(tee -a "$AUDIT_DIR/execucao.txt") 2>&1

PKGS=(
  linux-lqx
  linux-lqx-headers
  nvidia-open-dkms
  nvidia-utils
  lib32-nvidia-utils
  nvidia-settings
  opencl-nvidia
  lib32-opencl-nvidia
  vulkan-icd-loader
  lib32-vulkan-icd-loader
)

info "Modo: $MODE"
info "Este script instala/valida Liquorix + NVIDIA sem usar instalador .run."
info "O driver NVIDIA vem de pacote pacman/DKMS, não do repo Liquorix."

echo
info "Pacotes alvo:"
printf '%s\n' "${PKGS[@]}"

echo
info "Pacotes atualmente instalados:"
pacman -Q "${PKGS[@]}" 2>/dev/null || true

echo
info "Kernel ativo:"
uname -r || true

echo
info "DKMS atual:"
dkms status 2>/dev/null || true

echo
info "NVIDIA runtime atual:"
nvidia-smi 2>/dev/null || true

case "$MODE" in
  --check)
    ok "Check concluído. Nenhuma instalação foi feita."
    ;;
  --apply)
    info "Instalando pacotes necessários via pacman..."
    pacman -S --needed --noconfirm "${PKGS[@]}"

    info "Recriando initramfs, se mkinitcpio existir..."
    if command -v mkinitcpio >/dev/null 2>&1; then
      mkinitcpio -P
    fi

    info "Regenerando GRUB, se existir..."
    if command -v grub-mkconfig >/dev/null 2>&1 && [ -d /boot/grub ]; then
      grub-mkconfig -o /boot/grub/grub.cfg
    fi

    echo
    info "Validação pós-instalação:"
    pacman -Q "${PKGS[@]}" 2>/dev/null || true
    dkms status 2>/dev/null || true
    nvidia-smi 2>/dev/null || true

    ok "Instalação/validação concluída."
    ;;
  *)
    fail "Modo inválido. Use --check ou --apply."
    ;;
esac

ok "Auditoria: $AUDIT_DIR"
