# GameMode OC NVIDIA — espelho do runtime aprovado

Este diretório preserva o modelo que está funcionando no sistema Mocha.

## Cadeia ativa

`/etc/gamemode.ini` chama:

- `/usr/local/lib/mocha/gamemode-start-agressivo-oc.sh`
- `/usr/local/lib/mocha/gamemode-end-agressivo-oc.sh`

Esses dois caminhos são links simbólicos de compatibilidade para:

- `/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system`
- `/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system`

Os hooks chamam:

- `/usr/local/lib/mocha/mocha-nvidia-oc-root-helper`

Arquivos complementares:

- `/etc/mocha/nvidia-game-oc.conf`
- `/etc/sudoers.d/mocha-nvidia-oc-root-helper`

O payload deve preservar os links simbólicos como links. Não deve
convertê-los em cópias regulares nem substituir os caminhos definidos no
`gamemode.ini` por inferência.

## Aplicação

Executar:

`./mocha-aplica-gamemode-oc-nvidia-nvml.sh`

O instalador copia o `gamemode.ini` aprovado, os arquivos regulares e os
links simbólicos, preservando os modos registrados no payload.
