# MANUAL ÚNICO VIVO — Montagem do Mocha Arch/KDE

<!-- MOCHA-AUTO-REGISTRO-TEMA-TUNED-INICIO -->
## Registro canônico vivo — Tema Mocha KDE e TuneD

Atualizado em: 20260604-105401.

Fonte detalhada desta atualização: /media/mochafast/MochaArch/ativo/docs/mocha-registro-tema-tuned-canonico-20260604-105401.md

### Tema KDE/Plasma Mocha aprovado

Estado aprovado pelo usuário: as cores do Plasma agora estão Mocha.

Estado real registrado:

- Sessão: XDG_SESSION_TYPE=wayland; DESKTOP_SESSION=plasma; KDE_SESSION_VERSION=6.
- ColorScheme: MochaDark.
- Plasma theme: MochaPanelSolidCanonico.
- LookAndFeelPackage: org.kde.breezedark.desktop.
- Wallpaper: file:///media/mochafast/MochaArch/ativo/assets/branding/wallpaper/05fdb8fa-73e8-4d9b-a75e-6e1686f8e3ed.png.
- Tema local: /home/hal/.local/share/plasma/desktoptheme/MochaPanelSolidCanonico.

Regra canônica: não basta aplicar o ColorScheme. Para painel, menu Kickoff, popups e widgets ficarem Mocha, o tema Plasma precisa ter os SVGZ reais ajustados. Os arquivos críticos são panel-background.svgz, dialogs/background.svgz, widgets/background.svgz, tooltip.svgz, viewitem.svgz, listitem.svgz, tasks.svgz, button.svgz, lineedit.svgz e frame.svgz, incluindo variantes opaque, solid e translucent quando existirem.

Depois de alterar SVGZ do tema, limpar cache KSVG/Plasma, especialmente ~/.cache/ksvg-elements e ~/.cache/plasma_theme_MochaPanelSolidCanonico.kcache, reconstruir sycoca se disponível e reiniciar somente o plasmashell. Não reiniciar a máquina por dedução e não tocar em SDDM, GRUB, boot, kernel, firewall, Steam ou painel quando a tarefa for apenas cor do tema.

Paleta canônica desta correção: fundo profundo #171412; fundo janela #1f201f; fundo painel #2f2924; fundo popup/menu #28231f; fundo botão #322a24; borda #5c4638; accent #c98758; hover #d99e68; accent claro #f4be82; texto #ece2d7; texto discreto #aea296.

### TuneD/agressividade aprovado

Estado real registrado:

- tuned.service enabled: enabled.
- tuned.service active: active.
- Perfil ativo: mocha-latency-performance.
- Configuração detectada: /etc/tuned/profiles/mocha-latency-performance/tuned.conf.
- tuned-adm verify: Verification succeeded, current system settings match the preset profile. See TuneD log file ('/var/log/tuned/tuned.log') for details. .
- vm.swappiness: 180.
- vm.page-cluster: 0.
- vm.max_map_count: 16777216.
- zram0 comp_algorithm: lzo-rle lzo lz4 lz4hc [zstd] deflate 842 .
- swap atual: /dev/nvme0n1p3 partition 17G 0B -1 /dev/zram0 partition 15,4G 0B 32767.

Regra canônica: antes de alterar TuneD, auditar o estado real. O perfil Mocha aprovado deve ser preservado como perfil funcional e verificável. Se zram e swap em disco coexistirem, zram deve usar prioridade máxima e compressão zstd; swap em disco só como escape de baixa prioridade. Validar com tuned-adm active, tuned-adm verify, swapon --show, zramctl e sysctl antes de declarar concluído.

Este bloco substitui qualquer instrução anterior contraditória sobre aplicação visual Mocha no KDE/Plasma ou sobre o perfil TuneD/agressividade.
<!-- MOCHA-AUTO-REGISTRO-TEMA-TUNED-FIM -->



<!-- MOCHA_CORRECAO_PACOTES_AUDIO_INICIO -->
## Correção canônica MochaArch — pacotes substituídos e áudio PipeWire

Registro aprovado em 20260604-100319.

Esta seção substitui qualquer instrução anterior divergente no manual.

### Arquivadores

- No Arch atual, não usar `p7zip` em listas de instalação.
- Usar `7zip`.
- `7zip` substitui/provê `p7zip`.
- `zip` continua válido e não deve ser removido da lista apenas por confusão com `p7zip`.
- Lista canônica mínima para compactação/descompactação:
  - `zip`
  - `unzip`
  - `7zip`

### Áudio

- Não montar o Mocha com pilha PulseAudio clássica como padrão.
- Usar PipeWire como pilha de áudio padrão.
- Para compatibilidade com aplicações que falam PulseAudio, usar `pipewire-pulse`.
- Componentes canônicos da base de áudio:
  - `pipewire`
  - `pipewire-pulse`
  - `pipewire-alsa`
  - `pipewire-jack`
  - `wireplumber`
  - `alsa-utils`
  - `pavucontrol`
  - `plasma-pa`

### Regra operacional

Se uma lista antiga de instalação pedir `pulseaudio` como servidor de áudio padrão, a lista está inválida para o MochaArch atual e deve ser convertida para PipeWire-Pulse.

Se uma lista antiga pedir `p7zip`, substituir por `7zip`.

Antes de instalar pacotes em lote, auditar nomes reais com:

pacman -Si NOME_DO_PACOTE

Não continuar montagem com pacote inexistente, substituído ou renomeado sem registrar a correção no manual.
<!-- MOCHA_CORRECAO_PACOTES_AUDIO_FIM -->


Este é o manual operacional vivo do Mocha Arch/KDE.

Ele deve conter tudo que já fizemos e funcionou, em passo a passo, com validação e regra de não regressão. A partir de agora, toda nova solução aprovada deve ser acrescentada neste manual usando o script:

```text
/media/mochafast/MochaArch/ativo/scripts/mocha-adicionar-entrada-aprovada-ao-manual.sh
```

Pasta ativa:

```text
/media/mochafast/MochaArch/ativo
```

---

## 1. Regras obrigatórias

1. Auditar antes de editar.
2. Usar o arquivo real como fonte, não dedução.
3. Quando funcionar, documentar imediatamente.
4. Salvar script reutilizável quando fizer sentido.
5. Não guardar lixo na pasta ativa.
6. Tentativa falha deve ser apagada ou movida para quarentena.
7. Não remover programa sem ordem expressa.
8. Não usar Chrome como padrão do Mocha.
9. Não usar X11 como fallback. O caminho é Wayland.
10. Não tocar em XU sem ordem explícita.
11. Não reintroduzir `MANGOHUD_DLSYM`.
12. Não usar `vkbasalt` nem `gamescope` no wrapper canônico Steam/Mocha.
13. Não contaminar Launch Options com opções legadas.
14. Não mexer em geometria visual aprovada sem ordem.
15. Todo arquivo novo deve ter timestamp, salvo nome fixo obrigatório.
16. Manter no máximo 1 ou 2 backups por item.

---

## 2. Estrutura oficial do MochaArch

```text
/media/mochafast/MochaArch/ativo
/media/mochafast/MochaArch/ativo/documentacao
/media/mochafast/MochaArch/ativo/scripts
/media/mochafast/MochaArch/ativo/logs
/media/mochafast/MochaArch/ativo/backups
/media/mochafast/MochaArch/ativo/quarentena
/media/mochafast/MochaArch/ativo/kde
/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada
```

Regra:

- `ativo` recebe apenas solução aprovada, funcional ou em refino controlado.
- `quarentena` recebe coisa que talvez sirva depois.
- lixo experimental que não serve deve ser apagado.

---

## 3. Passo a passo aprovado até agora

### 3.1 Montagem obrigatória do FAST e VMSTORE

Objetivo:

- O Mocha precisa ter FAST e VMSTORE montados de forma persistente.
- FAST contém o trabalho ativo/evolutivo.
- VMSTORE contém armazenamento/canônico quando aplicável.

Caminhos obrigatórios:

```text
/media/mochafast
/media/vmstore
```

Validação:

```bash
mountpoint -q /media/mochafast && echo "FAST OK"
mountpoint -q /media/vmstore && echo "VMSTORE OK"
findmnt /media/mochafast
findmnt /media/vmstore
grep -nE '/media/mochafast|/media/vmstore' /etc/fstab
```

Regra de não regressão:

- Não empilhar linhas erradas no `/etc/fstab`.
- Auditar antes de editar.
- Se entrada estiver errada, substituir pela correta, sem duplicar.
- Não mexer no NVMe sem necessidade.
- Não fazer operação destrutiva em disco.

---

### 3.2 Driver de vídeo NVIDIA funcional

Objetivo:

- Sair do estado em que o sistema tinha interface, mas `nvidia-smi` falhava.
- Deixar NVIDIA funcional no kernel em uso.
- Garantir Plasma/Wayland funcional.
- Garantir Steam/jogo com FPS alto e fluidez.

Validação obrigatória:

```bash
uname -r
nvidia-smi
pacman -Q | grep -E '^(linux($|-)|linux-zen|linux-cachyos|nvidia|nvidia-utils|lib32-nvidia-utils|opencl-nvidia|egl-wayland|vulkan|lib32-vulkan)' | sort
```

Critério de aprovação:

- `nvidia-smi` comunica com a GPU.
- Plasma/Wayland abre.
- Jogo roda na Steam com FPS alto.
- Não quebra o login gráfico.

Regra de não regressão:

- Não voltar para Nouveau como solução permanente.
- Não usar X11 como escape.
- Não trocar driver sem auditar kernel atual, pacotes e boot.

---

### 3.3 Kernel/base funcional

Objetivo:

- Preservar a base atual que entregou desempenho superior ao Endeavour.
- Tratar kernel atual + NVIDIA funcional como base aprovada até novo teste.

Validação:

```bash
uname -a
pacman -Q | grep -E '^(linux($|-)|linux-zen|linux-cachyos|nvidia)' | sort
```

Resultado aprovado:

- Sistema rápido.
- Jogo fluido.
- FPS alto pelo overlay da Steam.
- Bluetooth funcional.
- Driver de vídeo funcional.

Regra de não regressão:

- Não trocar kernel no escuro.
- Registrar kernel atual antes de qualquer troca.
- Garantir entrada de retorno antes de mexer em boot/kernel.

---

### 3.4 Login manager / Wayland

Objetivo:

- Login gráfico funcional.
- Sessão KDE/Plasma em Wayland.
- Sem loop de senha.
- Sem fallback X11.

Validação:

```bash
systemctl status display-manager --no-pager --full
readlink -f /etc/systemd/system/display-manager.service
echo "$XDG_SESSION_TYPE"
loginctl show-session "$XDG_SESSION_ID" -p Type -p Desktop -p Name
```

Critério de aprovação:

- Tela de login aparece.
- Senha entra.
- Sessão Plasma/KDE abre.
- Sessão é Wayland.
- Não há loop de login.

Regra de não regressão:

- X11 não é opção.
- Não trocar gerenciador de login sem validação pós-boot.
- Quando a solução final do login manager estiver fechada, acrescentar comando exato neste manual.

---

### 3.5 Correção aprovada: Bluetooth e volume duplicados

Problema:

- Bluetooth aparecia duplicado na barra.
- Volume aparecia duplicado na barra.

Solução aprovada:

- Manter Bluetooth nativo do KDE/Bluedevil.
- Manter volume nativo do Plasma.
- Desativar apenas autostart redundante de `blueman-applet`.
- Desativar apenas autostart redundante de `kmix`.
- Não remover `blueman`.
- Não remover `kmix`.

Arquivos do usuário:

```text
~/.config/autostart/blueman.desktop
~/.config/autostart/kmix_autostart.desktop
```

Arquivos para novos usuários:

```text
/etc/skel/.config/autostart/blueman.desktop
/etc/skel/.config/autostart/kmix_autostart.desktop
```

Conteúdo esperado:

```ini
[Desktop Entry]
Hidden=true
```

Validação:

```bash
cat ~/.config/autostart/blueman.desktop
cat ~/.config/autostart/kmix_autostart.desktop
```

Resultado aprovado:

- O usuário confirmou que os ícones duplicados sumiram.
- Esta correção é passo permanente da montagem do Mocha Arch/KDE.

Regra de não regressão:

- Não remover os pacotes.
- Apenas impedir autostart redundante.

---

### 3.6 Barra Win11/Mocha aprovada

Pasta correta:

```text
/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/
```

Arquivo visual aprovado:

```text
/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
```

Arquivo real do Plasma:

