#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd -- "$ROOT"

test -f Cargo.toml
test -f Cargo.lock
test -x scripts/install-local.sh
test -x scripts/validar-pacote-reconstruido.sh

if rg -n '^\[liquorix\]|liquorix\.net' .; then
    printf 'ERRO: repositório Liquorix/LQX encontrado no pacote.\n' >&2
    exit 1
fi

rg -q 'https://repo\.dieseloslab\.org/stable/x86_64' src/protocol.rs
rg -q 'BASE_URL=https://updates\.dieseloslab\.org' data/update/update-endpoint.conf
rg -q 'CHANNEL=stable' data/update/update-endpoint.conf
rg -q 'package\.starts_with\("linux-"\)' src/protocol.rs
rg -q 'protected_pending' src/bin/mocha-update-helper.rs

if command -v cargo >/dev/null 2>&1; then
    cargo fmt --all -- --check
    cargo test --lib
else
    printf 'AVISO: cargo não está disponível; validação estática concluída.\n'
fi

printf 'OK: pacote validado; fluxos e bloqueios conferidos.\n'
