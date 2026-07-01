#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

PROFILE="mocha-latency-performance"

echo
echo "============================================================"
echo " Mocha — verificar TuneD mocha-latency-performance"
echo "============================================================"
echo

echo "Serviço TuneD antes:"
timeout 10 systemctl is-active tuned.service || true
timeout 10 systemctl is-enabled tuned.service || true

echo
echo "Reiniciando TuneD:"
sudo systemctl restart tuned.service
timeout 10 systemctl is-active tuned.service || {
  echo "[FALHA] tuned.service não está ativo após restart" >&2
  exit 1
}

echo
echo "Reaplicando perfil:"
sudo tuned-adm profile "$PROFILE"

echo
echo "Perfil ativo:"
timeout 10 tuned-adm active || true

echo
echo "Verificação TuneD:"
if timeout 20 tuned-adm verify; then
  echo "[OK] tuned-adm verify passou"
else
  echo "[AVISO] tuned-adm verify ainda reclamou"
  echo
  echo "Últimas linhas do log TuneD:"
  sudo timeout 10 tail -n 80 /var/log/tuned/tuned.log 2>/dev/null || true
fi

echo
echo "Sysctl Mocha:"
for key in \
  vm.swappiness \
  vm.vfs_cache_pressure \
  vm.page-cluster \
  vm.dirty_background_bytes \
  vm.dirty_bytes \
  vm.max_map_count \
  kernel.sched_autogroup_enabled
do
  printf '%s = ' "$key"
  sysctl -n "$key" 2>/dev/null || true
done

echo
echo "Serviço TuneD depois:"
timeout 10 systemctl is-active tuned.service || true
timeout 10 systemctl is-enabled tuned.service || true

echo
echo "[OK] Verificação concluída"
