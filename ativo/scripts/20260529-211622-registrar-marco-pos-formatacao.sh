#!/usr/bin/env bash
set -Eeuo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
ACTIVE="$BASE/ativo"
DOC_DIR="$ACTIVE/documentacao"
LOG_DIR="$ACTIVE/logs"
SCRIPT_DIR="$ACTIVE/scripts"
MANUAL="$ACTIVE/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
DOC="$DOC_DIR/${TS}-MARCO-ESTADO-REPRODUZIDO-POS-FORMATACAO.md"
LOG="$LOG_DIR/${TS}-marco-estado-reproduzido-pos-formatacao.log"

say() { printf '\n== %s ==\n' "$*"; }
ok() { printf '%s\n' "[OK] $*"; }
fail() { printf '\nERRO: %s\n' "$*" >&2; exit 1; }

mkdir -p "$DOC_DIR" "$LOG_DIR" "$SCRIPT_DIR"
exec > >(tee -a "$LOG") 2>&1

say "Validando base antes de registrar marco"

findmnt /media/mochafast >/dev/null 2>&1 || fail "/media/mochafast não está montado."
findmnt /media/vmstore >/dev/null 2>&1 || fail "/media/vmstore não está montado."
[ -d "$ACTIVE" ] || fail "pasta ativa não encontrada: $ACTIVE"

KERNEL="$(uname -r)"
SESSION="${XDG_SESSION_TYPE:-desconhecido}"
DESKTOP="${XDG_CURRENT_DESKTOP:-desconhecido}"
COLOR="$(kreadconfig6 --file kdeglobals --group General --key ColorScheme 2>/dev/null || true)"
STYLE="$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null || true)"
DM_TARGET="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
TUNED="$(tuned-adm active 2>/dev/null | tr '\n' ' ' || true)"
CPU_GOV="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || true)"
NVIDIA="$(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null | head -n1 || true)"
ZRAM="$(swapon --show=NAME,TYPE,SIZE,PRIO 2>/dev/null | grep -i zram || true)"

say "Criando documento do marco"

cat > "$DOC" <<EOF
# MARCO - Estado Mocha Arch/KDE reproduzido pós-formatação

Data: $TS

Status informado pelo usuário:

- Aparentemente está tudo perfeito.
- O estado da máquina foi reproduzido como estava antes da formatação.
- Ainda falta testar jogos.

Estado técnico observado:

- Kernel: $KERNEL
- Sessão: $SESSION
- Desktop: $DESKTOP
- Login manager: $DM_TARGET
- NVIDIA: ${NVIDIA:-não consultada}
- TuneD: ${TUNED:-não consultado}
- CPU governor: ${CPU_GOV:-não consultado}
- ColorScheme KDE: ${COLOR:-desconhecido}
- Plasma Style: ${STYLE:-desconhecido}
- zram: ${ZRAM:-não detectada}

Itens já reproduzidos/validados no fluxo:

- FAST e VMSTORE montados e persistentes.
- Login manager corrigido para caminho Plasma/KDE.
- Sessão Wayland preservada.
- Kernel Zen ativo.
- NVIDIA open funcional.
- Receita de agressividade/performance ativa.
- TuneD em latency-performance.
- CPU em governor performance.
- zram ativa.
- Duplicidade de Bluetooth e volume corrigida via autostart Hidden=true para blueman-applet e kmix.
- Tema Mocha aplicado.
- Wallpaper Mocha aplicado.
- Barra Mocha/Win11 aprovada aplicada.

Pendência:

- Testar jogos antes de tratar este estado como desempenho aprovado/canonizado.

Regra para próximos passos:

- Não mexer na base reproduzida antes dos testes.
- Testar jogos primeiro sem Launch Options, preservando o baseline que funcionou bem anteriormente.
- Não reintroduzir wrapper, MangoHud forçado, vkbasalt, gamescope ou MANGOHUD_DLSYM sem teste separado.
- Documentar cada jogo/teste com FPS, fluidez, imagem, som e eventuais travamentos.
EOF

if [ -f "$MANUAL" ]; then
  {
    printf '\n'
    printf '%s\n' "## $TS - Marco pós-formatação: estado Mocha reproduzido"
    printf '\n'
    printf '%s\n' "- Usuário confirmou que aparentemente está tudo perfeito."
    printf '%s\n' "- Estado pré-formatação reproduzido com sucesso visual/funcional."
    printf '%s\n' "- Pendência: testar jogos antes de canonizar desempenho."
    printf '%s\n' "- Documento do marco: $DOC"
    printf '%s\n' "- Log: $LOG"
  } >> "$MANUAL"
  ok "Manual vivo atualizado"
else
  fail "Manual vivo não encontrado: $MANUAL"
fi

REUSABLE="$SCRIPT_DIR/${TS}-registrar-marco-pos-formatacao.sh"
cp -a "$0" "$REUSABLE"
chmod +x "$REUSABLE"

say "Finalizado"
printf '%s\n' "[OK] Marco registrado: $DOC"
printf '%s\n' "[OK] Manual atualizado: $MANUAL"
printf '%s\n' "[OK] Script reutilizável: $REUSABLE"
printf '%s\n' "[OK] Log: $LOG"
