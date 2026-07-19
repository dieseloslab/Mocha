#!/usr/bin/env bash
set +e

export LC_ALL=C

TARGET_USER="${1:-${SUDO_USER:-${USER:-}}}"
SOURCE="/usr/local/share/mocha/branding/avatar-source.png"
SOURCE_SHA="d5f354db7fda50e81bf226ff08674ea6ad146a5cd7620eb37dff2e66b01a793b"

STAMP="$(date '+%Y%m%d-%H%M%S')"
AUDIT="${MOCHA_AUDIT_DIR:-/var/tmp/mocha-identidade-sistema-avatar-$STAMP}"
TMP="$AUDIT/tmp"
REPORT="$AUDIT/RELATORIO.txt"

FAIL=0

section() {
    printf '\n%s\n%s\n%s\n' \
        '================================================================' "$1" \
        '================================================================'
}

if [ "$(id -u)" -ne 0 ]; then
    printf '%s\n' 'ERRO: execute como root.'
    exit 1
fi

mkdir -p "$TMP" || {
    printf 'ERRO: não foi possível criar %s\n' "$TMP"
    exit 1
}

exec > >(tee "$REPORT") 2>&1

section 'APLICAÇÃO DA IDENTIDADE MOCHA'

printf 'Usuário alvo: %s\n' "$TARGET_USER"
printf 'Avatar-fonte: %s\n' "$SOURCE"
printf 'Auditoria: %s\n' "$AUDIT"

PASSWD_LINE="$(
    getent passwd "$TARGET_USER" 2>/dev/null ||
        true
)"

if [ -z "$PASSWD_LINE" ]; then
    printf 'ERRO: usuário inexistente: %s\n' "$TARGET_USER"
    exit 1
fi

TARGET_HOME="$(
    printf '%s\n' "$PASSWD_LINE" |
        awk -F: '{print $6}'
)"

TARGET_GID="$(
    printf '%s\n' "$PASSWD_LINE" |
        awk -F: '{print $4}'
)"

TARGET_GROUP="$(
    getent group "$TARGET_GID" |
        awk -F: '{print $1}'
)"

if [ ! -d "$TARGET_HOME" ]; then
    printf 'ERRO: HOME ausente: %s\n' "$TARGET_HOME"
    exit 1
fi

if [ -z "$TARGET_GROUP" ]; then
    printf '%s\n' 'ERRO: grupo primário não localizado.'
    exit 1
fi

if [ ! -f "$SOURCE" ]; then
    printf 'ERRO: avatar-fonte ausente: %s\n' "$SOURCE"
    exit 1
fi

CURRENT_SHA="$(
    sha256sum "$SOURCE" |
        awk '{print $1}'
)"

if [ "$CURRENT_SHA" != "$SOURCE_SHA" ]; then
    printf '%s\n' 'ERRO: hash do avatar-fonte inválido.'
    exit 1
fi

section '1. BACKUPS DO ESTADO ANTERIOR'

backup() {
    SRC="$1"
    NAME="$2"

    if [ -e "$SRC" ] || [ -L "$SRC" ]; then
        cp -a --no-dereference \
            "$SRC" \
            "$AUDIT/$NAME" ||
            FAIL=1

        printf 'BACKUP=%s -> %s\n' \
            "$SRC" \
            "$AUDIT/$NAME"
    else
        printf 'BACKUP_NAO_NECESSARIO=%s\n' "$SRC"
    fi
}

backup \
    /etc/os-release \
    etc-os-release.before

backup \
    /etc/os-release.mocha \
    etc-os-release-mocha.before

backup \
    "$TARGET_HOME/.face.icon" \
    user-face-icon.before

backup \
    "$TARGET_HOME/.face" \
    user-face.before

backup \
    /etc/skel/.face.icon \
    skel-face-icon.before

backup \
    /etc/skel/.face \
    skel-face.before

backup \
    "/usr/share/sddm/faces/$TARGET_USER.face.icon" \
    sddm-face.before

backup \
    "/var/lib/AccountsService/icons/$TARGET_USER" \
    accounts-icon.before

backup \
    "/var/lib/AccountsService/users/$TARGET_USER" \
    accounts-user.before

if [ "$FAIL" -ne 0 ]; then
    printf '%s\n' 'ERRO: um ou mais backups falharam.'
    exit 1
fi

section '2. PREPARAÇÃO DO AVATAR'

AV512="$TMP/avatar-512.png"
AV256="$TMP/avatar-256.png"
CONVERTER="cópia sem redimensionamento"

if command -v magick >/dev/null 2>&1; then
    magick \
        "$SOURCE" \
        -resize 512x512 \
        "$AV512" &&
    magick \
        "$SOURCE" \
        -resize 256x256 \
        "$AV256" ||
        FAIL=1

    CONVERTER="magick"

