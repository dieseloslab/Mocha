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

SCRIPT_CANONICO="$FAST/scripts/mocha-gamemode-system76-authority-v1.sh"

STAMP="$(date +%Y%m%d-%H%M%S)"
AUDIT_DIR="$FAST/auditorias/gamemode-system76-authority-$STAMP"
LOG="$AUDIT_DIR/execucao.log"

CONF_DIR="/etc/mocha/gamemode"
HELPER="/usr/local/sbin/mocha-system76-authority-helper"
WRAPPER_DIR="/usr/local/lib/mocha/performance"
SUDOERS="/etc/sudoers.d/mocha-gamemode-system76-authority"

SYSTEM_GAMEMODE_CONF="/etc/gamemode.ini"
USER_GAMEMODE_CONF="$HOME/.config/gamemode.ini"

[ -d "$FAST" ] || fail "FAST não montado em $FAST"
mkdir -p "$AUDIT_DIR" "$FAST/scripts"

exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo " Mocha — GameMode autoridade sobre system76-scheduler"
echo "============================================================"
echo

command -v systemctl >/dev/null 2>&1 || fail "systemctl ausente"
command -v python3 >/dev/null 2>&1 || fail "python3 ausente; necessário para editar gamemode.ini com segurança"

echo "Estado base:"
echo
echo "TuneD:"
timeout 10 tuned-adm active || true
timeout 10 tuned-adm verify || true

echo
echo "GameMode:"
timeout 10 gamemoded -s || true

echo
echo "system76-scheduler candidatos:"
timeout 10 systemctl list-unit-files --type=service --no-pager --no-legend 2>/dev/null | grep -E 'system76|Scheduler' || true

