# Auditoria Mocha Gamer Essentials

Data: 20260530-101522
Máquina: Mocha

## Escopo

Este relatório não instala, remove nem atualiza pacotes.
Ele apenas audita o estado local via pacman, consulta disponibilidade no AUR por RPC quando há curl/rede e verifica alguns AppIDs Flatpak conhecidos quando há flatpak/flathub.

## Regra Mocha para ferramentas gamer

Instalar ou disponibilizar uma ferramenta não significa ativá-la automaticamente no wrapper oficial.
O wrapper/LaunchOptions oficial deve continuar limpo, testado e sem MANGOHUD_DLSYM, sem vkBasalt e sem gamescope por padrão.
vkBasalt e gamescope podem existir para uso escolhido pelo usuário ou receitas específicas validadas.
MangoHud é obrigatório no padrão Mocha e precisa respeitar a configuração visual Mocha.

## Resumo por item

| Item | Camada | Pacman instalado | Repo oficial | AUR | Flatpak | Observação |
|---|---:|---:|---:|---:|---:|---|
| Steam | PADRAO | sim | sim | nao | SEM_APPID_MAPEADO | Cliente Steam; base comum de distros gamer. |
| GameMode | PADRAO | sim | sim | nao | SEM_APPID_MAPEADO | Ativador de perfil de jogo; linha oficial atual permanece gamemoderun %command% até teste do wrapper MangoHud. |
| MangoHud | PADRAO | sim | sim | nao | SEM_APPID_MAPEADO | Overlay fundamental do Mocha; deve usar padrão visual Mocha. |
| GOverlay | PADRAO | nao | sim | nao | SEM_APPID_MAPEADO | Interface para configurar MangoHud/vkBasalt/OptiScaler; instalado não significa ativar vkBasalt no wrapper. |
| Gamescope | DISPONIVEL_SEM_ATIVAR | nao | sim | nao | SEM_APPID_MAPEADO | Pode existir para usuário/testes, mas não entra no wrapper oficial sem validação. |
| Lutris | PADRAO | nao | sim | nao | FLATHUB_DISPONIVEL | Launcher importante para jogos fora da Steam. |
| Heroic Games Launcher | PADRAO | nao | nao | sim | FLATHUB_DISPONIVEL | Launcher Epic/GOG/Amazon; nome varia conforme repo/AUR/Flatpak. |
| Protontricks | PADRAO | nao | sim | nao | SEM_APPID_MAPEADO | Ferramenta de correção por prefixo Proton. |
| Winetricks | PADRAO | nao | sim | nao | SEM_APPID_MAPEADO | Ferramenta auxiliar Wine/Proton. |
| ProtonUp-Qt | PADRAO_OU_FLATPAK | nao | nao | sim | FLATHUB_DISPONIVEL | Gerenciador gráfico de Proton-GE/Wine-GE. |
| umu-launcher | PADRAO_SE_DISPONIVEL | nao | sim | nao | SEM_APPID_MAPEADO | Camada moderna usada por launchers para Proton fora da Steam. |
| Vulkan Tools | PADRAO | sim | sim | nao | SEM_APPID_MAPEADO | Diagnóstico Vulkan. |
| Mesa Utils | PADRAO | sim | sim | nao | SEM_APPID_MAPEADO | Diagnóstico OpenGL. |
| Piper | PADRAO | nao | sim | nao | SEM_APPID_MAPEADO | Configuração de mouse gamer via libratbag/ratbagd. |
| libratbag | PADRAO | nao | sim | nao | SEM_APPID_MAPEADO | Backend do Piper para mouse gamer. |
| Input Remapper | PADRAO | nao | nao | sim | NAO_ENCONTRADO_FLATHUB_OU_SEM_REDE | Remapeamento de mouse, teclado, controle e periféricos; útil no Wayland. |
| Oversteer | PADRAO | nao | nao | sim | SEM_APPID_MAPEADO | Gerenciamento de volantes suportados no Linux. |
| AntiMicroX | DISPONIVEL | nao | sim | nao | SEM_APPID_MAPEADO | Mapeador de controle/teclado útil para jogos antigos. |
| jstest-gtk | DISPONIVEL | nao | nao | nao | SEM_APPID_MAPEADO | Teste/calibração de joystick. |
| vkBasalt | DISPONIVEL_SEM_ATIVAR | nao | nao | sim | SEM_APPID_MAPEADO | Pode ficar disponível, mas não entra no wrapper oficial por padrão. |
| vkBasalt CLI | DISPONIVEL_SEM_ATIVAR | nao | nao | sim | SEM_APPID_MAPEADO | Ferramenta complementar se existir no repo usado. |
| ReShade Shaders | DISPONIVEL_SEM_ATIVAR | nao | nao | nao | SEM_APPID_MAPEADO | Shaders opcionais para usuário avançado. |
| LACT | CANDIDATO_AUDITAR | nao | sim | sim | SEM_APPID_MAPEADO | Controle de GPU; precisa validação por hardware e serviço antes de virar padrão. |
| CoreCtrl | CANDIDATO_AUDITAR | nao | sim | nao | SEM_APPID_MAPEADO | Útil sobretudo para AMD; não substituir política NVIDIA atual sem teste. |
| OBS Studio | PADRAO | nao | sim | nao | FLATHUB_DISPONIVEL | Gravação/streaming; comum em distro gamer/criador. |
| GPU Screen Recorder | DISPONIVEL | nao | sim | sim | FLATHUB_DISPONIVEL | Gravação leve; validar com NVIDIA/Wayland antes de padrão final. |
| Bottles | DISPONIVEL | nao | nao | sim | FLATHUB_DISPONIVEL | Wine apps/jogos; bom disponível, mas pode ficar Flatpak. |
| Faugus Launcher | CANDIDATO_AUDITAR | nao | nao | sim | SEM_APPID_MAPEADO | Candidato visto em GLF; auditar maturidade antes de padrão. |

## Estado MangoHud/GameMode

HOME=/home/hal
EXISTE /home/hal/.config/MangoHud/MangoHud.conf
EXISTE /home/hal/.config/MangoHud/Mocha-MangoHud.conf
EXISTE /home/hal/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf
AUSENTE /etc/MangoHud/MangoHud.conf
AUSENTE /etc/mangohud/MangoHud.conf
EXISTE /etc/mocha/mangohud/MangoHud.conf
AUSENTE /etc/mocha/mangohud/Mocha-MangoHud.conf
gamemoderun=OK /usr/bin/gamemoderun
mangohud=OK /usr/bin/mangohud

## Arquivos gerados

Relatório TSV: /media/mochafast/MochaArch/ativo/relatorios/20260530-101522-mocha-gamer-essentials-auditoria.tsv
Script reutilizável: /media/mochafast/MochaArch/ativo/scripts/20260530-101522-mocha-auditar-gamer-essentials.sh
