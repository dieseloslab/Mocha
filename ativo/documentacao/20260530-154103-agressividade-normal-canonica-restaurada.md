# MochaArch — agressividade normal/canônica restaurada

Data: 20260530-154103

## Valores aplicados

- `vm.swappiness=80`
- `vm.vfs_cache_pressure=50`
- `vm.page-cluster=0`
- `vm.dirty_background_bytes=67108864`
- `vm.dirty_bytes=268435456`
- `vm.max_map_count=16777216`
- THP: `madvise`
- zram: `zstd`, tamanho `100% da RAM`, prioridade `32767`
- TuneD: `latency-performance`, quando disponível
- CPU governor: `performance`, quando `cpupower` está disponível

## Arquivos ativos

- `/etc/sysctl.d/zz-mocha-agressividade-normal.conf`
- `/etc/tmpfiles.d/mocha-thp.conf`
- `/etc/systemd/zram-generator.conf`

## Aplicação ao vivo

- Sysctl aplicado ao vivo: sim.
- THP aplicado ao vivo: sim.
- TuneD aplicado ao vivo se instalado: sim.
- zram reiniciado ao vivo: não.

Motivo caso zram não tenha sido reiniciado:

`zram possui 874917888 bytes em uso; não reiniciei para evitar travamento. A configuração entra completa no próximo boot.`

## Observação para teste de FPS

Para comparação limpa, testar primeiro sem Launch Options extras na Steam ou somente com a linha oficial que estiver sendo avaliada no momento. Se zram não foi reiniciado ao vivo, reiniciar antes de considerar o teste final da receita normal.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260530-154103-mocha-restaurar-agressividade-normal.sh`

## Log

`/media/mochafast/MochaArch/ativo/relatorios/20260530-154103-mocha-agressividade-normal.log`
