<!-- MOCHA-CANONICO-MANGOHUD-GAMEMODE-NVIDIA-OC:BEGIN -->
## Mocha canonico - MangoHud e GameMode NVIDIA OC

### MangoHud aprovado

- Config ativa em runtime: ${HOME}/.config/MangoHud/mocha-active.conf.
- O wrapper Steam/Proton deve exportar MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf".
- Layout aprovado: uma linha, sem telemetria grafica extra.
- Ordem visual aprovada: FPS, latencia, CPU, GPU, VRAM, hora HH:MM e indicador GameMode.
- Validacao aceita: teste visual real dentro do jogo usando o wrapper Steam Mocha aprovado.

### GameMode NVIDIA OC aprovado

- O OC NVIDIA existe somente durante o GameMode.
- O `/etc/gamemode.ini` chama os aliases:
  - `/usr/local/lib/mocha/gamemode-start-agressivo-oc.sh`
  - `/usr/local/lib/mocha/gamemode-end-agressivo-oc.sh`
- Os aliases são links simbólicos de compatibilidade para:
  - `/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system`
  - `/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system`
- Os hooks reais chamam:
  - `/usr/local/lib/mocha/mocha-nvidia-oc-root-helper`
- Configuração efetiva:
  - `/etc/mocha/nvidia-game-oc.conf`
- Perfil aprovado:
  - core `+50`;
  - transfer-rate `+400`, equivalente a aproximadamente `+200 MHz` visível no memclock.
- O encerramento do GameMode reverte core e memória para `0`.
- Sudoers necessário:
  - `/etc/sudoers.d/mocha-nvidia-oc-root-helper`
- O payload deve preservar os aliases como links simbólicos.
- Não substituir os aliases pelos alvos reais por inferência.
- A validação deve limpar ou separar logs antigos para não confundir uma tentativa anterior com o teste atual.

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

A cadeia GameMode/OC abaixo foi revalidada no runtime e nos payloads em 2026-07-10.

Pontos essenciais:

    vm.swappiness=150
    TuneD profile: mocha-latency-performance
    GameMode start alias: /usr/local/lib/mocha/gamemode-start-agressivo-oc.sh
    GameMode start target: /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
    GameMode end alias: /usr/local/lib/mocha/gamemode-end-agressivo-oc.sh
    GameMode end target: /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system
    OC NVIDIA efetivo: /etc/mocha/nvidia-game-oc.conf
    OC aprovado: core +50 / transfer-rate +400 / aproximadamente +200 MHz visível no memclock

Não voltar automaticamente para presets antigos de agressividade.
Não converter os aliases simbólicos em arquivos regulares.
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

<!-- MOCHA:STEAM-LAUNCHOPTIONS-JOGOS-NOVOS:BEGIN -->
## Steam Mocha — LaunchOptions em jogos novos

Status: obrigatório na montagem do Mocha.

Objetivo desta etapa:

Garantir que jogos Steam/Proton recém-instalados também recebam a LaunchOptions canônica do Mocha, e não apenas jogos antigos que já estavam configurados.

LaunchOptions canônica:

    /usr/local/bin/mocha-steam-game-run %command%

Regra de montagem:

- O Mocha deve deixar o Steam preparado para aplicar a LaunchOptions canônica em jogos novos.
- A validação da montagem não pode aceitar somente jogos antigos já configurados.
- A auditoria precisa detectar AppID sem `LaunchOptions` e confirmar que o fluxo Steam Mocha adiciona a linha canônica.
- Ao fechar e reabrir o Steam Mocha, jogo novo sem `LaunchOptions` deve receber:
  `/usr/local/bin/mocha-steam-game-run %command%`
- Se um jogo novo permanecer sem essa linha, a montagem do Steam Mocha está incompleta.

Relação com o wrapper:

- O wrapper global obrigatório continua sendo:
  `/usr/local/bin/mocha-steam-game-run`
- A LaunchOptions deve chamar esse wrapper, não uma cópia local improvisada.
- Não substituir por gamescope.
- Não substituir por vkBasalt.
- Não usar MANGOHUD_DLSYM.
- Não recriar wrapper parecido quando o wrapper aprovado existir no runtime/snapshot.

