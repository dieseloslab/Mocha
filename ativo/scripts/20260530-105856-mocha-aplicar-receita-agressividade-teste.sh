#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"

FAST_BASE="/media/mochafast/MochaArch"
ACTIVE="$FAST_BASE/ativo"

DOC_DIR="$ACTIVE/documentacao"
SCRIPT_DIR="$ACTIVE/scripts"
REPORT_DIR="$ACTIVE/relatorios"

MANUAL="$DOC_DIR/MANUAL-INSTALACAO-MOCHA-ARCH-ORDEM.md"

LOG="$REPORT_DIR/${TS}-aplicar-receita-agressividade-teste.log"
AUDIT_MANUAL="$REPORT_DIR/${TS}-leitura-manual-antes-agressividade-teste.txt"
STATE_BEFORE="$REPORT_DIR/${TS}-estado-antes-agressividade-teste.txt"
STATE_AFTER="$REPORT_DIR/${TS}-estado-depois-agressividade-teste.txt"
DOC="$DOC_DIR/${TS}-receita-agressividade-teste-aplicada.md"

SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-aplicar-receita-agressividade-teste.sh"
ROLLBACK="$SCRIPT_DIR/${TS}-mocha-rollback-receita-agressividade-teste.sh"

SYSCTL_CONF="/etc/sysctl.d/99-mocha-agressividade-teste.conf"
THP_SERVICE="/etc/systemd/system/mocha-thp-madvise.service"
CPU_SERVICE="/etc/systemd/system/mocha-cpu-performance.service"
ZRAM_DROPIN_DIR="/etc/systemd/zram-generator.conf.d"
ZRAM_DROPIN="$ZRAM_DROPIN_DIR/99-mocha-agressividade-teste.conf"

TARGET_SWAPPINESS="100"
TARGET_VFS_CACHE_PRESSURE="35"
TARGET_PAGE_CLUSTER="0"
TARGET_DIRTY_BACKGROUND_BYTES="100663296"
TARGET_DIRTY_BYTES="402653184"
TARGET_MAX_MAP_COUNT="33554432"
TARGET_SCHED_AUTOGROUP="0"
TARGET_NMI_WATCHDOG="0"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

sudo_bin() {
  if [ -x /run/wrappers/bin/sudo ]; then
    printf '%s\n' /run/wrappers/bin/sudo
  else
    command -v sudo
  fi
}

read_file_or_na() {
  local file="$1"
  if [ -r "$file" ]; then
    cat "$file"
  else
    printf 'indisponível'
  fi
}

sysctl_value_or_empty() {
  local key="$1"
  sysctl -n "$key" 2>/dev/null || true
}

backup_root_file() {
  local file="$1"
  local backup_dir="$2"

  if [ -e "$file" ]; then
    mkdir -p "$backup_dir"
    "$SUDO" cp -a "$file" "$backup_dir/$(basename "$file").backup-$TS"
    printf '%s\n' "$backup_dir/$(basename "$file").backup-$TS"
  fi
}

write_lines_root() {
  local target="$1"
  local tmp="$2"

  "$SUDO" install -Dm644 "$tmp" "$target"
}

append_doc() {
  printf '%s\n' "$*" >> "$DOC"
}

append_manual() {
  printf '%s\n' "$*" >> "$MANUAL"
}

SUDO="$(sudo_bin)"

say "Validando estrutura obrigatória"
findmnt -rno TARGET /media/mochafast >/dev/null 2>&1 || fail "/media/mochafast não está montado."
mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR"

[ -f "$MANUAL" ] || fail "Manual não encontrado: $MANUAL"

say "Solicitando sudo uma vez e mantendo sessão ativa"
"$SUDO" -v
(
  while true; do
    "$SUDO" -n true 2>/dev/null || exit 0
    sleep 30
  done
) &
SUDO_KEEPALIVE_PID="$!"
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

exec > >(tee -a "$LOG") 2>&1

