#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ACTION="${1:-scan}"
HELPER="/usr/local/lib/mocha/kernel-driver/mocha-kernel-driver-action.sh"

CMD="$(printf '%q ' "$HELPER" "$ACTION")"
CMD="$CMD; echo; read -rp 'Pressione ENTER para fechar...' _"

if command -v konsole >/dev/null 2>&1; then
  exec konsole --title "Mocha - Kernel e Driver" --hold -e bash -lc "$CMD"
elif command -v xterm >/dev/null 2>&1; then
  exec xterm -T "Mocha - Kernel e Driver" -hold -e bash -lc "$CMD"
else
  exec bash -lc "$CMD"
fi
