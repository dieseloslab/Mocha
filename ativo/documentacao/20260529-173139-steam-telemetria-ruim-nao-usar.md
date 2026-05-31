# Mocha Arch/KDE — Telemetria Steam ruim: não usar

- Data: 20260529-173139
- Status: falhou operacionalmente
- Decisão: não usar, não canonizar, manter em quarentena

## O que aconteceu

O launcher de telemetria acoplado ao lançamento do jogo prejudicou o teste real: houve stutter e FPS muito baixo.

Além disso, o resumo final recebido veio sem dados úteis: sem SteamAppId, sem config MangoHud, sem código de saída, sem pasta e sem resumo numérico.

## Decisão

Este método de telemetria não deve ser usado como padrão nem como caminho de benchmark durante jogo real.

## Linha Steam segura atual

```text
gamemoderun %command%
```

## Regras preservadas

- Não mexer no MangoHud padrão Mocha.
- Não usar launcher de telemetria acoplado ao jogo.
- Não usar wrapper como padrão enquanto ele não provar vantagem clara.
- Não remover pacotes.
- Preservar os restos ruins em quarentena para auditoria, sem contaminar o ativo.

## Arquivos

- Quarentena: `/media/mochafast/MochaArch/ativo/quarentena/steam-telemetria-ruim-20260529-173139`
- Linha segura registrada: `/media/mochafast/MochaArch/ativo/steam-launcher-telemetria/linha-steam-atual-segura-20260529-173139.txt`

## Próximo teste correto

Testar primeiro sem overlay extra:

```text
gamemoderun %command%
```

Se for necessário medir depois, a medição deve ser feita de forma menos intrusiva, preferencialmente usando o próprio MangoHud padrão Mocha e log nativo, não coletor externo rodando a cada poucos segundos.
