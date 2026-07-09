<!-- MOCHA-CANONICO-MANGOHUD-GAMEMODE-NVIDIA-OC:BEGIN -->
## Mocha canonico - MangoHud e GameMode NVIDIA OC

### MangoHud aprovado

- Config ativa em runtime: ${HOME}/.config/MangoHud/mocha-active.conf.
- O wrapper Steam/Proton deve exportar MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf".
- Layout aprovado: uma linha, sem telemetria grafica extra.
- Ordem visual aprovada: FPS, latencia, CPU, GPU, VRAM, hora HH:MM e indicador GameMode.
- Validacao aceita: teste visual real dentro do jogo usando o wrapper Steam Mocha aprovado.

### GameMode NVIDIA OC aprovado

- OC NVIDIA existe somente durante GameMode.
- Metodo aprovado em Wayland/NVIDIA: NV-CONTROL via nvidia-settings executado por helper root.
- Helper aprovado: /usr/local/lib/mocha/mocha-nvidia-oc-root-helper.
- Hook start aprovado: /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system.
- Hook end aprovado: /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system.
- Start aplica core +50 e transfer-rate +400, equivalente a +200 MHz visivel em memclock.
- End reverte core 0 e memoria 0.
- Sudoers necessario: /etc/sudoers.d/mocha-nvidia-oc-root-helper.
- A validacao deve limpar os logs antes do teste para evitar falso negativo por tentativa antiga.

### Regra para futura instalacao

- Quem montar o Mocha deve aplicar apenas este fluxo canonico.
- Entradas antigas removidas deste manual ficam no Manual Legado.
- Manual Legado: ativo/documentacao/MANUAL-LEGADO-INFORMACOES-ULTRAPASSADAS.md.
<!-- MOCHA-CANONICO-MANGOHUD-GAMEMODE-NVIDIA-OC:END -->
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

<!-- MOCHA:KERNEL-CANONICO:INICIO -->
## Kernel canônico atual

Padrão atual do Mocha: Liquorix / linux-lqx.

Na montagem e instalação padrão do Mocha, instalar por padrão:

    linux-lqx
    linux-lqx-headers

Para NVIDIA, usar DKMS junto ao kernel lqx:

    nvidia-open-dkms
    nvidia-utils
    lib32-nvidia-utils

Regra operacional:

- linux-lqx é o kernel canônico atual do Mocha.
- linux-lqx-headers deve ser instalado junto com linux-lqx.
- O repo local canônico do lqx fica no VMSTORE:
  /media/vmstore/mocha-repo/local/kernel-liquorix/x86_64
- Nome do repo pacman local:
  mocha-lqx
- O repo Liquorix/lqx é repo-arquivo: baixar versões novas, mas nunca apagar versões antigas automaticamente.
- CachyOS fica como alternativa/teste/rollback, não como padrão enquanto lqx estiver aprovado.
- O Mocha Updater deve recomendar linux-lqx como kernel principal enquanto esta decisão estiver vigente.
<!-- MOCHA:KERNEL-CANONICO:FIM -->

<!-- MOCHA:REPO-LQX-SEMANAL:INICIO -->
## Atualização semanal do repo Liquorix/lqx

O repo Liquorix/lqx possui atualização semanal via systemd timer.

Script executável do sistema:
    /usr/local/sbin/mocha-atualiza-repo-liquorix-arquivo

Cópia canônica no FAST:
    /media/mochafast/MochaArch/scripts/repos/mocha-atualiza-repo-liquorix-arquivo-v1.sh

Service:
    /etc/systemd/system/mocha-repo-liquorix-update.service

Timer:
    /etc/systemd/system/mocha-repo-liquorix-update.timer

Agenda:
    segunda-feira, 04:30, com atraso aleatório de até 30 minutos

Repo atualizado:
    /media/vmstore/mocha-repo/local/kernel-liquorix/x86_64

Nome do repo pacman:
    mocha-lqx

Modo semanal:
    update

Modo de reparo sem download:
    rebuild-only

Comando manual para atualizar agora:
    sudo /usr/local/sbin/mocha-atualiza-repo-liquorix-arquivo update

Comando manual para apenas regenerar o banco:
    sudo /usr/local/sbin/mocha-atualiza-repo-liquorix-arquivo rebuild-only

Regra:
- baixar novas versões quando existirem;
- nunca apagar versões antigas automaticamente;
- manter manifesto;
- manter snapshot;
- não usar repo-add --files.
<!-- MOCHA:REPO-LQX-SEMANAL:FIM -->

## Reparo da substituição Liquorix/NVIDIA - 20260702-200647

Correção aplicada porque a primeira quarentena fez a parte principal, mas teve dois defeitos:

- referencias-antes.txt e referencias-depois.txt falharam por Permission denied;
- scripts de boot/instalação foram classificados de forma ampla demais como se fossem apenas sync de repo.

