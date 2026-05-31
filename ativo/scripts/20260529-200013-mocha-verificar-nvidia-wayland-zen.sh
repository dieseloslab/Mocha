#!/usr/bin/env bash
set -Eeuo pipefail

echo "== Mocha — verificar NVIDIA, Wayland e Kernel Zen =="
echo

echo "-- Kernel --"
uname -a
echo
if uname -r | grep -Eiq 'zen'; then
  echo "[OK] Kernel atual parece Zen: $(uname -r)"
else
  echo "[ATENCAO] Kernel atual nao parece Zen: $(uname -r)"
fi

echo
echo "-- Sessao --"
echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-indisponivel}"
echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-indisponivel}"
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
  echo "[OK] Sessao Wayland"
else
  echo "[ATENCAO] Sessao nao parece Wayland"
fi

echo
echo "-- NVIDIA --"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi
  nvidia-smi --query-gpu=name,driver_version,pstate,power.draw,power.limit,clocks.gr,clocks.mem --format=csv,noheader || true
else
  echo "[FALTA] nvidia-smi nao encontrado"
fi

echo
echo "-- Modulos NVIDIA --"
lsmod | grep -E '^nvidia' || echo "[FALTA] Modulos NVIDIA nao aparecem carregados"

echo
echo "-- Boot cmdline --"
cat /proc/cmdline
