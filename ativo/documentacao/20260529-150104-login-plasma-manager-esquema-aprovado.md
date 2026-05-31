# Mocha Arch — esquema de login aprovado

Registro gerado em: `20260529-150104`

## Mounts persistentes corrigidos

- FAST: `UUID=88e6aa16-110c-4b97-9ffb-85084c000198` em `/media/mochafast`, tipo `btrfs`, label `MOCHAFAST`
- VMSTORE: `UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6` em `/media/vmstore`, tipo `xfs`, label `vmstore`
- O script não formatou, não particionou, não removeu pacote, não alterou bootloader e não mexeu em XU.
- No `/etc/fstab`, foram substituídas somente entradas cujo mountpoint era exatamente `/media/mochafast` ou `/media/vmstore`.

## Estado aprovado observado do login

- Gerenciador de login desejado para esta fase: `plasma-login.service`
- Sessão alvo: KDE Plasma em Wayland
- X11 não é fallback neste projeto, salvo ordem explícita posterior.
- Link atual de `display-manager.service`: `/usr/lib/systemd/system/plasmalogin.service`
- Unidade carregada pelo systemd: `/usr/lib/systemd/system/plasmalogin.service`
- Estado de `plasma-login.service`: enabled=`not-found`, active=`inactive`
- Estado de `sddm.service`: enabled=`disabled`, active=`inactive`
- Sessão atual detectada: Type=`wayland`, Desktop=`KDE`

## Regra operacional

1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
