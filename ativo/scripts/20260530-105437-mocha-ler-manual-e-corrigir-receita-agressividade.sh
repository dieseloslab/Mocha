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
BACKUP="$DOC_DIR/${TS}-backup-MANUAL-INSTALACAO-MOCHA-ARCH-ORDEM.md"
NEW_MANUAL="$DOC_DIR/${TS}-manual-instalacao-mocha-arch-receita-agressividade-corrigida.md"

AUDIT="$REPORT_DIR/${TS}-leitura-manual-antes-da-correcao-agressividade.txt"
STATE="$REPORT_DIR/${TS}-estado-real-receita-agressividade.txt"
SECTION="/tmp/${TS}-secao-06-receita-agressividade.md"
TMP="/tmp/${TS}-manual-corrigido.md"
LOG="$REPORT_DIR/${TS}-corrigir-manual-receita-agressividade.log"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-ler-manual-e-corrigir-receita-agressividade.sh"

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

read_file_or_na() {
  local file="$1"
  if [ -r "$file" ]; then
    cat "$file"
  else
    printf 'indisponível'
  fi
}

append() {
  printf '%s\n' "$*" >> "$SECTION"
}

blank() {
  printf '\n' >> "$SECTION"
}

say "Validando estrutura"
findmnt -rno TARGET /media/mochafast >/dev/null 2>&1 || fail "/media/mochafast não está montado."
mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR"
[ -f "$MANUAL" ] || fail "Manual não encontrado: $MANUAL"

exec > >(tee -a "$LOG") 2>&1

say "Lendo o manual atual antes de editar"
{
  printf 'Leitura feita em: %s\n' "$TS"
  printf 'Manual lido: %s\n\n' "$MANUAL"

  printf 'Resumo do arquivo:\n'
  wc -l "$MANUAL" || true
  printf '\n'

  printf 'Títulos encontrados:\n'
  grep -nE '^(#|##|###) ' "$MANUAL" || true
  printf '\n'

  printf 'Seção 6 atual, antes da correção:\n'
  awk '
    /^## 6[.] / { inside=1 }
    inside { print }
    inside && /^## 7[.] / { exit }
  ' "$MANUAL" || true
  printf '\n'

  printf 'Menções atuais a termos de performance/agressividade:\n'
  grep -niE 'zram|agress|receita|sysctl|swappiness|vfs_cache|page-cluster|dirty_|max_map_count|sched_autogroup|transparent huge|thp|tuned|latency-performance|performance|governor|nvidia|powermizer|gamemode|mangohud' "$MANUAL" || true
} > "$AUDIT"

say "Auditoria do manual salva"
printf '%s\n' "$AUDIT"

say "Coletando estado real atual da máquina para anexar à documentação"
{
  printf 'Estado real coletado em: %s\n\n' "$TS"

  printf 'Kernel:\n'
  uname -r || true
  printf '\n\n'

  printf 'Sessão gráfica:\n'
  printf 'XDG_SESSION_TYPE=%s\n' "${XDG_SESSION_TYPE:-indisponível}"
  printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-indisponível}"
  printf '\n'

  printf 'TuneD:\n'
  if have tuned-adm; then
    tuned-adm active || true
  else
    printf 'tuned-adm não encontrado\n'
  fi
  if have systemctl; then
    printf 'systemctl is-active tuned: '
    systemctl is-active tuned 2>/dev/null || true
  fi
  printf '\n\n'

  printf 'CPU performance:\n'
  printf 'cpu0 scaling_governor: '
  read_file_or_na /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  printf '\n'
  printf 'cpu0 energy_performance_preference: '
  read_file_or_na /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
  printf '\n'
  if have cpupower; then
    printf '\ncpupower frequency-info -p:\n'
    cpupower frequency-info -p 2>/dev/null || true
  fi
  printf '\n\n'

  printf 'NVIDIA:\n'
  if have nvidia-smi; then
    nvidia-smi --query-gpu=name,driver_version,persistence_mode,power.management,power.draw,power.limit,clocks.current.graphics,clocks.current.memory --format=csv,noheader,nounits 2>/dev/null || nvidia-smi || true
  else
    printf 'nvidia-smi não encontrado\n'
  fi
  printf '\n\n'

  printf 'Sysctl da receita:\n'
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

  printf 'THP:\n'
  printf 'enabled: '
  read_file_or_na /sys/kernel/mm/transparent_hugepage/enabled
  printf '\n'
  printf 'defrag: '
  read_file_or_na /sys/kernel/mm/transparent_hugepage/defrag
  printf '\n\n'

  printf 'ZRAM e swap:\n'
  if have zramctl; then
    zramctl || true
  else
    printf 'zramctl não encontrado\n'
  fi
  printf '\n'
  swapon --show || true
  printf '\n\n'

  printf 'GameMode:\n'
  if have gamemoded; then
    gamemoded --version 2>/dev/null || true
  else
    printf 'gamemoded não encontrado\n'
  fi
  printf '\n'

  printf 'MangoHud:\n'
  if have mangohud; then
    mangohud --version 2>/dev/null || true
  else
    printf 'mangohud não encontrado\n'
  fi
  printf '\n'

  printf 'Arquivos de configuração MangoHud encontrados:\n'
  find "$HOME/.config/MangoHud" /etc 2>/dev/null -maxdepth 4 -type f \( -iname '*mangohud*.conf' -o -name 'MangoHud.conf' \) -print || true

} > "$STATE"

