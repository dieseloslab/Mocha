#!/usr/bin/env bash
set -u
LOG="/tmp/mocha-gamemode-authority-${USER:-unknown}.log"
{
  echo "================================================================"
  date '+%F %T end'
  echo "user=${USER:-unknown}"
  echo "Revertendo OC NVIDIA via NVML root helper"
  sudo -n /usr/local/lib/mocha/mocha-nvidia-oc-root-helper end
} >> "$LOG" 2>&1
