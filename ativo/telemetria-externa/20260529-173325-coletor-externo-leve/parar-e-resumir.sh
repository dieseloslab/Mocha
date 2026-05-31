#!/usr/bin/env bash
set -Eeuo pipefail

RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOP_FILE="$RUN_DIR/PARAR"
PID_FILE="$RUN_DIR/coletor.pid"
SAMPLES="$RUN_DIR/amostras.tsv"
EVENTS="$RUN_DIR/eventos.log"
PROCS="$RUN_DIR/processos.log"
SUMMARY="$RUN_DIR/resumo-final.md"

touch "$STOP_FILE"

if [ -f "$PID_FILE" ]; then
  PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [ -n "${PID:-}" ]; then
    for _ in 1 2 3 4 5 6; do
      if kill -0 "$PID" 2>/dev/null; then
        sleep 1
      else
        break
      fi
    done

    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID" 2>/dev/null || true
      sleep 1
    fi
  fi
fi

{
  echo "# Mocha Arch/KDE — Resumo final do coletor externo leve"
  echo
  echo "- Encerrado em: $(date --iso-8601=seconds)"
  echo "- Pasta: \`$RUN_DIR\`"
  echo
  echo "## Resumo numérico"
  echo
  echo '```'
  if [ -s "$SAMPLES" ]; then
    awk -F'\t' '
      NR==1 { next }
      {
        n++

        if ($2=="ON") gm_on++
        else if ($2=="OFF") gm_off++
        else gm_other++

        if ($5 ~ /^[0-9.]+$/) { gpu=$5+0; sum_gpu+=gpu; ngpu++; if (gpu>max_gpu) max_gpu=gpu }
        if ($8 ~ /^[0-9.]+$/) { gpup=$8+0; sum_power+=gpup; npower++; if (gpup>max_power) max_power=gpup }
        if ($7 ~ /^[0-9.]+$/) { gput=$7+0; sum_temp+=gput; ntemp++; if (gput>max_temp) max_temp=gput }
        if ($13 ~ /^[0-9.]+$/) { cpuavg=$13+0; sum_cpuavg+=cpuavg; ncpu++; if (cpuavg>max_cpuavg) max_cpuavg=cpuavg }
        if ($19 ~ /^[0-9.]+$/) { psi_cpu=$19+0; if (psi_cpu>max_psi_cpu) max_psi_cpu=psi_cpu }
        if ($20 ~ /^[0-9.]+$/) { psi_mem=$20+0; if (psi_mem>max_psi_mem) max_psi_mem=psi_mem }
        if ($21 ~ /^[0-9.]+$/) { psi_io=$21+0; if (psi_io>max_psi_io) max_psi_io=psi_io }

        if ($4 ~ /^P[0-9]+$/) pstate[$4]++
      }
      END {
        print "amostras=" n
        print "gamemode_on=" gm_on+0
        print "gamemode_off=" gm_off+0
        print "gamemode_incertos=" gm_other+0
        if (ngpu>0) print "gpu_util_media_pct=" sum_gpu/ngpu
        print "gpu_util_max_pct=" max_gpu+0
        if (npower>0) print "gpu_power_media_w=" sum_power/npower
        print "gpu_power_max_w=" max_power+0
        if (ntemp>0) print "gpu_temp_media_c=" sum_temp/ntemp
        print "gpu_temp_max_c=" max_temp+0
        if (ncpu>0) print "cpu_clock_medio_mhz=" sum_cpuavg/ncpu
        print "cpu_clock_medio_max_mhz=" max_cpuavg+0
        print "psi_cpu_some10_max=" max_psi_cpu+0
        print "psi_mem_some10_max=" max_psi_mem+0
        print "psi_io_some10_max=" max_psi_io+0
        printf "gpu_pstates="
        first=1
        for (p in pstate) {
          if (!first) printf ","
          printf "%s:%s", p, pstate[p]
          first=0
        }
        print ""
      }
    ' "$SAMPLES"
  else
    echo "Sem amostras."
  fi
  echo '```'
  echo
  echo "## Interpretação rápida"
  if [ -s "$SAMPLES" ]; then
    GM_ON="$(awk -F'\t' 'NR>1 && $2=="ON" {c++} END{print c+0}' "$SAMPLES")"
    GM_OFF="$(awk -F'\t' 'NR>1 && $2=="OFF" {c++} END{print c+0}' "$SAMPLES")"
    GPU_MAX="$(awk -F'\t' 'NR>1 && $5 ~ /^[0-9.]+$/ {if($5>m)m=$5} END{print m+0}' "$SAMPLES")"
    POWER_MAX="$(awk -F'\t' 'NR>1 && $8 ~ /^[0-9.]+$/ {if($8>m)m=$8} END{print m+0}' "$SAMPLES")"
    CPU_PSI_MAX="$(awk -F'\t' 'NR>1 && $19 ~ /^[0-9.]+$/ {if($19>m)m=$19} END{print m+0}' "$SAMPLES")"
    MEM_PSI_MAX="$(awk -F'\t' 'NR>1 && $20 ~ /^[0-9.]+$/ {if($20>m)m=$20} END{print m+0}' "$SAMPLES")"
    IO_PSI_MAX="$(awk -F'\t' 'NR>1 && $21 ~ /^[0-9.]+$/ {if($21>m)m=$21} END{print m+0}' "$SAMPLES")"

    if [ "$GM_ON" -gt 0 ] && [ "$GM_OFF" -eq 0 ]; then
      echo "- GameMode apareceu ON nas amostras úteis."
    elif [ "$GM_ON" -gt 0 ] && [ "$GM_OFF" -gt 0 ]; then
      echo "- GameMode oscilou entre ON e OFF durante a coleta."
    else
      echo "- GameMode não apareceu claramente como ON. Confirmar linha Steam usada."
    fi

    echo "- Pico de uso da GPU: ${GPU_MAX}%."
    echo "- Pico de consumo da GPU: ${POWER_MAX} W."
    echo "- Pico PSI CPU avg10: ${CPU_PSI_MAX}."
    echo "- Pico PSI memória avg10: ${MEM_PSI_MAX}."
    echo "- Pico PSI I/O avg10: ${IO_PSI_MAX}."

    if awk "BEGIN {exit !($CPU_PSI_MAX > 10)}"; then
      echo "- Atenção: PSI CPU alto pode indicar contenção/stall."
    fi
    if awk "BEGIN {exit !($MEM_PSI_MAX > 5)}"; then
      echo "- Atenção: PSI memória alto pode indicar pressão de RAM/zram."
    fi
    if awk "BEGIN {exit !($IO_PSI_MAX > 5)}"; then
      echo "- Atenção: PSI I/O alto pode indicar espera de disco."
    fi
  else
    echo "- Sem amostras para interpretar."
  fi
  echo
  echo "## Arquivos"
  echo
  echo "- Amostras: \`$SAMPLES\`"
  echo "- Eventos: \`$EVENTS\`"
  echo "- Processos: \`$PROCS\`"
} > "$SUMMARY"

cat "$SUMMARY"
echo
echo "Resumo salvo em:"
echo "$SUMMARY"