discover_system76_service() {
  local units candidate
  units="$(timeout 10 systemctl list-unit-files --type=service --no-pager --no-legend 2>/dev/null | awk '{print $1}' || true)"

  for candidate in \
    com.system76.Scheduler.service \
    system76-scheduler.service
  do
    if printf '%s\n' "$units" | grep -Fxq "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

SYSTEM76_SERVICE=""
if SYSTEM76_SERVICE="$(discover_system76_service)"; then
  ok "Serviço system76-scheduler detectado: $SYSTEM76_SERVICE"
else
  warn "Serviço system76-scheduler não detectado. Os wrappers serão instalados, mas não haverá serviço para pausar."
fi

echo
echo "Backups:"
sudo install -d -m 0755 "$CONF_DIR" "$WRAPPER_DIR"

if [ -f "$SYSTEM_GAMEMODE_CONF" ]; then
  sudo cp -a "$SYSTEM_GAMEMODE_CONF" "$AUDIT_DIR/gamemode.ini.system.bak"
  ok "Backup: $AUDIT_DIR/gamemode.ini.system.bak"
else
  warn "$SYSTEM_GAMEMODE_CONF não existia; será criado se necessário"
fi

if [ -f "$USER_GAMEMODE_CONF" ]; then
  cp -a "$USER_GAMEMODE_CONF" "$AUDIT_DIR/gamemode.ini.user.$(id -un).bak"
  ok "Backup: $AUDIT_DIR/gamemode.ini.user.$(id -un).bak"
fi

echo
echo "Registrando serviço system76:"
if [ -n "$SYSTEM76_SERVICE" ]; then
  printf '%s\n' "$SYSTEM76_SERVICE" | sudo tee "$CONF_DIR/system76-service.name" >/dev/null
  sudo chmod 0644 "$CONF_DIR/system76-service.name"
  timeout 10 systemctl is-active "$SYSTEM76_SERVICE" || true
  timeout 10 systemctl is-enabled "$SYSTEM76_SERVICE" || true
else
  sudo rm -f "$CONF_DIR/system76-service.name"
fi

echo
echo "Instalando helper root seguro:"
TMP_HELPER="$(mktemp)"
cat > "$TMP_HELPER" <<'MOCHA_HELPER'
#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ACTION="${1:-status}"

STATE_ROOT="/run/mocha"
STATE_DIR="$STATE_ROOT/gamemode-authority"
LOCK="$STATE_ROOT/gamemode-authority.lock"
CONF_DIR="/etc/mocha/gamemode"
SERVICE_FILE="$CONF_DIR/system76-service.name"
LOG="/var/log/mocha-gamemode-system76-authority.log"

log() {
  printf '%s %s\n' "$(date '+%F %T')" "$*" >> "$LOG" 2>/dev/null || true
}

discover_service() {
  local svc units candidate

  if [ -r "$SERVICE_FILE" ]; then
    svc="$(sed -n '1p' "$SERVICE_FILE" | tr -d '[:space:]')"
    if [ -n "$svc" ]; then
      printf '%s\n' "$svc"
      return 0
    fi
  fi

  units="$(systemctl list-unit-files --type=service --no-pager --no-legend 2>/dev/null | awk '{print $1}' || true)"

  for candidate in \
    com.system76.Scheduler.service \
    system76-scheduler.service
  do
    if printf '%s\n' "$units" | grep -Fxq "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

mkdir -p "$STATE_ROOT"
exec 9>"$LOCK"
flock -x 9

mkdir -p "$STATE_DIR"

COUNT_FILE="$STATE_DIR/count"
ACTIVE_FILE="$STATE_DIR/active"
WAS_ACTIVE_FILE="$STATE_DIR/system76-was-active"
SERVICE_STATE_FILE="$STATE_DIR/system76-service"

read_count() {
  local n
  n="$(cat "$COUNT_FILE" 2>/dev/null || printf '0')"
  case "$n" in
    ''|*[!0-9]*) n=0 ;;
  esac
  printf '%s\n' "$n"
}

write_count() {
  printf '%s\n' "$1" > "$COUNT_FILE"
}

case "$ACTION" in
  start)
    svc="$(discover_service || true)"
    count="$(read_count)"

    if [ "$count" -eq 0 ]; then
      date '+%F %T' > "$ACTIVE_FILE"

      if [ -n "${svc:-}" ]; then
        printf '%s\n' "$svc" > "$SERVICE_STATE_FILE"

        if systemctl is-active --quiet "$svc"; then
          printf 'active\n' > "$WAS_ACTIVE_FILE"
          log "GameMode start: stopping $svc"
          systemctl stop "$svc" || log "GameMode start: failed to stop $svc"
        else
          printf 'inactive\n' > "$WAS_ACTIVE_FILE"
          log "GameMode start: $svc was not active"
        fi
      else
        printf 'none\n' > "$WAS_ACTIVE_FILE"
        log "GameMode start: no system76 scheduler service found"
      fi
    fi

    count=$((count + 1))
    write_count "$count"
    log "GameMode start: authority count=$count"
    ;;

  end)
    count="$(read_count)"
    if [ "$count" -gt 0 ]; then
      count=$((count - 1))
    else
      count=0
    fi
    write_count "$count"
    log "GameMode end: authority count=$count"

    if [ "$count" -eq 0 ]; then
      svc="$(cat "$SERVICE_STATE_FILE" 2>/dev/null || discover_service || true)"
      was="$(cat "$WAS_ACTIVE_FILE" 2>/dev/null || printf 'none')"

      if [ -n "${svc:-}" ] && [ "$was" = "active" ]; then
        log "GameMode end: starting $svc"
        systemctl start "$svc" || log "GameMode end: failed to start $svc"
      else
        log "GameMode end: not starting system76 scheduler; previous state=$was service=${svc:-none}"
      fi

      rm -f "$ACTIVE_FILE" "$WAS_ACTIVE_FILE" "$SERVICE_STATE_FILE" "$COUNT_FILE"
    fi
    ;;

  status)
    svc="$(cat "$SERVICE_STATE_FILE" 2>/dev/null || discover_service || true)"
    count="$(read_count)"
    was="$(cat "$WAS_ACTIVE_FILE" 2>/dev/null || printf 'none')"

    printf 'service=%s\n' "${svc:-none}"
    printf 'count=%s\n' "$count"
    printf 'was_active=%s\n' "$was"
    printf 'marker=%s\n' "$([ -e "$ACTIVE_FILE" ] && printf active || printf inactive)"

    if [ -n "${svc:-}" ]; then
      systemctl is-active "$svc" || true
      systemctl is-enabled "$svc" || true
    fi
    ;;

  *)
    printf '[FALHA] ação inválida: %s\n' "$ACTION" >&2
    exit 2
    ;;
esac
MOCHA_HELPER

