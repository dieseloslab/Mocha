# MochaArch — Agressividade V3 candidata

Estado: candidata, precisa de teste prático antes de canonizar.

Objetivo: manter a agressividade atual de ZRAM/swap e importar ajustes úteis de cache, dirty writeback e mmap.

Valores:

vm.swappiness=133
vm.vfs_cache_pressure=50
vm.page-cluster=0
vm.dirty_background_bytes=67108864
vm.dirty_bytes=268435456
vm.max_map_count=16777216

THP enabled=madvise
THP defrag=defer+madvise

ZRAM=zstd
ZRAM size=ram
ZRAM priority=32767

TuneD=mocha-latency-performance

Observação: vm.dirty_background_bytes e vm.dirty_bytes substituem o uso ativo de vm.dirty_background_ratio e vm.dirty_ratio nesta receita.
