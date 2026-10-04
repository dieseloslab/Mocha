#!/usr/bin/env bash
set -Eeuo pipefail
ALVO="${1:-/}"
ALVO="${ALVO%/}"
for REL in \
    /usr/local/lib/mocha/mocha-nvidia-oc-root-helper \
    /usr/local/lib/mocha/mocha-nvidia-oc-nvml \
    /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system \
    /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system \
    /usr/local/lib/mocha/gamemode-start-agressivo-oc.sh \
    /usr/local/lib/mocha/gamemode-end-agressivo-oc.sh; do
    [[ -x "$ALVO$REL" ]] || { printf 'ERRO: componente OC ausente: %s\n' "$ALVO$REL"; exit 1; }
    [[ "$(stat -c '%u:%g' "$ALVO$REL")" == '0:0' ]] || { echo "ERRO: proprietário incorreto: $REL"; exit 1; }
    if [[ "$REL" != */mocha-nvidia-oc-nvml ]]; then bash -n "$ALVO$REL"; fi
done
for REL in /etc/mocha/gamemode/legacy-start-system.cmd /etc/mocha/gamemode/legacy-end-system.cmd /etc/gamemode.ini; do
    [[ -s "$ALVO$REL" ]] || { printf 'ERRO: configuração OC ausente: %s\n' "$ALVO$REL"; exit 1; }
done
[[ "$(stat -c '%u:%g:%a' "$ALVO/etc/sudoers.d/mocha-nvidia-oc-root-helper")" == '0:0:440' ]] || { echo 'ERRO: sudoers OC com permissões incorretas'; exit 1; }
visudo -cf "$ALVO/etc/sudoers.d/mocha-nvidia-oc-root-helper"
python3 - "$ALVO" <<'PY'
import configparser
import sys
from pathlib import Path
root = Path(sys.argv[1] or '/')
config = configparser.ConfigParser(strict=False, interpolation=None)
config.read(root / 'etc/gamemode.ini')
for key, direction in [('start', 'start'), ('end', 'end')]:
    expected = f'/usr/local/lib/mocha/performance/mocha-gamemode-{direction}-authority-system'
    if config.get('custom', key, fallback='').strip() != expected:
        raise SystemExit(f'ERRO: hook GameMode {key} diverge da cadeia canônica')
    bridge = root / f'etc/mocha/gamemode/legacy-{direction}-system.cmd'
    legacy = f'/usr/local/lib/mocha/gamemode-{direction}-agressivo-oc.sh'
    if bridge.read_text().strip() != legacy:
        raise SystemExit(f'ERRO: ponte {bridge} diverge da cadeia canônica')
    if '/usr/local/lib/mocha/mocha-nvidia-oc-root-helper' not in (root / legacy.lstrip('/')).read_text():
        raise SystemExit(f'ERRO: script {legacy} não alcança o helper OC')
print('CADEIA_OC_VALIDADA=SIM; preferências e offsets preservados')
PY