sudo install -m 0755 "$TMP_HELPER" "$HELPER"
rm -f "$TMP_HELPER"
ok "$HELPER"

echo
echo "Instalando sudoers restrito para o helper:"
CURRENT_USER="$(id -un)"
TMP_SUDOERS="$(mktemp)"
cat > "$TMP_SUDOERS" <<EOF
# Mocha: permite GameMode pausar/religar system76-scheduler sem senha.
Cmnd_Alias MOCHA_SYSTEM76_AUTHORITY = $HELPER, $HELPER *
%wheel ALL=(root) NOPASSWD: MOCHA_SYSTEM76_AUTHORITY
$CURRENT_USER ALL=(root) NOPASSWD: MOCHA_SYSTEM76_AUTHORITY
EOF

sudo install -m 0440 "$TMP_SUDOERS" "$SUDOERS"
rm -f "$TMP_SUDOERS"
sudo visudo -cf "$SUDOERS" >/dev/null
ok "$SUDOERS"

get_custom_value() {
  local file="$1"
  local key="$2"
  python3 - "$file" "$key" <<'PY_GET'
import sys, re, pathlib
path = pathlib.Path(sys.argv[1])
key = sys.argv[2].lower()
if not path.exists():
    sys.exit(0)
section = None
for raw in path.read_text(errors="replace").splitlines():
    line = raw.strip()
    m = re.match(r'^\[([^\]]+)\]\s*$', line)
    if m:
        section = m.group(1).strip().lower()
        continue
    if section == "custom":
        m = re.match(r'^([A-Za-z0-9_.-]+)\s*=\s*(.*)$', raw)
        if m and m.group(1).strip().lower() == key:
            print(m.group(2).strip())
            sys.exit(0)
PY_GET
}

is_mocha_authority_cmd() {
  printf '%s\n' "$1" | grep -Eq 'mocha-gamemode-(start|end)-authority'
}

make_wrapper_pair() {
  local label="$1"
  local start_wrapper="$2"
  local end_wrapper="$3"
  local legacy_start="$4"
  local legacy_end="$5"

  local tmp_start tmp_end
  tmp_start="$(mktemp)"
  tmp_end="$(mktemp)"

  cat > "$tmp_start" <<EOF_START
#!/usr/bin/env bash
set +e
export LC_ALL=C

HELPER="$HELPER"
LEGACY_CMD_FILE="$legacy_start"
LOG="/tmp/mocha-gamemode-authority-\${USER:-unknown}.log"

log() {
  printf '%s %s\n' "\$(date '+%F %T')" "\$*" >> "\$LOG" 2>/dev/null || true
}

run_legacy() {
  [ -s "\$LEGACY_CMD_FILE" ] || return 0
  cmd="\$(sed -n '1p' "\$LEGACY_CMD_FILE" 2>/dev/null || true)"
  [ -n "\$cmd" ] || return 0

  case "\$cmd" in
    *mocha-gamemode-start-authority*|*mocha-gamemode-end-authority*)
      log "legacy start ignorado para evitar recursão: \$cmd"
      return 0
      ;;
  esac

  log "executando legacy start: \$cmd"
  /bin/bash -lc "\$cmd" >> "\$LOG" 2>&1 || log "legacy start retornou falha"
}

log "GameMode start authority label=$label"
/usr/bin/sudo -n "\$HELPER" start >> "\$LOG" 2>&1 || log "helper start falhou"
run_legacy
exit 0
EOF_START

  cat > "$tmp_end" <<EOF_END
#!/usr/bin/env bash
set +e
export LC_ALL=C

HELPER="$HELPER"
LEGACY_CMD_FILE="$legacy_end"
LOG="/tmp/mocha-gamemode-authority-\${USER:-unknown}.log"

log() {
  printf '%s %s\n' "\$(date '+%F %T')" "\$*" >> "\$LOG" 2>/dev/null || true
}

run_legacy() {
  [ -s "\$LEGACY_CMD_FILE" ] || return 0
  cmd="\$(sed -n '1p' "\$LEGACY_CMD_FILE" 2>/dev/null || true)"
  [ -n "\$cmd" ] || return 0

  case "\$cmd" in
    *mocha-gamemode-start-authority*|*mocha-gamemode-end-authority*)
      log "legacy end ignorado para evitar recursão: \$cmd"
      return 0
      ;;
  esac

  log "executando legacy end: \$cmd"
  /bin/bash -lc "\$cmd" >> "\$LOG" 2>&1 || log "legacy end retornou falha"
}

