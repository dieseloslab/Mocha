# VMSTORE — montagem real no boot e acesso pelo Dolphin

Data: 20260531-175318

## Correção aplicada

O VMSTORE estava aparecendo como:

```
/media/vmstore systemd-1 autofs
```

Isso indicava automount sob demanda do systemd, não montagem real do XFS no boot.

Foi corrigida a entrada ativa de `/etc/fstab` para manter o VMSTORE como montagem real no boot, removendo opções como:

- `noauto`
- `x-systemd.automount`
- `x-systemd.idle-timeout=...`

Foram preservados o UUID/origem e o tipo de filesystem quando já existiam no fstab.

## Objetivo

- Montar `/media/vmstore` automaticamente no boot.
- Evitar pedido de senha no Dolphin.
- Manter o VMSTORE acessível como pasta fixa do sistema.
- Preservar o disco como XFS.
- Não usar TRIM/discard no VMSTORE.

## Resultado esperado

```
findmnt -T /media/vmstore
```

deve mostrar `FSTYPE=xfs`, não `autofs`.

## Log

```
/media/mochafast/MochaArch/ativo/relatorios/20260531-175318-vmstore-mount-real-boot-dolphin.log
```