say "Lendo o manual antes de editar"
{
  printf 'Leitura feita em: %s\n' "$TS"
  printf 'Manual: %s\n\n' "$MANUAL"

  printf 'Títulos do manual:\n'
  grep -nE '^(#|##|###) ' "$MANUAL" || true
  printf '\n'

  printf 'Seção de performance/agressividade atual:\n'
  awk '
    /^## 6[.] / { inside=1 }
    inside { print }
    inside && /^## 7[.] / { exit }
  ' "$MANUAL" || true
  printf '\n'

  printf 'Menções atuais a receita/agressividade:\n'
  grep -niE 'zram|agress|receita|sysctl|swappiness|vfs_cache|page-cluster|dirty_|max_map_count|sched_autogroup|thp|transparent_hugepage|tuned|latency-performance|governor|performance|nvidia|gamemode|mangohud' "$MANUAL" || true
} > "$AUDIT_MANUAL"

say "Capturando valores atuais para relatório e rollback"
BEFORE_SWAPPINESS="$(sysctl_value_or_empty vm.swappiness)"
BEFORE_VFS_CACHE_PRESSURE="$(sysctl_value_or_empty vm.vfs_cache_pressure)"
BEFORE_PAGE_CLUSTER="$(sysctl_value_or_empty vm.page-cluster)"
BEFORE_DIRTY_BACKGROUND_BYTES="$(sysctl_value_or_empty vm.dirty_background_bytes)"
BEFORE_DIRTY_BYTES="$(sysctl_value_or_empty vm.dirty_bytes)"
BEFORE_MAX_MAP_COUNT="$(sysctl_value_or_empty vm.max_map_count)"
BEFORE_SCHED_AUTOGROUP="$(sysctl_value_or_empty kernel.sched_autogroup_enabled)"
BEFORE_NMI_WATCHDOG="$(sysctl_value_or_empty kernel.nmi_watchdog)"

{
  printf 'Estado antes da receita agressiva de teste: %s\n\n' "$TS"

  printf 'Kernel:\n'
  uname -r || true
  printf '\n\n'

  printf 'Sessão:\n'
  printf 'XDG_SESSION_TYPE=%s\n' "${XDG_SESSION_TYPE:-indisponível}"
  printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-indisponível}"
  printf '\n'

  printf 'TuneD:\n'
  if have tuned-adm; then tuned-adm active || true; else printf 'tuned-adm não encontrado\n'; fi
  if have systemctl; then systemctl is-active tuned 2>/dev/null || true; fi
  printf '\n\n'

  printf 'CPU:\n'
  printf 'cpu0 scaling_governor: '
  read_file_or_na /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  printf '\n'
  printf 'cpu0 energy_performance_preference: '
  read_file_or_na /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
  printf '\n\n'

  printf 'NVIDIA:\n'
  if have nvidia-smi; then
    nvidia-smi --query-gpu=name,driver_version,persistence_mode,power.management,power.draw,power.limit,clocks.current.graphics,clocks.current.memory --format=csv,noheader,nounits 2>/dev/null || nvidia-smi || true
  else
    printf 'nvidia-smi não encontrado\n'
  fi
  printf '\n\n'

  printf 'Sysctl antes:\n'
  for key in \
    vm.swappiness \
    vm.vfs_cache_pressure \
    vm.page-cluster \
    vm.dirty_background_bytes \
    vm.dirty_bytes \
    vm.max_map_count \
    kernel.sched_autogroup_enabled \
    kernel.nmi_watchdog
  do
    sysctl "$key" 2>/dev/null || printf '%s = indisponível\n' "$key"
  done
  printf '\n'

  printf 'THP antes:\n'
  printf 'enabled: '
  read_file_or_na /sys/kernel/mm/transparent_hugepage/enabled
  printf '\n'
  printf 'defrag: '
  read_file_or_na /sys/kernel/mm/transparent_hugepage/defrag
  printf '\n\n'

  printf 'ZRAM/swap antes:\n'
  if have zramctl; then zramctl || true; else printf 'zramctl não encontrado\n'; fi
  printf '\n'
  swapon --show || true
} > "$STATE_BEFORE"

BACKUP_DIR="$REPORT_DIR/${TS}-backups-root-agressividade-teste"
mkdir -p "$BACKUP_DIR"

