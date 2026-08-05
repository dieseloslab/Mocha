#!/usr/bin/env bash
set -Eeuo pipefail

CATALOGO="${1:?uso: $0 CATALOGO ASSINATURA KEYRING ALLOWLIST ESTADO [ARQUITETURA]}"
ASSINATURA="${2:?assinatura ausente}"
KEYRING="${3:?keyring ausente}"
ALLOWLIST="${4:?allowlist ausente}"
ESTADO="${5:?estado instalado ausente}"
ARQUITETURA="${6:-$(uname -m)}"
PROJETO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
VALIDADOR="$PROJETO/target/release/mocha-update-catalog-check"

for arquivo in "$CATALOGO" "$ASSINATURA" "$KEYRING" "$ALLOWLIST" "$ESTADO"; do
    [[ -f "$arquivo" ]] || {
        printf 'ERRO=arquivo ausente: %s\n' "$arquivo" >&2
        exit 1
    }
done
command -v gpgv >/dev/null 2>&1 || {
    printf 'ERRO=gpgv ausente\n' >&2
    exit 1
}
[[ -x "$VALIDADOR" ]] || {
    printf 'ERRO=validador não compilado: %s\n' "$VALIDADOR" >&2
    exit 1
}

gpgv --keyring "$KEYRING" "$ASSINATURA" "$CATALOGO"
exec "$VALIDADOR" "$CATALOGO" "$ALLOWLIST" "$ESTADO" "$ARQUITETURA"
