<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_START -->
## TuneD canônico Mocha: mocha-latency-performance

Perfil canônico: `mocha-latency-performance`.

Caminho no sistema instalado:

    /etc/tuned/profiles/mocha-latency-performance/tuned.conf

Script canônico V2:

    /media/mochafast/MochaArch/scripts/mocha-tuned-latency-performance-v2.sh

Como aplicar/reaplicar:

    sudo bash /media/mochafast/MochaArch/scripts/mocha-tuned-latency-performance-v2.sh

Regra canônica:

    TuneD mantém o chão permanente de baixa latência/performance.
    system76-scheduler administra responsividade normal do desktop.
    GameMode assume autoridade máxima durante jogos.
    Ao fechar o jogo, GameMode reverte ajustes temporários e o sistema volta ao estado normal.

A V2 não herda `latency-performance` por `include=`, porque o perfil base do TuneD fixa `vm.swappiness=10`, enquanto o Mocha usa `vm.swappiness=133`. A V2 copia diretamente os ajustes úteis de CPU/latência e aplica os sysctl Mocha uma única vez.

Ajustes permanentes do perfil:

    CPU governor: performance
    CPU boost: 1
    CPU force_latency: cstate.id_no_zero:1|3
    ACPI platform_profile: performance
    vm.swappiness=133
    vm.vfs_cache_pressure=50
    vm.page-cluster=0
    vm.dirty_background_bytes=67108864
    vm.dirty_bytes=268435456
    vm.max_map_count=8388608
    kernel.sched_autogroup_enabled=1

Regra: o perfil TuneD não deve ser mais fraco que a base exigida pelo GameMode. Durante jogo, GameMode prevalece.
<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_END -->

<!-- MOCHA_GAMEMODE_SYSTEM76_AUTHORITY_START -->
## Autoridade de performance: GameMode sobre system76-scheduler

Script canônico V2:

    /media/mochafast/MochaArch/scripts/mocha-gamemode-system76-authority-v2-tuned-reassert.sh

Arquivos de sistema:

    /usr/local/sbin/mocha-system76-authority-helper
    /etc/sudoers.d/mocha-gamemode-system76-authority
    /etc/gamemode.ini
    /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
    /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system

Regra canônica:

    TuneD mantém o perfil permanente mocha-latency-performance.
    system76-scheduler gerencia responsividade normal do desktop fora dos jogos.
    Quando GameMode entra, GameMode vira autoridade principal.
    Durante jogo, o helper Mocha pausa o system76-scheduler para evitar disputa de prioridade.
    Ao fechar o jogo, o wrapper V2 executa o legacy end, reasserta o TuneD mocha-latency-performance, religa o system76-scheduler somente se ele estava ativo antes, e reasserta o TuneD novamente.

Motivo da V2:

    Na validação pós-jogo, GameMode encerrou corretamente, system76 voltou e OC NVIDIA reverteu, mas tuned-adm verify ficou sujo. A V2 força o retorno ao chão permanente mocha-latency-performance no final da sessão de jogo.

Estado/runtime:

    /run/mocha/gamemode-authority
    /var/log/mocha-gamemode-system76-authority.log
    /tmp/mocha-gamemode-authority-$USER.log

Como reaplicar:

    sudo bash /media/mochafast/MochaArch/scripts/mocha-gamemode-system76-authority-v2-tuned-reassert.sh

Como verificar durante jogo:

    timeout 10 gamemoded -s
    sudo /usr/local/sbin/mocha-system76-authority-helper status
    timeout 10 systemctl is-active com.system76.Scheduler.service
    timeout 20 tuned-adm verify

Como verificar após fechar jogo:

    timeout 10 gamemoded -s
    sudo /usr/local/sbin/mocha-system76-authority-helper status
    timeout 10 systemctl is-active com.system76.Scheduler.service
    timeout 20 tuned-adm verify
