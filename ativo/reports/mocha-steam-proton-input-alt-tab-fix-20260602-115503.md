# MOCHA — correção Steam/Proton input após Alt+Tab

- Timestamp: 20260602-115503
- Sessão: wayland
- Desktop: KDE
- Kernel: 7.0.10-2-cachyos
- Prefixos Proton encontrados: 5
- Prefixos corrigidos/gravados: 5
- Prefixos com falha: 0

## Correções aplicadas

- Steam Client Beta removido se havia arquivo beta local.
- Registro Proton/Wine por prefixo:
  - `HKCU\Software\Wine\X11 Driver\UseTakeFocus=N`
  - `HKCU\Software\Wine\DirectInput\MouseWarpOverride=force`
- Wrapper canônico refeito sem gamescope/vkbasalt/MANGOHUD_DLSYM:
  - `/home/hal/.local/bin/mocha-steam-game-run`
- Wrapper de resgate não-canônico com gamescope:
  - `/home/hal/.local/bin/mocha-steam-game-input-rescue`
- Script de auditoria pós-teste:
  - `/media/mochafast/MochaArch/ativo/scripts/mocha-auditar-input-steam-pos-teste-20260602-115503.sh`

## Launch Options para testar

Primeiro teste:

```bash
/home/hal/.local/bin/mocha-steam-game-run %command%
```

Se o jogo ainda perder input após Alt+Tab:

```bash
/home/hal/.local/bin/mocha-steam-game-input-rescue %command%
```

## Observação

Se o jogo estiver em Proton Experimental/Hotfix/10 e continuar falhando, force Proton 9.0-4 nas propriedades do jogo para testar a regressão de foco relatada em KWin/Proton.
