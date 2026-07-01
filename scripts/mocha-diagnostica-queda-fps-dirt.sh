#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

STAMP="$(date +%Y%m%d-%H%M%S)"
REPO="/media/mochafast/MochaArch"
LOG_DIR="$REPO/auditorias"
LOG="$LOG_DIR/mocha-diagnostico-queda-fps-dirt-$STAMP.log"

mkdir -p "$LOG_DIR"

run() {
  local title="$1"
  shift
  {
    echo
    echo "============================================================"
    echo "$title"
    echo "============================================================"
    timeout 8s "$@" 2>&1 || true
  } | tee -a "$LOG"
}

run_shell() {
  local title="$1"
  local cmd="$2"
  {
    echo
    echo "============================================================"
    echo "$title"
    echo "============================================================"
    timeout 8s bash -lc "$cmd" 2>&1 || true
  } | tee -a "$LOG"
}

{
  echo "Mocha — diagnóstico queda FPS Dirt"
  echo "Data: $(date -Is)"
  echo "Host: $(hostname)"
  echo "Usuário: ${USER:-desconhecido}"
  echo "Log: $LOG"
} | tee "$LOG"

run "Kernel / cmdline / sessão" uname -a
run_shell "Sessão gráfica" 'printf "XDG_SESSION_TYPE=%s\nDESKTOP_SESSION=%s\nXDG_CURRENT_DESKTOP=%s\n" "${XDG_SESSION_TYPE:-}" "${DESKTOP_SESSION:-}" "${XDG_CURRENT_DESKTOP:-}"'
run_shell "Steam / wrapper em processos" 'ps -eo pid,comm,args --sort=pid | grep -Ei "steam|dirt|proton|wine|gamemode|mangohud|mocha-steam-game-run" | grep -v grep || true'

run_shell "GameMode status" '
if command -v gamemoded >/dev/null 2>&1; then
  gamemoded -s || true
else
  echo "gamemoded ausente"
fi
'

run_shell "system76-scheduler" '
systemctl --user is-active com.system76.Scheduler.service 2>/dev/null || true
systemctl is-active com.system76.Scheduler.service 2>/dev/null || true
systemctl status com.system76.Scheduler.service --no-pager 2>/dev/null | head -80 || true
'

run_shell "TuneD / perfil de performance" '
if command -v tuned-adm >/dev/null 2>&1; then
  tuned-adm active || true
  tuned-adm verify || true
else
  echo "tuned-adm ausente"
fi
'

run_shell "CPU governor / frequência" '
echo "Governors:"
grep -H . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | sort -V | head -32 || true
echo
echo "Frequências atuais:"
grep -H . /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | sort -V | head -32 || true
echo
echo "Boost:"
cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
'

run_shell "Memória / zram / swappiness" '
free -h || true
echo
swapon --show || true
echo
sysctl vm.swappiness vm.vfs_cache_pressure vm.page-cluster vm.max_map_count 2>/dev/null || true
'

run_shell "NVIDIA resumo" '
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi || true
else
  echo "nvidia-smi ausente"
fi
'

run_shell "NVIDIA clocks / power / perf state" '
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,driver_version,pstate,temperature.gpu,utilization.gpu,utilization.memory,clocks.gr,clocks.mem,clocks.sm,power.draw,power.limit,enforced.power.limit,memory.used,memory.total --format=csv,noheader,nounits || true
fi
'

run_shell "NVIDIA atributos GameMode OC" '
if command -v nvidia-settings >/dev/null 2>&1; then
  nvidia-settings -q "[gpu:0]/GPUPowerMizerMode" 2>/dev/null || true
  nvidia-settings -q "[gpu:0]/GPUGraphicsClockOffsetAllPerformanceLevels" 2>/dev/null || true
  nvidia-settings -q "[gpu:0]/GPUMemoryTransferRateOffsetAllPerformanceLevels" 2>/dev/null || true
else
  echo "nvidia-settings ausente"
fi
'

run_shell "Módulos NVIDIA carregados" '
lsmod | grep -Ei "^nvidia|^nouveau" || true
modinfo nvidia 2>/dev/null | grep -E "^(filename|version):" || true
'

run_shell "Pacotes críticos instalados" '
pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-bore linux-cachyos-bore-headers linux-cachyos-eevdf linux-cachyos-eevdf-headers nvidia nvidia-open nvidia-dkms nvidia-utils lib32-nvidia-utils gamemode lib32-gamemode mangohud lib32-mangohud tuned system76-scheduler steam 2>/dev/null || true
'

