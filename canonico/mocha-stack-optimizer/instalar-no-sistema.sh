#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOTFS="$SRC/rootfs"

fail() {
  printf '[FALHA] %s\n' "$*" >&2
  exit 1
}

[ -d "$ROOTFS" ] || fail "rootfs canônico ausente: $ROOTFS"

sudo install -D -m 0755 "$ROOTFS/usr/local/lib/mocha/mocha-kernel-driver-engine" "/usr/local/lib/mocha/mocha-kernel-driver-engine"
sudo install -D -m 0755 "$ROOTFS/usr/local/bin/mocha-stack-optimizer" "/usr/local/bin/mocha-stack-optimizer"
sudo install -D -m 0755 "$ROOTFS/usr/local/bin/mocha-kernel-driver-gui-launch" "/usr/local/bin/mocha-kernel-driver-gui-launch"
sudo install -D -m 0755 "$ROOTFS/usr/local/bin/mocha-kernel-driver-updater" "/usr/local/bin/mocha-kernel-driver-updater"

sudo install -D -m 0755 "$ROOTFS/usr/share/applications/mocha-stack-optimizer.desktop" "/usr/share/applications/mocha-stack-optimizer.desktop"
sudo install -D -m 0755 "$ROOTFS/usr/share/applications/mocha-kernel-driver-updater.desktop" "/usr/share/applications/mocha-kernel-driver-updater.desktop"
sudo install -D -m 0755 "$ROOTFS/usr/share/applications/mocha-kernel-driver-gui.desktop" "/usr/share/applications/mocha-kernel-driver-gui.desktop"

sudo install -D -m 0755 "$ROOTFS/etc/skel/Desktop/Atualizar Kernel e Driver Mocha.desktop" "/etc/skel/Desktop/Atualizar Kernel e Driver Mocha.desktop"
sudo install -D -m 0755 "$ROOTFS/etc/skel/Desktop/mocha-stack-optimizer.desktop" "/etc/skel/Desktop/mocha-stack-optimizer.desktop"
sudo install -D -m 0755 "$ROOTFS/etc/skel/Desktop/mocha-kernel-driver-updater.desktop" "/etc/skel/Desktop/mocha-kernel-driver-updater.desktop"

sudo install -D -m 0755 "$ROOTFS/etc/skel/.local/share/applications/mocha-stack-optimizer.desktop" "/etc/skel/.local/share/applications/mocha-stack-optimizer.desktop"
sudo install -D -m 0755 "$ROOTFS/etc/skel/.local/share/applications/mocha-kernel-driver-updater.desktop" "/etc/skel/.local/share/applications/mocha-kernel-driver-updater.desktop"
sudo install -D -m 0755 "$ROOTFS/etc/skel/.local/share/applications/mocha-kernel-driver-gui.desktop" "/etc/skel/.local/share/applications/mocha-kernel-driver-gui.desktop"

mkdir -p "$HOME/Desktop" "$HOME/.local/share/applications"

install -m 0755 "$ROOTFS/etc/skel/Desktop/Atualizar Kernel e Driver Mocha.desktop" "$HOME/Desktop/Atualizar Kernel e Driver Mocha.desktop"
install -m 0755 "$ROOTFS/etc/skel/Desktop/mocha-stack-optimizer.desktop" "$HOME/Desktop/mocha-stack-optimizer.desktop"
install -m 0755 "$ROOTFS/etc/skel/.local/share/applications/mocha-stack-optimizer.desktop" "$HOME/.local/share/applications/mocha-stack-optimizer.desktop"
install -m 0755 "$ROOTFS/etc/skel/.local/share/applications/mocha-kernel-driver-updater.desktop" "$HOME/.local/share/applications/mocha-kernel-driver-updater.desktop"
install -m 0755 "$ROOTFS/etc/skel/.local/share/applications/mocha-kernel-driver-gui.desktop" "$HOME/.local/share/applications/mocha-kernel-driver-gui.desktop"

kbuildsycoca6 >/dev/null 2>&1 || true
kbuildsycoca5 >/dev/null 2>&1 || true

echo "OK: Mocha Stack Optimizer canônico instalado/reinstalado no sistema."
echo "Teste:"
echo "sudo /usr/local/lib/mocha/mocha-kernel-driver-engine check"
