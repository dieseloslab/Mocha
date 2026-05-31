#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/run/current-system/sw/bin:$PATH"
SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

echo "== Mocha — reaplicar agressividade/energia atual =="
echo "Este script escreve sysctl, THP, zram-generator, TuneD latency-performance e servicos de performance."
echo

$SUDO mkdir -p /etc/sysctl.d /etc/tmpfiles.d /etc/systemd/system

cat <<'EOS' | $SUDO tee /etc/sysctl.d/99-mocha-agressividade.conf >/dev/null
# Mocha Arch — receita de agressividade atual, ainda candidata/pre-canonica
vm.swappiness = 80
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.max_map_count = 16777216
kernel.sched_autogroup_enabled = 0
kernel.nmi_watchdog = 0
EOS

cat <<'EOS' | $SUDO tee /etc/tmpfiles.d/mocha-thp.conf >/dev/null
# Mocha Arch — THP em madvise
w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise
EOS

cat <<'EOS' | $SUDO tee /etc/systemd/zram-generator.conf >/dev/null
# Mocha Arch — zram receita atual
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 32767
EOS

cat <<'EOS' | $SUDO tee /etc/systemd/system/mocha-cpu-performance.service >/dev/null
[Unit]
Description=Mocha CPU performance governor
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -lc 'for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -w "$g" ] && echo performance > "$g"; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOS

cat <<'EOS' | $SUDO tee /etc/systemd/system/mocha-nvidia-max-performance.service >/dev/null
[Unit]
Description=Mocha NVIDIA maximum performance baseline
After=multi-user.target graphical.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -lc 'if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi -pm 1 || true; nvidia-smi -lgc 0,9999 || true; fi'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOS

$SUDO sysctl --system || true
$SUDO systemd-tmpfiles --create /etc/tmpfiles.d/mocha-thp.conf || true
$SUDO systemctl daemon-reload
$SUDO systemctl enable --now mocha-cpu-performance.service || true
$SUDO systemctl enable --now mocha-nvidia-max-performance.service || true

if command -v tuned-adm >/dev/null 2>&1; then
  $SUDO systemctl enable --now tuned || true
  $SUDO tuned-adm profile latency-performance || true
fi

echo
echo "Resumo:"
sysctl vm.swappiness vm.vfs_cache_pressure vm.page-cluster vm.dirty_background_bytes vm.dirty_bytes vm.max_map_count kernel.sched_autogroup_enabled kernel.nmi_watchdog 2>/dev/null || true
cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
zramctl 2>/dev/null || true
swapon --show || true
systemctl is-active tuned 2>/dev/null || true
tuned-adm active 2>/dev/null || true
