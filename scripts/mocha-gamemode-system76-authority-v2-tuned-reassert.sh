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

SCRIPT_CANONICO="$FAST/scripts/mocha-gamemode-system76-authority-v2-tuned-reassert.sh"

STAMP="$(date +%Y%m%d-%H%M%S)"
AUDIT_DIR="$FAST/auditorias/gamemode-system76-authority-v2-tuned-reassert-$STAMP"
LOG="$AUDIT_DIR/execucao.log"

HELPER="/usr/local/sbin/mocha-system76-authority-helper"
WRAPPER_DIR="/usr/local/lib/mocha/performance"
SYSTEM_END="$WRAPPER_DIR/mocha-gamemode-end-authority-system"
SYSTEM_START="$WRAPPER_DIR/mocha-gamemode-start-authority-system"
GAMEMODE_CONF="/etc/gamemode.ini"
SUDOERS="/etc/sudoers.d/mocha-gamemode-system76-authority"
PROFILE="mocha-latency-performance"

[ -d "$FAST" ] || fail "FAST não montado em $FAST"
mkdir -p "$AUDIT_DIR" "$FAST/scripts"

exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo " Mocha — GameMode/system76 V2 com TuneD reassert"
echo "============================================================"
echo

[ -x "$HELPER" ] || fail "Helper ausente ou não executável: $HELPER"
[ -x "$SYSTEM_END" ] || fail "Wrapper end ausente ou não executável: $SYSTEM_END"
[ -f "$GAMEMODE_CONF" ] || fail "gamemode.ini ausente: $GAMEMODE_CONF"

echo "Estado antes:"
echo
echo "GameMode:"
timeout 10 gamemoded -s || true

echo
echo "Autoridade Mocha:"
sudo timeout 10 "$HELPER" status || true

echo
echo "system76-scheduler:"
timeout 10 systemctl is-active com.system76.Scheduler.service || true
timeout 10 systemctl is-enabled com.system76.Scheduler.service || true

echo
echo "TuneD:"
timeout 10 tuned-adm active || true
timeout 20 tuned-adm verify || true

echo
echo "Backups:"
sudo cp -a "$HELPER" "$AUDIT_DIR/$(basename "$HELPER").bak"
sudo cp -a "$SYSTEM_END" "$AUDIT_DIR/$(basename "$SYSTEM_END").bak"
[ -x "$SYSTEM_START" ] && sudo cp -a "$SYSTEM_START" "$AUDIT_DIR/$(basename "$SYSTEM_START").bak" || true
sudo cp -a "$GAMEMODE_CONF" "$AUDIT_DIR/gamemode.ini.bak"
[ -f "$SUDOERS" ] && sudo cp -a "$SUDOERS" "$AUDIT_DIR/$(basename "$SUDOERS").bak" || true
ok "Backups salvos em $AUDIT_DIR"

echo
echo "Atualizando sudoers para permitir reassert controlado do TuneD:"
TMP_SUDOERS="$(mktemp)"
cat > "$TMP_SUDOERS" <<EOF
# Mocha: permite GameMode pausar/religar system76-scheduler e reassertar TuneD sem senha.
Cmnd_Alias MOCHA_SYSTEM76_AUTHORITY = $HELPER, $HELPER *
Cmnd_Alias MOCHA_TUNED_REASSERT = /usr/bin/tuned-adm profile $PROFILE, /usr/bin/tuned-adm verify, /usr/bin/systemctl restart tuned.service
%wheel ALL=(root) NOPASSWD: MOCHA_SYSTEM76_AUTHORITY, MOCHA_TUNED_REASSERT
$(id -un) ALL=(root) NOPASSWD: MOCHA_SYSTEM76_AUTHORITY, MOCHA_TUNED_REASSERT
EOF

sudo install -m 0440 "$TMP_SUDOERS" "$SUDOERS"
rm -f "$TMP_SUDOERS"
sudo visudo -cf "$SUDOERS" >/dev/null
ok "$SUDOERS"