say "Criando backups de arquivos que serão tocados"
backup_root_file "$SYSCTL_CONF" "$BACKUP_DIR" || true
backup_root_file "$THP_SERVICE" "$BACKUP_DIR" || true
backup_root_file "$CPU_SERVICE" "$BACKUP_DIR" || true
backup_root_file "$ZRAM_DROPIN" "$BACKUP_DIR" || true

say "Gravando sysctl agressivo de teste"
TMP_SYSCTL="/tmp/${TS}-99-mocha-agressividade-teste.conf"
: > "$TMP_SYSCTL"
printf '%s\n' '# Mocha Arch — receita de agressividade TESTE, não canonizada' >> "$TMP_SYSCTL"
printf '%s\n' "# Gerado em: $TS" >> "$TMP_SYSCTL"
printf '%s\n' '# Reversível pelo script de rollback salvo em MochaArch/ativo/scripts.' >> "$TMP_SYSCTL"
printf '%s\n' "vm.swappiness = $TARGET_SWAPPINESS" >> "$TMP_SYSCTL"
printf '%s\n' "vm.vfs_cache_pressure = $TARGET_VFS_CACHE_PRESSURE" >> "$TMP_SYSCTL"
printf '%s\n' "vm.page-cluster = $TARGET_PAGE_CLUSTER" >> "$TMP_SYSCTL"
printf '%s\n' "vm.dirty_background_bytes = $TARGET_DIRTY_BACKGROUND_BYTES" >> "$TMP_SYSCTL"
printf '%s\n' "vm.dirty_bytes = $TARGET_DIRTY_BYTES" >> "$TMP_SYSCTL"
printf '%s\n' "vm.max_map_count = $TARGET_MAX_MAP_COUNT" >> "$TMP_SYSCTL"
printf '%s\n' "kernel.sched_autogroup_enabled = $TARGET_SCHED_AUTOGROUP" >> "$TMP_SYSCTL"
printf '%s\n' "kernel.nmi_watchdog = $TARGET_NMI_WATCHDOG" >> "$TMP_SYSCTL"

write_lines_root "$SYSCTL_CONF" "$TMP_SYSCTL"

say "Aplicando sysctl agora"
"$SUDO" sysctl -p "$SYSCTL_CONF"

say "Gravando serviço THP madvise"
TMP_THP="/tmp/${TS}-mocha-thp-madvise.service"
: > "$TMP_THP"
printf '%s\n' '[Unit]' >> "$TMP_THP"
printf '%s\n' 'Description=Mocha THP madvise' >> "$TMP_THP"
printf '%s\n' 'After=multi-user.target' >> "$TMP_THP"
printf '%s\n' '' >> "$TMP_THP"
printf '%s\n' '[Service]' >> "$TMP_THP"
printf '%s\n' 'Type=oneshot' >> "$TMP_THP"
printf '%s\n' "ExecStart=/bin/sh -c 'test -w /sys/kernel/mm/transparent_hugepage/enabled && echo madvise > /sys/kernel/mm/transparent_hugepage/enabled || true'" >> "$TMP_THP"
printf '%s\n' "ExecStart=/bin/sh -c 'test -w /sys/kernel/mm/transparent_hugepage/defrag && echo madvise > /sys/kernel/mm/transparent_hugepage/defrag || true'" >> "$TMP_THP"
printf '%s\n' 'RemainAfterExit=yes' >> "$TMP_THP"
printf '%s\n' '' >> "$TMP_THP"
printf '%s\n' '[Install]' >> "$TMP_THP"
printf '%s\n' 'WantedBy=multi-user.target' >> "$TMP_THP"

write_lines_root "$THP_SERVICE" "$TMP_THP"

