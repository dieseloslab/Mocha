#!/usr/bin/env python3
"""Instala a cadeia OC, preservando a preferência manual e os demais ajustes."""
import os
import re
import sys
import tempfile
from pathlib import Path

source = Path(sys.argv[1]).resolve()
root = Path(sys.argv[2]).resolve()
if os.geteuid() != 0:
    raise SystemExit('ERRO: instalação da cadeia exige root')
paths = [
    'etc/mocha/gamemode/legacy-start-system.cmd',
    'etc/mocha/gamemode/legacy-end-system.cmd',
    'usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system',
    'usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system',
    'usr/local/lib/mocha/gamemode-start-agressivo-oc.sh',
    'usr/local/lib/mocha/gamemode-end-agressivo-oc.sh',
]

def atomic_write(target, data, mode):
    target.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=f'.{target.name}.', dir=target.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, mode)
        os.chown(temporary, 0, 0)
        os.replace(temporary, target)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)

for relative in paths:
    original = source / relative
    if not original.is_file():
        raise SystemExit(f'ERRO: fonte OC ausente: {original}')
for relative in paths:
    atomic_write(root / relative, (source / relative).read_bytes(),
                 0o755 if relative.startswith('usr/') else 0o644)

target = root / 'etc/gamemode.ini'
text = target.read_text() if target.exists() else (source / 'etc/gamemode.ini').read_text()
output = []
in_custom = False
found = False
for line in text.splitlines():
    section = re.match(r'^\s*\[([^]]+)\]\s*$', line)
    if section:
        in_custom = section.group(1).strip().lower() == 'custom'
        if in_custom:
            if found:
                raise SystemExit('ERRO: múltiplas seções custom; configuração preservada')
            found = True
            output.extend([line,
                'start=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system',
                'end=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system'])
            continue
    if in_custom and re.match(r'^\s*(start|end)\s*=', line, re.I):
        continue
    output.append(line)
if not found:
    output.extend(['', '[custom]',
        'start=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system',
        'end=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system'])
atomic_write(target, ('\n'.join(output) + '\n').encode(), 0o644)
print('CADEIA_OC_INSTALADA=SIM; nenhuma preferência de OC foi habilitada')
