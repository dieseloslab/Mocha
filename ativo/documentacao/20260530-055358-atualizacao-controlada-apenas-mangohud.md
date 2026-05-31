# Mocha Arch - atualização controlada apenas do MangoHud

Data: 20260530-055358

## Resultado

- Foi atualizada somente a família alvo: `mangohud`.
- Não foi executado `pacman -Syu`.
- Não foi feita atualização geral do sistema.
- Kernel, NVIDIA, Mesa, Vulkan, Wayland, boot e base crítica foram bloqueados por auditoria antes da alteração.
- Pacotes AUR/foreign foram apenas listados, sem atualização.

## Antes

```
mangohud 0.8.3-2
```

## Depois

```
mangohud 0.8.4-1
```

## Atualizações restantes após o teste

```
Nenhuma atualização restante.
```

## Pacotes foreign/AUR/locais registrados

```
libpamac-aur 11.7.4-2
pamac-aur 11.7.4-3
```

## Arquivos

- Log: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055358-atualizacao-controlada-apenas-mangohud.log`
- Atualizações antes: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055358-pacman-Qu-antes-mangohud.txt`
- Atualizações depois: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055358-pacman-Qu-depois-mangohud.txt`
- MangoHud antes: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055358-mangohud-antes.txt`
- MangoHud repo sync: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055358-mangohud-sync-repo.txt`
- MangoHud depois: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055358-mangohud-depois.txt`
- Foreign/AUR: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055358-pacotes-foreign-pos-mangohud.txt`
- Script reutilizável: `/media/mochafast/MochaArch/ativo/scripts/20260530-055358-mocha-atualizar-apenas-mangohud-controlado.sh`

## Próximo teste manual

- Abrir um jogo pela Steam.
- Confirmar se o overlay do MangoHud aparece.
- Confirmar se FPS/frametime continuam bons.
- Se houver regressão, usar o pacote antigo em `/var/cache/pacman/pkg` para rollback.
