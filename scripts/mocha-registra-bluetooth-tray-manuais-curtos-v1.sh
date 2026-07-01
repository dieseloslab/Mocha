#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

FAST="/media/mochafast/MochaArch"
INTERNO="/media/mochafast/MochaArch-Interno"
VMSTORE="/media/vmstore/MochaArch"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$FAST/auditorias/backup-bluetooth-tray-manuais-curtos-$STAMP"

mkdir -p "$BACKUP_DIR"

MANUAL_BLOCK="$(cat <<'MOCHA_MANUAL'
<!-- MOCHA:BLUETOOTH-TRAY-DUPLICADO:BEGIN -->

## Bluetooth na bandeja — evitar gerenciador duplicado

Regra de montagem: o Mocha deve iniciar com apenas um gerenciador visual de Bluetooth na bandeja do KDE.

Decisão canônica:

- manter `bluez` e `bluez-utils`;
- manter o serviço `bluetooth`;
- manter o applet nativo do KDE/BlueDevil;
- desativar o autostart do `blueman-applet`;
- não remover `blueman` por padrão, apenas impedir duplicidade visual e consumo desnecessário.

Script canônico:

    /media/mochafast/MochaArch/scripts/mocha-corrige-duplicidade-bluetooth-tray-v1.sh

Aplicação esperada na montagem:

- criar override em `$HOME/.config/autostart/blueman.desktop` com `Hidden=true`;
- criar o mesmo override em `/etc/skel/.config/autostart/blueman.desktop` para novos usuários;
- preservar `bluetooth.service` ativo;
- preservar BlueDevil/KDE como gerenciador principal.

Critério esperado no sistema instalado:

- apenas um ícone/gerenciador Bluetooth na bandeja;
- `systemctl is-active bluetooth` retorna `active`;
- `blueman-applet` não inicia automaticamente;
- Bluetooth continua funcional pelo KDE.

<!-- MOCHA:BLUETOOTH-TRAY-DUPLICADO:END -->
MOCHA_MANUAL
)"

update_manual() {
  local manual="$1"
  local tmp final base
  [ -f "$manual" ] || return 0

  base="$(basename "$manual")"
  tmp="$(mktemp)"
  final="$(mktemp)"

  sudo cp -a "$manual" "$BACKUP_DIR/$base.bak"

  awk '
    /<!-- MOCHA:BLUETOOTH-TRAY-DUPLICADO:BEGIN -->/ { skip=1; next }
    /<!-- MOCHA:BLUETOOTH-TRAY-DUPLICADO:END -->/ { skip=0; next }
    skip != 1 { print }
  ' "$manual" > "$tmp"

  {
    cat "$tmp"
    printf '\n'
    printf '%s\n' "$MANUAL_BLOCK"
    printf '\n'
  } > "$final"

  if [ -w "$manual" ]; then
    cat "$final" > "$manual"
  else
    sudo tee "$manual" < "$final" >/dev/null
  fi

  rm -f "$tmp" "$final"
  ok "Manual curto atualizado: $manual"
}

echo
echo "============================================================"
echo " Mocha — registrar Bluetooth nos manuais curtos"
echo "============================================================"
echo

shopt -s nullglob

declare -a CANDIDATOS=(
  "$FAST/MANUAL-CURTO-MONTAGEM-MOCHA-ARCH-KDE.md"
  "$FAST/manual/MANUAL-CURTO-MONTAGEM-MOCHA-ARCH-KDE.md"
  "$FAST/docs/MANUAL-CURTO-MONTAGEM-MOCHA-ARCH-KDE.md"
  "$INTERNO/ativo/MANUAL-CURTO-MONTAGEM-MOCHA-ARCH-KDE.md"
  "$VMSTORE/iso/manual/MANUAL-CURTO-MONTAGEM-MOCHA-ARCH-KDE.md"
)

for f in \
  "$FAST"/*CURTO*.md \
  "$FAST"/manual/*CURTO*.md \
  "$FAST"/docs/*CURTO*.md \
  "$INTERNO"/ativo/*CURTO*.md \
  "$VMSTORE"/iso/manual/*CURTO*.md
do
  [ -f "$f" ] && CANDIDATOS+=("$f")
done

declare -A VISTO=()
ATUALIZADOS=0

for manual in "${CANDIDATOS[@]}"; do
  [ -f "$manual" ] || continue
  [ -z "${VISTO[$manual]+x}" ] || continue
  VISTO[$manual]=1
  update_manual "$manual"
  ATUALIZADOS=$((ATUALIZADOS + 1))
done

if [ "$ATUALIZADOS" -eq 0 ]; then
  warn "Nenhum manual curto encontrado."
else
  ok "Total de manuais curtos atualizados: $ATUALIZADOS"
fi

echo
echo "============================================================"
echo " Conferência"
echo "============================================================"
echo

for manual in "${!VISTO[@]}"; do
  [ -f "$manual" ] || continue
  echo "--- $manual"
  grep -n "MOCHA:BLUETOOTH-TRAY-DUPLICADO" "$manual" || true
done

echo
echo "============================================================"
echo " Concluído"
echo "============================================================"
ok "Backup: $BACKUP_DIR"
