# Seguimento do manual Mocha Arch - estado real

Data: 20260529-210855

Este relatório é somente leitura sobre o sistema, exceto pela criação deste próprio arquivo de auditoria.

## Mounts e fstab

- FAST: presente no /etc/fstab.
- VMSTORE: presente no /etc/fstab.

## Login manager

- Estado: active.
- Habilitado: alias.
- Alvo: /usr/lib/systemd/system/plasmalogin.service.

## Sessão gráfica

- Sessão: wayland.
- Desktop: KDE.

## Kernel e NVIDIA

- Kernel: 7.0.10-zen1-1-zen.
- NVIDIA: funcional: NVIDIA GeForce RTX 5060 Ti, 595.71.05.
- linux-zen: instalado.
- nvidia-open-dkms: instalado.

## Performance permanente

- tuned: enabled=enabled; active=active.
- power-profiles-daemon: enabled=not-found; active=inactive.
- cpupower: enabled=enabled; active=inactive.
- gamemoded: enabled=not-found; active=inactive.
- TuneD perfil: Current active profile: latency-performance .
- CPU governor atual: performance.
- zram: ativa.
NAME           TYPE       SIZE  PRIO
/dev/zram0     partition 15,4G 32767
/dev/nvme0n1p3 partition   17G    -1

## Barra KDE e ícones duplicados

- blueman-applet: autostart redundante desativado.
- kmix: autostart redundante desativado.
- Barra Win11/Mocha: pasta aprovada encontrada.

## Tema e cores

- ColorScheme atual: BreezeDark.
- Plasma Style atual: default.

## Manual/documentação ativa

- Documentos encontrados:
  - /media/mochafast/MochaArch/ativo/auditorias/20260529-210855-seguimento-manual-estado-real.md
  - /media/mochafast/MochaArch/ativo/documentacao/20260529-154304-MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
  - /media/mochafast/MochaArch/ativo/documentacao/20260529-175841-esquema-cores-kde-mocha-solid-canonico-aplicado.md
  - /media/mochafast/MochaArch/ativo/documentacao/20260529-180309-plasma-style-barra-mocha-aplicado.md
  - /media/mochafast/MochaArch/ativo/documentacao/manual-montagem-mochaarch.md
  - /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/MANUAL-BARRA-WIN11-MOCHA-APROVADA.md
  - /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/20260529-200013-TABELA-CORES-MOCHA-SOLID-CANONICO.md
  - /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/TABELA-CORES-MOCHA-SOLID-CANONICO.md
  - /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md
  - /media/mochafast/MochaArch/ativo/logs/20260529-154304-evidencias-extraidas-para-manual.md
  - /media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
  - /media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md
  - /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-auditoria-geral-pre-formatacao-mochaarch.md
  - /media/mochafast/MochaArch/ativo/relatorios/20260529-205350-auditoria-seguimento-manual-pos-congelamento.md

## Próximo passo sugerido

- reaplicar tema Mocha aprovado
