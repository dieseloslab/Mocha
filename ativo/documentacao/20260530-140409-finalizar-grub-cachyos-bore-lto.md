# Mocha Arch - finalização GRUB CachyOS Bore LTO

Data: 20260530-140409

Correção aplicada:

- O erro anterior foi leitura de /boot/grub/grub.cfg sem sudo.
- Este reparo leu /boot/grub/grub.cfg com sudo.
- Não reinstalou pacotes.
- Não removeu pacotes.
- Não executou mkinitcpio -P.
- Apenas regenerou GRUB e definiu a entrada CachyOS Bore LTO como padrão.

Validar após reiniciar:

uname -r
nvidia-smi
pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils
