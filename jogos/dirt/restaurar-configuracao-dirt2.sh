#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$BASE/hardware_settings_config.xml"

DEST_DIR="$HOME/.local/share/Steam/steamapps/compatdata/690790/pfx/drive_c/users/steamuser/Documents/My Games/DiRT Rally 2.0/hardwaresettings"
DEST_CFG="$DEST_DIR/hardware_settings_config.xml"

TS="$(date +%Y%m%d-%H%M%S)"

echo "==> MochaArch: restaurar configuração do DiRT Rally 2.0"
echo

if pgrep -afi 'dirtrally2|dirtrally2.exe|DiRT Rally 2.0' >/dev/null 2>&1; then
    echo "ERRO: o DiRT Rally 2.0 parece estar aberto."
    echo "Feche o jogo antes de restaurar."
    exit 1
fi

if [ ! -f "$BACKUP" ]; then
    echo "ERRO: backup canônico ausente:"
    echo "$BACKUP"
    exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
    echo "ERRO: o prefixo Proton do jogo ainda não existe."
    echo
    echo "Depois de formatar:"
    echo "1. Instale o DiRT Rally 2.0 pela Steam."
    echo "2. Abra o jogo uma vez."
    echo "3. Feche o jogo normalmente."
    echo "4. Execute este restaurador novamente."
    exit 1
fi

if [ -f "$DEST_CFG" ]; then
    SEGURANCA="$DEST_DIR/hardware_settings_config.antes-restauracao-${TS}.xml"
    cp -a -- "$DEST_CFG" "$SEGURANCA"
    echo "==> Configuração atual preservada em:"
    echo "$SEGURANCA"
    echo
fi

echo "==> Restaurando backup canônico"
cp -a -- "$BACKUP" "$DEST_CFG"

echo "==> Validando restauração"
cmp --silent "$BACKUP" "$DEST_CFG"

echo
echo "OK: configuração restaurada."
echo "Origem: $BACKUP"
echo "Destino: $DEST_CFG"
echo
sha256sum "$BACKUP" "$DEST_CFG"
