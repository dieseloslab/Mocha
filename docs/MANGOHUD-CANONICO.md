# MangoHud canônico Mocha

Estado aprovado em jogo real em 2026-07-03.

## Regra bloqueante

O relógio do overlay deve mostrar minutos obrigatoriamente em `HH:MM`.

## Causa confirmada

O jogo lia corretamente:

- `MANGOHUD_CONFIGFILE=/home/hal/.config/MangoHud/MangoHud.conf`
- `time_format="%H:%M"`

O erro visual era layout/fonte: `font_size=22`, `table_columns=20` e hora no fim da linha faziam o campo ser cortado, aparecendo só a hora.

## Configuração aprovada

- `font_size=18`
- sem `table_columns`
- sem `MANGOHUD_CONFIG` inline
- wrapper exporta somente `MANGOHUD=1` e `MANGOHUD_CONFIGFILE`
- `time_format="%H:%M"`
- MangoHud em uma linha
- itens visuais: hora, FPS, frametime, CPU uso/temp/freq, GPU uso/temp/core/mem, VRAM, RAM, GameMode

## Caminhos canônicos de runtime

- `/usr/local/share/mocha/mangohud/MangoHud.conf`
- `/home/hal/.config/MangoHud/MangoHud.conf`
- `/etc/skel/.config/MangoHud/MangoHud.conf`
- `/usr/local/bin/mocha-steam-game-run`

## Proibido voltar

- não usar `font_size=22`
- não usar `table_columns=20`
- não exportar `MANGOHUD_CONFIG` inline
- não diagnosticar pelo nome de wrapper sem auditar conteúdo real e ambiente do processo

## Auditoria

Rodar:

    mocha-mangohud-auditar

Resultado esperado em processo de jogo:

    MANGOHUD=1
    MANGOHUD_CONFIGFILE=/home/hal/.config/MangoHud/MangoHud.conf

Não deve aparecer:

    MANGOHUD_CONFIG=...
