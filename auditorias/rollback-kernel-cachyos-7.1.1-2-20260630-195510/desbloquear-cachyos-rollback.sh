#!/usr/bin/env bash
set -Eeuo pipefail
sudo -v
sudo python - <<'PY'
from pathlib import Path

path = Path("/etc/pacman.conf")
text = path.read_text()
remove = {"linux-cachyos", "linux-cachyos-headers", "linux-cachyos-nvidia-open"}

out = []
for line in text.splitlines():
    stripped = line.strip()
    if stripped.startswith("IgnorePkg") and "=" in line:
        prefix, _, rest = line.partition("=")
        kept = [p for p in rest.split() if p not in remove]
        if kept:
            out.append(prefix.rstrip() + " = " + " ".join(kept))
        else:
            out.append("# IgnorePkg =")
    else:
        out.append(line)

path.write_text("\n".join(out) + "\n")
PY
grep -n '^IgnorePkg\|^# IgnorePkg' /etc/pacman.conf || true
