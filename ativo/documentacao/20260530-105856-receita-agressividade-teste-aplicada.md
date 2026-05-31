# Receita de agressividade de teste — Mocha Arch

Gerado em: 20260530-105856

Este teste aumenta a agressividade da receita sem canonizar os valores.

## Valores aplicados

- vm.swappiness=100
- vm.vfs_cache_pressure=35
- vm.page-cluster=0
- vm.dirty_background_bytes=100663296
- vm.dirty_bytes=402653184
- vm.max_map_count=33554432
- kernel.sched_autogroup_enabled=0
- kernel.nmi_watchdog=0
- THP=madvise
- TuneD=latency-performance, se disponível
- CPU=performance, quando suportado pelo driver cpufreq
- NVIDIA persistence mode tentou ser ativado com nvidia-smi, se disponível
- ZRAM drop-in: zstd, zram-size=ram, swap-priority=32767, sem reiniciar ZRAM ativa durante a sessão

## Arquivos criados/alterados

- /etc/sysctl.d/99-mocha-agressividade-teste.conf
- /etc/systemd/system/mocha-thp-madvise.service
- /etc/systemd/system/mocha-cpu-performance.service
- /etc/systemd/zram-generator.conf.d/99-mocha-agressividade-teste.conf

## Relatórios

- Manual lido antes de editar: /media/mochafast/MochaArch/ativo/relatorios/20260530-105856-leitura-manual-antes-agressividade-teste.txt
- Estado antes: /media/mochafast/MochaArch/ativo/relatorios/20260530-105856-estado-antes-agressividade-teste.txt
- Estado depois: /media/mochafast/MochaArch/ativo/relatorios/20260530-105856-estado-depois-agressividade-teste.txt
- Log: /media/mochafast/MochaArch/ativo/relatorios/20260530-105856-aplicar-receita-agressividade-teste.log
- Rollback: /media/mochafast/MochaArch/ativo/scripts/20260530-105856-mocha-rollback-receita-agressividade-teste.sh

## Critério de teste

Testar jogos nos cenários:

1. Sem Launch Options.
2. gamemoderun %command%.
3. mangohud gamemoderun %command%.

Se aparecer stutter, queda de FPS, travamento ou piora de imagem/fluidez, rodar auditoria e comparar os relatórios antes/depois. O rollback está salvo no caminho indicado acima.