```text
~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

Fluxo aprovado:

1. Validar `/media/mochafast`.
2. Validar pasta da barra aprovada.
3. Validar arquivo `plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617`.
4. Validar assinaturas:
   - `plugin=org.kde.plasma.panelspacer`
   - `plugin=org.kde.plasma.icontasks` ou `plugin=org.kde.plasma.taskmanager`
   - `plugin=org.kde.plasma.systemtray`
   - `AppletOrder=`
5. Fazer backup do `appletsrc` atual.
6. Parar `plasmashell`.
7. Copiar o `appletsrc` aprovado para o caminho real.
8. Reiniciar `plasmashell`.
9. Validar visualmente.

Resultado aprovado:

- Funcionou perfeitamente quando aplicado pelo arquivo aprovado.
- A barra Mocha/Win11 ficou correta.

Regra de não regressão:

- A fonte visual canônica é o `appletsrc` aprovado.
- Não procurar script inexistente como fonte primária.
- Scripts podem automatizar, mas a fonte aprovada é o arquivo salvo nessa pasta.

---

### 3.7 Energia, CPU/GPU e agressividade

Objetivo:

- CPU e GPU entregarem o máximo possível.
- CPU em perfil de desempenho/latência.
- GPU NVIDIA priorizando desempenho máximo.
- Preservar o estado que deu FPS alto e fluidez.

Validações:

```bash
powerprofilesctl get
tuned-adm active
systemctl is-enabled tuned
systemctl is-active tuned
grep -H . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | sort -V
nvidia-smi -q -d POWER
systemctl is-enabled nvidia-persistenced
systemctl is-active nvidia-persistenced
```

Resultado aprovado relatado:

- Sistema rápido.
- Jogo fluido.
- FPS alto.
- Mais de 200 FPS em alguns momentos.
- Campo aberto majoritariamente na faixa de 150–170 FPS, com variações.
- Qualidade de imagem melhor.
- Som aparentando surround/Dolby, causa ainda não isolada.

Regra de não regressão:

- Não reduzir agressividade sem teste comparativo.
- Não aplicar economia de energia como padrão gamer.
- Se mudança piorar FPS, fluidez ou imagem, voltar ao estado aprovado.

---

### 3.8 Steam, Launch Options e wrapper

Estado aprovado:

- Melhor baseline atual: Steam sem nenhuma linha em Launch Options.
- Overlay da Steam usado para medir FPS.
- Jogo fluido e FPS alto nesse baseline.

Regra atual:

```text
Launch Options padrão: vazio
```

Wrapper canônico pretendido:

```text
/home/hal/.local/bin/mocha-steam-game-run %command%
```

Proibições no wrapper canônico:

- Não usar `MANGOHUD_DLSYM`.
- Não usar `vkbasalt`.
- Não usar `gamescope`.
- Não usar opções antigas de notebook híbrido.
- Não contaminar baseline aprovado.

Regra de não regressão:

- Todo wrapper novo precisa ser testado contra o baseline sem Launch Options.
- Se piorar, o baseline aprovado permanece vazio.

---

### 3.9 Organização e limpeza

Regra aprovada:

- Se funcionou, documentar.
- Se funcionou e pode ser reutilizado, salvar script limpo.
- Se falhou e não serve, apagar.
- Se falhou mas pode servir depois, mover para quarentena.
- Não deixar a pasta ativa virar depósito de remendos.

---

## 4. Como acrescentar novas entradas aprovadas

Usar:

```bash
/media/mochafast/MochaArch/ativo/scripts/mocha-adicionar-entrada-aprovada-ao-manual.sh "Área" "Título" <<'EOF'
O que foi feito:
Por que foi feito:
Arquivo(s) alterado(s):
Comando/script aprovado:
Validação:
Resultado:
Regra de não regressão:
EOF
```

Exemplo:

```bash
/media/mochafast/MochaArch/ativo/scripts/mocha-adicionar-entrada-aprovada-ao-manual.sh "Login manager" "Plasma login validado em Wayland" <<'EOF'
O que foi feito:
Por que foi feito:
Arquivo(s) alterado(s):
Comando/script aprovado:
Validação:
Resultado:
Regra de não regressão:
EOF
```

---

## 5. Pendências que ainda precisam de comando final exato no manual

Estas áreas já têm direção e validação, mas devem receber o comando exato final assim que forem fechadas ou extraídas dos logs:

1. Login manager final validado pós-boot.
2. Comando exato final do driver NVIDIA.
3. Script permanente final de energia/agressividade.
4. Wrapper Steam/Mocha novo, apenas depois de vencer ou igualar o baseline sem Launch Options.

---

## Auditoria automática do estado atual

Gerada em: 20260529-154304

Esta auditoria registra o estado real no momento da criação do manual. Ela não altera o sistema.

### Kernel atual

```text
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux
```

### Driver NVIDIA

```text
Fri May 29 15:43:04 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 595.71.05              Driver Version: 595.71.05      CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5060 Ti     On  |   00000000:01:00.0  On |                  N/A |
|  0%   37C    P8             11W /  180W |     843MiB /  16311MiB |      1%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A             891      G   /usr/bin/ksecretd                         2MiB |
|    0   N/A  N/A             956      G   /usr/bin/kwin_wayland                    30MiB |
|    0   N/A  N/A            1039      G   /usr/bin/Xwayland                         2MiB |
|    0   N/A  N/A            1079      G   /usr/bin/ksmserver                        2MiB |
|    0   N/A  N/A            1081      G   /usr/bin/kded6                            2MiB |
|    0   N/A  N/A            1192      G   /usr/bin/kaccess                          2MiB |
|    0   N/A  N/A            1193      G   ...it-kde-authentication-agent-1          2MiB |
|    0   N/A  N/A            1288      G   /usr/bin/kdeconnectd                      2MiB |
|    0   N/A  N/A            1319      G   /usr/lib/firefox/firefox                243MiB |
|    0   N/A  N/A            1487      G   /usr/bin/akonadi_control                  2MiB |
|    0   N/A  N/A            1679      G   ...bin/akonadi_archivemail_agent          2MiB |
|    0   N/A  N/A            1682      G   ...konadi_followupreminder_agent          2MiB |
|    0   N/A  N/A            1686      G   .../akonadi_maildispatcher_agent          2MiB |
|    0   N/A  N/A            1687      G   .../bin/akonadi_mailfilter_agent          2MiB |
|    0   N/A  N/A            1688      G   /usr/bin/akonadi_mailmerge_agent          2MiB |
|    0   N/A  N/A            1689      G   /usr/bin/akonadi_migration_agent          2MiB |
|    0   N/A  N/A            1690      G   ...akonadi_newmailnotifier_agent          2MiB |
|    0   N/A  N/A            1691      G   /usr/bin/akonadi_sendlater_agent          2MiB |
|    0   N/A  N/A            1692      G   .../akonadi_unifiedmailbox_agent          2MiB |
|    0   N/A  N/A            2033      G   /usr/lib/DiscoverNotifier                 2MiB |
|    0   N/A  N/A            2042      G   /usr/bin/kalendarac                       2MiB |
|    0   N/A  N/A            2093      G   /usr/lib/xdg-desktop-portal-kde           2MiB |
|    0   N/A  N/A            2469      G   ...share/Steam/ubuntu12_32/steam          4MiB |
|    0   N/A  N/A            2676      G   ./steamwebhelper                         23MiB |
|    0   N/A  N/A            2705    C+G   ...am/ubuntu12_64/steamwebhelper          5MiB |
|    0   N/A  N/A            3236      G   ...asma-browser-integration-host          2MiB |
|    0   N/A  N/A            4133      G   /usr/bin/kwalletd6                        2MiB |
|    0   N/A  N/A            8656      G   /usr/bin/konsole                          2MiB |
|    0   N/A  N/A            8813      G   /usr/bin/dolphin                          2MiB |
|    0   N/A  N/A            9032      G   /usr/bin/plasmashell                     71MiB |
+-----------------------------------------------------------------------------------------+
```

### Pacotes de kernel, NVIDIA, Vulkan e Steam relevantes

```text
egl-wayland2 1.0.1-1
egl-wayland 4:1.1.21-1
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
lib32-nvidia-utils 595.71.05-1
lib32-vulkan-icd-loader 1.4.350.0-1
linux-api-headers 6.19-1
linux-atm 2.5.2-9
linux-firmware 20260519-1
linux-firmware-amdgpu 20260519-1
linux-firmware-atheros 20260519-1
linux-firmware-broadcom 20260519-1
linux-firmware-cirrus 20260519-1
linux-firmware-intel 20260519-1
linux-firmware-mediatek 20260519-1
linux-firmware-nvidia 20260519-1
linux-firmware-other 20260519-1
linux-firmware-radeon 20260519-1
linux-firmware-realtek 20260519-1
linux-firmware-whence 20260519-1
linux-headers 7.0.10.arch1-1
mangohud 0.8.3-2
nvidia-open-dkms 595.71.05-2
nvidia-settings 595.71.05-1
nvidia-utils 595.71.05-2
opencl-nvidia 595.71.05-2
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
vulkan-icd-loader 1.4.350.0-1
vulkan-tools 1.4.350.0-1
```

### Login manager / display manager

```text
● plasmalogin.service - Plasma Login Manager
     Loaded: loaded (/usr/lib/systemd/system/plasmalogin.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 1h 13min ago
 Invocation: 7c16afbe746f47008acd42cd1d5dbc36
       Docs: man:plasmalogin(1)
             man:plasmalogin.conf(5)
   Main PID: 683 (plasmalogin)
      Tasks: 2 (limit: 18662)
     Memory: 16.8M (peak: 39.4M, swap: 560K, swap peak: 560K, zswap: 112.7K)
        CPU: 106ms
     CGroup: /system.slice/plasmalogin.service
             └─683 /usr/bin/plasmalogin

mai 29 14:29:52 Mocha plasmalogin-helper[865]: [PAM] returning.
mai 29 14:29:52 Mocha plasmalogin[683]: Authentication for user  "hal"  successful
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_kwallet5(plasmalogin:setcred): pam_kwallet5: pam_sm_setcred
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_unix(plasmalogin:session): session opened for user hal(uid=1000) by hal(uid=0)
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_kwallet5(plasmalogin:session): pam_kwallet5: pam_sm_open_session
mai 29 14:29:52 Mocha plasmalogin-helper[865]: Starting Wayland user session: "/usr/share/plasmalogin/scripts/wayland-session" "/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland"
mai 29 14:29:52 Mocha plasmalogin[683]: Session started true
mai 29 14:29:57 Mocha plasmalogin[683]: Greeter stopping...
mai 29 14:29:57 Mocha plasmalogin[683]: Auth: plasmalogin-helper exited with 255
mai 29 14:29:57 Mocha plasmalogin[683]: Greeter stopped. PLASMALOGIN::Auth::HelperExitStatus(255)

--- display-manager.service aponta para ---
/usr/lib/systemd/system/plasmalogin.service

--- units conhecidas ---
display-manager.service                      alias           -
plasmalogin.service                          enabled         disabled
plymouth-halt.service                        static          -
plymouth-kexec.service                       static          -
plymouth-poweroff.service                    static          -
plymouth-quit-wait.service                   static          -
plymouth-quit.service                        static          -
plymouth-read-write.service                  static          -
plymouth-reboot.service                      static          -
plymouth-start.service                       static          -
plymouth-switch-root-initramfs.service       static          -
plymouth-switch-root.service                 static          -
sddm.service                                 disabled        disabled
systemd-ask-password-plymouth.service        static          -
systemd-tmpfiles-setup-dev-early.service     static          -
systemd-tpm2-setup-early.service             static          -
```

### Sessão gráfica

```text
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=KDE
Name=hal
Desktop=KDE
Type=wayland
```

### Montagens obrigatórias FAST e VMSTORE

```text
/media/mochafast: MONTADO
TARGET           SOURCE    FSTYPE OPTIONS
/media/mochafast /dev/sda1 btrfs  rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=5,subvol=/

/media/vmstore: MONTADO
TARGET         SOURCE    FSTYPE OPTIONS
/media/vmstore /dev/sdb1 xfs    rw,noatime,inode64,logbufs=8,logbsize=32k,noquota

--- /etc/fstab: entradas relevantes ---
17:UUID=88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast btrfs defaults,noatime,compress=zstd:3,ssd,discard=async,nofail,x-systemd.device-timeout=10s 0 0
18:UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore xfs defaults,noatime,nofail,x-systemd.device-timeout=10s 0 2
```

### Energia, CPU, GPU e agressividade

```text
--- powerprofilesctl ---
powerprofilesctl não encontrado.

--- tuned ---
Current active profile: latency-performance
enabled
active

--- governor CPU ---
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu3/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu4/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu5/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu8/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu9/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu10/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu11/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu12/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu13/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu14/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu15/cpufreq/scaling_governor:performance

--- NVIDIA power/persistence ---

==============NVSMI LOG==============

Timestamp                                              : Fri May 29 15:43:05 2026
Driver Version                                         : 595.71.05
CUDA Version                                           : 13.2

Attached GPUs                                          : 1
GPU 00000000:01:00.0
    GPU Power Readings
        Average Power Draw                             : 11.67 W
        Instantaneous Power Draw                       : 10.85 W
        Current Power Limit                            : 180.00 W
        Requested Power Limit                          : 180.00 W
        Default Power Limit                            : 180.00 W
        Min Power Limit                                : 150.00 W
        Max Power Limit                                : 180.00 W
    Power Samples
        Duration                                       : 2.36 sec
        Number of Samples                              : 119
        Max                                            : 16.48 W
        Min                                            : 10.43 W
        Avg                                            : 11.93 W
    GPU Memory Power Readings 
        Average Power Draw                             : N/A
        Instantaneous Power Draw                       : N/A
    Module Power Readings
        Average Power Draw                             : N/A
        Instantaneous Power Draw                       : N/A
        Current Power Limit                            : N/A
        Requested Power Limit                          : N/A
        Default Power Limit                            : N/A
        Min Power Limit                                : N/A
        Max Power Limit                                : N/A
    EDPp Multiplier                                    : N/A

disabled
inactive
```

### Correção Bluetooth e volume duplicados

```text
--- /home/hal/.config/autostart/blueman.desktop ---
[Desktop Entry]
Name[be]=Аплет Blueman
Name[da]=Blueman-panelprogram
Name[de]=Blueman Applet
Name[el]=Εφαρμογή blueman
Name[en_GB]=Blueman Applet
Name[es]=Miniaplicación Blueman
Name[et]=Blueman rakend
Name[eu]=Blueman trepeta
Name[fi]=Blueman-sovelma
Name[fr]=Applet Blueman
Name[ga]=Feidhmchláirín Blueman
Name[he]=יישומון Blueman
Name[hr]=Blueman aplet
Name[hu]=Blueman kisalkalmazás
Name[is]=Blueman-smáforrit
Name[it]=Blueman Applet
Name[ja]=Bluetooth アプレット
Name[ko]=Blueman 애플릿
Name[mr]=ब्लूमॅन ॲपलेट
Name[ms]=Aplet Blueman
Name[nb]=Blueman-panelprogram
Name[nl]=Blueman-werkbalkhulpje
Name[pl]=Aplet Blueman
Name[pt_BR]=Miniaplicativo Blueman
Name[pt]=Applet Blueman
Name[ro]=Miniaplicație Blueman
Name[ru]=Апплет Blueman
Name[sk]=Aplet bluetooth
Name[sl]=Blueman Applet
Name[sv]=Blueman panelprogram
Name[ta]=ப்ளூமேன் ஆப்லெட்
Name[tr]=Blueman Uygulaması
Name[uk]=Аплет Blueman
Name[zh_CN]=Blueman 小程序
Name[zh_TW]=Blueman 小程式
Name[oc]=Applet Blueman
Name=Blueman Applet
Comment[ast]=Alministrador Bluetooth Blueman
Comment[be]=Blueman - кіраўнік Bluetooth
Comment[ca]=Gestor de Bluetooth Blueman
Comment[da]=Blueman Bluetooth-håndtering
Comment[de]=Blueman Bluetooth Manager
Comment[el]=Διαχειριστής bluetooth του blueman
Comment[en_GB]=Blueman Bluetooth Manager
Comment[es]=Gestor de conexiones Bluetooth Blueman
Comment[et]=Bluetoothi haldur Blueman
Comment[eu]=Blueman Bluetooth kudeatzailea
Comment[fi]=Blueman bluetooth-hallinta
Comment[fr]=Gestionnaire Bluetooth Blueman
Comment[ga]=Bainisteoir Bluetooth Blueman
Comment[he]=Blueman - מנהל בלוטות׳
Comment[hr]=Blueman Bluetooth upravitelj
Comment[hu]=Blueman Bluetooth-kezelő
Comment[is]=Blueman Bluetooth-umsýsla
Comment[it]=Blueman Gestore Bluetooth
Comment[ja]=Blueman Bluetooth マネージャー
Comment[ko]=Blueman 블루투스 관리자
Comment[lt]=Blueman „Bluetooth“ tvarkytuvė
Comment[nb]=Blueman Blåtannsbehandler

--- /home/hal/.config/autostart/kmix_autostart.desktop ---
[Desktop Entry]
Exec=kmix --keepvisibility
X-DocPath=kmix/index.html
OnlyShowIn=KDE;
Type=Application
X-KDE-autostart-after=panel
X-KDE-autostart-after=pulseaudio
X-KDE-StartupNotify=false
X-DBUS-StartupType=Unique
X-KDE-autostart-condition=kmixrc:Global:AutoStart:true
Icon=kmix
GenericName=Sound Mixer
GenericName[ar]=مازج الصوت
GenericName[bg]=Звуков миксер
GenericName[bs]=Mikser zvuka
GenericName[ca]=Mesclador de so
GenericName[ca@valencia]=Mesclador de so
GenericName[cs]=Směšovač zvuku
GenericName[da]=Lydmikser
GenericName[de]=Lautstärkeregler
GenericName[el]=Μείκτης ήχου
GenericName[en_GB]=Sound Mixer
GenericName[eo]=Sonmiksilo
GenericName[es]=Mezclador de sonido
GenericName[et]=Helimikser
GenericName[eu]=Soinua nahaslea
GenericName[fi]=Äänimikseri
GenericName[fr]=Console de mixage
GenericName[ga]=Meascthóir Fuaime
GenericName[gl]=Mesturador de son
GenericName[he]=מערבל שמע
GenericName[hu]=Hangkeverő
GenericName[ia]=Miscitor de sono
GenericName[id]=Mixer Suara
GenericName[is]=Hljóðblandari
GenericName[it]=Mixer audio
GenericName[ja]=サウンドミキサー
GenericName[ka]=ხმის მიქსერი
GenericName[kk]=Дыбыс микшері
GenericName[km]=កម្មវិធី​លាយ​សំលេង
GenericName[ko]=소리 믹서
GenericName[lt]=Garsų maišiklis
GenericName[lv]=Skaņas mikseris
GenericName[mr]=आवाज मिक्सर
GenericName[nb]=Lydmikser
GenericName[nds]=Klangmischer
GenericName[nl]=Geluidsmixer
GenericName[nn]=Lydmiksar
GenericName[pa]=ਸਾਊਡ ਮਿਕਸਰ
GenericName[pl]=Mikser dźwięku
GenericName[pt]=Mistura de Áudio
GenericName[pt_BR]=Mixer de som
GenericName[ro]=Mixer de sunet
GenericName[ru]=Звуковой микшер
GenericName[sa]=ध्वनिमिश्रकः
GenericName[se]=Jietnamixer
GenericName[sk]=Zvukový mixér
GenericName[sl]=Mešalnik zvoka
GenericName[sr]=Звучна миксета
GenericName[sr@ijekavian]=Звучна миксета

--- /etc/skel/.config/autostart/blueman.desktop ---
[Desktop Entry]
Type=Application
Name=blueman.desktop
Comment=Mocha KDE: disabled because KDE/Bluedevil already provides Bluetooth in the system tray
Exec=blueman-applet
OnlyShowIn=KDE;
Hidden=true

--- /etc/skel/.config/autostart/kmix_autostart.desktop ---
[Desktop Entry]
Type=Application
Name=kmix_autostart.desktop
Comment=Mocha KDE: disabled because Plasma volume applet already provides volume control in the system tray
Exec=kmix --keepvisibility
OnlyShowIn=KDE;
Hidden=true

```

### Barra Win11/Mocha aprovada

```text
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:33  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

--- assinaturas do appletsrc aprovado ---
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true
```

### Scripts e documentos principais no ativo

```text
2026-05-28 22:56  1159 bytes  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:01  1754 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md
2026-05-29 15:01  2068 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:01  2068 bytes  /media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:24  10321 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt
2026-05-29 15:24  1070 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md
2026-05-29 15:24  4616 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/plasma-applets-volume-bluetooth-systemtray.txt
2026-05-29 15:24  624 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt
2026-05-29 15:25  3401 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152529-corrigir-blueman-auditar-volume/execucao.log
2026-05-29 15:27  1108 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh
2026-05-29 15:27  1389 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md
2026-05-29 15:27  7077 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log
2026-05-29 15:29  1624 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md
2026-05-29 15:29  1624 bytes  /media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md
2026-05-29 15:29  2541 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
2026-05-29 15:29  3810 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log
2026-05-29 15:30  3891 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
2026-05-29 15:32  824 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153249-aplicar-barra-win11-aprovada-pasta-certa.log
2026-05-29 15:33  2039 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log
2026-05-29 15:33  2985 bytes  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
2026-05-29 15:33  835 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
2026-05-29 15:43  17941 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md
2026-05-29 15:43  203 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-154304-criar-manual-vivo-definitivo-mocha-arch-kde.log
```


## Evidências extraídas dos documentos, scripts e logs do MochaArch

Estas evidências foram extraídas automaticamente de `documentacao`, `scripts`, `logs` e `kde`, ignorando `backups`, `quarentena` e caminhos com `XU`.

### Driver de vídeo NVIDIA

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 6

Linhas aproximadas 3-42:

```text
Gerada em: 20260529-154304

Esta auditoria registra o estado real no momento da criação do manual. Ela não altera o sistema.

### Kernel atual

```text
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux
```

### Driver NVIDIA

```text
Fri May 29 15:43:04 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 595.71.05              Driver Version: 595.71.05      CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5060 Ti     On  |   00000000:01:00.0  On |                  N/A |
|  0%   37C    P8             11W /  180W |     843MiB /  16311MiB |      1%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A             891      G   /usr/bin/ksecretd                         2MiB |
|    0   N/A  N/A             956      G   /usr/bin/kwin_wayland                    30MiB |
|    0   N/A  N/A            1039      G   /usr/bin/Xwayland                         2MiB |
|    0   N/A  N/A            1079      G   /usr/bin/ksmserver                        2MiB |
|    0   N/A  N/A            1081      G   /usr/bin/kded6                            2MiB |
|    0   N/A  N/A            1192      G   /usr/bin/kaccess                          2MiB |
|    0   N/A  N/A            1193      G   ...it-kde-authentication-agent-1          2MiB |
|    0   N/A  N/A            1288      G   /usr/bin/kdeconnectd                      2MiB |
|    0   N/A  N/A            1319      G   /usr/lib/firefox/firefox                243MiB |
```

Linhas aproximadas 57-103:

```text
|    0   N/A  N/A            2676      G   ./steamwebhelper                         23MiB |
|    0   N/A  N/A            2705    C+G   ...am/ubuntu12_64/steamwebhelper          5MiB |
|    0   N/A  N/A            3236      G   ...asma-browser-integration-host          2MiB |
|    0   N/A  N/A            4133      G   /usr/bin/kwalletd6                        2MiB |
|    0   N/A  N/A            8656      G   /usr/bin/konsole                          2MiB |
|    0   N/A  N/A            8813      G   /usr/bin/dolphin                          2MiB |
|    0   N/A  N/A            9032      G   /usr/bin/plasmashell                     71MiB |
+-----------------------------------------------------------------------------------------+
```

### Pacotes de kernel, NVIDIA, Vulkan e Steam relevantes

```text
egl-wayland2 1.0.1-1
egl-wayland 4:1.1.21-1
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
lib32-nvidia-utils 595.71.05-1
lib32-vulkan-icd-loader 1.4.350.0-1
linux-api-headers 6.19-1
linux-atm 2.5.2-9
linux-firmware 20260519-1
linux-firmware-amdgpu 20260519-1
linux-firmware-atheros 20260519-1
linux-firmware-broadcom 20260519-1
linux-firmware-cirrus 20260519-1
linux-firmware-intel 20260519-1
linux-firmware-mediatek 20260519-1
linux-firmware-nvidia 20260519-1
linux-firmware-other 20260519-1
linux-firmware-radeon 20260519-1
linux-firmware-realtek 20260519-1
linux-firmware-whence 20260519-1
linux-headers 7.0.10.arch1-1
mangohud 0.8.3-2
nvidia-open-dkms 595.71.05-2
nvidia-settings 595.71.05-1
nvidia-utils 595.71.05-2
opencl-nvidia 595.71.05-2
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
vulkan-icd-loader 1.4.350.0-1
vulkan-tools 1.4.350.0-1
```

### Login manager / display manager

```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 2

Linhas aproximadas 38-75:

```text
linux 7.0.10.arch1-1
linux-api-headers 6.19-1
linux-atm 2.5.2-9
linux-firmware 20260519-1
linux-firmware-amdgpu 20260519-1
linux-firmware-atheros 20260519-1
linux-firmware-broadcom 20260519-1
linux-firmware-cirrus 20260519-1
linux-firmware-intel 20260519-1
linux-firmware-mediatek 20260519-1
linux-firmware-nvidia 20260519-1
linux-firmware-other 20260519-1
linux-firmware-radeon 20260519-1
linux-firmware-realtek 20260519-1
linux-firmware-whence 20260519-1
linux-headers 7.0.10.arch1-1
mangohud 0.8.3-2
nvidia-open-dkms 595.71.05-2
nvidia-settings 595.71.05-1
nvidia-utils 595.71.05-2
pipewire 1:1.6.6-1
pipewire-session-manager 1:1.6.6-1
plasma5support 6.6.5-1
plasma-activities 6.6.5-1
plasma-activities-stats 6.6.5-1
plasma-browser-integration 6.6.5-1
plasma-camera 26.04.1-1
plasma-desktop 6.6.5-1
plasma-disks 6.6.5-1
plasma-firewall 6.6.5-1
plasma-integration 6.6.5-2
plasma-keyboard 6.6.5-1
plasma-login-manager 6.6.5-1
plasma-nm 6.6.5-1
plasma-pa 6.6.5-1
plasma-sdk 6.6.5-1
plasma-systemmonitor 6.6.5-1
plasma-thunderbolt 6.6.5-1
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 1

Linhas aproximadas 33-61:

```text
e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
```

#### Fonte: `documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

### Kernel/base funcional

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 2

Linhas aproximadas 1-25:

```text
## Auditoria automática do estado atual

Gerada em: 20260529-154304

Esta auditoria registra o estado real no momento da criação do manual. Ela não altera o sistema.

### Kernel atual

```text
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux
```

### Driver NVIDIA

```text
Fri May 29 15:43:04 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 595.71.05              Driver Version: 595.71.05      CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5060 Ti     On  |   00000000:01:00.0  On |                  N/A |
|  0%   37C    P8             11W /  180W |     843MiB /  16311MiB |      1%      Default |
```

Linhas aproximadas 57-85:

```text
|    0   N/A  N/A            2676      G   ./steamwebhelper                         23MiB |
|    0   N/A  N/A            2705    C+G   ...am/ubuntu12_64/steamwebhelper          5MiB |
|    0   N/A  N/A            3236      G   ...asma-browser-integration-host          2MiB |
|    0   N/A  N/A            4133      G   /usr/bin/kwalletd6                        2MiB |
|    0   N/A  N/A            8656      G   /usr/bin/konsole                          2MiB |
|    0   N/A  N/A            8813      G   /usr/bin/dolphin                          2MiB |
|    0   N/A  N/A            9032      G   /usr/bin/plasmashell                     71MiB |
+-----------------------------------------------------------------------------------------+
```

### Pacotes de kernel, NVIDIA, Vulkan e Steam relevantes

```text
egl-wayland2 1.0.1-1
egl-wayland 4:1.1.21-1
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
lib32-nvidia-utils 595.71.05-1
lib32-vulkan-icd-loader 1.4.350.0-1
linux-api-headers 6.19-1
linux-atm 2.5.2-9
linux-firmware 20260519-1
linux-firmware-amdgpu 20260519-1
linux-firmware-atheros 20260519-1
linux-firmware-broadcom 20260519-1
linux-firmware-cirrus 20260519-1
linux-firmware-intel 20260519-1
linux-firmware-mediatek 20260519-1
linux-firmware-nvidia 20260519-1
```

Linhas aproximadas 131-159:

```text

--- units conhecidas ---
display-manager.service                      alias           -
plasmalogin.service                          enabled         disabled
plymouth-halt.service                        static          -
plymouth-kexec.service                       static          -
plymouth-poweroff.service                    static          -
plymouth-quit-wait.service                   static          -
plymouth-quit.service                        static          -
plymouth-read-write.service                  static          -
plymouth-reboot.service                      static          -
plymouth-start.service                       static          -
plymouth-switch-root-initramfs.service       static          -
plymouth-switch-root.service                 static          -
sddm.service                                 disabled        disabled
systemd-ask-password-plymouth.service        static          -
systemd-tmpfiles-setup-dev-early.service     static          -
systemd-tpm2-setup-early.service             static          -
```

### Sessão gráfica

```text
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=KDE
Name=hal
Desktop=KDE
Type=wayland
```
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 2

Linhas aproximadas 20-30:

```text
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 1

Linhas aproximadas 33-61:

```text
e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 1

Linhas aproximadas 1-22:

```text
### DATA
sex 29 mai 2026 15:24:16 -03

### KERNEL
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

### PACOTES RELEVANTES
bluedevil 1:6.6.5-1
bluez 5.86-6
bluez-libs 5.86-6
bluez-qt 6.26.0-1
bluez-tools 0.2.0-6
gamemode 1.8.2-2
kdebugsettings 26.04.1-1
kdeclarative 6.26.0-1
kde-cli-tools 6.6.5-1
kdeconnect 26.04.1-1
kdecoration 6.6.5-1
kded 6.26.0-1
kde-dev-scripts 26.04.1-1
kde-dev-utils 26.04.1-1
kdeedu-data 26.04.1-1
```

#### Fonte: `documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
```

#### Fonte: `scripts/mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 1

Linhas aproximadas 2-30:

```bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi
```

#### Fonte: `scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 1

Linhas aproximadas 2-30:

```bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi
```

#### Fonte: `documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md`

Pontuação de relevância: 1

Linhas aproximadas 1-41:

```text
# Mocha Arch — esquema de login aprovado

Registro gerado em: `20260529-150104`

## Mounts persistentes corrigidos

- FAST: `UUID=88e6aa16-110c-4b97-9ffb-85084c000198` em `/media/mochafast`, tipo `btrfs`, label `MOCHAFAST`
- VMSTORE: `UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6` em `/media/vmstore`, tipo `xfs`, label `vmstore`
- O script não formatou, não particionou, não removeu pacote, não alterou bootloader e não mexeu em XU.
- No `/etc/fstab`, foram substituídas somente entradas cujo mountpoint era exatamente `/media/mochafast` ou `/media/vmstore`.

## Estado aprovado observado do login

- Gerenciador de login desejado para esta fase: `plasma-login.service`
- Sessão alvo: KDE Plasma em Wayland
- X11 não é fallback neste projeto, salvo ordem explícita posterior.
- Link atual de `display-manager.service`: `/usr/lib/systemd/system/plasmalogin.service`
- Unidade carregada pelo systemd: `/usr/lib/systemd/system/plasmalogin.service`
- Estado de `plasma-login.service`: enabled=`not-found`, active=`inactive`
- Estado de `sddm.service`: enabled=`disabled`, active=`inactive`
- Sessão atual detectada: Type=`wayland`, Desktop=`KDE`

## Regra operacional

1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
```

### Login manager / Wayland

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 6

Linhas aproximadas 25-54:

```text
|  0%   37C    P8             11W /  180W |     843MiB /  16311MiB |      1%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A             891      G   /usr/bin/ksecretd                         2MiB |
|    0   N/A  N/A             956      G   /usr/bin/kwin_wayland                    30MiB |
|    0   N/A  N/A            1039      G   /usr/bin/Xwayland                         2MiB |
|    0   N/A  N/A            1079      G   /usr/bin/ksmserver                        2MiB |
|    0   N/A  N/A            1081      G   /usr/bin/kded6                            2MiB |
|    0   N/A  N/A            1192      G   /usr/bin/kaccess                          2MiB |
|    0   N/A  N/A            1193      G   ...it-kde-authentication-agent-1          2MiB |
|    0   N/A  N/A            1288      G   /usr/bin/kdeconnectd                      2MiB |
|    0   N/A  N/A            1319      G   /usr/lib/firefox/firefox                243MiB |
|    0   N/A  N/A            1487      G   /usr/bin/akonadi_control                  2MiB |
|    0   N/A  N/A            1679      G   ...bin/akonadi_archivemail_agent          2MiB |
|    0   N/A  N/A            1682      G   ...konadi_followupreminder_agent          2MiB |
|    0   N/A  N/A            1686      G   .../akonadi_maildispatcher_agent          2MiB |
|    0   N/A  N/A            1687      G   .../bin/akonadi_mailfilter_agent          2MiB |
|    0   N/A  N/A            1688      G   /usr/bin/akonadi_mailmerge_agent          2MiB |
|    0   N/A  N/A            1689      G   /usr/bin/akonadi_migration_agent          2MiB |
|    0   N/A  N/A            1690      G   ...akonadi_newmailnotifier_agent          2MiB |
|    0   N/A  N/A            1691      G   /usr/bin/akonadi_sendlater_agent          2MiB |
|    0   N/A  N/A            1692      G   .../akonadi_unifiedmailbox_agent          2MiB |
|    0   N/A  N/A            2033      G   /usr/lib/DiscoverNotifier                 2MiB |
|    0   N/A  N/A            2042      G   /usr/bin/kalendarac                       2MiB |
```

Linhas aproximadas 60-127:

```text
|    0   N/A  N/A            4133      G   /usr/bin/kwalletd6                        2MiB |
|    0   N/A  N/A            8656      G   /usr/bin/konsole                          2MiB |
|    0   N/A  N/A            8813      G   /usr/bin/dolphin                          2MiB |
|    0   N/A  N/A            9032      G   /usr/bin/plasmashell                     71MiB |
+-----------------------------------------------------------------------------------------+
```

### Pacotes de kernel, NVIDIA, Vulkan e Steam relevantes

```text
egl-wayland2 1.0.1-1
egl-wayland 4:1.1.21-1
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
lib32-nvidia-utils 595.71.05-1
lib32-vulkan-icd-loader 1.4.350.0-1
linux-api-headers 6.19-1
linux-atm 2.5.2-9
linux-firmware 20260519-1
linux-firmware-amdgpu 20260519-1
linux-firmware-atheros 20260519-1
linux-firmware-broadcom 20260519-1
linux-firmware-cirrus 20260519-1
linux-firmware-intel 20260519-1
linux-firmware-mediatek 20260519-1
linux-firmware-nvidia 20260519-1
linux-firmware-other 20260519-1
linux-firmware-radeon 20260519-1
linux-firmware-realtek 20260519-1
linux-firmware-whence 20260519-1
linux-headers 7.0.10.arch1-1
mangohud 0.8.3-2
nvidia-open-dkms 595.71.05-2
nvidia-settings 595.71.05-1
nvidia-utils 595.71.05-2
opencl-nvidia 595.71.05-2
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
vulkan-icd-loader 1.4.350.0-1
vulkan-tools 1.4.350.0-1
```

### Login manager / display manager

```text
● plasmalogin.service - Plasma Login Manager
     Loaded: loaded (/usr/lib/systemd/system/plasmalogin.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 1h 13min ago
 Invocation: 7c16afbe746f47008acd42cd1d5dbc36
       Docs: man:plasmalogin(1)
             man:plasmalogin.conf(5)
   Main PID: 683 (plasmalogin)
      Tasks: 2 (limit: 18662)
     Memory: 16.8M (peak: 39.4M, swap: 560K, swap peak: 560K, zswap: 112.7K)
        CPU: 106ms
     CGroup: /system.slice/plasmalogin.service
             └─683 /usr/bin/plasmalogin

mai 29 14:29:52 Mocha plasmalogin-helper[865]: [PAM] returning.
mai 29 14:29:52 Mocha plasmalogin[683]: Authentication for user  "hal"  successful
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_kwallet5(plasmalogin:setcred): pam_kwallet5: pam_sm_setcred
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_unix(plasmalogin:session): session opened for user hal(uid=1000) by hal(uid=0)
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_kwallet5(plasmalogin:session): pam_kwallet5: pam_sm_open_session
mai 29 14:29:52 Mocha plasmalogin-helper[865]: Starting Wayland user session: "/usr/share/plasmalogin/scripts/wayland-session" "/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland"
mai 29 14:29:52 Mocha plasmalogin[683]: Session started true
mai 29 14:29:57 Mocha plasmalogin[683]: Greeter stopping...
mai 29 14:29:57 Mocha plasmalogin[683]: Auth: plasmalogin-helper exited with 255
mai 29 14:29:57 Mocha plasmalogin[683]: Greeter stopped. PLASMALOGIN::Auth::HelperExitStatus(255)
```

#### Fonte: `documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md`

Pontuação de relevância: 6

Linhas aproximadas 4-41:

```text

## Mounts persistentes corrigidos

- FAST: `UUID=88e6aa16-110c-4b97-9ffb-85084c000198` em `/media/mochafast`, tipo `btrfs`, label `MOCHAFAST`
- VMSTORE: `UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6` em `/media/vmstore`, tipo `xfs`, label `vmstore`
- O script não formatou, não particionou, não removeu pacote, não alterou bootloader e não mexeu em XU.
- No `/etc/fstab`, foram substituídas somente entradas cujo mountpoint era exatamente `/media/mochafast` ou `/media/vmstore`.

## Estado aprovado observado do login

- Gerenciador de login desejado para esta fase: `plasma-login.service`
- Sessão alvo: KDE Plasma em Wayland
- X11 não é fallback neste projeto, salvo ordem explícita posterior.
- Link atual de `display-manager.service`: `/usr/lib/systemd/system/plasmalogin.service`
- Unidade carregada pelo systemd: `/usr/lib/systemd/system/plasmalogin.service`
- Estado de `plasma-login.service`: enabled=`not-found`, active=`inactive`
- Estado de `sddm.service`: enabled=`disabled`, active=`inactive`
- Sessão atual detectada: Type=`wayland`, Desktop=`KDE`

## Regra operacional

1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
```

#### Fonte: `scripts/mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 3

Linhas aproximadas 1-44:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi

echo "== Aplicando esquema aprovado =="
"$SUDO" systemctl disable --now sddm.service 2>/dev/null || true
"$SUDO" systemctl enable plasma-login.service
"$SUDO" systemctl set-default graphical.target

echo
echo "== Verificação depois da alteração =="
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || true
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || true
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || true
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || true
echo
echo "Concluído. Reinicie apenas quando quiser testar o login pelo plasma-login."
```

#### Fonte: `scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 3

Linhas aproximadas 1-44:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi

echo "== Aplicando esquema aprovado =="
"$SUDO" systemctl disable --now sddm.service 2>/dev/null || true
"$SUDO" systemctl enable plasma-login.service
"$SUDO" systemctl set-default graphical.target

echo
echo "== Verificação depois da alteração =="
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || true
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || true
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || true
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || true
echo
echo "Concluído. Reinicie apenas quando quiser testar o login pelo plasma-login."
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 2

Linhas aproximadas 60-88:

```text
plasma5support 6.6.5-1
plasma-activities 6.6.5-1
plasma-activities-stats 6.6.5-1
plasma-browser-integration 6.6.5-1
plasma-camera 26.04.1-1
plasma-desktop 6.6.5-1
plasma-disks 6.6.5-1
plasma-firewall 6.6.5-1
plasma-integration 6.6.5-2
plasma-keyboard 6.6.5-1
plasma-login-manager 6.6.5-1
plasma-nm 6.6.5-1
plasma-pa 6.6.5-1
plasma-sdk 6.6.5-1
plasma-systemmonitor 6.6.5-1
plasma-thunderbolt 6.6.5-1
plasmatube 26.04.1-2
plasma-vault 6.6.5-1
plasma-welcome 6.6.5-1
plasma-workspace 6.6.5-2
plasma-workspace-wallpapers 6.6.5-1
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
wireplumber 0.5.14-1

### SERVIÇOS DO SISTEMA RELACIONADOS
● bluetooth.service - Bluetooth service
     Loaded: loaded (/usr/lib/systemd/system/bluetooth.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 54min ago
```

Linhas aproximadas 114-182:

```text
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-blueman@autostart.service                                                                                           loaded active running   Blueman Applet
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
plasma-gmenudbusmenuproxy.service                                                                                       loaded active running   Proxies GTK DBus menus to a Plasma readable format
plasma-kaccess.service                                                                                                  loaded active running   KAccess
plasma-kactivitymanagerd.service                                                                                        loaded active running   KActivityManager Activity manager Service
plasma-kded6.service                                                                                                    loaded active running   KDE Daemon 6
plasma-ksmserver.service                                                                                                loaded active running   KDE Session Management Server
plasma-kwin_wayland.service                                                                                             loaded active running   KDE Wayland Compositor
plasma-plasmashell.service                                                                                              loaded active running   KDE Plasma Workspace
plasma-polkit-agent.service                                                                                             loaded active running   KDE PolicyKit Authentication Agent
plasma-powerdevil.service                                                                                               loaded active running   Powerdevil
plasma-xdg-desktop-portal-kde.service                                                                                   loaded active running   Xdg Desktop Portal For KDE
plasma-xembedsniproxy.service                                                                                           loaded active running   Handle legacy xembed system tray icons
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth
plasma-core.target                                                                                                      loaded active active    KDE Plasma Workspace Core
plasma-workspace-wayland.target                                                                                         loaded active active    plasma-workspace-wayland.target
plasma-workspace.target                                                                                                 loaded active active    KDE Plasma Workspace

### ÁUDIO
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
Índice do cliente: 39
Tamanho de fragmento: 65472
Nome do usuário: hal
Nome da máquina: Mocha
Nome do servidor: pulseaudio
Versão do servidor: 17.0-98-gb096
Especificação padrão de amostragem: s16le 2ch 44100Hz
Mapa de canais padrão: front-left,front-right
Destino padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink
Fonte padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor
Cookie: ed82:a34c

2	alsa_output.pci-0000_01_00.1.hdmi-stereo	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

2	alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

PipeWire 'pipewire-0' [1.6.6, hal@Mocha, cookie:1187326163]
 └─ Clients:
        32. kwin_wayland                        [1.6.6, hal@Mocha, pid:956]
        33. WirePlumber                         [1.6.6, hal@Mocha, pid:1015]
        41. WirePlumber [export]                [1.6.6, hal@Mocha, pid:1015]
        42. plasmashell                         [1.6.6, hal@Mocha, pid:1114]
        43. xdg-desktop-portal                  [1.6.6, hal@Mocha, pid:964]
        47. wpctl                               [1.6.6, hal@Mocha, pid:8278]

Audio
 ├─ Devices:
 │  
 ├─ Sinks:
 │  
 ├─ Sources:
 │  
 ├─ Filters:
 │  
 └─ Streams:

Video
```

### Montagem FAST e VMSTORE

#### Fonte: `documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md`

Pontuação de relevância: 5

Linhas aproximadas 1-41:

```text
# Mocha Arch — esquema de login aprovado

Registro gerado em: `20260529-150104`

## Mounts persistentes corrigidos

- FAST: `UUID=88e6aa16-110c-4b97-9ffb-85084c000198` em `/media/mochafast`, tipo `btrfs`, label `MOCHAFAST`
- VMSTORE: `UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6` em `/media/vmstore`, tipo `xfs`, label `vmstore`
- O script não formatou, não particionou, não removeu pacote, não alterou bootloader e não mexeu em XU.
- No `/etc/fstab`, foram substituídas somente entradas cujo mountpoint era exatamente `/media/mochafast` ou `/media/vmstore`.

## Estado aprovado observado do login

- Gerenciador de login desejado para esta fase: `plasma-login.service`
- Sessão alvo: KDE Plasma em Wayland
- X11 não é fallback neste projeto, salvo ordem explícita posterior.
- Link atual de `display-manager.service`: `/usr/lib/systemd/system/plasmalogin.service`
- Unidade carregada pelo systemd: `/usr/lib/systemd/system/plasmalogin.service`
- Estado de `plasma-login.service`: enabled=`not-found`, active=`inactive`
- Estado de `sddm.service`: enabled=`disabled`, active=`inactive`
- Sessão atual detectada: Type=`wayland`, Desktop=`KDE`

## Regra operacional

1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
```

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 4

Linhas aproximadas 151-192:

```text
### Sessão gráfica

```text
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=KDE
Name=hal
Desktop=KDE
Type=wayland
```

### Montagens obrigatórias FAST e VMSTORE

```text
/media/mochafast: MONTADO
TARGET           SOURCE    FSTYPE OPTIONS
/media/mochafast /dev/sda1 btrfs  rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=5,subvol=/

/media/vmstore: MONTADO
TARGET         SOURCE    FSTYPE OPTIONS
/media/vmstore /dev/sdb1 xfs    rw,noatime,inode64,logbufs=8,logbsize=32k,noquota

--- /etc/fstab: entradas relevantes ---
17:UUID=88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast btrfs defaults,noatime,compress=zstd:3,ssd,discard=async,nofail,x-systemd.device-timeout=10s 0 0
18:UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore xfs defaults,noatime,nofail,x-systemd.device-timeout=10s 0 2
```

### Energia, CPU, GPU e agressividade

```text
--- powerprofilesctl ---
powerprofilesctl não encontrado.

--- tuned ---
Current active profile: latency-performance
enabled
active

--- governor CPU ---
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu3/cpufreq/scaling_governor:performance
```

#### Fonte: `kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh`

Pontuação de relevância: 2

Linhas aproximadas 1-41:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
fi

if [ ! -f "$APPROVED" ]; then
  echo "ERRO: appletsrc aprovado não encontrado:"
  echo "  $APPROVED"
  exit 1
fi

if [ ! -f "$CFG" ]; then
  echo "ERRO: appletsrc atual não encontrado:"
  echo "  $CFG"
  exit 1
fi

if ! grep -q 'plugin=org.kde.plasma.panelspacer' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem panelspacer. Abortando."
  exit 1
```

#### Fonte: `logs/20260529-154304-criar-manual-vivo-definitivo-mocha-arch-kde.log`

Pontuação de relevância: 1

Linhas aproximadas 1-12:

```text
== Preflight ==
FAST montado: OK
Pasta ativa: /media/mochafast/MochaArch/ativo

== Backup do manual anterior, se existir ==
Nenhum manual anterior com nome fixo.

== Gerando auditoria do estado atual ==
Auditoria salva:
  /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md

== Extraindo evidências e comandos salvos por tema ==
```

#### Fonte: `logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 1-22:

```text
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
```

#### Fonte: `logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 1-57:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada: OK
Arquivo aprovado: OK
Config atual: OK

== Auditoria do arquivo aprovado ==
Arquivo:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617

Assinaturas esperadas:
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true

Assinatura da barra aprovada validada.

== Criando script reutilizável na pasta aprovada ==
Script reutilizável criado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

== Executando restauração da barra aprovada ==
== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11

== Finalizado ==
Log principal:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log
Script salvo para uso futuro:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
```

#### Fonte: `logs/20260529-153249-aplicar-barra-win11-aprovada-pasta-certa.log`

Pontuação de relevância: 1

Linhas aproximadas 1-16:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada encontrada: OK
Configuração Plasma encontrada: OK

== Conteúdo da pasta aprovada ==
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt

== Procurando script aprovado dentro da pasta correta ==
ERRO: não achei script .sh/.bash aprovado dentro de:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada

Arquivos encontrados:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 1-26:

```text
== Preflight ==
FAST montado: OK
Pasta de scripts: /media/mochafast/MochaArch/ativo/scripts
Config Plasma: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

== Procurando script aprovado da barra Mocha/KDE ==
Script escolhido:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
```

Linhas aproximadas 109-134:

```text
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x blueman-applet 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "Mocha KDE: autostarts redundantes de Blueman e KMix desativados."
echo "Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume."
--- fim da auditoria curta ---

== Backup da configuração atual do Plasma ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
Mantendo no máximo 2 backups recentes desta configuração...

== Executando script documentado/aprovado da barra ==
Mocha KDE: autostarts redundantes de Blueman e KMix desativados.
Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume.

== Reiniciando Plasma Shell para refletir a barra, se necessário ==

== Finalizado ==
Barra Mocha aplicada usando:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
```

#### Fonte: `auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log`

Pontuação de relevância: 1

Linhas aproximadas 40-60:

```text
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

== 5/6 Criando script reutilizável ==
Script criado: /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== 6/6 Documentando como passo canônico de montagem ==
Documento criado:
/media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md

Passo canônico criado:
/media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md

Log salvo em:
/media/mochafast/MochaArch/ativo/auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 1

Linhas aproximadas 50-68:

```text
1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 1

Linhas aproximadas 50-68:

```text
1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log`

Pontuação de relevância: 1

Linhas aproximadas 14-42:

```text
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
2060 /usr/bin/kmix --keepvisibility
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

== 2/7 Confirmando que o volume do Plasma existe no system tray ==
OK: org.kde.plasma.volume existe no Plasma. Podemos remover apenas o KMix redundante da sessão/autostart.

== 3/7 Localizando arquivo original de autostart do KMix ==
Fonte encontrada: /etc/xdg/autostart/kmix_autostart.desktop

== 4/7 Criando override local com Hidden=true para KMix ==
Override final:
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 5/7 Parando KMix nesta sessão ==
KMix após stop:
OK: kmix não está mais rodando.

```

Linhas aproximadas 54-97:

```text
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes depois
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

### Áudio continua respondendo?
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
Índice do cliente: 44
Tamanho de fragmento: 65472
Nome do usuário: hal
Nome da máquina: Mocha
Nome do servidor: pulseaudio
Versão do servidor: 17.0-98-gb096
Especificação padrão de amostragem: s16le 2ch 44100Hz
Mapa de canais padrão: front-left,front-right
Destino padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink
Fonte padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor
Cookie: ed82:a34c

2	alsa_output.pci-0000_01_00.1.hdmi-stereo	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

### Bluetooth continua ativo?
active

== 7/7 Salvando documentação e script reutilizável ==
Documento criado:
/media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md

Script reutilizável criado:
/media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh

Log salvo em:
/media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log
```

### Bluetooth e volume duplicados

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 6

Linhas aproximadas 237-275:

```text
        Requested Power Limit                          : N/A
        Default Power Limit                            : N/A
        Min Power Limit                                : N/A
        Max Power Limit                                : N/A
    EDPp Multiplier                                    : N/A

disabled
inactive
```

### Correção Bluetooth e volume duplicados

```text
--- /home/hal/.config/autostart/blueman.desktop ---
[Desktop Entry]
Name[be]=Аплет Blueman
Name[da]=Blueman-panelprogram
Name[de]=Blueman Applet
Name[el]=Εφαρμογή blueman
Name[en_GB]=Blueman Applet
Name[es]=Miniaplicación Blueman
Name[et]=Blueman rakend
Name[eu]=Blueman trepeta
Name[fi]=Blueman-sovelma
Name[fr]=Applet Blueman
Name[ga]=Feidhmchláirín Blueman
Name[he]=יישומון Blueman
Name[hr]=Blueman aplet
Name[hu]=Blueman kisalkalmazás
Name[is]=Blueman-smáforrit
Name[it]=Blueman Applet
Name[ja]=Bluetooth アプレット
Name[ko]=Blueman 애플릿
Name[mr]=ब्लूमॅन ॲपलेट
Name[ms]=Aplet Blueman
Name[nb]=Blueman-panelprogram
Name[nl]=Blueman-werkbalkhulpje
Name[pl]=Aplet Blueman
Name[pt_BR]=Miniaplicativo Blueman
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 6

Linhas aproximadas 1-84:

```text
== Preflight ==
FAST montado: OK
Pasta de scripts: /media/mochafast/MochaArch/ativo/scripts
Config Plasma: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

== Procurando script aprovado da barra Mocha/KDE ==
Script escolhido:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
      break
    fi
  done

  if [ -n "$src" ]; then
    cp -a "$src" "$target"
  else
    cat > "$target" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
EOINNER
  fi

  if grep -q '^Hidden=' "$target"; then
    sed -i 's/^Hidden=.*/Hidden=true/' "$target"
  else
    printf '\nHidden=true\n' >> "$target"
  fi
}

write_hidden_desktop_skel() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local skel_dir="/etc/skel/.config/autostart"
  local target="$skel_dir/$name"
  local tmp

  $SUDO mkdir -p "$skel_dir"
  tmp="$(mktemp)"

  cat > "$tmp" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
Hidden=true
EOINNER

  $SUDO install -m 0644 "$tmp" "$target"
  rm -f "$tmp"
```

#### Fonte: `auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log`

Pontuação de relevância: 6

Linhas aproximadas 1-31:

```text
== 1/6 Confirmando applets nativos do KDE/Plasma ==
75:plugin=org.kde.plasma.systemtray
114:plugin=org.kde.plasma.volume
145:plugin=org.kde.plasma.bluetooth

== 2/6 Aplicando permanência no usuário atual ==
OK usuário: /home/hal/.config/autostart/blueman.desktop
38:Name=Blueman Applet
78:Exec=blueman-applet
83:Hidden=true

OK usuário: /home/hal/.config/autostart/kmix_autostart.desktop
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 3/6 Preparando /etc/skel para novos usuários do Mocha ==
OK /etc/skel: /etc/skel/.config/autostart/blueman.desktop
3:Name=blueman.desktop
5:Exec=blueman-applet
6:OnlyShowIn=KDE;
7:Hidden=true

OK /etc/skel: /etc/skel/.config/autostart/kmix_autostart.desktop
3:Name=kmix_autostart.desktop
5:Exec=kmix --keepvisibility
6:OnlyShowIn=KDE;
7:Hidden=true

== 4/6 Garantindo sessão atual limpa ==
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 6

Linhas aproximadas 1-44:

```text
# Mocha Arch/KDE — passo canônico: barra sem Bluetooth/volume duplicados

Timestamp: 20260529-152907

## Status

Aprovado pelo usuário em teste real.

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:

- `~/.config/autostart/blueman.desktop`
- `~/.config/autostart/kmix_autostart.desktop`

Arquivos preparados para novos usuários:

- `/etc/skel/.config/autostart/blueman.desktop`
- `/etc/skel/.config/autostart/kmix_autostart.desktop`
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 6

Linhas aproximadas 1-44:

```text
# Mocha Arch/KDE — passo canônico: barra sem Bluetooth/volume duplicados

Timestamp: 20260529-152907

## Status

Aprovado pelo usuário em teste real.

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:

- `~/.config/autostart/blueman.desktop`
- `~/.config/autostart/kmix_autostart.desktop`

Arquivos preparados para novos usuários:

- `/etc/skel/.config/autostart/blueman.desktop`
- `/etc/skel/.config/autostart/kmix_autostart.desktop`
```

#### Fonte: `scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

Pontuação de relevância: 6

Linhas aproximadas 5-87:

```bash

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
      break
    fi
  done

  if [ -n "$src" ]; then
    cp -a "$src" "$target"
  else
    cat > "$target" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
EOINNER
  fi

  if grep -q '^Hidden=' "$target"; then
    sed -i 's/^Hidden=.*/Hidden=true/' "$target"
  else
    printf '\nHidden=true\n' >> "$target"
  fi
}

write_hidden_desktop_skel() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local skel_dir="/etc/skel/.config/autostart"
  local target="$skel_dir/$name"
  local tmp

  $SUDO mkdir -p "$skel_dir"
  tmp="$(mktemp)"

  cat > "$tmp" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
Hidden=true
EOINNER

  $SUDO install -m 0644 "$tmp" "$target"
  rm -f "$tmp"
}

apply_hidden_desktop_user \
  "blueman.desktop" \
  "blueman-applet" \
  "Mocha KDE: disabled because KDE/Bluedevil already provides Bluetooth in the system tray"

apply_hidden_desktop_user \
  "kmix_autostart.desktop" \
  "kmix --keepvisibility" \
  "Mocha KDE: disabled because Plasma volume applet already provides volume control in the system tray"

write_hidden_desktop_skel \
  "blueman.desktop" \
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 6

Linhas aproximadas 1-35:

```text
# Mocha Arch/KDE — volume duplicado corrigido por desativação do KMix

Timestamp: 20260529-152700

## Diagnóstico

A barra apresentava volume duplicado.

A auditoria mostrou:

- O applet normal do Plasma para volume existe no system tray:
  - `org.kde.plasma.volume`
- O KMix também estava rodando por autostart:
  - `app-kmix_autostart@autostart.service`
  - processo `kmix --keepvisibility`

Isso cria redundância visual de volume.

## Ação aplicada

Foi criado/ajustado o override local:

`/home/hal/.config/autostart/kmix_autostart.desktop`

com:

`Hidden=true`

Também foi parado nesta sessão:

`app-kmix_autostart@autostart.service`

e encerrado o processo:

`kmix`
```

#### Fonte: `auditorias/20260529-152529-corrigir-blueman-auditar-volume/execucao.log`

Pontuação de relevância: 6

Linhas aproximadas 1-29:

```text
== 1/6 Estado antes ==

### Serviços de usuário relevantes antes
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0-hci0:1.device                    loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0/hci0:1
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0.device                           loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0
sys-subsystem-bluetooth-devices-hci0.device                                                                             loaded active plugged   /sys/subsystem/bluetooth/devices/hci0
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-blueman@autostart.service                                                                                           loaded active running   Blueman Applet
app-kmix_autostart@autostart.service                                                                                    loaded active running   KMix
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
1994 /usr/bin/python /usr/bin/blueman-applet
2060 /usr/bin/kmix --keepvisibility

== 2/6 Criando override local para impedir autostart do Blueman ==
Criado override local a partir de: /etc/xdg/autostart/blueman.desktop
Override final:
```

#### Fonte: `auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log`

Pontuação de relevância: 5

Linhas aproximadas 1-34:

```text
== 1/7 Estado antes ==

### Serviços de usuário relevantes antes
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0-hci0:1.device                    loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0/hci0:1
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0.device                           loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0
sys-subsystem-bluetooth-devices-hci0.device                                                                             loaded active plugged   /sys/subsystem/bluetooth/devices/hci0
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-kmix_autostart@autostart.service                                                                                    loaded active running   KMix
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
2060 /usr/bin/kmix --keepvisibility
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

== 2/7 Confirmando que o volume do Plasma existe no system tray ==
OK: org.kde.plasma.volume existe no Plasma. Podemos remover apenas o KMix redundante da sessão/autostart.

== 3/7 Localizando arquivo original de autostart do KMix ==
Fonte encontrada: /etc/xdg/autostart/kmix_autostart.desktop

== 4/7 Criando override local com Hidden=true para KMix ==
Override final:
2:Exec=kmix --keepvisibility
```

#### Fonte: `scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh`

Pontuação de relevância: 4

Linhas aproximadas 1-43:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

AUTO_USER="$HOME/.config/autostart/kmix_autostart.desktop"
mkdir -p "$HOME/.config/autostart"

SRC=""
for candidate in \
  "/etc/xdg/autostart/kmix_autostart.desktop" \
  "/usr/etc/xdg/autostart/kmix_autostart.desktop" \
  "/usr/share/applications/org.kde.kmix.desktop" \
  "/usr/share/applications/kmix.desktop"
do
  if [ -f "$candidate" ]; then
    SRC="$candidate"
    break
  fi
done

if [ -n "$SRC" ]; then
  cp -a "$SRC" "$AUTO_USER"
else
  cat > "$AUTO_USER" <<'EOINNER'
[Desktop Entry]
Type=Application
Name=KMix
Comment=Disabled by Mocha KDE because Plasma volume applet already provides volume control in the system tray
Exec=kmix --keepvisibility
OnlyShowIn=KDE;
EOINNER
fi

if grep -q '^Hidden=' "$AUTO_USER"; then
  sed -i 's/^Hidden=.*/Hidden=true/' "$AUTO_USER"
else
  printf '\nHidden=true\n' >> "$AUTO_USER"
fi

systemctl --user stop app-kmix_autostart@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "KMix autostart desativado para o usuário atual."
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 3

Linhas aproximadas 76-118:

```text
plasmatube 26.04.1-2
plasma-vault 6.6.5-1
plasma-welcome 6.6.5-1
plasma-workspace 6.6.5-2
plasma-workspace-wallpapers 6.6.5-1
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
wireplumber 0.5.14-1

### SERVIÇOS DO SISTEMA RELACIONADOS
● bluetooth.service - Bluetooth service
     Loaded: loaded (/usr/lib/systemd/system/bluetooth.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 54min ago
 Invocation: 040213ede68b4cc48886bc2a25c46bd6
       Docs: man:bluetoothd(8)
   Main PID: 617 (bluetoothd)
     Status: "Running"
      Tasks: 1 (limit: 18662)
     Memory: 2M (peak: 3.4M)
        CPU: 47ms
     CGroup: /system.slice/bluetooth.service
             └─617 /usr/lib/bluetooth/bluetoothd

mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/sbc_xq_453
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc_xq_453
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/sbc_xq_512
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc_xq_512
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/sbc_xq_552
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc_xq_552
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/faststream
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/faststream
mai 29 15:01:55 Mocha bluetoothd[617]: /org/bluez/hci0/dev_0C_ED_E7_FF_AB_9D/sep1/fd0: fd(31) ready

### SERVIÇOS DE USUÁRIO RELACIONADOS
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0-hci0:1.device                    loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0/hci0:1
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0.device                           loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0
sys-subsystem-bluetooth-devices-hci0.device                                                                             loaded active plugged   /sys/subsystem/bluetooth/devices/hci0
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-blueman@autostart.service                                                                                           loaded active running   Blueman Applet
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt`

Pontuação de relevância: 2

Linhas aproximadas 1-11:

```text
Auditoria somente leitura da duplicidade de Bluetooth/volume.

Arquivos principais:
- resumo-auditoria.txt
- plasma-applets-volume-bluetooth-systemtray.txt
- plasma-org.kde.plasma.desktop-appletsrc.copia

Interpretação esperada:
- Se houver org.kde.plasma.volume como applet independente e também dentro do system tray, a correção provável é remover apenas o applet independente.
- Se houver org.kde.plasma.bluetooth como applet independente e também dentro do system tray, a correção provável é remover apenas o applet independente.
- Não corrigir por dedução. Corrigir apenas após confirmar no relatório.
```

### Barra Win11/Mocha KDE

#### Fonte: `kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh`

Pontuação de relevância: 7

Linhas aproximadas 1-58:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
fi

if [ ! -f "$APPROVED" ]; then
  echo "ERRO: appletsrc aprovado não encontrado:"
  echo "  $APPROVED"
  exit 1
fi

if [ ! -f "$CFG" ]; then
  echo "ERRO: appletsrc atual não encontrado:"
  echo "  $CFG"
  exit 1
fi

if ! grep -q 'plugin=org.kde.plasma.panelspacer' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem panelspacer. Abortando."
  exit 1
fi

if ! grep -Eq 'plugin=org\.kde\.plasma\.(icontasks|taskmanager)' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem icontasks/taskmanager. Abortando."
  exit 1
fi

BACKUP="$BACKUP_DIR/${TS}-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11"
cp -a "$CFG" "$BACKUP"

find "$BACKUP_DIR" -maxdepth 1 -type f -name '*plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11*' \
  -printf '%T@ %p\n' 2>/dev/null \
  | sort -nr \
  | awk 'NR>2 {sub(/^[^ ]+ /,""); print}' \
  | while IFS= read -r old; do
      [ -n "$old" ] && rm -f -- "$old"
    done || true
```

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 6

Linhas aproximadas 53-81:

```text
|    0   N/A  N/A            2033      G   /usr/lib/DiscoverNotifier                 2MiB |
|    0   N/A  N/A            2042      G   /usr/bin/kalendarac                       2MiB |
|    0   N/A  N/A            2093      G   /usr/lib/xdg-desktop-portal-kde           2MiB |
|    0   N/A  N/A            2469      G   ...share/Steam/ubuntu12_32/steam          4MiB |
|    0   N/A  N/A            2676      G   ./steamwebhelper                         23MiB |
|    0   N/A  N/A            2705    C+G   ...am/ubuntu12_64/steamwebhelper          5MiB |
|    0   N/A  N/A            3236      G   ...asma-browser-integration-host          2MiB |
|    0   N/A  N/A            4133      G   /usr/bin/kwalletd6                        2MiB |
|    0   N/A  N/A            8656      G   /usr/bin/konsole                          2MiB |
|    0   N/A  N/A            8813      G   /usr/bin/dolphin                          2MiB |
|    0   N/A  N/A            9032      G   /usr/bin/plasmashell                     71MiB |
+-----------------------------------------------------------------------------------------+
```

### Pacotes de kernel, NVIDIA, Vulkan e Steam relevantes

```text
egl-wayland2 1.0.1-1
egl-wayland 4:1.1.21-1
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
lib32-nvidia-utils 595.71.05-1
lib32-vulkan-icd-loader 1.4.350.0-1
linux-api-headers 6.19-1
linux-atm 2.5.2-9
linux-firmware 20260519-1
linux-firmware-amdgpu 20260519-1
linux-firmware-atheros 20260519-1
linux-firmware-broadcom 20260519-1
```

Linhas aproximadas 387-425:

```text
Comment=Mocha KDE: disabled because Plasma volume applet already provides volume control in the system tray
Exec=kmix --keepvisibility
OnlyShowIn=KDE;
Hidden=true

```

### Barra Win11/Mocha aprovada

```text
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:33  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

--- assinaturas do appletsrc aprovado ---
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true
```

### Scripts e documentos principais no ativo

```text
2026-05-28 22:56  1159 bytes  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:01  1754 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md
2026-05-29 15:01  2068 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:01  2068 bytes  /media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:24  10321 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt
2026-05-29 15:24  1070 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md
2026-05-29 15:24  4616 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/plasma-applets-volume-bluetooth-systemtray.txt
2026-05-29 15:24  624 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt
2026-05-29 15:25  3401 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152529-corrigir-blueman-auditar-volume/execucao.log
2026-05-29 15:27  1108 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 6

Linhas aproximadas 1-30:

```text
MOCHA ARCH / KDE — BARRA ESTILO WINDOWS 11 APROVADA
Timestamp: 20260528-225617

Status:
- Funcionou e foi aprovado pelo usuário nesta instalação EndeavourOS KDE.
- Deve ser preservado como solução de referência para MochaArch.

O que a solução faz:
- Audita o arquivo real:
  $HOME/.config/plasma-org.kde.plasma.desktop-appletsrc
- Cria backup com timestamp.
- Mantém no máximo 2 backups do arquivo da barra.
- Usa dois org.kde.plasma.panelspacer expansíveis.
- Centraliza Kickoff/Iniciar + icontasks/taskmanager.
- Preserva pager/outros applets à esquerda.
- Mantém systemtray/digitalclock/showdesktop à direita.
- Reinicia somente plasmashell.

Arquivos salvos:
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

#### Fonte: `logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log`

Pontuação de relevância: 5

Linhas aproximadas 1-22:

```text
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
```

#### Fonte: `logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log`

Pontuação de relevância: 5

Linhas aproximadas 1-51:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada: OK
Arquivo aprovado: OK
Config atual: OK

== Auditoria do arquivo aprovado ==
Arquivo:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617

Assinaturas esperadas:
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true

Assinatura da barra aprovada validada.

== Criando script reutilizável na pasta aprovada ==
Script reutilizável criado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

== Executando restauração da barra aprovada ==
== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
```

#### Fonte: `logs/20260529-153249-aplicar-barra-win11-aprovada-pasta-certa.log`

Pontuação de relevância: 2

Linhas aproximadas 1-16:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada encontrada: OK
Configuração Plasma encontrada: OK

== Conteúdo da pasta aprovada ==
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt

== Procurando script aprovado dentro da pasta correta ==
ERRO: não achei script .sh/.bash aprovado dentro de:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada

Arquivos encontrados:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/plasma-applets-volume-bluetooth-systemtray.txt`

Pontuação de relevância: 2

Linhas aproximadas 1-28:

```text
### PLUGINS RELEVANTES ENCONTRADOS NO plasma-org.kde.plasma.desktop-appletsrc
16:plugin=org.kde.plasma.folder
17:wallpaperplugin=org.kde.image
25:plugin=org.kde.panel
26:wallpaperplugin=org.kde.image
30:plugin=org.kde.plasma.digitalclock
41:plugin=org.kde.plasma.showdesktop
45:plugin=org.kde.plasma.kickoff
56:plugin=org.kde.plasma.pager
60:plugin=org.kde.plasma.icontasks
67:plugin=org.kde.plasma.marginsseparator
75:plugin=org.kde.plasma.systemtray
78:wallpaperplugin=org.kde.image
82:plugin=org.kde.kscreen
86:plugin=org.kde.plasma.keyboardlayout
90:plugin=org.kde.plasma.weather
94:plugin=org.kde.plasma.clipboard
98:plugin=org.kde.plasma.keyboardindicator
102:plugin=org.kde.plasma.devicenotifier
106:plugin=org.kde.plasma.printmanager
110:plugin=org.kde.plasma.cameraindicator
114:plugin=org.kde.plasma.volume
121:plugin=org.kde.plasma.notifications
125:plugin=org.kde.plasma.manage-inputmethod
129:plugin=org.kde.plasma.networkmanagement
133:plugin=org.kde.merkuro.contact.applet
137:plugin=org.kde.plasma.brightness
141:plugin=org.kde.plasma.battery
```

Linhas aproximadas 38-66:

```text
      1 plugin=org.kde.merkuro.contact.applet
      1 plugin=org.kde.panel
      1 plugin=org.kde.plasma.battery
      1 plugin=org.kde.plasma.bluetooth
      1 plugin=org.kde.plasma.brightness
      1 plugin=org.kde.plasma.cameraindicator
      1 plugin=org.kde.plasma.clipboard
      1 plugin=org.kde.plasma.devicenotifier
      1 plugin=org.kde.plasma.digitalclock
      1 plugin=org.kde.plasma.folder
      1 plugin=org.kde.plasma.icontasks
      1 plugin=org.kde.plasma.keyboardindicator
      1 plugin=org.kde.plasma.keyboardlayout
      1 plugin=org.kde.plasma.kickoff
      1 plugin=org.kde.plasma.manage-inputmethod
      1 plugin=org.kde.plasma.marginsseparator
      1 plugin=org.kde.plasma.networkmanagement
      1 plugin=org.kde.plasma.notifications
      1 plugin=org.kde.plasma.pager
      1 plugin=org.kde.plasma.printmanager
      1 plugin=org.kde.plasma.showdesktop
      1 plugin=org.kde.plasma.systemtray
      1 plugin=org.kde.plasma.vault
      1 plugin=org.kde.plasma.volume
      1 plugin=org.kde.plasma.weather

### SUSPEITOS DIRETOS
75:plugin=org.kde.plasma.systemtray
114:plugin=org.kde.plasma.volume
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 1-22:

```text
== Preflight ==
FAST montado: OK
Pasta de scripts: /media/mochafast/MochaArch/ativo/scripts
Config Plasma: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

== Procurando script aprovado da barra Mocha/KDE ==
Script escolhido:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
```

Linhas aproximadas 109-134:

```text
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x blueman-applet 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "Mocha KDE: autostarts redundantes de Blueman e KMix desativados."
echo "Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume."
--- fim da auditoria curta ---

== Backup da configuração atual do Plasma ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
Mantendo no máximo 2 backups recentes desta configuração...

== Executando script documentado/aprovado da barra ==
Mocha KDE: autostarts redundantes de Blueman e KMix desativados.
Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume.

== Reiniciando Plasma Shell para refletir a barra, se necessário ==

== Finalizado ==
Barra Mocha aplicada usando:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
```

#### Fonte: `auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log`

Pontuação de relevância: 1

Linhas aproximadas 12-40:

```text
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
2060 /usr/bin/kmix --keepvisibility
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

== 2/7 Confirmando que o volume do Plasma existe no system tray ==
OK: org.kde.plasma.volume existe no Plasma. Podemos remover apenas o KMix redundante da sessão/autostart.

== 3/7 Localizando arquivo original de autostart do KMix ==
Fonte encontrada: /etc/xdg/autostart/kmix_autostart.desktop

== 4/7 Criando override local com Hidden=true para KMix ==
Override final:
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 5/7 Parando KMix nesta sessão ==
KMix após stop:
```

Linhas aproximadas 53-81:

```text
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes depois
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

### Áudio continua respondendo?
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
Índice do cliente: 44
Tamanho de fragmento: 65472
Nome do usuário: hal
Nome da máquina: Mocha
Nome do servidor: pulseaudio
Versão do servidor: 17.0-98-gb096
Especificação padrão de amostragem: s16le 2ch 44100Hz
Mapa de canais padrão: front-left,front-right
Destino padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink
Fonte padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor
Cookie: ed82:a34c
```

#### Fonte: `auditorias/20260529-152529-corrigir-blueman-auditar-volume/execucao.log`

Pontuação de relevância: 1

Linhas aproximadas 13-41:

```text
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
1994 /usr/bin/python /usr/bin/blueman-applet
2060 /usr/bin/kmix --keepvisibility

== 2/6 Criando override local para impedir autostart do Blueman ==
Criado override local a partir de: /etc/xdg/autostart/blueman.desktop
Override final:
38:Name=Blueman Applet
78:Exec=blueman-applet
83:Hidden=true

== 3/6 Parando Blueman Applet nesta sessão ==
Blueman após stop:
blueman-applet não está mais rodando.

== 4/6 Mantendo Bluetooth do KDE e serviço do sistema ==
bluetooth.service:
active

```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt`

Pontuação de relevância: 1

Linhas aproximadas 1-11:

```text
Auditoria somente leitura da duplicidade de Bluetooth/volume.

Arquivos principais:
- resumo-auditoria.txt
- plasma-applets-volume-bluetooth-systemtray.txt
- plasma-org.kde.plasma.desktop-appletsrc.copia

Interpretação esperada:
- Se houver org.kde.plasma.volume como applet independente e também dentro do system tray, a correção provável é remover apenas o applet independente.
- Se houver org.kde.plasma.bluetooth como applet independente e também dentro do system tray, a correção provável é remover apenas o applet independente.
- Não corrigir por dedução. Corrigir apenas após confirmar no relatório.
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 1

Linhas aproximadas 115-143:

```text
app-blueman@autostart.service                                                                                           loaded active running   Blueman Applet
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
plasma-gmenudbusmenuproxy.service                                                                                       loaded active running   Proxies GTK DBus menus to a Plasma readable format
plasma-kaccess.service                                                                                                  loaded active running   KAccess
plasma-kactivitymanagerd.service                                                                                        loaded active running   KActivityManager Activity manager Service
plasma-kded6.service                                                                                                    loaded active running   KDE Daemon 6
plasma-ksmserver.service                                                                                                loaded active running   KDE Session Management Server
plasma-kwin_wayland.service                                                                                             loaded active running   KDE Wayland Compositor
plasma-plasmashell.service                                                                                              loaded active running   KDE Plasma Workspace
plasma-polkit-agent.service                                                                                             loaded active running   KDE PolicyKit Authentication Agent
plasma-powerdevil.service                                                                                               loaded active running   Powerdevil
plasma-xdg-desktop-portal-kde.service                                                                                   loaded active running   Xdg Desktop Portal For KDE
plasma-xembedsniproxy.service                                                                                           loaded active running   Handle legacy xembed system tray icons
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth
plasma-core.target                                                                                                      loaded active active    KDE Plasma Workspace Core
plasma-workspace-wayland.target                                                                                         loaded active active    plasma-workspace-wayland.target
plasma-workspace.target                                                                                                 loaded active active    KDE Plasma Workspace

### ÁUDIO
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
```

Linhas aproximadas 157-185:

```text
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

2	alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

PipeWire 'pipewire-0' [1.6.6, hal@Mocha, cookie:1187326163]
 └─ Clients:
        32. kwin_wayland                        [1.6.6, hal@Mocha, pid:956]
        33. WirePlumber                         [1.6.6, hal@Mocha, pid:1015]
        41. WirePlumber [export]                [1.6.6, hal@Mocha, pid:1015]
        42. plasmashell                         [1.6.6, hal@Mocha, pid:1114]
        43. xdg-desktop-portal                  [1.6.6, hal@Mocha, pid:964]
        47. wpctl                               [1.6.6, hal@Mocha, pid:8278]

Audio
 ├─ Devices:
 │  
 ├─ Sinks:
 │  
 ├─ Sources:
 │  
 ├─ Filters:
 │  
 └─ Streams:

Video
 ├─ Devices:
 │  
 ├─ Sinks:
```

### Energia, CPU/GPU e agressividade

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 5

Linhas aproximadas 170-210:

```text
/media/vmstore /dev/sdb1 xfs    rw,noatime,inode64,logbufs=8,logbsize=32k,noquota

--- /etc/fstab: entradas relevantes ---
17:UUID=88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast btrfs defaults,noatime,compress=zstd:3,ssd,discard=async,nofail,x-systemd.device-timeout=10s 0 0
18:UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore xfs defaults,noatime,nofail,x-systemd.device-timeout=10s 0 2
```

### Energia, CPU, GPU e agressividade

```text
--- powerprofilesctl ---
powerprofilesctl não encontrado.

--- tuned ---
Current active profile: latency-performance
enabled
active

--- governor CPU ---
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu3/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu4/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu5/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu8/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu9/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu10/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu11/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu12/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu13/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu14/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu15/cpufreq/scaling_governor:performance

--- NVIDIA power/persistence ---

==============NVSMI LOG==============

Timestamp                                              : Fri May 29 15:43:05 2026
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 1

Linhas aproximadas 33-61:

```text
e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
```

#### Fonte: `documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

### Steam, MangoHud e wrapper

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 3

Linhas aproximadas 46-114:

```text
|    0   N/A  N/A            1686      G   .../akonadi_maildispatcher_agent          2MiB |
|    0   N/A  N/A            1687      G   .../bin/akonadi_mailfilter_agent          2MiB |
|    0   N/A  N/A            1688      G   /usr/bin/akonadi_mailmerge_agent          2MiB |
|    0   N/A  N/A            1689      G   /usr/bin/akonadi_migration_agent          2MiB |
|    0   N/A  N/A            1690      G   ...akonadi_newmailnotifier_agent          2MiB |
|    0   N/A  N/A            1691      G   /usr/bin/akonadi_sendlater_agent          2MiB |
|    0   N/A  N/A            1692      G   .../akonadi_unifiedmailbox_agent          2MiB |
|    0   N/A  N/A            2033      G   /usr/lib/DiscoverNotifier                 2MiB |
|    0   N/A  N/A            2042      G   /usr/bin/kalendarac                       2MiB |
|    0   N/A  N/A            2093      G   /usr/lib/xdg-desktop-portal-kde           2MiB |
|    0   N/A  N/A            2469      G   ...share/Steam/ubuntu12_32/steam          4MiB |
|    0   N/A  N/A            2676      G   ./steamwebhelper                         23MiB |
|    0   N/A  N/A            2705    C+G   ...am/ubuntu12_64/steamwebhelper          5MiB |
|    0   N/A  N/A            3236      G   ...asma-browser-integration-host          2MiB |
|    0   N/A  N/A            4133      G   /usr/bin/kwalletd6                        2MiB |
|    0   N/A  N/A            8656      G   /usr/bin/konsole                          2MiB |
|    0   N/A  N/A            8813      G   /usr/bin/dolphin                          2MiB |
|    0   N/A  N/A            9032      G   /usr/bin/plasmashell                     71MiB |
+-----------------------------------------------------------------------------------------+
```

### Pacotes de kernel, NVIDIA, Vulkan e Steam relevantes

```text
egl-wayland2 1.0.1-1
egl-wayland 4:1.1.21-1
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
lib32-nvidia-utils 595.71.05-1
lib32-vulkan-icd-loader 1.4.350.0-1
linux-api-headers 6.19-1
linux-atm 2.5.2-9
linux-firmware 20260519-1
linux-firmware-amdgpu 20260519-1
linux-firmware-atheros 20260519-1
linux-firmware-broadcom 20260519-1
linux-firmware-cirrus 20260519-1
linux-firmware-intel 20260519-1
linux-firmware-mediatek 20260519-1
linux-firmware-nvidia 20260519-1
linux-firmware-other 20260519-1
linux-firmware-radeon 20260519-1
linux-firmware-realtek 20260519-1
linux-firmware-whence 20260519-1
linux-headers 7.0.10.arch1-1
mangohud 0.8.3-2
nvidia-open-dkms 595.71.05-2
nvidia-settings 595.71.05-1
nvidia-utils 595.71.05-2
opencl-nvidia 595.71.05-2
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
vulkan-icd-loader 1.4.350.0-1
vulkan-tools 1.4.350.0-1
```

### Login manager / display manager

```text
● plasmalogin.service - Plasma Login Manager
     Loaded: loaded (/usr/lib/systemd/system/plasmalogin.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 1h 13min ago
 Invocation: 7c16afbe746f47008acd42cd1d5dbc36
       Docs: man:plasmalogin(1)
             man:plasmalogin.conf(5)
   Main PID: 683 (plasmalogin)
      Tasks: 2 (limit: 18662)
     Memory: 16.8M (peak: 39.4M, swap: 560K, swap peak: 560K, zswap: 112.7K)
        CPU: 106ms
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 3

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 3

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 3

Linhas aproximadas 33-61:

```text
e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 3

Linhas aproximadas 3-31:

```text

### KERNEL
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

### PACOTES RELEVANTES
bluedevil 1:6.6.5-1
bluez 5.86-6
bluez-libs 5.86-6
bluez-qt 6.26.0-1
bluez-tools 0.2.0-6
gamemode 1.8.2-2
kdebugsettings 26.04.1-1
kdeclarative 6.26.0-1
kde-cli-tools 6.6.5-1
kdeconnect 26.04.1-1
kdecoration 6.6.5-1
kded 6.26.0-1
kde-dev-scripts 26.04.1-1
kde-dev-utils 26.04.1-1
kdeedu-data 26.04.1-1
kdegraphics-mobipocket 26.04.1-1
kdegraphics-thumbnailers 26.04.1-1
kde-gtk-config 6.6.5-1
kde-inotify-survey 26.04.1-2
kdenetwork-filesharing 26.04.1-1
kdenlive 26.04.1-1
kdepim-addons 26.04.1-1
kdepim-runtime 26.04.1-1
kdeplasma-addons 6.6.5-1
```

Linhas aproximadas 44-100:

```text
linux-firmware-broadcom 20260519-1
linux-firmware-cirrus 20260519-1
linux-firmware-intel 20260519-1
linux-firmware-mediatek 20260519-1
linux-firmware-nvidia 20260519-1
linux-firmware-other 20260519-1
linux-firmware-radeon 20260519-1
linux-firmware-realtek 20260519-1
linux-firmware-whence 20260519-1
linux-headers 7.0.10.arch1-1
mangohud 0.8.3-2
nvidia-open-dkms 595.71.05-2
nvidia-settings 595.71.05-1
nvidia-utils 595.71.05-2
pipewire 1:1.6.6-1
pipewire-session-manager 1:1.6.6-1
plasma5support 6.6.5-1
plasma-activities 6.6.5-1
plasma-activities-stats 6.6.5-1
plasma-browser-integration 6.6.5-1
plasma-camera 26.04.1-1
plasma-desktop 6.6.5-1
plasma-disks 6.6.5-1
plasma-firewall 6.6.5-1
plasma-integration 6.6.5-2
plasma-keyboard 6.6.5-1
plasma-login-manager 6.6.5-1
plasma-nm 6.6.5-1
plasma-pa 6.6.5-1
plasma-sdk 6.6.5-1
plasma-systemmonitor 6.6.5-1
plasma-thunderbolt 6.6.5-1
plasmatube 26.04.1-2
plasma-vault 6.6.5-1
plasma-welcome 6.6.5-1
plasma-workspace 6.6.5-2
plasma-workspace-wallpapers 6.6.5-1
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
wireplumber 0.5.14-1

### SERVIÇOS DO SISTEMA RELACIONADOS
● bluetooth.service - Bluetooth service
     Loaded: loaded (/usr/lib/systemd/system/bluetooth.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 54min ago
 Invocation: 040213ede68b4cc48886bc2a25c46bd6
       Docs: man:bluetoothd(8)
   Main PID: 617 (bluetoothd)
     Status: "Running"
      Tasks: 1 (limit: 18662)
     Memory: 2M (peak: 3.4M)
        CPU: 47ms
     CGroup: /system.slice/bluetooth.service
             └─617 /usr/lib/bluetooth/bluetoothd

mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/sbc_xq_453
```

#### Fonte: `kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh`

Pontuação de relevância: 1

Linhas aproximadas 1-24:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 8-37:

```text
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
```

#### Fonte: `scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

Pontuação de relevância: 1

Linhas aproximadas 1-26:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
```

#### Fonte: `documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md`

Pontuação de relevância: 1

Linhas aproximadas 1-30:

```text
# Mocha Arch/KDE — baseline superior ao Endeavour

Timestamp: 20260529-152416

## Resultado relatado pelo usuário

Este estado atual foi relatado como superior ao Endeavour em todos os aspectos principais:

- FPS alto usando a medição do overlay da Steam.
- Jogo fluido.
- Sistema em geral muito rápido.
- Sem problemas de conectividade Bluetooth.
- Desempenho geral superior ao Endeavour.

## Pendências observadas

- Há redundância relacionada ao Bluetooth.
- Há redundância no controle de volume.
- O controle de volume aparece duas vezes na barra de tarefas.

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
```

#### Fonte: `scripts/mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 1

Linhas aproximadas 1-25:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

```

#### Fonte: `scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 1

Linhas aproximadas 1-25:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

### Organização, limpeza e documentação

#### Fonte: `logs/20260529-154304-criar-manual-vivo-definitivo-mocha-arch-kde.log`

Pontuação de relevância: 3

Linhas aproximadas 1-12:

```text
== Preflight ==
FAST montado: OK
Pasta ativa: /media/mochafast/MochaArch/ativo

== Backup do manual anterior, se existir ==
Nenhum manual anterior com nome fixo.

== Gerando auditoria do estado atual ==
Auditoria salva:
  /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md

== Extraindo evidências e comandos salvos por tema ==
```

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 3

Linhas aproximadas 1-23:

```text
## Auditoria automática do estado atual

Gerada em: 20260529-154304

Esta auditoria registra o estado real no momento da criação do manual. Ela não altera o sistema.

### Kernel atual

```text
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux
```

### Driver NVIDIA

```text
Fri May 29 15:43:04 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 595.71.05              Driver Version: 595.71.05      CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
```

Linhas aproximadas 265-293:

```text
Name[hu]=Blueman kisalkalmazás
Name[is]=Blueman-smáforrit
Name[it]=Blueman Applet
Name[ja]=Bluetooth アプレット
Name[ko]=Blueman 애플릿
Name[mr]=ब्लूमॅन ॲपलेट
Name[ms]=Aplet Blueman
Name[nb]=Blueman-panelprogram
Name[nl]=Blueman-werkbalkhulpje
Name[pl]=Aplet Blueman
Name[pt_BR]=Miniaplicativo Blueman
Name[pt]=Applet Blueman
Name[ro]=Miniaplicație Blueman
Name[ru]=Апплет Blueman
Name[sk]=Aplet bluetooth
Name[sl]=Blueman Applet
Name[sv]=Blueman panelprogram
Name[ta]=ப்ளூமேன் ஆப்லெட்
Name[tr]=Blueman Uygulaması
Name[uk]=Аплет Blueman
Name[zh_CN]=Blueman 小程序
Name[zh_TW]=Blueman 小程式
Name[oc]=Applet Blueman
Name=Blueman Applet
Comment[ast]=Alministrador Bluetooth Blueman
Comment[be]=Blueman - кіраўнік Bluetooth
Comment[ca]=Gestor de Bluetooth Blueman
Comment[da]=Blueman Bluetooth-håndtering
Comment[de]=Blueman Bluetooth Manager
```

Linhas aproximadas 387-435:

```text
Comment=Mocha KDE: disabled because Plasma volume applet already provides volume control in the system tray
Exec=kmix --keepvisibility
OnlyShowIn=KDE;
Hidden=true

```

### Barra Win11/Mocha aprovada

```text
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:33  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

--- assinaturas do appletsrc aprovado ---
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true
```

### Scripts e documentos principais no ativo

```text
2026-05-28 22:56  1159 bytes  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:01  1754 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md
2026-05-29 15:01  2068 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:01  2068 bytes  /media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:24  10321 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt
2026-05-29 15:24  1070 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md
2026-05-29 15:24  4616 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/plasma-applets-volume-bluetooth-systemtray.txt
2026-05-29 15:24  624 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt
2026-05-29 15:25  3401 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152529-corrigir-blueman-auditar-volume/execucao.log
2026-05-29 15:27  1108 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh
2026-05-29 15:27  1389 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md
2026-05-29 15:27  7077 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log
2026-05-29 15:29  1624 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md
2026-05-29 15:29  1624 bytes  /media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md
2026-05-29 15:29  2541 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
2026-05-29 15:29  3810 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log
2026-05-29 15:30  3891 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
2026-05-29 15:32  824 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153249-aplicar-barra-win11-aprovada-pasta-certa.log
2026-05-29 15:33  2039 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log
2026-05-29 15:33  2985 bytes  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
```

#### Fonte: `logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log`

Pontuação de relevância: 3

Linhas aproximadas 1-57:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada: OK
Arquivo aprovado: OK
Config atual: OK

== Auditoria do arquivo aprovado ==
Arquivo:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617

Assinaturas esperadas:
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true

Assinatura da barra aprovada validada.

== Criando script reutilizável na pasta aprovada ==
Script reutilizável criado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

== Executando restauração da barra aprovada ==
== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11

== Finalizado ==
Log principal:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log
Script salvo para uso futuro:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
```

#### Fonte: `kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh`

Pontuação de relevância: 3

Linhas aproximadas 1-78:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
fi

if [ ! -f "$APPROVED" ]; then
  echo "ERRO: appletsrc aprovado não encontrado:"
  echo "  $APPROVED"
  exit 1
fi

if [ ! -f "$CFG" ]; then
  echo "ERRO: appletsrc atual não encontrado:"
  echo "  $CFG"
  exit 1
fi

if ! grep -q 'plugin=org.kde.plasma.panelspacer' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem panelspacer. Abortando."
  exit 1
fi

if ! grep -Eq 'plugin=org\.kde\.plasma\.(icontasks|taskmanager)' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem icontasks/taskmanager. Abortando."
  exit 1
fi

BACKUP="$BACKUP_DIR/${TS}-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11"
cp -a "$CFG" "$BACKUP"

find "$BACKUP_DIR" -maxdepth 1 -type f -name '*plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11*' \
  -printf '%T@ %p\n' 2>/dev/null \
  | sort -nr \
  | awk 'NR>2 {sub(/^[^ ]+ /,""); print}' \
  | while IFS= read -r old; do
      [ -n "$old" ] && rm -f -- "$old"
    done || true

echo "Backup salvo em:"
echo "  $BACKUP"

echo "Parando Plasma Shell..."
if command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 plasmashell >/dev/null 2>&1 || true
else
  pkill -x plasmashell >/dev/null 2>&1 || true
fi

sleep 2

echo "Aplicando appletsrc aprovado..."
cp -a "$APPROVED" "$CFG"

echo "Reiniciando Plasma Shell..."
if command -v kstart6 >/dev/null 2>&1; then
  nohup kstart6 plasmashell >/tmp/mocha-plasmashell-${TS}.log 2>&1 &
elif command -v kstart >/dev/null 2>&1; then
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 3

Linhas aproximadas 1-26:

```text
== Preflight ==
FAST montado: OK
Pasta de scripts: /media/mochafast/MochaArch/ativo/scripts
Config Plasma: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

== Procurando script aprovado da barra Mocha/KDE ==
Script escolhido:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
```

Linhas aproximadas 107-134:

```text
systemctl --user stop app-blueman@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix_autostart@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x blueman-applet 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "Mocha KDE: autostarts redundantes de Blueman e KMix desativados."
echo "Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume."
--- fim da auditoria curta ---

== Backup da configuração atual do Plasma ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
Mantendo no máximo 2 backups recentes desta configuração...

== Executando script documentado/aprovado da barra ==
Mocha KDE: autostarts redundantes de Blueman e KMix desativados.
Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume.

== Reiniciando Plasma Shell para refletir a barra, se necessário ==

== Finalizado ==
Barra Mocha aplicada usando:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
```

#### Fonte: `auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log`

Pontuação de relevância: 3

Linhas aproximadas 1-19:

```text
== 1/6 Confirmando applets nativos do KDE/Plasma ==
75:plugin=org.kde.plasma.systemtray
114:plugin=org.kde.plasma.volume
145:plugin=org.kde.plasma.bluetooth

== 2/6 Aplicando permanência no usuário atual ==
OK usuário: /home/hal/.config/autostart/blueman.desktop
38:Name=Blueman Applet
78:Exec=blueman-applet
83:Hidden=true

OK usuário: /home/hal/.config/autostart/kmix_autostart.desktop
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 3/6 Preparando /etc/skel para novos usuários do Mocha ==
OK /etc/skel: /etc/skel/.config/autostart/blueman.desktop
```

Linhas aproximadas 39-60:

```text
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

== 5/6 Criando script reutilizável ==
Script criado: /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== 6/6 Documentando como passo canônico de montagem ==
Documento criado:
/media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md

Passo canônico criado:
/media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md

Log salvo em:
/media/mochafast/MochaArch/ativo/auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log
```

#### Fonte: `auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log`

Pontuação de relevância: 3

Linhas aproximadas 14-42:

```text
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
2060 /usr/bin/kmix --keepvisibility
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

== 2/7 Confirmando que o volume do Plasma existe no system tray ==
OK: org.kde.plasma.volume existe no Plasma. Podemos remover apenas o KMix redundante da sessão/autostart.

== 3/7 Localizando arquivo original de autostart do KMix ==
Fonte encontrada: /etc/xdg/autostart/kmix_autostart.desktop

== 4/7 Criando override local com Hidden=true para KMix ==
Override final:
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 5/7 Parando KMix nesta sessão ==
KMix após stop:
OK: kmix não está mais rodando.

```

Linhas aproximadas 54-97:

```text
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes depois
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

### Áudio continua respondendo?
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
Índice do cliente: 44
Tamanho de fragmento: 65472
Nome do usuário: hal
Nome da máquina: Mocha
Nome do servidor: pulseaudio
Versão do servidor: 17.0-98-gb096
Especificação padrão de amostragem: s16le 2ch 44100Hz
Mapa de canais padrão: front-left,front-right
Destino padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink
Fonte padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor
Cookie: ed82:a34c

2	alsa_output.pci-0000_01_00.1.hdmi-stereo	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

### Bluetooth continua ativo?
active

== 7/7 Salvando documentação e script reutilizável ==
Documento criado:
/media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md

Script reutilizável criado:
/media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh

Log salvo em:
/media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 3

Linhas aproximadas 1-30:

```text
MOCHA ARCH / KDE — BARRA ESTILO WINDOWS 11 APROVADA
Timestamp: 20260528-225617

Status:
- Funcionou e foi aprovado pelo usuário nesta instalação EndeavourOS KDE.
- Deve ser preservado como solução de referência para MochaArch.

O que a solução faz:
- Audita o arquivo real:
  $HOME/.config/plasma-org.kde.plasma.desktop-appletsrc
- Cria backup com timestamp.
- Mantém no máximo 2 backups do arquivo da barra.
- Usa dois org.kde.plasma.panelspacer expansíveis.
- Centraliza Kickoff/Iniciar + icontasks/taskmanager.
- Preserva pager/outros applets à esquerda.
- Mantém systemtray/digitalclock/showdesktop à direita.
- Reinicia somente plasmashell.

Arquivos salvos:
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

#### Fonte: `logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log`

Pontuação de relevância: 2

Linhas aproximadas 1-22:

```text
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 2

Linhas aproximadas 8-36:

```text

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:
```

Linhas aproximadas 48-68:

```text
Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 2

Linhas aproximadas 8-36:

```text

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:
```

Linhas aproximadas 48-68:

```text
Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md`

Pontuação de relevância: 2

Linhas aproximadas 25-41:

```text
1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
```


---

## Índice de arquivos gerados nesta consolidação

Data: 20260529-154304



## 20260529-175841 — Esquema de cores KDE MochaSolidCanonico aplicado

- Origem: `/media/mochafast/MochaKDE-BaseAtiva-20260527-221154/kdedeutoflake/tema-kde-atual-salvo-20260524-212342/home-config/.local/share/color-schemes`
- Cópia ativa: `/media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados`
- Instalação do usuário: `/home/hal/.local/share/color-schemes`
- Esquema aplicado: `MochaSolidCanonico`
- Correção importante: arquivos `.colors` do KDE podem usar RGB em vez de HEX; scripts não devem abortar quando não houver códigos `#RRGGBB`.

## 20260529-180309 — Plasma Style local para barra Mocha

- Criado/aplicado tema Plasma local: `MochaPanelSolidCanonico`
- Motivo: `.colors` não controla sozinho o fundo da barra; o painel vem de `panel-background.svgz` do Plasma Style.
- Cor aplicada na barra: `#4f463e`
- Cópia ativa: `/media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico`
- Script reutilizável: `/media/mochafast/MochaArch/ativo/scripts/20260529-180309-reaplicar-plasma-style-barra-mocha.sh`


---

# Pendencias da auditoria pre-formatacao corrigidas — Mocha Arch KDE

Data: 20260529-200013

## Natureza deste estado

Este estado ainda nao e canonizacao definitiva. E uma base candidata/pre-canonica para tentar reproduzir o Mocha apos formatacao, evitando o drama das montagens anteriores.

## Correcoes aplicadas

1. Wrapper Steam limpo regravado em:
   - `/home/hal/.local/bin/mocha-steam-game-run`

   Regras preservadas:
   - sem `MANGOHUD_DLSYM`;
   - sem `vkbasalt`;
   - sem `gamescope`;
   - com `MANGOHUD=1`;
   - usa config de MangoHud do usuario se existir;
   - usa `gamemoderun` se existir.

2. Estado atual da barra salvo como snapshot aprovado de reproducao:
   - `/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual-20260529-200013`
   - `/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual`

3. Tabela de cores gerada:
   - `/media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/20260529-200013-TABELA-CORES-MOCHA-SOLID-CANONICO.md`
   - `/media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/TABELA-CORES-MOCHA-SOLID-CANONICO.md`

4. Scripts reutilizaveis adicionados:
   - Wrapper limpo: `/media/mochafast/MochaArch/ativo/scripts/20260529-200013-mocha-reaplicar-wrapper-steam-limpo.sh`
   - Verificacao NVIDIA/Wayland/Zen: `/media/mochafast/MochaArch/ativo/scripts/20260529-200013-mocha-verificar-nvidia-wayland-zen.sh`
   - Reaplicar agressividade/energia atual: `/media/mochafast/MochaArch/ativo/scripts/20260529-200013-mocha-reaplicar-agressividade-energia-atual.sh`
   - Reaplicar barra atual: `/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-200013-mocha-reaplicar-barra-aprovada-atual.sh`

## Estado tecnico que deve ser reproduzido

- Kernel alvo atual: Zen como primeira/default.
- Driver NVIDIA funcional observado: 595.71.05.
- Sessao obrigatoria: KDE Wayland.
- FAST obrigatorio: `/media/mochafast`.
- VMSTORE obrigatorio: `/media/vmstore`.
- CPU: governor `performance`.
- TuneD: `latency-performance`.
- Receita de agressividade atual:
  - `vm.swappiness = 80`
  - `vm.vfs_cache_pressure = 50`
  - `vm.page-cluster = 0`
  - `vm.dirty_background_bytes = 67108864`
  - `vm.dirty_bytes = 268435456`
  - `vm.max_map_count = 16777216`
  - `kernel.sched_autogroup_enabled = 0`
  - `kernel.nmi_watchdog = 0`
  - THP: `madvise`
  - zram: `zstd`, tamanho RAM, prioridade `32767`
- Cores KDE:
  - `MochaSolidCanonico`
- Plasma Style:
  - `MochaPanelSolidCanonico`
- Barra:
  - usar snapshot atual aprovado, nao deduzir geometria.
- Bluetooth/volume duplicados:
  - manter KDE/Bluedevil e Plasma PA;
  - ocultar autostart de `blueman` e `kmix`;
  - nao remover pacotes.
- Flatpak/Flathub:
  - manter.
- Chrome:
  - nao incluir por padrao.
- Bitwarden:
  - manter fora por enquanto.

## Observacao importante

A auditoria anterior gerou um falso problema parcial na leitura do ColorScheme e quebrou a checagem de cobertura dos manuais por erro de Bash. Esta rodada corrige esse ponto com uma auditoria revisada.

## 20260529-205629 - Base de jogos e correções leves pós-auditoria
Estado lido antes da alteração: NVIDIA 595.71.05 carregada no boot auditado, receita Mocha de agressividade ativa, mas Steam/MangoHud/wrapper ausentes e overrides de blueman/kmix ausentes.
Ação aplicada: sem mexer em boot, kernel ou driver; apenas instalou pacotes de jogos disponíveis, recriou overrides Hidden=true para blueman/kmix no usuário atual e em /etc/skel, criou MangoHud config local e wrapper limpo /home/hal/.local/bin/mocha-steam-game-run.
Regra preservada: nenhuma Launch Option da Steam foi alterada automaticamente. O baseline sem linha continua preservado; o wrapper fica disponível apenas para teste controlado.
Proibições preservadas no wrapper: sem MANGOHUD_DLSYM, sem gamescope, sem vkbasalt e sem variáveis PRIME de notebook.

## 20260529-211221 - Tema Mocha aprovado aplicado e validado

- ColorScheme antes: BreezeDark
- Plasma Style antes: default
- ColorScheme validado depois: MochaSolidCanonico
- Plasma Style validado depois: MochaPanelSolidCanonico
- Entrada errada antiga removida quando encontrada.
- Script reutilizável: /media/mochafast/MochaArch/ativo/scripts/20260529-211221-corrigir-manual-e-reaplicar-tema.sh
- Log: /media/mochafast/MochaArch/ativo/logs/20260529-211221-corrigir-manual-e-reaplicar-tema.log

## 20260529-211408 - Wallpaper e barra Mocha aplicados

- Wallpaper aplicado: /media/mochafast/MochaArch/ativo/assets/branding/wallpaper/05fdb8fa-73e8-4d9b-a75e-6e1686f8e3ed.png
- Barra aplicada a partir do appletsrc aprovado: /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- ColorScheme validado: MochaSolidCanonico
- Plasma Style validado: MochaPanelSolidCanonico
- Script reutilizável: /media/mochafast/MochaArch/ativo/scripts/20260529-211408-aplicar-wallpaper-e-barra-mocha.sh
- Log: /media/mochafast/MochaArch/ativo/logs/20260529-211408-aplicar-wallpaper-e-barra-mocha.log

## 20260529-211622 - Marco pós-formatação: estado Mocha reproduzido

- Usuário confirmou que aparentemente está tudo perfeito.
- Estado pré-formatação reproduzido com sucesso visual/funcional.
- Pendência: testar jogos antes de canonizar desempenho.
- Documento do marco: /media/mochafast/MochaArch/ativo/documentacao/20260529-211622-MARCO-ESTADO-REPRODUZIDO-POS-FORMATACAO.md
- Log: /media/mochafast/MochaArch/ativo/logs/20260529-211622-marco-estado-reproduzido-pos-formatacao.log
# MochaArch — montagem fase 01 corrigida — 20260602-075226

Procedimento desta fase:

1. Montar FAST em `/media/mochafast`, persistente via `/etc/fstab`, visível no Dolphin.
2. Montar VMSTORE em `/media/vmstore`, persistente via `/etc/fstab`, visível no Dolphin.
3. Detectar discos por `lsblk` e UUID real, não por `blkid -L`.
4. Atualizar o sistema inteiro antes de ativar qualquer repositório temporário.
5. Ativar repositório CachyOS somente de forma temporária para instalar kernel comum CachyOS e driver NVIDIA compatível.
6. Não instalar Bore, LTO, EEVDF ou variantes.
7. Restaurar `/etc/pacman.conf` original ao final.
8. Definir o kernel comum `linux-cachyos` como padrão no GRUB.
9. Preservar o kernel Arch como fallback.
10. Não remover programas nesta fase.

---

## Entrada aprovada — 20260602-102320 — Pacotes / visual / performance — Pacotes faltantes, wallpaper e CPU/GPU máximo

### Área

Pacotes / visual / performance

### Título

Pacotes faltantes, wallpaper e CPU/GPU máximo

### Registro

Correção aplicada para pacotes faltantes, wallpaper e estado máximo de CPU/GPU.

- Pacotes críticos foram validados contra os repositórios ativos com `pacman -Si` antes da instalação.
- `tuned` e `cpupower` foram instalados quando disponíveis e configurados para `latency-performance`/`performance`.
- Serviço persistente `mocha-max-performance.service` força governor/EPP da CPU em performance e aplica NVIDIA persistence mode, power limit máximo e lock de clocks quando suportado pelo driver/GPU.
- Wallpaper Mocha encontrado no ativo foi copiado para `~/.local/share/wallpapers/Mocha/` e aplicado no Plasma.
- Nenhum pacote foi removido; kernel, GRUB e entrada padrão de boot não foram alterados por esta correção.
- Relatório: /media/mochafast/MochaArch/ativo/relatorios/20260602-102241-pacotes-faltantes-wallpaper-cpu-gpu-max.log
- Script: /media/mochafast/MochaArch/ativo/scripts/20260602-102241-mocha-instalar-pacotes-faltantes-wallpaper-cpu-gpu-max.sh

### Modelo obrigatório para completar a entrada

```text
O que foi feito:
Por que foi feito:
Arquivo(s) alterado(s):
Comando/script aprovado:
Validação:
Resultado:
Regra de não regressão:
```

## Registro operacional 20260602-105738 — pendências pós-auditoria

- Ver documento: `/media/mochafast/MochaArch/ativo/documentacao/20260602-105738-correcao-pendencias-nvidia-zram-tema-wallpaper.md`
- Pontos tratados: NVIDIA/GRUB, zram, performance, tema KDE, barra aprovada e wallpaper.
- Não houve remoção de programas.
- Parâmetros de GRUB exigem reboot para validação no próximo boot.

---

## Entrada aprovada — SDDM funcional real e wrapper Steam canônico — 20260602-193706

### SDDM / login funcional aprovado

Estado real validado:

```text
sddm.service: enabled
sddm.service: active
display-manager: /usr/lib/systemd/system/sddm.service
config funcional: /etc/sddm.conf.d/00-mocha-resgate.conf
tema: breeze
display server: wayland
```

Conteúdo funcional aprovado:

```ini
[Theme]
Current=breeze

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1
```

Regra de não regressão:

- Manter SDDM em Wayland.
- Não usar X11 como fallback.
- Não trocar o tema Breeze funcional por tema customizado sem auditoria, backup e teste controlado.
- O estado funcional aprovado é Breeze + Wayland + fundo Mocha.
- Não desabilitar `sddm.service` se ele estiver `enabled` e `active`.

### Steam / Proton / wrapper canônico

Wrapper canônico validado:

```text
/home/hal/.local/bin/mocha-steam-game-run
```

Launch Option padrão aprovada para jogos testados:

```text
/home/hal/.local/bin/mocha-steam-game-run %command%
```

Regras do wrapper:

- Mantém o desktop em Wayland.
- Bloqueia Proton Wayland nativo para preservar compatibilidade de input.
- Usa `gamemoderun` quando disponível.
- Não usa `gamescope`.
- Não usa `vkbasalt`.
- Não usa `MANGOHUD_DLSYM`.
- Não força `SDL_VIDEODRIVER` globalmente.

Correção aprovada para perda de input após Alt+Tab nos prefixos Proton/Wine:

```text
HKCU\Software\Wine\X11 Driver\UseTakeFocus=N
HKCU\Software\Wine\DirectInput\MouseWarpOverride=force
```

Regra de não regressão:

- Não voltar para Launch Options antigas como `gamemoderun %command%` sem teste comparativo.
- Não reintroduzir gamescope/vkbasalt/MANGOHUD_DLSYM no wrapper canônico.
- Se um jogo específico falhar, auditar por jogo antes de mudar o padrão global.


<!-- MOCHA:INICIO:F2FS-PROXIMA-FORMATACAO -->

## F2FS na próxima formatação — auditoria obrigatória no primeiro boot

Esta seção é para a próxima instalação/formatação do MochaArch usando o Calam-Arch-Installer.

Estado atual conhecido: o sistema em uso agora não precisa estar em F2FS. A auditoria atual mostrou / em ext4, FAST em btrfs e VMSTORE em xfs. O uso de F2FS será decidido/aplicado na próxima formatação, preferencialmente apenas para a partição raiz em SSD/NVMe.

Regra de montagem: após o primeiro boot do sistema recém-instalado, montar FAST em /media/mochafast e VMSTORE em /media/vmstore. Logo depois, antes de seguir para kernel CachyOS, NVIDIA, SDDM/Wayland, tema e agressividade, rodar a auditoria abaixo.

Comando canônico:

    sudo bash /media/mochafast/MochaArch/ativo/scripts/mocha-auditoria-f2fs-primeiro-boot.sh

Critério de aprovação: se / estiver em F2FS, precisam estar corretos f2fs-tools, módulo f2fs, mkinitcpio, presets, /etc/fstab, EFI em vfat/FAT32 e bootloader apontando para o UUID correto. Se / não estiver em F2FS, registrar como diferença da receita pretendida antes de prosseguir.

Arquivo do script:

    /media/mochafast/MochaArch/ativo/scripts/mocha-auditoria-f2fs-primeiro-boot.sh

<!-- MOCHA:FIM:F2FS-PROXIMA-FORMATACAO -->

---

## Registro operacional automático — seguimento pós-ZRAM/pacotes/firewall/CPU — 20260602-212601

### Estado confirmado antes deste registro

- FAST montado em `/media/mochafast`.
- VMSTORE montado em `/media/vmstore`.
- SDDM preservado: não alterar SDDM, GRUB, kernel, driver NVIDIA ou entrada de boot nesta etapa.
- ZRAM preservada como swap prioritário:
  - algoritmo: `zstd`;
  - prioridade: `32767`;
  - swap físico fica como fallback de baixa prioridade.
- Agressividade de memória consolidada em `/etc/sysctl.d/99-mocha-zram-agressividade.conf`:
  - `vm.swappiness = 180`;
  - `vm.watermark_boost_factor = 0`;
  - `vm.watermark_scale_factor = 125`;
  - `vm.page-cluster = 0`.
- UFW ativo:
  - entrada negada;
  - saída liberada;
  - portas Steam não abertas por padrão.
- CPU configurada em `performance` via governor e EPP.
- `fstrim.timer` ativo.
- `7zip` não existe nos repositórios ativos usados nesta montagem; usar `7zip`.

### Steam/Mocha

Wrapper canônico preservado/criado em:

```
/home/hal/.local/bin/mocha-steam-game-run
```

Launch Option padrão:

```
/home/hal/.local/bin/mocha-steam-game-run %command%
```

O wrapper canônico:
- remove variáveis de IME que causam conflito;
- força Proton fora do Wayland interno do Wine;
- mantém `SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0`;
- usa `gamemoderun` se disponível;
- não usa `gamescope`;
- não usa `vkbasalt`;
- não usa `MANGOHUD_DLSYM`;
- não ativa MangoHud por padrão.

### MangoHud

Configuração preservada/criada, mas não ativada no wrapper:

```
/home/hal/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf
```

Para teste manual por jogo, usar:

```
MANGOHUD=1 MANGOHUD_CONFIGFILE=/home/hal/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf %command%
```

### Relatórios

- Relatório desta etapa:

```
/media/mochafast/MochaArch/auditorias/mocha-seguimento-pos-zram-wrapper-mangohud-manual-20260602-212601.md
```


---

## Registro operacional automático — montagem tema/Steam/SDDM/rede/firewall — 20260602-213110

### Alterações aplicadas

- Steam instalado/conferido pelo pacote `steam`.
- Multilib habilitado/conferido em `/etc/pacman.conf`.
- Wrapper Steam/Mocha preservado em:

```
/home/hal/.local/bin/mocha-steam-game-run
```

- Launch Option padrão por jogo:

```
/home/hal/.local/bin/mocha-steam-game-run %command%
```

- SDDM consolidado em Wayland pelo arquivo:

```
/etc/sddm.conf.d/00-mocha-resgate.conf
```

- SDDM mantido com tema `breeze`, fundo Mocha quando o wallpaper foi encontrado.
- KDE recebeu tentativa de aplicação do tema Breeze Dark, wallpaper Mocha e barra aprovada, sem alterar GRUB, kernel ou NVIDIA.
- DNS-over-TLS Cloudflare configurado em:

```
/etc/systemd/resolved.conf.d/10-mocha-cloudflare-dot.conf
```

- NetworkManager configurado para usar `systemd-resolved`.
- IPv4 fixo definido a partir do IP atual da conexão ativa quando a conexão foi detectada com segurança.
- UFW configurado:
  - entrada negada;
  - saída permitida;
  - roteamento negado;
  - portas Steam fechadas por padrão.
- Atalhos criados:
  - abrir portas Steam: `/usr/local/bin/mocha-steam-firewall-open`;
  - fechar portas Steam: `/usr/local/bin/mocha-steam-firewall-close`.

### Relatório

```
/media/mochafast/MochaArch/auditorias/mocha-montagem-tema-steam-login-rede-firewall-20260602-213110.md
```


<!-- MOCHA-DETECCAO-DISCOS-CANONICA:INICIO -->
## Detecção canônica de FAST e VMSTORE

Regra aprovada para instalação nova do MochaArch:

- Não detectar FAST/VMSTORE por /dev/sdX, /dev/nvmeX, ordem do kernel, tamanho, modelo ou ROTA.
- Detectar por LABEL exata e única.
- Conferir com findfs LABEL=...
- Validar TYPE depois da detecção.
- Extrair UUID.
- Gravar /etc/fstab por UUID.
- FAST esperado: LABEL=MOCHAFAST, TYPE=btrfs, montagem em /media/mochafast.
- VMSTORE esperado: LABEL=vmstore, TYPE=xfs, montagem em /media/vmstore.
- Não usar blkid com filtro composto LABEL mais TYPE como método de decisão.
- Não usar lsblk -r -P. Para pares chave/valor, usar lsblk -pPo.

Função base aprovada, sem cerca Markdown interna:

    resolve_label_unique() {
      local name="$1"
      local label="$2"
      local expected_type="$3"
      local findfs_dev real_findfs real type uuid
      local -a found

      mapfile -t found < <(blkid -o device -t "LABEL=${label}" 2>/dev/null | sort -u)

      [ "${#found[@]}" -eq 1 ] || return 1

      findfs_dev="$(findfs "LABEL=${label}" 2>/dev/null || true)"
      [ -n "$findfs_dev" ] || return 1

      real="$(readlink -f "${found[0]}")"
      real_findfs="$(readlink -f "$findfs_dev")"
      [ "$real" = "$real_findfs" ] || return 1

      type="$(blkid -s TYPE -o value "$real" 2>/dev/null || true)"
      uuid="$(blkid -s UUID -o value "$real" 2>/dev/null || true)"

      [ "$type" = "$expected_type" ] || return 1
      [ -n "$uuid" ] || return 1

      printf '%s\n' "$real"
    }

<!-- MOCHA-DETECCAO-DISCOS-CANONICA:FIM -->

<!-- MOCHA-ZRAM-SWAP-BAIXA-PRIORIDADE-INICIO -->

## Registro aprovado — zram + swap física de baixa prioridade

Data do registro: 20260604-094348

Configuração aprovada para agressividade de memória/swap:

- zram é a swap principal.
- zram deve usar zstd.
- zram deve ficar com prioridade máxima: 32767.
- swap física em disco é permitida.
- swap física em disco deve ficar sempre com prioridade baixa em relação à zram.
- Prioridade negativa/default baixa da swap física é aceita.
- Estado aprovado: zram em PRIO 32767 e swap física em PRIO -1.
- Não forçar pri=0 na swap física, pois 0 é maior que -1.
- A swap física é fallback para quando a zram estourar.
- Se /dev/zram0 já estiver ativa com zstd, [SWAP] e PRIO 32767, não escrever em comp_algorithm nem em disksize; preservar a zram em execução.
- FAST e VMSTORE devem permanecer persistentes, montados por UUID e visíveis no Dolphin.

Nota detalhada criada em:

/media/mochafast/MochaArch/ativo/docs/mocha-agressividade-zram-swap-baixa-prioridade-aprovada-20260604-094348.md

<!-- MOCHA-ZRAM-SWAP-BAIXA-PRIORIDADE-FIM -->

## Registro operacional automático — fechamento geral — 20260604-103622

- SDDM Wayland/Breeze canônico restaurado em `/etc/sddm.conf.d/00-mocha-resgate.conf`.
- Perfil TuneD `mocha-latency-performance` regravado como perfil autônomo, incluindo `kernel.sched_autogroup_enabled=0`.
- `tuned-adm verify` executado após reaplicação do perfil.
- Fallback initramfs do `linux-cachyos` conferido/gerado em `/boot/initramfs-linux-cachyos-fallback.img`.
- GRUB não foi alterado nesta etapa.
- Bitwarden foi tratado apenas via repositório oficial do pacman; AUR não foi usado automaticamente.

Relatório da execução: `/media/mochafast/MochaArch/auditorias/mocha-corrige-fechamento-final-20260604-103622.log`

## Registro operacional automático — fechamento visual KDE — 20260604-103944

- Barra KDE estilo Windows 11 reaplicada a partir do arquivo aprovado, quando disponível.
- Cores Mocha aplicadas via plasma-apply-colorscheme quando arquivo .colors foi localizado.
- Wallpaper Mocha aplicado preferencialmente pelo comando mocha-aplica-somente-wallpaper; fallback restrito ao Plasma foi usado somente se necessário.
- SDDM foi apenas auditado e preservado como Breeze + Wayland; o serviço não foi reiniciado.
- GRUB, kernel, firewall, TuneD e swap não foram alterados nesta etapa.

Relatório da execução: /media/mochafast/MochaArch/auditorias/mocha-fechamento-visual-kde-20260604-103944.log

<!-- MOCHA-SOFTWARES-GAMER-CRIACAO-INICIO -->

## Softwares default Mocha — gamer e criação

Validação atualizada em 20260604-124652.

Regra operacional:
- Esta lista só pode ser atualizada depois de instalação concluída sem erro e auditoria pós-instalação aprovada.
- Não instalar GNOME Shell, GDM, gnome-session, gnome-control-center, Mutter ou metapacotes GNOME no Mocha KDE.
- Bibliotecas GTK/GNOME isoladas podem existir como dependências de aplicativos, desde que não adicionem sessão GNOME, display manager GNOME ou concorrência com Plasma/SDDM.
- vkBasalt e Gamescope são ferramentas opcionais permitidas no sistema, mas não entram no wrapper canônico Steam/Mocha nem nas Launch Options padrão salvo ordem explícita de teste.
- AUR e Flatpak devem ser tratados em etapa separada, pacote a pacote, com auditoria.

Pacotes oficiais instalados e confirmados nesta validação:
- ardour 9.5-1
- audacity 1:3.7.7-2
- blender 17:5.1.2-1
- darktable 2:5.4.1-3
- digikam 9.0.0-1
- ffmpeg 2:8.1.1-2
- frei0r-plugins 3.1.3-1
- gamescope 3.16.24-1
- gimp 3.2.4-1
- gpu-screen-recorder 5.13.9-2
- graphicsmagick 1.3.47-1
- handbrake 1.11.1-1
- imagemagick 7.1.2.24-1
- inkscape 1.4.4-2
- kcolorchooser 26.04.2-1
- kdegraphics-thumbnailers 26.04.2-1
- kdenlive 26.04.2-1
- krita 6.0.2.1-1
- lmms 1.2.2-28
- mediainfo-gui 26.05-1
- mkvtoolnix-gui 99.0-1
- obs-studio 32.1.2-5
- rawtherapee 1:5.12-1
- sc-controller 0.5.5-3
- scribus 1.6.6-4
- shotcut 26.4.30-1
- sox 14.8.0.1-1
- umu-launcher 1.4.0-1

Candidatos não confirmados nesta validação e portanto não canonizados como instalados:
- bottles
- dosbox-staging
- duckstation
- game-devices-udev
- gpu-screen-recorder-gtk
- input-remapper
- jstest-gtk
- lib32-vkbasalt
- libretro-meta
- minigalaxy
- obs-vkcapture
- oversteer
- pcsx2
- protonup-qt
- rpcs3
- vkbasalt

<!-- MOCHA-SOFTWARES-GAMER-CRIACAO-FIM -->

---

## Adendo aprovado — Perfis de software e perfil Mocha Gamer padrão — 20260604-130440

Documento aprovado:
- docs/mocha-perfis-software-gamer-calamares-20260604-130440.md

Resumo:
A instalação atual foi reduzida ao perfil Mocha Gamer. Foram separados perfis para Calamares: Gamer, Criador, Escritório e Escola. O perfil Gamer mantém somente kmahjongg, kpat e kigo entre os jogos casuais e remove KDE Games/Education/PIM completos, suítes redundantes e aplicativos fora do perfil gamer. Órfãos devem ser apenas auditados, não removidos automaticamente.

Regra:
Mocha Gamer é o perfil padrão da ISO gamer. Perfis de escritório, escola e criação devem ser opcionais no instalador.

---

## Adendo aprovado — OnlyOffice canônico no perfil Escritório — 20260604-130843

Documento aprovado:
- docs/mocha-onlyoffice-canonico-escritorio-20260604-130843.md

Regra:
OnlyOffice é a suíte de escritório canônica do Mocha. O pacote onlyoffice-desktopeditors deve constar no perfil Mocha Gamer e também no perfil Mocha Escritório. LibreOffice, Calligra e outras suítes são alternativas opcionais, não substitutas do OnlyOffice.

---

## Adendo aprovado — OnlyOffice canônico via Flatpak — 20260604-134231

Documento aprovado:
- docs/mocha-onlyoffice-flatpak-canonico-20260604-134231.md

Regra:
OnlyOffice Desktop Editors é canônico no Mocha via Flatpak, usando o App ID org.onlyoffice.desktopeditors. O app deve constar nas listas Flatpak dos perfis Mocha Gamer e Mocha Escritório. As listas pacman não devem depender de onlyoffice-desktopeditors enquanto o pacote não estiver disponível nos repositórios Arch ativos da instalação.

<!-- MOCHA-CANON-WRAPPER-PROTON-INPUT-START -->
## ADENDO CANÔNICO — Wrapper Steam/Proton e input após Alt+Tab — 20260604-140526

Regra canônica do Mocha Gamer:

- O wrapper padrão é /home/hal/.local/bin/mocha-steam-game-run.
- A Launch Option padrão dos jogos Steam que usam o wrapper é /home/hal/.local/bin/mocha-steam-game-run %command%.
- O usuário final não deve precisar corrigir prefixo Proton manualmente.
- O wrapper deve corrigir automaticamente o prefixo Proton do jogo em cada execução.
- A correção automática obrigatória no registro Wine/Proton é:
  - HKCU\Software\Wine\X11 Driver\UseTakeFocus=N
  - HKCU\Software\Wine\DirectInput\MouseWarpOverride=force
- A correção deve funcionar para prefixos existentes, prefixos novos e prefixos recriados.
- O wrapper deve manter PROTON_ENABLE_WAYLAND=0 e PROTON_USE_WAYLAND=0 enquanto esta correção depender do caminho XWayland/X11 do Wine/Proton.
- O wrapper deve manter SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0.
- O wrapper deve preservar GameMode usando gamemoderun quando disponível.
- O wrapper canônico não deve chamar gamescope, vkBasalt nem MANGOHUD_DLSYM por padrão.
- gamescope e vkBasalt podem existir no sistema como ferramentas opcionais, mas não entram no wrapper canônico nem na Launch Option padrão salvo teste explícito.
- Esta regra existe porque perda de input após Alt+Tab é falha crítica de experiência do usuário final e não pode depender de instrução pós-instalação.

<!-- MOCHA-CANON-WRAPPER-PROTON-INPUT-END -->


---

## Registro operacional — Pamac controlado e limpeza do perfil Mocha Gamer (2026-06-04 15:01:17 -0300)

### Decisão canônica: gerenciador gráfico de pacotes

O Mocha Gamer pode manter uma interface gráfica de gerenciamento de pacotes para usuários comuns, desde que ela não assuma o controle operacional do sistema. A interface gráfica é aceitável para instalação manual de aplicativos comuns, Flatpaks, utilitários e pacotes AUR de baixo risco quando o usuário pedir explicitamente.

Estado auditado nesta máquina:

- pamac-aur: instalado
- libpamac-aur: instalado
- Discover: instalado
- flatpak-kcm: instalado
- packagekit: ausente
- Flathub: habilitado
- Repositório CachyOS no pacman.conf: OK: nenhum repositório CachyOS ativo detectado no pacman.conf

Política obrigatória:

- Pamac e Discover podem permanecer instalados no Mocha Gamer.
- Pamac não deve atualizar o sistema automaticamente.
- Pamac não deve baixar atualizações automaticamente.
- Pamac não deve procurar ou aplicar atualizações do AUR automaticamente.
- AUR pode ficar disponível, mas apenas por ação explícita do usuário.
- Nenhum pacote AUR deve substituir pacote oficial sem ordem explícita.
- Kernel, headers, driver NVIDIA, GRUB, SDDM, pacman.conf, repositórios e componentes de boot nunca devem ser geridos pelo Pamac/Discover.
- Atualizações críticas do Mocha devem continuar sendo feitas por terminal auditado, com comando completo, log, pré-checagem e validação final.

Estado auditado do Pamac nesta data:

- EnableAUR: habilitado
- RefreshPeriod: desativado, RefreshPeriod = 0
- DownloadUpdates: desabilitado ou ausente
- CheckAURUpdates: desabilitado ou ausente
- CheckAURVCSUpdates: desabilitado ou ausente
- CheckFlatpakUpdates: desabilitado ou ausente

### Decisão canônica: limpeza do perfil Mocha Gamer

A imagem Mocha Gamer não deve vir carregada com suíte KDE completa de PIM, aplicativos mobile/sociais, educacionais, exemplos de desenvolvimento KDE, players duplicados ou utilitários que não agregam ao perfil gamer/laboratório. Ferramentas de sistema, monitoramento, diagnóstico, benchmark, logs, rede, disco, GPU, energia, criação de conteúdo e manutenção continuam essenciais e não entram na limpeza.

Devem ser preservados no perfil Gamer + Laboratório:

- KDE Plasma, Wayland, SDDM, Dolphin, Konsole, Kate, Ark, Okular, Gwenview e Spectacle.
- PipeWire, WirePlumber, NetworkManager, Bluetooth, firewall e integração KDE.
- Steam, Lutris, Wine, Winetricks, Protontricks, MangoHud, GOverlay, GameMode, Gamescope e vkBasalt, com a ressalva de que Gamescope/vkBasalt não entram no wrapper canônico Steam/Mocha salvo ordem explícita de teste.
- OBS Studio, Kdenlive, GIMP, Krita, Blender, HandBrake, Audacity, Inkscape e ferramentas úteis de criação.
- Ferramentas de sistema e laboratório como htop, glances, hardinfo2, kinfocenter, ksystemlog, kjournald, filelight, gparted, partitionmanager, smartmontools, hwinfo, usbutils, ethtool, evtest, nvidia-utils, nvidia-settings, OpenRGB, Piper, Solaar, archiso, arch-install-scripts, base-devel, git, rsync, pv, wget, 7zip, zip, unzip e unrar.

Pacotes tratados como candidatos de limpeza ou migração para perfil escritório/escola/mobile/dev KDE:

- alligator
- angelfish
- arianna
- artikulate
- audiotube
- blinken
- cantor
- francis
- itinerary
- kalm
- kasts
- kig
- kiten
- koko
- kongress
- ktrip
- kweather
- minuet
- neochat
- plasmatube
- qrca
- telly-skout
- tokodon
- umbrello
- zanshin
- akonadi-calendar-tools
- akonadiconsole
- akonadi-import-wizard
- grantlee-editor
- kdepim-addons
- kmail-account-wizard
- mbox-importer
- pim-data-exporter
- pim-sieve-editor
- dragon
- elisa
- falkon
- juk
- konqueror
- krecorder
- kteatime
- ktimer
- kgraphviewer
- kimagemapeditor
- kirigami-gallery
- khelpcenter
- kruler
- plasma-camera
- plasma-keyboard
- plasma-welcome
- kapptemplate
- kde-dev-scripts
- kde-dev-utils
- kdesdk-kio
- kdesdk-thumbnailers
- kdevelop
- kdevelop-php
- kdevelop-python
- lokalize
- massif-visualizer
- poxml
- plasma-sdk

Estado auditado da limpeza nesta data:

- Total de pacotes da lista já ausentes/removidos: 62
- Total de pacotes da lista ainda instalados: 0

Pacotes da lista de limpeza ausentes/removidos no momento da auditoria:

- alligator
- angelfish
- arianna
- artikulate
- audiotube
- blinken
- cantor
- francis
- itinerary
- kalm
- kasts
- kig
- kiten
- koko
- kongress
- ktrip
- kweather
- minuet
- neochat
- plasmatube
- qrca
- telly-skout
- tokodon
- umbrello
- zanshin
- akonadi-calendar-tools
- akonadiconsole
- akonadi-import-wizard
- grantlee-editor
- kdepim-addons
- kmail-account-wizard
- mbox-importer
- pim-data-exporter
- pim-sieve-editor
- dragon
- elisa
- falkon
- juk
- konqueror
- krecorder
- kteatime
- ktimer
- kgraphviewer
- kimagemapeditor
- kirigami-gallery
- khelpcenter
- kruler
- plasma-camera
- plasma-keyboard
- plasma-welcome
- kapptemplate
- kde-dev-scripts
- kde-dev-utils
- kdesdk-kio
- kdesdk-thumbnailers
- kdevelop
- kdevelop-php
- kdevelop-python
- lokalize
- massif-visualizer
- poxml
- plasma-sdk

Pacotes da lista de limpeza ainda instalados no momento da auditoria:

- Nenhum pacote da lista permaneceu instalado nesta auditoria.

Regra para próximas montagens:

- O perfil Mocha Gamer deve instalar somente a base gamer/laboratório e ferramentas de criação úteis.
- Aplicativos educacionais, PIM/e-mail KDE, mobile/social KDE, jogos casuais excedentes, desenvolvimento KDE e players duplicados devem ficar fora do perfil Gamer por padrão.
- Esses grupos podem existir em perfis opcionais do instalador, como escritório, escola, criação expandida ou desenvolvimento.
- Remoções grandes devem sempre usar auditoria, prévia de transação, lista de protegidos, confirmação manual e validação final de pacotes críticos.


---

## REGRA CANÔNICA — MONTA O MOCHA = MOCHA GAMER (2026-06-04 15:05:19 -0300)

Quando o usuário disser apenas “monta o Mocha”, sem especificar outro perfil, a interpretação operacional obrigatória é: montar o perfil Mocha Gamer.

Perfis diferentes só devem ser assumidos quando forem citados explicitamente, por exemplo: Mocha escritório, Mocha escola, Mocha desenvolvimento, Mocha completo, Mocha criação expandida ou outro perfil nomeado.

### Consequência operacional

Montar o Mocha Gamer não significa apenas instalar Steam e ferramentas gamer. A montagem do perfil Gamer inclui duas metades obrigatórias:

1. Instalar ou preservar a camada gamer/laboratório.
2. Remover ou impedir a instalação da camada não gamer.

A limpeza do perfil Gamer é parte canônica da montagem, no mesmo nível de importância da instalação de Steam, Lutris, Wine/Proton, MangoHud, GameMode, GOverlay, OBS/Kdenlive e ferramentas de monitoramento.

### Instalar ou preservar no Mocha Gamer

- Steam, Lutris, Wine/Wine-Staging, Winetricks, Protontricks, MangoHud, GOverlay, GameMode, Gamescope e vkBasalt.
- Gamescope e vkBasalt podem existir no sistema como ferramentas gamer, mas não entram no wrapper canônico Steam/Mocha nem nas Launch Options padrão salvo ordem explícita de teste.
- OBS Studio, Kdenlive, GIMP, Krita, Blender, HandBrake, Audacity, Inkscape e ferramentas úteis de criação.
- Ferramentas de sistema, diagnóstico, benchmark, monitoramento, logs, rede, disco, GPU, energia, sensores e manutenção.
- KDE Plasma, Wayland, SDDM, Dolphin, Konsole, Kate, Ark, Okular, Gwenview, Spectacle, PipeWire, NetworkManager, Bluetooth e firewall.
- Pamac e Discover podem permanecer para usuário comum, mas sem atualizações automáticas, sem substituição silenciosa por AUR e sem uso para kernel, NVIDIA, GRUB, SDDM, pacman.conf, repositórios ou boot.

### Remover ou deixar fora do Mocha Gamer por padrão

- PIM/e-mail KDE e componentes Akonadi explícitos que não sejam dependência necessária.
- Aplicativos mobile/social KDE sem função direta no perfil gamer.
- Aplicativos educacionais KDE, salvo perfil escola.
- Ferramentas de desenvolvimento KDE, salvo perfil desenvolvimento.
- Players duplicados, utilitários redundantes e jogos casuais excedentes.
- Aplicativos de escritório duplicados quando OnlyOffice for o padrão do perfil.

### Fluxo obrigatório da limpeza

Toda limpeza grande do perfil Gamer deve seguir este fluxo:

1. Auditar pacotes explícitos instalados.
2. Separar protegidos, gamer/laboratório, criação, sistema/monitoramento e candidatos de remoção.
3. Fazer prévia da transação antes de remover.
4. Bloquear a operação se a transação puxar kernel, NVIDIA, SDDM, Plasma, PipeWire, NetworkManager, firewall, boot, ferramentas de sistema/monitoramento ou camada gamer.
5. Exigir confirmação manual antes da remoção.
6. Validar pacotes críticos ao final.
7. Registrar no manual somente o que foi realmente aplicado ou auditado.

### Regra curta

Montar o Mocha, salvo orientação contrária, significa montar o Mocha Gamer: instalar a camada gamer/laboratório e remover a camada não gamer.

<!-- MOCHA-RCLONE-NUVENS-PESSOAL-INICIO -->

## Adendo pessoal — Google Drive e OneDrive via rclone mount

Registro: 20260604-213440

Esta etapa é parte da montagem pessoal/laboratório do MochaArch usado pelo mantenedor. Não é etapa da ISO pública e não deve ser copiada para imagem distribuível.

Estado aprovado para uso pessoal:

- Cliente usado: rclone mount com FUSE3.
- Google Drive: remote mocha-gdrive, montado em /home/hal/Nuvens/GoogleDrive.
- OneDrive: remote mocha-onedrive, montado em /home/hal/Nuvens/OneDrive.
- Cache VFS preferencial: /media/mochafast/MochaArch/cache/rclone.
- Serviços systemd --user:
  - mocha-rclone-gdrive.service
  - mocha-rclone-onedrive.service
- Atalhos operacionais:
  - mocha-nuvens-status
  - mocha-nuvens-monta
  - mocha-nuvens-desmonta

Configuração de desempenho atualmente usada nos serviços:

- --vfs-cache-mode full
- --vfs-cache-max-size 80G
- --vfs-cache-max-age 168h
- --vfs-cache-poll-interval 30s
- --vfs-write-back 1s
- --dir-cache-time 168h
- --poll-interval 1m
- --buffer-size 32M
- --vfs-read-ahead 128M
- --transfers 8
- --attr-timeout 10s
- --log-level NOTICE

Resultado dos testes:

- Google Drive funciona, mas a experiência no Dolphin pode ficar lenta, especialmente na raiz da nuvem ou em pastas grandes.
- OneDrive funciona e ficou razoável para o uso pessoal atual, embora não tão rápido quanto cliente nativo/local.
- O teste de escrita via pasta montada funcionou nos dois provedores.
- Listagem após otimização: GoogleDrive em cerca de 1s e OneDrive em cerca de 0s no teste local executado.

Regras de segurança:

- Não copiar /home/hal/.config/rclone/rclone.conf para ISO, repositório, documentação pública, backup compartilhado ou relatório enviado a terceiros.
- Não registrar tokens OAuth no manual.
- Não canonizar logs contendo access_token ou refresh_token.
- Antes de compartilhar qualquer log de rclone, procurar e remover access_token e refresh_token.
- Cache em /media/mochafast/MochaArch/cache/rclone é dado local de uso pessoal e não entra em ISO.

Comandos de controle:

- Ver estado: mocha-nuvens-status
- Montar ambos: mocha-nuvens-monta
- Desmontar ambos: mocha-nuvens-desmonta
- Ativar no login do usuário: systemctl --user enable --now mocha-rclone-gdrive.service mocha-rclone-onedrive.service
- Parar temporariamente Google Drive: systemctl --user stop mocha-rclone-gdrive.service
- Parar temporariamente OneDrive: systemctl --user stop mocha-rclone-onedrive.service

Decisão canônica pessoal:

- Manter Google Drive e OneDrive disponíveis no Dolphin para uso pessoal.
- Não transformar esta etapa em padrão de ISO.
- Para ISO pública, tratar integração de nuvens como opcional, pós-instalação e dependente de autenticação do usuário.

<!-- MOCHA-RCLONE-NUVENS-PESSOAL-FIM -->

<!-- MOCHA-RCLONE-AUTO-OTIMIZA-PESSOAL-INICIO -->

## Adendo pessoal — otimização automática das nuvens rclone

Registro: 20260604-214015

Esta configuração é apenas para uso pessoal/laboratório do mantenedor. Não entra na ISO pública do MochaArch.

Objetivo:

- manter Google Drive e OneDrive disponíveis no Dolphin sem exigir comandos de terminal antes do uso;
- iniciar ambos via systemd --user no login;
- usar cache VFS no FAST;
- pré-aquecer cache de diretórios em segundo plano por timer systemd --user;
- manter rclone.conf, tokens OAuth, logs sensíveis e cache fora da ISO e fora de documentação pública.

Serviços ativos:

- mocha-rclone-gdrive.service
- mocha-rclone-onedrive.service
- mocha-rclone-preaquece.timer
- mocha-rclone-preaquece.service

Pastas:

- /home/hal/Nuvens/GoogleDrive
- /home/hal/Nuvens/OneDrive

Cache:

- /media/mochafast/MochaArch/cache/rclone

Portas RC locais:

- Google Drive: 127.0.0.1:5573
- OneDrive: 127.0.0.1:5574

Decisão:

- Google Drive permanece disponível, embora seja mais lento.
- OneDrive permanece disponível e é a nuvem pessoal principal.
- O usuário final não deve precisar rodar comandos antes de usar as pastas no Dolphin.
- Para ISO pública, nuvens devem ser tratadas como integração opcional pós-instalação.

<!-- MOCHA-RCLONE-AUTO-OTIMIZA-PESSOAL-FIM -->

## CALAMARES — INSTALADOR MOCHA

Registro inicial: 20260605-104632

O Calamares passa a ser tratado como instalador gráfico do MochaArch.

Regras:
- A máquina atual é ambiente de desenvolvimento, não molde cego da ISO.
- As configs do Calamares devem ficar versionadas em:
  /media/mochafast/MochaArch/calamares/mocha-calamares
- Não copiar configs para /etc/calamares da máquina atual sem teste controlado.
- Não mexer em SDDM, GRUB, boot, kernel ou tema da instalação atual por dedução.
- O perfil padrão de instalação é Mocha Gamer, salvo ordem explícita em contrário.
- Itens pessoais/laboratório, como rclone Google Drive e OneDrive, não entram na ISO pública.
- O SDDM aprovado continua sendo Breeze + Wayland + fundo Mocha, salvo nova validação real.
- Primeiro alvo: esqueleto de settings.conf, branding Mocha, módulos base e roteiro de pós-instalação.
- Validação obrigatória em VM antes de teste em máquina real.


### Auditoria AUR Calamares 20260605-104803

Resultado:
- O pacote calamares não apareceu nos repositórios pacman ativos.
- O AUR foi auditado localmente por clone direto dos PKGBUILDs.
- Diretório de auditoria:
  /media/mochafast/MochaArch/calamares/aur
- Nenhum pacote Calamares foi instalado nesta etapa.
- Próxima decisão: compilar calamares-git em ambiente atual de desenvolvimento ou empacotar primeiro mocha-calamares-config.


### Auditoria AUR Calamares 20260605-110129

Resultado:
- O pacote calamares não apareceu nos repositórios pacman ativos.
- O AUR foi auditado por clone direto dos PKGBUILDs.
- Diretório de auditoria:
  /media/mochafast/MochaArch/calamares/aur
- Nenhum pacote Calamares foi instalado nesta etapa.
- Próxima decisão técnica: compilar calamares-git, compilar calamares estável ou criar primeiro o pacote mocha-calamares-config.


---

## Calamares — branding provisório pendente

Data de registro: 20260605-121142

A árvore ativa do Calamares Mocha pode usar, temporariamente, arquivos de branding funcionais já validados. Esses arquivos não são a identidade visual final do projeto.

Antes da ISO pública, substituir o branding do Calamares por arquivos próprios do Mocha baseados no logo oficial do projeto, no papel de parede Mocha aprovado e na paleta visual KDE/Mocha canonizada.

Arquivos provisórios a revisar/substituir:

- usr/share/calamares/branding/mocha/logo.png
- usr/share/calamares/branding/mocha/splash.png
- usr/share/calamares/branding/mocha/welcome.png
- usr/share/calamares/branding/mocha/slide1.png até slide9.png
- usr/share/calamares/branding/mocha/show.qml, se necessário
- usr/share/calamares/branding/mocha/branding.desc, se necessário

Regras:

- não herdar identidade visual da Calam-Arch na versão final;
- inglês é a base e fallback dos textos;
- traduções devem acompanhar o idioma escolhido no instalador quando disponíveis;
- não alterar SDDM, boot, kernel, Steam wrapper, firewall, DNS ou perfil gamer durante essa etapa visual;
- auditar dimensões, referências e carregamento do slideshow antes de promover qualquer substituição.

## Registro Calamares - correção YAML do netinstall - 20260605-122108

- Corrigidos os campos textuais do netinstall/packagechooser para escalares YAML entre aspas.
- A causa era uma descrição com dois-pontos em texto livre: YAML interpretava o texto como mapeamento inválido.
- netinstall.yaml, netinstall.conf, packagechooser.conf e packages.conf foram validados com PyYAML.
- A instalação inicial continua limitada a KDE Plasma + SDDM.
- XWayland permanece apenas como camada de compatibilidade, não como fallback de sessão X11.
- Relatório: /media/mochafast/MochaArch/auditorias/mocha-corrige-yaml-netinstall-descricoes-20260605-122108.log
- Documento: /media/mochafast/MochaArch/calamares/mocha-calamares/reports/mocha-calamares-yaml-netinstall-descricoes-20260605-122108.md


<!-- MOCHA_CALAMARES_PAYLOAD_LOCAL_INICIO -->
## Calamares — payload clean local ignorado

Estado canonizado em: 20260605-151439

O diretório `calamares/payloads/` é artefato local gerado e deve permanecer ignorado pelo Git.
Ele guarda payloads prontos para aplicação em uma raiz de ISO/airootfs, mas não deve ser versionado.

Payload clean atual validado:

- Diretório: `/media/mochafast/MochaArch/calamares/payloads/payload-calamares-mocha-20260605-151012`
- Tarball: `/media/mochafast/MochaArch/calamares/payloads/payload-calamares-mocha-20260605-151012.tar.zst`
- SHA256 externo: `d00ced7019a43568df8c88f218b61affdec7d263e6211d7e9d56cb29ae4cd269`
- SHA256 file: `/media/mochafast/MochaArch/calamares/payloads/payload-calamares-mocha-20260605-151012.tar.zst.sha256`
- Manifesto externo: `/media/mochafast/MochaArch/calamares/payloads/payload-calamares-mocha-20260605-151012.tar.zst.manifest.txt`
- Instrução local de aplicação: `/media/mochafast/MochaArch/calamares/payloads/payload-calamares-mocha-20260605-151012.COMO-APLICAR.txt`
- Log de geração do payload: `/media/mochafast/MochaArch/auditorias/mocha-gera-payload-clean-calamares-20260605-151012.log`

Validação já confirmada:

- `sha256sum -c` passou para os arquivos internos do payload.
- `sha256sum -c` passou para o tarball externo.
- O payload não contém `propostas/`, `staging/`, `reports/` nem `.git`.
- `.gitignore` contém `calamares/payloads/`.

Regra operacional:

1. Não commitar `calamares/payloads/`.
2. Não aplicar payload sem validar SHA256.
3. Não substituir branding provisório por definitivo sem antes usar logo oficial e wallpaper Mocha aprovado.
4. O Mocha inicial deve continuar KDE Plasma + SDDM; não oferecer outros desktops no Calamares inicial.
5. Textos do instalador devem ter inglês como base/fallback e traduções conforme idioma escolhido.

Fluxo de aplicação futura:

1. Validar o tarball com o arquivo `.sha256`.
2. Extrair em diretório temporário.
3. Aplicar com `rsync -aHAX --info=progress2` sobre a raiz de trabalho da ISO/airootfs.
4. Validar `settings.conf`, `settings-online.conf`, módulos em `etc/calamares/modules/` e branding em `usr/share/calamares/branding/mocha/`.
<!-- MOCHA_CALAMARES_PAYLOAD_LOCAL_FIM -->

<!-- MOCHA-REPO-CONTROLADO-INICIO -->

## Repositório controlado MochaArch: kernel, NVIDIA e pacotes críticos

Atualizado em: 20260605-211728

### Decisão canônica

O usuário final do MochaArch não deve ter repositórios CachyOS habilitados no sistema.

O CachyOS pode ser usado pelo projeto MochaArch apenas como fonte upstream de coleta, comparação, teste ou inspiração técnica.

O usuário final deve consumir somente repositórios Mocha curados:

- mocha-kernel
- mocha-core
- mocha-gaming

Nunca habilitar no cliente final:

- cachyos
- cachyos-v3
- cachyos-v4
- cachyos-extra
- cachyos-extra-v3
- cachyos-extra-v4

### Motivo

Evitar contaminação do sistema por pacotes não curados, recompilações globais, prioridades externas e combinações kernel/driver que não foram validadas pelo MochaArch.

### Fluxo obrigatório do repositório

1. incoming/upstream-arch
2. incoming/upstream-cachyos
3. incoming/local-builds
4. staging/kernel-stacks/<perfil>/<stack-id>
5. testing/<perfil>
6. stable/<perfil>
7. publicação externa, por exemplo Cloudflare R2

incoming é apenas área de coleta.

testing é canal de validação.

stable é o único canal público normal para usuário final.

Cloudflare R2 deve ser espelho/CDN do canal stable; a fonte canônica local continua sendo /media/vmstore/mocha-repo.

### Perfis obrigatórios

- generic-x86_64-lts: fallback seguro, ISO e maior compatibilidade Intel/AMD.
- generic-x86_64-current: Arch comum/current sem otimização agressiva de microarquitetura.
- x86_64-v3-lts: LTS otimizado para CPUs compatíveis, quando validado.
- x86_64-v3-current: perfil gamer/performance preferencial em CPU compatível.
- x86_64-v4-current: opcional para CPU compatível com x86-64-v4/AVX-512; não usar como padrão.

### Política de stack

Cada stack fechado deve conter, quando aplicável:

- kernel
- headers
- módulo NVIDIA correspondente
- nvidia-utils
- lib32-nvidia-utils
- opencl-nvidia
- nvidia-settings
- libxnvctrl
- egl-wayland
- firmware necessário
- manifesto
- checksums
- banco pacman
- status de validação

Nenhuma atualização de kernel deve remover o último kernel funcional validado.

Todo perfil otimizado deve preservar fallback generic-x86_64-lts.

### Estado staging atual registrado

Stack: linux-cachyos-7.0.11-1-cachyos-nvidia-610.43.02-3-20260605-210945

Perfil: generic-x86_64-current

Caminho canônico:

/media/vmstore/mocha-repo/staging/kernel-stacks/generic-x86_64-current/linux-cachyos-7.0.11-1-cachyos-nvidia-610.43.02-3-20260605-210945

Status: staging-only.

Não foi promovido para testing.

Não foi promovido para stable.

Não foi habilitado CachyOS no cliente.

### Arquivos de referência

Política local:

/media/vmstore/mocha-repo/policy/20260605-211422-politica-repo-mocha-sem-cachyos-no-cliente.md

Snippet conceitual de pacman sem CachyOS:

/media/vmstore/mocha-repo/policy/20260605-211422-pacman-snippet-usuario-final-sem-cachyos.conf

Ponteiro do último stack staging canônico:

/media/vmstore/mocha-repo/state/ULTIMO-STACK-STAGING-CANONICO-MOCHA.txt

Cópia documental no Git:

/media/mochafast/MochaArch/ativo/docs/repo-mocha/ultimo-stack-staging-canonico.md

### Regra operacional

Antes de qualquer promoção para testing ou stable, auditar o stack real, validar boot, headers, NVIDIA, SDDM Wayland, Steam/Proton, desempenho e rollback.

Depois de alterar política, staging, manual ou documentação, commitar com mocha-commit-agora.

<!-- MOCHA-REPO-CONTROLADO-FIM -->

<!-- MOCHA-ISO-LTS-HARDWARE-ADVISOR-INICIO -->

## ISO MochaArch: kernel LTS padrão e upgrade assistido por hardware

Atualizado em: 20260605-221240

### Decisão canônica

A ISO MochaArch e a instalação inicial devem usar por padrão o kernel Arch LTS genérico.

Pacotes obrigatórios da base inicial:

- linux-lts
- linux-lts-headers

A ISO não deve nascer agressiva.

A primeira instalação deve priorizar compatibilidade, boot confiável, SDDM, KDE Plasma, Wayland e recuperação.

### Stack LTS da ISO

Stack baixado e registrado:

arch-linux-lts-6.18.34-1-iso-base-20260605-221240

Perfil:

generic-x86_64-lts

Versão linux-lts:

6.18.34-1

Caminho canônico no VMSTORE:

/media/vmstore/mocha-repo/staging/kernel-stacks/generic-x86_64-lts/arch-linux-lts-6.18.34-1-iso-base-20260605-221240

Origem:

Arch Linux oficial, repo core.

Status:

staging-only, destinado à base da ISO e ao fallback.

### Upgrade de performance pós-instalação

Depois da instalação, ou no primeiro boot do sistema instalado, o Mocha deve detectar o hardware real e sugerir um upgrade de performance quando houver stack validado no repositório Mocha stable.

Nome operacional sugerido:

mocha-hardware-advisor

Função:

Detectar CPU, arquitetura suportada, GPU e driver indicado; depois sugerir o melhor stack kernel + headers + driver disponível no repo Mocha stable.

### Perfis de CPU

Perfis mínimos:

- generic-x86_64
- x86_64-v3
- x86_64-v4

generic-x86_64 é o perfil seguro.

x86_64-v3 é o perfil gamer/performance preferencial quando a CPU suportar.

x86_64-v4 é opcional e não deve ser padrão.

### Detecção de GPU

O assistente deve detectar:

- NVIDIA
- AMD
- Intel
- GPU híbrida, quando aplicável

Para NVIDIA, o stack recomendado deve preservar compatibilidade entre kernel, headers, módulo NVIDIA, nvidia-utils, lib32-nvidia-utils, opencl-nvidia, nvidia-settings, libxnvctrl, egl-wayland e firmware necessário.

### Consentimento obrigatório

O upgrade de performance nunca deve ser automático sem aceite explícito do usuário.

A sugestão deve informar:

- perfil detectado
- stack recomendado
- origem no repo Mocha stable
- que o kernel LTS será mantido como fallback
- que o usuário pode continuar no perfil seguro

### Fallback obrigatório

O kernel Arch LTS genérico deve permanecer instalado.

Nenhuma atualização de kernel deve remover o último kernel funcional validado.

O bootloader deve manter entrada de recuperação para o LTS.

### Repositório

O upgrade deve vir apenas do repositório Mocha stable.

Nunca habilitar CachyOS no cliente final.

incoming é coleta.

staging é montagem de stack.

testing é validação.

stable é canal público normal.

Cloudflare R2 deve ser espelho/CDN do stable, não fonte canônica local.

Fonte local canônica:

/media/vmstore/mocha-repo

### Arquivos de referência

Documento canônico:

/media/mochafast/MochaArch/ativo/docs/politica-iso-kernel-lts-hardware-advisor.md

Especificação inicial do advisor:

/media/mochafast/MochaArch/ativo/docs/especificacao-mocha-hardware-advisor.md

Último stack ISO LTS:

/media/mochafast/MochaArch/ativo/docs/ultimo-stack-iso-lts.md

Política repo Mocha:

/media/vmstore/mocha-repo/policy/20260605-211422-politica-repo-mocha-sem-cachyos-no-cliente.md

Snippet pacman sem CachyOS:

/media/vmstore/mocha-repo/policy/20260605-211422-pacman-snippet-usuario-final-sem-cachyos.conf

Ponteiro do stack ISO LTS:

/media/vmstore/mocha-repo/state/ULTIMO-STACK-ISO-LTS-MOCHA.txt

### Regra operacional

Na ISO e na instalação inicial, usar linux-lts e linux-lts-headers.

Após detectar CPU/GPU, sugerir upgrade para o melhor stack Mocha compatível.

Instalar somente com aceite do usuário.

Manter LTS como fallback.

Não habilitar CachyOS no cliente final.

<!-- MOCHA-ISO-LTS-HARDWARE-ADVISOR-FIM -->

<!-- MOCHA-DIRT2-BACKUP-BEGIN -->
## Backup persistente — DiRT Rally 2.0

Estado registrado em `20260606-150516`.

- Jogo: DiRT Rally 2.0.
- Steam App ID: `690790`.
- Arquivo real utilizado pelo Proton:
  `~/.local/share/Steam/steamapps/compatdata/690790/pfx/drive_c/users/steamuser/Documents/My Games/DiRT Rally 2.0/hardwaresettings/hardware_settings_config.xml`
- Backup canônico versionado:
  `/media/mochafast/MochaArch/jogos/dirt/hardware_settings_config.xml`
- Restaurador permanente:
  `/media/mochafast/MochaArch/jogos/dirt/restaurar-configuracao-dirt2.sh`
- SHA256 do backup canônico:
  `d4a1cc365e857c80b87979f796931996eb61696e57f5e70f6a2ebef3a0fc64e9`

O arquivo `hardware_settings_config.xml` preserva as configurações gráficas
e de exibição do jogo. O arquivo `hardware_settings_info.xml` não deve ser
restaurado, pois registra informações detectadas sobre o hardware da máquina.

Procedimento após formatar:

1. Montar o FAST em `/media/mochafast`.
2. Instalar o DiRT Rally 2.0 pela Steam.
3. Abrir e fechar o jogo uma vez para criar o prefixo Proton.
4. Executar `/media/mochafast/MochaArch/jogos/dirt/restaurar-configuracao-dirt2.sh`.

Antes da restauração, o script preserva automaticamente a configuração
existente no prefixo Proton.
<!-- MOCHA-DIRT2-BACKUP-END -->

<!-- MOCHA-INICIO-WALLPAPER-BLOQUEIO -->
## Wallpaper Mocha no bloqueio de tela do Plasma

- O SDDM de inicialização e o bloqueio de tela do KDE Plasma são configurações independentes.
- Ambos devem usar o mesmo wallpaper oficial Mocha utilizado no desktop.
- O bloqueio deve usar o plugin `org.kde.image` no arquivo `~/.config/kscreenlockerrc`.
- As chaves `Image` e `PreviewImage` devem apontar para o arquivo canônico do wallpaper Mocha.
- Esta configuração faz parte obrigatória da montagem visual do perfil Mocha Gamer.
- A validação final deve incluir a tela inicial do SDDM e o bloqueio acionado por `Meta+L`.
<!-- MOCHA-FIM-WALLPAPER-BLOQUEIO -->

<!-- MOCHA:IMPORTACAO-SSH-BITWARDEN:BEGIN -->
## Importação manual da chave SSH do GitHub pelo Bitwarden

A chave privada do GitHub deve ser importada manualmente a partir do Bitwarden por meio de um arquivo protegido aberto diretamente em um editor. A chave nunca deve ser colada diretamente no shell.

### Procedimento canônico

1. Criar o diretório `~/.ssh` com permissão `700`.
2. Criar o arquivo intermediário `~/.ssh/.id_mocha_github.import` com permissão `600`.
3. Abrir o arquivo usando `nano --ignorercfiles ~/.ssh/.id_mocha_github.import`.
4. Colar a chave privada completa, incluindo as linhas `BEGIN` e `END`.
5. Salvar com `Ctrl+O`, confirmar com `Enter` e sair com `Ctrl+X`.
6. Normalizar possíveis finais de linha CRLF trazidos do Bitwarden ou de sistemas Windows.
7. Validar a chave privada usando `ssh-keygen -y`.
8. Gerar a chave pública correspondente.
9. Instalar a chave privada como `~/.ssh/id_mocha_github`, com permissão `600`.
10. Instalar a chave pública como `~/.ssh/id_mocha_github.pub`, com permissão `644`.
11. Configurar `~/.ssh/config` para usar exclusivamente essa identidade em `github.com`.
12. Testar a autenticação usando `ssh -n -T git@github.com`.
13. Usar `-n` ou entrada redirecionada de `/dev/null` quando o teste SSH estiver dentro de um heredoc, impedindo que o SSH consuma o restante do script.
14. Apagar o arquivo intermediário somente depois da validação, instalação e autenticação bem-sucedidas.
15. Preservar o arquivo intermediário quando qualquer etapa falhar.

### Identidade Git canônica

- Nome: `Ricardo Kern Diesel`
- E-mail: `ricardo.diesel@gmail.com`
- Repositório: `git@github.com:dieseloslab/Mocha.git`
- Chave privada local: `~/.ssh/id_mocha_github`
- Chave pública local: `~/.ssh/id_mocha_github.pub`

### Regras de segurança

- Nunca colar a chave privada diretamente em um comando.
- Nunca transportar a chave por `echo`, variável de shell ou argumento de linha de comando.
- Nunca salvar a chave na Área de Trabalho, em Downloads, no FAST, no VMSTORE ou no repositório.
- Nunca registrar o conteúdo da chave nos relatórios de auditoria.
- Nunca versionar identidades SSH ou arquivos `.pem`, `.key`, `.p12` ou `.pfx`.
- Antes de cada commit, auditar os nomes e o conteúdo dos arquivos preparados.
<!-- MOCHA:IMPORTACAO-SSH-BITWARDEN:END -->

<!-- MOCHA:GIT-LFS-OBRIGATORIO:BEGIN -->
## Git LFS obrigatório no repositório Mocha

O pacote `git-lfs` é requisito obrigatório para operar o repositório Mocha quando o arquivo `.gitattributes` contém filtros LFS.

### Procedimento canônico

1. Instalar o pacote usando `sudo pacman -S --needed git-lfs`.
2. Confirmar a instalação usando `git lfs version`.
3. Inicializar o Git LFS dentro do repositório usando `git lfs install --local`.
4. Executar a inicialização antes de `git add`, `git commit` ou `git push`.
5. Conferir os arquivos administrados pelo LFS usando `git lfs ls-files`.
6. Nunca remover filtros LFS do arquivo `.gitattributes` apenas para contornar uma falha de ambiente.

### Falha característica

Quando o Git LFS não está instalado, operações de staging ou transferência podem falhar com mensagens semelhantes a:

- `git-lfs: command not found`
- `git-lfs filter-process`
- `fatal: the remote end hung up unexpectedly`

Essa falha deve ser corrigida instalando e inicializando o Git LFS. Não se deve remover arquivos, filtros ou regras do repositório como remendo.
<!-- MOCHA:GIT-LFS-OBRIGATORIO:END -->

---

## Política interna do manual e dos commits

- Manual canônico: `/media/mochafast/MochaArch-Interno/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md`.
- Repositório privado: `git@github.com:dieseloslab/Mocha-Interno.git`.
- Repositório público: `git@github.com:dieseloslab/Mocha.git`.
- O caminho antigo em `/media/mochafast/MochaArch/ativo/` é somente um link simbólico local.
- O manual nunca deve ser rastreado, adicionado à força ou reaparecer no histórico público.
- Alterações públicas e internas recebem commits separados pelo comando `mocha-commit-agora "Descrição objetiva"`.
- Backups anteriores a reescritas de histórico ficam em `/media/vmstore/mocha-backups`.
- Todos os arquivos das cópias de trabalho em FAST devem pertencer ao usuário normal; corrigir propriedade antes de `reset`, `checkout` ou reescrita.
- Para mostrar somente a contagem privada no perfil, habilitar `Profile > Contribution settings > Private contributions`.



## Registro operacional — teste kernel CachyOS BORE v3 corrigido — 20260610-155055

- Kernel de teste: `linux-cachyos-bore` + `linux-cachyos-bore-headers` + `linux-cachyos-bore-nvidia-open`.
- Correção aplicada: `pacman.conf` temporário com `Architecture = auto x86_64 x86_64_v3`.
- Repositório usado: CachyOS `x86_64_v3`, apenas via `pacman.conf` temporário em `/media/mochafast/MochaArch/auditorias/backup-bore-v3-cachyos-corrigido-20260610-155055/pacman-cachyos-v3-temporario.conf`.
- Política: não deixar CachyOS ativo no `/etc/pacman.conf` após instalação; evitar `pacman -Syu` global com CachyOS ativo.
- Boot padrão GRUB configurado para: `Advanced options for Arch Linux>Arch Linux, with Linux linux-cachyos-bore`.
- Relatório: `/media/mochafast/MochaArch/auditorias/mocha-instala-bore-v3-cachyos-corrigido-20260610-155055.log`.
<!-- MOCHA_WALLPAPER_CANONICO_START -->

## Wallpaper canônico Mocha — desktop, bloqueio e login

- A imagem canônica do papel de parede fica em: `/media/mochafast/MochaArch/ativo/assets/branding/wallpaper/`.
- A mesma identidade visual deve ser aplicada em três pontos: desktop Plasma, tela de bloqueio KDE e tela de login SDDM.
- Para estabilidade no boot/login, a imagem escolhida deve ser instalada também em: `/usr/share/backgrounds/mocha/`.
- Caminho atualmente aplicado pelo sistema: `/usr/share/backgrounds/mocha/mocha-wallpaper-canonico.png`.
- O SDDM deve permanecer em Breeze/Wayland, usando `theme.conf.user` com `background=/usr/share/backgrounds/mocha/mocha-wallpaper-canonico.png`.
<!-- MOCHA_WALLPAPER_CANONICO_END -->


## Registro operacional — atualização controlada pré-ISO interna (20260610-193344)



## Registro operacional — atualização controlada pré-ISO interna (20260610-193548)

- Escopo: preparação da primeira ISO interna/laboratório com Calamares.
- Resultado: atualização concluída; falha anterior ocorreu apenas na etapa de registro no manual.
- Manual acessado por symlink: `/media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md`.
- Manual real resolvido: `/media/mochafast/MochaArch-Interno/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md`.
- Kernel em execução: `7.0.11-1-cachyos`.
- Driver NVIDIA via modinfo: `610.43.02`.
- Driver NVIDIA via nvidia-smi: `610.43.02`.
- Vermagic NVIDIA: `7.0.11-1-cachyos SMP preempt mod_unload `.
- Stack sensível antes: `/media/mochafast/MochaArch/auditorias/mocha-stack-sensivel-antes-update-pre-iso-20260610-193344.tsv`.
- Stack sensível depois: `/media/mochafast/MochaArch/auditorias/mocha-stack-sensivel-depois-update-pre-iso-20260610-193344.tsv`.
- Transação pacman: `/media/mochafast/MochaArch/auditorias/mocha-pacman-transacao-pre-iso-interna-20260610-193344.log`.
- Relatório original do update: `/media/mochafast/MochaArch/auditorias/mocha-atualiza-sistema-pre-iso-interna-20260610-193344.log`.
- Relatório de finalização: `/media/mochafast/MochaArch/auditorias/mocha-finaliza-update-pre-iso-interna-symlink-manual-20260610-193548.log`.
- Lista pacnew pós-update: `/media/mochafast/MochaArch/auditorias/mocha-pacnew-pos-update-pre-iso-20260610-193548.txt`.
- Reboot recomendado: `sim`.
- Regra preservada: kernel CachyOS, NVIDIA, EGL e firmware NVIDIA não foram atualizados nesta transação.
- Próximo passo após reboot: refazer o congelamento da stack CachyOS/NVIDIA com parser corrigido para versões com epoch.

<!-- MOCHA:RECEITA-ISO-LIVE-DIRETA-CALAMARES-20260611 -->

## Receita canônica — ISO live direta com Calamares

Data de canonização: 2026-06-11.

### Objetivo

Gerar a ISO interna `mocha.iso` com boot direto na live, Calamares disponível imediatamente e artefatos pesados fora do FAST.

### Locais canônicos

- Repositório público/leves: `/media/mochafast/MochaArch`
- Manual interno: `/media/mochafast/MochaArch-Interno`
- Artefatos pesados, workdir e ISO: `/media/vmstore/MochaArch`
- Saída final da ISO: `/media/vmstore/MochaArch/iso/mocha.iso`
- Checksum final: `/media/vmstore/MochaArch/iso/mocha.iso.sha256`
- Workdir temporário do mkarchiso: `/media/vmstore/MochaArch/work/`

### Regras

1. A ISO deve ser gerada no VMSTORE, não no FAST.
2. A ISO final deve ser canonizada como `mocha.iso`.
3. A live deve entrar direto no ambiente gráfico, sem exigir login manual.
4. O Calamares deve abrir automaticamente na live, com lançador também disponível na área de trabalho.
5. O repositório local do Calamares deve ser usado para satisfazer pacotes ausentes dos repositórios oficiais.
6. O SDDM da live é apenas mecanismo de entrada automática da live. Ele não define a política final do sistema instalado.
7. O sistema instalado deve preservar a política Mocha: Plasma/KDE, Wayland obrigatório e configuração final controlada pelo Calamares e pelos módulos Mocha.
8. Pacotes, serviços e arquivos criados para a live devem ser versionados em commits pequenos e temáticos.
9. O manual interno não deve ser commitado no repositório público do Mocha.
10. O caminho público de acesso ao manual deve ser symlink para `/media/mochafast/MochaArch-Interno`, nunca arquivo físico dentro de `/media/mochafast/MochaArch`.

### Resultado aprovado

A geração aprovada produziu:

- `/media/vmstore/MochaArch/iso/mocha.iso`
- ISO com aproximadamente 1.2 GiB
- SHA256 registrado em `/media/vmstore/MochaArch/iso/mocha.iso.sha256`
- Commit público do diretório Arch: `fix(iso): usar repo local do Calamares na live`

### Observação operacional

Se a ISO iniciar em gerenciador de login ou parar antes da live, isso é falha para esta etapa. A live precisa entrar direto no ambiente gráfico e permitir iniciar a instalação imediatamente.


---

## MochaArch — Correção definitiva de áudio pós Alt+Tab em jogos Proton/Wine

Sintoma observado: jogos Steam/Proton podem perder áudio depois de Alt+Tab, com caso recorrente em DiRT Rally 2.0.

Política canônica:

- manter PipeWire + WirePlumber;
- desativar suspensão automática de nós ALSA via `/etc/wireplumber/wireplumber.conf.d/51-mocha-gaming-no-alsa-suspend.conf`;
- usar `session.suspend-timeout-seconds = 0`;
- usar `node.pause-on-idle = false`;
- manter wrapper Steam canônico com guarda de áudio durante a execução do jogo;
- comando de resgate manual: `mocha-audio-recover`.

Linha Steam canônica:

```
/home/hal/.local/bin/mocha-steam-game-run %command%
```

Restrições mantidas:

- sessão do sistema continua Wayland;
- Proton/Wine pode ser forçado para caminho compatível;
- sem gamescope por padrão;
- sem vkBasalt por padrão;
- sem `MANGOHUD_DLSYM` por padrão;
- GameMode ativo quando disponível.

Receita persistente salva em:

```
/media/vmstore/MochaArch/receitas/audio/mocha-audio-alt-tab-definitivo.md
```

<!-- MOCHA-FIRSTBOOT-STACK-BEGIN -->

## Mocha Firstboot Stack Optimizer — Rust executável com ícone

Registro atualizado em: `2026-06-12 00:33:38`.

### Objetivo

Programa gráfico em Rust/GTK4 para execução no primeiro boot/login do sistema instalado. Ele detecta CPU e GPU, atualiza totalmente o sistema antes de qualquer troca de kernel, instala a stack CachyOS apropriada de forma restrita e limpa qualquer canal CachyOS temporário ao final.

### Regras obrigatórias

- O programa é um executável Rust real: `/usr/bin/mocha-firstboot-stack`.
- O atalho `.desktop` chama diretamente o binário Rust, sem `.sh` intermediário.
- O programa tem ícone próprio: `mocha-firstboot-stack.svg`.
- O autostart chama o binário com `--autostart`.
- O worker root é o próprio binário relançado via `pkexec --worker`.
- Antes de instalar kernel/driver, o sistema é atualizado com `pacman -Syu` usando somente os canais normais Arch/Mocha.
- O CachyOS é usado somente via `pacman --config /tmp/mocha-firstboot-pacman-cachy.conf`.
- Não usar `cachyos-repo.sh`.
- Não deixar `[cachyos]`, `[cachyos-v3]`, `[cachyos-v4]` ou `[cachyos-znver4]` permanentes em `/etc/pacman.conf`.
- Após instalar a stack, remover bases sync CachyOS, remover config temporária e validar ausência de canal CachyOS permanente.
- Se a stack ideal já estiver instalada, o programa deve avisar e oferecer reinstalação/reparo.

### Caminhos instalados

```text
/usr/bin/mocha-firstboot-stack
/usr/share/icons/hicolor/scalable/apps/mocha-firstboot-stack.svg
/usr/share/applications/mocha-firstboot-stack.desktop
/etc/xdg/autostart/mocha-firstboot-stack.desktop
/usr/share/polkit-1/actions/org.mocha.firstboot.stack.policy
/var/lib/mocha-firstboot-stack/done
/var/log/mocha-firstboot-stack.log
```

### Comandos de validação

```bash
/usr/bin/mocha-firstboot-stack --diagnose
/usr/bin/mocha-firstboot-stack
grep -n '^\[cachyos' /etc/pacman.conf || true
ls -l /usr/bin/mocha-firstboot-stack
ls -l /usr/share/applications/mocha-firstboot-stack.desktop
ls -l /etc/xdg/autostart/mocha-firstboot-stack.desktop
```

### Código completo

#### `Cargo.toml`

```toml
[package]
name = "mocha-firstboot-stack"
version = "0.3.0"
edition = "2021"
license = "GPL-3.0-or-later"
description = "Mocha first boot stack optimizer"

[dependencies]
gtk = { package = "gtk4", version = "0.9" }

[profile.release]
lto = "thin"
codegen-units = 1
strip = true
```

#### `src/main.rs`

```rust
use gtk::glib::{self, ControlFlow};
use gtk::prelude::*;
use gtk::{
    Application, ApplicationWindow, Box as GtkBox, Button, Label, Orientation, ProgressBar,
    ScrolledWindow, TextBuffer, TextView,
};
use std::env;
use std::fs::{self, File, OpenOptions};
use std::io::{BufRead, BufReader, Write};
use std::path::Path;
use std::process::{Command, Stdio};
use std::sync::mpsc::{self, Sender};
use std::thread;
use std::time::Duration;

const APP_ID: &str = "org.mocha.FirstbootStack";
const DONE_MARKER: &str = "/var/lib/mocha-firstboot-stack/done";
const STATE_DIR: &str = "/var/lib/mocha-firstboot-stack";
const LOG_PATH: &str = "/var/log/mocha-firstboot-stack.log";
const TEMP_PACMAN_CONF: &str = "/tmp/mocha-firstboot-pacman-cachy.conf";
const CACHY_KEY: &str = "F3B607488DB35A47";

#[derive(Clone, Debug)]
struct Tier {
    label: &'static str,
    repo: &'static str,
    arch_path: &'static str,
}

#[derive(Clone, Debug)]
enum GpuKind {
    NvidiaOpen,
    NvidiaLegacy,
    Amd,
    Intel,
    Unknown,
}

#[derive(Clone, Debug)]
struct Hardware {
    cpu_model: String,
    cpu_vendor: String,
    gpu_summary: String,
    gpu_kind: GpuKind,
    tier: Tier,
}

#[derive(Clone, Debug)]
struct StackStatus {
    installed: bool,
    desired_packages: Vec<String>,
    missing_packages: Vec<String>,
}

enum UiMsg {
    Progress(u8, String),
    Log(String),
    Done(bool, String),
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.iter().any(|a| a == "--worker") {
        let reinstall = args.iter().any(|a| a == "--reinstall");
        let rc = match worker_main(reinstall) {
            Ok(()) => 0,
            Err(e) => {
                eprintln!("ERRO: {e}");
                emit_progress(100, &format!("Erro: {e}"));
                1
            }
        };
        std::process::exit(rc);
    }

    if args.iter().any(|a| a == "--diagnose") {
        let hw = detect_hardware();
        let status = stack_status(&hw);
        println!("Hardware:\n{:#?}", hw);
        println!("Stack:\n{:#?}", status);
        return;
    }

    gui_main(args.iter().any(|a| a == "--autostart"));
}

fn gui_main(is_autostart: bool) {
    let hw = detect_hardware();
    let status = stack_status(&hw);

    if is_autostart && Path::new(DONE_MARKER).exists() && status.installed {
        return;
    }

    let app = Application::builder().application_id(APP_ID).build();
    app.connect_activate(move |app| {
        build_ui(app, hw.clone(), status.clone(), is_autostart);
    });
    app.run();
}

fn build_ui(app: &Application, hw: Hardware, status: StackStatus, is_autostart: bool) {
    let window = ApplicationWindow::builder()
        .application(app)
        .title("Mocha Stack Optimizer")
        .default_width(860)
        .default_height(660)
        .resizable(true)
        .build();

    let root = GtkBox::new(Orientation::Vertical, 14);
    root.set_margin_top(24);
    root.set_margin_bottom(24);
    root.set_margin_start(28);
    root.set_margin_end(28);

    let title = Label::new(Some("Mocha Stack Optimizer"));
    title.set_xalign(0.0);
    title.add_css_class("title-1");

    let subtitle = Label::new(Some(
        "Atualização total do sistema, detecção de CPU/GPU e instalação restrita do kernel CachyOS com driver de vídeo casado.",
    ));
    subtitle.set_xalign(0.0);
    subtitle.set_wrap(true);

    let marker_state = if Path::new(DONE_MARKER).exists() {
        "Marcador firstboot: concluído anteriormente"
    } else {
        "Marcador firstboot: ainda não concluído"
    };

    let stack_state = if status.installed {
        "Estado da stack: a stack ideal já está instalada"
    } else {
        "Estado da stack: faltam pacotes da stack ideal"
    };

    let missing = if status.missing_packages.is_empty() {
        "Pacotes faltantes: nenhum".to_string()
    } else {
        format!("Pacotes faltantes: {}", status.missing_packages.join(", "))
    };

    let desired = format!("Pacotes desejados: {}", status.desired_packages.join(", "));

    let autostart_text = if is_autostart {
        "Modo de abertura: autostart pós-login"
    } else {
        "Modo de abertura: manual por atalho/menu"
    };

    let info_text = format!(
        "CPU: {}\nVendor: {}\nGPU: {}\nStack selecionada: {}\n{}\n{}\n{}\n{}\n{}\n\nPolítica: CachyOS será usado somente por pacman.conf temporário em /tmp. O programa não deixa canal CachyOS permanente no sistema.",
        hw.cpu_model,
        hw.cpu_vendor,
        hw.gpu_summary,
        hw.tier.label,
        marker_state,
        stack_state,
        missing,
        desired,
        autostart_text,
    );

    let info = Label::new(Some(&info_text));
    info.set_xalign(0.0);
    info.set_wrap(true);
    info.add_css_class("monospace");

    let progress = ProgressBar::new();
    progress.set_show_text(true);

    if status.installed {
        progress.set_fraction(1.0);
        progress.set_text(Some("Stack ideal já instalada"));
    } else {
        progress.set_fraction(0.0);
        progress.set_text(Some("Pronto para instalar stack ideal"));
    }

    let log_view = TextView::new();
    log_view.set_editable(false);
    log_view.set_cursor_visible(false);
    log_view.set_monospace(true);
    let log_buffer = log_view.buffer();

    if status.installed {
        append_log(
            &log_buffer,
            "A stack ideal já está instalada. Use o botão de reinstalação somente se quiser reparar ou recasar os pacotes.\n",
        );
    } else {
        append_log(
            &log_buffer,
            "A stack ideal ainda não está completa. O botão principal fará atualização total e instalação restrita.\n",
        );
    }

    let scroll = ScrolledWindow::builder()
        .vexpand(true)
        .hexpand(true)
        .child(&log_view)
        .build();

    let buttons = GtkBox::new(Orientation::Horizontal, 12);

    let main_button_label = if status.installed {
        "Reinstalar stack ideal"
    } else {
        "Atualizar e instalar stack ideal"
    };

    let main_button = Button::with_label(main_button_label);
    main_button.add_css_class("suggested-action");

    let diagnose_button = Button::with_label("Diagnóstico");
    let close_button = Button::with_label("Fechar");

    let app_weak = app.downgrade();
    close_button.connect_clicked(move |_| {
        if let Some(app) = app_weak.upgrade() {
            app.quit();
        }
    });

    buttons.append(&main_button);
    buttons.append(&diagnose_button);
    buttons.append(&close_button);

    root.append(&title);
    root.append(&subtitle);
    root.append(&info);
    root.append(&progress);
    root.append(&scroll);
    root.append(&buttons);

    window.set_child(Some(&root));
    window.present();

    let progress_clone = progress.clone();
    let buffer_clone = log_buffer.clone();
    let button_clone = main_button.clone();
    let force_reinstall = status.installed;

    main_button.connect_clicked(move |_| {
        button_clone.set_sensitive(false);

        if force_reinstall {
            append_log(&buffer_clone, "Reinstalação solicitada. O worker reinstalará os pacotes mesmo que já estejam presentes.\n");
        } else {
            append_log(&buffer_clone, "Instalação solicitada. O worker atualizará o sistema antes de instalar a stack.\n");
        }

        progress_clone.set_fraction(0.01);
        progress_clone.set_text(Some("Iniciando worker privilegiado"));

        let (tx, rx) = mpsc::channel::<UiMsg>();

        thread::spawn(move || {
            run_worker_process(tx, force_reinstall);
        });

        let progress_tick = progress_clone.clone();
        let buffer_tick = buffer_clone.clone();

        glib::timeout_add_local(Duration::from_millis(150), move || {
            let mut finished = false;

            while let Ok(msg) = rx.try_recv() {
                match msg {
                    UiMsg::Progress(pct, text) => {
                        let fraction = (pct as f64 / 100.0).clamp(0.0, 1.0);
                        progress_tick.set_fraction(fraction);
                        progress_tick.set_text(Some(&text));
                        append_log(&buffer_tick, &format!("[{:>3}%] {}\n", pct, text));
                    }
                    UiMsg::Log(text) => {
                        append_log(&buffer_tick, &format!("{text}\n"));
                    }
                    UiMsg::Done(ok, text) => {
                        if ok {
                            progress_tick.set_fraction(1.0);
                            progress_tick.set_text(Some("Concluído. Reinicie o sistema."));
                        } else {
                            progress_tick.set_text(Some("Falha. Verifique o log."));
                        }
                        append_log(&buffer_tick, &format!("{text}\n"));
                        finished = true;
                    }
                }
            }

            if finished {
                ControlFlow::Break
            } else {
                ControlFlow::Continue
            }
        });
    });

    let buffer_diag = log_buffer.clone();
    diagnose_button.connect_clicked(move |_| {
        let hw = detect_hardware();
        let status = stack_status(&hw);
        append_log(&buffer_diag, "\n===== Diagnóstico atual =====\n");
        append_log(&buffer_diag, &format!("CPU: {}\n", hw.cpu_model));
        append_log(&buffer_diag, &format!("Vendor: {}\n", hw.cpu_vendor));
        append_log(&buffer_diag, &format!("GPU: {}\n", hw.gpu_summary));
        append_log(&buffer_diag, &format!("Tier: {}\n", hw.tier.label));
        append_log(
            &buffer_diag,
            &format!(
                "Stack instalada: {}\n",
                if status.installed { "sim" } else { "não" }
            ),
        );
        append_log(
            &buffer_diag,
            &format!(
                "Pacotes desejados: {}\n",
                status.desired_packages.join(", ")
            ),
        );
        append_log(
            &buffer_diag,
            &format!(
                "Pacotes faltantes: {}\n",
                if status.missing_packages.is_empty() {
                    "nenhum".to_string()
                } else {
                    status.missing_packages.join(", ")
                }
            ),
        );
        append_log(&buffer_diag, "============================\n");
    });
}

fn append_log(buffer: &TextBuffer, text: &str) {
    let mut end = buffer.end_iter();
    buffer.insert(&mut end, text);
}

fn run_worker_process(tx: Sender<UiMsg>, reinstall: bool) {
    let exe = env::current_exe().unwrap_or_else(|_| "/usr/bin/mocha-firstboot-stack".into());

    let mut cmd = Command::new("pkexec");
    cmd.arg(exe).arg("--worker");

    if reinstall {
        cmd.arg("--reinstall");
    }

    let mut child = match cmd.stdout(Stdio::piped()).stderr(Stdio::piped()).spawn() {
        Ok(c) => c,
        Err(e) => {
            let _ = tx.send(UiMsg::Done(false, format!("Falha ao iniciar pkexec: {e}")));
            return;
        }
    };

    if let Some(stderr) = child.stderr.take() {
        let tx_err = tx.clone();
        thread::spawn(move || {
            let reader = BufReader::new(stderr);
            for line in reader.lines().flatten() {
                let _ = tx_err.send(UiMsg::Log(format!("stderr: {line}")));
            }
        });
    }

    if let Some(stdout) = child.stdout.take() {
        let reader = BufReader::new(stdout);
        for line in reader.lines().flatten() {
            if let Some((pct, msg)) = parse_progress_line(&line) {
                let _ = tx.send(UiMsg::Progress(pct, msg));
            } else {
                let _ = tx.send(UiMsg::Log(line));
            }
        }
    }

    match child.wait() {
        Ok(status) if status.success() => {
            let _ = tx.send(UiMsg::Done(true, format!("Concluído. Log: {LOG_PATH}")));
        }
        Ok(status) => {
            let _ = tx.send(UiMsg::Done(
                false,
                format!("Worker retornou erro: {:?}. Log: {LOG_PATH}", status.code()),
            ));
        }
        Err(e) => {
            let _ = tx.send(UiMsg::Done(
                false,
                format!("Falha aguardando worker: {e}. Log: {LOG_PATH}"),
            ));
        }
    }
}

fn parse_progress_line(line: &str) -> Option<(u8, String)> {
    let mut parts = line.splitn(3, '|');
    let tag = parts.next()?;
    if tag != "MOCHA_PROGRESS" {
        return None;
    }
    let pct = parts.next()?.parse::<u8>().ok()?;
    let msg = parts.next().unwrap_or("").to_string();
    Some((pct.min(100), msg))
}

fn worker_main(reinstall: bool) -> Result<(), String> {
    if !is_root() {
        return Err("worker precisa ser executado como root via pkexec".to_string());
    }

    fs::create_dir_all(STATE_DIR).map_err(|e| format!("falha criando {STATE_DIR}: {e}"))?;

    let mut log = OpenOptions::new()
        .create(true)
        .append(true)
        .open(LOG_PATH)
        .map_err(|e| format!("falha abrindo log {LOG_PATH}: {e}"))?;

    emit_progress(1, "Iniciando Mocha Stack Optimizer");
    log_line(
        &mut log,
        "============================================================",
    );
    log_line(&mut log, "Mocha Stack Optimizer — início");
    log_line(&mut log, &format!("Modo reinstalação: {reinstall}"));

    if Path::new("/var/lib/pacman/db.lck").exists() {
        return Err("lock do pacman encontrado em /var/lib/pacman/db.lck; feche outro gerenciador de pacotes".to_string());
    }

    let hw = detect_hardware();
    let initial_status = stack_status(&hw);
    log_line(&mut log, &format!("Hardware detectado: {hw:#?}"));
    log_line(&mut log, &format!("Status inicial: {initial_status:#?}"));

    if initial_status.installed && !reinstall {
        emit_progress(100, "Stack ideal já instalada. Nada a fazer.");
        log_line(
            &mut log,
            "Stack ideal já instalada; worker encerrado sem alterações.",
        );
        fs::write(DONE_MARKER, "done\n")
            .map_err(|e| format!("falha gravando marcador {DONE_MARKER}: {e}"))?;
        return Ok(());
    }

    emit_progress(
        5,
        "Removendo qualquer canal CachyOS permanente antes da atualização",
    );
    scrub_cachy_repos_from_pacman_conf(&mut log)?;
    remove_cachy_sync_dbs(&mut log)?;

    emit_progress(10, "Sincronizando bases oficiais Arch/Mocha");
    run_checked(&mut log, "pacman", &["-Syy", "--noconfirm"])?;

    emit_progress(16, "Atualizando totalmente o sistema antes do kernel");
    run_checked(&mut log, "pacman", &["-Syu", "--noconfirm"])?;

    let arch_gpu = arch_gpu_packages(&hw);
    if !arch_gpu.is_empty() {
        emit_progress(
            30,
            "Garantindo pilha gráfica Arch/Mocha para GPU não-NVIDIA",
        );
        let mut args = vec![
            "-S".to_string(),
            "--needed".to_string(),
            "--noconfirm".to_string(),
        ];
        args.extend(arch_gpu.into_iter().map(|s| s.to_string()));
        run_checked_owned(&mut log, "pacman", &args)?;
    }

    emit_progress(38, "Importando chave CachyOS somente para esta transação");
    run_checked(
        &mut log,
        "pacman-key",
        &[
            "--recv-keys",
            CACHY_KEY,
            "--keyserver",
            "keyserver.ubuntu.com",
        ],
    )?;
    run_checked(&mut log, "pacman-key", &["--lsign-key", CACHY_KEY])?;

    emit_progress(44, "Criando pacman.conf temporário restrito");
    write_temp_pacman_conf(&hw.tier, &mut log)?;

    emit_progress(50, "Sincronizando bases temporárias CachyOS");
    run_checked(
        &mut log,
        "pacman",
        &["--config", TEMP_PACMAN_CONF, "-Syy", "--noconfirm"],
    )?;

    let cachy_pkgs = cachy_packages(&hw);
    log_line(
        &mut log,
        &format!(
            "Pacotes CachyOS explicitamente permitidos: {:?}",
            cachy_pkgs
        ),
    );

    if reinstall {
        emit_progress(60, "Reinstalando kernel CachyOS e driver casado");
    } else {
        emit_progress(60, "Instalando kernel CachyOS e driver casado");
    }

    let mut args = vec![
        "--config".to_string(),
        TEMP_PACMAN_CONF.to_string(),
        "-S".to_string(),
        "--noconfirm".to_string(),
    ];

    if !reinstall {
        args.push("--needed".to_string());
    }

    args.extend(cachy_pkgs);
    run_checked_owned(&mut log, "pacman", &args)?;

    emit_progress(78, "Regerando initramfs");
    run_checked(&mut log, "mkinitcpio", &["-P"])?;

    emit_progress(
        86,
        "Configurando GRUB para linux-cachyos quando GRUB existir",
    );
    configure_grub_default(&mut log)?;

    emit_progress(94, "Limpando canal CachyOS temporário");
    cleanup_cachy_channel(&mut log)?;

    emit_progress(98, "Validando ausência de canal CachyOS permanente");
    verify_no_cachy_repo_left(&mut log)?;

    let final_status = stack_status(&hw);
    log_line(&mut log, &format!("Status final: {final_status:#?}"));

    if !final_status.installed {
        return Err(format!(
            "após a instalação ainda faltam pacotes: {}",
            final_status.missing_packages.join(", ")
        ));
    }

    fs::write(DONE_MARKER, "done\n")
        .map_err(|e| format!("falha gravando marcador {DONE_MARKER}: {e}"))?;

    emit_progress(100, "Concluído. Reinicie para usar o kernel CachyOS");
    log_line(&mut log, "Mocha Stack Optimizer — concluído com sucesso");
    Ok(())
}

fn detect_hardware() -> Hardware {
    let cpuinfo = fs::read_to_string("/proc/cpuinfo").unwrap_or_default();

    let cpu_model = cpuinfo
        .lines()
        .find_map(|l| {
            l.strip_prefix("model name")
                .and_then(|x| x.split_once(':').map(|(_, v)| v.trim().to_string()))
        })
        .unwrap_or_else(|| "CPU não identificada".to_string());

    let cpu_vendor = cpuinfo
        .lines()
        .find_map(|l| {
            l.strip_prefix("vendor_id")
                .and_then(|x| x.split_once(':').map(|(_, v)| v.trim().to_string()))
        })
        .unwrap_or_else(|| "vendor desconhecido".to_string());

    let lspci = command_text("lspci", &["-nn"]);
    let gpu_summary = lspci
        .lines()
        .filter(|l| {
            let ll = l.to_lowercase();
            ll.contains("vga compatible controller")
                || ll.contains("3d controller")
                || ll.contains("display controller")
        })
        .map(|s| s.trim().to_string())
        .collect::<Vec<_>>()
        .join(" | ");

    let gpu_summary = if gpu_summary.is_empty() {
        "GPU não identificada por lspci".to_string()
    } else {
        gpu_summary
    };

    let gpu_kind = detect_gpu_kind(&gpu_summary);
    let tier = detect_tier(&cpuinfo, &cpu_model, &cpu_vendor);

    Hardware {
        cpu_model,
        cpu_vendor,
        gpu_summary,
        gpu_kind,
        tier,
    }
}

fn detect_tier(cpuinfo: &str, cpu_model: &str, cpu_vendor: &str) -> Tier {
    let ld = command_text("/lib/ld-linux-x86-64.so.2", &["--help"]);
    let supports_v4 = ld.contains("x86-64-v4 (supported, searched)");
    let supports_v3 = ld.contains("x86-64-v3 (supported, searched)");
    let is_amd = cpu_vendor.contains("AuthenticAMD") || cpuinfo.contains("AuthenticAMD");

    if is_amd && supports_v4 && looks_zen4_or_newer(cpu_model) {
        return Tier {
            label: "AMD Zen4/Zen5 — cachyos-znver4",
            repo: "cachyos-znver4",
            arch_path: "x86_64_v4",
        };
    }

    if supports_v4 {
        return Tier {
            label: "x86-64-v4 — cachyos-v4",
            repo: "cachyos-v4",
            arch_path: "x86_64_v4",
        };
    }

    if supports_v3 {
        return Tier {
            label: "x86-64-v3 — cachyos-v3",
            repo: "cachyos-v3",
            arch_path: "x86_64_v3",
        };
    }

    Tier {
        label: "x86-64 genérico — cachyos",
        repo: "cachyos",
        arch_path: "x86_64",
    }
}

fn looks_zen4_or_newer(model: &str) -> bool {
    let lower = model.to_lowercase();

    if lower.contains("epyc 9")
        || lower.contains("zen 4")
        || lower.contains("zen4")
        || lower.contains("zen 5")
        || lower.contains("zen5")
    {
        return true;
    }

    if lower.contains("ryzen") {
        for token in lower.split(|c: char| !c.is_ascii_alphanumeric()) {
            let digits: String = token.chars().filter(|c| c.is_ascii_digit()).collect();
            if digits.len() >= 4 {
                if let Ok(n) = digits[..4].parse::<u32>() {
                    if n >= 7000 {
                        return true;
                    }
                }
            }
        }
    }

    false
}

fn detect_gpu_kind(summary: &str) -> GpuKind {
    let s = summary.to_lowercase();

    if s.contains("nvidia") {
        let legacy_markers = [
            "gtx 10",
            "gtx 9",
            "gtx 8",
            "gtx 7",
            "gtx 6",
            "gtx 5",
            "gtx 4",
            "geforce 10",
            "geforce 9",
            "geforce 8",
            "geforce 7",
            "quadro k",
            "quadro m",
            "tesla k",
            "tesla m",
        ];

        if legacy_markers.iter().any(|m| s.contains(m)) {
            return GpuKind::NvidiaLegacy;
        }

        return GpuKind::NvidiaOpen;
    }

    if s.contains("amd") || s.contains("advanced micro devices") || s.contains("radeon") {
        return GpuKind::Amd;
    }

    if s.contains("intel") {
        return GpuKind::Intel;
    }

    GpuKind::Unknown
}

fn stack_status(hw: &Hardware) -> StackStatus {
    let desired = package_names_only(&cachy_packages(hw));
    let missing = desired
        .iter()
        .filter(|pkg| !package_installed(pkg))
        .cloned()
        .collect::<Vec<_>>();

    StackStatus {
        installed: missing.is_empty(),
        desired_packages: desired,
        missing_packages: missing,
    }
}

fn package_names_only(pkgs: &[String]) -> Vec<String> {
    pkgs.iter()
        .map(|p| {
            if let Some((_, name)) = p.split_once('/') {
                name.to_string()
            } else {
                p.to_string()
            }
        })
        .collect()
}

fn package_installed(pkg: &str) -> bool {
    Command::new("pacman")
        .arg("-Q")
        .arg(pkg)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn cachy_packages(hw: &Hardware) -> Vec<String> {
    let repo = hw.tier.repo;
    let mut pkgs = vec![
        format!("{repo}/linux-cachyos"),
        format!("{repo}/linux-cachyos-headers"),
    ];

    match hw.gpu_kind {
        GpuKind::NvidiaOpen => {
            pkgs.push(format!("{repo}/linux-cachyos-nvidia-open"));
            pkgs.push("cachyos/nvidia-utils".to_string());
            pkgs.push("cachyos/lib32-nvidia-utils".to_string());
            pkgs.push("cachyos/opencl-nvidia".to_string());
        }
        GpuKind::NvidiaLegacy => {
            pkgs.push(format!("{repo}/linux-cachyos-nvidia"));
            pkgs.push("cachyos/nvidia-utils".to_string());
            pkgs.push("cachyos/lib32-nvidia-utils".to_string());
            pkgs.push("cachyos/opencl-nvidia".to_string());
        }
        _ => {}
    }

    pkgs
}

fn arch_gpu_packages(hw: &Hardware) -> Vec<&'static str> {
    match hw.gpu_kind {
        GpuKind::Amd => vec![
            "mesa",
            "lib32-mesa",
            "vulkan-radeon",
            "lib32-vulkan-radeon",
            "libva-mesa-driver",
            "mesa-vdpau",
            "lib32-mesa-vdpau",
        ],
        GpuKind::Intel => vec![
            "mesa",
            "lib32-mesa",
            "vulkan-intel",
            "lib32-vulkan-intel",
            "intel-media-driver",
        ],
        _ => vec![],
    }
}

fn write_temp_pacman_conf(tier: &Tier, log: &mut File) -> Result<(), String> {
    let original = fs::read_to_string("/etc/pacman.conf")
        .map_err(|e| format!("falha lendo /etc/pacman.conf: {e}"))?;

    let mut out = original;
    out.push_str("\n\n# Mocha firstboot: CachyOS temporário, não persistente.\n");
    out.push_str("# Usado somente por --config /tmp/mocha-firstboot-pacman-cachy.conf.\n");

    if tier.repo == "cachyos" {
        out.push_str(
            "\n[cachyos]\n\
             Server = https://cdn77.cachyos.org/repo/x86_64/$repo\n\
             Server = https://mirror.cachyos.org/repo/x86_64/$repo\n",
        );
    } else {
        out.push_str(&format!(
            "\n[{repo}]\n\
             Server = https://cdn77.cachyos.org/repo/{arch}/$repo\n\
             Server = https://mirror.cachyos.org/repo/{arch}/$repo\n",
            repo = tier.repo,
            arch = tier.arch_path
        ));

        out.push_str(
            "\n[cachyos]\n\
             Server = https://cdn77.cachyos.org/repo/x86_64/$repo\n\
             Server = https://mirror.cachyos.org/repo/x86_64/$repo\n",
        );
    }

    fs::write(TEMP_PACMAN_CONF, out)
        .map_err(|e| format!("falha escrevendo {TEMP_PACMAN_CONF}: {e}"))?;

    log_line(
        log,
        &format!("pacman.conf temporário gravado em {TEMP_PACMAN_CONF}"),
    );
    Ok(())
}

fn scrub_cachy_repos_from_pacman_conf(log: &mut File) -> Result<(), String> {
    let path = "/etc/pacman.conf";
    let original = fs::read_to_string(path).map_err(|e| format!("falha lendo {path}: {e}"))?;

    let mut out = Vec::new();
    let mut skip = false;
    let mut changed = false;

    for line in original.lines() {
        let trimmed = line.trim();

        if trimmed.starts_with('[') && trimmed.ends_with(']') {
            let name = trimmed.trim_start_matches('[').trim_end_matches(']');
            skip = name.starts_with("cachyos");
            if skip {
                changed = true;
                continue;
            }
        }

        if !skip {
            out.push(line);
        } else {
            changed = true;
        }
    }

    if changed {
        let backup = format!("{path}.mocha-firstboot-bak-{}", std::process::id());
        fs::copy(path, &backup).map_err(|e| format!("falha criando backup {backup}: {e}"))?;
        fs::write(path, format!("{}\n", out.join("\n")))
            .map_err(|e| format!("falha limpando blocos CachyOS de {path}: {e}"))?;
        log_line(
            log,
            &format!("blocos CachyOS removidos de {path}; backup: {backup}"),
        );
    } else {
        log_line(
            log,
            "nenhum bloco CachyOS permanente encontrado em /etc/pacman.conf",
        );
    }

    Ok(())
}

fn cleanup_cachy_channel(log: &mut File) -> Result<(), String> {
    let _ = fs::remove_file(TEMP_PACMAN_CONF);
    scrub_cachy_repos_from_pacman_conf(log)?;
    remove_cachy_sync_dbs(log)?;
    try_run(log, "pacman-key", &["--delete", CACHY_KEY]);
    run_checked(log, "pacman", &["-Syy", "--noconfirm"])?;
    Ok(())
}

fn verify_no_cachy_repo_left(log: &mut File) -> Result<(), String> {
    let conf = fs::read_to_string("/etc/pacman.conf")
        .map_err(|e| format!("falha lendo /etc/pacman.conf para validação: {e}"))?;

    for line in conf.lines() {
        let t = line.trim();
        if t.starts_with("[cachyos") {
            return Err(format!(
                "canal CachyOS permanente ainda presente em /etc/pacman.conf: {t}"
            ));
        }
    }

    log_line(
        log,
        "validação OK: sem canal CachyOS permanente em /etc/pacman.conf",
    );
    Ok(())
}

fn remove_cachy_sync_dbs(log: &mut File) -> Result<(), String> {
    let sync = Path::new("/var/lib/pacman/sync");
    if !sync.is_dir() {
        return Ok(());
    }

    for entry in fs::read_dir(sync).map_err(|e| format!("falha lendo sync db: {e}"))? {
        let entry = entry.map_err(|e| format!("falha lendo entrada sync db: {e}"))?;
        let name = entry.file_name().to_string_lossy().to_string();
        if name.starts_with("cachyos") {
            let p = entry.path();
            fs::remove_file(&p).map_err(|e| format!("falha removendo {:?}: {e}", p))?;
            log_line(log, &format!("sync db CachyOS removida: {name}"));
        }
    }

    Ok(())
}

fn configure_grub_default(log: &mut File) -> Result<(), String> {
    if !Path::new("/boot/grub/grub.cfg").exists() || !has_cmd("grub-mkconfig") {
        log_line(log, "GRUB não detectado; bootloader não alterado.");
        return Ok(());
    }

    run_checked(log, "grub-mkconfig", &["-o", "/boot/grub/grub.cfg"])?;

    let grub_cfg = fs::read_to_string("/boot/grub/grub.cfg")
        .map_err(|e| format!("falha lendo /boot/grub/grub.cfg: {e}"))?;

    let entry = find_linux_cachyos_grub_entry(&grub_cfg)
        .ok_or_else(|| "não encontrei menuentry linux-cachyos no grub.cfg".to_string())?;

    ensure_grub_default_saved(log)?;

    if !Path::new("/boot/grub/grubenv").exists() && has_cmd("grub-editenv") {
        try_run(log, "grub-editenv", &["/boot/grub/grubenv", "create"]);
    }

    run_checked_owned(log, "grub-set-default", &[entry.clone()])?;
    log_line(log, &format!("GRUB default definido para: {entry}"));

    Ok(())
}

fn find_linux_cachyos_grub_entry(cfg: &str) -> Option<String> {
    let mut submenu: Option<String> = None;

    for raw in cfg.lines() {
        let line = raw.trim_start();

        if line.starts_with("submenu ") {
            if let Some(title) = single_quoted_title(line) {
                submenu = Some(title);
            }
        }

        if line.starts_with("menuentry ") {
            if let Some(title) = single_quoted_title(line) {
                if title.contains("linux-cachyos") || title.contains("Linux linux-cachyos") {
                    return Some(match submenu.clone() {
                        Some(s) => format!("{s}>{title}"),
                        None => title,
                    });
                }
            }
        }
    }

    None
}

fn single_quoted_title(line: &str) -> Option<String> {
    let start = line.find('\'')?;
    let rest = &line[start + 1..];
    let end = rest.find('\'')?;
    Some(rest[..end].to_string())
}

fn ensure_grub_default_saved(log: &mut File) -> Result<(), String> {
    let path = "/etc/default/grub";
    if !Path::new(path).exists() {
        return Ok(());
    }

    let original = fs::read_to_string(path).map_err(|e| format!("falha lendo {path}: {e}"))?;
    let mut found = false;
    let mut changed = false;
    let mut out = Vec::new();

    for line in original.lines() {
        if line.trim_start().starts_with("GRUB_DEFAULT=") {
            found = true;
            if line.trim() != "GRUB_DEFAULT=saved" {
                out.push("GRUB_DEFAULT=saved".to_string());
                changed = true;
            } else {
                out.push(line.to_string());
            }
        } else {
            out.push(line.to_string());
        }
    }

    if !found {
        out.push("GRUB_DEFAULT=saved".to_string());
        changed = true;
    }

    if changed {
        let backup = format!("{path}.mocha-firstboot-bak-{}", std::process::id());
        fs::copy(path, &backup).map_err(|e| format!("falha criando backup {backup}: {e}"))?;
        fs::write(path, format!("{}\n", out.join("\n")))
            .map_err(|e| format!("falha ajustando {path}: {e}"))?;
        log_line(
            log,
            &format!("GRUB_DEFAULT=saved aplicado; backup: {backup}"),
        );
    }

    Ok(())
}

fn is_root() -> bool {
    command_text("id", &["-u"]).trim() == "0"
}

fn has_cmd(cmd: &str) -> bool {
    Command::new("sh")
        .arg("-c")
        .arg(format!("command -v {cmd} >/dev/null 2>&1"))
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn command_text(program: &str, args: &[&str]) -> String {
    Command::new(program)
        .args(args)
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).to_string())
        .unwrap_or_default()
}

fn emit_progress(percent: u8, msg: &str) {
    println!("MOCHA_PROGRESS|{}|{}", percent.min(100), msg);
}

fn log_line(log: &mut File, msg: &str) {
    let _ = writeln!(log, "{msg}");
    let _ = log.flush();
}

fn run_checked(log: &mut File, program: &str, args: &[&str]) -> Result<(), String> {
    let owned: Vec<String> = args.iter().map(|s| s.to_string()).collect();
    run_checked_owned(log, program, &owned)
}

fn run_checked_owned(log: &mut File, program: &str, args: &[String]) -> Result<(), String> {
    let cmdline = format!("{} {}", program, args.join(" "));
    log_line(log, &format!("+ {cmdline}"));

    let output = Command::new(program)
        .args(args)
        .output()
        .map_err(|e| format!("falha executando {cmdline}: {e}"))?;

    if !output.stdout.is_empty() {
        let s = String::from_utf8_lossy(&output.stdout);
        for line in s.lines() {
            log_line(log, line);
        }
    }

    if !output.stderr.is_empty() {
        let s = String::from_utf8_lossy(&output.stderr);
        for line in s.lines() {
            log_line(log, line);
        }
    }

    if output.status.success() {
        Ok(())
    } else {
        Err(format!("comando falhou: {cmdline}"))
    }
}

fn try_run(log: &mut File, program: &str, args: &[&str]) {
    match run_checked(log, program, args) {
        Ok(()) => {}
        Err(e) => log_line(log, &format!("AVISO ignorado: {e}")),
    }
}
```

#### `assets/mocha-firstboot-stack.svg`

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
  <defs>
    <linearGradient id="bg" x1="34" y1="20" x2="222" y2="236" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#2a1712"/>
      <stop offset="0.45" stop-color="#120b0a"/>
      <stop offset="1" stop-color="#070606"/>
    </linearGradient>
    <linearGradient id="copper" x1="67" y1="39" x2="190" y2="216" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#ffbf78"/>
      <stop offset="0.24" stop-color="#b96a35"/>
      <stop offset="0.52" stop-color="#6f351f"/>
      <stop offset="0.78" stop-color="#d18449"/>
      <stop offset="1" stop-color="#3c1c14"/>
    </linearGradient>
    <radialGradient id="glow" cx="128" cy="106" r="110" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#d87c3f" stop-opacity="0.48"/>
      <stop offset="0.55" stop-color="#8c4328" stop-opacity="0.18"/>
      <stop offset="1" stop-color="#000000" stop-opacity="0"/>
    </radialGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="8" stdDeviation="8" flood-color="#000000" flood-opacity="0.65"/>
    </filter>
  </defs>
  <rect width="256" height="256" rx="52" fill="url(#bg)"/>
  <rect x="9" y="9" width="238" height="238" rx="45" fill="none" stroke="#5a2a1d" stroke-width="2"/>
  <circle cx="128" cy="118" r="110" fill="url(#glow)"/>
  <path d="M70 56h64c38 0 66 28 66 72s-28 72-66 72H70V56zm41 37v70h20c19 0 30-14 30-35s-11-35-30-35h-20z" fill="url(#copper)" filter="url(#shadow)"/>
  <path d="M70 56h64c38 0 66 28 66 72s-28 72-66 72H70V56zm41 37v70h20c19 0 30-14 30-35s-11-35-30-35h-20z" fill="none" stroke="#f2b070" stroke-opacity="0.42" stroke-width="2"/>
  <path d="M55 211h146" stroke="#b66a3d" stroke-width="5" stroke-linecap="round" opacity="0.7"/>
  <path d="M93 224h70" stroke="#ffbd7d" stroke-width="3" stroke-linecap="round" opacity="0.42"/>
</svg>
```

#### `assets/mocha-firstboot-stack.desktop`

```ini
[Desktop Entry]
Type=Application
Version=1.5
Name=Mocha Stack Optimizer
Name[pt_BR]=Otimizador de Stack Mocha
GenericName=Mocha Hardware Stack Tool
GenericName[pt_BR]=Ferramenta de Stack de Hardware Mocha
Comment=Atualiza o sistema e instala kernel CachyOS com driver de vídeo casado, sem manter canal CachyOS
Comment[pt_BR]=Atualiza o sistema e instala kernel CachyOS com driver de vídeo casado, sem manter canal CachyOS
Exec=/usr/bin/mocha-firstboot-stack
Icon=mocha-firstboot-stack
Terminal=false
StartupNotify=true
Categories=Utility;System;Settings;
Keywords=Mocha;Kernel;CachyOS;NVIDIA;Driver;Hardware;Ferramentas;Sistema;
X-KDE-SubstituteUID=false
```

#### `assets/mocha-firstboot-stack-autostart.desktop`

```ini
[Desktop Entry]
Type=Application
Version=1.5
Name=Mocha Stack Optimizer
Name[pt_BR]=Otimizador de Stack Mocha
Comment=Verifica stack de hardware Mocha no login
Comment[pt_BR]=Verifica stack de hardware Mocha no login
Exec=/usr/bin/mocha-firstboot-stack --autostart
Icon=mocha-firstboot-stack
Terminal=false
StartupNotify=false
Categories=Utility;System;Settings;
X-KDE-autostart-after=panel
X-GNOME-Autostart-enabled=true
OnlyShowIn=KDE;
```

#### `assets/org.mocha.firstboot.stack.policy`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/PolicyKit-1.0.dtd">
<policyconfig>
  <vendor>Mocha</vendor>
  <vendor_url>https://dieseloslab.github.io</vendor_url>

  <action id="org.mocha.firstboot.stack.worker">
    <description>Run Mocha first boot stack optimizer</description>
    <description xml:lang="pt_BR">Executar otimizador de stack do primeiro boot Mocha</description>
    <message>Authentication is required to install or reinstall the Mocha kernel and video driver stack.</message>
    <message xml:lang="pt_BR">Autenticação necessária para instalar ou reinstalar o kernel e o driver de vídeo do Mocha.</message>
    <icon_name>mocha-firstboot-stack</icon_name>

    <defaults>
      <allow_any>auth_admin</allow_any>
      <allow_inactive>auth_admin</allow_inactive>
      <allow_active>auth_admin_keep</allow_active>
    </defaults>

    <annotate key="org.freedesktop.policykit.exec.path">/usr/bin/mocha-firstboot-stack</annotate>
    <annotate key="org.freedesktop.policykit.exec.argv1">--worker</annotate>
  </action>
</policyconfig>
```

#### `README.md`

```markdown
# Mocha Firstboot Stack

Programa Rust de primeiro boot para sistema instalado MochaArch.

## Função

1. Abre assistente KDE após login.
2. Remove qualquer canal CachyOS permanente antes de atualizar.
3. Atualiza totalmente o sistema usando Arch/Mocha.
4. Detecta CPU/GPU.
5. Usa `pacman --config /tmp/mocha-firstboot-pacman-cachy.conf` para baixar somente kernel/headers/driver de vídeo casado do CachyOS.
6. Regera initramfs.
7. Configura GRUB para `linux-cachyos`.
8. Remove canal CachyOS temporário e apaga bases sync Cachy.
9. Marca `/var/lib/mocha-firstboot-stack/done`.

## Dependências de runtime recomendadas na ISO

- kdialog
- qt6-tools ou pacote que forneça qdbus6/qdbus
- polkit-kde-agent
- pciutils
- grub
- mkinitcpio

## Política de não contaminação

O app não executa `cachyos-repo.sh`, não deixa `[cachyos]` em `/etc/pacman.conf` e não faz `pacman -Syu` com repositório CachyOS ativo.
```

<!-- MOCHA-FIRSTBOOT-STACK-END -->


<!-- MOCHA:AGRESSIVIDADE_V3_CANDIDATA:START -->

## Receita V3 de agressividade — candidata à canonização

Status: candidata à canonização.
Data de registro: 2026-06-12 08:32:34 -03
Escopo: MochaArch Gamer/Laboratório.

### Objetivo

Manter o sistema agressivo para uso gamer, com ZRAM como swap principal, swap em disco apenas como fallback de baixa prioridade e zswap ativo com impacto controlado.

### Decisão técnica

- ZRAM permanece como camada principal de swap.
- ZRAM deve usar zstd.
- ZRAM deve ter tamanho equivalente à RAM física.
- ZRAM deve ter prioridade 32767.
- Swap em disco deve existir apenas como fallback, com prioridade baixa.
- zswap deve permanecer ativo.
- zswap não deve ser tratado como falha nem aviso por estar ativo.
- zswap não possui prioridade própria exibida por swapon; a prioridade baixa é aplicada ao backend de swap em disco.
- O impacto do zswap deve ser limitado por pool baixo.

### Valores V3

- vm.swappiness = 133
- vm.vfs_cache_pressure = 50
- vm.page-cluster = 0
- vm.dirty_background_bytes = 67108864
- vm.dirty_bytes = 268435456
- vm.max_map_count = 16777216
- THP enabled = madvise
- THP defrag = defer+madvise
- ZRAM compression-algorithm = zstd
- ZRAM zram-size = ram
- ZRAM swap-priority = 32767
- Swap em disco/fallback = pri=-100
- zswap enabled = Y
- zswap compressor = zstd
- zswap zpool = zsmalloc
- zswap max_pool_percent = 5
- zswap accept_threshold_percent = 90

### Arquivos persistentes esperados

- /etc/sysctl.d/99-mocha-agressividade-v3.conf
- /etc/tmpfiles.d/99-mocha-thp-v3.conf
- /etc/systemd/zram-generator.conf.d/99-mocha.conf
- /etc/modprobe.d/99-mocha-zswap-baixo.conf
- /etc/systemd/system/mocha-zswap-baixo.service
- /etc/fstab, com swap não-ZRAM usando pri=-100

### Regra operacional importante

Não tentar instalar cegamente pacote chamado systemd-zram-generator. Se o pacote não existir no repositório ativo, o comando não pode abortar. A receita deve escrever a configuração de ZRAM, detectar se o gerador/unidade já existe e deixar a auditoria runtime decidir o estado real.

### Critério de aprovação

A receita V3 candidata é considerada em uso quando:

- sysctl bate com os valores V3.
- THP está em madvise e defer+madvise.
- /dev/zram0 aparece em swapon.
- /dev/zram0 usa prioridade 32767.
- /dev/zram0 usa zstd.
- /dev/zram0 tem tamanho compatível com a RAM física.
- swap em disco existe somente com prioridade baixa.
- zswap está ativo.
- zswap está limitado por max_pool_percent baixo.
- tuned.service está ativo.
- TuneD usa o perfil mocha-latency-performance.

### Comando operacional associado

Nome da receita operacional candidata: MOCHA_AGRESSIVIDADE_V3_ZSWAP_CORRIGIDO_V2.

Essa versão substitui a tentativa anterior que falhava ao instalar systemd-zram-generator e substitui a auditoria que classificava zswap ativo como aviso.

### Observação para canonização

Antes de canonizar, validar após reboot: swapon, zswap, THP, sysctl, TuneD e persistência do fstab. Se os valores permanecerem iguais após reboot, a receita pode ser promovida de candidata para canônica.

<!-- MOCHA:AGRESSIVIDADE_V3_CANDIDATA:END -->

## Correção registrada — pacman CachyOS v3 Architecture

- Data: 2026-06-13 15:00:34
- Erro: package architecture is not valid em pacotes x86_64_v3.
- Causa: pacman.conf temporário com Architecture = auto.
- Correção: usar Architecture = x86_64 x86_64_v3.
- Especificação: /media/mochafast/MochaArch/ativo/ferramentas/CORRECAO-CANONICA-PACMAN-CACHYOS-V3-ARCHITECTURE.md

<!-- MOCHA_RECEITA_AGRESSIVIDADE_FPS_V4_INICIO -->

## Receita padrão Mocha — agressividade/FPS V4

**Estado canônico atual:** usar estes valores como padrão para jogos/Steam/Proton no MochaArch.

### Memória, zram, swap e THP

| Item | Valor padrão |
|---|---:|
| `vm.swappiness` | `133` |
| `vm.vfs_cache_pressure` | `50` |
| `vm.page-cluster` | `0` |
| `vm.dirty_background_bytes` | `67108864` |
| `vm.dirty_bytes` | `268435456` |
| `vm.max_map_count` | `8388608` |
| `kernel.sched_autogroup_enabled` | `1` |
| zram | `zstd`, tamanho aproximado de 100% da RAM, prioridade `32767` |
| swap em disco | prioridade baixa, padrão `-1` |
| THP | `madvise` |
| THP defrag | `defer+madvise` |

### CPU e energia

| Item | Valor padrão |
|---|---|
| Driver CPU | `amd-pstate-epp`, quando disponível |
| Governor | `performance` |
| EPP | `performance` |
| Boost CPU | ligado, `1` |
| TuneD | `mocha-latency-performance` |
| Serviços conflitantes | `power-profiles-daemon`, `tlp`, `auto-cpufreq`, `thermald` não devem comandar o perfil gamer |

### NVIDIA

| Item | Valor padrão |
|---|---:|
| `GPUPowerMizerMode` durante jogos | `1` |
| Significado | `Prefer Maximum Performance` |
| Local preferencial de aplicação | GameMode e wrapper Steam Mocha |
| Política | não fazer overclock por padrão; apenas impedir modo adaptativo durante jogo |

### GameMode agressivo

Arquivo padrão: `/etc/gamemode.ini`.

~~~ini
[general]
reaper_freq=5
desiredgov=performance
desiredprof=performance
softrealtime=off
renice=10
ioprio=0
inhibit_screensaver=1
disable_splitlock=1

[gpu]
nv_powermizer_mode=1

[cpu]
park_cores=no
pin_cores=no
~~~

### sysctl padrão

Arquivo padrão: `/etc/sysctl.d/99-mocha-agressividade-fps.conf`.

~~~conf
vm.swappiness = 133
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.max_map_count = 8388608
kernel.sched_autogroup_enabled = 1
~~~

### Wrapper Steam Mocha

O wrapper canônico deve continuar usando:

~~~text
/home/hal/.local/bin/mocha-steam-game-run %command%
~~~

Durante o jogo, o wrapper/GameMode deve garantir:

~~~bash
nvidia-settings -a '[gpu:0]/GPUPowerMizerMode=1'
~~~

### Observações

- `vm.max_map_count=8388608` é valor alto controlado para Proton/Wine/jogos grandes.
- Esse valor não é ajuste direto de FPS; é folga para mapeamentos de memória.
- Ganho de FPS esperado vem principalmente de GPU em `GPUPowerMizerMode=1`, CPU/EPP em `performance` e GameMode agressivo.
- Se `gamemoded -s` mostrar inativo com o jogo fechado, é normal.
- Se `gamemoded -s` mostrar inativo com o jogo aberto via Steam, revisar wrapper/Launch Options.
- Se FPS continuar inferior após estes padrões, próximo suspeito é Proton Experimental, KWin/compositor ou regressão específica de Mesa/NVIDIA/jogo.

<!-- MOCHA_RECEITA_AGRESSIVIDADE_FPS_V4_FIM -->

## POLÍTICA PERMANENTE — LIMPEZA DE ISOS

<!-- MOCHA_STEAM_WRAPPER_ATALHO_MANGOHUD_CANONICO_V2_BEGIN -->

## Regra canônica — Steam Mocha, wrapper, atalho e MangoHud

Status: canônico e prevalente desde 2026-06-19.

Esta seção revoga qualquer instrução anterior ou conflitante sobre wrapper Steam, atalho Steam, MangoHud, vkBasalt, gamescope, MANGOHUD_DLSYM ou correção de input após Alt+Tab.

### Arquivos canônicos

Wrapper de jogos Steam/Proton:

    /home/hal/.local/bin/mocha-steam-game-run

Lançador global da Steam com ambiente Mocha:

    /home/hal/.local/bin/mocha-steam

Copiador da launch option canônica:

    /home/hal/.local/bin/mocha-copy-steam-launch-option

Configuração MangoHud Mocha:

    /home/hal/.config/MangoHud/MangoHud.conf

Configuração Mocha da Steam:

    /home/hal/.config/mocha/steam.conf
    /home/hal/.config/mocha/steam-launch-option.txt

Atalho do menu:

    /home/hal/.local/share/applications/mocha-steam.desktop

Cópia canônica no repositório ativo:

    /media/mochafast/MochaArch/ativo/assets/mocha-steam/

Estrutura para futura instalação:

    /media/mochafast/MochaArch/ativo/etc/skel/

### Launch option canônica por jogo

A linha obrigatória nas launch options dos jogos Steam/Proton é:

    /home/hal/.local/bin/mocha-steam-game-run %command%

Regra importante:
O placeholder %command% só é interpretado pela Steam dentro das launch options de cada jogo. Ele não funciona como substituto global dentro de um atalho .desktop da Steam.

Portanto:
- O atalho Steam Mocha abre a Steam com ambiente Mocha.
- A launch option canônica continua sendo configurada por jogo.
- O arquivo steam-launch-option.txt mantém a linha salva para cópia rápida.

### Variáveis obrigatórias do wrapper

O wrapper canônico deve exportar:

    SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
    WINE_MOUSE_WARP_OVERRIDE=force
    MANGOHUD=1

Se existir configuração MangoHud do usuário, o wrapper deve usar:

    MANGOHUD_CONFIGFILE=/home/hal/.config/MangoHud/MangoHud.conf

### Correção obrigatória nos prefixes Proton/Wine

Cada prefix Proton/Wine deve receber, quando aplicável:

    [Software\\Wine\\DirectInput]
    "MouseWarpOverride"="force"

    [Software\\Wine\\X11 Driver]
    "UseTakeFocus"="N"
    "GrabFullscreen"="Y"

Objetivo:
Reduzir perda de input, mouse, mira ou foco após Alt+Tab em jogos Proton/Steam.

### GameMode

O wrapper deve usar gamemoderun quando disponível.

Regra:
Se gamemoderun existir e MOCHA_NO_GAMEMODE não estiver definido como 1, o jogo deve ser executado por gamemoderun.

### MangoHud

MangoHud é canônico no perfil Mocha e deve ser ativado por variável:

    MANGOHUD=1

O wrapper não deve injetar o comando mangohud no argv do jogo. Isso evita quebrar launchers, jogos sensíveis e comandos Steam com %command%.

A configuração canônica fica em:

    /home/hal/.config/MangoHud/MangoHud.conf

### Proibições no wrapper canônico

O wrapper canônico deve permanecer limpo.

É proibido colocar no wrapper base:

    vkBasalt
    gamescope
    MANGOHUD_DLSYM

Esses recursos são opcionais e devem ficar fora do wrapper canônico. Se forem testados, devem ser ativados por configuração separada, por jogo ou por perfil experimental, nunca no wrapper base do Mocha.

### Atalho Steam Mocha

O atalho correto é:

    Steam Mocha

Ele deve executar:

    /home/hal/.local/bin/mocha-steam

Função do atalho:
- abrir a Steam com ambiente Mocha;
- ativar variáveis globais úteis;
- manter a launch option canônica salva;
- copiar a launch option quando houver wl-copy/xclip disponível.

Função que o atalho não tem:
- substituir automaticamente a launch option de cada jogo;
- interpretar %command% globalmente.

### Regra para instalação futura

Toda instalação nova do Mocha deve receber estes arquivos a partir do diretório ativo:

    assets/mocha-steam/
    etc/skel/.local/bin/mocha-steam-game-run
    etc/skel/.local/bin/mocha-steam
    etc/skel/.local/bin/mocha-copy-steam-launch-option
    etc/skel/.config/MangoHud/MangoHud.conf
    etc/skel/.config/mocha/steam-launch-option.txt
    etc/skel/.local/share/applications/mocha-steam.desktop

Se o wrapper for corrigido no sistema instalado, a mesma correção deve ser copiada para o diretório ativo antes de commit/push. Caso contrário, a próxima instalação do Mocha perde a correção.

### Regra de precedência

Em caso de conflito com qualquer trecho antigo do manual, prevalece esta seção.

Qualquer instrução anterior que mande:
- usar vkBasalt dentro do wrapper;
- usar gamescope dentro do wrapper;
- usar MANGOHUD_DLSYM no wrapper;
- substituir o wrapper por launch option avulsa;
- colocar mangohud antes de %command%;
- tratar Steam Mocha .desktop como substituto global de %command%;
- aplicar Alt+Tab/input apenas como remendo manual por jogo;

está revogada.

<!-- MOCHA_STEAM_WRAPPER_ATALHO_MANGOHUD_CANONICO_V2_END -->


<!-- MOCHA-ISO-REFERENCIAS-BOOT-GRAFICO-20260620-INICIO -->

## ISO Mocha — regra obrigatória após auditoria EndeavourOS, CachyOS e Calam em 2026-06-20

Esta seção corrige a validação e a receita da ISO instaladora gráfica do Mocha. Ela prevalece sobre qualquer trecho antigo que assuma apenas SDDM clássico, `display-manager.service` comum ou `graphical.target` como prova única de boot gráfico.

### Resultado da auditoria de referência

| ISO | ISO label | rootfs montado | default.target | display-manager | NetworkManager | Calamares | sessão detectada | conclusão |
|---|---|---:|---|---|---:|---:|---|---|
| EndeavourOS Titan-Neo 2026.04.27 | EOS_202604 | sim | `/usr/lib/systemd/system/multi-user.target` | ausente | sim | sim | Plasma Wayland e Plasma X11 | Funciona sem depender de `display-manager.service`; auditar getty/autologin/scripts/autostart. |
| CachyOS desktop 2026.04.26 | COS_202604 | sim | `/usr/lib/systemd/system/graphical.target` | `/usr/lib/systemd/system/plasmalogin.service` | sim | sim | Plasma Wayland | `plasmalogin.service` é mecanismo válido de login gráfico/autologin. |
| Calam-Arch-Installer 2026-06 | ARCH_202606 | não | indisponível | indisponível | indisponível | indisponível | indisponível | A auditoria desta rodada não montou o rootfs; Calam ainda exige auditoria específica corrigida. |
| ArchyOS | não encontrada | não aplicável | não aplicável | não aplicável | não aplicável | não aplicável | não aplicável | Não usar como referência até localizar e auditar. |

### Regras obrigatórias para a próxima ISO Mocha

A próxima ISO Mocha não pode validar boot gráfico/autologin procurando somente SDDM clássico. A validação deve aceitar e auditar explicitamente estes mecanismos:

1. `sddm.service`, quando existir.
2. `plasmalogin.service`, obrigatório como caminho válido por causa do CachyOS.
3. `getty@tty1` com autologin, obrigatório como caminho válido por causa do EndeavourOS.
4. `default.target` pode ser `graphical.target` ou `multi-user.target`, desde que haja mecanismo real que suba a sessão gráfica.
5. NetworkManager precisa estar habilitado por symlink real dentro do rootfs live.
6. Calamares precisa ser validado por binário, arquivo `.desktop`, atalho/autostart, configuração em `/etc/calamares` e permissões sudo/polkit.
7. A validação do bootloader deve ler as linhas reais de `options`, `linux`, `append`, `archisolabel`, `img_dev`, `img_loop`, `cow_label`, `root=` e `LABEL=`.
8. Não reprovar a ISO apenas por ausência de `archisolabel=MOCHA_YYYYMMDD` literal sem antes comparar com o label real da ISO e possíveis placeholders usados pelo archiso.
9. O status `OK` de um script de auditoria significa apenas que o script terminou. Não significa que todas as referências foram auditadas com sucesso. Se algum rootfs não montar, a referência fica incompleta e deve ser marcada como pendente.

### Checklist obrigatório de validação da ISO Mocha

Antes de considerar uma ISO Mocha válida:

- Montar a ISO final somente leitura.
- Detectar o label real da ISO.
- Ler os arquivos reais de bootloader/cmdline.
- Reprovar se ainda aparecer `Arch Linux install medium` em menus/bootloader textuais.
- Validar branding Mocha nos menus reais de boot.
- Validar que o bootloader aponta para label real ou placeholder correto.
- Montar o rootfs live.
- Validar `default.target`.
- Validar pelo menos um mecanismo gráfico/autologin real:
  - `sddm.service`;
  - `plasmalogin.service`;
  - `getty@tty1` com autologin e sessão gráfica;
  - script/autostart de sessão comprovado.
- Validar sessão Plasma Wayland disponível.
- Validar NetworkManager habilitado.
- Validar usuário live sem senha ou com permissões compatíveis com instalador.
- Validar Calamares instalado, configurado, com atalho e com permissão de execução.
- Validar que o Calamares instala o Mocha completo no disco; a ISO live é somente ambiente gráfico de instalação.
- Testar em QEMU com `usb-tablet` e `usb-kbd`.
- Não copiar automaticamente para Ventoy.
- Não apagar a ISO final apenas porque falhou; preservar para teste e auditoria.

### Antídoto contra erro de receita

Não escrever validações do tipo:

- “se não há `display-manager.service`, então não há boot gráfico”;
- “se não há SDDM autologin, então não há autologin”;
- “se `default.target` é `multi-user.target`, então a ISO não é gráfica”;
- “se não há `archisolabel=MOCHA_YYYYMMDD` literal, então o bootloader está errado”.

Essas conclusões são falsas para ISOs de referência funcionais. A receita correta é auditar o mecanismo real, como EndeavourOS e CachyOS fazem.

<!-- MOCHA-ISO-REFERENCIAS-BOOT-GRAFICO-20260620-FIM -->

<!-- MOCHA-RECEITA-ISO-PLANO-B-BOOTOU:INICIO -->

# Receita canônica — ISO Live Plano B Clone que entrou no sistema

Data de consolidação: 2026-06-22.

## Resultado confirmado

Esta foi a primeira receita do Plano B Clone que gerou uma ISO Live Mocha que entrou no sistema.

Sequência que funcionou:

- usar o clone sanitizado já funcional como rootfs;
- não reconstruir a distro inteira com mkarchiso;
- não baixar nem trocar kernel;
- herdar o kernel funcional já presente no clone;
- gerar initramfs Archiso mínimo com mkinitcpio -r "$ROOTFS";
- gerar airootfs.sfs diretamente do clone com mksquashfs;
- criar menu GRUB manual;
- fechar a ISO com grub-mkrescue;
- aplicar autologin somente em runtime da live;
- não aplicar autologin à instalação final.

## Caminhos canônicos

BASE=/media/vmstore/MochaArch
ISO_DIR=/media/vmstore/MochaArch/iso
CLONE_BASE=/media/vmstore/MochaArch/iso/plano-b-clone
CURRENT_LINK=/media/vmstore/MochaArch/iso/plano-b-clone/rootfs-current
BUILD_BASE=/media/vmstore/MochaArch/iso/build
OUT_DIR=/media/vmstore/MochaArch/iso/out
REJEITADOS=/media/vmstore/MochaArch/iso/rejeitados

## Pré-condições

Comandos de validação:

    findmnt -rn /media/vmstore
    test -L /media/vmstore/MochaArch/iso/plano-b-clone/rootfs-current
    ROOTFS="$(sudo readlink -f /media/vmstore/MochaArch/iso/plano-b-clone/rootfs-current)"
    test -d "$ROOTFS/usr/lib/modules"
    test -x "$ROOTFS/usr/bin/calamares"

Não pode haver montagem interna no clone:

    findmnt -R "$ROOTFS"

Se aparecer /proc, /sys, /dev, /run ou bind mount dentro do clone, desmontar antes de compactar.

## Pacotes usados

    sudo pacman -S --needed --noconfirm archiso mkinitcpio grub xorriso mtools dosfstools squashfs-tools cdrtools util-linux

## Kernel

Detectar o kernel no clone:

    KVER="$(sudo find "$ROOTFS/usr/lib/modules" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -V | tail -n1)"

No teste que entrou no sistema:

    KVER=7.0.12-arch1-1
    VMLINUX=/media/vmstore/MochaArch/iso/plano-b-clone/rootfs-20260622-122829/boot/vmlinuz-linux

Regra: aceitar o kernel funcional já presente no clone. Não bloquear por pkgbase=linux. Não instalar LTS. Não trocar kernel nesta etapa.

## Preparação live dentro do clone

O /etc/fstab da live deve ficar vazio de propósito:

    # Mocha Live ISO
    # fstab vazio de propósito: a live usa archiso/overlayfs.

Ativar alvo gráfico e SDDM:

    sudo ln -sfn /usr/lib/systemd/system/graphical.target "$ROOTFS/etc/systemd/system/default.target"
    sudo ln -sfn /usr/lib/systemd/system/sddm.service "$ROOTFS/etc/systemd/system/display-manager.service"

## Autologin somente na live

Autologin é permitido na live, mas não na instalação final.

A solução que funcionou foi criar um serviço runtime que só age quando detecta live ISO pela cmdline:

    case " $(cat /proc/cmdline 2>/dev/null) " in
      *" archisolabel="*|*" archisosearchuuid="*) ;;
      *) exit 0 ;;
    esac