elif command -v convert >/dev/null 2>&1; then
    convert \
        "$SOURCE" \
        -resize 512x512 \
        "$AV512" &&
    convert \
        "$SOURCE" \
        -resize 256x256 \
        "$AV256" ||
        FAIL=1

    CONVERTER="convert"

else
    cp "$SOURCE" "$AV512" ||
        FAIL=1

    cp "$SOURCE" "$AV256" ||
        FAIL=1
fi

if [ ! -s "$AV512" ] || [ ! -s "$AV256" ]; then
    FAIL=1
fi

printf 'CONVERSOR=%s\n' "$CONVERTER"

if [ -s "$AV512" ]; then
    file "$AV512"
    sha256sum "$AV512"
fi

if [ -s "$AV256" ]; then
    file "$AV256"
    sha256sum "$AV256"
fi

if [ "$FAIL" -ne 0 ]; then
    printf '%s\n' 'ERRO: preparação do avatar falhou.'
    exit 1
fi

section '3. LOGO DO SISTEMA'

install -Dm644 \
    "$SOURCE" \
    /usr/local/share/mocha/branding/avatar-source.png ||
    FAIL=1

install -Dm644 \
    "$AV256" \
    /usr/local/share/mocha/branding/mocha.png ||
    FAIL=1

install -Dm644 \
    "$AV256" \
    /usr/share/icons/hicolor/256x256/apps/mocha.png ||
    FAIL=1

install -Dm644 \
    "$AV256" \
    /usr/share/pixmaps/mocha.png ||
    FAIL=1

if [ "$FAIL" -ne 0 ]; then
    printf '%s\n' 'ERRO: instalação do logo falhou.'
    exit 1
fi

section '4. IDENTIDADE EM OS-RELEASE'

BASE="/usr/lib/os-release"

if [ ! -f "$BASE" ]; then
    BASE="/etc/os-release"
fi

if [ ! -f "$BASE" ]; then
    printf '%s\n' 'ERRO: os-release base ausente.'
    exit 1
fi

OS_NEW="$TMP/os-release.mocha"

awk '
BEGIN {
    count=7

    order[1]="NAME"
    order[2]="PRETTY_NAME"
    order[3]="VARIANT"
    order[4]="VARIANT_ID"
    order[5]="LOGO"
    order[6]="HOME_URL"
    order[7]="SUPPORT_URL"

    value["NAME"]="\"Mocha\""

    value["PRETTY_NAME"]="\"Mocha (base Arch Linux) — Produzido por DieselOSLab — projeto de finalidade beneficente\""

    value["VARIANT"]="\"Mocha\""
    value["VARIANT_ID"]="mocha"
    value["LOGO"]="mocha"

    value["HOME_URL"]="\"https://dieseloslab.org/\""
    value["SUPPORT_URL"]="\"https://dieseloslab.org/\""
}
{
    key=$0
    sub(/=.*/, "", key)

    if (key in value) {
        if (!seen[key]) {
            print key "=" value[key]
            seen[key]=1
        }

        next
    }

    print
}
END {
    for (i=1; i<=count; i++) {
        key=order[i]

        if (!seen[key]) {
            print key "=" value[key]
        }
    }
}
' "$BASE" > "$OS_NEW" ||
    FAIL=1

grep -Eq '^ID="?arch"?$' "$OS_NEW" ||
    FAIL=1

grep -Fqx \
    'LOGO=mocha' \
    "$OS_NEW" ||
    FAIL=1

grep -Fqx \
    'PRETTY_NAME="Mocha (base Arch Linux) — Produzido por DieselOSLab — projeto de finalidade beneficente"' \
    "$OS_NEW" ||
    FAIL=1

if [ "$FAIL" -ne 0 ]; then
    printf '%s\n' \
        'ERRO: validação do novo os-release falhou.'
    exit 1
fi

install -Dm644 \
    "$OS_NEW" \
    /etc/os-release.mocha ||
    exit 1

LINK_TMP="/etc/.os-release.mocha-$STAMP"

rm -f "$LINK_TMP"

ln -s \
    os-release.mocha \
    "$LINK_TMP" ||
    exit 1

mv -Tf \
    "$LINK_TMP" \
    /etc/os-release ||
    exit 1

section '5. AVATAR DO USUÁRIO E DO SDDM'

if [ -d "$TARGET_HOME/.face" ] ||
   [ -d /etc/skel/.face ]; then

    printf '%s\n' \
        'ERRO: .face é diretório; alteração bloqueada.'

    exit 1
fi

install -Dm644 \
    -o "$TARGET_USER" \
    -g "$TARGET_GROUP" \
    "$AV512" \
    "$TARGET_HOME/.face.icon" ||
    FAIL=1

