# Mocha Arch — GRUB fixado no CachyOS BORE LTO v3

Timestamp: 20260530-134240

## Correção aplicada

- O comando anterior havia gerado corretamente o initramfs do CachyOS BORE LTO.
- O erro ocorreu porque `/boot/grub/grub.cfg` foi lido sem `sudo`, resultando em `Permission denied`.
- Esta correção leu o `grub.cfg` com `sudo`, encontrou a entrada do CachyOS BORE LTO e aplicou `grub-set-default`.
- Nenhum pacote foi instalado.
- Nenhum pacote foi removido.
- Nenhum `mkinitcpio -P` foi executado.
- Nenhum reinício automático foi feito.

## Entrada escolhida

- Tipo: ID
- Valor: gnulinux-linux-cachyos-bore-lto-advanced-2a8beb39-04e6-4520-a873-9134a2f73f53

## Estado NVIDIA/CachyOS

- linux-cachyos-bore-lto 7.0.10-2
- linux-cachyos-bore-lto-nvidia-open 7.0.10-2
- nvidia-utils 610.43.02-3
- lib32-nvidia-utils 610.43.02-1

## Arquivos

- Log: /media/mochafast/MochaArch/ativo/relatorios/20260530-134240-fixar-grub-cachyos-bore-lto-v3-permissao-corrigida.log
- Script salvo: /media/mochafast/MochaArch/ativo/scripts/20260530-134240-mocha-fixar-grub-cachyos-bore-lto-v3-permissao-corrigida.sh