Validação obrigatória durante a montagem:

    1. Fechar completamente o Steam.
    2. Identificar ou criar um caso de AppID Steam/Proton sem LaunchOptions canônica.
    3. Abrir o Steam pelo fluxo Steam Mocha aprovado.
    4. Fechar e reabrir o Steam Mocha quando necessário para persistência no `localconfig.vdf`.
    5. Conferir se o AppID novo recebeu:
       /usr/local/bin/mocha-steam-game-run %command%
    6. Abrir o jogo.
    7. Confirmar MangoHud em uma linha.
    8. Confirmar indicador GameMode.
    9. Confirmar que o OC NVIDIA via GameMode só atua durante o jogo.

Critério de aprovação:

- Jogo antigo com LaunchOptions canônica: necessário, mas insuficiente.
- Jogo novo recebendo a LaunchOptions canônica automaticamente: obrigatório.
- Steam Mocha sem autoinserção para jogo novo: reprova a montagem.
<!-- MOCHA:STEAM-LAUNCHOPTIONS-JOGOS-NOVOS:END -->


<!-- MOCHA_MANUAL_CURTO_GAMEMODE_OC_NVIDIA_NVML_START -->

## GameMode, system76-scheduler, TuneD e OC NVIDIA — cadeia canônica

Solução validada em teste real em **2026-07-11 23:30:18 -03**, no host `derp-x8664`, kernel `7.0.14-lqx1-1-lqx`.

### Contrato obrigatório de exclusão

1. Fora de jogo, `com.system76.Scheduler.service` permanece `enabled` e `active`.
2. Quando o primeiro cliente entra no GameMode, o wrapper start chama o helper de autoridade, registra que o scheduler estava ativo, para o `system76-scheduler` e então executa o start legacy das otimizações e do OC.
3. Enquanto houver cliente GameMode, o scheduler permanece inativo e o contador da autoridade fica maior que zero.
4. Quando o último cliente sai, o wrapper end executa primeiro o end legacy, restaurando o OC para `core 0 / memória 0`; depois reasserta o TuneD `mocha-latency-performance`, restaura o scheduler somente se ele estava ativo antes e reasserta o TuneD novamente.
5. GameMode e `system76-scheduler` não devem permanecer ativos simultaneamente.

### Cadeia canônica preservada

- Payload público: `/media/mochafast/MochaArch/scripts/performance/gamemode-oc-nvidia-nvml`
- Payload interno: `/media/mochafast/MochaArch-Interno/ativo/performance/gamemode-oc-nvidia-nvml`
- Instalador: `/media/mochafast/MochaArch/scripts/performance/gamemode-oc-nvidia-nvml/mocha-aplica-gamemode-oc-nvidia-nvml.sh`
- Unidade do scheduler: `/usr/lib/systemd/system/com.system76.Scheduler.service`
- Seletor da unidade: `/etc/mocha/gamemode/system76-service.name`
- Helper da autoridade: `/usr/local/sbin/mocha-system76-authority-helper`
- Sudoers da autoridade: `/etc/sudoers.d/mocha-gamemode-system76-authority`
- Wrapper start: `/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system`
- Wrapper end: `/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system`
- Start legacy real: `/usr/local/lib/mocha/gamemode-start-agressivo-oc.sh`
- End legacy real: `/usr/local/lib/mocha/gamemode-end-agressivo-oc.sh`
- Ponte start legacy: `/etc/mocha/gamemode/legacy-start-system.cmd`
- Ponte end legacy: `/etc/mocha/gamemode/legacy-end-system.cmd`
- Configuração do GameMode: `/etc/gamemode.ini`
- Estado da autoridade: `/run/mocha/gamemode-authority`
- Log da autoridade: `/var/log/mocha-gamemode-system76-authority.log`
- Log dos wrappers: `/tmp/mocha-gamemode-authority-$USER.log`

### Integração obrigatória em `/etc/gamemode.ini`

~~~ini
[custom]
start=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
end=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system
~~~

Os scripts com nome `agressivo-oc` são os artefatos legacy reais chamados pelos wrappers. Eles não devem ser apontados diretamente pelo GameMode.

### OC temporário aprovado

- Entrada do GameMode: `core +50` e `MEMORY_TRANSFER_RATE_OFFSET=400`, com efeito real esperado em torno de `+200 MHz` na memória.
- Saída do GameMode: `core 0 / memória 0`.
- O OC não é permanente e não deve ser aplicado no boot.

### Hashes do runtime aprovado