run_shell "Wrappers canônicos Steam/Mocha" '
for f in \
  /usr/local/bin/mocha-steam-game-run \
  /usr/local/bin/mocha-steam-client \
  /usr/local/bin/mocha-gamemode-oc-start \
  /usr/local/bin/mocha-gamemode-oc-end \
  /usr/local/bin/mocha-nvidia-oc-helper
do
  echo
  echo "--- $f ---"
  if [ -e "$f" ]; then
    ls -l "$f"
    sed -n "1,180p" "$f" 2>/dev/null || true
  else
    echo "AUSENTE"
  fi
done
'

run_shell "Config GameMode" '
for f in \
  /etc/gamemode.ini \
  "$HOME/.config/gamemode.ini"
do
  echo
  echo "--- $f ---"
  if [ -e "$f" ]; then
    ls -l "$f"
    sed -n "1,220p" "$f" 2>/dev/null || true
  else
    echo "AUSENTE"
  fi
done
'

run_shell "Config MangoHud" '
for f in \
  /usr/local/share/mocha/mangohud/MangoHud.conf \
  "$HOME/.config/MangoHud/MangoHud.conf"
do
  echo
  echo "--- $f ---"
  if [ -e "$f" ]; then
    ls -l "$f"
    sed -n "1,220p" "$f" 2>/dev/null || true
  else
    echo "AUSENTE"
  fi
done
'

run_shell "Limites FPS / VSync suspeitos em configs Steam e wrapper" '
grep -RInE "fps_limit|fps_limit_method|vsync|vblank|MANGOHUD_CONFIG|DXVK_FRAME_RATE|vblank_mode|__GL_SYNC_TO_VBLANK|gamescope|vkBasalt|MANGOHUD_DLSYM" \
  /usr/local/bin/mocha-steam-game-run \
  /usr/local/share/mocha \
  "$HOME/.steam" \
  "$HOME/.local/share/Steam/userdata" \
  "$HOME/.config/MangoHud" \
  2>/dev/null | head -200 || true
'

run_shell "Thermal throttling / erros recentes" '
dmesg -T 2>/dev/null | grep -Ei "nvrm|xid|thermal|thrott|overheat|reset|pcie|gpu|amdgpu|mce|hardware error" | tail -120 || true
'

run_shell "Top processos no momento" '
ps -eo pid,ppid,comm,%cpu,%mem,args --sort=-%cpu | head -35 || true
'

{
  echo
  echo "============================================================"
  echo "Resumo automático"
  echo "============================================================"

  GM="$(timeout 4s gamemoded -s 2>/dev/null || true)"
  if echo "$GM" | grep -qi "active"; then
    echo "[OK] GameMode aparenta estar ativo."
  else
    echo "[SUSPEITO] GameMode não aparenta estar ativo."
  fi

  if command -v nvidia-smi >/dev/null 2>&1; then
    PSTATE="$(nvidia-smi --query-gpu=pstate --format=csv,noheader 2>/dev/null | head -1 || true)"
    echo "P-State NVIDIA: ${PSTATE:-desconhecido}"
    if [ "${PSTATE:-}" != "P0" ]; then
      echo "[SUSPEITO] GPU não está em P0 no momento da coleta."
    fi
  fi

  if command -v nvidia-settings >/dev/null 2>&1; then
    GFX_OC="$(nvidia-settings -q "[gpu:0]/GPUGraphicsClockOffsetAllPerformanceLevels" 2>/dev/null | grep -Eo -- "-?[0-9]+" | tail -1 || true)"
    MEM_OC="$(nvidia-settings -q "[gpu:0]/GPUMemoryTransferRateOffsetAllPerformanceLevels" 2>/dev/null | grep -Eo -- "-?[0-9]+" | tail -1 || true)"
    echo "OC GPU: ${GFX_OC:-desconhecido}"
    echo "OC VRAM: ${MEM_OC:-desconhecido}"
    if [ "${GFX_OC:-0}" = "0" ] || [ "${MEM_OC:-0}" = "0" ]; then
      echo "[SUSPEITO] Offset de OC parece zerado ou não aplicado."
    fi
  fi

  if grep -Rqs "gamescope\|vkBasalt\|MANGOHUD_DLSYM\|DXVK_FRAME_RATE\|__GL_SYNC_TO_VBLANK=1" /usr/local/bin/mocha-steam-game-run "$HOME/.local/share/Steam/userdata" "$HOME/.config/MangoHud" 2>/dev/null; then
    echo "[SUSPEITO] Encontrado limitador/interferência possível em configs/wrapper."
  fi

  echo
  echo "Log salvo em:"
  echo "$LOG"
} | tee -a "$LOG"
