#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

BACKUP_DIR="${1:-}"

if [ -z "$BACKUP_DIR" ]; then
  BACKUP_DIR="$(ls -dt /var/backups/mocha-agressividade-cachy-proxima-v2-* 2>/dev/null | head -n1 || true)"
fi

[ -n "$BACKUP_DIR" ] || fail "Nenhum backup encontrado."
[ -d "$BACKUP_DIR" ] || fail "Backup inexistente: $BACKUP_DIR"

restore_path() {
  local path="$1"
  if [ -e "$BACKUP_DIR$path" ]; then
    install -d -m 755 "$(dirname "$path")"
    cp -a "$BACKUP_DIR$path" "$path"
    ok "Restaurado: $path"
  else
    if [ -e "$path" ]; then
      rm -f "$path"
      ok "Removido arquivo novo sem backup anterior: $path"
    fi
  fi
}

restore_path /etc/sysctl.d/99-mocha-agressivo-v2.conf
restore_path /etc/tmpfiles.d/mocha-zswap-off.conf
restore_path /etc/udev/rules.d/60-mocha-io-scheduler.rules
restore_path /usr/local/sbin/mocha-io-scheduler-apply
restore_path /etc/default/grub
restore_path /boot/grub/grub.cfg

sysctl --system >/tmp/mocha-rollback-sysctl.log 2>&1 || warn "sysctl --system retornou aviso/erro. Ver /tmp/mocha-rollback-sysctl.log"

udevadm control --reload-rules 2>/dev/null || true
udevadm trigger --subsystem-match=block 2>/dev/null || true

ok "Rollback aplicado usando: $BACKUP_DIR"
