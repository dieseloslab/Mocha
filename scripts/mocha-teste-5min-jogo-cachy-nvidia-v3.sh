#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

DURACAO=300
INTERVALO=5
AMOSTRAS=$((DURACAO / INTERVALO))
STAMP="$(date +%Y%m%d-%H%M%S)"

BASE="/media/mochafast/MochaArch/auditorias"
if [ ! -d "$BASE" ] || [ ! -w "$BASE" ]; then
  BASE="$HOME/mocha-auditorias"
fi

OUT="$BASE/teste-5min-jogo-$STAMP"
mkdir -p "$OUT"

CSV="$OUT/amostras.csv"
RESUMO="$OUT/resumo.txt"
RAW_GPU="$OUT/gpu-raw.csv"
RAW_GAME="$OUT/gamemode-raw.txt"
RAW_NVSET="$OUT/nvidia-settings-raw.txt"

trim() {
  sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

num_or_zero() {
  awk '{
    gsub(/[^0-9.]/,"",$0);
    if ($0 == "") print 0;
    else print $0;
  }'
}

echo
echo "============================================================"
echo " Mocha — teste de 5 minutos com jogo rodando"
echo "============================================================"
echo
echo "[INFO] Duração: ${DURACAO}s"
echo "[INFO] Intervalo: ${INTERVALO}s"
echo "[INFO] Amostras: ${AMOSTRAS}"
echo "[INFO] Saída: $OUT"
echo

{
  echo "timestamp,elapsed_s,gamemode_active,gpu_name,driver,pstate,gpu_clock_mhz,mem_clock_mhz,power_w,temp_c,gpu_util_pct,vram_used_mib,vram_total_mib,ram_used_mib,ram_total_mib,load1,load5,load15,cpu_busy_pct"
} > "$CSV"

echo "[INFO] Captura inicial do sistema..." | tee "$RESUMO"

{
  echo "============================================================"
  echo " Mocha — resumo inicial"
  echo "============================================================"
  echo
  echo "Data: $(date -Is)"
  echo "Kernel: $(uname -r)"
  echo
  echo "Pacotes:"
  pacman -Q linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open 2>/dev/null || true
  pacman -Q nvidia-open nvidia-utils linux linux-zen linux-lts 2>/dev/null || true
  echo
  echo "CPU:"
  lscpu | awk -F: '/Model name|CPU\(s\)|Thread|Core|Socket|Vendor ID|Flags/ {gsub(/^[ \t]+/,"",$2); print $1 ": " $2}' || true
  echo
  echo "Memória:"
  free -h || true
  echo
  echo "GameMode inicial:"
  timeout 5 gamemoded -s 2>&1 || true
  echo
  echo "TuneD:"
  timeout 5 tuned-adm active 2>&1 || true
  timeout 5 tuned-adm verify 2>&1 || true
  echo
  echo "NVIDIA inicial:"
  timeout 5 nvidia-smi 2>&1 || true
  echo
  echo "nvidia-settings inicial:"
  timeout 5 nvidia-settings -q '[gpu:0]/GPUPowerMizerMode' 2>&1 || true
  timeout 5 nvidia-settings -q '[gpu:0]/GPUGraphicsClockOffsetAllPerformanceLevels' 2>&1 || true
  timeout 5 nvidia-settings -q '[gpu:0]/GPUMemoryTransferRateOffsetAllPerformanceLevels' 2>&1 || true
} >> "$RESUMO"

START_EPOCH="$(date +%s)"
PREV_IDLE=""
PREV_TOTAL=""

