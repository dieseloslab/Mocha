#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/var/backups/mocha-agressividade-cachy-proxima-v2-$STAMP"

SYSCTL_FILE="/etc/sysctl.d/99-mocha-agressivo-v2.conf"
TMPFILES_ZSWAP="/etc/tmpfiles.d/mocha-zswap-off.conf"
UDEV_RULE="/etc/udev/rules.d/60-mocha-io-scheduler.rules"
IO_HELPER="/usr/local/sbin/mocha-io-scheduler-apply"
GRUB_DEFAULT="/etc/default/grub"
GRUB_CFG="/boot/grub/grub.cfg"

mkdir -p "$BACKUP_DIR"

backup_if_exists() {
  local path="$1"
  if [ -e "$path" ]; then
    mkdir -p "$BACKUP_DIR$(dirname "$path")"
    cp -a "$path" "$BACKUP_DIR$path"
    ok "Backup: $path -> $BACKUP_DIR$path"
  fi
}

echo
echo "============================================================"
echo " Mocha — agressividade próxima do CachyOS v2"
echo "============================================================"
echo
echo "Backup em:"
echo "$BACKUP_DIR"

backup_if_exists "$SYSCTL_FILE"
backup_if_exists "$TMPFILES_ZSWAP"
backup_if_exists "$UDEV_RULE"
backup_if_exists "$IO_HELPER"
backup_if_exists "$GRUB_DEFAULT"
backup_if_exists "$GRUB_CFG"

echo
echo "1/6 — Aplicando sysctl Mocha agressivo v2"

cat > "$SYSCTL_FILE" <<'EOF'
# Mocha — perfil agressivo v2 próximo do CachyOS
# Escopo: VM/cache, dirty writeback, diagnóstico leve e limites gerais.
# Não ativa SCX/sched-ext. Não interfere diretamente no GameMode/system76.

vm.swappiness = 150
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.dirty_writeback_centisecs = 1500

kernel.nmi_watchdog = 0
kernel.unprivileged_userns_clone = 1
kernel.printk = 3 3 3 3
kernel.kptr_restrict = 2

net.core.netdev_max_backlog = 4096
fs.file-max = 2097152
EOF

apply_sysctl() {
  local key="$1"
  local value="$2"
  local proc="/proc/sys/${key//./\/}"

  if [ -e "$proc" ]; then
    if sysctl -w "$key=$value" >/dev/null; then
      ok "$key = $value"
    else
      warn "Falhou ao aplicar $key = $value"
    fi
  else
    warn "Chave ausente neste kernel: $key"
  fi
}

apply_sysctl "vm.swappiness" "150"
apply_sysctl "vm.vfs_cache_pressure" "50"
apply_sysctl "vm.page-cluster" "0"
apply_sysctl "vm.dirty_background_bytes" "67108864"
apply_sysctl "vm.dirty_bytes" "268435456"
apply_sysctl "vm.dirty_writeback_centisecs" "1500"
apply_sysctl "kernel.nmi_watchdog" "0"
apply_sysctl "kernel.unprivileged_userns_clone" "1"
apply_sysctl "kernel.printk" "3 3 3 3"
apply_sysctl "kernel.kptr_restrict" "2"
apply_sysctl "net.core.netdev_max_backlog" "4096"
apply_sysctl "fs.file-max" "2097152"

echo
echo "2/6 — Desativando zswap com ZRAM ativa"

cat > "$TMPFILES_ZSWAP" <<'EOF'
# Mocha — desativar zswap; usamos ZRAM como camada principal.
w /sys/module/zswap/parameters/enabled - - - - N
EOF

if [ -e /sys/module/zswap/parameters/enabled ]; then
  if printf 'N' > /sys/module/zswap/parameters/enabled 2>/dev/null; then
    ok "zswap desligado em runtime."
  else
    warn "Não foi possível desligar zswap em runtime. Pode exigir reboot com zswap.enabled=0."
  fi
else
  ok "zswap não exposto/indisponível neste kernel."
fi

echo
echo "3/6 — Garantindo zswap.enabled=0 no GRUB quando aplicável"

if [ -f "$GRUB_DEFAULT" ]; then
  if grep -q 'zswap.enabled=0' "$GRUB_DEFAULT"; then
    ok "GRUB já contém zswap.enabled=0."
  else
    python - "$GRUB_DEFAULT" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
param = "zswap.enabled=0"

def add_param(match):
    prefix = match.group(1)
    content = match.group(2)
    suffix = match.group(3)
    parts = content.split()
    if param not in parts:
        parts.append(param)
    return prefix + " ".join(parts) + suffix

pattern = re.compile(r'^(GRUB_CMDLINE_LINUX_DEFAULT=")([^"]*)(")', re.M)
if pattern.search(text):
    text = pattern.sub(add_param, text, count=1)
else:
    text += '\nGRUB_CMDLINE_LINUX_DEFAULT="zswap.enabled=0"\n'

