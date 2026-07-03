#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

SUDO_KEEPALIVE_PID=""
(
  while true; do
    sudo -n true || exit
    sleep 30
  done
) &
SUDO_KEEPALIVE_PID="$!"

cleanup() {
  set +e
  [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

ok()   { printf '[OK] %s\n' "$*"; }
info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*" >&2; exit 1; }

BASE="/media/mochafast/MochaArch"
ATIVO="$BASE/ativo"
LOGDIR="$ATIVO/logs"
TS="$(date +%Y%m%d-%H%M%S)"
LOG="$LOGDIR/$TS-define-lqx-padrao-boot-v3.log"
SCRIPT_DEST="$BASE/scripts/mocha-define-lqx-padrao-boot-v3.sh"
MANUAL="/media/mochafast/MochaArch-Interno/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"

mkdir -p "$LOGDIR"
exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo " Mocha — definir Liquorix/linux-lqx como PADRÃO REAL do boot"
echo "============================================================"
echo "Log: $LOG"
echo

[ -d /boot/grub ] || fail "Diretório /boot/grub não existe. Este script é para GRUB."
[ -f /etc/default/grub ] || fail "Arquivo /etc/default/grub não encontrado."
[ -e /boot/vmlinuz-linux-lqx ] || fail "Kernel /boot/vmlinuz-linux-lqx não encontrado. Instale/valide o linux-lqx primeiro."

command -v grub-mkconfig >/dev/null 2>&1 || fail "grub-mkconfig não encontrado."
command -v grub-editenv >/dev/null 2>&1 || fail "grub-editenv não encontrado."

BKPDIR="/var/backups/mocha-lqx-boot-padrao-$TS"
sudo mkdir -p "$BKPDIR"

sudo cp -a /etc/default/grub "$BKPDIR/grub.default.bak"
[ -f /boot/grub/grub.cfg ] && sudo cp -a /boot/grub/grub.cfg "$BKPDIR/grub.cfg.bak" || true
[ -f /boot/grub/grubenv ] && sudo cp -a /boot/grub/grubenv "$BKPDIR/grubenv.bak" || true

ok "Backup salvo em $BKPDIR"

info "Normalizando /etc/default/grub para Liquorix como primeira entrada..."

TMP_GRUB="$(mktemp)"

sudo awk '
  {
    line=$0
    key=line
    sub(/^[[:space:]]*/, "", key)
    sub(/=.*/, "", key)

    if (key == "GRUB_DEFAULT") next
    if (key == "GRUB_SAVEDEFAULT") next
    if (key == "GRUB_TOP_LEVEL") next

    print line
  }
' /etc/default/grub > "$TMP_GRUB"

cat >> "$TMP_GRUB" <<'EOF'

# Mocha: Liquorix/linux-lqx como kernel padrão real de boot
GRUB_TOP_LEVEL="/boot/vmlinuz-linux-lqx"
GRUB_DEFAULT=0
GRUB_SAVEDEFAULT=false
EOF

sudo install -m 0644 "$TMP_GRUB" /etc/default/grub
rm -f "$TMP_GRUB"

echo
echo "Trecho ativo de /etc/default/grub:"
grep -E '^(GRUB_DEFAULT|GRUB_SAVEDEFAULT|GRUB_TOP_LEVEL)=' /etc/default/grub || true
echo

info "Regenerando /boot/grub/grub.cfg..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

[ -f /boot/grub/grub.cfg ] || fail "grub.cfg não foi gerado."

if [ ! -f /boot/grub/grubenv ]; then
  info "Criando /boot/grub/grubenv..."
  sudo grub-editenv /boot/grub/grubenv create
fi

info "Limpando saved_entry antigo para não manter kernel anterior como padrão..."
sudo grub-editenv /boot/grub/grubenv unset saved_entry || true
sudo grub-editenv /boot/grub/grubenv unset next_entry || true

info "Validando primeira entrada real do GRUB..."

FIRST_MENUENTRY="$(
  sudo awk '
    /^[[:space:]]*menuentry / {
      print
      exit
    }
  ' /boot/grub/grub.cfg
)"

FIRST_LINUX_LINE="$(
  sudo awk '
    /^[[:space:]]*linux[[:space:]]/ {
      print
      exit
    }
  ' /boot/grub/grub.cfg
)"

echo
echo "Primeira menuentry:"
echo "  ${FIRST_MENUENTRY:-NÃO ENCONTRADA}"
echo
echo "Primeira linha linux:"
echo "  ${FIRST_LINUX_LINE:-NÃO ENCONTRADA}"
echo

printf '%s\n' "$FIRST_LINUX_LINE" | grep -q 'vmlinuz-linux-lqx' \
  || fail "A primeira entrada de boot ainda não aponta para vmlinuz-linux-lqx."

ok "A primeira entrada real do GRUB aponta para linux-lqx."

echo
echo "Validação dos kernels encontrados no grub.cfg:"
echo "------------------------------------------------------------"
sudo grep -nE "menuentry |vmlinuz-linux" /boot/grub/grub.cfg | head -n 60 || true
echo "------------------------------------------------------------"

echo
echo "Pacotes lqx instalados:"
pacman -Q linux-lqx linux-lqx-headers 2>/dev/null || warn "Não consegui listar linux-lqx/linux-lqx-headers via pacman -Q."

echo
echo "grubenv atual:"
sudo grub-editenv /boot/grub/grubenv list || true

echo
info "Salvando script canônico no projeto..."
install -Dm755 /tmp/mocha-define-lqx-padrao-boot-v3.sh "$SCRIPT_DEST"
ok "Script salvo em: $SCRIPT_DEST"

if [ -f "$MANUAL" ]; then
  if ! grep -q 'mocha-define-lqx-padrao-boot-v3.sh' "$MANUAL"; then
    {
      echo
      echo "## Liquorix/linux-lqx como boot padrão real"
      echo
      echo "- Script canônico: \`/media/mochafast/MochaArch/scripts/mocha-define-lqx-padrao-boot-v3.sh\`"
      echo "- Objetivo: deixar \`linux-lqx\` como primeira entrada real do GRUB, não escondido apenas em opções avançadas."
      echo "- Configuração aplicada: \`GRUB_TOP_LEVEL=\"/boot/vmlinuz-linux-lqx\"\`, \`GRUB_DEFAULT=0\`, \`GRUB_SAVEDEFAULT=false\`."
      echo "- Outros kernels permanecem instalados apenas como fallback."
      echo "- Validação pós-reboot: \`uname -r\` deve conter \`lqx\`."
    } | tee -a "$MANUAL" >/dev/null
    ok "Manual vivo atualizado."
  else
    ok "Manual vivo já citava o script v3."
  fi
else
  warn "Manual vivo não encontrado em $MANUAL; script foi salvo mesmo assim."
fi

echo
ok "Liquorix/linux-lqx agora está definido como padrão real do boot."
ok "Outros kernels continuam disponíveis como fallback."
echo
echo "Agora reinicie e valide com:"
echo "  uname -r"
echo
echo "Resultado esperado:"
echo "  algo contendo lqx"
