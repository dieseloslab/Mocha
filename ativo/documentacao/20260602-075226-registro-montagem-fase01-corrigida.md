# MochaArch — montagem fase 01 corrigida — 20260602-075226

Procedimento desta fase:

1. Montar FAST em `/media/mochafast`, persistente via `/etc/fstab`, visível no Dolphin.
2. Montar VMSTORE em `/media/vmstore`, persistente via `/etc/fstab`, visível no Dolphin.
3. Detectar discos por `lsblk` e UUID real, não por `blkid -L`.
4. Atualizar o sistema inteiro antes de ativar qualquer repositório temporário.
5. Ativar repositório CachyOS somente de forma temporária para instalar kernel comum CachyOS e driver NVIDIA compatível.
6. Não instalar Bore, LTO, EEVDF ou variantes.
7. Restaurar `/etc/pacman.conf` original ao final.
8. Definir o kernel comum `linux-cachyos` como padrão no GRUB.
9. Preservar o kernel Arch como fallback.
10. Não remover programas nesta fase.
