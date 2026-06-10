#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"
export LANG=C
export LC_ALL=C

TS="$(date +%Y%m%d-%H%M%S)"
REAL_USER="${SUDO_USER:-$USER}"
REAL_GROUP="$(id -gn "$REAL_USER")"

FAST_BASE="/media/mochafast/MochaArch"
DOC_DIR="$FAST_BASE/ativo/documentacao"
SCRIPT_DIR="$FAST_BASE/ativo/scripts"
REPORT_DIR="$FAST_BASE/ativo/relatorios"
BACKUP_DIR="$FAST_BASE/ativo/backups/bootloader"

LOG="$REPORT_DIR/${TS}-fixar-grub-cachyos-bore-lto-v3-permissao-corrigida.log"
DOC="$DOC_DIR/${TS}-fixar-grub-cachyos-bore-lto-v3-permissao-corrigida.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-fixar-grub-cachyos-bore-lto-v3-permissao-corrigida.sh"

say() { printf '\n== %s ==\n' "$*"; }
fail() { printf '\nERRO: %s\n' "$*" >&2; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || fail "Comando obrigatório ausente: $1"; }

need_cmd sudo
need_cmd pacman
need_cmd findmnt
need_cmd awk
need_cmd sed
need_cmd grep
need_cmd tee
need_cmd install
need_cmd cp
need_cmd uname
need_cmd grub-mkconfig
need_cmd grub-set-default
need_cmd grub-editenv

findmnt /media/mochafast >/dev/null || fail "/media/mochafast não está montado."
findmnt /media/vmstore >/dev/null || fail "/media/vmstore não está montado."

sudo -v
while true; do sudo -n true 2>/dev/null || exit; sleep 45; done &
SUDO_KEEPALIVE_PID="$!"
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

sudo install -d -o "$REAL_USER" -g "$REAL_GROUP" "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR" "$BACKUP_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Mocha Arch — fixando GRUB no CachyOS BORE LTO v3 com permissão corrigida"
date
uname -a
printf 'Log: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
printf 'Script salvo: %s\n' "$SCRIPT_COPY"

say "Escopo seguro"
printf '%s\n' "Este script NÃO roda pacman -Syu."
printf '%s\n' "Este script NÃO instala pacotes."
printf '%s\n' "Este script NÃO remove pacotes."
printf '%s\n' "Este script NÃO roda mkinitcpio -P."
printf '%s\n' "Este script NÃO reinicia automaticamente."
printf '%s\n' "Este script apenas configura o GRUB para iniciar pelo CachyOS BORE LTO."

say "Auditando estado atual"
pacman -Q \
  linux \
  linux-headers \
  linux-zen \
  linux-zen-headers \
  linux-cachyos-bore-lto \
  linux-cachyos-bore-lto-headers \
  linux-cachyos-bore-lto-nvidia-open \
  nvidia-utils \
  lib32-nvidia-utils \
  nvidia-open-dkms \
  2>/dev/null || true

say "Validando kernel, driver e initramfs CachyOS"
pacman -Q linux-cachyos-bore-lto >/dev/null 2>&1 || fail "linux-cachyos-bore-lto não está instalado."
pacman -Q linux-cachyos-bore-lto-nvidia-open >/dev/null 2>&1 || fail "linux-cachyos-bore-lto-nvidia-open não está instalado."
pacman -Q nvidia-utils >/dev/null 2>&1 || fail "nvidia-utils não está instalado."
pacman -Q lib32-nvidia-utils >/dev/null 2>&1 || fail "lib32-nvidia-utils não está instalado."

[ -f /boot/vmlinuz-linux-cachyos-bore-lto ] || fail "Não existe /boot/vmlinuz-linux-cachyos-bore-lto."
[ -f /boot/initramfs-linux-cachyos-bore-lto.img ] || fail "Não existe /boot/initramfs-linux-cachyos-bore-lto.img."
[ -f /etc/default/grub ] || fail "Não existe /etc/default/grub."
[ -f /boot/grub/grub.cfg ] || fail "Não existe /boot/grub/grub.cfg."

printf '\n%s\n' "Arquivos CachyOS em /boot:"
ls -lh /boot/vmlinuz-linux-cachyos-bore-lto /boot/initramfs-linux-cachyos-bore-lto.img

say "Validando módulos NVIDIA do CachyOS"
if ! find /usr/lib/modules -type f -path '*cachyos-bore-lto*' \( \
  -name 'nvidia.ko*' -o \
  -name 'nvidia_drm.ko*' -o \
  -name 'nvidia_modeset.ko*' -o \
  -name 'nvidia_uvm.ko*' \
\) 2>/dev/null | grep -q .; then
  fail "Não encontrei módulos NVIDIA do kernel CachyOS BORE LTO."
fi

find /usr/lib/modules -type f -path '*cachyos-bore-lto*' \( \
  -name 'nvidia.ko*' -o \
  -name 'nvidia_drm.ko*' -o \
  -name 'nvidia_modeset.ko*' -o \
  -name 'nvidia_uvm.ko*' \
\) 2>/dev/null | sort

say "Backup controlado do GRUB"
sudo cp -a /etc/default/grub "$BACKUP_DIR/${TS}-grub-default.bak"
sudo cp -a /boot/grub/grub.cfg "$BACKUP_DIR/${TS}-grub.cfg.bak"

