#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

SUDO_KEEPALIVE_PID=""
(
  while true; do
    sudo -n true || exit
    sleep 30
  done
) &
SUDO_KEEPALIVE_PID="$!"

cleanup() {
  set +e
  [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*" >&2; exit 1; }

FAST="/media/mochafast/MochaArch"
INTERNO="/media/mochafast/MochaArch-Interno"
MANUAL_VIVO="$INTERNO/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
MANUAL_CURTO="$FAST/MANUAL-MOCHA-CURTO.md"

PROFILE="mocha-latency-performance"
PROFILE_DIR="/etc/tuned/profiles/$PROFILE"
CONF="$PROFILE_DIR/tuned.conf"

SCRIPT_CANONICO="$FAST/scripts/mocha-tuned-latency-performance-v2.sh"

STAMP="$(date +%Y%m%d-%H%M%S)"
AUDIT_DIR="$FAST/auditorias/tuned-mocha-latency-performance-v2-$STAMP"
LOG="$AUDIT_DIR/execucao.log"

[ -d "$FAST" ] || fail "FAST não montado em $FAST"

mkdir -p "$AUDIT_DIR" "$FAST/scripts"

exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo " Mocha — TuneD mocha-latency-performance V2"
echo "============================================================"
echo

command -v tuned-adm >/dev/null 2>&1 || fail "tuned-adm ausente"

echo "Perfil ativo antes:"
timeout 10 tuned-adm active || true

echo
echo "Serviço TuneD antes:"
timeout 10 systemctl is-active tuned.service || true
timeout 10 systemctl is-enabled tuned.service || true

echo
echo "Backup do perfil Mocha anterior:"
if [ -d "$PROFILE_DIR" ]; then
  sudo cp -a "$PROFILE_DIR" "$AUDIT_DIR/${PROFILE}.bak"
  ok "Backup salvo em $AUDIT_DIR/${PROFILE}.bak"
else
  ok "Perfil anterior não existia"
fi

TMP_CONF="$(mktemp)"
cat > "$TMP_CONF" <<'EOF_CONF'
[main]
summary=Mocha low-latency/performance base profile for gamer desktop
description=Mocha profile copied from latency-performance essentials without inheriting conflicting vm.swappiness=10.

[cpu]
force_latency=cstate.id_no_zero:1|3
governor=performance
energy_perf_bias=performance
min_perf_pct=100
boost=1

[acpi]
platform_profile=performance

[sysctl]
# Mocha canonical VM/memory policy.
vm.swappiness=133
vm.vfs_cache_pressure=50
vm.page-cluster=0
vm.dirty_background_bytes=67108864
vm.dirty_bytes=268435456
vm.max_map_count=8388608

# Preserve interactive desktop grouping outside GameMode.
kernel.sched_autogroup_enabled=1
EOF_CONF

echo
echo "Instalando perfil V2 sem include=latency-performance:"
sudo install -d -m 0755 "$PROFILE_DIR"
sudo install -m 0644 "$TMP_CONF" "$CONF"
rm -f "$TMP_CONF"

echo
echo "Conteúdo novo do perfil:"
sudo sed -n '1,220p' "$CONF"

if sudo grep -q '^include=latency-performance' "$CONF"; then
  fail "Perfil V2 ainda contém include=latency-performance"
fi
ok "Perfil V2 não herda latency-performance; conflito de swappiness removido"

echo
echo "Reiniciando TuneD:"
sudo systemctl enable --now tuned.service
sudo systemctl restart tuned.service
timeout 10 systemctl is-active tuned.service || fail "tuned.service não ficou ativo"

echo
echo "Aplicando perfil $PROFILE:"
sudo tuned-adm profile "$PROFILE"

echo
echo "Perfil ativo:"
timeout 10 tuned-adm active || true

echo
echo "Verificação TuneD:"
VERIFY_OK=0
if timeout 20 tuned-adm verify; then
  VERIFY_OK=1
  ok "tuned-adm verify passou"
else
  warn "tuned-adm verify ainda reclamou"
  echo
  echo "Últimas linhas do log TuneD:"
  sudo timeout 10 tail -n 120 /var/log/tuned/tuned.log 2>/dev/null || true
fi

echo
echo "Sysctl Mocha aplicados:"
for key in \
  vm.swappiness \
  vm.vfs_cache_pressure \
  vm.page-cluster \
  vm.dirty_background_bytes \
  vm.dirty_bytes \
  vm.max_map_count \
  kernel.sched_autogroup_enabled
do
  printf '%s = ' "$key"
  sysctl -n "$key" 2>/dev/null || true
done

echo
echo "CPU governors:"
if compgen -G '/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor' >/dev/null; then
  cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | sort | uniq -c || true
else
  warn "scaling_governor não encontrado"
fi

echo
echo "CPU boost, se existir:"
if [ -r /sys/devices/system/cpu/cpufreq/boost ]; then
  cat /sys/devices/system/cpu/cpufreq/boost
else
  warn "/sys/devices/system/cpu/cpufreq/boost não existe neste driver"
fi

echo
echo "Documentando V2 nos manuais:"
MANUAL_BLOCK="$(mktemp)"
cat > "$MANUAL_BLOCK" <<EOF_BLOCK
<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_START -->
## TuneD canônico Mocha: mocha-latency-performance

Perfil canônico: \`mocha-latency-performance\`.

Caminho no sistema instalado:

    /etc/tuned/profiles/mocha-latency-performance/tuned.conf

Script canônico V2:

    $SCRIPT_CANONICO

Como aplicar/reaplicar:

    sudo bash $SCRIPT_CANONICO

Regra canônica:

    TuneD mantém o chão permanente de baixa latência/performance.
    system76-scheduler administra responsividade normal do desktop.
    GameMode assume autoridade máxima durante jogos.
    Ao fechar o jogo, GameMode reverte ajustes temporários e o sistema volta ao estado normal.

A V2 não herda \`latency-performance\` por \`include=\`, porque o perfil base do TuneD fixa \`vm.swappiness=10\`, enquanto o Mocha usa \`vm.swappiness=133\`. A V2 copia diretamente os ajustes úteis de CPU/latência e aplica os sysctl Mocha uma única vez.

Ajustes permanentes do perfil:

    CPU governor: performance
    CPU boost: 1
    CPU force_latency: cstate.id_no_zero:1|3
    ACPI platform_profile: performance
    vm.swappiness=133
    vm.vfs_cache_pressure=50
    vm.page-cluster=0
    vm.dirty_background_bytes=67108864
    vm.dirty_bytes=268435456
    vm.max_map_count=8388608
    kernel.sched_autogroup_enabled=1

Regra: o perfil TuneD não deve ser mais fraco que a base exigida pelo GameMode. Durante jogo, GameMode prevalece.
<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_END -->
EOF_BLOCK

upsert_block() {
  local file="$1"
  local block_file="$2"
  local start='<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_START -->'
  local end='<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_END -->'
  local tmp
  tmp="$(mktemp)"

  sudo install -d -m 0755 "$(dirname "$file")"

  if [ -f "$file" ]; then
    sudo cp -a "$file" "$AUDIT_DIR/$(basename "$file").bak"
    awk -v start="$start" -v end="$end" -v block_file="$block_file" '
      BEGIN {
        while ((getline line < block_file) > 0) {
          block = block line ORS
        }
        close(block_file)
        inblock = 0
        done = 0
      }
      $0 == start {
        if (!done) {
          printf "%s", block
          done = 1
        }
        inblock = 1
        next
      }
      $0 == end {
        inblock = 0
        next
      }
      !inblock {
        print
      }
      END {
        if (!done) {
          print ""
          printf "%s", block
        }
      }
    ' "$file" > "$tmp"
  else
    cat "$block_file" > "$tmp"
  fi

  sudo install -m 0644 "$tmp" "$file"
  rm -f "$tmp"
}

if [ -f "$MANUAL_VIVO" ]; then
  upsert_block "$MANUAL_VIVO" "$MANUAL_BLOCK"
  ok "Manual vivo atualizado: $MANUAL_VIVO"
else
  warn "Manual vivo não encontrado: $MANUAL_VIVO"
fi

upsert_block "$MANUAL_CURTO" "$MANUAL_BLOCK"
ok "Manual curto atualizado: $MANUAL_CURTO"

rm -f "$MANUAL_BLOCK"

echo
echo "Resumo:"
echo "  Perfil: $PROFILE"
echo "  Config: $CONF"
echo "  Script: $SCRIPT_CANONICO"
echo "  Auditoria: $AUDIT_DIR"
echo "  Log: $LOG"
echo "  Verify OK: $VERIFY_OK"

if [ "$VERIFY_OK" -eq 1 ]; then
  ok "TuneD Mocha V2 aplicado e verificado limpo"
else
  warn "TuneD Mocha V2 aplicado, mas verify ainda precisa de leitura do log"
fi
