# Perfis Steam Mocha V1

O Steam continua usando somente:

```text
/usr/local/bin/mocha-steam-game-run %command%
```

O wrapper identifica o AppID e a família do Proton. O perfil global fica em
`/usr/local/share/mocha/steam-profiles/APPID.conf`. Uma substituição do usuário
pode ficar em `~/.config/mocha/steam-profiles/APPID.conf`.

O carregador aceita somente as chaves abaixo; ele não executa o conteúdo do
perfil como código:

- `MOCHA_PROFILE_NAME`
- `MOCHA_DXVK_LOWLATENCY` (`0` ou `1`)
- `MOCHA_VKD3D_LOWLATENCY` (`0` ou `1`)
- `MOCHA_VKREFLEX` (`0` ou `1`)
- `MOCHA_LOW_LATENCY_LAYER` (`0` ou `1`)
- `MOCHA_FRAME_RATE` (`0` desativa; nenhum limite é aplicado por padrão)
- `MOCHA_WOW64` (`0` ou `1`)

Compatibilidade aplicada pela V1:

- DW-Proton: todos os seletores auditados.
- GE-Proton: VKReflex, low-latency layer, frame-rate e WoW64.
- Proton-EM: somente WoW64.
- Proton Valve/Experimental e ferramentas desconhecidas: nenhum seletor
  específico, preservando o comportamento original.

Os perfis iniciais são `690790` (DiRT Rally 2.0, DXVK) e `1029690`
(Sniper Elite 5, VKD3D). Nenhum limite de FPS, Wayland, HDR, Reflex ou WoW64 é
ativado nesses perfis.

O registro de seleção fica em
`~/.local/state/mocha/steam-profiles.log`.
