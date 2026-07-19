#!/usr/bin/env bash
set -u
LOG="/tmp/mocha-gamemode-authority-${USER:-unknown}.log"
{
  echo "================================================================"
  date '+%F %T end'
  echo "user=${USER:-unknown}"
  echo "Revertendo OC NVIDIA via NVML root helper"
  sudo -n /usr/local/lib/mocha/mocha-nvidia-oc-root-helper end
  if command -v tuned-adm >/dev/null 2>&1; then
    sudo -n tuned-adm profile mocha-latency-performance || true
  fi
} >> "$LOG" 2>&1
