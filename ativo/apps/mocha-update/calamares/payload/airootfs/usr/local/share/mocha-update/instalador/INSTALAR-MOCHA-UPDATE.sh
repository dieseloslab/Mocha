#!/usr/bin/env bash
set -Eeuo pipefail

umask 022

BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PAYLOAD="${BASE}/calamares/payload/airootfs"
HASHES_PAYLOAD="${BASE}/calamares/SHA256SUMS-PAYLOAD-V76.txt"
PACOTES_RUNTIME="${BASE}/calamares/PACOTES-RUNTIME-OBSERVADOS.txt"
DATA="$(date '+%Y%m%d-%H%M%S')"
BACKUP="/var/backups/mocha/mocha-update-instalacao-manual-${DATA}"
INSTALAR_DEPENDENCIAS=1
COPIA_INICIADA=0
CONCLUIDO=0
TIMER_JA_HABILITADO=0

usage()
{
    printf '%s\n' \
        "Uso: sudo bash $0 [--sem-instalar-dependencias]" \
        '' \
        'Sem opção: instala somente pacotes ausentes usando o pacman e' \
        'reinstala o runtime validado do Mocha Update.' \
        '' \
        '--sem-instalar-dependencias: exige que todas as dependências já' \
        'estejam instaladas; útil para reinstalação totalmente offline.'
}

rollback()
{
    local rc="$?"

    trap - EXIT HUP INT TERM

    if (( rc != 0 && CONCLUIDO == 0 && COPIA_INICIADA == 1 )); then
        printf '\nERRO: instalação interrompida; restaurando arquivos anteriores.\n' >&2

        if [[ -f "$BACKUP/arquivos-novos.bin" ]]; then
            while IFS= read -r -d '' arquivo_novo; do
                rm -f -- "$arquivo_novo" || true
            done < "$BACKUP/arquivos-novos.bin"
        fi

        if [[ -d "$BACKUP/rootfs" ]]; then
            rsync -aH -- "$BACKUP/rootfs/" / || true
        fi

        systemctl daemon-reload 2>/dev/null || true

        if (( TIMER_JA_HABILITADO == 0 )); then
            systemctl disable --now \
                mocha-update-snapshot-index.timer \
                >/dev/null 2>&1 || true
        fi

        printf 'BACKUP_PRESERVADO=%s\n' "$BACKUP" >&2
    fi

    exit "$rc"
}

trap rollback EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

while (( $# > 0 )); do
    case "$1" in
        --sem-instalar-dependencias)
            INSTALAR_DEPENDENCIAS=0
            ;;
        -h|--help)
            usage
            CONCLUIDO=1
            exit 0
            ;;
        *)
            printf 'ERRO: opção desconhecida: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

if (( EUID != 0 )); then
    printf 'ERRO: execute com sudo: sudo bash %s\n' "$0" >&2
    exit 1
fi

[[ "$(uname -m)" == "x86_64" ]] || {
    printf 'ERRO: os binários deste checkpoint são somente para x86_64.\n' >&2
    exit 1
}

for comando in \
    awk cmp find install ldd pacman pgrep rm rsync sha256sum sort systemctl
do
    command -v "$comando" >/dev/null 2>&1 || {
        printf 'ERRO: comando obrigatório ausente: %s\n' "$comando" >&2
        exit 1
    }
done

[[ -d "$PAYLOAD" ]] || {
    printf 'ERRO: payload ausente: %s\n' "$PAYLOAD" >&2
    exit 1
}

[[ -f "$HASHES_PAYLOAD" ]] || {
    printf 'ERRO: arquivo de hashes ausente: %s\n' "$HASHES_PAYLOAD" >&2
    exit 1
}

[[ -f "$PACOTES_RUNTIME" ]] || {
    printf 'ERRO: inventário de pacotes ausente: %s\n' "$PACOTES_RUNTIME" >&2
    exit 1
}

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
        printf 'ERRO: componente obrigatório ausente: %s\n' "$arquivo" >&2
        exit 1
    }
done

[[ ! -e "$PAYLOAD/var/lib/mocha-update" ]] || {
    printf 'ERRO: o payload contém estado ou snapshots de outra máquina.\n' >&2
    exit 1
}

if pgrep -x mocha-update >/dev/null 2>&1; then
    printf 'ERRO: feche o Mocha Update antes da reinstalação.\n' >&2
    exit 1
fi

if systemctl is-enabled --quiet mocha-update-snapshot-index.timer \
    2>/dev/null; then
    TIMER_JA_HABILITADO=1
fi

printf '%s\n' \
    '============================================================' \
    'MOCHA UPDATE — INSTALAÇÃO MANUAL SEM CALAMARES' \
    '============================================================'
printf 'BASE=%s\n' "$BASE"
printf 'PAYLOAD=%s\n' "$PAYLOAD"
printf 'BACKUP=%s\n' "$BACKUP"
printf 'INSTALAR_DEPENDENCIAS=%s\n' "$INSTALAR_DEPENDENCIAS"