ls -1t "$BACKUP_DIR"/*-grub-default.bak 2>/dev/null | awk 'NR>2' | while read -r old_backup; do
  sudo rm -f "$old_backup"
done

ls -1t "$BACKUP_DIR"/*-grub.cfg.bak 2>/dev/null | awk 'NR>2' | while read -r old_backup; do
  sudo rm -f "$old_backup"
done

say "Garantindo GRUB_DEFAULT=saved"
if grep -q '^GRUB_DEFAULT=' /etc/default/grub; then
  sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
else
  printf '%s\n' 'GRUB_DEFAULT=saved' | sudo tee -a /etc/default/grub >/dev/null
fi

if grep -q '^GRUB_SAVEDEFAULT=' /etc/default/grub; then
  sudo sed -i 's/^GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=false/' /etc/default/grub
else
  printf '%s\n' 'GRUB_SAVEDEFAULT=false' | sudo tee -a /etc/default/grub >/dev/null
fi

say "Regenerando grub.cfg com sudo"
sudo grub-mkconfig -o /boot/grub/grub.cfg

say "Lendo entradas do GRUB com sudo"
printf '%s\n' "Entradas relacionadas a CachyOS/BORE/LTO:"
sudo grep -Ei "menuentry .*cachyos|menuentry .*bore|menuentry .*lto|submenu .*advanced" /boot/grub/grub.cfg || true

GRUB_LINE="$(
  sudo grep -Ei "^[[:space:]]*menuentry .*cachyos.*bore.*lto|^[[:space:]]*menuentry .*linux-cachyos-bore-lto|^[[:space:]]*menuentry .*CachyOS.*BORE.*LTO" /boot/grub/grub.cfg \
    | head -n1 || true
)"

if [ -z "$GRUB_LINE" ]; then
  printf '%s\n' "Todas as menuentries encontradas:"
  sudo grep -E "^[[:space:]]*menuentry " /boot/grub/grub.cfg || true
  fail "Não encontrei uma menuentry segura para linux-cachyos-bore-lto."
fi

printf '\n%s\n%s\n' "Linha CachyOS escolhida:" "$GRUB_LINE"

GRUB_ID="$(
  printf '%s\n' "$GRUB_LINE" \
    | sed -n "s/.*\\\$menuentry_id_option '\([^']*\)'.*/\1/p; s/.*--id '\([^']*\)'.*/\1/p" \
    | head -n1
)"

GRUB_TITLE="$(
  printf '%s\n' "$GRUB_LINE" \
    | sed -n "s/^[[:space:]]*menuentry '\([^']*\)'.*/\1/p" \
    | head -n1
)"

if [ -n "$GRUB_ID" ]; then
  sudo grub-set-default "$GRUB_ID"
  CHOSEN="$GRUB_ID"
  CHOSEN_KIND="ID"
  printf 'GRUB default definido por ID: %s\n' "$GRUB_ID"
elif [ -n "$GRUB_TITLE" ]; then
  sudo grub-set-default "$GRUB_TITLE"
  CHOSEN="$GRUB_TITLE"
  CHOSEN_KIND="título"
  printf 'GRUB default definido por título: %s\n' "$GRUB_TITLE"
else
  fail "Achei a linha do CachyOS, mas não consegui extrair ID nem título."
fi

say "Validando grubenv"
sudo grub-editenv list || true

if ! sudo grub-editenv list | grep -q '^saved_entry='; then
  fail "grub-set-default não gravou saved_entry no grubenv."
fi

say "Resumo de boot"
printf '%s\n' "Kernel atual ainda é o do boot presente:"
uname -r

printf '\n%s\n' "Próximo boot padrão configurado para:"
printf '%s: %s\n' "$CHOSEN_KIND" "$CHOSEN"

printf '\n%s\n' "Pacotes NVIDIA atuais:"
pacman -Q linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils

say "Documentando correção"
{
  printf '# Mocha Arch — GRUB fixado no CachyOS BORE LTO v3\n\n'
  printf 'Timestamp: %s\n\n' "$TS"

  printf '## Correção aplicada\n\n'
  printf '%s\n' '- O comando anterior havia gerado corretamente o initramfs do CachyOS BORE LTO.'
  printf '%s\n' '- O erro ocorreu porque `/boot/grub/grub.cfg` foi lido sem `sudo`, resultando em `Permission denied`.'
  printf '%s\n' '- Esta correção leu o `grub.cfg` com `sudo`, encontrou a entrada do CachyOS BORE LTO e aplicou `grub-set-default`.'
  printf '%s\n' '- Nenhum pacote foi instalado.'
  printf '%s\n' '- Nenhum pacote foi removido.'
  printf '%s\n' '- Nenhum `mkinitcpio -P` foi executado.'
  printf '%s\n' '- Nenhum reinício automático foi feito.'
  printf '\n'

  printf '## Entrada escolhida\n\n'
  printf '%s\n' "- Tipo: $CHOSEN_KIND"
  printf '%s\n' "- Valor: $CHOSEN"
  printf '\n'

  printf '## Estado NVIDIA/CachyOS\n\n'
  pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils 2>/dev/null \
    | sed 's/^/- /'
  printf '\n'

  printf '## Arquivos\n\n'
  printf '%s\n' "- Log: $LOG"
  printf '%s\n' "- Script salvo: $SCRIPT_COPY"
} > "$DOC"

cp -a "$0" "$SCRIPT_COPY"

say "Resumo final"
printf '%s\n' "Correção concluída."
printf '%s\n' "GRUB foi apontado para o CachyOS BORE LTO v3."
printf '%s\n' "Driver NVIDIA CachyOS permanece instalado."
printf '%s\n' "Não houve reinstalação, remoção nem reinício automático."
printf 'Log: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
printf 'Script salvo: %s\n' "$SCRIPT_COPY"
