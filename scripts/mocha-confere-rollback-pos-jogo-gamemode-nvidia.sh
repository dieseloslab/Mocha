#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

STAMP="$(date +%Y%m%d-%H%M%S)"

BASE="/media/mochafast/MochaArch/auditorias"
if [ ! -d "$BASE" ] || [ ! -w "$BASE" ]; then
  BASE="$HOME/mocha-auditorias"
fi

OUT="$BASE/rollback-pos-jogo-gamemode-nvidia-$STAMP"
RESUMO="$OUT/resumo.txt"
mkdir -p "$OUT"

export DISPLAY="${DISPLAY:-:0}"
if [ -z "${XAUTHORITY:-}" ] && [ -n "${HOME:-}" ] && [ -f "$HOME/.Xauthority" ]; then
  export XAUTHORITY="$HOME/.Xauthority"
fi

log() {
  printf '%s\n' "$*" | tee -a "$RESUMO"
}

sep() {
  log "============================================================"
}

parse_attr_value() {
  awk -F': ' '
    /Attribute / {
      v=$2
      gsub(/\./,"",v)
      gsub(/^[ \t]+/,"",v)
      gsub(/[ \t]+$/,"",v)
      print v
      exit
    }
  '
}

num_or_empty() {
  awk '{
    gsub(/[^0-9.]/,"",$0)
    print $0
  }'
}

FAILS=0
WARNS=0

echo
sep
log " Mocha — conferir rollback pós-jogo GameMode/NVIDIA"
sep
log ""
log "Data: $(date -Is)"
log "Kernel: $(uname -r)"
log "Saída: $OUT"
log ""

log "GameMode:"
GM_RAW="$(timeout 5 gamemoded -s 2>&1 || true)"
printf '%s\n' "$GM_RAW" | tee -a "$RESUMO"

if printf '%s\n' "$GM_RAW" | grep -qi 'gamemode is inactive'; then
  GM_STATUS="OK"
else
  GM_STATUS="FALHA"
  FAILS=$((FAILS + 1))
fi

log ""
log "NVIDIA:"
GPU_LINE="$(timeout 5 nvidia-smi --query-gpu=name,pstate,clocks.gr,clocks.mem,power.draw,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1 || true)"

if [ -z "$GPU_LINE" ]; then
  log "[FALHA] nvidia-smi não retornou dados."
  GPU_NAME=""
  PSTATE=""
  GPU_CLOCK=""
  MEM_CLOCK=""
  POWER=""
  TEMP=""
  UTIL=""
  VRAM_USED=""
  VRAM_TOTAL=""
  FAILS=$((FAILS + 1))
else
  log "$GPU_LINE"
  IFS=',' read -r GPU_NAME PSTATE GPU_CLOCK MEM_CLOCK POWER TEMP UTIL VRAM_USED VRAM_TOTAL <<< "$GPU_LINE"

  GPU_NAME="$(printf '%s' "$GPU_NAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  PSTATE="$(printf '%s' "$PSTATE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  GPU_CLOCK="$(printf '%s' "$GPU_CLOCK" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  MEM_CLOCK="$(printf '%s' "$MEM_CLOCK" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  POWER="$(printf '%s' "$POWER" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  TEMP="$(printf '%s' "$TEMP" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  UTIL="$(printf '%s' "$UTIL" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  VRAM_USED="$(printf '%s' "$VRAM_USED" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  VRAM_TOTAL="$(printf '%s' "$VRAM_TOTAL" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  if [ "$PSTATE" = "P0" ]; then
    FAILS=$((FAILS + 1))
  fi

  POWER_NUM="$(printf '%s' "$POWER" | num_or_empty)"
  if [ -n "$POWER_NUM" ]; then
    awk -v p="$POWER_NUM" 'BEGIN { exit !(p > 30) }' && WARNS=$((WARNS + 1)) || true
  fi
fi

log ""
log "Offsets NVIDIA:"
GFX_RAW="$(timeout 5 nvidia-settings -q '[gpu:0]/GPUGraphicsClockOffsetAllPerformanceLevels' 2>&1 || true)"
MEM_RAW="$(timeout 5 nvidia-settings -q '[gpu:0]/GPUMemoryTransferRateOffsetAllPerformanceLevels' 2>&1 || true)"

printf '%s\n' "$GFX_RAW" | tee -a "$RESUMO"
printf '%s\n' "$MEM_RAW" | tee -a "$RESUMO"

GFX_OFFSET="$(printf '%s\n' "$GFX_RAW" | parse_attr_value || true)"
MEM_OFFSET="$(printf '%s\n' "$MEM_RAW" | parse_attr_value || true)"

if [ "${GFX_OFFSET:-}" != "0" ]; then
  FAILS=$((FAILS + 1))
fi

if [ "${MEM_OFFSET:-}" != "0" ]; then
  FAILS=$((FAILS + 1))
fi

log ""
sep
log " Resultado objetivo"
sep
log ""

if [ "$GM_STATUS" = "OK" ]; then
  log "[OK] GameMode inativo pós-jogo."
else
  log "[FALHA] GameMode ainda ativo pós-jogo."
fi

if [ -n "${PSTATE:-}" ]; then
  if [ "$PSTATE" = "P0" ]; then
    log "[FALHA] GPU ainda em P0 pós-jogo."
  else
    log "[OK] GPU fora de P0 pós-jogo: $PSTATE."
  fi
fi

if [ "${GFX_OFFSET:-}" = "0" ]; then
  log "[OK] Offset GPU revertido para 0."
else
  log "[FALHA] Offset GPU não voltou para 0. Valor atual: ${GFX_OFFSET:-indisponível}"
fi

if [ "${MEM_OFFSET:-}" = "0" ]; then
  log "[OK] Offset memória revertido para 0."
else
  log "[FALHA] Offset memória não voltou para 0. Valor atual: ${MEM_OFFSET:-indisponível}"
fi

if [ -n "${POWER:-}" ]; then
  log "[INFO] Power pós-jogo: ${POWER}W"
fi

if [ -n "${TEMP:-}" ]; then
  log "[INFO] Temperatura pós-jogo: ${TEMP}C"
fi

if [ -n "${UTIL:-}" ]; then
  log "[INFO] Utilização GPU pós-jogo: ${UTIL}%"
fi

if [ "$WARNS" -gt 0 ]; then
  log "[WARN] Há $WARNS aviso(s), mas sem reprovação objetiva."
fi

log ""
sep
if [ "$FAILS" -eq 0 ]; then
  log "APROVADO: rollback pós-jogo GameMode/NVIDIA correto."
  sep
  log "[OK] Resumo salvo em: $RESUMO"
  exit 0
else
  log "REPROVADO: rollback pós-jogo GameMode/NVIDIA com $FAILS falha(s)."
  sep
  log "[ERRO] Resumo salvo em: $RESUMO"
  exit 1
fi
