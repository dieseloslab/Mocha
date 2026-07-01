#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

DURATION="${MOCHA_TEST_DURATION:-300}"
INTERVAL="${MOCHA_TEST_INTERVAL:-2}"
EXPECTED=$(( DURATION / INTERVAL ))

BASE="${MOCHA_TEST_DIR:-$HOME/mocha-tests}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$BASE/teste-5min-avaliacao-precisa-$STAMP"

RAW="$OUT/amostras.psv"
META="$OUT/metadados.txt"
SUMMARY="$OUT/resumo.txt"
JOURNAL="$OUT/kernel-journal-warning-alert.txt"
NVIDIA_ERR="$OUT/nvidia-smi-erros.txt"
NVIDIA_ALERTS="$OUT/alertas-nvidia-kernel.txt"

mkdir -p "$OUT"
touch "$NVIDIA_ERR"

SUDO_KEEPALIVE_PID=""
(
  while true; do
    sudo -n true >/dev/null 2>&1 || exit
    sleep 30
  done
) &
SUDO_KEEPALIVE_PID="$!"

cleanup() {
  set +e
  [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

trim() {
  local x="${1:-}"
  x="${x#"${x%%[![:space:]]*}"}"
  x="${x%"${x##*[![:space:]]}"}"
  printf '%s' "$x"
}

cmd_or_na() {
  timeout 5 bash -lc "$*" 2>/dev/null || true
}

cpu_read() {
  awk '/^cpu / {
    total=$2+$3+$4+$5+$6+$7+$8+$9+$10
    idle=$5+$6
    busy=total-idle
    print total, busy
  }' /proc/stat
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[FALHA] Comando ausente: $1"
    exit 1
  fi
}

require_cmd nvidia-smi
require_cmd python3

START_ISO="$(date --iso-8601=seconds)"
START_EPOCH="$(date +%s)"

{
  echo "============================================================"
  echo " Mocha — teste 5 min avaliação precisa"
  echo "============================================================"
  echo "Inicio: $START_ISO"
  echo "Duracao: ${DURATION}s"
  echo "Intervalo: ${INTERVAL}s"
  echo "Amostras previstas: $EXPECTED"
  echo
  echo "Sistema:"
  echo "  Hostname: $(hostname)"
  echo "  Kernel: $(uname -r)"
  echo "  OS: $(grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2- | tr -d '\"' || true)"
  echo
  echo "CPU:"
  lscpu | grep -E 'Model name|Architecture|CPU\(s\)|Thread|Core|Socket|MHz|Flags' | head -n 12 || true
  echo
  echo "GPU NVIDIA:"
  timeout 5 nvidia-smi --query-gpu=name,driver_version,pstate,pci.bus_id,memory.total,power.limit --format=csv,noheader,nounits || true
  echo
  echo "Pacotes relevantes:"
  pacman -Q \
    linux linux-headers linux-zen linux-zen-headers \
    linux-cachyos linux-cachyos-headers \
    linux-cachyos-nvidia-open nvidia-open nvidia-utils \
    gamemode tuned system76-scheduler \
    2>/dev/null || true
  echo
  echo "GameMode inicial:"
  timeout 5 gamemoded -s 2>/dev/null || true
  echo
  echo "TuneD inicial:"
  timeout 5 tuned-adm active 2>/dev/null || true
  echo
  echo "system76-scheduler inicial:"
  timeout 5 systemctl is-active com.system76.Scheduler.service 2>/dev/null || true
  timeout 5 systemctl is-enabled com.system76.Scheduler.service 2>/dev/null || true
  echo
  echo "OC NVIDIA inicial:"
  timeout 5 nvidia-settings -q '[gpu:0]/GPUGraphicsClockOffsetAllPerformanceLevels' -t 2>/dev/null || true
  timeout 5 nvidia-settings -q '[gpu:0]/GPUMemoryTransferRateOffsetAllPerformanceLevels' -t 2>/dev/null || true
} | tee "$META"

cat > "$RAW" <<'HEADER'
epoch|iso|cpu_busy_pct|driver|pstate|gpu_clock_mhz|gpu_mem_clock_mhz|power_w|temp_c|gpu_util_pct|gpu_mem_util_pct|vram_used_mib|vram_total_mib|hw_slowdown|sw_power_cap|gamemode_active|system76_service|top_process
HEADER

read -r PREV_TOTAL PREV_BUSY < <(cpu_read)

echo
echo "============================================================"
echo " Iniciando coleta de 5 minutos"
echo " Saida: $OUT"
echo " Mantenha o jogo rodando na mesma cena/carga durante o teste."
echo "============================================================"
echo

sample=0
while true; do
  now_epoch="$(date +%s)"
  elapsed=$(( now_epoch - START_EPOCH ))
  [ "$elapsed" -ge "$DURATION" ] && break

  sample=$(( sample + 1 ))
  remaining=$(( DURATION - elapsed ))

  read -r TOTAL BUSY < <(cpu_read)
  DT=$(( TOTAL - PREV_TOTAL ))
  DB=$(( BUSY - PREV_BUSY ))
  PREV_TOTAL="$TOTAL"
  PREV_BUSY="$BUSY"

  if [ "$DT" -gt 0 ]; then
    CPU_BUSY="$(awk -v db="$DB" -v dt="$DT" 'BEGIN { printf "%.2f", (db/dt)*100 }')"
  else
    CPU_BUSY="0.00"
  fi

  ISO="$(date --iso-8601=seconds)"

  GPU_LINE="$(
    timeout 4 nvidia-smi \
      --query-gpu=driver_version,pstate,clocks.gr,clocks.mem,power.draw,temperature.gpu,utilization.gpu,utilization.memory,memory.used,memory.total,clocks_throttle_reasons.hw_slowdown,clocks_throttle_reasons.sw_power_cap \
      --format=csv,noheader,nounits \
      2>>"$NVIDIA_ERR" | head -n1 || true
  )"

  if [ -n "$GPU_LINE" ]; then
    IFS=',' read -r DRIVER PSTATE GCLK MCLK POWER TEMP GUTIL GMEMUTIL VRAMUSED VRAMTOTAL HWSLOW SWPOWER <<< "$GPU_LINE"

    DRIVER="$(trim "$DRIVER")"
    PSTATE="$(trim "$PSTATE")"
    GCLK="$(trim "$GCLK")"
    MCLK="$(trim "$MCLK")"
    POWER="$(trim "$POWER")"
    TEMP="$(trim "$TEMP")"
    GUTIL="$(trim "$GUTIL")"
    GMEMUTIL="$(trim "$GMEMUTIL")"
    VRAMUSED="$(trim "$VRAMUSED")"
    VRAMTOTAL="$(trim "$VRAMTOTAL")"
    HWSLOW="$(trim "$HWSLOW")"
    SWPOWER="$(trim "$SWPOWER")"
  else
    DRIVER="NA"
    PSTATE="NA"
    GCLK="NA"
    MCLK="NA"
    POWER="NA"
    TEMP="NA"
    GUTIL="NA"
    GMEMUTIL="NA"
    VRAMUSED="NA"
    VRAMTOTAL="NA"
    HWSLOW="NA"
    SWPOWER="NA"
  fi

  if command -v gamemoded >/dev/null 2>&1; then
    if timeout 3 gamemoded -s 2>/dev/null | grep -qi 'is active'; then
      GM_ACTIVE="1"
    else
      GM_ACTIVE="0"
    fi
  else
    GM_ACTIVE="NA"
  fi

  SYS76="$(timeout 3 systemctl is-active com.system76.Scheduler.service 2>/dev/null || true)"
  [ -n "$SYS76" ] || SYS76="NA"

  TOPPROC="$(
    ps -eo comm=,%cpu= --sort=-%cpu 2>/dev/null \
      | awk 'NR==1 { gsub(/[|]/, "/", $0); print $0 }'
  )"
  [ -n "$TOPPROC" ] || TOPPROC="NA"

  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
    "$now_epoch" "$ISO" "$CPU_BUSY" "$DRIVER" "$PSTATE" "$GCLK" "$MCLK" "$POWER" "$TEMP" "$GUTIL" "$GMEMUTIL" "$VRAMUSED" "$VRAMTOTAL" "$HWSLOW" "$SWPOWER" "$GM_ACTIVE" "$SYS76" "$TOPPROC" \
    >> "$RAW"

  printf '[%03d/%03d] restante=%03ds | GPU=%s%% | temp=%sC | clock=%sMHz | power=%sW | VRAM=%sMiB | GM=%s | system76=%s\n' \
    "$sample" "$EXPECTED" "$remaining" "$GUTIL" "$TEMP" "$GCLK" "$POWER" "$VRAMUSED" "$GM_ACTIVE" "$SYS76"

  sleep "$INTERVAL"