O serviço gera em runtime:

    /etc/sddm.conf.d/10-mocha-live-runtime-autologin.conf

Conteúdo esperado:

    [Autologin]
    User=mocha
    Session=plasma.desktop
    Relogin=true

    [General]
    DisplayServer=wayland

## Estrutura da ISO

Criar:

    isofs/arch/x86_64
    isofs/arch/boot/x86_64
    isofs/boot/grub

Copiar kernel:

    sudo cp -f "$VMLINUX" "$ISO_ROOT/arch/boot/x86_64/vmlinuz-linux"

Criar UUID de busca:

    BOOT_UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
    touch "$ISO_ROOT/boot/$BOOT_UUID.uuid"

## mkinitcpio correto

Config mínima que funcionou:

    MODULES=(loop squashfs overlay isofs vfat nls_cp437 nls_iso8859-1)
    BINARIES=()
    FILES=()
    HOOKS=(base udev microcode modconf kms archiso block filesystems keyboard)
    COMPRESSION="xz"
    COMPRESSION_OPTIONS=(-9e)

Comando:

    sudo mkinitcpio \
      -c "$MKCONF" \
      -r "$ROOTFS" \
      -k "$KVER" \
      -g "$ISO_ROOT/arch/boot/x86_64/initramfs-linux.img" \
      -t "$MKINIT_TMP"