say "Gravando serviço CPU performance"
TMP_CPU="/tmp/${TS}-mocha-cpu-performance.service"
: > "$TMP_CPU"
printf '%s\n' '[Unit]' >> "$TMP_CPU"
printf '%s\n' 'Description=Mocha CPU performance governor' >> "$TMP_CPU"
printf '%s\n' 'After=multi-user.target' >> "$TMP_CPU"
printf '%s\n' '' >> "$TMP_CPU"
printf '%s\n' '[Service]' >> "$TMP_CPU"
printf '%s\n' 'Type=oneshot' >> "$TMP_CPU"
printf '%s\n' "ExecStart=/bin/sh -c 'for g in /sys/devices/system/cpu/cpufreq/policy*/scaling_governor; do [ -e \"\$g\" ] || continue; echo performance > \"\$g\" || true; done'" >> "$TMP_CPU"
printf '%s\n' "ExecStart=/bin/sh -c 'for e in /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference; do [ -e \"\$e\" ] || continue; echo performance > \"\$e\" || true; done'" >> "$TMP_CPU"
printf '%s\n' 'RemainAfterExit=yes' >> "$TMP_CPU"
printf '%s\n' '' >> "$TMP_CPU"
printf '%s\n' '[Install]' >> "$TMP_CPU"
printf '%s\n' 'WantedBy=multi-user.target' >> "$TMP_CPU"

write_lines_root "$CPU_SERVICE" "$TMP_CPU"

say "Ativando serviços THP e CPU performance"
"$SUDO" systemctl daemon-reload
"$SUDO" systemctl enable --now mocha-thp-madvise.service
"$SUDO" systemctl enable --now mocha-cpu-performance.service

say "Ativando TuneD latency-performance, se disponível"
if have tuned-adm; then
  "$SUDO" systemctl enable --now tuned.service || true
  "$SUDO" tuned-adm profile latency-performance || true
else
  printf '%s\n' 'tuned-adm não encontrado; TuneD não foi alterado.'
fi

say "Ajustando NVIDIA persistenced, se disponível"
if have nvidia-smi; then
  "$SUDO" nvidia-smi -pm 1 || true
fi

if systemctl list-unit-files nvidia-persistenced.service >/dev/null 2>&1; then
  "$SUDO" systemctl enable --now nvidia-persistenced.service || true
fi

say "Gravando drop-in ZRAM agressivo para próximo boot ou ativação segura"
if [ -x /usr/lib/systemd/system-generators/zram-generator ] || [ -x /usr/local/lib/systemd/system-generators/zram-generator ] || have zram-generator; then
  TMP_ZRAM="/tmp/${TS}-99-mocha-agressividade-teste-zram.conf"
  : > "$TMP_ZRAM"
  printf '%s\n' '# Mocha Arch — ZRAM agressiva de teste, não canonizada' >> "$TMP_ZRAM"
  printf '%s\n' "# Gerado em: $TS" >> "$TMP_ZRAM"
  printf '%s\n' '[zram0]' >> "$TMP_ZRAM"
  printf '%s\n' 'zram-size = ram' >> "$TMP_ZRAM"
  printf '%s\n' 'compression-algorithm = zstd' >> "$TMP_ZRAM"
  printf '%s\n' 'swap-priority = 32767' >> "$TMP_ZRAM"
  printf '%s\n' 'fs-type = swap' >> "$TMP_ZRAM"

  "$SUDO" mkdir -p "$ZRAM_DROPIN_DIR"
  write_lines_root "$ZRAM_DROPIN" "$TMP_ZRAM"
  "$SUDO" systemctl daemon-reload

  if swapon --show | grep -qi zram; then
    printf '%s\n' 'ZRAM já está ativa; não vou reiniciar swap/ZRAM durante a sessão para evitar travamento. O drop-in vale no próximo boot.'
  else
    "$SUDO" systemctl start systemd-zram-setup@zram0.service || true
  fi
else
  printf '%s\n' 'zram-generator não encontrado; não foi criado drop-in ZRAM.'
fi

