#!/usr/bin/env bash
set -Eeuo pipefail
export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/run/current-system/sw/bin:$PATH"

OUT="/media/mochafast/MochaArch/ativo/reports/mocha-input-steam-pos-teste-$(date +%Y%m%d-%H%M%S).md"

{
  echo "# MOCHA — auditoria input Steam pós-teste"
  echo
  echo "- Data: $(date -Is)"
  echo "- Sessão: ${XDG_SESSION_TYPE:-indefinida}"
  echo "- Desktop: ${XDG_CURRENT_DESKTOP:-indefinido}"
  echo "- Kernel: $(uname -r)"
  echo
  echo "## Processos Steam/Proton/Wine"
  echo
  echo ''
  echo
  echo "## Janelas KWin"
  echo
  echo ''
  echo
  echo "## Últimos logs relevantes da sessão"
  echo
  echo ''
} > "$OUT"

echo "Auditoria salva em: $OUT"
