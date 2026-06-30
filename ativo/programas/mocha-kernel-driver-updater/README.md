# Mocha Kernel Driver Updater

Programa canônico do Mocha para atualização de kernel, driver de vídeo e stack gamer/performance.

## Componentes

- Backend:
  - /usr/local/sbin/mocha-kernel-driver-updater

- Interface gráfica:
  - /usr/local/bin/mocha-kernel-driver-updater-gui

- Atalho KDE:
  - /usr/share/applications/mocha-kernel-driver-updater.desktop

## Funções

- Detectar arquitetura do processador.
- Detectar placa de vídeo.
- Mostrar kernel atual.
- Mostrar driver de vídeo atual.
- Mostrar versões candidatas antes de instalar.
- Atualizar o sistema.
- Colocar temporariamente o sistema no canal CachyOS adequado.
- Instalar kernel CachyOS e headers.
- Instalar driver de vídeo adequado.
- Remover drivers conflitantes.
- Regenerar initramfs.
- Tornar o kernel novo padrão de boot no GRUB.
- Reinstalar stack gamer/performance quando solicitado.
- Oferecer interface gráfica para usuário comum.

## Reinstalação

Executar:

    bash "/media/mochafast/MochaArch-Interno/ativo/programas/mocha-kernel-driver-updater/scripts/REINSTALAR-MOCHA-KERNEL-DRIVER-UPDATER.sh"

## Pasta canônica

/media/mochafast/MochaArch-Interno/ativo/programas/mocha-kernel-driver-updater

## Criado em

20260629-180811