Regras:

    Não usar memdisk.
    Não usar memdiskfind.
    Não usar archiso_pxe.
    Não usar hooks PXE.

## SquashFS correto

Comando que funcionou:

    nice -n 10 ionice -c2 -n7 sudo mksquashfs "$ROOTFS" "$SFS" \
      -noappend \
      -no-recovery \
      -comp xz \
      -b 1M \
      -Xbcj x86 \
      -Xdict-size 100% \
      -processors "$PROCS"

No teste que entrou no sistema, o airootfs.sfs ficou em torno de 3,2 GiB.

Mensagem observada e não fatal:

    Unrecognised xattr prefix system.posix_acl_default

## grub.cfg correto

Parâmetros críticos:

    archisobasedir=arch
    archisolabel=$LABEL
    archisosearchuuid=$BOOT_UUID
    cow_spacesize=1G
    copytoram=n
    systemd.unit=graphical.target

Entrada normal:

    menuentry "Mocha Live - Plasma Wayland" {
      search --no-floppy --label --set=root LABEL_AQUI
      linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=LABEL_AQUI archisosearchuuid=BOOT_UUID_AQUI cow_spacesize=1G copytoram=n systemd.unit=graphical.target loglevel=3 quiet
      initrd /arch/boot/x86_64/initramfs-linux.img
    }

