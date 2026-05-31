#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"
TS="$(date +%Y%m%d-%H%M%S)"

FAST_BASE="/media/mochafast/MochaArch"
REPORT_DIR="/tmp"
DOC_DIR="/tmp"
SCRIPT_DIR="/tmp"

if findmnt -rn /media/mochafast >/dev/null 2>&1 && [ -d "$FAST_BASE/ativo" ]; then
  if mkdir -p "$FAST_BASE/ativo/relatorios" "$FAST_BASE/ativo/documentacao" "$FAST_BASE/ativo/scripts" 2>/dev/null; then
    REPORT_DIR="$FAST_BASE/ativo/relatorios"
    DOC_DIR="$FAST_BASE/ativo/documentacao"
    SCRIPT_DIR="$FAST_BASE/ativo/scripts"
  fi
fi

LOG="$REPORT_DIR/${TS}-finalizar-grub-cachyos-bore-lto.log"
DOC="$DOC_DIR/${TS}-finalizar-grub-cachyos-bore-lto.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-finalizar-grub-cachyos-bore-lto.sh"

exec > >(tee -a "$LOG") 2>&1

say() { printf '\n== %s ==\n' "$*"; }

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  printf 'Log: %s\n' "$LOG" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Comando obrigatório ausente: $1"
}

keep_last_two_backups() {
  local original="$1" dir base
  dir="$(dirname "$original")"
  base="$(basename "$original")"
  sudo find "$dir" -maxdepth 1 -type f -name "${base}.bak-*" -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | awk 'NR>2 { sub(/^[^ ]+ /, ""); print }' \
    | while IFS= read -r old_backup; do
        [ -n "$old_backup" ] && sudo rm -f -- "$old_backup"
      done
}

set_grub_var() {
  local key="$1"
  local value="$2"
  local file="/etc/default/grub"

  if sudo grep -qE "^${key}=" "$file"; then
    sudo sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$file"
  else
    printf '%s="%s"\n' "$key" "$value" | sudo tee -a "$file" >/dev/null
  fi
}

append_grub_cmdline_param() {
  local param="$1"
  local file="/etc/default/grub"
  local current

  current="$(sudo sed -nE 's/^GRUB_CMDLINE_LINUX_DEFAULT="?([^"]*)"?/\1/p' "$file" | tail -n1 || true)"
  [ -n "${current:-}" ] || current="quiet splash"

  case " $current " in
    *" $param "*) ;;
    *) current="$current $param" ;;
  esac

  current="$(printf '%s\n' "$current" | xargs)"
  set_grub_var GRUB_CMDLINE_LINUX_DEFAULT "$current"
}

say "Revisão 1/3 - pré-checagem sem reinstalar nada"
need_cmd sudo
need_cmd pacman
need_cmd grep
need_cmd sed
need_cmd awk
need_cmd grub-mkconfig
need_cmd grub-set-default
need_cmd grub-editenv

[ -f /etc/default/grub ] || fail "Arquivo ausente: /etc/default/grub"
[ -d /boot/grub ] || fail "Diretório ausente: /boot/grub"
[ -f /boot/vmlinuz-linux-cachyos-bore-lto ] || fail "Kernel ausente: /boot/vmlinuz-linux-cachyos-bore-lto"
[ -f /boot/initramfs-linux-cachyos-bore-lto.img ] || fail "Initramfs ausente: /boot/initramfs-linux-cachyos-bore-lto.img"
[ -f /etc/mkinitcpio.d/linux-cachyos-bore-lto.preset ] || fail "Preset ausente: /etc/mkinitcpio.d/linux-cachyos-bore-lto.preset"

say "Pedindo sudo uma vez e mantendo sessão ativa"
sudo -v
while true; do
  sudo -n true 2>/dev/null || exit
  sleep 25
done &
KEEPALIVE_PID="$!"
trap 'kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT

say "Estado atual antes de finalizar GRUB"
echo "Kernel atual: $(uname -r)"
echo
pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils
echo
echo "Preset CachyOS Bore LTO:"
grep -E '^(ALL_config|ALL_kver|default_image|fallback_image|PRESETS)' /etc/mkinitcpio.d/linux-cachyos-bore-lto.preset || true
echo
echo "Imagem em /boot:"
ls -lh /boot/vmlinuz-linux-cachyos-bore-lto /boot/initramfs-linux-cachyos-bore-lto.img

say "Revisão 2/3 - ajustando somente GRUB para preferir CachyOS Bore LTO"
sudo cp -a /etc/default/grub "/etc/default/grub.bak-${TS}"
keep_last_two_backups /etc/default/grub

