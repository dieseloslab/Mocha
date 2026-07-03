#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

APP="/media/mochafast/MochaArch/apps/mocha-updater"
FRONT="${APP}/frontend/mocha-updater-qt.py"
ACTION="${APP}/scripts/mocha-updater-action-v1.sh"

echo "Mocha Updater canonico:"
echo "  Frontend Qt: $FRONT"
echo "  Backend action: $ACTION"
echo "  Kernel recomendado: linux-lqx + linux-lqx-headers"
echo "  NVIDIA recomendado: nvidia-open-dkms + nvidia-utils + lib32-nvidia-utils"
echo

python -m py_compile "$FRONT"
bash "$ACTION" system-check
bash "$ACTION" kernel-check

echo
echo "[OK] Mocha Updater LQX/DKMS validado."
