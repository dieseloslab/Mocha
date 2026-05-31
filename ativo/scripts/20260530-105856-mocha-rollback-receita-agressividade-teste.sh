#!/usr/bin/env bash
set -Eeuo pipefail
PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"
if [ -x /run/wrappers/bin/sudo ]; then SUDO=/run/wrappers/bin/sudo; else SUDO="$(command -v sudo)"; fi
TS_ROLLBACK="$(date +%Y%m%d-%H%M%S)"
say(){ printf "\n== %s ==\n" "$*"; }
say "Solicitando sudo uma vez"
"$SUDO" -v
say "Desativando serviços de teste Mocha"
"$SUDO" systemctl disable --now mocha-thp-madvise.service 2>/dev/null || true
"$SUDO" systemctl disable --now mocha-cpu-performance.service 2>/dev/null || true
say "Removendo arquivos persistentes de teste"
for f in /etc/sysctl.d/99-mocha-agressividade-teste.conf /etc/systemd/system/mocha-thp-madvise.service /etc/systemd/system/mocha-cpu-performance.service /etc/systemd/zram-generator.conf.d/99-mocha-agressividade-teste.conf; do if [ -e "$f" ]; then "$SUDO" mv "$f" "${f}.disabled-${TS_ROLLBACK}"; fi; done
say "Restaurando sysctl que estavam ativos antes do teste, ao vivo"
"$SUDO" sysctl -w vm.swappiness=80 || true
"$SUDO" sysctl -w vm.vfs_cache_pressure=50 || true
"$SUDO" sysctl -w vm.page-cluster=0 || true
"$SUDO" sysctl -w vm.dirty_background_bytes=67108864 || true
"$SUDO" sysctl -w vm.dirty_bytes=268435456 || true
"$SUDO" sysctl -w vm.max_map_count=16777216 || true
"$SUDO" sysctl -w kernel.sched_autogroup_enabled=0 || true
"$SUDO" sysctl -w kernel.nmi_watchdog=0 || true
say "Recarregando systemd"
"$SUDO" systemctl daemon-reload
say "Rollback concluído. Reinicie para garantir que ZRAM volte ao estado anterior se ela tiver sido alterada no boot."
