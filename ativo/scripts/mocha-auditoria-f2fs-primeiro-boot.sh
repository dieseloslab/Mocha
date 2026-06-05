#!/usr/bin/env bash
set -u

printf "%s\n" "==> Auditoria pós-instalação: F2FS / Calam-Arch / Mocha"
printf "%s\n" ""
printf "%s\n" "==> Kernel em execução"
uname -r
printf "%s\n" ""
printf "%s\n" "==> Montagens críticas"
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /boot 2>/dev/null || printf "%s\n" "/boot não montado separadamente"
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /boot/efi 2>/dev/null || printf "%s\n" "/boot/efi não montado"
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /efi 2>/dev/null || true
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /media/mochafast 2>/dev/null || printf "%s\n" "ALERTA: FAST não montado em /media/mochafast"
findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS /media/vmstore 2>/dev/null || printf "%s\n" "ALERTA: VMSTORE não montado em /media/vmstore"
printf "%s\n" ""
printf "%s\n" "==> fstab ativo"
grep -vE "^[[:space:]]*(#|$)" /etc/fstab || true
printf "%s\n" ""
printf "%s\n" "==> f2fs-tools"
pacman -Q f2fs-tools 2>/dev/null || printf "%s\n" "ERRO: f2fs-tools não instalado"
printf "%s\n" ""
printf "%s\n" "==> Módulo F2FS no kernel atual"
modinfo f2fs 2>/dev/null | sed -n "1,20p" || printf "%s\n" "ERRO: módulo f2fs não encontrado"
printf "%s\n" ""
printf "%s\n" "==> mkinitcpio"
grep -E "^(MODULES|HOOKS)=" /etc/mkinitcpio.conf || true
printf "%s\n" ""
printf "%s\n" "==> Presets disponíveis"
ls -1 /etc/mkinitcpio.d/*.preset 2>/dev/null || printf "%s\n" "ERRO: nenhum preset mkinitcpio encontrado"
printf "%s\n" ""
printf "%s\n" "==> GRUB"
grep -E "^(GRUB_DEFAULT|GRUB_SAVEDEFAULT|GRUB_CMDLINE_LINUX|GRUB_CMDLINE_LINUX_DEFAULT)=" /etc/default/grub 2>/dev/null || printf "%s\n" "GRUB não encontrado em /etc/default/grub"
printf "%s\n" ""
printf "%s\n" "==> Conclusão automática"
ROOTFS="$(findmnt -no FSTYPE / 2>/dev/null || true)"
EFI_FS="$(findmnt -no FSTYPE /boot/efi 2>/dev/null || true)"
if [ "$ROOTFS" = "f2fs" ]; then
  printf "%s\n" "OK: / está em F2FS."
else
  printf "%s\n" "ATENÇÃO: / não está em F2FS; está em: ${ROOTFS:-desconhecido}"
fi
if [ "$EFI_FS" = "vfat" ]; then
  printf "%s\n" "OK: /boot/efi está em FAT32/vfat."
else
  printf "%s\n" "ATENÇÃO: /boot/efi não está em vfat ou não está montado."
fi
if pacman -Q f2fs-tools >/dev/null 2>&1 && modinfo f2fs >/dev/null 2>&1; then
  printf "%s\n" "OK: ferramentas e módulo F2FS presentes."
else
  printf "%s\n" "ERRO: falta f2fs-tools ou módulo f2fs."
fi
