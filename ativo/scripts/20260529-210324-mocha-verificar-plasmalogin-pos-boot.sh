#!/usr/bin/env bash
set -Eeuo pipefail
printf "\n== display-manager.service ==\n"
readlink -v /etc/systemd/system/display-manager.service 2>/dev/null || true
readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true
printf "\n== plasmalogin.service ==\n"
systemctl is-enabled plasmalogin.service 2>/dev/null || true
systemctl is-active plasmalogin.service 2>/dev/null || true
systemctl status plasmalogin.service --no-pager -l || true
printf "\n== sessão atual ==\n"
if [ -n "${XDG_SESSION_ID:-}" ]; then loginctl show-session "$XDG_SESSION_ID" -p Type -p Desktop -p Name 2>/dev/null || true; else loginctl list-sessions || true; fi
printf "\n== logs do boot atual do plasmalogin ==\n"
journalctl -b -u plasmalogin.service --no-pager -n 120 || true
