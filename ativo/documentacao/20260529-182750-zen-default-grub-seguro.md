# Mocha Arch — Kernel Zen como primeira entrada/default do GRUB

Data: 20260529-182750

## Resultado

- O Kernel Zen já estava instalado.
- O initramfs do Zen existe.
- O DKMS mostra NVIDIA instalado para o Kernel Zen.
- A primeira entrada do GRUB aponta para /vmlinuz-linux-zen.
- A primeira entrada não é fallback.
- /etc/default/grub ficou com GRUB_DEFAULT=0 e GRUB_SAVEDEFAULT=false.

Primeira entrada validada: Arch Linux

Log: /media/mochafast/MochaArch/ativo/logs/20260529-182750-zen-verificar-e-marcar-default-seguro.log
