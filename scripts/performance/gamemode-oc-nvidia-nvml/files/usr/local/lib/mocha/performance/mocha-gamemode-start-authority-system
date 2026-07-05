#!/usr/bin/env bash
set -u
LOG="/tmp/mocha-gamemode-authority-${USER:-unknown}.log"
{
  echo "================================================================"
  date '+%F %T start'
  echo "user=${USER:-unknown}"
  echo "Aplicando OC NVIDIA via NVML root helper"
  sudo -n /usr/local/lib/mocha/mocha-nvidia-oc-root-helper start
} >> "$LOG" 2>&1
