#!/usr/bin/env bash
set -Eeuo pipefail

if (( EUID != 0 )); then
    printf 'ERRO: este instalador deve ser executado pelo Calamares como root.\n' >&2
    exit 1
fi

if (( $# != 1 )); then
    printf 'Uso: %s /ponto/de/montagem/do/sistema-instalado\n' "$0" >&2
    exit 1
fi

BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PAYLOAD="${BASE}/payload/airootfs"
ALVO="$(realpath -e -- "$1")"

[[ "$ALVO" != "/" ]] || {
    printf 'ERRO: recusa de instalação sobre o sistema live ou host (/).\n' >&2
    exit 1
}

[[ -d "$ALVO/usr" && -d "$ALVO/etc" && -d "$ALVO/var" ]] || {
    printf 'ERRO: raiz-alvo inválida ou ainda não montada: %s\n' "$ALVO" >&2
    exit 1
}

for comando in install realpath rsync systemctl; do
    command -v "$comando" >/dev/null 2>&1 || {
        printf 'ERRO: comando obrigatório ausente no ambiente live: %s\n' \
            "$comando" >&2
        exit 1
    }
done

for arquivo in \
    "$PAYLOAD/usr/bin/mocha-update" \
    "$PAYLOAD/usr/lib/mocha-update/mocha-update-helper" \
    "$PAYLOAD/usr/lib/mocha-update/mocha-snapshot-admin" \
    "$PAYLOAD/usr/lib/systemd/system/mocha-update-snapshot-index.service" \
    "$PAYLOAD/usr/lib/systemd/system/mocha-update-snapshot-index.timer" \
    "$PAYLOAD/usr/share/applications/org.mocha.update.desktop" \
    "$PAYLOAD/usr/share/polkit-1/actions/org.mocha.update.policy" \
    "$PAYLOAD/usr/share/polkit-1/actions/org.mocha.snapshot.policy" \
    "$PAYLOAD/usr/share/libalpm/hooks/05-mocha-snapshot-before.hook"
do
    [[ -e "$arquivo" ]] || {
        printf 'ERRO: payload incompleto: %s\n' "$arquivo" >&2
        exit 1
    }
done

[[ ! -e "$PAYLOAD/var/lib/mocha-update" ]] || {
    printf 'ERRO: o payload contém estado específico da máquina de origem.\n' >&2
    exit 1
}

rsync -aH --chown=0:0 -- "$PAYLOAD/" "$ALVO/"

install -d -o root -g root -m 0755 \
    "$ALVO/var/lib/mocha-update" \
    "$ALVO/var/lib/mocha-update/snapshot-index" \
    "$ALVO/var/log/mocha-update"
install -d -o root -g root -m 0700 \
    "$ALVO/var/lib/mocha-update/rollbacks"

systemctl --root="$ALVO" enable mocha-update-snapshot-index.timer

[[ -x "$ALVO/usr/bin/mocha-update" ]] || {
    printf 'ERRO: binário final não é executável.\n' >&2
    exit 1
}

[[ -x "$ALVO/usr/lib/mocha-update/mocha-update-helper" ]] || {
    printf 'ERRO: helper final não é executável.\n' >&2
    exit 1
}

[[ -x "$ALVO/usr/lib/mocha-update/mocha-snapshot-admin" ]] || {
    printf 'ERRO: administrador de snapshots final não é executável.\n' >&2
    exit 1
}

printf 'RESULTADO=SUCESSO\n'
printf 'ALVO=%s\n' "$ALVO"
printf 'TIMER_HABILITADO=mocha-update-snapshot-index.timer\n'
printf 'ESTADO_E_SNAPSHOTS_DA_MAQUINA_DE_ORIGEM_COPIADOS=NAO\n'
