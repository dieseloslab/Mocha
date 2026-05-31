#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
REAL_USER="${SUDO_USER:-$USER}"
FAST_BASE="/media/mochafast/MochaArch"
DOC_DIR="$FAST_BASE/ativo/documentacao"
SCRIPT_DIR="$FAST_BASE/ativo/scripts"
REPORT_DIR="$FAST_BASE/ativo/relatorios"

SYSCTL_FILE="/etc/sysctl.d/zz-mocha-agressividade-normal.conf"
ZRAM_FILE="/etc/systemd/zram-generator.conf"
THP_FILE="/etc/tmpfiles.d/mocha-thp.conf"

LOG="/tmp/${TS}-mocha-agressividade-normal.log"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

backup_file() {
  local file="$1"
  local base name dir backup
  [ -e "$file" ] || return 0

  dir="$(dirname "$file")"
  name="$(basename "$file")"
  backup="${file}.bak-${TS}"

  sudo cp -a "$file" "$backup"
  printf 'Backup criado: %s\n' "$backup"

  # Mantém no máximo 2 backups por arquivo.
  mapfile -t olds < <(find "$dir" -maxdepth 1 -type f -name "${name}.bak-*" -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR>2 {print $2}')
  if [ "${#olds[@]}" -gt 0 ]; then
    printf 'Limpando backups excedentes de %s:\n' "$file"
    printf '  %s\n' "${olds[@]}"
    sudo rm -f -- "${olds[@]}"
  fi
}

say "MOCHA — restaurar agressividade normal/canônica"
echo "Timestamp: $TS"
echo "Log temporário: $LOG"

exec > >(tee -a "$LOG") 2>&1

say "Validando sudo e mantendo sessão ativa"
sudo -v
(
  while true; do
    sudo -n true 2>/dev/null || exit 0
    sleep 30
  done
) &
SUDO_KEEPALIVE_PID="$!"
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

say "Validando pasta MochaArch no FAST"
findmnt /media/mochafast >/dev/null || fail "/media/mochafast não está montado."
[ -d "$FAST_BASE" ] || fail "$FAST_BASE não existe."

mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR"

say "Auditando estado atual antes de alterar"
printf '\n-- Kernel --\n'
uname -r || true

printf '\n-- Valores sysctl atuais --\n'
for key in \
  vm.swappiness \
  vm.vfs_cache_pressure \
  vm.page-cluster \
  vm.dirty_background_bytes \
  vm.dirty_bytes \
  vm.max_map_count
do
  sysctl "$key" 2>/dev/null || true
done

printf '\n-- Arquivos sysctl que já citam esses valores --\n'
sudo grep -RInE 'vm\.swappiness|vm\.vfs_cache_pressure|vm\.page-cluster|vm\.dirty_background_bytes|vm\.dirty_bytes|vm\.max_map_count' \
  /etc/sysctl.conf /etc/sysctl.d /usr/lib/sysctl.d 2>/dev/null || true

printf '\n-- ZRAM atual --\n'
swapon --show || true
zramctl || true
[ -e /sys/block/zram0/comp_algorithm ] && cat /sys/block/zram0/comp_algorithm || true

printf '\n-- THP atual --\n'
[ -e /sys/kernel/mm/transparent_hugepage/enabled ] && cat /sys/kernel/mm/transparent_hugepage/enabled || true

printf '\n-- TuneD atual --\n'
systemctl is-enabled tuned.service 2>/dev/null || true
systemctl is-active tuned.service 2>/dev/null || true
command -v tuned-adm >/dev/null 2>&1 && tuned-adm active || true

printf '\n-- Governor CPU atual --\n'
if command -v cpupower >/dev/null 2>&1; then
  cpupower frequency-info -p 2>/dev/null || true
fi

say "Criando backups dos arquivos que serão sobrescritos"
backup_file "$SYSCTL_FILE"
backup_file "$ZRAM_FILE"
backup_file "$THP_FILE"

say "Escrevendo receita normal/canônica de agressividade"
sudo tee "$SYSCTL_FILE" >/dev/null <<'EOF'
# MOCHA — agressividade normal/canônica
# Receita meio termo turbo usada como padrão seguro para comparação de FPS.
# Gerenciado pelo projeto MochaArch.

vm.swappiness = 80
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.max_map_count = 16777216
EOF

sudo tee "$THP_FILE" >/dev/null <<'EOF'
# MOCHA — Transparent Huge Pages
# Mantém THP em madvise, evitando agressividade global excessiva.

w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise
EOF

sudo tee "$ZRAM_FILE" >/dev/null <<'EOF'
# MOCHA — zram normal/canônica
# Equivalente Arch da receita padrão:
# zram 100% RAM, algoritmo zstd, prioridade máxima.

[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 32767
EOF

say "Aplicando sysctl ao vivo"
sudo sysctl --system

say "Aplicando THP madvise ao vivo"
if [ -e /sys/kernel/mm/transparent_hugepage/enabled ]; then
  echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null
else
  echo "Aviso: THP não encontrado em /sys/kernel/mm/transparent_hugepage/enabled."
fi

say "Aplicando TuneD latency-performance se disponível"
if command -v tuned-adm >/dev/null 2>&1; then
  sudo systemctl enable --now tuned.service
  sudo tuned-adm profile latency-performance
else
  echo "Aviso: tuned-adm não encontrado; TuneD não foi alterado."
fi

say "Aplicando governor performance se cpupower estiver disponível"
if command -v cpupower >/dev/null 2>&1; then
  sudo cpupower frequency-set -g performance || true
  if systemctl list-unit-files cpupower.service >/dev/null 2>&1; then
    sudo systemctl enable --now cpupower.service || true
  fi
else
  echo "Aviso: cpupower não encontrado; governor não foi alterado por este script."
fi

say "Recarregando systemd para reconhecer zram-generator"
sudo systemctl daemon-reload

say "Tentando aplicar zram ao vivo apenas se for seguro"
ZRAM_RESTARTED="não"
ZRAM_SKIP_REASON=""

if systemctl list-unit-files 'systemd-zram-setup@.service' >/dev/null 2>&1 || systemctl status systemd-zram-setup@zram0.service >/dev/null 2>&1; then
  ZRAM_SWAP_USED_BYTES="$(swapon --bytes --show=NAME,USED 2>/dev/null | awk '$1 ~ /zram/ {sum += $2} END {print sum+0}')"

  if [ "$ZRAM_SWAP_USED_BYTES" -eq 0 ]; then
    echo "zram sem uso de swap; reiniciando zram0 para aplicar zstd/100%/32767 agora."
    sudo systemctl restart systemd-zram-setup@zram0.service || true
    ZRAM_RESTARTED="sim"
  else
    ZRAM_SKIP_REASON="zram possui ${ZRAM_SWAP_USED_BYTES} bytes em uso; não reiniciei para evitar travamento. A configuração entra completa no próximo boot."
    echo "Aviso: $ZRAM_SKIP_REASON"
  fi
else
  ZRAM_SKIP_REASON="serviço systemd-zram-setup@zram0 não encontrado; configuração foi escrita para o próximo boot se zram-generator estiver instalado."
  echo "Aviso: $ZRAM_SKIP_REASON"
fi

say "Validando resultado final"
printf '\n-- Valores sysctl finais --\n'
for key in \
  vm.swappiness \
  vm.vfs_cache_pressure \
  vm.page-cluster \
  vm.dirty_background_bytes \
  vm.dirty_bytes \
  vm.max_map_count
do
  sysctl "$key"
done

printf '\n-- THP final --\n'
[ -e /sys/kernel/mm/transparent_hugepage/enabled ] && cat /sys/kernel/mm/transparent_hugepage/enabled || true

printf '\n-- ZRAM final --\n'
swapon --show || true
zramctl || true
[ -e /sys/block/zram0/comp_algorithm ] && cat /sys/block/zram0/comp_algorithm || true

printf '\n-- TuneD final --\n'
command -v tuned-adm >/dev/null 2>&1 && tuned-adm active || true

say "Gravando documentação operacional"
DOC="$DOC_DIR/${TS}-agressividade-normal-canonica-restaurada.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-restaurar-agressividade-normal.sh"
FINAL_LOG="$REPORT_DIR/${TS}-mocha-agressividade-normal.log"

cp -a "$0" "$SCRIPT_COPY"
chmod +x "$SCRIPT_COPY"

cat > "$DOC" <<EOF
# MochaArch — agressividade normal/canônica restaurada

Data: ${TS}

## Valores aplicados

- \`vm.swappiness=80\`
- \`vm.vfs_cache_pressure=50\`
- \`vm.page-cluster=0\`
- \`vm.dirty_background_bytes=67108864\`
- \`vm.dirty_bytes=268435456\`
- \`vm.max_map_count=16777216\`
- THP: \`madvise\`
- zram: \`zstd\`, tamanho \`100% da RAM\`, prioridade \`32767\`
- TuneD: \`latency-performance\`, quando disponível
- CPU governor: \`performance\`, quando \`cpupower\` está disponível

## Arquivos ativos

- \`${SYSCTL_FILE}\`
- \`${THP_FILE}\`
- \`${ZRAM_FILE}\`

## Aplicação ao vivo

- Sysctl aplicado ao vivo: sim.
- THP aplicado ao vivo: sim.
- TuneD aplicado ao vivo se instalado: sim.
- zram reiniciado ao vivo: ${ZRAM_RESTARTED}.

Motivo caso zram não tenha sido reiniciado:

\`${ZRAM_SKIP_REASON:-nenhum}\`

## Observação para teste de FPS

Para comparação limpa, testar primeiro sem Launch Options extras na Steam ou somente com a linha oficial que estiver sendo avaliada no momento. Se zram não foi reiniciado ao vivo, reiniciar antes de considerar o teste final da receita normal.

## Script reutilizável

\`${SCRIPT_COPY}\`

## Log

\`${FINAL_LOG}\`
EOF

cp -a "$LOG" "$FINAL_LOG"

say "Resumo final"
echo "Documentação: $DOC"
echo "Script salvo:   $SCRIPT_COPY"
echo "Log salvo:      $FINAL_LOG"

if [ "$ZRAM_RESTARTED" != "sim" ]; then
  echo
  echo "Atenção: os sysctls e THP já foram aplicados ao vivo. A zram só fica 100% normal/canônica após reboot se ela não pôde ser reiniciada agora."
fi

echo
echo "MOCHA — agressividade normal/canônica aplicada."