printf '\nValidando todos os arquivos do payload...\n'
(
    cd -- "$PAYLOAD"
    sha256sum --check --strict "$HASHES_PAYLOAD"
)

mapfile -t PACOTES < <(
    awk '!/^[[:space:]]*(#|$)/ { print }' "$PACOTES_RUNTIME" |
        sort -u
)

(( ${#PACOTES[@]} > 0 )) || {
    printf 'ERRO: o inventário de pacotes está vazio.\n' >&2
    exit 1
}

PACOTES_AUSENTES=()
for pacote in "${PACOTES[@]}"; do
    pacman -Q -- "$pacote" >/dev/null 2>&1 ||
        PACOTES_AUSENTES+=("$pacote")
done

if (( ${#PACOTES_AUSENTES[@]} > 0 )); then
    printf '\nPACOTES_AUSENTES=%s\n' "${#PACOTES_AUSENTES[@]}"
    printf '  %s\n' "${PACOTES_AUSENTES[@]}"

    if (( INSTALAR_DEPENDENCIAS == 0 )); then
        printf '%s\n' \
            'ERRO: faltam dependências e a instalação automática foi desativada.' >&2
        exit 1
    fi

    printf '\nInstalando somente as dependências ausentes...\n'
    pacman -S --needed --noconfirm -- "${PACOTES_AUSENTES[@]}"
else
    printf 'DEPENDENCIAS_RUNTIME=JA_INSTALADAS\n'
fi

install -d -o root -g root -m 0700 "$BACKUP/rootfs"
: > "$BACKUP/arquivos-novos.bin"

while IFS= read -r -d '' arquivo_payload; do
    relativo="${arquivo_payload#"$PAYLOAD"/}"
    arquivo_sistema="/${relativo}"

    if [[ -e "$arquivo_sistema" || -L "$arquivo_sistema" ]]; then
        rsync -aR -- "$arquivo_sistema" "$BACKUP/rootfs/"
    else
        printf '%s\0' "$arquivo_sistema" >> "$BACKUP/arquivos-novos.bin"
    fi
done < <(
    find "$PAYLOAD" \( -type f -o -type l \) -print0 |
        sort -z
)

COPIA_INICIADA=1
rsync -aH --chown=0:0 -- "$PAYLOAD/" /

install -d -o root -g root -m 0755 \
    /var/lib/mocha-update \
    /var/lib/mocha-update/snapshot-index \
    /var/log/mocha-update
install -d -o root -g root -m 0700 \
    /var/lib/mocha-update/rollbacks

systemctl daemon-reload
systemctl enable --now mocha-update-snapshot-index.timer

command -v update-desktop-database >/dev/null 2>&1 &&
    update-desktop-database /usr/share/applications || true
command -v gtk-update-icon-cache >/dev/null 2>&1 &&
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true

for par in \
    "$PAYLOAD/usr/bin/mocha-update:/usr/bin/mocha-update" \
    "$PAYLOAD/usr/lib/mocha-update/mocha-update-helper:/usr/lib/mocha-update/mocha-update-helper" \
    "$PAYLOAD/usr/lib/mocha-update/mocha-snapshot-admin:/usr/lib/mocha-update/mocha-snapshot-admin"
do
    origem="${par%%:*}"
    instalado="${par#*:}"

    cmp -s -- "$origem" "$instalado" || {
        printf 'ERRO: o componente instalado divergiu: %s\n' "$instalado" >&2
        exit 1
    }

    [[ -x "$instalado" ]] || {
        printf 'ERRO: o componente não é executável: %s\n' "$instalado" >&2
        exit 1
    }

    saida_ldd="$(ldd "$instalado" 2>&1 || true)"
    [[ "$saida_ldd" != *'not found'* ]] || {
        printf 'ERRO: biblioteca dinâmica ausente em %s\n' "$instalado" >&2
        printf '%s\n' "$saida_ldd" >&2
        exit 1
    }
done

systemctl is-enabled --quiet mocha-update-snapshot-index.timer || {
    printf 'ERRO: o timer de índice não ficou habilitado.\n' >&2
    exit 1
}

CONCLUIDO=1
printf '\n%s\n' \
    '============================================================' \
    'RESULTADO FINAL' \
    '============================================================'
printf '%s\n' \
    'RESULTADO=SUCESSO' \
    'INSTALACAO_SEM_CALAMARES=SIM' \
    'PAYLOAD_VALIDADO_POR_SHA256=SIM' \
    'DEPENDENCIAS_VALIDAS=SIM' \
    'APP_INSTALADO=SIM' \
    'HELPER_INSTALADO=SIM' \
    'SNAPSHOT_ADMIN_INSTALADO=SIM' \
    'TIMER_HABILITADO=SIM' \
    'ESTADO_ANTERIOR_PRESERVADO=SIM' \
    'SNAPSHOTS_ANTERIORES_PRESERVADOS=SIM'
printf 'BACKUP=%s\n' "$BACKUP"
