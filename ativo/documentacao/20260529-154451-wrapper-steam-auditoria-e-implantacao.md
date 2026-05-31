# Mocha Arch/KDE — Auditoria e implantação do wrapper Steam limpo

- Data: 20260529-154451
- Wrapper alvo: `/home/hal/.local/bin/mocha-steam-game-run`
- Pasta ativa: `/media/mochafast/MochaArch/ativo`

## Objetivo

Auditar o wrapper Steam real e implantar uma versão limpa, mínima e testável, baseada no melhor resultado observado até agora: jogo fluido, FPS alto e boa imagem sem Launch Options legadas.

## Regras preservadas

- Não usar X11 como fallback.
- Não usar `MANGOHUD_DLSYM`.
- Não usar `vkbasalt` no wrapper canônico.
- Não usar `gamescope` no wrapper canônico.
- Não forçar opções antigas de Launch Options.
- Não remover pacotes.
- Preservar o wrapper anterior em backup.

## Estado antes da implantação

```
Kernel atual:
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

Sessão:
XDG_SESSION_TYPE=wayland
DESKTOP_SESSION=/usr/share/wayland-sessions/plasma.desktop

GPU/NVIDIA:
NVIDIA GeForce RTX 5060 Ti, 595.71.05, P0, [Requested functionality has been deprecated]

Ferramentas disponíveis:
steam: /usr/bin/steam
mangohud: /usr/bin/mangohud
gamemoderun: /usr/bin/gamemoderun
nvidia-smi: /usr/bin/nvidia-smi
```


## Wrapper anterior

Nenhum wrapper anterior encontrado em `/home/hal/.local/bin/mocha-steam-game-run`.