say "Fazendo backup do manual antes de publicar correção"
cp -a "$MANUAL" "$BACKUP"

say "Mantendo no máximo 2 backups do manual fixo"
find "$DOC_DIR" -maxdepth 1 -type f -name '*-backup-MANUAL-INSTALACAO-MOCHA-ARCH-ORDEM.md' -printf '%T@ %p\0' 2>/dev/null \
  | sort -z -nr \
  | tail -z -n +3 \
  | cut -z -d' ' -f2- \
  | xargs -0r rm -f --

say "Gerando seção 6 corrigida com a receita completa de agressividade"
: > "$SECTION"

append "## 6. Performance, energia e agressividade"
blank
append "Esta seção é obrigatória no manual porque a receita de agressividade do Mocha não se resume à ZRAM. ZRAM é apenas um dos componentes. A receita completa também inclui sysctl de memória/latência, THP, TuneD, CPU em performance, GPU NVIDIA em máximo desempenho quando aplicável, GameMode, MangoHud padrão Mocha e validação real em jogos."
blank

append "### 6.1 Receita de agressividade que não pode sumir do manual"
blank
append "A receita de agressividade deve aparecer explicitamente no manual com estes itens:"
blank
append "- CPU em modo performance."
append "- GPU NVIDIA em modo de máximo desempenho quando aplicável."
append "- TuneD ativo com perfil latency-performance."
append "- ZRAM ativa e configurada."
append "- THP em madvise."
append "- Sysctl de memória/latência documentado."
append "- GameMode instalado e funcional."
append "- MangoHud instalado e usando padrão visual Mocha."
append "- Baseline de jogo sem Launch Options preservado para comparação."
blank

append "### 6.2 Valores da receita meio termo turbo usada como referência"
blank
append "Estes valores precisam constar no manual para evitar que a receita seja reduzida erroneamente à ZRAM:"
blank
append "- vm.swappiness=80"
append "- vm.vfs_cache_pressure=50"
append "- vm.page-cluster=0"
append "- vm.dirty_background_bytes=67108864"
append "- vm.dirty_bytes=268435456"
append "- vm.max_map_count=16777216"
append "- kernel.sched_autogroup_enabled=0"
append "- transparent_hugepage=madvise"
append "- zram com compressão zstd quando a implementação usada permitir"
append "- zram com 100% de memória como alvo da receita"
append "- zram com prioridade alta, alvo 32767 quando a implementação usada permitir"
append "- TuneD habilitado"
append "- perfil TuneD: latency-performance"
blank
append "Se o estado real do Arch estiver diferente desses valores, isso deve ser registrado como divergência ou adaptação da montagem atual, não apagado do manual."
blank

append "### 6.3 CPU em performance"
blank
append "- A CPU deve priorizar desempenho, não economia."
append "- Validar governor em /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor."
append "- Quando existir energy_performance_preference, validar preferência em performance."
append "- Validar com cpupower quando disponível."
append "- A configuração precisa sobreviver ao reboot."
blank

append "### 6.4 TuneD latency-performance"
blank
append "- TuneD faz parte da receita de agressividade."
append "- O perfil esperado é latency-performance."
append "- Validar com tuned-adm active."
append "- Validar serviço ativo com systemctl is-active tuned."
append "- Não substituir por perfil experimental sem teste em jogo e aprovação."
blank

append "### 6.5 GPU NVIDIA em máximo desempenho"
blank
append "- A GPU NVIDIA deve preferir máximo desempenho quando a pilha atual permitir."
append "- Validar o driver com nvidia-smi."
append "- Registrar driver, power limit, clocks e modo de energia quando disponíveis."
append "- Evitar ajuste dependente de X11."
append "- Não alterar driver NVIDIA em atualização comum sem teste específico."
blank

append "### 6.6 Sysctl da receita"
blank
append "O manual deve registrar estes sysctl, mesmo quando o comando de instalação apenas validar o estado atual:"
blank
append "- vm.swappiness"
append "- vm.vfs_cache_pressure"
append "- vm.page-cluster"
append "- vm.dirty_background_bytes"
append "- vm.dirty_bytes"
append "- vm.max_map_count"
append "- kernel.sched_autogroup_enabled"
append "- kernel.nmi_watchdog, quando aplicado"
blank
append "A ausência desses valores no manual é falha de documentação, porque esconde parte da receita que influenciou o comportamento em jogo."
blank