Entrada segura:

    menuentry "Mocha Live - modo seguro" {
      search --no-floppy --label --set=root LABEL_AQUI
      linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=LABEL_AQUI archisosearchuuid=BOOT_UUID_AQUI cow_spacesize=1G copytoram=n systemd.unit=graphical.target nomodeset nouveau.modeset=0 loglevel=4
      initrd /arch/boot/x86_64/initramfs-linux.img
    }

## Erro corrigido no fechamento da ISO

Erro que não pode repetir:

    sudo grub-mkrescue \
      -o "$ISO_PATH" \
      "$ISO_ROOT" \
      -- \
      -volid "$LABEL" \
      -iso-level 3 \
      -full-iso9660-filenames

Sintoma:

    xorriso : FAILURE : Not a known command: '-iso-level'
    xorriso : FAILURE : Not a known command: '3'
    xorriso : FAILURE : Not a known command: '-full-iso9660-filenames'
    grub-mkrescue: error: `xorriso` invocation failed

Correção:

    sudo grub-mkrescue \
      -o "$ISO_PATH" \
      "$ISO_ROOT" \
      -volid "$LABEL" \
      -iso-level 3 \
      -full-iso9660-filenames

Fallback aceitável:

    sudo grub-mkrescue \
      -o "$ISO_PATH" \
      "$ISO_ROOT" \
      -volid "$LABEL"