path.write_text(text)
PY
    ok "Adicionado zswap.enabled=0 ao $GRUB_DEFAULT."
  fi

  if command -v grub-mkconfig >/dev/null 2>&1 && [ -d /boot/grub ]; then
    if timeout 120 grub-mkconfig -o "$GRUB_CFG" >/tmp/mocha-grub-mkconfig-zswap.log 2>&1; then
      ok "GRUB regenerado em $GRUB_CFG."
    else
      warn "Falha ao regenerar GRUB. Log:"
      sed -n '1,120p' /tmp/mocha-grub-mkconfig-zswap.log || true
    fi
  else
    warn "grub-mkconfig ou /boot/grub ausente. Persistência do zswap via GRUB não aplicada."
  fi
else
  warn "$GRUB_DEFAULT ausente. Persistência via GRUB ignorada."
fi

echo
echo "4/6 — Instalando helper de I/O scheduler"

cat > "$IO_HELPER" <<'EOF'
#!/usr/bin/env bash
set -u

DEV="${1:-}"
[ -n "$DEV" ] || exit 0

SYS="/sys/block/$DEV"
SCHED="$SYS/queue/scheduler"
ROT="$SYS/queue/rotational"

[ -e "$SCHED" ] || exit 0

supported="$(tr ' ' '\n' < "$SCHED" | tr -d '[]' | awk 'NF' | sort -u | tr '\n' ' ')"

has_sched() {
  printf '%s\n' "$supported" | grep -qw "$1"
}

set_first_supported() {
  for candidate in "$@"; do
    if has_sched "$candidate"; then
      printf '%s' "$candidate" > "$SCHED" 2>/dev/null || exit 0
      logger -t mocha-io-scheduler "device=$DEV scheduler=$candidate supported=[$supported]"
      exit 0
    fi
  done
  logger -t mocha-io-scheduler "device=$DEV no-supported-target supported=[$supported]"
  exit 0
}

case "$DEV" in
  nvme*n*)
    set_first_supported none mq-deadline kyber bfq
    ;;
  sd*|vd*|xvd*)
    if [ -r "$ROT" ] && [ "$(cat "$ROT" 2>/dev/null || echo 0)" = "1" ]; then
      set_first_supported bfq mq-deadline kyber none
    else
      set_first_supported mq-deadline none kyber bfq
    fi
    ;;
  *)
    exit 0
    ;;
esac
EOF

chmod 755 "$IO_HELPER"
ok "Helper instalado: $IO_HELPER"

cat > "$UDEV_RULE" <<EOF
# Mocha — I/O scheduler por tipo de disco
# NVMe -> none
# SSD SATA/virtio -> mq-deadline
# HDD -> bfq
ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme[0-9]n[0-9]|sd[a-z]|vd[a-z]|xvd[a-z]", RUN+="$IO_HELPER %k"
EOF

ok "Regra udev instalada: $UDEV_RULE"

echo
echo "5/6 — Aplicando I/O scheduler nos discos atuais"

for devpath in /sys/block/nvme*n* /sys/block/sd* /sys/block/vd* /sys/block/xvd*; do
  [ -e "$devpath" ] || continue
  dev="$(basename "$devpath")"
  printf '  - %s: ' "$dev"
  "$IO_HELPER" "$dev" || true
  if [ -r "$devpath/queue/scheduler" ]; then
    cat "$devpath/queue/scheduler"
  else
    echo "sem scheduler exposto"
  fi
done

udevadm control --reload-rules || warn "Falha ao recarregar regras udev."
udevadm trigger --subsystem-match=block || warn "Falha ao disparar udev para block."

echo
echo "6/6 — Validação consolidada"

echo
echo "Sysctl principais:"
for key in \
  vm.swappiness \
  vm.vfs_cache_pressure \
  vm.page-cluster \
  vm.dirty_background_bytes \
  vm.dirty_bytes \
  vm.dirty_writeback_centisecs \
  kernel.nmi_watchdog \
  kernel.unprivileged_userns_clone \
  kernel.printk \
  kernel.kptr_restrict \
  net.core.netdev_max_backlog \
  fs.file-max
do
  sysctl "$key" 2>/dev/null || true
done

echo
echo "zswap:"
if [ -e /sys/module/zswap/parameters/enabled ]; then
  printf 'zswap.enabled runtime = '
  cat /sys/module/zswap/parameters/enabled
else
  echo "zswap.enabled runtime = ausente"
fi

echo
echo "ZRAM:"
zramctl 2>/dev/null || true
swapon --show 2>/dev/null || true

echo
echo "I/O schedulers:"
for devpath in /sys/block/nvme*n* /sys/block/sd* /sys/block/vd* /sys/block/xvd*; do
  [ -e "$devpath" ] || continue
  dev="$(basename "$devpath")"
  if [ -r "$devpath/queue/scheduler" ]; then
    printf '%s: ' "$dev"
    cat "$devpath/queue/scheduler"
  fi
done

echo
echo "GameMode/system76 não alterados por este script:"
systemctl is-active com.system76.Scheduler.service 2>/dev/null || true
gamemoded -s 2>/dev/null || true

echo
ok "Perfil Mocha agressivo v2 aplicado."
echo
echo "Backup completo:"
echo "$BACKUP_DIR"
