# Auditoria Mocha Arch — procura correta do CachyOS BORE LTO NVIDIA

Timestamp: 20260530-133009

## O que este comando fez

- Sincronizou somente as bases dos repositórios com `pacman -Sy`.
- Procurou os pacotes reais em `cachyos-v3`, `cachyos-core-v3` e `cachyos-extra-v3`.
- Não instalou pacote nenhum.
- Não removeu pacote nenhum.
- Não mudou bootloader.
- Não reiniciou.

## Pacotes procurados

- linux-cachyos-bore-lto
- linux-cachyos-bore-lto-headers
- linux-cachyos-bore-lto-nvidia-open
- nvidia-utils
- lib32-nvidia-utils
- nvidia-open-dkms
- nvidia-open

## Próxima decisão

Se os pacotes aparecerem, a instalação real deve ser feita em comando separado, preservando kernel atual e sem mudar default de boot automaticamente.

## Arquivos

- Log: /media/mochafast/MochaArch/ativo/relatorios/20260530-133009-procurar-cachyos-bore-lto-nvidia-corretamente.log
- Script salvo: /media/mochafast/MochaArch/ativo/scripts/20260530-133009-mocha-procurar-cachyos-bore-lto-nvidia-corretamente.sh