say "Criando script de rollback"
TMP_ROLLBACK="/tmp/${TS}-rollback-agressividade.sh"
: > "$TMP_ROLLBACK"
printf '%s\n' '#!/usr/bin/env bash' >> "$TMP_ROLLBACK"
printf '%s\n' 'set -Eeuo pipefail' >> "$TMP_ROLLBACK"
printf '%s\n' 'PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"' >> "$TMP_ROLLBACK"
printf '%s\n' 'if [ -x /run/wrappers/bin/sudo ]; then SUDO=/run/wrappers/bin/sudo; else SUDO="$(command -v sudo)"; fi' >> "$TMP_ROLLBACK"
printf '%s\n' 'TS_ROLLBACK="$(date +%Y%m%d-%H%M%S)"' >> "$TMP_ROLLBACK"
printf '%s\n' 'say(){ printf "\n== %s ==\n" "$*"; }' >> "$TMP_ROLLBACK"
printf '%s\n' 'say "Solicitando sudo uma vez"' >> "$TMP_ROLLBACK"
printf '%s\n' '"$SUDO" -v' >> "$TMP_ROLLBACK"
printf '%s\n' 'say "Desativando serviços de teste Mocha"' >> "$TMP_ROLLBACK"
printf '%s\n' '"$SUDO" systemctl disable --now mocha-thp-madvise.service 2>/dev/null || true' >> "$TMP_ROLLBACK"
printf '%s\n' '"$SUDO" systemctl disable --now mocha-cpu-performance.service 2>/dev/null || true' >> "$TMP_ROLLBACK"
printf '%s\n' 'say "Removendo arquivos persistentes de teste"' >> "$TMP_ROLLBACK"
printf '%s\n' 'for f in /etc/sysctl.d/99-mocha-agressividade-teste.conf /etc/systemd/system/mocha-thp-madvise.service /etc/systemd/system/mocha-cpu-performance.service /etc/systemd/zram-generator.conf.d/99-mocha-agressividade-teste.conf; do if [ -e "$f" ]; then "$SUDO" mv "$f" "${f}.disabled-${TS_ROLLBACK}"; fi; done' >> "$TMP_ROLLBACK"
printf '%s\n' 'say "Restaurando sysctl que estavam ativos antes do teste, ao vivo"' >> "$TMP_ROLLBACK"
if [ -n "$BEFORE_SWAPPINESS" ]; then printf '%s\n' "\"\$SUDO\" sysctl -w vm.swappiness=$BEFORE_SWAPPINESS || true" >> "$TMP_ROLLBACK"; fi
if [ -n "$BEFORE_VFS_CACHE_PRESSURE" ]; then printf '%s\n' "\"\$SUDO\" sysctl -w vm.vfs_cache_pressure=$BEFORE_VFS_CACHE_PRESSURE || true" >> "$TMP_ROLLBACK"; fi
if [ -n "$BEFORE_PAGE_CLUSTER" ]; then printf '%s\n' "\"\$SUDO\" sysctl -w vm.page-cluster=$BEFORE_PAGE_CLUSTER || true" >> "$TMP_ROLLBACK"; fi
if [ -n "$BEFORE_DIRTY_BACKGROUND_BYTES" ]; then printf '%s\n' "\"\$SUDO\" sysctl -w vm.dirty_background_bytes=$BEFORE_DIRTY_BACKGROUND_BYTES || true" >> "$TMP_ROLLBACK"; fi
if [ -n "$BEFORE_DIRTY_BYTES" ]; then printf '%s\n' "\"\$SUDO\" sysctl -w vm.dirty_bytes=$BEFORE_DIRTY_BYTES || true" >> "$TMP_ROLLBACK"; fi
if [ -n "$BEFORE_MAX_MAP_COUNT" ]; then printf '%s\n' "\"\$SUDO\" sysctl -w vm.max_map_count=$BEFORE_MAX_MAP_COUNT || true" >> "$TMP_ROLLBACK"; fi
if [ -n "$BEFORE_SCHED_AUTOGROUP" ]; then printf '%s\n' "\"\$SUDO\" sysctl -w kernel.sched_autogroup_enabled=$BEFORE_SCHED_AUTOGROUP || true" >> "$TMP_ROLLBACK"; fi
if [ -n "$BEFORE_NMI_WATCHDOG" ]; then printf '%s\n' "\"\$SUDO\" sysctl -w kernel.nmi_watchdog=$BEFORE_NMI_WATCHDOG || true" >> "$TMP_ROLLBACK"; fi
printf '%s\n' 'say "Recarregando systemd"' >> "$TMP_ROLLBACK"
printf '%s\n' '"$SUDO" systemctl daemon-reload' >> "$TMP_ROLLBACK"
printf '%s\n' 'say "Rollback concluído. Reinicie para garantir que ZRAM volte ao estado anterior se ela tiver sido alterada no boot."' >> "$TMP_ROLLBACK"

install -Dm755 "$TMP_ROLLBACK" "$ROLLBACK"