done

END_ISO="$(date --iso-8601=seconds)"

echo
echo "============================================================"
echo " Coleta encerrada. Capturando journal do kernel..."
echo "============================================================"

timeout 12 sudo journalctl -k --since "$START_ISO" --until "$END_ISO" -p warning..alert --no-pager > "$JOURNAL" 2>/dev/null || true
grep -Ei 'NVRM|Xid|GPU has fallen|fallen off|pcie|PCIe Bus Error|nvidia|nvml|reset|timeout' "$JOURNAL" > "$NVIDIA_ALERTS" 2>/dev/null || true

python3 - "$RAW" "$SUMMARY" "$JOURNAL" "$NVIDIA_ALERTS" "$EXPECTED" "$OUT" <<'PY'
import csv
import math
import re
import statistics
import sys
from collections import Counter
from pathlib import Path

raw = Path(sys.argv[1])
summary = Path(sys.argv[2])
journal = Path(sys.argv[3])
nvidia_alerts = Path(sys.argv[4])
expected = int(sys.argv[5])
out = Path(sys.argv[6])

def to_float(value):
    if value is None:
        return None
    value = str(value).strip()
    if not value or value.upper() in {"NA", "N/A", "[N/A]", "UNKNOWN"}:
        return None
    m = re.search(r"-?\d+(?:\.\d+)?", value)
    if not m:
        return None
    try:
        return float(m.group(0))
    except ValueError:
        return None