ln -sfn \
    .face.icon \
    "$TARGET_HOME/.face" ||
    FAIL=1

chown -h \
    "$TARGET_USER:$TARGET_GROUP" \
    "$TARGET_HOME/.face" ||
    FAIL=1

install -Dm644 \
    "$AV512" \
    /etc/skel/.face.icon ||
    FAIL=1

ln -sfn \
    .face.icon \
    /etc/skel/.face ||
    FAIL=1

install -Dm644 \
    "$AV512" \
    "/usr/share/sddm/faces/$TARGET_USER.face.icon" ||
    FAIL=1

section '6. ACCOUNTSSERVICE'

ACCOUNTS_ICON="/var/lib/AccountsService/icons/$TARGET_USER"
ACCOUNTS_USER="/var/lib/AccountsService/users/$TARGET_USER"
ACCOUNTS_NEW="$TMP/accounts-user"

install -Dm644 \
    "$AV512" \
    "$ACCOUNTS_ICON" ||
    FAIL=1

mkdir -p \
    /var/lib/AccountsService/users ||
    FAIL=1

if [ -f "$ACCOUNTS_USER" ]; then
    awk -v icon="$ACCOUNTS_ICON" '
    BEGIN {
        inside=0
        found=0
        written=0
    }

    /^\[User\]$/ {
        print
        inside=1
        found=1
        next
    }

    /^\[/ {
        if (inside && !written) {
            print "Icon=" icon
            written=1
        }

        inside=0
        print
        next
    }

    {
        if (inside && /^Icon=/) {
            if (!written) {
                print "Icon=" icon
                written=1
            }

            next
        }

        print
    }

    END {
        if (inside && !written) {
            print "Icon=" icon
        }

        if (!found) {
            print "[User]"
            print "Icon=" icon
        }
    }
    ' "$ACCOUNTS_USER" > "$ACCOUNTS_NEW" ||
        FAIL=1
else
    printf '[User]\nIcon=%s\n' \
        "$ACCOUNTS_ICON" \
        > "$ACCOUNTS_NEW" ||
        FAIL=1
fi

if [ "$FAIL" -eq 0 ]; then
    install -Dm600 \
        "$ACCOUNTS_NEW" \
        "$ACCOUNTS_USER" ||
        FAIL=1
fi

section '7. VALIDAÇÃO TÉCNICA'

grep -E \
    '^(NAME|PRETTY_NAME|ID|ID_LIKE|VARIANT|VARIANT_ID|LOGO|HOME_URL|SUPPORT_URL)=' \
    /etc/os-release ||
    FAIL=1

for P in \
    /usr/local/share/mocha/branding/avatar-source.png \
    /usr/local/share/mocha/branding/mocha.png \
    /usr/share/icons/hicolor/256x256/apps/mocha.png \
    /usr/share/pixmaps/mocha.png \
    "$TARGET_HOME/.face.icon" \
    "$TARGET_HOME/.face" \
    /etc/skel/.face.icon \
    /etc/skel/.face \
    "/usr/share/sddm/faces/$TARGET_USER.face.icon" \
    "$ACCOUNTS_ICON" \
    "$ACCOUNTS_USER"
do
    if [ -e "$P" ] || [ -L "$P" ]; then
        stat -c \
            'tipo=%F modo=%a dono=%U grupo=%G bytes=%s caminho=%n' \
            "$P" \
            2>/dev/null ||
        printf 'link=%s -> %s\n' \
            "$P" \
            "$(readlink "$P")"
    else
        printf 'ERRO: alvo ausente: %s\n' "$P"
        FAIL=1
    fi
done

grep -Fqx \
    "Icon=$ACCOUNTS_ICON" \
    "$ACCOUNTS_USER" ||
    FAIL=1

INSTALLED_SHA="$(
    sha256sum \
        /usr/local/share/mocha/branding/avatar-source.png |
        awk '{print $1}'
)"

if [ "$INSTALLED_SHA" != "$SOURCE_SHA" ]; then
    printf '%s\n' \
        'ERRO: avatar-fonte instalado diverge do aprovado.'
    FAIL=1
fi

section 'VEREDITO'

printf 'USUARIO=%s\n' "$TARGET_USER"
printf 'HOME=%s\n' "$TARGET_HOME"
printf 'CONVERSOR=%s\n' "$CONVERTER"
printf 'FAIL=%s\n' "$FAIL"
printf 'RELATORIO=%s\n' "$REPORT"

if [ "$FAIL" -eq 0 ]; then
    printf '%s\n' 'APLICACAO_TECNICA=OK'
    printf '%s\n' \
        'VALIDACAO_VISUAL=PENDENTE_NO_SOBRE_E_NO_SDDM'
else
    printf '%s\n' 'APLICACAO_TECNICA=FALHOU'
fi

exit "$FAIL"
