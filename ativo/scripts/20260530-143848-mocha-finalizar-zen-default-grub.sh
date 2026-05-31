#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
FAST_BASE="/media/mochafast/MochaArch"

if findmnt -rn /media/mochafast >/dev/null 2>&1 && [ -d "$FAST_BASE/ativo" ]; then
  DOC_DIR="$FAST_BASE/ativo/documentacao"
  SCRIPT_DIR="$FAST_BASE/ativo/scripts"
  REPORT_DIR="$FAST_BASE/ativo/relatorios"
else
  DOC_DIR="/tmp/mocha-${TS}/documentacao"
  SCRIPT_DIR="/tmp/mocha-${TS}/scripts"
  REPORT_DIR="/tmp/mocha-${TS}/relatorios"
fi

mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR"

LOG="$REPORT_DIR/${TS}-finalizar-zen-default-grub.log"
DOC="$DOC_DIR/${TS}-finalizar-zen-default-grub.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-finalizar-zen-default-grub.sh"

exec > >(tee -a "$LOG") 2>&1

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  printf 'Log: %s\n' "$LOG" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "comando obrigatório ausente: $1"
}

backup_file_keep_two() {
  local f="$1"
  [ -f "$f" ] || fail "arquivo não existe para backup: $f"

  sudo cp -a "$f" "${f}.bak-${TS}"

  mapfile -t OLD_BACKUPS < <(ls -1t "${f}".bak-* 2>/dev/null | tail -n +3 || true)
  if [ "${#OLD_BACKUPS[@]}" -gt 0 ]; then
    sudo rm -f "${OLD_BACKUPS[@]}"
  fi
}

say "Pré-validação"
need_cmd sudo
need_cmd pacman
need_cmd dkms
need_cmd mkinitcpio
need_cmd grub-mkconfig
need_cmd grub-set-default
need_cmd grub-editenv
need_cmd awk
need_cmd findmnt

[ -d /boot/grub ] || fail "/boot/grub não existe."
[ -f /etc/default/grub ] || fail "/etc/default/grub não existe."

sudo -v
(
  while true; do
    sudo -n true 2>/dev/null || exit 0
    sleep 30
  done
) &
KEEPALIVE_PID="$!"
trap 'kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT

say "Estado atual"
printf '%s\n' "Kernel em uso agora:"
uname -r || true

printf '\n%s\n' "Pacotes esperados para Zen + NVIDIA oficial Arch:"
pacman -Q linux-zen linux-zen-headers dkms nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

say "Detectando kernel Zen instalado"
ZEN_KVER="$(find /usr/lib/modules -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | grep -E 'zen$' | sort -V | tail -n 1 || true)"
[ -n "$ZEN_KVER" ] || fail "não encontrei linux-zen em /usr/lib/modules"

printf 'Kernel Zen detectado: %s\n' "$ZEN_KVER"

say "Validando DKMS NVIDIA no kernel Zen"
dkms status || true

if ! dkms status | grep -F "nvidia/610.43.02, ${ZEN_KVER}" | grep -Fq "installed"; then
  printf '%s\n' "DKMS NVIDIA ainda não aparece como installed para o Zen. Rodando autoinstall apenas para o Zen..."
  sudo dkms autoinstall -k "$ZEN_KVER"
fi

sudo depmod "$ZEN_KVER"

if ! find "/usr/lib/modules/$ZEN_KVER" -type f \( -name 'nvidia.ko*' -o -name 'nvidia_drm.ko*' -o -name 'nvidia_modeset.ko*' -o -name 'nvidia_uvm.ko*' \) -print | grep -q 'nvidia'; then
  fail "módulos NVIDIA não foram encontrados em /usr/lib/modules/$ZEN_KVER"
fi

say "Regenerando initramfs somente do linux-zen"
sudo mkinitcpio -p linux-zen

say "Configurando GRUB_DEFAULT=saved sem alterar outras opções"
backup_file_keep_two /etc/default/grub

