# Mocha Arch - finalização revisada do boot CachyOS Bore LTO + NVIDIA open

Data: 20260530-135419

## O que foi corrigido

- O erro anterior era a leitura de /boot/grub/grub.cfg sem sudo na etapa de verificação.
- O GRUB foi regenerado com verificação privilegiada.
- CachyOS Bore LTO foi colocado como primeira entrada via GRUB_TOP_LEVEL.
- Zen foi preservado como fallback quando instalado.
- mkinitcpio foi executado somente para linux-cachyos-bore-lto.
- Nenhum pacote foi removido.

## Kernel e NVIDIA

Kernel CachyOS detectado: 7.0.10-2-cachyos-bore-lto
Versão módulo NVIDIA: 610.43.02
Versão nvidia-utils: 610.43.02
Versão lib32-nvidia-utils: 610.43.02

## Validação pós-reboot

Rodar:

uname -r
nvidia-smi
pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils

Esperado:

- uname -r deve mostrar o kernel CachyOS Bore LTO.
- nvidia-smi deve funcionar.
- Zen deve continuar disponível como fallback no GRUB.
