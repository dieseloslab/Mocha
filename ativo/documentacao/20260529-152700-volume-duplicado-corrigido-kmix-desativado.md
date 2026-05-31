# Mocha Arch/KDE — volume duplicado corrigido por desativação do KMix

Timestamp: 20260529-152700

## Diagnóstico

A barra apresentava volume duplicado.

A auditoria mostrou:

- O applet normal do Plasma para volume existe no system tray:
  - `org.kde.plasma.volume`
- O KMix também estava rodando por autostart:
  - `app-kmix_autostart@autostart.service`
  - processo `kmix --keepvisibility`

Isso cria redundância visual de volume.

## Ação aplicada

Foi criado/ajustado o override local:

`/home/hal/.config/autostart/kmix_autostart.desktop`

com:

`Hidden=true`

Também foi parado nesta sessão:

`app-kmix_autostart@autostart.service`

e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
