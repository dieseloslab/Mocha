# Receita de agressividade/FPS Mocha

<!-- MOCHA_RECEITA_AGRESSIVIDADE_FPS_V4_INICIO -->

## Receita padrão Mocha — agressividade/FPS V4

**Estado canônico atual:** usar estes valores como padrão para jogos/Steam/Proton no MochaArch.

### Memória, zram, swap e THP

| Item | Valor padrão |
|---|---:|
| `vm.swappiness` | `133` |
| `vm.vfs_cache_pressure` | `50` |
| `vm.page-cluster` | `0` |
| `vm.dirty_background_bytes` | `67108864` |
| `vm.dirty_bytes` | `268435456` |
| `vm.max_map_count` | `8388608` |
| `kernel.sched_autogroup_enabled` | `1` |
| zram | `zstd`, tamanho aproximado de 100% da RAM, prioridade `32767` |
| swap em disco | prioridade baixa, padrão `-1` |
| THP | `madvise` |
| THP defrag | `defer+madvise` |

### CPU e energia

| Item | Valor padrão |
|---|---|
| Driver CPU | `amd-pstate-epp`, quando disponível |
| Governor | `performance` |
| EPP | `performance` |
| Boost CPU | ligado, `1` |
| TuneD | `mocha-latency-performance` |
| Serviços conflitantes | `power-profiles-daemon`, `tlp`, `auto-cpufreq`, `thermald` não devem comandar o perfil gamer |

### NVIDIA

| Item | Valor padrão |
|---|---:|
| `GPUPowerMizerMode` durante jogos | `1` |
| Significado | `Prefer Maximum Performance` |
| Local preferencial de aplicação | GameMode e wrapper Steam Mocha |
| Política | não fazer overclock por padrão; apenas impedir modo adaptativo durante jogo |

### GameMode agressivo

Arquivo padrão: `/etc/gamemode.ini`.

~~~ini
[general]
reaper_freq=5
desiredgov=performance
desiredprof=performance
softrealtime=off
renice=10
ioprio=0
inhibit_screensaver=1
disable_splitlock=1

[gpu]
nv_powermizer_mode=1

[cpu]
park_cores=no
pin_cores=no
~~~

### sysctl padrão

Arquivo padrão: `/etc/sysctl.d/99-mocha-agressividade-fps.conf`.

~~~conf
vm.swappiness = 133
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.max_map_count = 8388608
kernel.sched_autogroup_enabled = 1
~~~

### Wrapper Steam Mocha

O wrapper canônico deve continuar usando:

~~~text
/home/hal/.local/bin/mocha-steam-game-run %command%
~~~

Durante o jogo, o wrapper/GameMode deve garantir:

~~~bash
nvidia-settings -a '[gpu:0]/GPUPowerMizerMode=1'
~~~

### Observações

- `vm.max_map_count=8388608` é valor alto controlado para Proton/Wine/jogos grandes.
- Esse valor não é ajuste direto de FPS; é folga para mapeamentos de memória.
- Ganho de FPS esperado vem principalmente de GPU em `GPUPowerMizerMode=1`, CPU/EPP em `performance` e GameMode agressivo.
- Se `gamemoded -s` mostrar inativo com o jogo fechado, é normal.
- Se `gamemoded -s` mostrar inativo com o jogo aberto via Steam, revisar wrapper/Launch Options.
- Se FPS continuar inferior após estes padrões, próximo suspeito é Proton Experimental, KWin/compositor ou regressão específica de Mesa/NVIDIA/jogo.

<!-- MOCHA_RECEITA_AGRESSIVIDADE_FPS_V4_FIM -->
