# Mocha — agressividade vigente aprovada em 2026-07-04

Este documento registra o estado de agressividade vigente para reconstrução do Mocha.

Não reutilizar presets antigos sem nova auditoria. O estado abaixo substitui referências antigas que apontavam para `vm.swappiness=133` ou para scripts de GameMode/OC anteriores como chamada primária.

## TuneD

Perfil ativo:

    mocha-latency-performance

Perfil instalado:

    /etc/tuned/profiles/mocha-latency-performance/tuned.conf

Cópia versionada no repo:

    configs/tuned/mocha-latency-performance/tuned.conf

Estado validado:

    tuned-adm verify

Resultado validado:

    Verification succeeded, current system settings match the preset profile.

Valores vigentes:

    vm.swappiness=150
    vm.vfs_cache_pressure=50
    vm.page-cluster=0
    vm.dirty_background_bytes=67108864
    vm.dirty_bytes=268435456
    vm.max_map_count=8388608

Observação:

    kernel.sched_autogroup_enabled não é obrigatório no LQX atual quando
    /proc/sys/kernel/sched_autogroup_enabled não existir.

## zram / swap / hibernação

Estado vigente:

    zram: zstd
    zram-size = ram
    swap-priority = 32767
    swap persistente NVMe: prioridade 0
    zswap.enabled=0
    resume=UUID aponta para swap persistente, nunca para zram

Swap persistente validada:

    UUID=c55827ce-1ead-4561-84c9-435612a8862b

## GameMode

Config vigente:

    /etc/gamemode.ini

Chamadas vigentes:

    start=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
    end=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system

Teste aprovado:

    gamemoderun deixa gamemoded -s ativo durante execução e inativo ao sair.

## OC NVIDIA via GameMode

Config efetiva:

    /etc/mocha/nvidia-game-oc.conf

Estado aprovado:

    MOCHA_NVIDIA_GAME_OC_ENABLE=1
    MOCHA_NVIDIA_GPU_OFFSET_MHZ=50
    MOCHA_NVIDIA_MEM_OFFSET_MHZ=250
    MOCHA_NVIDIA_POWER_LIMIT_POLICY=keep
    MOCHA_NVIDIA_FAN_POLICY=auto

Regra:

    O OC deve entrar apenas durante GameMode/jogo e deve zerar ao encerrar.
    Não aplicar +170/+200 como padrão universal.

## Critérios de aprovação para próxima montagem

Antes de considerar a montagem fechada:

    tuned-adm verify
    gamemoderun bash -lc 'gamemoded -s; sleep 3'
    swapon --show
    zramctl
    grep -E "swappiness|vfs_cache|page-cluster|dirty_background|dirty_bytes|max_map_count" /etc/tuned/profiles/mocha-latency-performance/tuned.conf