Regra: não usar -- antes de -volid, -iso-level e -full-iso9660-filenames.

## Regra de resgate

Se o initramfs e o airootfs.sfs já foram criados, não refazer a fase pesada.

Validar build pronto:

    test -s "$ISO_ROOT/arch/x86_64/airootfs.sfs"
    test -s "$ISO_ROOT/arch/boot/x86_64/vmlinuz-linux"
    test -s "$ISO_ROOT/arch/boot/x86_64/initramfs-linux.img"
    test -s "$ISO_ROOT/boot/grub/grub.cfg"

Extrair label:

    LABEL="$(awk 'match($0,/archisolabel=[^ ]+/){print substr($0,RSTART+13,RLENGTH-13); exit}' "$ISO_ROOT/boot/grub/grub.cfg")"

Fechar ISO reaproveitando build:

    sudo grub-mkrescue \
      -o "$ISO_PATH" \
      "$ISO_ROOT" \
      -volid "$LABEL" \
      -iso-level 3 \
      -full-iso9660-filenames

Validar Volume ID:

    VOLID="$(sudo isoinfo -d -i "$ISO_PATH" | awk -F': ' '/^Volume id:/{print $2; exit}')"
    test "$VOLID" = "$LABEL"

Gerar hash:

    sudo sha256sum "$ISO_PATH" | sudo tee "$ISO_PATH.sha256" >/dev/null