log "GameMode end authority label=$label"
run_legacy
/usr/bin/sudo -n "\$HELPER" end >> "\$LOG" 2>&1 || log "helper end falhou"
exit 0
EOF_END

  sudo install -m 0755 "$tmp_start" "$start_wrapper"
  sudo install -m 0755 "$tmp_end" "$end_wrapper"
  rm -f "$tmp_start" "$tmp_end"

  ok "$start_wrapper"
  ok "$end_wrapper"
}

patch_gamemode_config() {
  local label="$1"
  local target="$2"
  local owner_mode="$3"
  local fallback_start="${4:-}"
  local fallback_end="${5:-}"

  local start_wrapper="$WRAPPER_DIR/mocha-gamemode-start-authority-$label"
  local end_wrapper="$WRAPPER_DIR/mocha-gamemode-end-authority-$label"
  local legacy_start="$CONF_DIR/legacy-start-$label.cmd"
  local legacy_end="$CONF_DIR/legacy-end-$label.cmd"

  local old_start old_end save_start save_end
  old_start="$(get_custom_value "$target" start || true)"
  old_end="$(get_custom_value "$target" end || true)"

  save_start="$old_start"
  save_end="$old_end"

  [ -n "$save_start" ] || save_start="$fallback_start"
  [ -n "$save_end" ] || save_end="$fallback_end"

  if ! is_mocha_authority_cmd "$old_start"; then
    printf '%s\n' "$save_start" | sudo tee "$legacy_start" >/dev/null
  elif [ ! -f "$legacy_start" ]; then
    printf '%s\n' "$save_start" | sudo tee "$legacy_start" >/dev/null
  fi

  if ! is_mocha_authority_cmd "$old_end"; then
    printf '%s\n' "$save_end" | sudo tee "$legacy_end" >/dev/null
  elif [ ! -f "$legacy_end" ]; then
    printf '%s\n' "$save_end" | sudo tee "$legacy_end" >/dev/null
  fi

  sudo chmod 0644 "$legacy_start" "$legacy_end"

  make_wrapper_pair "$label" "$start_wrapper" "$end_wrapper" "$legacy_start" "$legacy_end"

  tmp="$(mktemp)"

  python3 - "$target" "$tmp" "$start_wrapper" "$end_wrapper" <<'PY_PATCH'
import sys, pathlib, re

source = pathlib.Path(sys.argv[1])
dest = pathlib.Path(sys.argv[2])
start_cmd = sys.argv[3]
end_cmd = sys.argv[4]

if source.exists():
    lines = source.read_text(errors="replace").splitlines()
else:
    lines = []

out = []
in_custom = False
custom_found = False
start_done = False
end_done = False
inserted = False

def add_missing():
    global start_done, end_done
    if not start_done:
        out.append(f"start={start_cmd}")
        start_done = True
    if not end_done:
        out.append(f"end={end_cmd}")
        end_done = True

for raw in lines:
    stripped = raw.strip()
    section = re.match(r'^\[([^\]]+)\]\s*$', stripped)

    if section:
        if in_custom and not inserted:
            add_missing()
            inserted = True
        name = section.group(1).strip().lower()
        in_custom = (name == "custom")
        if in_custom:
            custom_found = True
        out.append(raw)
        continue

    if in_custom:
        key = re.match(r'^([A-Za-z0-9_.-]+)\s*=', raw)
        if key:
            k = key.group(1).strip().lower()
            if k == "start":
                if not start_done:
                    out.append(f"start={start_cmd}")
                    start_done = True
                continue
            if k == "end":
                if not end_done:
                    out.append(f"end={end_cmd}")
                    end_done = True
                continue

    out.append(raw)

if custom_found:
    if in_custom and not inserted:
        add_missing()
else:
    if out and out[-1].strip():
        out.append("")
    out.append("[custom]")
    out.append(f"start={start_cmd}")
    out.append(f"end={end_cmd}")

dest.write_text("\n".join(out) + "\n")
PY_PATCH

  if [ "$owner_mode" = "user" ]; then
    install -Dm644 "$tmp" "$target"
  else
    sudo install -Dm644 "$tmp" "$target"
  fi

  rm -f "$tmp"

  ok "gamemode.ini ajustado: $target"
  echo "  legacy start: ${save_start:-<vazio>}"
  echo "  legacy end: ${save_end:-<vazio>}"
  echo "  wrapper start: $start_wrapper"
  echo "  wrapper end: $end_wrapper"
}

