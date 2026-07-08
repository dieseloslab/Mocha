# MangoHud canônico do Mocha

Estado canônico vigente:

- Config ativa em runtime: `${HOME}/.config/MangoHud/mocha-active.conf`
- Wrapper Steam/Proton: `/usr/local/bin/mocha-steam-game-run`
- Variável obrigatória no wrapper: `MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf"`
- O Steam/Proton deve receber sempre `${HOME}/.config/MangoHud/mocha-active.conf`.
- Não usar configuração inline antiga como fonte principal do Mocha.
- Não usar caminho fixo de usuário.
- Não usar configuração global antiga como runtime canônico.
- Para novos usuários, entregar a configuração em `/etc/skel/.config/MangoHud/mocha-active.conf`.

Contrato visual aprovado:

- Uma linha.
- Sem gráficos.
- Sem histogramas.
- Sem tabelas/colunas.
- Ordem esperada: FPS, latência, CPU, GPU, VRAM, hora em HH:MM e indicador GameMode.

Contrato do wrapper:

- Preservar correções de Alt+Tab/input.
- Preservar `SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0`.
- Preservar `MouseWarpOverride=force`.
- Exportar `MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf"`.
- Limpar `MANGOHUD_CONFIG`.
- Limpar `MANGOHUD_DLSYM`.
- Manter `MANGOHUD_DLSYM` proibido no wrapper canônico.