say "Coletando estado depois"
{
  printf 'Estado depois da receita agressiva de teste: %s\n\n' "$TS"

  printf 'Kernel:\n'
  uname -r || true
  printf '\n\n'

  printf 'Sessão:\n'
  printf 'XDG_SESSION_TYPE=%s\n' "${XDG_SESSION_TYPE:-indisponível}"
  printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-indisponível}"
  printf '\n'

  printf 'TuneD:\n'
  if have tuned-adm; then tuned-adm active || true; else printf 'tuned-adm não encontrado\n'; fi
  if have systemctl; then systemctl is-active tuned 2>/dev/null || true; fi
  printf '\n\n'

  printf 'CPU:\n'
  printf 'cpu0 scaling_governor: '
  read_file_or_na /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  printf '\n'
  printf 'cpu0 energy_performance_preference: '
  read_file_or_na /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
  printf '\n\n'

  printf 'NVIDIA:\n'
  if have nvidia-smi; then
    nvidia-smi --query-gpu=name,driver_version,persistence_mode,power.management,power.draw,power.limit,clocks.current.graphics,clocks.current.memory --format=csv,noheader,nounits 2>/dev/null || nvidia-smi || true
  else
    printf 'nvidia-smi não encontrado\n'
  fi
  printf '\n\n'

  printf 'Sysctl depois:\n'
  for key in \
    vm.swappiness \
    vm.vfs_cache_pressure \
    vm.page-cluster \
    vm.dirty_background_bytes \
    vm.dirty_bytes \
    vm.max_map_count \
    kernel.sched_autogroup_enabled \
    kernel.nmi_watchdog
  do
    sysctl "$key" 2>/dev/null || printf '%s = indisponível\n' "$key"
  done
  printf '\n'

  printf 'THP depois:\n'
  printf 'enabled: '
  read_file_or_na /sys/kernel/mm/transparent_hugepage/enabled
  printf '\n'
  printf 'defrag: '
  read_file_or_na /sys/kernel/mm/transparent_hugepage/defrag
  printf '\n\n'

  printf 'ZRAM/swap depois:\n'
  if have zramctl; then zramctl || true; else printf 'zramctl não encontrado\n'; fi
  printf '\n'
  swapon --show || true
} > "$STATE_AFTER"

say "Registrando documentação do teste"
: > "$DOC"
append_doc "# Receita de agressividade de teste — Mocha Arch"
append_doc ""
append_doc "Gerado em: $TS"
append_doc ""
append_doc "Este teste aumenta a agressividade da receita sem canonizar os valores."
append_doc ""
append_doc "## Valores aplicados"
append_doc ""
append_doc "- vm.swappiness=$TARGET_SWAPPINESS"
append_doc "- vm.vfs_cache_pressure=$TARGET_VFS_CACHE_PRESSURE"
append_doc "- vm.page-cluster=$TARGET_PAGE_CLUSTER"
append_doc "- vm.dirty_background_bytes=$TARGET_DIRTY_BACKGROUND_BYTES"
append_doc "- vm.dirty_bytes=$TARGET_DIRTY_BYTES"
append_doc "- vm.max_map_count=$TARGET_MAX_MAP_COUNT"
append_doc "- kernel.sched_autogroup_enabled=$TARGET_SCHED_AUTOGROUP"
append_doc "- kernel.nmi_watchdog=$TARGET_NMI_WATCHDOG"
append_doc "- THP=madvise"
append_doc "- TuneD=latency-performance, se disponível"
append_doc "- CPU=performance, quando suportado pelo driver cpufreq"
append_doc "- NVIDIA persistence mode tentou ser ativado com nvidia-smi, se disponível"
append_doc "- ZRAM drop-in: zstd, zram-size=ram, swap-priority=32767, sem reiniciar ZRAM ativa durante a sessão"
append_doc ""
append_doc "## Arquivos criados/alterados"
append_doc ""
append_doc "- $SYSCTL_CONF"
append_doc "- $THP_SERVICE"
append_doc "- $CPU_SERVICE"
append_doc "- $ZRAM_DROPIN"
append_doc ""
append_doc "## Relatórios"
append_doc ""
append_doc "- Manual lido antes de editar: $AUDIT_MANUAL"
append_doc "- Estado antes: $STATE_BEFORE"
append_doc "- Estado depois: $STATE_AFTER"
append_doc "- Log: $LOG"
append_doc "- Rollback: $ROLLBACK"
append_doc ""
append_doc "## Critério de teste"
append_doc ""
append_doc "Testar jogos nos cenários:"
append_doc ""
append_doc "1. Sem Launch Options."
append_doc "2. gamemoderun %command%."
append_doc "3. mangohud gamemoderun %command%."
append_doc ""
append_doc "Se aparecer stutter, queda de FPS, travamento ou piora de imagem/fluidez, rodar auditoria e comparar os relatórios antes/depois. O rollback está salvo no caminho indicado acima."