append "### 6.7 Transparent Huge Pages"
blank
append "- THP deve ficar documentado como madvise na receita."
append "- Validar em /sys/kernel/mm/transparent_hugepage/enabled."
append "- Registrar defrag quando relevante."
append "- Não mudar THP sem novo teste real em jogo."
blank

append "### 6.8 ZRAM"
blank
append "- ZRAM é obrigatória, mas não é a receita inteira."
append "- Validar com zramctl."
append "- Validar com swapon --show."
append "- Registrar algoritmo, tamanho e prioridade."
append "- Alvo da receita: zstd, 100% de memória e prioridade 32767 quando a implementação usada permitir."
blank

append "### 6.9 GameMode"
blank
append "- GameMode deve estar instalado e funcional."
append "- Linha Steam para testar somente GameMode:"
append "- gamemoderun %command%"
append "- Essa linha não chama MangoHud."
blank

append "### 6.10 MangoHud padrão Mocha"
blank
append "- MangoHud é parte fundamental da configuração gamer do Mocha."
append "- MangoHud deve usar o padrão visual/configuração Mocha."
append "- Linha Steam para GameMode com MangoHud:"
append "- mangohud gamemoderun %command%"
append "- Quando houver arquivo canônico de configuração, usar MANGOHUD_CONFIGFILE apontando para o arquivo Mocha aprovado."
append "- Não usar MANGOHUD_DLSYM no wrapper canônico."
blank

append "### 6.11 Baseline de teste em jogos"
blank
append "A validação deve comparar estes cenários:"
blank
append "1. Sem Launch Options."
append "2. gamemoderun %command%."
append "3. mangohud gamemoderun %command%."
append "4. Wrapper Mocha somente depois de revisado."
blank
append "O melhor resultado observado anteriormente incluiu teste sem nenhuma Launch Option. Esse baseline não deve ser apagado nem substituído por wrapper sem comparação."
blank

append "### 6.12 Relatórios ligados a esta correção"
blank
append "- Leitura do manual antes da edição: $AUDIT"
append "- Estado real da receita/agressividade na máquina: $STATE"
append "- Backup do manual antes da correção: $BACKUP"
blank

say "Substituindo a seção 6, preservando o restante do manual"
awk -v repl="$SECTION" '
BEGIN {
  while ((getline line < repl) > 0) {
    replacement = replacement line ORS
  }
  close(repl)
  in_section = 0
  replaced = 0
}
/^## 6[.] / {
  printf "%s", replacement
  in_section = 1
  replaced = 1
  next
}
in_section && /^## 7[.] / {
  in_section = 0
  print
  next
}
!in_section {
  print
}
END {
  if (replaced == 0) {
    print ""
    printf "%s", replacement
  }
}
' "$MANUAL" > "$TMP"

say "Validando se a correção entrou no manual"
grep -q '^## 6[.] Performance, energia e agressividade' "$TMP" || fail "Seção 6 corrigida não encontrada."
grep -q 'vm.swappiness=80' "$TMP" || fail "vm.swappiness não entrou."
grep -q 'vm.vfs_cache_pressure=50' "$TMP" || fail "vm.vfs_cache_pressure não entrou."
grep -q 'vm.page-cluster=0' "$TMP" || fail "vm.page-cluster não entrou."
grep -q 'vm.dirty_background_bytes=67108864' "$TMP" || fail "dirty_background_bytes não entrou."
grep -q 'vm.dirty_bytes=268435456' "$TMP" || fail "dirty_bytes não entrou."
grep -q 'vm.max_map_count=16777216' "$TMP" || fail "max_map_count não entrou."
grep -q 'kernel.sched_autogroup_enabled=0' "$TMP" || fail "sched_autogroup não entrou."
grep -q 'transparent_hugepage=madvise' "$TMP" || fail "THP madvise não entrou."
grep -q 'latency-performance' "$TMP" || fail "TuneD latency-performance não entrou."
grep -q 'mangohud gamemoderun %command%' "$TMP" || fail "Linha MangoHud/GameMode não entrou."
grep -q 'ZRAM é obrigatória, mas não é a receita inteira' "$TMP" || fail "Aviso de que ZRAM não é a receita inteira não entrou."

say "Publicando manual corrigido"
cp -a "$TMP" "$NEW_MANUAL"
cp -a "$TMP" "$MANUAL"

say "Salvando script usado"
cp -a "$0" "$SCRIPT_COPY"
chmod +x "$SCRIPT_COPY"

say "Resumo final"
printf 'Manual corrigido: %s\n' "$MANUAL"
printf 'Cópia histórica corrigida: %s\n' "$NEW_MANUAL"
printf 'Backup anterior: %s\n' "$BACKUP"
printf 'Leitura feita antes de editar: %s\n' "$AUDIT"
printf 'Estado real coletado: %s\n' "$STATE"
printf 'Log: %s\n' "$LOG"
printf 'Script salvo: %s\n' "$SCRIPT_COPY"

say "Prévia da seção corrigida"
grep -n -A95 '^## 6[.] Performance, energia e agressividade' "$MANUAL" || true

say "Concluído"