## O que não mexer

Não alterar sem motivo técnico confirmado:

- não usar memdiskfind;
- não usar memdisk;
- não usar archiso_pxe;
- não usar hooks PXE;
- não usar -- antes de -volid no grub-mkrescue;
- não baixar kernel LTS;
- não trocar kernel durante a geração;
- não usar mkarchiso para reconstruir a distro inteira;
- não aplicar autologin na instalação final;
- não compactar clone com montagens internas;
- não apagar build pronto se a falha foi só no fechamento da ISO.

## Comandos canônicos

Fase pesada:

    MOCHA_GERA_ISO_PLANO_B_CLONE_V4_MINIMO_SEM_MEMDISK

Fase de resgate quando só o fechamento falhou:

    MOCHA_FECHA_ISO_REAPROVEITA_BUILD_V1

Resumo:

    Se falhou antes do SquashFS: corrigir fase pesada.
    Se falhou depois do SquashFS: reaproveitar build e rodar só o fechamento.

<!-- MOCHA-RECEITA-ISO-PLANO-B-BOOTOU:FIM -->


<!-- MOCHA:STACK-GAMER-CANONICO:BEGIN -->
## Stack gamer canônico do Mocha

Esta seção é canônica para o Mocha gamer final. A live installer-only pode ser menor, mas o sistema instalado deve conter este conjunto ou equivalentes funcionais documentados.

