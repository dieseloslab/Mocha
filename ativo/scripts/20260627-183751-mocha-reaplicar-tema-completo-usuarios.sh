#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

BASE="/media/mochafast/MochaArch/ativo"
FINALIZER="$BASE/calamares/scripts/mocha-finaliza-tema-completo-usuarios.sh"
PAYLOAD="$BASE/calamares/payload/tema-completo"

if [ ! -x "$FINALIZER" ]; then
  echo "[FALHA] Finalizador não executável: $FINALIZER" >&2
  exit 1
fi

MOCHA_TEMA_PAYLOAD="$PAYLOAD" sudo -E "$FINALIZER" /

if command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 plasmashell || true
elif command -v qdbus6 >/dev/null 2>&1; then
  qdbus6 org.kde.plasmashell /PlasmaShell quit || true
else
  pkill -x plasmashell || true
fi

sleep 2

if command -v kstart6 >/dev/null 2>&1; then
  kstart6 plasmashell >/tmp/mocha-plasmashell-reaplica-tema-completo.log 2>&1 &
else
  nohup plasmashell >/tmp/mocha-plasmashell-reaplica-tema-completo.log 2>&1 &
fi

echo "OK — tema completo Mocha reaplicado na instalação atual."
