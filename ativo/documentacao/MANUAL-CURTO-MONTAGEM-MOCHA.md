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
- Metodo aprovado em Wayland/NVIDIA: NVML executado por helper root.
- Helper aprovado: /usr/local/lib/mocha/mocha-nvidia-oc-root-helper.
- Hook start aprovado: /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system.
- Hook end aprovado: /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system.
- Start aplica core +50 e memoria +250.
- End reverte core 0 e memoria 0.
- Sudoers necessario: /etc/sudoers.d/mocha-nvidia-oc-root-helper.
- A validacao deve limpar os logs antes do teste para evitar falso negativo por tentativa antiga.

### Regra para futura instalacao

- Quem montar o Mocha deve aplicar apenas este fluxo canonico.
- Entradas antigas removidas deste manual ficam no Manual Legado.
- Manual Legado: ativo/documentacao/MANUAL-LEGADO-INFORMACOES-ULTRAPASSADAS.md.
<!-- MOCHA-CANONICO-MANGOHUD-GAMEMODE-NVIDIA-OC:END -->
<!-- MOCHA-SOFTWARES-BARRA-BEGIN -->
## Barra KDE e lista canônica de softwares

Atualizado em: 20260703-164059

### Barra KDE

Formato/layout da barra e cor/paleta são separados.

Contrato:
- /media/mochafast/MochaArch/ativo/documentacao/CONTRATO-BARRA-KDE-MOCHA.md

Auditoria dos scripts candidatos:
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/candidatos-script-barra.txt
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/candidatos-script-barra-preview.txt

Regra:
- usar o script aprovado existente para formato/layout;
- não mexer na cor dentro desse script;
- cor vem do contrato visual KDE/paleta.

### Softwares Mocha

Contrato:
- /media/mochafast/MochaArch/ativo/documentacao/CONTRATO-SOFTWARES-MOCHA.md

Listas:
- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-keep-base.txt
- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-remove-candidatos.txt
- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-review.txt

Auditoria desta máquina:
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/pacotes-explicitos.txt
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/remove-candidatos-instalados.txt
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/review-instalados.txt

Regra:
- transformar Arch normal em Mocha por script e listas versionadas;
- não depender de memória;
- não remover pacote sem passar pela lista canônica e revisão.
<!-- MOCHA-SOFTWARES-BARRA-END -->

<!-- MOCHA-BARRA-KDE-SCRIPT-APROVADO-BEGIN -->
## Script aprovado de formato/layout da barra KDE

Atualizado em: 20260703-165625

### Caminho aprovado original

- /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh

### Hash aprovado

- SHA256: 3212dfa72c464a649b5f4affb080544995e6199d9987450a73a3fcbb037ae5a4

### Caminhos canônicos

- FAST: /media/mochafast/MochaArch/ativo/kde/mocha-kde-barra-layout-aprovado.sh
- Nota: /media/mochafast/MochaArch/ativo/kde/mocha-kde-barra-layout-aprovado-nota.txt
- Sistema instalado: /usr/local/share/mocha/kde/mocha-kde-barra-layout-aprovado.sh
- Comando estável: /usr/local/bin/mocha-kde-barra-layout-aprovado

### O que altera

- arquivo do painel do usuário em HOME/.config/plasma-org.kde.plasma.desktop-appletsrc;
- ordem dos applets do painel via AppletOrder;
- dois espaçadores expansíveis org.kde.plasma.panelspacer;
- centralização de Kickoff/Iniciar e icontasks/taskmanager;
- manutenção de systemtray, digitalclock e showdesktop à direita;
- reinício somente do plasmashell.

### O que não altera

- não altera cor da barra;
- não altera tema/paleta KDE;
- não instala pacotes;
- não mexe em kernel;
- não mexe em NVIDIA;
- não mexe em boot.

### Comando de execução

mocha-kde-barra-layout-aprovado

### Regra

Formato/layout da barra e cor/paleta continuam separados. Este script é somente para layout/formato da barra. A cor deve vir do tema/paleta KDE Mocha canônica.
<!-- MOCHA-BARRA-KDE-SCRIPT-APROVADO-END -->

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
    OC aprovado: core +50 / mem +250

