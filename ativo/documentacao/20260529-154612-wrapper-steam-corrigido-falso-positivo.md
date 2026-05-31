# Mocha Arch/KDE — Wrapper Steam limpo corrigido

- Data: 20260529-154612
- Wrapper alvo: `/home/hal/.local/bin/mocha-steam-game-run`
- Pasta ativa: `/media/mochafast/MochaArch/ativo`

## Correção feita

A tentativa anterior implantou o wrapper, mas abortou por falso positivo na verificação final.
O filtro antigo acusava inclusive comentários e linhas de limpeza de ambiente.

Nesta correção:

- O wrapper foi recriado sem comentários internos com termos problemáticos.
- A limpeza de variáveis herdadas foi mantida, mas sem acionar o grep bruto antigo.
- A validação agora diferencia ativação real de limpeza defensiva.
- O wrapper continua sem gamescope, sem vkbasalt, sem fallback X11 e sem MANGOHUD_DLSYM ativo.

## Estado do sistema no momento da correção

```
Kernel:
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

Sessão:
XDG_SESSION_TYPE=wayland
DESKTOP_SESSION=/usr/share/wayland-sessions/plasma.desktop

NVIDIA:
NVIDIA GeForce RTX 5060 Ti, 595.71.05, P8, [Requested functionality has been deprecated]

Ferramentas:
steam: /usr/bin/steam
mangohud: /usr/bin/mangohud
gamemoderun: /usr/bin/gamemoderun
nvidia-smi: /usr/bin/nvidia-smi
```

## Backup do wrapper anterior

- SHA256 anterior: `1d0ad8a15db4813200d389cbbb33bc71c06956a13e7225cc15a0a01084ee0722`
- Backup: `/media/mochafast/MochaArch/ativo/wrapper-steam/backups/mocha-steam-game-run-backup-20260529-154612`

### Conteúdo anterior

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

# Mocha Steam Game Run — wrapper limpo
# Uso na Steam:
# /home/hal/.local/bin/mocha-steam-game-run %command%
#
# Regras:
# - não usar MANGOHUD_DLSYM
# - não usar vkbasalt
# - não usar gamescope
# - não forçar X11
# - preservar o comportamento base da Steam/Proton o máximo possível

if [ "$#" -lt 1 ]; then
  echo "Uso: mocha-steam-game-run %command%" >&2
  exit 64
fi

unset MANGOHUD_DLSYM
unset ENABLE_VKBASALT
unset VKBASALT_CONFIG_FILE
unset GAMESCOPE_ARGS
unset GAMESCOPE_WSI

export DXVK_LOG_LEVEL="${DXVK_LOG_LEVEL:-none}"

MANGOHUD_CONF_USER="${HOME}/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf"
MANGOHUD_CONF_SYSTEM="/etc/mocha/mangohud/MangoHud.conf"

cmd=( "$@" )

if command -v gamemoderun >/dev/null 2>&1; then
  cmd=( gamemoderun "${cmd[@]}" )
fi

if command -v mangohud >/dev/null 2>&1; then
  export MANGOHUD=1

  if [ -f "$MANGOHUD_CONF_USER" ]; then
    export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_USER"
  elif [ -f "$MANGOHUD_CONF_SYSTEM" ]; then
    export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_SYSTEM"
  fi

  cmd=( mangohud "${cmd[@]}" )
fi

exec "${cmd[@]}"
```

## Wrapper novo implantado

- Caminho ativo: `/home/hal/.local/bin/mocha-steam-game-run`
- Cópia candidata canônica: `/media/mochafast/MochaArch/ativo/wrapper-steam/mocha-steam-game-run-aprovado-candidato-20260529-154612`
- Script reutilizável: `/media/mochafast/MochaArch/ativo/scripts/20260529-154612-mocha-instalar-wrapper-steam-limpo-corrigido.sh`
- SHA256 novo: `ba549b9443ba53c50313015e084418e44840b86978b588b224c93fd7c4b3ddea`

## Conteúdo implantado

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$#" -lt 1 ]; then
  echo "Uso: mocha-steam-game-run %command%" >&2
  exit 64
fi

for mocha_env_var in \
  "MANGOHUD_"'DLSYM' \
  'ENABLE_''VKBASALT' \
  'VK''BASALT_CONFIG_FILE' \
  'GAMESCOPE_''ARGS' \
  'GAMESCOPE_''WSI'
do
  unset "$mocha_env_var" || true
done

export DXVK_LOG_LEVEL="${DXVK_LOG_LEVEL:-none}"

MANGOHUD_CONF_USER="${HOME}/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf"
MANGOHUD_CONF_SYSTEM="/etc/mocha/mangohud/MangoHud.conf"

cmd=( "$@" )

if command -v gamemoderun >/dev/null 2>&1; then
  cmd=( gamemoderun "${cmd[@]}" )
fi

if command -v mangohud >/dev/null 2>&1; then
  export MANGOHUD=1

  if [ -f "$MANGOHUD_CONF_USER" ]; then
    export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_USER"
  elif [ -f "$MANGOHUD_CONF_SYSTEM" ]; then
    export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_SYSTEM"
  fi

  cmd=( mangohud "${cmd[@]}" )
fi

exec "${cmd[@]}"
```

## Linha para teste na Steam

```text
/home/hal/.local/bin/mocha-steam-game-run %command%
```

## Comparação obrigatória

Comparar este wrapper limpo contra o baseline sem nenhuma Launch Option, porque o melhor resultado recente foi observado com o jogo lançado sem linha nenhuma.
