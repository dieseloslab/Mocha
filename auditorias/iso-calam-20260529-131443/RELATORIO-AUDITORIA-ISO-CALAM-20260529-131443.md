# Auditoria ISO Calam/Calam-Arch — 20260529-131443

## ISO

- Caminho: `/home/hal/Downloads/Calam-Arch-Installer-2026-05.iso`
- Tamanho:

```
-rw-r--r-- 1 hal hal 4,0G mai 29 13:07 /home/hal/Downloads/Calam-Arch-Installer-2026-05.iso
4,0G	/home/hal/Downloads/Calam-Arch-Installer-2026-05.iso
/home/hal/Downloads/Calam-Arch-Installer-2026-05.iso: ISO 9660 CD-ROM filesystem data (DOS/MBR boot sector) 'ARCH_202605' (bootable)
```

## Hash local

```
f261af28f0389dfa10ac362b4a17bdf4c1ac4af394237c9c55c79983d0bcf954  /home/hal/Downloads/Calam-Arch-Installer-2026-05.iso
660118aab79bae7ffca2c793bf42120a4806926e089d43d62a2cc8c6d3c72ba230dbc805cc0d8caf4a627e353f7c1c2323d13ad702bb2dc48d513536cf460bcc  /home/hal/Downloads/Calam-Arch-Installer-2026-05.iso
```

## Assinatura/checksum ao lado da ISO

```
Nenhum arquivo .sig/.asc/SHA256SUMS correspondente encontrado ao lado da ISO.
```

## Repositórios/pacman detectados

```
Não foi possível extrair pacman.conf/mirrorlist do rootfs, ou não havia dados.
```

## Identidade do sistema live

```
Não foi possível extrair os-release/lsb-release.
```

## Marcadores relevantes

```
Nenhum marcador forte encontrado nos arquivos extraídos.
```

## Critério Mocha

- Bom sinal: repositórios finais apenas Arch oficial: [core], [extra], opcionalmente [multilib].
- Bom sinal: os-release com ID=arch ou instalação final claramente Arch.
- Atenção: pamac, repositório próprio, keyring próprio, branding persistente ou pacotes de identidade visual.
- Atenção: Calamares pode ser aceitável como instalador, mas não deve deixar identidade Calam/ALCI/Endeavour/Arco/Garuda/Manjaro no sistema final.

## Arquivos gerados

- Log completo: `/media/mochafast/MochaArch/auditorias/iso-calam-20260529-131443/auditoria-iso-calam-20260529-131443.log`
- Lista completa da ISO: `/media/mochafast/MochaArch/auditorias/iso-calam-20260529-131443/lista-completa-arquivos-iso-20260529-131443.txt`
- Arquivos interessantes: `/media/mochafast/MochaArch/auditorias/iso-calam-20260529-131443/arquivos-interessantes-iso-20260529-131443.txt`
- Relatório: `/media/mochafast/MochaArch/auditorias/iso-calam-20260529-131443/RELATORIO-AUDITORIA-ISO-CALAM-20260529-131443.md`
