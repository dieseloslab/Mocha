
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