Não voltar automaticamente para presets antigos de agressividade.
<!-- MOCHA-PONTEIRO-AGRESSIVIDADE-VIGENTE-20260704-FIM -->


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

Proibido no wrapper/config MangoHud:

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

<!-- MOCHA_MANUAL_CURTO_GAMEMODE_OC_NVIDIA_NVML_START -->

## GameMode OC NVIDIA NVML — canônico

Validado em runtime em 2026-07-05 no host `derp-x8664`.

O OC NVIDIA do Mocha deve ser aplicado somente junto com GameMode. Não aplicar OC permanente solto.

Pacote canônico:

`gamemode-oc-nvidia-nvml`

Caminho público:

`/media/mochafast/MochaArch/scripts/performance/gamemode-oc-nvidia-nvml`

Caminho interno:

`/media/mochafast/MochaArch-Interno/ativo/performance/gamemode-oc-nvidia-nvml`

Instalador:

`mocha-aplica-gamemode-oc-nvidia-nvml.sh`

Arquivos runtime canônicos:

`/etc/mocha/nvidia-game-oc.conf`

`/etc/sudoers.d/mocha-nvidia-oc-root-helper`

`/usr/local/lib/mocha/mocha-nvidia-oc-root-helper`

`/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system`

`/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system`

Integração obrigatória em `/etc/gamemode.ini`:

`[custom]`

`start=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system`

`end=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system`

Permissões validadas:

`root:root 644 /etc/mocha/nvidia-game-oc.conf`

`root:root 440 /etc/sudoers.d/mocha-nvidia-oc-root-helper`

`root:root 755 /usr/local/lib/mocha/mocha-nvidia-oc-root-helper`

`root:root 755 /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system`

`root:root 755 /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system`

`root:root 644 /etc/gamemode.ini`

O sudoers precisa passar em:

`visudo -cf /etc/sudoers.d/mocha-nvidia-oc-root-helper`

Proibido usar como método canônico novo:

`gamemode-ionice-oc-nvidia`

`gamemode-start-agressivo-oc.sh`

`gamemode-end-agressivo-oc.sh`

`nvidia-settings -a`

`GPUGraphicsClockOffset`

`GPUMemoryTransferRateOffset`

`GPUPowerMizerMode`

Não substituir o helper NVML por wrapper improvisado.

Não documentar nova alteração como canônica sem teste real de runtime e aprovação explícita.

<!-- MOCHA_MANUAL_CURTO_GAMEMODE_OC_NVIDIA_NVML_END -->

<!-- MOCHA:SYSTRAY-DUPLICIDADE-PREREQ:BEGIN -->
## Pré-requisito de montagem — systray sem duplicidade de volume e Bluetooth

Status: obrigatório para matriz, live ISO e sistema instalado.

Problema que esta regra corrige:

- Dois ícones de volume no systray.
- Dois ícones de Bluetooth no systray.
- Duplicidade causada por applet nativo do KDE junto de applet externo iniciado no login.

Regra canônica Mocha:

- Volume canônico no systray: applet nativo do KDE/Plasma, via plasma-pa.
- Bluetooth canônico no systray: applet nativo do KDE/Plasma/BlueDevil.
- Não iniciar KMix como ícone paralelo de volume.
- Não iniciar Blueman Applet como ícone paralelo de Bluetooth.
- Não remover BlueZ, bluetooth.service, PipeWire, PulseAudio ou backend de áudio por causa de ícone duplicado.
- A correção deve ser por override XDG Autostart com Hidden=true para os duplicadores.
- A correção deve ser aplicada no usuário atual e em /etc/skel para novos usuários criados pelo instalador.

Script canônico salvo:

    /media/mochafast/MochaArch-Interno/ativo/scripts/mocha-desativa-duplicidade-systray-volume-bluetooth.sh

Uso na matriz antes de congelar imagem ou antes de validar a ISO:

    /media/mochafast/MochaArch-Interno/ativo/scripts/mocha-desativa-duplicidade-systray-volume-bluetooth.sh

