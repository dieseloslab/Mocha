# MochaArch — agressividade aprovada: zram + swap física baixa prioridade

Data: 20260604-094348

## Estado aprovado

A configuração aprovada para memória/swap do MochaArch é:

- zram ativa como swap principal.
- zram com algoritmo zstd.
- zram com prioridade máxima: 32767.
- swap física em disco permitida.
- swap física deve ficar sempre com prioridade baixa em relação à zram.
- Prioridade negativa/default baixa da swap física é aceita.
- O estado PRIO -1 para swap física é aprovado quando a zram está em PRIO 32767.
- Não forçar pri=0 para a swap física, pois 0 é maior que -1 e não melhora o objetivo.
- A swap física serve apenas como fallback quando a zram estourar.
- FAST e VMSTORE devem permanecer persistentes, visíveis no Dolphin e montados por UUID.

## Critério objetivo aprovado

Estado aceito:

/dev/zram0      PRIO 32767  prioridade máxima
swap física     PRIO -1     prioridade baixa/default negativa aceita

## Estado validado na auditoria

A auditoria validou:

- /dev/zram0 ativa como [SWAP].
- algoritmo zstd selecionado.
- prioridade da zram em 32767.
- swap física /dev/nvme0n1p3 ativa, sem uso, com PRIO -1.
- FAST em /media/mochafast montado por UUID.
- VMSTORE em /media/vmstore montado por UUID.
- diretórios FAST/VMSTORE com dono hal:hal.
- sysctl de agressividade aplicado.
- THP em madvise.

## Regra operacional

Em próximas correções, não recriar nem reconfigurar sysfs de /dev/zram0 se ela já estiver ativa. Não escrever em comp_algorithm nem disksize com zram em uso, pois o kernel bloqueia como dispositivo ocupado.

Se a zram já estiver ativa com zstd, [SWAP] e PRIO 32767, preservar a zram em execução e ajustar apenas persistência e documentação.