say "Anexando registro ao manual principal"
{
  printf '\n'
  printf '%s\n' "## Registro $TS — receita de agressividade de teste"
  printf '\n'
  printf '%s\n' "Foi aplicada uma receita de agressividade candidata, não canonizada."
  printf '\n'
  printf '%s\n' "Valores principais:"
  printf '\n'
  printf '%s\n' "- vm.swappiness=$TARGET_SWAPPINESS"
  printf '%s\n' "- vm.vfs_cache_pressure=$TARGET_VFS_CACHE_PRESSURE"
  printf '%s\n' "- vm.page-cluster=$TARGET_PAGE_CLUSTER"
  printf '%s\n' "- vm.dirty_background_bytes=$TARGET_DIRTY_BACKGROUND_BYTES"
  printf '%s\n' "- vm.dirty_bytes=$TARGET_DIRTY_BYTES"
  printf '%s\n' "- vm.max_map_count=$TARGET_MAX_MAP_COUNT"
  printf '%s\n' "- kernel.sched_autogroup_enabled=$TARGET_SCHED_AUTOGROUP"
  printf '%s\n' "- kernel.nmi_watchdog=$TARGET_NMI_WATCHDOG"
  printf '%s\n' "- THP=madvise"
  printf '%s\n' "- TuneD=latency-performance"
  printf '%s\n' "- CPU=performance"
  printf '%s\n' "- ZRAM=zstd, zram-size=ram, swap-priority=32767"
  printf '\n'
  printf '%s\n' "Relatórios:"
  printf '\n'
  printf '%s\n' "- $AUDIT_MANUAL"
  printf '%s\n' "- $STATE_BEFORE"
  printf '%s\n' "- $STATE_AFTER"
  printf '%s\n' "- $DOC"
  printf '%s\n' "- Rollback: $ROLLBACK"
} >> "$MANUAL"

say "Salvando cópia do script usado"
cp -a "$0" "$SCRIPT_COPY"
chmod +x "$SCRIPT_COPY"

say "Validação final"
grep -q "vm.swappiness = $TARGET_SWAPPINESS" "$SYSCTL_CONF" || fail "sysctl de teste não foi gravado corretamente."
grep -q "vm.max_map_count = $TARGET_MAX_MAP_COUNT" "$SYSCTL_CONF" || fail "max_map_count de teste não foi gravado corretamente."
grep -q 'zram-size = ram' "$ZRAM_DROPIN" 2>/dev/null || printf '%s\n' 'Aviso: drop-in ZRAM não foi criado porque zram-generator não foi encontrado.'
grep -q "receita de agressividade de teste" "$MANUAL" || fail "manual não recebeu registro do teste."

say "Resumo"
printf 'Sysctl aplicado: %s\n' "$SYSCTL_CONF"
printf 'Serviço THP: %s\n' "$THP_SERVICE"
printf 'Serviço CPU: %s\n' "$CPU_SERVICE"
printf 'Drop-in ZRAM: %s\n' "$ZRAM_DROPIN"
printf 'Relatório antes: %s\n' "$STATE_BEFORE"
printf 'Relatório depois: %s\n' "$STATE_AFTER"
printf 'Documento do teste: %s\n' "$DOC"
printf 'Rollback: %s\n' "$ROLLBACK"
printf 'Log: %s\n' "$LOG"
printf 'Script salvo: %s\n' "$SCRIPT_COPY"

say "Concluído"