- `bd41359ec63ebd5b2686b5da4dd707b4dfaab40e5b0e86d8ba39d34bfd74ef1c` — `/etc/gamemode.ini`
- `58a8e4dc6a4916c9178814086551f3f44bdba7b7a39caf6fcd47d7ba38eec5bb` — `/usr/local/sbin/mocha-system76-authority-helper`
- `7a817389836af6f9c49d5a44ce8204bc5f0fa70497d5a463e4e7a3ba830ca1a2` — wrapper start
- `7be2a646fe45250794e84dea8fdd0bf48c7a13821452571b29dc15eacae03adb` — wrapper end
- `fffc494f2f74f0f589e92d4cba310970b548a383149fe19e31d9760415f5a45a` — start legacy
- `8e81f3b2b57b30e027e54f1096d8cb515d182bac2343a6ed784e9cb534c05294` — end legacy

A regressão conhecida do `/etc/gamemode.ini`, que apontava diretamente para os scripts legacy, possui SHA256 `a1931485550ae90d23ba00f752be652c0b3925342d75b07da6c3fb9dd26e090b` e não deve ser restaurada.

### Resultado já aprovado

Durante o GameMode: GameMode ativo, scheduler inativo e contador positivo.

Após a saída do último cliente: GameMode inativo, scheduler ativo, contador zero, OC em `0/0`, TuneD `mocha-latency-performance` validado e nenhum novo coredump do scheduler.

Não substituir helper, wrappers, scripts legacy, sudoers, seletor, unidade ou caminhos por equivalentes aproximados. Qualquer alteração futura exige nova validação antes de atualizar este bloco.

<!-- MOCHA_MANUAL_CURTO_GAMEMODE_OC_NVIDIA_NVML_END -->

<!-- MOCHA:COBERTURA-FUNCIONAL-RUNTIME-APROVADO:BEGIN -->
## Cobertura funcional Mocha — runtime aprovado

Status: obrigatório para considerar o Mocha pronto sobre sistema-base instalado.

Esta seção não substitui os blocos específicos de Steam, MangoHud, GameMode, TuneD, KDE, tema ou repositório. Ela consolida os pontos que a auditoria final deve encontrar no manual curto.

### MangoHud canônico

Caminhos aprovados que devem estar documentados:

- `/usr/local/share/mocha/mangohud/MangoHud.conf`
- `/home/hal/.config/MangoHud/mocha-active.conf`
- `/etc/skel/.config/MangoHud/mocha-active.conf`

A exibição aprovada do MangoHud deve permanecer em uma linha e cobrir:

- FPS
- latência
- CPU
- GPU
- temperatura
- MHz
- VRAM
- hora HH:MM
- indicador GameMode

Não substituir por gamescope.
Não substituir por vkBasalt.
Não usar MANGOHUD_DLSYM.

### GameMode + OC NVIDIA canônico

Artefatos obrigatórios já validados em runtime:

- `/etc/gamemode.ini`
- `/etc/mocha/nvidia-game-oc.conf`
- `/etc/sudoers.d/mocha-nvidia-oc-root-helper`
- `/usr/local/lib/mocha/mocha-nvidia-oc-root-helper`
- `/usr/local/lib/mocha/gamemode-start-agressivo-oc.sh`
- `/usr/local/lib/mocha/gamemode-end-agressivo-oc.sh`
- `/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system`
- `/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system`

Cadeia ativa:

- `/etc/gamemode.ini` chama os aliases `gamemode-start-agressivo-oc.sh` e `gamemode-end-agressivo-oc.sh`.
- Os aliases permanecem links simbólicos para os hooks `authority-system`.
- Os hooks reais chamam o helper root aprovado.
- O payload de montagem deve preservar os links simbólicos e o `gamemode.ini` aprovado.

Regra canônica:

- OC NVIDIA deve existir somente durante o jogo.
- O acionamento deve ocorrer somente junto com GameMode.
- Perfil aprovado: core `+50` e transfer-rate `+400`, equivalente a aproximadamente `+200 MHz` visível no memclock.
- O encerramento do GameMode deve remover o OC e devolver core/memória ao estado neutro.

Não aplicar OC permanente solto.
Não trocar o helper por wrapper improvisado.
Não substituir aliases por cópias regulares.
Não recriar artefato parecido quando o runtime ou payload aprovado existir.

### TuneD / agressividade / memória

Perfil obrigatório:

- `mocha-latency-performance`

Parâmetros que devem estar documentados para validação:

- `swappiness=150`
- `vfs_cache_pressure=50`
- `page-cluster=0`
- `dirty_background_bytes`
- `dirty_bytes`
- `max_map_count`
- `zram`
- `THP`

A validação deve confirmar o perfil ativo e o runtime antes de qualquer reparo. Não alterar TuneD/agressividade por inferência ou memória quando o sistema atual aprovado puder ser auditado.

