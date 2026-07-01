#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

REPO_NAME="${1:-mocha}"
TARGET_VER="7.1.1-2"

sudo pacman -Syy

for pkg in linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open; do
  ver="$(pacman -Si "${REPO_NAME}/${pkg}" 2>/dev/null | awk -F ':' '/^Version[[:space:]]*:/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')"
  [ "$ver" = "$TARGET_VER" ] || {
    echo "[ERRO] ${REPO_NAME}/${pkg} não está em ${TARGET_VER}; versão vista: ${ver:-NA}"
    exit 1
  }
done

sudo pacman -S --noconfirm \
  "${REPO_NAME}/linux-cachyos" \
  "${REPO_NAME}/linux-cachyos-headers" \
  "${REPO_NAME}/linux-cachyos-nvidia-open"

if command -v mkinitcpio >/dev/null 2>&1; then
  sudo mkinitcpio -P
fi

if command -v grub-mkconfig >/dev/null 2>&1 && [ -d /boot/grub ]; then
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "[OK] CachyOS 7.1.1-2 instalado pelo repo ${REPO_NAME}. Reinicie."