<!-- MOCHA_GAMEMODE_SYSTEM76_AUTHORITY_END -->

<!-- MOCHA:ROLLBACK-GAMEMODE-NVIDIA:BEGIN -->

## Validação canônica pós-jogo — GameMode/OC NVIDIA

Status: **aprovado em 2026-07-01**.

Esta validação confirma que o perfil gamer do Mocha aplica agressividade durante o jogo e reverte corretamente ao fechar o jogo.

Script canônico:

    /media/mochafast/MochaArch/scripts/mocha-confere-rollback-pos-jogo-gamemode-nvidia.sh

Quando usar:

- depois de trocar kernel;
- depois de trocar driver NVIDIA;
- depois de alterar GameMode;
- depois de alterar wrapper Steam;
- depois de alterar OC NVIDIA;
- depois de alterar TuneD/system76 Scheduler;
- depois de regressão de FPS, travamento, temperatura, clock ou consumo.

Critério de aprovação pós-jogo:

- `gamemode is inactive`;
- GPU fora de `P0`, normalmente `P8` ou `P3`;
- `GPUGraphicsClockOffsetAllPerformanceLevels = 0`;
- `GPUMemoryTransferRateOffsetAllPerformanceLevels = 0`;
- power baixo em idle;
- clocks baixos em idle.

Resultado de referência aprovado em 2026-07-01:

    Durante jogo:
    - 60 amostras
    - GameMode ativo: 100%
    - P0: 60/60
    - GPU util média/máx: 74.8% / 88.0%
    - CPU busy média/máx: 44.6% / 49.0%
    - Power média/máx: 118.6W / 133.3W
    - Temperatura média/máx: 57.8C / 62.0C
    - VRAM média/máx: 7581MiB / 8385MiB
    - OC NVIDIA ativo: graphics offset 50, memory offset 250

    Pós-jogo:
    - gamemode is inactive
    - RTX 5060 Ti em P8
    - clocks 397/405 MHz
    - power 11.70W
    - temperatura 37C
    - GPU util 1%
    - VRAM 409/16311 MiB
    - offsets NVIDIA revertidos para 0/0

Observação: `GPUPowerMizerMode` pode consultar como `0`. Não tratar isso como falha enquanto o comportamento real estiver correto: P0 durante jogo, offsets aplicados durante jogo, clocks altos durante jogo e rollback para offsets `0/0` após fechar o jogo.

<!-- MOCHA:ROLLBACK-GAMEMODE-NVIDIA:END -->


<!-- MOCHA:BLUETOOTH-TRAY-DUPLICADO:BEGIN -->

## Bluetooth na bandeja — evitar gerenciador duplicado

Regra de montagem: o Mocha deve iniciar com apenas um gerenciador visual de Bluetooth na bandeja do KDE.

Decisão canônica:

- manter `bluez` e `bluez-utils`;
- manter o serviço `bluetooth`;
- manter o applet nativo do KDE/BlueDevil;
- desativar o autostart do `blueman-applet`;
- não remover `blueman` por padrão, apenas impedir duplicidade visual e consumo desnecessário.

Script canônico:

    /media/mochafast/MochaArch/scripts/mocha-corrige-duplicidade-bluetooth-tray-v1.sh

Aplicação esperada na montagem:

- criar override em `$HOME/.config/autostart/blueman.desktop` com `Hidden=true`;
- criar o mesmo override em `/etc/skel/.config/autostart/blueman.desktop` para novos usuários;
- preservar `bluetooth.service` ativo;
- preservar BlueDevil/KDE como gerenciador principal.

Critério esperado no sistema instalado:

- apenas um ícone/gerenciador Bluetooth na bandeja;
- `systemctl is-active bluetooth` retorna `active`;
- `blueman-applet` não inicia automaticamente;
- Bluetooth continua funcional pelo KDE.

<!-- MOCHA:BLUETOOTH-TRAY-DUPLICADO:END -->

