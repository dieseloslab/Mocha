# Mocha Arch/KDE — passo canônico: barra sem Bluetooth/volume duplicados

Timestamp: 20260529-152907

## Status

Aprovado pelo usuário em teste real.

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:

- `~/.config/autostart/blueman.desktop`
- `~/.config/autostart/kmix_autostart.desktop`

Arquivos preparados para novos usuários:

- `/etc/skel/.config/autostart/blueman.desktop`
- `/etc/skel/.config/autostart/kmix_autostart.desktop`

## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