### Repositório fallback local/publicável

Caminho canônico local:

- `/media/vmstore/mocha-repo`

Função canônica:

- servir como repositório de fallback para kernels, drivers NVIDIA e pacotes relacionados que precisem de rollback seguro;
- ser publicável futuramente para usuários do Mocha;
- permitir retorno a versões anteriores quando uma atualização quebrar FPS, boot, driver ou stack gamer.

Regra de atualização:

- adicionar somente pacotes novos ausentes;
- reindexar com `repo-add`;
- usar `repo-add` sem `-R`;
- não apagar pacotes antigos;
- não podar versões antigas;
- não usar limpeza automática destrutiva;
- atualização periódica por script/agendador a cada 2 ou 3 dias, depois de o script ser auditado e aprovado.

### Validação final de Mocha pronto

A validação final deve imprimir um VEREDITO explícito e terminar com `FAIL=0` somente se todos os pontos obrigatórios forem confirmados.

Itens mínimos do VEREDITO:

- Steam Mocha abre pelo fluxo correto.
- LaunchOptions canônica existe para jogos antigos e jogos Steam/Proton recém-instalados.
- MangoHud aparece em uma linha com os campos aprovados.
- GameMode ativa durante o jogo.
- OC NVIDIA atua somente durante o jogo.
- TuneD está no perfil `mocha-latency-performance`.
- Repo fallback `/media/vmstore/mocha-repo` existe e segue regra incremental sem remoção.
- KDE, painel, systray, tema, wallpaper e SDDM estão coerentes com o runtime aprovado.

Critério:

- `FAIL=0`: Mocha funcional aprovado pelos critérios auditados.
- `FAIL=1`: existe falta, divergência, staged indevido, artefato ausente ou risco de descaracterização.
<!-- MOCHA:COBERTURA-FUNCIONAL-RUNTIME-APROVADO:END -->

<!-- MOCHA:KDE-TEMA-PAINEL-SDDM-LOCKSCREEN-OPERACIONAL:BEGIN -->
## KDE, tema, painel, wallpaper, SDDM e lockscreen — mapa operacional

Status: obrigatório na montagem do Mocha.

Objetivo desta etapa:

Deixar o manual curto como mapa operacional de montagem, sem substituir os artefatos reais aprovados. Este bloco aponta quais scripts e payloads devem ser usados para reproduzir o visual Mocha aprovado: tema KDE/Plasma, painel estilo Windows 11, wallpaper, SDDM/login e trava de tela.

Regra canônica:

- Não recriar tema, painel, wallpaper, SDDM ou lockscreen por aproximação.
- Não substituir artefato aprovado por equivalente parecido.
- Não editar runtime por inferência.
- Usar os scripts, snapshots e payloads reais listados abaixo.
- Antes de canonizar mudança, auditar o runtime atual aprovado e comparar contra estes caminhos.

### Painel estilo Windows 11

Artefatos aprovados:

- script de reaplicação:
  `ativo/kde/barra-win11-aprovada/20260529-200013-mocha-reaplicar-barra-aprovada-atual.sh`
- snapshot/layout aprovado:
  `ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual`
- manual específico do painel:
  `ativo/kde/barra-win11-aprovada/MANUAL-BARRA-WIN11-MOCHA-APROVADA.md`

Como montar:

- aplicar o painel pelo script aprovado acima;
- validar o resultado contra o snapshot/layout aprovado;
- não reconstruir painel manualmente se o snapshot real existir;
- validar ausência de duplicidade de applets soltos que concorram com o System Tray.

### Tema KDE/Plasma e cores

Artefatos aprovados:

- esquema de cores principal:
  `ativo/kde/esquemas-cores-aprovados/MochaSolidCanonico.colors`
- esquema auxiliar presente no payload:
  `ativo/kde/color-schemes/MochaDark.colors`
- desktop theme Plasma:
  `ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico`
- payload Calamares de configuração:
  `ativo/calamares/payload/tema-completo/config/kdeglobals`
  `ativo/calamares/payload/tema-completo/config/plasma-org.kde.plasma.desktop-appletsrc`
  `ativo/calamares/payload/tema-completo/config/plasmarc`

Como montar:

- usar o payload de tema completo como fonte da instalação;
- aplicar/reaplicar em usuários com:
  `ativo/scripts/mocha-reaplicar-tema-completo-usuarios.sh`
