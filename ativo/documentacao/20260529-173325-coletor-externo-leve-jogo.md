# Mocha Arch/KDE — Coletor externo leve para jogo

- Data: 20260529-173325
- Pasta: `/media/mochafast/MochaArch/ativo/telemetria-externa/20260529-173325-coletor-externo-leve`
- Modo: externo, baixa frequência, sem acoplar ao lançamento do jogo

## Linha Steam recomendada durante este teste

```text
gamemoderun %command%
```

## O que este coletor mede

- Estado do GameMode via `gamemoded -s`.
- P-state, uso, temperatura, clocks e consumo da NVIDIA via `nvidia-smi`.
- Frequência média/min/máx da CPU via `/sys`.
- Governors da CPU.
- RAM disponível/usada.
- PSI de CPU, memória e I/O.
- Processos Steam/Proton/Wine detectados periodicamente.

## Estado inicial

```
Kernel:
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

Sessão:
XDG_SESSION_TYPE=wayland
DESKTOP_SESSION=/usr/share/wayland-sessions/plasma.desktop

Pacotes relevantes:
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
mangohud 0.8.3-2
lib32-mangohud 0.8.3-1
steam 1.0.0.85-7
nvidia-utils 595.71.05-2

Binários:
gamemoderun: /usr/bin/gamemoderun
gamemoded: /usr/bin/gamemoded
nvidia-smi: /usr/bin/nvidia-smi
mangohud: /usr/bin/mangohud
steam: /usr/bin/steam

NVIDIA inicial:
NVIDIA GeForce RTX 5060 Ti, 595.71.05, P8, [Requested functionality has been deprecated], 11.91 W, 180.00 W, 465 MHz, 405 MHz, 37

GameMode inicial:
gamemode is inactive
```

## Coletor iniciado

- PID: `1820675`
- Amostras: `/media/mochafast/MochaArch/ativo/telemetria-externa/20260529-173325-coletor-externo-leve/amostras.tsv`
- Eventos: `/media/mochafast/MochaArch/ativo/telemetria-externa/20260529-173325-coletor-externo-leve/eventos.log`
- Processos: `/media/mochafast/MochaArch/ativo/telemetria-externa/20260529-173325-coletor-externo-leve/processos.log`
- Parar/resumir: `/media/mochafast/MochaArch/ativo/telemetria-externa/20260529-173325-coletor-externo-leve/parar-e-resumir.sh`