echo
echo "Recriando wrapper END para reassertar TuneD após legacy end:"
LEGACY_END="/etc/mocha/gamemode/legacy-end-system.cmd"

TMP_END="$(mktemp)"
cat > "$TMP_END" <<'EOF_END'
#!/usr/bin/env bash
set +e
export LC_ALL=C

HELPER="/usr/local/sbin/mocha-system76-authority-helper"
LEGACY_CMD_FILE="/etc/mocha/gamemode/legacy-end-system.cmd"
PROFILE="mocha-latency-performance"
LOG="/tmp/mocha-gamemode-authority-${USER:-unknown}.log"

log() {
  printf '%s %s\n' "$(date '+%F %T')" "$*" >> "$LOG" 2>/dev/null || true
}

run_legacy() {
  [ -s "$LEGACY_CMD_FILE" ] || return 0
  cmd="$(sed -n '1p' "$LEGACY_CMD_FILE" 2>/dev/null || true)"
  [ -n "$cmd" ] || return 0

  case "$cmd" in
    *mocha-gamemode-start-authority*|*mocha-gamemode-end-authority*)
      log "legacy end ignorado para evitar recursão: $cmd"
      return 0
      ;;
  esac

  log "executando legacy end: $cmd"
  /bin/bash -lc "$cmd" >> "$LOG" 2>&1 || log "legacy end retornou falha"
}

reassert_tuned() {
  log "reassert TuneD profile: $PROFILE"
  /usr/bin/sudo -n /usr/bin/tuned-adm profile "$PROFILE" >> "$LOG" 2>&1 || log "tuned-adm profile falhou"

  if ! /usr/bin/sudo -n /usr/bin/tuned-adm verify >> "$LOG" 2>&1; then
    log "tuned verify falhou; tentando restart tuned + reaplicar perfil"
    /usr/bin/sudo -n /usr/bin/systemctl restart tuned.service >> "$LOG" 2>&1 || log "restart tuned falhou"
    /usr/bin/sudo -n /usr/bin/tuned-adm profile "$PROFILE" >> "$LOG" 2>&1 || log "tuned-adm profile pós-restart falhou"
    /usr/bin/sudo -n /usr/bin/tuned-adm verify >> "$LOG" 2>&1 || log "tuned verify ainda falhou após restart"
  fi
}

log "GameMode end authority V2"
run_legacy
reassert_tuned
/usr/bin/sudo -n "$HELPER" end >> "$LOG" 2>&1 || log "helper end falhou"
reassert_tuned
exit 0
EOF_END

sudo install -m 0755 "$TMP_END" "$SYSTEM_END"
rm -f "$TMP_END"
ok "$SYSTEM_END"

echo
echo "Garantindo /etc/gamemode.ini apontando para o wrapper V2:"
if grep -q '^end=' "$GAMEMODE_CONF"; then
  sudo sed -i "s#^end=.*#end=$SYSTEM_END#" "$GAMEMODE_CONF"