### Launchers, lojas e compatibilidade
- steam
- steam-native-runtime
- steam-devices
- lutris
- heroic-games-launcher-bin ou Flatpak com.heroicgameslauncher.hgl
- bottles via Flatpak com.usebottles.bottles
- legendary
- minigalaxy
- itch ou Flatpak io.itch.itch
- wine-staging
- winetricks
- protontricks
- protonup-qt ou Flatpak net.davidotek.pupgui2
- protonplus ou Flatpak com.vysp3r.ProtonPlus
- umu-launcher

### Overlay, Vulkan, benchmark e performance
- gamemode
- lib32-gamemode
- mangohud
- lib32-mangohud
- goverlay
- gamescope
- vkbasalt
- lib32-vkbasalt
- vulkan-tools
- mesa-utils
- lib32-vulkan-icd-loader
- lib32-mesa
- lib32-libpulse
- lib32-alsa-plugins
- lib32-pipewire
- lib32-openal
- lib32-sdl2-compat

### Periféricos, controle, remap e RGB
- piper
- libratbag
- solaar
- input-remapper
- antimicrox
- jstest-gtk
- evtest
- oversteer
- openrgb

### GPU, captura e criação
- lact
- corectrl
- obs-studio ou Flatpak com.obsproject.Studio
- gpu-screen-recorder
- kdenlive
- handbrake ou Flatpak fr.handbrake.ghb

### Emulação e comunicação
- retroarch
- dolphin-emu
- pcsx2
- duckstation ou Flatpak org.duckstation.DuckStation
- discord ou Flatpak com.discordapp.Discord
- vesktop ou Flatpak dev.vencord.Vesktop

### Flatpak e utilitários
- flatpak
- flatseal ou Flatpak com.github.tchx84.Flatseal
- discover
- flatpak + discover (equivalente Arch para backend Flatpak do Discover)
- bitwarden ou Flatpak com.bitwarden.desktop

### Regra de segurança
Esta lista não deve instalar kernel, headers, NVIDIA, linux-cachyos ou drivers de vídeo. Kernel e driver de vídeo continuam em rotina própria do Mocha.

### Arquivos canônicos relacionados
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-gamer-default.pkglist
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-gamer-default.flatpaklist
<!-- MOCHA:STACK-GAMER-CANONICO:END -->

<!-- MOCHA_TEMA_COMPLETO_USUARIOS_CANONICO_V1_START -->
## Tema completo Mocha obrigatório para Calamares e novos usuários

Registro corrigido em: 20260627-184133

### Decisão canônica

O Mocha não pode depender de ajuste manual pós-instalação para parecer Mocha.

A instalação só é válida se o usuário criado pelo Calamares receber automaticamente:

- wallpaper Mocha;
- ColorScheme `MochaSolidCanonico`;
- Plasma Style `MochaPanelSolidCanonico`;
- painel/barra com cor Mocha sólida;
- Kickoff/menu com cor Mocha sólida;
- popups/widgets com cor Mocha;
- painel canônico preservado com altura de 48 px;
- permissões corretas no home do usuário.

Se o usuário criado pelo Calamares abrir sessão com KDE genérico, painel transparente, menu preto/transparente ou permissões quebradas no `$HOME`, a etapa visual está reprovada.

### Regra técnica obrigatória

Não basta aplicar apenas `MochaSolidCanonico.colors`.

A barra, o Kickoff/menu e os popups do Plasma dependem do Plasma Style real, com SVG/SVGZ corrigidos.

Tema obrigatório:

`MochaPanelSolidCanonico`

ColorScheme obrigatório:

`MochaSolidCanonico`

Altura canônica do painel:

`48 px`

### Artefatos canônicos salvos na pasta ativa

Plasma Style canônico:

`/media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico`

SVG/SVGZ críticos atuais:

`/media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/svgz-criticos-atuais`

ColorScheme canônico:

`/media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaSolidCanonico.colors`

Painel/barra aprovado atual:

`/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual`

Payload do Calamares:

`/media/mochafast/MochaArch/ativo/calamares/payload/tema-completo`

Finalizador obrigatório do Calamares:

`/media/mochafast/MochaArch/ativo/calamares/scripts/mocha-finaliza-tema-completo-usuarios.sh`

Script local reaplicável:

`/media/mochafast/MochaArch/ativo/scripts/mocha-reaplicar-tema-completo-usuarios.sh`

### SVG/SVGZ críticos do Plasma Style

Devem ser preservados e reaplicados quando existirem:

- `widgets/panel-background.svgz`
- `dialogs/background.svgz`
- `widgets/background.svgz`
- `widgets/viewitem.svgz`
- `widgets/listitem.svgz`
- `widgets/tasks.svgz`
- `widgets/button.svgz`
- `widgets/lineedit.svgz`
- `widgets/frame.svgz`

Também devem ser consideradas variantes `opaque`, `solid` e `translucent` quando existirem no tema.

### Paleta canônica usada no tema Mocha

- Fundo profundo: `#171412`
- Fundo janela: `#1f201f`
- Fundo painel/barra: `#2f2924`
- Fundo popup/menu: `#28231f`
- Fundo botão: `#322a24`
- Borda: `#5c4638`
- Accent: `#c98758`
- Hover: `#d99e68`
- Accent claro: `#f4be82`
- Texto: `#ece2d7`
- Texto discreto: `#aea296`

### Aplicação obrigatória no Calamares

O finalizador deve rodar depois da criação do usuário e antes do encerramento/desmontagem do target.

Ele deve aplicar o tema em:

- `/target/usr/share/plasma/desktoptheme/MochaPanelSolidCanonico`
- `/target/usr/share/color-schemes/MochaSolidCanonico.colors`
- `/target/etc/skel`
- `/target/home/<usuario_criado>`

Para cada usuário real em `/target/home`, devem ser criados ou corrigidos:

- `~/.local/share/plasma/desktoptheme/MochaPanelSolidCanonico`
- `~/.local/share/color-schemes/MochaSolidCanonico.colors`
- `~/.config/plasmarc`
- `~/.config/kdeglobals`
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc`

Depois da cópia, deve ser aplicado `chown -R usuario:usuario` nos arquivos gravados dentro do home do usuário.

### Limpeza obrigatória de cache

Para cada usuário real:

- `~/.cache/ksvg-elements`
- `~/.cache/plasma_theme_MochaPanelSolidCanonico.kcache`

### Regra de escopo

Quando a tarefa for apenas registrar ou reaplicar o tema visual, não mexer em:

- SDDM;
- GRUB;
- boot;
- kernel;
- driver NVIDIA;
- firewall;
- Steam;
- wrapper Steam;
- MangoHud.

### Comando local de reaplicação

Usar somente quando for necessário reaplicar o tema completo na instalação atual:

`/media/mochafast/MochaArch/ativo/scripts/mocha-reaplicar-tema-completo-usuarios.sh`

Para reiniciar Plasma explicitamente:

`/media/mochafast/MochaArch/ativo/scripts/mocha-reaplicar-tema-completo-usuarios.sh --restart-plasma`
<!-- MOCHA_TEMA_COMPLETO_USUARIOS_CANONICO_V1_END -->




<!-- MOCHA_KERNEL_DRIVER_MANAGER_RUST_V8_BEGIN -->
## Registro canônico — Atualizador/Reinstalador Rust GUI Mocha

Data do registro: 20260627-194513

Status: V8 canônico.

Regras obrigatórias:

- Não abrir Konsole como interface inicial.
- A interface inicial deve ser KDE/kdialog herdando tema Plasma/Mocha.
- Botões obrigatórios: Instalar, Reinstalar, Cancelar.
- O atalho `.desktop` deve usar `Terminal=false`.
- O firstboot deve chamar `/usr/local/bin/mocha-kernel-driver-manager --gui`.
- CachyOS deve ser canal transitório via `pacman.conf` temporário.
- `/etc/pacman.conf` não pode ser editado.
- Não executar `pacman -Syu` geral por CachyOS.
- Instalar/reinstalar somente kernel/headers/microcode/driver detectados.

Arquivos canônicos:

- `/usr/local/bin/mocha-kernel-driver-manager`
- `/usr/local/bin/mocha-kernel-driver-firstboot`
- `/usr/local/lib/mocha/mocha-cachyos-transient-install`
- `/usr/share/applications/mocha-kernel-driver-manager.desktop`
- `/etc/skel/Desktop/mocha-kernel-driver-manager.desktop`
- `/etc/xdg/autostart/mocha-kernel-driver-firstboot.desktop`

Cópias preservadas:

- `/media/mochafast/MochaArch/ativo/apps/mocha-kernel-driver-manager`
- `/media/mochafast/MochaArch/ativo/calamares/payload/mocha-kernel-driver-manager`
- fonte: `/media/mochafast/MochaArch/ativo/ferramentas/mocha-kernel-driver-manager-rust-gui-mocha`

<!-- MOCHA_KERNEL_DRIVER_MANAGER_RUST_V8_END -->

---

## Mocha — Wrapper Steam definitivo para Alt+Tab/input

Registro consolidado em 2026-06-28.

O wrapper que aparentemente resolve a perda de input após Alt+Tab é:

/media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak

Regra operacional:

- Não reescrever o wrapper do zero quando o problema for perda de input após Alt+Tab.
- Não escolher automaticamente o backup mais recente.
- Restaurar primeiro esse wrapper definitivo.
- Separar a correção de Alt+Tab/input da correção do MangoHud.
- Não mexer em prefixos Proton, user.reg, compatdata ou localconfig da Steam como primeira tentativa.
- Manter a linha oficial da Steam:

/usr/local/bin/mocha-steam-game-run %command%

Comando de restauração recomendado:

sudo install -Dm755 /media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak /usr/local/bin/mocha-steam-game-run


---

## Mocha — verdadeiro wrapper Steam canônico para Alt+Tab/input

Registro consolidado em 20260628-011105.

O verdadeiro wrapper Steam canônico do Mocha, confirmado como solução para perda de input após Alt+Tab, é:

/media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak

Destino runtime:

/usr/local/bin/mocha-steam-game-run

Linha oficial dos jogos Steam:

/usr/local/bin/mocha-steam-game-run %command%

SHA256:

3d58607f9f7c3bd1aaa8e3924a9f4eb7e1f13531bf64c10fd5587aec271b0235

Regra operacional:

- Este é o verdadeiro wrapper Steam canônico.
- Não reescrever o wrapper do zero quando o problema for perda de input após Alt+Tab.
- Não escolher automaticamente o backup mais recente.
- Restaurar primeiro este wrapper canônico.
- Separar Alt+Tab/input de MangoHud.
- Não mexer em prefixos Proton, user.reg, compatdata ou localconfig da Steam como primeira tentativa.

Cópias canônicas mantidas em múltiplos pontos do projeto:

/media/mochafast/MochaArch/ativo/assets/mocha-steam/bin/mocha-steam-game-run
/media/mochafast/MochaArch/ativo/wrapper-steam/mocha-steam-game-run-canonico
/media/mochafast/MochaArch/ativo/wrapper-steam/mocha-steam-game-run-canonico-alt-tab-input-20260611
/media/mochafast/MochaArch/ativo/usr/local/bin/mocha-steam-game-run
/media/mochafast/MochaArch/ativo/etc/skel/.local/bin/mocha-steam-game-run
/media/mochafast/MochaArch/ativo/calamares/payload/usr/local/bin/mocha-steam-game-run
/media/mochafast/MochaArch/ativo/calamares/payload/etc/skel/.local/bin/mocha-steam-game-run
/media/mochafast/MochaArch/ativo/calamares/payload/tema-completo/usr/local/bin/mocha-steam-game-run
/media/mochafast/MochaArch/ativo/steam-wrapper-canonico/usr/local/bin/mocha-steam-game-run
/media/mochafast/MochaArch/ativo/steam-mangohud-canonico/usr/local/bin/mocha-steam-game-run

Comando de restauração:

sudo install -Dm755 /media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak /usr/local/bin/mocha-steam-game-run

