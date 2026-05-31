#!/usr/bin/env bash
set -Eeuo pipefail

RUN_DIR="$1"
SAMPLES="$RUN_DIR/amostras.tsv"
EVENTS="$RUN_DIR/eventos.log"
PROCS="$RUN_DIR/processos.log"
STOP_FILE="$RUN_DIR/PARAR"

INTERVAL=5

trim_field() {
  sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

gm_state_now() {
  if ! command -v gamemoded >/dev/null 2>&1; then
    printf 'AUSENTE\tgamemoded ausente'
    return 0
  fi

  raw="$(gamemoded -s 2>&1 | tr '\n' ' ' | tr '\t' ' ' || true)"

  if printf '%s' "$raw" | grep -Eiq 'inactive|not active|off|desativ|inativo'; then
    printf 'OFF\t%s' "$raw"
  elif printf '%s' "$raw" | grep -Eiq 'active|on|ativ'; then
    printf 'ON\t%s' "$raw"
  else
    printf 'INCERTO\t%s' "$raw"
  fi
}

gpu_now() {
  if ! command -v nvidia-smi >/dev/null 2>&1; then
    printf 'NA\tNA\tNA\tNA\tNA\tNA\tNA\tNA'
    return 0
  fi

  line="$(nvidia-smi --query-gpu=pstate,utilization.gpu,utilization.memory,temperature.gpu,power.draw,power.limit,clocks.gr,clocks.mem --format=csv,noheader,nounits 2>/dev/null | head -n1 || true)"

  if [ -z "$line" ]; then
    printf 'NA\tNA\tNA\tNA\tNA\tNA\tNA\tNA'
    return 0
  fi

  IFS=',' read -r pstate gpu_util mem_util temp power power_limit gr_clock mem_clock <<< "$line"

  pstate="$(printf '%s' "${pstate:-NA}" | trim_field)"
  gpu_util="$(printf '%s' "${gpu_util:-NA}" | trim_field)"
  mem_util="$(printf '%s' "${mem_util:-NA}" | trim_field)"
  temp="$(printf '%s' "${temp:-NA}" | trim_field)"
  power="$(printf '%s' "${power:-NA}" | trim_field)"
  power_limit="$(printf '%s' "${power_limit:-NA}" | trim_field)"
  gr_clock="$(printf '%s' "${gr_clock:-NA}" | trim_field)"
  mem_clock="$(printf '%s' "${mem_clock:-NA}" | trim_field)"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' "$pstate" "$gpu_util" "$mem_util" "$temp" "$power" "$power_limit" "$gr_clock" "$mem_clock"
}

cpu_freq_now() {
  shopt -s nullglob
  files=(/sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq)

  if [ "${#files[@]}" -eq 0 ]; then
    printf 'NA\tNA\tNA'
    return 0
  fi

  awk '
    {
      mhz=$1/1000
      if (NR==1 || mhz<min) min=mhz
      if (NR==1 || mhz>max) max=mhz
      sum+=mhz
      n++
    }
    END {
      if (n>0) printf "%.0f\t%.0f\t%.0f", min, sum/n, max
      else printf "NA\tNA\tNA"
    }
  ' "${files[@]}"
}

cpu_govs_now() {
  shopt -s nullglob
  files=(/sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor)

  if [ "${#files[@]}" -eq 0 ]; then
    printf 'NA'
    return 0
  fi

  cat "${files[@]}" 2>/dev/null | sort | uniq -c | awk '{printf "%sx%s ", $2, $1}' | sed 's/[[:space:]]*$//'
}

mem_now() {
  awk '
    /MemTotal:/ { total=$2 }
    /MemAvailable:/ { avail=$2 }
    END {
      if (total>0 && avail>0) printf "%d\t%d", (total-avail)/1024, avail/1024
      else printf "NA\tNA"
    }
  ' /proc/meminfo
}

psi_now() {
  cpu_some="$(awk '/some/ {print $2}' /proc/pressure/cpu 2>/dev/null | sed 's/avg10=//' || true)"
  mem_some="$(awk '/some/ {print $2}' /proc/pressure/memory 2>/dev/null | sed 's/avg10=//' || true)"
  io_some="$(awk '/some/ {print $2}' /proc/pressure/io 2>/dev/null | sed 's/avg10=//' || true)"
  printf '%s\t%s\t%s' "${cpu_some:-NA}" "${mem_some:-NA}" "${io_some:-NA}"
}

proc_count_now() {
  list="$(pgrep -af 'steamapps|Proton|proton|wine64|wine|wineserver|pressure-vessel|GameOverlayUI|gamemoderun|mangohud' 2>/dev/null || true)"
  count="$(printf '%s\n' "$list" | sed '/^[[:space:]]*$/d' | wc -l)"
  pids="$(printf '%s\n' "$list" | sed '/^[[:space:]]*$/d' | awk '{print $1}' | paste -sd, -)"
  [ -n "$pids" ] || pids="NA"
  printf '%s\t%s' "$count" "$pids"
}

printf 'iso_time\tgamemode_state\tgamemode_raw\tgpu_pstate\tgpu_util_pct\tgpu_mem_util_pct\tgpu_temp_c\tgpu_power_w\tgpu_power_limit_w\tgpu_clock_mhz\tgpu_mem_clock_mhz\tcpu_min_mhz\tcpu_avg_mhz\tcpu_max_mhz\tcpu_governors\tload1\tmem_used_mb\tmem_avail_mb\tpsi_cpu_some10\tpsi_mem_some10\tpsi_io_some10\tproc_count\tproc_pids\n' > "$SAMPLES"

echo "Coletor externo leve iniciado em $(date --iso-8601=seconds)" >> "$EVENTS"
echo "Intervalo: ${INTERVAL}s" >> "$EVENTS"
echo "Parar criando arquivo: $STOP_FILE" >> "$EVENTS"

i=0
while [ ! -e "$STOP_FILE" ]; do
  iso="$(date --iso-8601=seconds)"
  gm="$(gm_state_now)"
  gpu="$(gpu_now)"
  cpu="$(cpu_freq_now)"
  govs="$(cpu_govs_now)"
  load1="$(awk '{print $1}' /proc/loadavg 2>/dev/null || echo NA)"
  mem="$(mem_now)"
  psi="$(psi_now)"
  procs="$(proc_count_now)"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$iso" "$gm" "$gpu" "$cpu" "$govs" "$load1" "$mem" "$psi" "$procs" >> "$SAMPLES"

  if [ $((i % 6)) -eq 0 ]; then
    {
      echo
      echo "===== $iso ====="
      pgrep -af 'steamapps|Proton|proton|wine64|wine|wineserver|pressure-vessel|GameOverlayUI|gamemoderun|mangohud' 2>/dev/null || echo "Nenhum processo Steam/Proton/Wine detectado."
    } >> "$PROCS"
  fi

  i=$((i + 1))
  sleep "$INTERVAL"
done

echo "Coletor externo leve encerrado em $(date --iso-8601=seconds)" >> "$EVENTS"
