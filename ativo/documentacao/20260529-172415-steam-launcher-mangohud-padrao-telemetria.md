# Mocha Arch/KDE — Launcher Steam com MangoHud padrão + telemetria

- Data: 20260529-172415
- Launcher ativo: `/home/hal/.local/bin/mocha-steam-game-telemetry-run`
- Cópia canônica: `/media/mochafast/MochaArch/ativo/steam-launcher-telemetria/mocha-steam-game-telemetry-run-20260529-172415.sh`
- MangoHud padrão usado: `/home/hal/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf`

## Linha correta para usar na Steam

```text
/home/hal/.local/bin/mocha-steam-game-telemetry-run %command%
```

## O que esta linha faz

- Usa o arquivo MangoHud padrão Mocha existente.
- Exporta `MANGOHUD=1`.
- Exporta `MANGOHUD_CONFIGFILE` apontando para o padrão Mocha.
- Executa `gamemoderun mangohud %command%`.
- Coleta telemetria automaticamente enquanto o jogo roda.
- Salva resumo ao fechar o jogo.

## Estado encontrado

```
Kernel:
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

Sessão:
XDG_SESSION_TYPE=wayland
DESKTOP_SESSION=/usr/share/wayland-sessions/plasma.desktop

Pacotes:
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
mangohud 0.8.3-2
lib32-mangohud 0.8.3-1
steam 1.0.0.85-7

Binários:
gamemoderun: /usr/bin/gamemoderun
gamemoded: /usr/bin/gamemoded
mangohud: /usr/bin/mangohud
steam: /usr/bin/steam
nvidia-smi: /usr/bin/nvidia-smi

GameMode agora:
gamemode is inactive
```
