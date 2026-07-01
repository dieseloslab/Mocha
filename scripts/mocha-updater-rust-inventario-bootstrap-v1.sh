#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ROOT="/media/mochafast/MochaArch"
TOOL="$ROOT/tools/mocha-updater-rs"

if ! command -v cargo >/dev/null 2>&1; then
  echo "[ERRO] cargo não encontrado. Instale Rust/cargo antes de compilar o updater."
  exit 1
fi

cd "$TOOL"
cargo build --release
"$TOOL/target/release/mocha-updater" inventario