else
  if grep -q '^\[custom\]' "$GAMEMODE_CONF"; then
    sudo awk -v end_line="end=$SYSTEM_END" '
      BEGIN {in_custom=0; done=0}
      /^\[custom\]/ {in_custom=1; print; next}
      /^\[/ && in_custom && !done {print end_line; done=1; in_custom=0}
      {print}
      END {if (in_custom && !done) print end_line}
    ' "$GAMEMODE_CONF" > "$AUDIT_DIR/gamemode.ini.tmp"
    sudo install -m 0644 "$AUDIT_DIR/gamemode.ini.tmp" "$GAMEMODE_CONF"
  else
    printf '\n[custom]\nend=%s\n' "$SYSTEM_END" | sudo tee -a "$GAMEMODE_CONF" >/dev/null
  fi
fi

echo
echo "Trecho custom atual:"
awk '
  /^\[custom\]/ {show=1}
  /^\[/ && $0 !~ /^\[custom\]/ {if (show) exit}
  show {print}
' "$GAMEMODE_CONF" || true

echo
echo "Reassert TuneD agora:"
sudo tuned-adm profile "$PROFILE"
if timeout 20 tuned-adm verify; then
  ok "TuneD verify passou agora"
else
  warn "TuneD ainda falhou agora; últimas linhas do log:"
  sudo timeout 10 tail -n 80 /var/log/tuned/tuned.log 2>/dev/null || true
fi

echo
echo "Validação pós-correção:"
echo
echo "GameMode:"
timeout 10 gamemoded -s || true

echo
echo "Autoridade Mocha:"
sudo timeout 10 "$HELPER" status || true

echo
echo "system76-scheduler:"
timeout 10 systemctl is-active com.system76.Scheduler.service || true
timeout 10 systemctl is-enabled com.system76.Scheduler.service || true

echo
echo "TuneD:"
timeout 10 tuned-adm active || true
timeout 20 tuned-adm verify || true

echo
echo "Sysctl Mocha:"
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
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | sort | uniq -c || true

echo
echo "Documentando V2 nos manuais:"
MANUAL_BLOCK="$(mktemp)"
cat > "$MANUAL_BLOCK" <<EOF_BLOCK
<!-- MOCHA_GAMEMODE_SYSTEM76_AUTHORITY_START -->
## Autoridade de performance: GameMode sobre system76-scheduler

Script canônico V2:

    $SCRIPT_CANONICO

Arquivos de sistema:

    $HELPER
    $SUDOERS
    $GAMEMODE_CONF
    $SYSTEM_START
    $SYSTEM_END

Regra canônica:

    TuneD mantém o perfil permanente mocha-latency-performance.
    system76-scheduler gerencia responsividade normal do desktop fora dos jogos.
    Quando GameMode entra, GameMode vira autoridade principal.
    Durante jogo, o helper Mocha pausa o system76-scheduler para evitar disputa de prioridade.
    Ao fechar o jogo, o wrapper V2 executa o legacy end, reasserta o TuneD mocha-latency-performance, religa o system76-scheduler somente se ele estava ativo antes, e reasserta o TuneD novamente.

Motivo da V2:

    Na validação pós-jogo, GameMode encerrou corretamente, system76 voltou e OC NVIDIA reverteu, mas tuned-adm verify ficou sujo. A V2 força o retorno ao chão permanente mocha-latency-performance no final da sessão de jogo.

Estado/runtime:

    /run/mocha/gamemode-authority
    /var/log/mocha-gamemode-system76-authority.log
    /tmp/mocha-gamemode-authority-\$USER.log

Como reaplicar:

    sudo bash $SCRIPT_CANONICO

Como verificar durante jogo:

    timeout 10 gamemoded -s
    sudo $HELPER status
    timeout 10 systemctl is-active com.system76.Scheduler.service
    timeout 20 tuned-adm verify

Como verificar após fechar jogo:

    timeout 10 gamemoded -s
    sudo $HELPER status
    timeout 10 systemctl is-active com.system76.Scheduler.service
    timeout 20 tuned-adm verify
<!-- MOCHA_GAMEMODE_SYSTEM76_AUTHORITY_END -->
EOF_BLOCK

upsert_block() {
  local file="$1"
  local block_file="$2"
  local start='<!-- MOCHA_GAMEMODE_SYSTEM76_AUTHORITY_START -->'
  local end='<!-- MOCHA_GAMEMODE_SYSTEM76_AUTHORITY_END -->'
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
echo "  Script canônico: $SCRIPT_CANONICO"
echo "  Wrapper end V2: $SYSTEM_END"
echo "  Sudoers: $SUDOERS"
echo "  Auditoria: $AUDIT_DIR"
echo "  Log: $LOG"

ok "GameMode/system76 V2 com reassert TuneD aplicado"
