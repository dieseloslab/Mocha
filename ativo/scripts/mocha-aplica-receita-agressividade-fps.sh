#!/usr/bin/env bash
set -Eeuo pipefail

if locale -a 2>/dev/null | grep -qx 'C\.UTF-8'; then
    export LC_ALL=C.UTF-8
else
    export LC_ALL=C
fi

sudo -v

echo "MochaArch — aplicar receita padrão de agressividade/FPS V4"

sudo tee /etc/sysctl.d/99-mocha-agressividade-fps.conf >/dev/null <<'CONF'
vm.swappiness = 133
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.max_map_count = 8388608
kernel.sched_autogroup_enabled = 1
CONF

sudo sysctl --system >/dev/null
sudo sysctl -w vm.max_map_count=8388608 >/dev/null

if ! getent group gamemode >/dev/null; then
    sudo groupadd -r gamemode
fi

sudo usermod -aG gamemode "$USER"

sudo tee /etc/gamemode.ini >/dev/null <<'CONF'
[general]
reaper_freq=5
desiredgov=performance
desiredprof=performance
softrealtime=off
renice=10
ioprio=0
inhibit_screensaver=1
disable_splitlock=1

[gpu]
nv_powermizer_mode=1

[cpu]
park_cores=no
pin_cores=no
CONF

sudo systemctl enable --now tuned 2>/dev/null || true

if command -v tuned-adm >/dev/null 2>&1; then
    if tuned-adm list 2>/dev/null | grep -q 'mocha-latency-performance'; then
        sudo tuned-adm profile mocha-latency-performance
    else
        sudo tuned-adm profile latency-performance
    fi
    sudo systemctl restart tuned 2>/dev/null || true
fi

systemctl --user restart gamemoded 2>/dev/null || true
sudo systemctl restart gamemoded 2>/dev/null || true

if command -v nvidia-settings >/dev/null 2>&1; then
    nvidia-settings -a '[gpu:0]/GPUPowerMizerMode=1' >/dev/null 2>&1 || true
fi

echo
echo "Estado:"
sysctl vm.swappiness vm.vfs_cache_pressure vm.page-cluster vm.dirty_background_bytes vm.dirty_bytes vm.max_map_count kernel.sched_autogroup_enabled
swapon --show --output NAME,TYPE,SIZE,USED,PRIO || true
zramctl 2>/dev/null || true
cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
cat /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || true
find /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor -type f -exec cat {} \; 2>/dev/null | sort | uniq -c || true
find /sys/devices/system/cpu/cpu[0-9]*/cpufreq/energy_performance_preference -type f -exec cat {} \; 2>/dev/null | sort | uniq -c || true
cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
tuned-adm active 2>/dev/null || true
gamemoded -s 2>/dev/null || true
nvidia-settings -q '[gpu:0]/GPUPowerMizerMode' 2>/dev/null || true

echo
echo "Observação: faça logout/login ou reinicie para o grupo gamemode valer integralmente."