- no fluxo Calamares/finalizador, usar:
  `ativo/calamares/scripts/mocha-finaliza-tema-completo-usuarios.sh`
- não gerar novo esquema de cores se os arquivos aprovados acima existirem.

### Wallpaper

Artefatos aprovados:

- wallpaper canônico no repo:
  `ativo/kde/wallpapers/mocha-wallpaper-canonico.png`
- wallpaper no payload Calamares:
  `ativo/calamares/payload/tema-completo/wallpaper/mocha-wallpaper-canonico.png`

Como montar:

- usar o mesmo wallpaper canônico para desktop, login e lockscreen quando o payload assim determinar;
- não trocar por imagem parecida;
- validar o caminho instalado em `/usr/share/wallpapers/mocha-wallpaper-canonico.png` quando estiver auditando runtime.

### SDDM / login

Artefatos e runtime esperados:

- tema SDDM Mocha instalado em:
  `/usr/share/sddm/themes/mocha`
- arquivos esperados no tema instalado:
  `/usr/share/sddm/themes/mocha/theme.conf`
  `/usr/share/sddm/themes/mocha/theme.conf.user`
  `/usr/share/sddm/themes/mocha/Background.qml`
  `/usr/share/sddm/themes/mocha/mocha-wallpaper.png`
- override esperado:
  `/etc/sddm.conf.d/99-mocha-theme.conf`

Como montar:

- instalar/copiar o tema SDDM Mocha real;
- apontar o SDDM para o tema Mocha via override;
- preservar Wayland/Plasma conforme regra vigente;
- não usar tema Breeze genérico como substituto visual do Mocha.

### Lockscreen / trava de tela

Artefatos aprovados:

- config no payload principal:
  `ativo/calamares/payload/tema-completo/config/kscreenlockerrc`
- config para skel:
  `ativo/calamares/payload/tema-completo/etc/skel/.config/kscreenlockerrc`
- config XDG:
  `ativo/calamares/payload/tema-completo/etc/xdg/kscreenlockerrc`

Como montar:

- copiar/aplicar `kscreenlockerrc` do payload aprovado;
- validar runtime em `/home/<usuario>/.config/kscreenlockerrc`;
- validar base para novos usuários em `/etc/skel/.config/kscreenlockerrc`;
- não configurar lockscreen por memória nem por aproximação visual.

### Validação mínima desta etapa

A montagem só deve ser aceita se a auditoria confirmar:

- script do painel aprovado existe e passa em `bash -n`;
- snapshot/layout aprovado do painel existe;
- esquemas de cores aprovados existem;
- desktop theme `MochaPanelSolidCanonico` existe;
- wallpaper canônico existe no repo e no payload;
- finalizadores de tema existem e passam em `bash -n`;
- SDDM usa tema Mocha real;
- `kscreenlockerrc` existe no payload, em XDG/skel e no runtime auditado;
- nada foi substituído por artefato parecido.

Critério:

- `FAIL=0`: caminhos reais comprovados e coerentes com o runtime/payload aprovado.
- `FAIL=1`: arquivo ausente, script inválido, stage indevido, runtime divergente ou risco de descaracterização.
<!-- MOCHA:KDE-TEMA-PAINEL-SDDM-LOCKSCREEN-OPERACIONAL:END -->



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


<!-- MOCHA:BEGIN AUTORIDADE_GAMEMODE_SYSTEM76_SEM_OC_CURTO_V1 -->
## GameMode e system76-scheduler — autoridade sem OC

- Script: `/media/mochafast/MochaArch/scripts/performance/gamemode-oc-nvidia-nvml/mocha-restaura-autoridade-gamemode-system76-sem-oc.sh`
- SHA256: `76c1c84d89b0d6e3f78ccee262b2757b009f6f5e795d26a891b21257cd0cfcd0`
- Contrato: scheduler ativo fora do jogo; GameMode ativo interrompe o scheduler; ao encerrar o último cliente, o scheduler volta e o perfil `mocha-latency-performance` é reafirmado.
- OC NVIDIA: não habilitado e não chamado.
- Execução: `bash /media/mochafast/MochaArch/scripts/performance/gamemode-oc-nvidia-nvml/mocha-restaura-autoridade-gamemode-system76-sem-oc.sh`
- Resultado aprovado: `AUTORIDADE_GAMEMODE_SYSTEM76_SEM_OC_APROVADA`.
<!-- MOCHA:END AUTORIDADE_GAMEMODE_SYSTEM76_SEM_OC_CURTO_V1 -->