Mapeamento canônico corrigido:

- mocha-audita-repo-liquorix-remoto-nvidia-v1.sh -> /media/mochafast/MochaArch/scripts/mocha-audita-repo-liquorix-remoto-nvidia-v2.sh
- mocha-corrige-default-liquorix-grub-v1.sh -> /media/mochafast/MochaArch/scripts/mocha-define-lqx-padrao-boot-v3.sh
- mocha-define-liquorix-padrao-v1.sh -> /media/mochafast/MochaArch/scripts/mocha-define-lqx-padrao-boot-v3.sh
- mocha-instala-liquorix-nvidia-open-dkms-v1.sh -> /media/mochafast/MochaArch/scripts/mocha-instala-lqx-nvidia-casado-v2.sh
- mocha-liquorix-repo-binario-nvidia-dkms-v1.sh -> /media/mochafast/MochaArch/scripts/mocha-sincroniza-repo-liquorix-somente-lqx-v1.sh
- mocha-separa-repo-lqx-nvidia-v1.sh -> /media/mochafast/MochaArch/scripts/mocha-sincroniza-repo-liquorix-somente-lqx-v1.sh

Regra corrigida:

- Sync semanal Liquorix só atualiza/cacheia linux-lqx, linux-lqx-headers e opcionalmente linux-lqx-docs.
- Instalação LQX + NVIDIA usa script próprio: /media/mochafast/MochaArch/scripts/mocha-instala-lqx-nvidia-casado-v2.sh
- Boot/default LQX usa script próprio: /media/mochafast/MochaArch/scripts/mocha-define-lqx-padrao-boot-v3.sh
- NVIDIA continua em repo próprio: /media/vmstore/mocha-repo/local/nvidia/x86_64
- Liquorix continua em repo próprio: /media/vmstore/mocha-repo/local/kernel-liquorix/x86_64

Auditoria original:

- /media/vmstore/MochaArch/auditorias/quarentena-substituicao-scripts-lqx-nvidia-20260702-164718

Auditoria deste reparo:

- /media/vmstore/MochaArch/auditorias/repara-quarentena-lqx-nvidia-20260702-200647

## 20260703-114819 — Mocha Updater LQX/DKMS canônico

- Frontend Qt/Python preservado como interface canônica.
- Backend ajustado para tratar linux-lqx + linux-lqx-headers como kernel recomendado.
- NVIDIA ajustado para nvidia-open-dkms + nvidia-utils + lib32-nvidia-utils.
- CachyOS deixa de ser apresentado como padrão estável; permanece como histórico/fallback.
- Scripts antigos do updater movidos para quarentena em /media/mochafast/MochaArch/ativo/quarentena/mocha-updater-scripts-legados-20260703-114819.

<!-- MOCHA-PONTEIRO-AGRESSIVIDADE-VIGENTE-20260704-INICIO -->
## Agressividade vigente aprovada — 2026-07-04

A referência versionada para a agressividade vigente fica em:

    docs/AGRESSIVIDADE-VIGENTE-MOCHA-20260704.md

Pontos essenciais:

    vm.swappiness=150
    TuneD profile: mocha-latency-performance
    GameMode start: /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
    GameMode end: /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system
    OC NVIDIA efetivo: /etc/mocha/nvidia-game-oc.conf
    OC aprovado: core +50 / transfer-rate +400, equivalente a +200 MHz visivel em memclock

Não voltar automaticamente para presets antigos de agressividade.
<!-- MOCHA-PONTEIRO-AGRESSIVIDADE-VIGENTE-20260704-FIM -->

<!-- MOCHA-WALLPAPER-CANONICO-2026-07-04:START -->
## MOCHA-WALLPAPER-CANONICO-2026-07-04

Fonte canônica do wallpaper aprovado:

```text
/media/mochafast/MochaArch/ativo/assets/branding/wallpaper/
```

Regra: não escolher wallpaper a partir de imagens de Calamares, slides, screenshots, análises visuais, mosaicos, miniaturas ou diretórios de auditoria. A pasta acima é a única fonte canônica.

Wallpaper padrão atualmente selecionado para configurações:

```text
Wall.png
```

Caminhos de implantação:

```text
Fonte repo:
  ativo/assets/branding/wallpaper/

Payload sistema instalado:
  ativo/calamares/payload/tema-completo/usr/share/backgrounds/mocha/

Skel/local do usuário:
  ativo/calamares/payload/kde/skel/.local/share/backgrounds/mocha/

Caminho runtime esperado no sistema instalado:
  /usr/share/backgrounds/mocha/Wall.png
```

Configurações:

```text
Desktop Plasma:
  plasma-org.kde.plasma.desktop-appletsrc
  Image=file:///usr/share/backgrounds/mocha/Wall.png

Tela de bloqueio:
  kscreenlockerrc
  Image=file:///usr/share/backgrounds/mocha/Wall.png
  PreviewImage=file:///usr/share/backgrounds/mocha/Wall.png

SDDM:
  theme.conf.user do tema SDDM Mocha, quando presente no payload
  background=/usr/share/backgrounds/mocha/Wall.png
```
<!-- MOCHA-WALLPAPER-CANONICO-2026-07-04:END -->

<!-- MOCHA-STACK-GAMER-CANONICO:INI -->
## Stack gamer/software gamer canônico do Mocha

Lista canônica aprovada em 2026-07-04. Lutris não faz parte desta lista.

### Launchers / lojas / bibliotecas

- Steam
- Steam Mocha
- Faugus Launcher
- Heroic Games Launcher
- Legendary
- Bottles

### Proton / Wine / prefixos

- ProtonPlus
- ProtonUp
- ProtonUp-Qt
- Protontricks
- Wine
- Wine-Staging
- Winetricks
- Wine-GE / Proton-GE
- componentes Proton necessários

### Overlay / runtime / performance

- MangoHud
- GameMode
- Gamescope
- vkBasalt
- GOverlay
- LACT
- TuneD

### Vulkan / GPU / driver

- Vulkan
- utilitários Vulkan
- componentes Vulkan 64 bits
- componentes Vulkan 32 bits
- drivers NVIDIA
- utilitários NVIDIA
- DKMS NVIDIA

### Controles / periféricos / input

- input-remapper
- antimicrox
- oversteer
- piper
- ferramentas de mapeamento de mouse
- ferramentas de mapeamento de controle
- ferramentas de volante

### Aplicativos aprovados no perfil gamer

- OBS
- Kdenlive
- OnlyOffice

### Suporte do ecossistema Mocha

- Mocha Updater
- KDE Discover
- Flatpak
- Flathub
- UFW / GUFW

### Jogos casuais aprovados

- kmahjongg
- kpat
- kigo

### Regras

- Lutris não é item canônico.
- ProtonPlus é item explícito e obrigatório.
- ProtonUp e ProtonUp-Qt permanecem aprovados.
- Gamescope, vkBasalt e GOverlay fazem parte do stack gamer, mesmo que o wrapper Steam padrão não force esses recursos.
- KDE Discover fica preservado como suporte a Flatpak.
- Drivers/utilitários/DKMS NVIDIA entram quando houver GPU NVIDIA.
- Fonte auxiliar: `ativo/software/perfis/mocha-stack-gamer-canonico.txt`.
<!-- MOCHA-STACK-GAMER-CANONICO:FIM -->

<!-- MOCHA-CANONICO-SOFTWARE-E-LIMPEZA-INICIO -->

## Regra canônica Mocha — software que fica e limpeza obrigatória

Registro operacional atualizado em 2026-07-04.

### Canônicos que devem ser preservados

Em conversões Arch → Mocha e limpezas de menu/software, estes itens são canônicos ou suporte canônico e não devem ser removidos por engano:

- Firefox.
- Steam.
- Steam Mocha.
- Faugus Launcher.
- Heroic Games Launcher.
- Legendary.
- Bottles.
- ProtonPlus.
- ProtonUp.
- ProtonUp-Qt.
- Protontricks.
- Wine.
- Wine-Staging.
- Winetricks.
- Wine-GE / Proton-GE quando aplicável.
- MangoHud.
- GameMode.
- Gamescope.
- vkBasalt.
- GOverlay.
- LACT.
- TuneD.
- Vulkan e utilitários Vulkan.
- Componentes Vulkan 64 bits e 32 bits.
- Componentes Proton necessários.
- Drivers NVIDIA.
- Utilitários NVIDIA.
- DKMS NVIDIA quando aplicável ao kernel usado.
- input-remapper.
- antimicrox.
- oversteer.
- piper.
- Ferramentas de mapeamento de mouse.
- Ferramentas de mapeamento de controle.
- Ferramentas de volante.
- OBS.
- Kdenlive.
- OnlyOffice.
- Mocha Updater.
- KDE Discover, limitado ao suporte/gerenciamento de Flatpak.
- Flatpak.
- Flathub.
- UFW / GUFW.
- kmahjongg.
- kpat.
- kigo.

Observação bloqueante: Gamescope, vkBasalt e GOverlay fazem parte do stack gamer Mocha. Eles não fazem parte do wrapper Steam Mocha obrigatório, mas não devem ser removidos em limpeza do stack gamer.

### Remoção obrigatória do que não é Mocha

Toda conversão Arch → Mocha deve remover, ocultar ou quarentenar software, atalhos, widgets e entradas de menu que não façam parte do Mocha canônico, especialmente quando poluírem o menu ou duplicarem funções.

Itens explicitamente não canônicos ou removíveis quando aparecerem:

- Falkon.
- Konqueror.
- Angelfish.
- KDE Connect, quando mantido apenas por dependência de lixo não canônico.
- plasma-bigscreen.
- Launchers duplicados ou antigos que concorram com Steam Mocha.
- Entradas de menu duplicadas, quebradas, genéricas ou não aprovadas.
- Applets soltos duplicados de Volume/Bluetooth na barra.
- Widgets de painel que dupliquem funções já presentes no System Tray.

Regra de painel: a barra canônica deve expor apenas uma entrada de áudio/volume e uma entrada de Bluetooth, preferencialmente via System Tray. Applets soltos `org.kde.plasma.volume` e `org.kde.plasma.bluetooth` fora do System Tray devem ser removidos quando causarem duplicidade.

<!-- MOCHA-CANONICO-SOFTWARE-E-LIMPEZA-FIM -->

<!-- MOCHA-WRAPPER-STEAM-CANONICO-ALT-TAB-INPUT:BEGIN -->
## Mocha — Wrapper Steam canônico para Alt+Tab/input

**Registro:** `20260628-011105`

Este é o **verdadeiro wrapper Steam canônico do Mocha para Alt+Tab/input**.

**Fonte canônica:**

`/media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak`

**Destino runtime:**

`/usr/local/bin/mocha-steam-game-run`

**Linha oficial dos jogos Steam:**

`/usr/local/bin/mocha-steam-game-run %command%`

**SHA256 canônico:**

`3d58607f9f7c3bd1aaa8e3924a9f4eb7e1f13531bf64c10fd5587aec271b0235`

### Regra operacional obrigatória

- Este é o wrapper Steam canônico único para Alt+Tab/input.
- Não substituir por wrapper mínimo criado em 2026-06-28 ou posterior.
- Não escolher automaticamente o backup mais recente.
- Para perda de input após Alt+Tab, restaurar este wrapper primeiro.
- Separar Alt+Tab/input de MangoHud.
- Não mexer em prefixos Proton, `user.reg`, `compatdata` ou `localconfig` da Steam como primeira tentativa.
- Não promover outro wrapper como canônico sem validação explícita e registro manual novo.

### Comando de restauração canônico

`sudo install -Dm755 /media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak /usr/local/bin/mocha-steam-game-run`
<!-- MOCHA-WRAPPER-STEAM-CANONICO-ALT-TAB-INPUT:END -->


<!-- MOCHA-MANGOHUD-STEAM-RUNTIME-CONF-START -->
## MangoHud aprovado — Steam Runtime / Proton / wrapper Alt+Tab

Estado aprovado pelo teste real em jogo Steam/Proton em 2026-07-04:

- Esta é a configuração que funciona perfeitamente com o wrapper Alt+Tab do Mocha.
- Caminho ativo funcional do MangoHud no wrapper:
  - variável: MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf"
  - arquivo real por usuário: ~/.config/MangoHud/mocha-active.conf
- Motivo: dentro do Steam Runtime / pressure-vessel, o processo do jogo pode não aplicar visualmente o /usr/local/share/... do host.
- A validação correta é fechar e abrir novamente o jogo.
- Não depender de reload_cfg, Shift_L+F4 ou recarga em processo vivo.
- Steam aberta pelo atalho normal steam %U não garante herança da configuração Mocha.
- A abertura correta é via Steam Mocha ou launch option que use mocha-steam-game-run %command%.

Wrapper Steam Mocha / Alt+Tab deve preservar a lógica de input/Alt+Tab e exportar apenas o ambiente MangoHud necessário:

    export MANGOHUD=1
    export MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf"
    unset MANGOHUD_CONFIG
    unset MANGOHUD_DLSYM

Proibido no wrapper/config MangoHud:
- MANGOHUD_CONFIG= inline
- MANGOHUD_DLSYM

- gamescope
- vkBasalt
- graphs

Config aprovada:

    legacy_layout=0
    horizontal
    hud_no_margin
    position=top-left
    font_size=17
    round_corners=0
    background_alpha=0.35
    alpha=1.0

    time
    time_format="%H:%M"
    time_no_label

    fps
    frametime
    cpu_stats
    cpu_temp
    cpu_mhz
    gpu_stats
    gpu_temp
    gpu_core_clock
    gpu_mem_clock
    vram
    ram
    gamemode

    toggle_hud=Shift_R+F12
    reload_cfg=none

Regra operacional:

- Se o MangoHud voltar ao padrão, primeiro verificar o ambiente do processo e o namespace com /proc/<PID>/root.
- Não recriar wrapper.
- Não insistir em Shift_L+F4.
- Não voltar para /usr/local/share/... como caminho primário.
- Ajuste de fonte aprovado: font_size=17.
<!-- MOCHA-MANGOHUD-STEAM-RUNTIME-CONF-END -->