def percentile(values, p):
    values = sorted(values)
    if not values:
        return None
    if len(values) == 1:
        return values[0]
    k = (len(values) - 1) * (p / 100.0)
    f = math.floor(k)
    c = math.ceil(k)
    if f == c:
        return values[int(k)]
    return values[f] * (c - k) + values[c] * (k - f)

def stat(values):
    values = [v for v in values if v is not None]
    if not values:
        return None
    return {
        "n": len(values),
        "avg": statistics.fmean(values),
        "min": min(values),
        "max": max(values),
        "p95": percentile(values, 95),
        "stdev": statistics.pstdev(values) if len(values) > 1 else 0.0,
    }

def fmt(x, unit=""):
    if x is None:
        return "NA"
    return f"{x:.2f}{unit}"

with raw.open(newline="") as f:
    rows = list(csv.DictReader(f, delimiter="|"))

numeric_cols = {
    "CPU busy": ("cpu_busy_pct", "%"),
    "GPU util": ("gpu_util_pct", "%"),
    "GPU mem util": ("gpu_mem_util_pct", "%"),
    "GPU clock": ("gpu_clock_mhz", " MHz"),
    "VRAM clock": ("gpu_mem_clock_mhz", " MHz"),
    "Power": ("power_w", " W"),
    "Temp": ("temp_c", " C"),
    "VRAM usada": ("vram_used_mib", " MiB"),
}

stats = {}
for label, (col, unit) in numeric_cols.items():
    stats[label] = (stat([to_float(r.get(col)) for r in rows]), unit)

sample_count = len(rows)
valid_gpu = sum(1 for r in rows if to_float(r.get("gpu_util_pct")) is not None)
gpu_failures = sample_count - valid_gpu

gm_known = [r.get("gamemode_active") for r in rows if r.get("gamemode_active") in {"0", "1"}]
gm_active_ratio = (sum(1 for v in gm_known if v == "1") / len(gm_known) * 100.0) if gm_known else None

sys76_known = [r.get("system76_service", "").strip() for r in rows if r.get("system76_service", "").strip() not in {"", "NA"}]
sys76_counter = Counter(sys76_known)

pstate_counter = Counter(r.get("pstate", "NA") for r in rows)
driver_counter = Counter(r.get("driver", "NA") for r in rows)

hw_values = [r.get("hw_slowdown", "").strip().lower() for r in rows]
hw_active = sum(1 for v in hw_values if v == "active")
hw_known = sum(1 for v in hw_values if v not in {"", "na", "not supported", "[not supported]"})

sw_values = [r.get("sw_power_cap", "").strip().lower() for r in rows]
sw_active = sum(1 for v in sw_values if v == "active")
sw_known = sum(1 for v in sw_values if v not in {"", "na", "not supported", "[not supported]"})

journal_text = journal.read_text(errors="replace") if journal.exists() else ""
nvidia_text = nvidia_alerts.read_text(errors="replace") if nvidia_alerts.exists() else ""

failures = []
warnings = []

if sample_count < max(1, int(expected * 0.90)):
    failures.append(f"Amostras insuficientes: {sample_count}/{expected}.")

if sample_count and gpu_failures / sample_count > 0.05:
    failures.append(f"Falhas de leitura do nvidia-smi acima de 5%: {gpu_failures}/{sample_count}.")