TMP_GRUB="$(mktemp)"
awk '
BEGIN {
  found_default = 0
  found_savedefault = 0
}
/^GRUB_DEFAULT=/ {
  print "GRUB_DEFAULT=saved"
  found_default = 1
  next
}
/^GRUB_SAVEDEFAULT=/ {
  print "GRUB_SAVEDEFAULT=false"
  found_savedefault = 1
  next
}
{
  print
}
END {
  if (found_default == 0) {
    print "GRUB_DEFAULT=saved"
  }
  if (found_savedefault == 0) {
    print "GRUB_SAVEDEFAULT=false"
  }
}
' /etc/default/grub > "$TMP_GRUB"

sudo install -m 0644 "$TMP_GRUB" /etc/default/grub
rm -f "$TMP_GRUB"

say "Regenerando grub.cfg"
sudo grub-mkconfig -o /boot/grub/grub.cfg

say "Localizando entrada linux-zen não-fallback no GRUB"
ZEN_TARGET="$(
  sudo awk -F"'" '
    /^[[:space:]]*submenu / {
      submenu_title = $2
      submenu_id = ""
      for (i = 3; i <= NF; i++) {
        if ($i ~ /^gnulinux-advanced-/) {
          submenu_id = $i
        }
      }
    }

    /^[[:space:]]*menuentry / && /linux-zen/ && !/fallback/ {
      entry_title = $2
      entry_id = ""

      for (i = 3; i <= NF; i++) {
        if ($i ~ /^gnulinux-linux-zen-/) {
          entry_id = $i
        }
      }

      if (submenu_id != "" && entry_id != "") {
        print submenu_id ">" entry_id
        exit
      }

      if (submenu_title != "" && entry_title != "") {
        print submenu_title ">" entry_title
        exit
      }

      if (entry_title != "") {
        print entry_title
        exit
      }
    }
  ' /boot/grub/grub.cfg
)"

[ -n "$ZEN_TARGET" ] || fail "não encontrei entrada linux-zen não-fallback em /boot/grub/grub.cfg"

printf 'Entrada GRUB definida como padrão: %s\n' "$ZEN_TARGET"
sudo grub-set-default "$ZEN_TARGET"

say "Verificando grubenv"
sudo grub-editenv list || true

say "Resumo final"
printf '%s\n' "Zen detectado: $ZEN_KVER"
printf '%s\n' "GRUB saved_entry alvo: $ZEN_TARGET"

printf '\n%s\n' "Módulos NVIDIA encontrados no Zen:"
find "/usr/lib/modules/$ZEN_KVER" -type f \( -name 'nvidia.ko*' -o -name 'nvidia_drm.ko*' -o -name 'nvidia_modeset.ko*' -o -name 'nvidia_uvm.ko*' \) -print | sort

{
  printf '%s\n' "# Mocha Arch - finalização do rollback para linux-zen"
  printf '%s\n' ""
  printf '%s\n' "Timestamp: ${TS}"
  printf '%s\n' "Objetivo: finalizar o GRUB para iniciar pelo linux-zen como padrão e validar NVIDIA DKMS no Zen."
  printf '%s\n' "Kernel Zen detectado: ${ZEN_KVER}"
  printf '%s\n' "Entrada GRUB salva: ${ZEN_TARGET}"
  printf '%s\n' "Driver: nvidia-open-dkms + nvidia-utils/lib32-nvidia-utils."
  printf '%s\n' "Observação: o kernel Cachy permanece instalado, mas não deve ser usado como padrão neste teste."
  printf '%s\n' "Log: ${LOG}"
  printf '%s\n' ""
  printf '%s\n' "Validação após reboot:"
  printf '%s\n' "uname -r"
  printf '%s\n' "nvidia-smi"
  printf '%s\n' "dkms status | grep -i nvidia || true"
  printf '%s\n' "lsmod | grep -E '^nvidia|^nvidia_drm|^nvidia_modeset|^nvidia_uvm' || true"
} > "$DOC"

cp -a "$0" "$SCRIPT_COPY" 2>/dev/null || true

say "Concluído"
printf '%s\n' "Log: $LOG"
printf '%s\n' "Documento: $DOC"
printf '%s\n' "Script salvo: $SCRIPT_COPY"

printf '\n%s\n' "Agora reinicie:"
printf '%s\n' "sudo systemctl reboot"

printf '\n%s\n' "Depois do reboot, valide:"
printf '%s\n' "uname -r"
printf '%s\n' "nvidia-smi"
printf '%s\n' "dkms status | grep -i nvidia || true"