O script faz somente isto:

- cria override de autostart para blueman.desktop;
- cria override de autostart para blueman-applet.desktop;
- cria override de autostart para kmix_autostart.desktop;
- cria override de autostart para org.kde.kmix.desktop;
- cria override de autostart para org.kde.kmix.autostart.desktop;
- replica os overrides em /etc/skel/.config/autostart;
- encerra blueman-applet e kmix se estiverem rodando na sessão atual;
- não remove pacotes;
- não altera backend de áudio;
- não desativa bluetooth.service;
- não mexe no applet nativo do KDE.

Validação esperada após logout/login ou reinício do Plasma:

    pgrep -a -f '/usr/bin/blueman-applet|blueman-applet|/usr/bin/kmix|(^|[[:space:]])kmix([[:space:]]|$)'

Resultado esperado: nenhum processo blueman-applet ou kmix iniciado automaticamente. O systray deve manter apenas um volume e um Bluetooth.

Evidência local que motivou a regra:

- auditoria: /media/mochafast/MochaArch-Interno/ativo/auditorias/auditoria-systray-volume-blue-duplicado-derp-x8664-20260705-201229.txt
- correção/manualização: /media/mochafast/MochaArch-Interno/ativo/auditorias/manualiza-systray-duplicidade-derp-x8664-20260705-203741
<!-- MOCHA:SYSTRAY-DUPLICIDADE-PREREQ:END -->

<!-- MOCHA:RUNTIME-REPRODUTIVEL:INICIO -->
## Snapshot runtime reproduzível da máquina Mocha atual

Data da captura: 20260708-154027
Host de origem: derp-x8664
Usuário de origem usado para template HOME: hal

### Objetivo desta seção

Esta seção existe para permitir reconstruir o runtime aprovado do Mocha mesmo sem memória externa, histórico de conversa ou decisões implícitas.

Ela cobre o conjunto de arquivos que transforma uma instalação nova do Calam Arch em uma base Mocha reproduzível no que depende de runtime local:

- wrapper Steam Mocha;
- hooks e biblioteca Mocha em `/usr/local/lib/mocha`;
- GameMode e OC NVIDIA via helper aprovado;
- MangoHud ativo por usuário;
- tema KDE, KWin, sessão Plasma, barra Plasma e esquemas de cor;
- SDDM;
- `/etc/skel` usado para novos usuários;
- temas SDDM presentes no sistema.

Esta seção não substitui a instalação dos pacotes do stack gamer, kernels, drivers, Calamares, Flatpaks ou repositórios. Ela pressupõe que as seções próprias do manual curto já instalaram a base de software. Aqui ficam os arquivos de runtime que não devem ser recriados por memória.

### Fonte de verdade

Snapshot canônico candidato:

    /media/mochafast/MochaArch-Interno/ativo/snapshots/runtime-reprodutivel-mocha-derp-x8664-20260708-154027

Manifestos do snapshot:

    /media/mochafast/MochaArch-Interno/ativo/snapshots/runtime-reprodutivel-mocha-derp-x8664-20260708-154027/manifestos/ALVOS-CRITICOS.tsv
    /media/mochafast/MochaArch-Interno/ativo/snapshots/runtime-reprodutivel-mocha-derp-x8664-20260708-154027/manifestos/MANIFESTO-SNAPSHOT.tsv

Regra: se existir arquivo no snapshot, restaurar o arquivo real. Não recriar equivalente parecido.

### Árvore esperada do snapshot

    runtime/
      usr/local/bin/mocha-steam-game-run
      usr/local/lib/mocha/
      etc/gamemode.ini
      etc/sddm.conf.d/
      etc/skel/
      usr/share/sddm/themes/

    home-user-template/
      hal/.config/MangoHud/mocha-active.conf
      hal/.config/plasma-org.kde.plasma.desktop-appletsrc
      hal/.config/kdeglobals
      hal/.config/kwinrc
      hal/.config/ksmserverrc
      hal/.local/share/color-schemes/

### Ausências registradas na captura

Os itens abaixo estavam ausentes na máquina de origem no momento da captura e não devem ser inventados durante restauração:

- `/etc/mocha/skel`;
- `/usr/share/mocha/skel`;
- `/home/hal/.local/share/wallpapers`.

Se algum desses itens passar a ser necessário, abrir nova auditoria, capturar o arquivo real aprovado e só depois atualizar esta seção.

### Hashes críticos conhecidos

Arquivos críticos capturados:

- `runtime/usr/local/bin/mocha-steam-game-run`
  - SHA256: `d2517c0fb53b5955744128bdb498581cc117ed277e8e671a90761c8bbc78e7b6`
  - dono esperado no sistema instalado: `root:root`
  - modo esperado: `755`

- `runtime/etc/gamemode.ini`
  - SHA256: `a1931485550ae90d23ba00f752be652c0b3925342d75b07da6c3fb9dd26e090b`
  - dono esperado no sistema instalado: `root:root`
  - modo esperado: `644`

- `home-user-template/hal/.config/MangoHud/mocha-active.conf`
  - SHA256: `f176609653b7a5dec8b8d6832177d32e92dbbc7bf4c05aa662cae8d4db85593c`
  - dono esperado no sistema instalado: usuário final
  - modo esperado: `644`

- `home-user-template/hal/.config/plasma-org.kde.plasma.desktop-appletsrc`
  - SHA256: `13536ad388836ab5b6bd1acc08c654f1024075500a40283e98a7847d5ec3573d`
  - dono esperado no sistema instalado: usuário final
  - modo esperado: `644`

- `home-user-template/hal/.config/kdeglobals`
  - SHA256: `d935ab13ffd4c457cc5ff1eaaa96eaec5ea9f2c6226e378801844a7df177c568`
  - dono esperado no sistema instalado: usuário final
  - modo esperado: `644`

- `home-user-template/hal/.config/kwinrc`
  - SHA256: `63767f229c99e5c40f77ad60e9509c064d29ca48b71983660e316ce48d4324dc`
  - dono esperado no sistema instalado: usuário final
  - modo esperado: `644`

- `home-user-template/hal/.config/ksmserverrc`
  - SHA256: `cc856e3e06584d8d2e29641090177faa256affe2227a658e45d699274155a4ae`
  - dono esperado no sistema instalado: usuário final
  - modo esperado: `600`

Diretórios críticos devem ser conferidos pelo manifesto:

- `runtime/usr/local/lib/mocha`;
- `runtime/etc/sddm.conf.d`;
- `runtime/etc/skel`;
- `runtime/usr/share/sddm/themes`;
- `home-user-template/hal/.local/share/color-schemes`.

### Procedimento de aplicação em uma instalação nova do Calam Arch

Antes de executar, trocar `NOME_DO_USUARIO_FINAL` pelo usuário real criado na instalação.

Executar depois que o sistema base, KDE Plasma Wayland, SDDM, GameMode, MangoHud, Steam, driver NVIDIA e stack gamer já estiverem instalados pelas seções próprias do manual.

    SNAPSHOT="/media/mochafast/MochaArch-Interno/ativo/snapshots/runtime-reprodutivel-mocha-derp-x8664-20260708-154027"
    TARGET_USER="NOME_DO_USUARIO_FINAL"
    TARGET_HOME="/home/${TARGET_USER}"
    TARGET_GROUP="$(id -gn "$TARGET_USER")"

    test -d "$SNAPSHOT"
    test -d "$TARGET_HOME"
    test -n "$TARGET_GROUP"

Validar presença dos manifestos:

    test -f "$SNAPSHOT/manifestos/ALVOS-CRITICOS.tsv"
    test -f "$SNAPSHOT/manifestos/MANIFESTO-SNAPSHOT.tsv"

