# MochaArch — estado aprovado pós-auditoria

Timestamp: 20260602-194017

## Resultado

Estado geral coerente para seguir a montagem do MochaArch.

## Manual principal

Arquivo:

```text
/media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
```

Hash auditado:

```text
726f8ad7dcea02b21e9867628e29a5689848485b50d2331252921e4221e079f6
```

## Montagens

FAST:

```text
/media/mochafast
```

VMSTORE:

```text
/media/vmstore
```

Ambos montados e presentes no /etc/fstab.

## Login

Estado funcional aprovado:

```text
SDDM + Breeze + Wayland
/etc/sddm.conf.d/00-mocha-resgate.conf
```

Regra:

- Não trocar por tema customizado sem auditoria.
- Não usar X11 como fallback.
- Não desabilitar sddm.service enquanto estiver funcional.

## Kernel / boot / NVIDIA

Kernel atual:

```text
7.0.10-2-cachyos
```

Boot:

```text
BOOT_IMAGE=/boot/vmlinuz-linux-cachyos
GRUB_DEFAULT=linux-cachyos
GRUB_SAVEDEFAULT=false
```

NVIDIA:

```text
Driver 610.43.02
RTX 5060 Ti
nvidia-smi OK
```

## Firewall / DNS

```text
ufw enabled
ufw active
entrada deny
saída allow
DNS-over-TLS Cloudflare ativo
```

## Steam

Wrapper canônico:

```text
/home/hal/.local/bin/mocha-steam-game-run
```

Launch Option padrão:

```text
/home/hal/.local/bin/mocha-steam-game-run %command%
```

Proibições preservadas:

- sem gamescope;
- sem vkbasalt;
- sem MANGOHUD_DLSYM.

## Decisão

Não mexer agora em SDDM, GRUB, kernel, NVIDIA, firewall ou wrapper Steam.
