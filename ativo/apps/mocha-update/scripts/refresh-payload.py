#!/usr/bin/env python3
"""Regera o payload a partir dos binários compilados e componentes canônicos."""
import hashlib
import os
import shutil
import sys
from pathlib import Path

project = Path(sys.argv[1]).resolve()
build = Path(sys.argv[2]).resolve()
payload = project / 'calamares/payload/airootfs'
pairs = {
    build / 'mocha-update': 'usr/bin/mocha-update',
    build / 'mocha-update-helper': 'usr/lib/mocha-update/mocha-update-helper',
    build / 'mocha-update-catalog-check': 'usr/lib/mocha-update/mocha-update-catalog-check',
    build / 'mocha-snapshot-admin': 'usr/lib/mocha-update/mocha-snapshot-admin',
    build / 'mocha-nvidia-oc-nvml': 'usr/local/lib/mocha/mocha-nvidia-oc-nvml',
    project / 'data/mocha-oc/mocha-nvidia-oc-root-helper': 'usr/local/lib/mocha/mocha-nvidia-oc-root-helper',
    project / 'data/sudoers.d/mocha-nvidia-oc-root-helper': 'etc/sudoers.d/mocha-nvidia-oc-root-helper',
    project / 'INSTALAR-MOCHA-UPDATE.sh': 'usr/local/share/mocha-update/instalador/INSTALAR-MOCHA-UPDATE.sh',
    project / 'scripts/install-oc-chain.py': 'usr/local/share/mocha-update/instalador/install-oc-chain.py',
    project / 'calamares/VALIDAR-MOCHA-OC.sh': 'usr/local/share/mocha-update/instalador/VALIDAR-MOCHA-OC.sh',
}
for source, relative in pairs.items():
    if not source.is_file():
        raise SystemExit(f'ERRO: artefato obrigatório ausente: {source}')
    target = payload / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        target.chmod(0o644)
    shutil.copyfile(source, target)
    target.chmod(0o440 if relative.startswith('etc/sudoers.d/') else 0o755)
for source in sorted((project / 'data/mocha-oc/chain').rglob('*')):
    if source.is_file():
        relative = source.relative_to(project / 'data/mocha-oc/chain')
        target = payload / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        target.chmod(0o755 if str(relative).startswith('usr/') else 0o644)
if (payload / 'etc/mocha/nvidia-game-oc.conf').exists():
    raise SystemExit('ERRO: payload não pode distribuir preferência permanente de OC')
legacy_backup = payload / 'usr/lib/mocha-update/mocha-update-helper.backup-v70-20260726-143956'
if legacy_backup.exists():
    legacy_backup.unlink()
hashes = []
manifest = ['# Runtime consolidado: kernel real e OC NVML com habilitação manual']
for path in sorted(payload.rglob('*')):
    if not path.is_file() or path.is_symlink():
        continue
    relative = path.relative_to(payload)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    hashes.append(f'{digest}  ./{relative}')
    manifest.append(f'DESTINO=/{relative}|MODO={path.stat().st_mode & 0o777:o}|DONO_ALVO=root:root|SHA256={digest}')
for name in ['SHA256SUMS-PAYLOAD-V76.txt', 'SHA256SUMS-PAYLOAD-R2-V2.txt']:
    (project / 'calamares' / name).write_text('\n'.join(hashes) + '\n')
(project / 'calamares/MANIFESTO-RUNTIME.txt').write_text('\n'.join(manifest) + '\n')
print(f'PAYLOAD_REGENERADO={len(hashes)} arquivos')
