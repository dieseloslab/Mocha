import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1]).resolve(strict=True)
if not all((root / d).is_dir() for d in ('etc', 'usr', 'var')):
    raise SystemExit('Raiz-alvo invalida')
pattern = r'(?<!\S)(?:resume|resume_offset|resumedelay)=[^\s"\']+|(?<!\S)resumewait(?=\s|["\']|$)'
units = ('hibernate.target', 'hybrid-sleep.target', 'suspend-then-hibernate.target',
         'systemd-hibernate.service', 'systemd-hybrid-sleep.service',
         'systemd-suspend-then-hibernate.service')
for unit in units:
    p = root / 'etc/systemd/system' / unit
    if not p.is_symlink() or p.readlink() != pathlib.Path('/dev/null'):
        raise SystemExit('Mascara ausente ou incorreta: ' + str(p))
changes = []
for relative in ('etc/default/grub', 'etc/mkinitcpio.conf',
                 'etc/mkinitcpio-mocha-729.conf',
                 'etc/grub.d/06_mocha_gcc_principal', 'etc/grub.d/40_custom',
                 'boot/grub/grub.cfg'):
    p = root / relative
    if not p.exists():
        if relative in ('etc/default/grub', 'etc/mkinitcpio.conf'):
            raise SystemExit('Configuracao obrigatoria ausente: ' + str(p))
        continue
    if p.is_symlink():
        raise SystemExit('Configuracao simbolica exige auditoria: ' + str(p))
    old = p.read_text()
    new = old
    if relative == 'etc/default/grub':
        found = [False]
        def command_line(m):
            found[0] = True
            value = re.sub(pattern, '', m[3]).strip()
            if 'nohibernate' not in value.split():
                value = (value + ' nohibernate').strip()
            return m[1] + m[2] + value + m[2]
        new = re.sub(r'(?m)^(\s*GRUB_CMDLINE_LINUX(?:_DEFAULT)?=)(["\'])(.*?)\2', command_line, old)
        if not found[0]:
            raise SystemExit('Parametros do GRUB nao reconhecidos')
    elif relative.startswith('etc/mkinitcpio'):
        new, count = re.subn(r'(?m)^(\s*HOOKS=\()([^)]*)(\))',
            lambda m: m[1] + re.sub(r'(?<!\S)resume(?=\s|$)', '', m[2]) + m[3], old)
        if count != 1:
            raise SystemExit('HOOKS nao reconhecido: ' + str(p))
    else:
        lines = []
        for line in old.splitlines(keepends=True):
            if re.match(r'^\s*linux(?:efi)?\s', line):
                line = re.sub(pattern, '', line)
                if 'nohibernate' not in line.split():
                    line = line.rstrip('\n') + ' nohibernate\n'
            lines.append(line)
        new = ''.join(lines)
    changes.append((p, old, new))
for p, old, new in changes:
    if new != old:
        p.write_text(new)
    print('SEM_HIBERNACAO:', p)