set_grub_var GRUB_DEFAULT saved
set_grub_var GRUB_SAVEDEFAULT false
set_grub_var GRUB_DISABLE_SUBMENU y

if sudo grep -Rqs 'GRUB_TOP_LEVEL' /etc/grub.d /usr/share/grub 2>/dev/null; then
  set_grub_var GRUB_TOP_LEVEL /boot/vmlinuz-linux-cachyos-bore-lto
fi

append_grub_cmdline_param nvidia_drm.modeset=1
append_grub_cmdline_param nvidia_drm.fbdev=1

say "Regenerando grub.cfg"
sudo grub-mkconfig -o /boot/grub/grub.cfg

[ -f /boot/grub/grub.cfg ] || fail "grub.cfg não foi gerado."

say "Revisão 3/3 - lendo grub.cfg com sudo e encontrando entrada CachyOS"
MATCH_HEADER=""
MATCH_INDEX=""
HEADER=""
INDEX=-1

while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*menuentry[[:space:]] ]]; then
    INDEX=$((INDEX + 1))
    HEADER="$line"
  fi

  if [[ "$line" == *"vmlinuz-linux-cachyos-bore-lto"* ]]; then
    MATCH_HEADER="$HEADER"
    MATCH_INDEX="$INDEX"
    break
  fi
done < <(sudo cat /boot/grub/grub.cfg)

[ -n "$MATCH_HEADER" ] || {
  echo "Trecho diagnóstico do grub.cfg:"
  sudo grep -niE 'menuentry|vmlinuz-linux-cachyos-bore-lto|vmlinuz-linux-zen|vmlinuz-linux' /boot/grub/grub.cfg || true
  fail "Não encontrei menuentry que carregue vmlinuz-linux-cachyos-bore-lto."
}

MATCH_TITLE="$(printf '%s\n' "$MATCH_HEADER" | sed -nE "s/^[[:space:]]*menuentry '([^']+)'.*/\1/p")"

echo "Entrada encontrada:"
echo "$MATCH_HEADER"
echo
echo "Índice encontrado: $MATCH_INDEX"
echo "Título encontrado: ${MATCH_TITLE:-não extraído}"

if [ -n "$MATCH_TITLE" ]; then
  sudo grub-set-default "$MATCH_TITLE"
  echo "GRUB default definido pelo título."
else
  [ "$MATCH_INDEX" -ge 0 ] || fail "Índice inválido para grub-set-default."
  sudo grub-set-default "$MATCH_INDEX"
  echo "GRUB default definido pelo índice."
fi

say "Validação final"
echo "grub-editenv:"
sudo grub-editenv list || true
echo
echo "Primeiras entradas Linux no grub.cfg:"
sudo grep -nE "^[[:space:]]*menuentry |vmlinuz-linux-cachyos-bore-lto|vmlinuz-linux-zen|vmlinuz-linux$" /boot/grub/grub.cfg | head -n 40 || true
echo
echo "Pacotes:"
pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils
echo
echo "Arquivos CachyOS em /boot:"
ls -lh /boot/vmlinuz-linux-cachyos-bore-lto /boot/initramfs-linux-cachyos-bore-lto.img

say "Documentando"
{
  printf '%s\n' '# Mocha Arch - finalização GRUB CachyOS Bore LTO'
  printf '%s\n' ''
  printf '%s\n' "Data: $TS"
  printf '%s\n' ''
  printf '%s\n' 'Correção aplicada:'
  printf '%s\n' ''
  printf '%s\n' '- O erro anterior foi leitura de /boot/grub/grub.cfg sem sudo.'
  printf '%s\n' '- Este reparo leu /boot/grub/grub.cfg com sudo.'
  printf '%s\n' '- Não reinstalou pacotes.'
  printf '%s\n' '- Não removeu pacotes.'
  printf '%s\n' '- Não executou mkinitcpio -P.'
  printf '%s\n' '- Apenas regenerou GRUB e definiu a entrada CachyOS Bore LTO como padrão.'
  printf '%s\n' ''
  printf '%s\n' 'Validar após reiniciar:'
  printf '%s\n' ''
  printf '%s\n' 'uname -r'
  printf '%s\n' 'nvidia-smi'
  printf '%s\n' 'pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils'
} > "$DOC"

cp -f "$0" "$SCRIPT_COPY" 2>/dev/null || true

say "Resumo"
echo "Finalização concluída."
echo "Log: $LOG"
echo "Documento: $DOC"
echo "Script salvo: $SCRIPT_COPY"
echo
echo "Reinicie manualmente. Depois rode:"
echo "  uname -r"
echo "  nvidia-smi"
echo "  pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils"
