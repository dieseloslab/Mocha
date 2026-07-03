# Mocha — Repo Liquorix/lqx

## Decisão

Liquorix/lqx é o kernel canônico atual do Mocha.

## Local do repo

```
/media/vmstore/mocha-repo/local/kernel-liquorix/x86_64
```

## Nome do repo pacman

```
mocha-lqx
```

## Snippet pacman

```
/media/vmstore/mocha-repo/local/kernel-liquorix/x86_64/mocha-lqx.pacman.conf.snippet
```

## Política

- Repo arquivo.
- Baixar versões novas.
- Nunca apagar versões antigas automaticamente.
- Preservar rollback.
- Manter manifestos por rodada.
- Manter snapshots por rodada.
- Não usar `repo-add --files`, porque o `repo-add` desta instalação não aceita essa opção.

## Pacotes centrais

```
linux-lqx
linux-lqx-headers
```

## NVIDIA

Com lqx, preferir DKMS:

```
nvidia-open-dkms
nvidia-utils
lib32-nvidia-utils
```

## Último manifesto

```
/media/vmstore/mocha-repo/manifestos/kernel-liquorix/manifesto-liquorix-latest.txt
```