temp_stat = stats["Temp"][0]
gpu_util_stat = stats["GPU util"][0]
gpu_clock_stat = stats["GPU clock"][0]

if temp_stat:
    if temp_stat["max"] >= 88:
        failures.append(f"Temperatura máxima crítica: {temp_stat['max']:.1f} C.")
    elif temp_stat["p95"] >= 83:
        warnings.append(f"Temperatura p95 alta: {temp_stat['p95']:.1f} C.")

if gpu_util_stat:
    if gpu_util_stat["avg"] < 50 and gpu_util_stat["p95"] < 70:
        warnings.append("Carga de GPU baixa. O teste pode ter sido feito em menu, cena leve ou jogo limitado por CPU/FPS.")
else:
    failures.append("Não foi possível calcular utilização da GPU.")

if gpu_clock_stat and gpu_util_stat:
    if gpu_util_stat["avg"] >= 70 and gpu_clock_stat["avg"] < 1000:
        failures.append("Clock médio da GPU baixo sob carga alta. Possível regressão, throttling ou perfil de energia incorreto.")

if gm_active_ratio is not None and gm_active_ratio < 80:
    warnings.append(f"GameMode ativo em apenas {gm_active_ratio:.1f}% das amostras.")

if hw_known and hw_active > 0:
    failures.append(f"HW slowdown NVIDIA ativo em {hw_active}/{hw_known} amostras.")

if nvidia_text.strip():
    failures.append("Alertas NVIDIA/kernel encontrados no journal durante o teste.")

if "Xid" in journal_text or "NVRM" in journal_text:
    failures.append("Ocorrência NVRM/Xid detectada no journal.")

if failures:
    result = "FALHA"
elif warnings:
    result = "APROVADO COM ALERTAS"
else:
    result = "APROVADO"

lines = []
lines.append("============================================================")
lines.append(" Mocha — resumo do teste 5 min")
lines.append("============================================================")
lines.append(f"Resultado: {result}")
lines.append(f"Amostras: {sample_count}/{expected}")
lines.append(f"Amostras GPU válidas: {valid_gpu}/{sample_count}")
lines.append("")
lines.append("Driver NVIDIA observado:")
for drv, n in driver_counter.most_common():
    lines.append(f"  {drv}: {n} amostras")
lines.append("")
lines.append("P-states observados:")
for ps, n in pstate_counter.most_common():
    lines.append(f"  {ps}: {n} amostras")
lines.append("")
lines.append("Estatísticas:")
lines.append("  Métrica        média       min         max         p95         desvio")
for label, (s, unit) in stats.items():
    if not s:
        lines.append(f"  {label:<13} NA")
    else:
        lines.append(
            f"  {label:<13} "
            f"{fmt(s['avg'], unit):>10} "
            f"{fmt(s['min'], unit):>10} "
            f"{fmt(s['max'], unit):>10} "
            f"{fmt(s['p95'], unit):>10} "
            f"{fmt(s['stdev'], unit):>10}"
        )

lines.append("")
lines.append(f"GameMode ativo: {fmt(gm_active_ratio, '%') if gm_active_ratio is not None else 'NA'}")
lines.append("system76-scheduler:")
if sys76_counter:
    for state, n in sys76_counter.most_common():
        lines.append(f"  {state}: {n} amostras")
else:
    lines.append("  NA")

lines.append("")
lines.append(f"HW slowdown NVIDIA ativo: {hw_active}/{hw_known if hw_known else 0}")
lines.append(f"SW power cap NVIDIA ativo: {sw_active}/{sw_known if sw_known else 0}")
lines.append("")
lines.append("Diagnóstico:")
if failures:
    for item in failures:
        lines.append(f"  [FALHA] {item}")
if warnings:
    for item in warnings:
        lines.append(f"  [ALERTA] {item}")
if not failures and not warnings:
    lines.append("  Sem falhas, sem alertas relevantes e sem erro NVIDIA/kernel detectado.")

lines.append("")
lines.append("Arquivos gerados:")
lines.append(f"  Pasta: {out}")
lines.append(f"  Amostras: {raw}")
lines.append(f"  Resumo: {summary}")
lines.append(f"  Journal kernel: {journal}")
lines.append(f"  Alertas NVIDIA/kernel: {nvidia_alerts}")
lines.append("============================================================")

text = "\n".join(lines)
summary.write_text(text + "\n")
print(text)
PY

echo
echo "Resumo salvo em:"
echo "$SUMMARY"
echo
echo "Para ver novamente:"
echo "cat '$SUMMARY'"
