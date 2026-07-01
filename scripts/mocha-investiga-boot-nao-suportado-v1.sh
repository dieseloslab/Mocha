#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

OUT="${1:-/tmp/mocha-boot-nao-suportado-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT"

PATTERN='não suport|nao suport|unsupported|not supported|not available|not present|not implemented|platform|plataforma|amd_pstate|amd-pstate|cppc|_CPC|acpi_cpufreq|cpufreq|pstate|ACPI|WMI|asus|firmware|microcode|NVRM|nvidia|nouveau|secure|SGX|TPM|tpm|ucsi|usb|IOMMU|MCE|APEI|ERST'

{
  echo "============================================================"
  echo " Mocha — investigação de mensagem 'não suportado no boot'"
  echo "============================================================"
  echo "Data: $(date -Is)"
  echo
  echo "Kernel:"
  uname -a || true
  echo
  echo "Cmdline:"
  cat /proc/cmdline || true
  echo
  echo "CPU:"
  lscpu 2>/dev/null | sed -n '1,35p' || true
  echo
  echo "GPU:"
  command -v nvidia-smi >/dev/null 2>&1 && timeout 8s nvidia-smi -L || true
  echo
  echo "Boots disponíveis:"
  journalctl --list-boots || true
} > "$OUT/00-contexto.txt" 2>&1

journalctl -b 0 -o short-precise --no-pager > "$OUT/01-journal-boot-atual-completo.txt" 2>&1 || true
journalctl -b 0 -p warning..alert -o short-precise --no-pager > "$OUT/02-journal-boot-atual-warnings.txt" 2>&1 || true
journalctl -b 0 -o short-precise --no-pager | grep -Ei "$PATTERN" > "$OUT/03-journal-boot-atual-matches.txt" 2>&1 || true

if journalctl --list-boots | awk '{print $1}' | grep -qx -- "-1"; then
  journalctl -b -1 -o short-precise --no-pager | grep -Ei "$PATTERN" > "$OUT/04-journal-boot-anterior-matches.txt" 2>&1 || true
fi

timeout 8s dmesg -T > "$OUT/05-dmesg-completo.txt" 2>&1 || true
timeout 8s dmesg -T | grep -Ei "$PATTERN" > "$OUT/06-dmesg-matches.txt" 2>&1 || true

systemctl --failed --no-pager > "$OUT/07-systemd-failed.txt" 2>&1 || true
systemd-analyze blame > "$OUT/08-systemd-blame.txt" 2>&1 || true
systemd-analyze critical-chain > "$OUT/09-systemd-critical-chain.txt" 2>&1 || true

{
  echo "============================================================"
  echo " DIAGNÓSTICO CURTO"
  echo "============================================================"
  echo
  echo "Arquivos gerados em:"
  echo "$OUT"
  echo
  echo "Mensagens exatas encontradas no boot atual:"
  echo "------------------------------------------------------------"
  if [ -s "$OUT/03-journal-boot-atual-matches.txt" ]; then
    grep -Ei 'não suport|nao suport|unsupported|not supported|not available|not present|not implemented' "$OUT/03-journal-boot-atual-matches.txt" || true
  else
    echo "Nenhuma ocorrência direta encontrada no journal do boot atual."
  fi
  echo
  echo "Mensagens exatas encontradas no dmesg:"
  echo "------------------------------------------------------------"
  if [ -s "$OUT/06-dmesg-matches.txt" ]; then
    grep -Ei 'não suport|nao suport|unsupported|not supported|not available|not present|not implemented' "$OUT/06-dmesg-matches.txt" || true
  else
    echo "Nenhuma ocorrência direta encontrada no dmesg."
  fi
  echo
  echo "Possíveis áreas relacionadas:"
  echo "------------------------------------------------------------"
  grep -Eio 'amd_pstate|amd-pstate|cppc|_CPC|acpi_cpufreq|nvidia|NVRM|ACPI|WMI|asus|firmware|microcode|SGX|TPM|ucsi|IOMMU' \
    "$OUT"/03-journal-boot-atual-matches.txt "$OUT"/06-dmesg-matches.txt 2>/dev/null \
    | sort -u || true
  echo
  echo "Falhas systemd:"
  echo "------------------------------------------------------------"
  cat "$OUT/07-systemd-failed.txt" || true
} | tee "$OUT/10-resumo.txt"

echo
echo "============================================================"
echo " Interpretação automática inicial"
echo "============================================================"

if grep -RiqE 'amd_pstate.*(not supported|not present|unsupported|_CPC|platform)' "$OUT"; then
  echo "[ACHADO] A mensagem parece ligada ao amd_pstate/CPPC."
  echo "        Em placa ASUS/AMD isso costuma indicar que o firmware/ACPI não expõe CPPC como o kernel espera."
  echo "        Normalmente não é erro fatal: o sistema cai para acpi-cpufreq ou outro driver."
fi

if grep -RiqE 'SGX.*(disabled|unsupported|not supported)' "$OUT"; then
  echo "[ACHADO] A mensagem parece ligada a Intel SGX."
  echo "        Em máquina AMD isso é irrelevante; se aparecer via firmware genérico, não é causa de lentidão."
fi

if grep -RiqE 'platform profile.*(not supported|unsupported)|asus.*(platform|profile)' "$OUT"; then
  echo "[ACHADO] A mensagem parece ligada a platform_profile/asus_wmi."
  echo "        Normalmente é recurso de notebook/perfil térmico não disponível em desktop."
fi

if grep -RiqE 'nvidia|NVRM' "$OUT"; then
  echo "[INFO] Há mensagens NVIDIA no boot. Verifique 03/06-matches para confirmar se são erro, aviso benigno ou carregamento normal."
fi

echo
echo "[OK] Script salvo em: $/media/mochafast/MochaArch/scripts/mocha-investiga-boot-nao-suportado-v1.sh"
echo "[OK] Auditoria salva em: $OUT"
