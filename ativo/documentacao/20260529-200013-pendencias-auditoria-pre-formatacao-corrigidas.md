# Pendencias da auditoria pre-formatacao corrigidas — Mocha Arch KDE

Data: 20260529-200013

## Natureza deste estado

Este estado ainda nao e canonizacao definitiva. E uma base candidata/pre-canonica para tentar reproduzir o Mocha apos formatacao, evitando o drama das montagens anteriores.

## Correcoes aplicadas

1. Wrapper Steam limpo regravado em:
   - `/home/hal/.local/bin/mocha-steam-game-run`

   Regras preservadas:
   - sem `MANGOHUD_DLSYM`;
   - sem `vkbasalt`;
   - sem `gamescope`;
   - com `MANGOHUD=1`;
   - usa config de MangoHud do usuario se existir;
   - usa `gamemoderun` se existir.

2. Estado atual da barra salvo como snapshot aprovado de reproducao:
   - `/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual-20260529-200013`
   - `/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual`

3. Tabela de cores gerada:
   - `/media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/20260529-200013-TABELA-CORES-MOCHA-SOLID-CANONICO.md`
   - `/media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/TABELA-CORES-MOCHA-SOLID-CANONICO.md`

4. Scripts reutilizaveis adicionados:
   - Wrapper limpo: `/media/mochafast/MochaArch/ativo/scripts/20260529-200013-mocha-reaplicar-wrapper-steam-limpo.sh`
   - Verificacao NVIDIA/Wayland/Zen: `/media/mochafast/MochaArch/ativo/scripts/20260529-200013-mocha-verificar-nvidia-wayland-zen.sh`
   - Reaplicar agressividade/energia atual: `/media/mochafast/MochaArch/ativo/scripts/20260529-200013-mocha-reaplicar-agressividade-energia-atual.sh`
   - Reaplicar barra atual: `/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-200013-mocha-reaplicar-barra-aprovada-atual.sh`

## Estado tecnico que deve ser reproduzido

- Kernel alvo atual: Zen como primeira/default.
- Driver NVIDIA funcional observado: 595.71.05.
- Sessao obrigatoria: KDE Wayland.
- FAST obrigatorio: `/media/mochafast`.
- VMSTORE obrigatorio: `/media/vmstore`.
- CPU: governor `performance`.
- TuneD: `latency-performance`.
- Receita de agressividade atual:
  - `vm.swappiness = 80`
  - `vm.vfs_cache_pressure = 50`
  - `vm.page-cluster = 0`
  - `vm.dirty_background_bytes = 67108864`
  - `vm.dirty_bytes = 268435456`
  - `vm.max_map_count = 16777216`
  - `kernel.sched_autogroup_enabled = 0`
  - `kernel.nmi_watchdog = 0`
  - THP: `madvise`
  - zram: `zstd`, tamanho RAM, prioridade `32767`
- Cores KDE:
  - `MochaSolidCanonico`
- Plasma Style:
  - `MochaPanelSolidCanonico`
- Barra:
  - usar snapshot atual aprovado, nao deduzir geometria.
- Bluetooth/volume duplicados:
  - manter KDE/Bluedevil e Plasma PA;
  - ocultar autostart de `blueman` e `kmix`;
  - nao remover pacotes.
- Flatpak/Flathub:
  - manter.
- Chrome:
  - nao incluir por padrao.
- Bitwarden:
  - manter fora por enquanto.

## Observacao importante

A auditoria anterior gerou um falso problema parcial na leitura do ColorScheme e quebrou a checagem de cobertura dos manuais por erro de Bash. Esta rodada corrige esse ponto com uma auditoria revisada.