Validar hashes dos arquivos críticos antes de instalar:

    HASHES_TMP="$(mktemp)"
    printf '%s  %s\n' > "$HASHES_TMP" \
      'd2517c0fb53b5955744128bdb498581cc117ed277e8e671a90761c8bbc78e7b6' "$SNAPSHOT/runtime/usr/local/bin/mocha-steam-game-run" \
      'a1931485550ae90d23ba00f752be652c0b3925342d75b07da6c3fb9dd26e090b' "$SNAPSHOT/runtime/etc/gamemode.ini" \
      'f176609653b7a5dec8b8d6832177d32e92dbbc7bf4c05aa662cae8d4db85593c' "$SNAPSHOT/home-user-template/hal/.config/MangoHud/mocha-active.conf" \
      '13536ad388836ab5b6bd1acc08c654f1024075500a40283e98a7847d5ec3573d' "$SNAPSHOT/home-user-template/hal/.config/plasma-org.kde.plasma.desktop-appletsrc" \
      'd935ab13ffd4c457cc5ff1eaaa96eaec5ea9f2c6226e378801844a7df177c568' "$SNAPSHOT/home-user-template/hal/.config/kdeglobals" \
      '63767f229c99e5c40f77ad60e9509c064d29ca48b71983660e316ce48d4324dc' "$SNAPSHOT/home-user-template/hal/.config/kwinrc" \
      'cc856e3e06584d8d2e29641090177faa256affe2227a658e45d699274155a4ae' "$SNAPSHOT/home-user-template/hal/.config/ksmserverrc"
    sha256sum -c "$HASHES_TMP"
    rm -f "$HASHES_TMP"

Instalar arquivos de sistema:

    sudo install -Dm755 "$SNAPSHOT/runtime/usr/local/bin/mocha-steam-game-run" /usr/local/bin/mocha-steam-game-run
    sudo mkdir -p /usr/local/lib/mocha
    sudo rsync -a "$SNAPSHOT/runtime/usr/local/lib/mocha/" /usr/local/lib/mocha/
    sudo install -Dm644 "$SNAPSHOT/runtime/etc/gamemode.ini" /etc/gamemode.ini

Instalar configurações de SDDM e skeleton do sistema sem apagar conteúdo extra existente:

    sudo mkdir -p /etc/sddm.conf.d
    sudo rsync -a "$SNAPSHOT/runtime/etc/sddm.conf.d/" /etc/sddm.conf.d/

    sudo mkdir -p /etc/skel
    sudo rsync -a "$SNAPSHOT/runtime/etc/skel/" /etc/skel/

    sudo mkdir -p /usr/share/sddm/themes
    sudo rsync -a "$SNAPSHOT/runtime/usr/share/sddm/themes/" /usr/share/sddm/themes/

Instalar arquivos do usuário final a partir do template capturado de `hal`:

    sudo install -o "$TARGET_USER" -g "$TARGET_GROUP" -Dm644 "$SNAPSHOT/home-user-template/hal/.config/MangoHud/mocha-active.conf" "$TARGET_HOME/.config/MangoHud/mocha-active.conf"
    sudo install -o "$TARGET_USER" -g "$TARGET_GROUP" -Dm644 "$SNAPSHOT/home-user-template/hal/.config/plasma-org.kde.plasma.desktop-appletsrc" "$TARGET_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    sudo install -o "$TARGET_USER" -g "$TARGET_GROUP" -Dm644 "$SNAPSHOT/home-user-template/hal/.config/kdeglobals" "$TARGET_HOME/.config/kdeglobals"
    sudo install -o "$TARGET_USER" -g "$TARGET_GROUP" -Dm644 "$SNAPSHOT/home-user-template/hal/.config/kwinrc" "$TARGET_HOME/.config/kwinrc"
    sudo install -o "$TARGET_USER" -g "$TARGET_GROUP" -Dm600 "$SNAPSHOT/home-user-template/hal/.config/ksmserverrc" "$TARGET_HOME/.config/ksmserverrc"

Instalar esquemas de cor do KDE, se presentes no snapshot:

    if [ -d "$SNAPSHOT/home-user-template/hal/.local/share/color-schemes" ]; then
      sudo mkdir -p "$TARGET_HOME/.local/share/color-schemes"
      sudo rsync -a --chown="$TARGET_USER:$TARGET_GROUP" "$SNAPSHOT/home-user-template/hal/.local/share/color-schemes/" "$TARGET_HOME/.local/share/color-schemes/"
    fi

