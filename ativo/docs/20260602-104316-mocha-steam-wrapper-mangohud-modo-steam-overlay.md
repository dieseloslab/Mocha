# MochaArch — Steam overlay como medição atual e MangoHud preservado

Timestamp: 20260602-104316

## Decisão

Neste momento, o desempenho dos jogos está sendo medido pelo overlay da Steam.

Portanto:

- MangoHud permanece instalado/configurado no padrão Mocha.
- MangoHud não é forçado pelo wrapper Steam atual.
- O wrapper canônico atual executa GameMode e variáveis NVIDIA básicas.
- vkBasalt, gamescope e MANGOHUD_DLSYM continuam fora do wrapper canônico.

## Linha Steam recomendada para o teste atual

```
gamemoderun %command%
```

## Alternativa se o jogo estiver melhor sem Launch Options

```
Launch Options vazia
```

## Wrapper candidato sem MangoHud forçado

```
/home/hal/.local/bin/mocha-steam-game-run %command%
```

## Configuração MangoHud preservada

Usuário:

```
/home/hal/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf
```

Sistema:

```
/etc/mocha/mangohud/MangoHud.conf
```