for i in $(seq 1 "$AMOSTRAS"); do
  NOW_EPOCH="$(date +%s)"
  ELAPSED=$((NOW_EPOCH - START_EPOCH))
  RESTANTE=$((DURACAO - ELAPSED))
  [ "$RESTANTE" -lt 0 ] && RESTANTE=0

  TS="$(date -Is)"

  if timeout 3 gamemoded -s 2>&1 | tee -a "$RAW_GAME" | grep -qi 'gamemode is active'; then
    GM=1
  else
    GM=0
  fi

  GPU_LINE="$(timeout 5 nvidia-smi \
    --query-gpu=name,driver_version,pstate,clocks.gr,clocks.mem,power.draw,temperature.gpu,utilization.gpu,memory.used,memory.total \
    --format=csv,noheader,nounits 2>/dev/null | head -n1 || true)"

  echo "$TS,$GPU_LINE" >> "$RAW_GPU"

  IFS=',' read -r GPU_NAME DRIVER PSTATE GPU_CLOCK MEM_CLOCK POWER TEMP UTIL VRAM_USED VRAM_TOTAL <<< "$GPU_LINE"

  GPU_NAME="$(printf '%s' "${GPU_NAME:-}" | trim)"
  DRIVER="$(printf '%s' "${DRIVER:-}" | trim)"
  PSTATE="$(printf '%s' "${PSTATE:-}" | trim)"
  GPU_CLOCK="$(printf '%s' "${GPU_CLOCK:-0}" | num_or_zero)"
  MEM_CLOCK="$(printf '%s' "${MEM_CLOCK:-0}" | num_or_zero)"
  POWER="$(printf '%s' "${POWER:-0}" | num_or_zero)"
  TEMP="$(printf '%s' "${TEMP:-0}" | num_or_zero)"
  UTIL="$(printf '%s' "${UTIL:-0}" | num_or_zero)"
  VRAM_USED="$(printf '%s' "${VRAM_USED:-0}" | num_or_zero)"
  VRAM_TOTAL="$(printf '%s' "${VRAM_TOTAL:-0}" | num_or_zero)"

  read -r RAM_TOTAL RAM_USED < <(free -m | awk '/^Mem:/ {print $2, $3}')
  read -r LOAD1 LOAD5 LOAD15 _ < /proc/loadavg

  read -r _ CPU_USER CPU_NICE CPU_SYSTEM CPU_IDLE CPU_IOWAIT CPU_IRQ CPU_SOFTIRQ CPU_STEAL _ < /proc/stat

  IDLE=$((CPU_IDLE + CPU_IOWAIT))
  TOTAL=$((CPU_USER + CPU_NICE + CPU_SYSTEM + CPU_IDLE + CPU_IOWAIT + CPU_IRQ + CPU_SOFTIRQ + CPU_STEAL))

  if [ -n "$PREV_TOTAL" ]; then
    DIFF_IDLE=$((IDLE - PREV_IDLE))
    DIFF_TOTAL=$((TOTAL - PREV_TOTAL))
    if [ "$DIFF_TOTAL" -gt 0 ]; then
      CPU_BUSY="$(awk -v idle="$DIFF_IDLE" -v total="$DIFF_TOTAL" 'BEGIN { printf "%.1f", 100 * (1 - idle / total) }')"
    else
      CPU_BUSY="0"
    fi
  else
    CPU_BUSY="0"
  fi

  PREV_IDLE="$IDLE"
  PREV_TOTAL="$TOTAL"

  printf '%s,%s,%s,"%s",%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
    "$TS" "$ELAPSED" "$GM" "$GPU_NAME" "$DRIVER" "$PSTATE" \
    "$GPU_CLOCK" "$MEM_CLOCK" "$POWER" "$TEMP" "$UTIL" \
    "$VRAM_USED" "$VRAM_TOTAL" "$RAM_USED" "$RAM_TOTAL" \
    "$LOAD1" "$LOAD5" "$LOAD15" "$CPU_BUSY" >> "$CSV"

  printf '[%02d/%02d] restante=%03ds GameMode=%s GPU=%s%% PState=%s Clock=%sMHz Mem=%sMHz Power=%sW Temp=%sC VRAM=%s/%sMiB CPU=%s%%\n' \
    "$i" "$AMOSTRAS" "$RESTANTE" "$GM" "$UTIL" "$PSTATE" "$GPU_CLOCK" "$MEM_CLOCK" "$POWER" "$TEMP" "$VRAM_USED" "$VRAM_TOTAL" "$CPU_BUSY"

  sleep "$INTERVALO"
done

{
  echo
  echo "============================================================"
  echo " Resumo estatístico"
  echo "============================================================"
  echo
  awk -F',' '
    NR > 1 {
      n++
      gm += $3
      gpu += $11
      power += $9
      temp += $10
      vram += $12
      cpu += $19

      if (n == 1 || $11 > gpu_max) gpu_max = $11
      if (n == 1 || $9 > power_max) power_max = $9
      if (n == 1 || $10 > temp_max) temp_max = $10
      if (n == 1 || $12 > vram_max) vram_max = $12
      if (n == 1 || $19 > cpu_max) cpu_max = $19

      if ($6 ~ /P0/) p0++
      if ($6 ~ /P[1-9]/) pnot0++
    }
    END {
      if (n == 0) {
        print "Sem amostras válidas."
        exit
      }

      printf "Amostras: %d\n", n
      printf "GameMode ativo: %.1f%% das amostras\n", 100 * gm / n
      printf "GPU util média/máx: %.1f%% / %.1f%%\n", gpu / n, gpu_max
      printf "CPU busy média/máx: %.1f%% / %.1f%%\n", cpu / n, cpu_max
      printf "Power média/máx: %.1fW / %.1fW\n", power / n, power_max
      printf "Temperatura média/máx: %.1fC / %.1fC\n", temp / n, temp_max
      printf "VRAM média/máx: %.0fMiB / %.0fMiB\n", vram / n, vram_max
      printf "P0: %d amostras\n", p0
      printf "Não-P0: %d amostras\n", pnot0
    }
  ' "$CSV"

  echo
  echo "============================================================"
  echo " Final GameMode/NVIDIA"
  echo "============================================================"
  timeout 5 gamemoded -s 2>&1 || true
  echo
  timeout 5 nvidia-settings -q '[gpu:0]/GPUPowerMizerMode' 2>&1 | tee -a "$RAW_NVSET" || true
  timeout 5 nvidia-settings -q '[gpu:0]/GPUGraphicsClockOffsetAllPerformanceLevels' 2>&1 | tee -a "$RAW_NVSET" || true
  timeout 5 nvidia-settings -q '[gpu:0]/GPUMemoryTransferRateOffsetAllPerformanceLevels' 2>&1 | tee -a "$RAW_NVSET" || true
} | tee -a "$RESUMO"

echo
echo "============================================================"
echo " Concluído"
echo "============================================================"
echo "[OK] Script salvo em: $0"
echo "[OK] CSV: $CSV"
echo "[OK] Resumo: $RESUMO"
echo
echo "Cole aqui o bloco final do resumo."