Reaplicar dono do HOME apenas nos caminhos tocados por esta seção:

    sudo chown -R "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.config/MangoHud"
    sudo chown "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    sudo chown "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.config/kdeglobals"
    sudo chown "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.config/kwinrc"
    sudo chown "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.config/ksmserverrc"
    if [ -d "$TARGET_HOME/.local/share/color-schemes" ]; then
      sudo chown -R "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.local/share/color-schemes"
    fi

Reiniciar GameMode depois de restaurar `/etc/gamemode.ini`:

    sudo systemctl restart gamemoded.service

### Validação pós-aplicação

Validar wrapper Steam Mocha:

    test -x /usr/local/bin/mocha-steam-game-run
    grep -E 'MANGOHUD|SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS|MouseWarpOverride' /usr/local/bin/mocha-steam-game-run

Validar GameMode e hooks de OC NVIDIA:

    grep -E '^[[:space:]]*(start|end)[[:space:]]*=' /etc/gamemode.ini
    gamemoded -t

Validar MangoHud ativo do usuário final:

    test -f "$TARGET_HOME/.config/MangoHud/mocha-active.conf"
    grep -Ev '^[[:space:]]*(#|$)' "$TARGET_HOME/.config/MangoHud/mocha-active.conf"

Validar arquivos KDE principais:

    test -f "$TARGET_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    test -f "$TARGET_HOME/.config/kdeglobals"
    test -f "$TARGET_HOME/.config/kwinrc"
    test -f "$TARGET_HOME/.config/ksmserverrc"

    grep -E 'plugin=|immutability=|formfactor=' "$TARGET_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" | head -80
    grep -E '^\[|ColorScheme|LookAndFeelPackage|widgetStyle|SingleClick' "$TARGET_HOME/.config/kdeglobals"
    grep -E '^\[|BorderlessMaximizedWindows|Placement|Xwayland|Backend|Effect' "$TARGET_HOME/.config/kwinrc"
    sed -n '1,120p' "$TARGET_HOME/.config/ksmserverrc"

Validar permissões dos arquivos do usuário final:

    stat -c '%a %U:%G %n' \
      "$TARGET_HOME/.config/MangoHud/mocha-active.conf" \
      "$TARGET_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
      "$TARGET_HOME/.config/kdeglobals" \
      "$TARGET_HOME/.config/kwinrc" \
      "$TARGET_HOME/.config/ksmserverrc"

Validar SDDM e skeleton:

    find /etc/sddm.conf.d -type f -name '*.conf' -print -exec sed -n '1,120p' {} ';'
    find /etc/skel -maxdepth 4 -type f -printf '%m %u:%g %p\n' | sort
    find /usr/share/sddm/themes -maxdepth 3 -type f -printf '%m %u:%g %p\n' | sort

### Validação visual obrigatória

Depois de aplicar o snapshot em uma instalação nova:

1. Reiniciar a sessão gráfica ou reiniciar o sistema.
2. Entrar no Plasma Wayland com o usuário final.
3. Confirmar que a barra, tema, cores e comportamento visual correspondem à matriz aprovada.
4. Abrir Steam pelo fluxo Steam Mocha.
5. Abrir um jogo Steam/Proton com a launch option canônica:
   `/usr/local/bin/mocha-steam-game-run %command%`
6. Confirmar MangoHud em uma linha, sem gráficos extras, com FPS, latência, CPU, GPU, VRAM, hora HH:MM e indicador GameMode.
7. Confirmar que GameMode aplica e remove o OC NVIDIA apenas durante o jogo.

### Regras de segurança desta seção

- Não recriar artefato parecido quando existir arquivo no snapshot.
- Não inventar arquivos ausentes.
- Não usar outro wrapper Steam como substituto.
- Não trocar o método GameMode/NVIDIA OC por script alternativo.
- Não apagar arquivos antigos com `rsync --delete`.
- Não fazer stage, commit ou push por consequência desta seção.
- Promoção deste snapshot de candidato para canônico final exige teste visual/runtime e aprovação explícita.
<!-- MOCHA:RUNTIME-REPRODUTIVEL:FIM -->
