# MochaArch — correção input-remapper daemon

Timestamp: 20260531-205511

## Problema

O boot apresentava várias falhas de `input-remapper-control --command autoload`.

A auditoria confirmou que:

- o pacote `input-remapper` estava instalado;
- `/etc/xdg/autostart/input-remapper-autoload.desktop` chamava o autoload;
- `/usr/lib/udev/rules.d/99-input-remapper.rules` chamava o autoload em eventos de input;
- `input-remapper.service` existia, mas estava desativado e inativo;
- não havia perfis/configurações do usuário em `~/.config/input-remapper`.

## Correção aplicada

Foi habilitado e iniciado o daemon:

```bash
sudo systemctl enable --now input-remapper.service
```

Também foi limpo o estado falhado da unidade de autostart gerada pelo systemd do usuário, sem remover autostart, pacote ou regra udev.

## Resultado esperado

No próximo boot, as chamadas automáticas de autoload devem encontrar o daemon ativo e parar de gerar:

- `ERROR: Service not running?`
- `ERROR: Daemon missing`
- `app-input-remapper-autoload@autostart.service: Failed with result 'exit-code'`

## Arquivo de log

`/media/mochafast/MochaArch/ativo/relatorios/20260531-205511-corrigir-input-remapper-daemon.log`