echo
echo "Lendo comandos GameMode atuais:"
SYSTEM_OLD_START="$(get_custom_value "$SYSTEM_GAMEMODE_CONF" start || true)"
SYSTEM_OLD_END="$(get_custom_value "$SYSTEM_GAMEMODE_CONF" end || true)"

echo "Sistema start: ${SYSTEM_OLD_START:-<vazio>}"
echo "Sistema end:   ${SYSTEM_OLD_END:-<vazio>}"

echo
echo "Aplicando patch no /etc/gamemode.ini:"
patch_gamemode_config "system" "$SYSTEM_GAMEMODE_CONF" "root" "" ""

if [ -f "$USER_GAMEMODE_CONF" ]; then
  echo
  echo "Config local detectada; aplicando patch também para evitar override do /etc:"
  patch_gamemode_config "user-$(id -un)" "$USER_GAMEMODE_CONF" "user" "$SYSTEM_OLD_START" "$SYSTEM_OLD_END"
else
  echo
  ok "Sem $USER_GAMEMODE_CONF; configuração canônica fica em /etc/gamemode.ini"
fi

echo
echo "Validação do helper:"
sudo "$HELPER" status || true

echo
echo "Trecho custom do /etc/gamemode.ini:"
awk '
  /^\[custom\]/ {show=1}
  /^\[/ && $0 !~ /^\[custom\]/ {if (show) exit}
  show {print}
' "$SYSTEM_GAMEMODE_CONF" || true

if [ -f "$USER_GAMEMODE_CONF" ]; then
  echo
  echo "Trecho custom do gamemode.ini local:"
  awk '
    /^\[custom\]/ {show=1}
    /^\[/ && $0 !~ /^\[custom\]/ {if (show) exit}
    show {print}
  ' "$USER_GAMEMODE_CONF" || true
fi

echo
echo "Documentando nos manuais:"
MANUAL_BLOCK="$(mktemp)"
cat > "$MANUAL_BLOCK" <<EOF_BLOCK
<!-- MOCHA_GAMEMODE_SYSTEM76_AUTHORITY_START -->
## Autoridade de performance: GameMode sobre system76-scheduler

Script canônico:

    $SCRIPT_CANONICO

Arquivos de sistema:

    $HELPER
    $SUDOERS
    $CONF_DIR/system76-service.name
    $SYSTEM_GAMEMODE_CONF

Regra canônica:

    TuneD mantém o perfil permanente mocha-latency-performance.
    system76-scheduler gerencia responsividade normal do desktop fora dos jogos.
    Quando GameMode entra, GameMode vira autoridade principal.
    Durante jogo, o helper Mocha pausa o system76-scheduler para evitar disputa de prioridade.
    Ao fechar o jogo, o helper Mocha religa o system76-scheduler somente se ele estava ativo antes.
    Start/end antigos do GameMode são preservados como legacy e chamados pelos wrappers Mocha.

Estado/runtime:

    /run/mocha/gamemode-authority
    /var/log/mocha-gamemode-system76-authority.log
    /tmp/mocha-gamemode-authority-\$USER.log

Como reaplicar:

    sudo bash $SCRIPT_CANONICO

Como verificar:

    sudo $HELPER status
    timeout 10 gamemoded -s
    timeout 10 systemctl is-active $SYSTEM76_SERVICE
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
echo "  Helper: $HELPER"
echo "  Sudoers: $SUDOERS"
echo "  Serviço system76: ${SYSTEM76_SERVICE:-não detectado}"
echo "  Config GameMode sistema: $SYSTEM_GAMEMODE_CONF"
[ -f "$USER_GAMEMODE_CONF" ] && echo "  Config GameMode usuário: $USER_GAMEMODE_CONF"
echo "  Auditoria: $AUDIT_DIR"
echo "  Log: $LOG"

ok "Autoridade GameMode/system76 instalada"
