# MOCHA — relatório correção input Steam Alt+Tab

- Timestamp: 20260602-114912
- Sessão: wayland
- Desktop: KDE
- Kernel: 7.0.10-2-cachyos
- Steam: /usr/bin/steam

## KWin antes

```
FocusPolicy=ClickToFocus
FocusStealingPreventionLevel=0
DelayFocusInterval=0
AutoRaise=false
NextFocusPrefersMouse=false
```


## KWin depois

```
FocusPolicy=ClickToFocus
FocusStealingPreventionLevel=0
DelayFocusInterval=0
AutoRaise=false
NextFocusPrefersMouse=false
```

## Resultado aplicado

- Steam launcher seguro: `/home/hal/.local/bin/mocha-steam-input-safe-launcher`
- Wrapper canônico de jogo: `/home/hal/.local/bin/mocha-steam-game-run`
- Launch Option recomendada: `/home/hal/.local/bin/mocha-steam-game-run %command%`
- Sem gamescope.
- Sem vkbasalt.
- Sem MANGOHUD_DLSYM.
- Proton Wayland nativo bloqueado por segurança: `PROTON_ENABLE_WAYLAND=0`.
- SDL forçado para X11/XWayland dentro dos jogos: `SDL_VIDEODRIVER=x11`.
- IME removido do ambiente do jogo: `XMODIFIERS/GTK_IM_MODULE/QT_IM_MODULE/GLFW_IM_MODULE unset`.

## Teste

1. Abra a Steam pelo menu normal; o desktop local agora chama o launcher seguro.
2. No jogo afetado, use exatamente:

```
/home/hal/.local/bin/mocha-steam-game-run %command%
```

3. Teste Alt+Tab e retorno ao jogo.
