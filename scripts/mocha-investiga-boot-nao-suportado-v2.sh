#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

OUT="${1:-/media/mochafast/MochaArch/auditorias/boot-nao-suportado-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT"

PATTERN='não suport|nao suport|unsupported|not supported|not available|not present|not implemented|platform|plataforma|tdx|amd_pstate|amd-pstate|cppc|_CPC|acpi_cpufreq|cpufreq|pstate|ACPI|WMI|asus|firmware|microcode|NVRM|nvidia|nouveau|secure|SGX|TPM|tpm|ucsi|usb|IOMMU|MCE|APEI|ERST'

echo "============================================================"
echo " Mocha — investigação de mensagens não suportadas no boot"
echo "============================================================"
echo "Saída: $OUT"
echo

{
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

sudo timeout 8s dmesg -T > "$OUT/04-dmesg-completo.txt" 2>&1 || true
sudo timeout 8s dmesg -T | grep -Ei "$PATTERN" > "$OUT/05-dmesg-matches.txt" 2>&1 || true

systemctl --failed --no-pager > "$OUT/06-systemd-failed.txt" 2>&1 || true

{
  echo "============================================================"
  echo " DIAGNÓSTICO CURTO"
  echo "============================================================"
  echo
  echo "Arquivos gerados em:"
  echo "$OUT"
  echo
  echo "Mensagens diretas de não suporte:"
  echo "------------------------------------------------------------"
  grep -RhiE 'não suport|nao suport|unsupported|not supported|not available|not present|not implemented' \
    "$OUT/03-journal-boot-atual-matches.txt" "$OUT/05-dmesg-matches.txt" 2>/dev/null \
    | sort -u || echo "Nenhuma ocorrência direta encontrada."
  echo
  echo "Falhas systemd:"
  echo "------------------------------------------------------------"
  cat "$OUT/06-systemd-failed.txt" || true
  echo
  echo "Interpretação:"
  echo "------------------------------------------------------------"
  if grep -Riq 'virt/tdx: TDX not supported by the host platform' "$OUT"; then
    echo "[BENIGNO] TDX não suportado pela plataforma. Normal em AMD/desktop sem Intel TDX. Ignorar."
  fi
  if grep -Riq 'Charge thresholds are not supported by the kernel for this hardware' "$OUT"; then
    echo "[BENIGNO] KDE PowerDevil tentou limite de carga de bateria. Recurso ausente neste hardware. Ignorar."
  fi
  if grep -Riq 'Bluetooth not supported' "$OUT"; then
    echo "[BENIGNO] BlueZ MIDI/PipeWire sem suporte Bluetooth MIDI. Ignorar se não usa MIDI Bluetooth."
  fi
} | tee "$OUT/10-resumo.txt"

echo
echo "[OK] Auditoria salva em: $OUT"
echo "[OK] Resumo: $OUT/10-resumo.txt"
