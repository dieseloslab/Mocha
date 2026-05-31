#!/usr/bin/env bash
set -Eeuo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
CONF="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
LOG="$HOME/mocha-kde-barra-win11-aprovada-$TS.log"
BACKUP="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc.mocha-backup-$TS"

export PATH="$HOME/.local/bin:/usr/lib/qt6/bin:/usr/lib/qt5/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat
export SYSTEMD_PAGER=cat
export LESS=FRX

exec > >(tee "$LOG") 2>&1

echo "== MOCHA KDE — BARRA ESTILO WINDOWS 11 APROVADA =="
echo "Timestamp: $TS"
echo "Arquivo: $CONF"
echo "Modo: audita, organiza a barra e reinicia somente o plasmashell."
echo "Não instala pacote. Não mexe em kernel. Não mexe em NVIDIA. Não mexe em boot."
echo

if [ "${XDG_CURRENT_DESKTOP:-}" != "KDE" ]; then
  echo "ERRO: sessão atual não parece KDE."
  exit 1
fi

if [ ! -f "$CONF" ]; then
  echo "ERRO: arquivo do painel não encontrado: $CONF"
  exit 1
fi

cp -a "$CONF" "$BACKUP"
echo "Backup criado: $BACKUP"

python - "$CONF" <<'PY'
import os
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])

def read_lines():
    return path.read_text(encoding="utf-8", errors="replace").splitlines(True)

def parse(lines):
    sections = {}
    current = None
    for i, line in enumerate(lines):
        m = re.match(r'^\s*(\[.*\])\s*$', line)
        if m:
            current = m.group(1)
            sections.setdefault(current, {"start": i, "items": {}})
            continue
        if current and "=" in line and not line.lstrip().startswith("#"):
            k, v = line.split("=", 1)
            sections[current]["items"][k.strip()] = {"value": v.strip(), "line": i}
    return sections

def find_section_end(lines, start):
    for j in range(start + 1, len(lines)):
        if re.match(r'^\s*\[.*\]\s*$', lines[j]):
            return j
    return len(lines)

def set_key(lines, section, key, value):
    sections = parse(lines)
    if section in sections:
        item = sections[section]["items"].get(key)
        if item:
            lines[item["line"]] = f"{key}={value}\n"
        else:
            end = find_section_end(lines, sections[section]["start"])
            lines.insert(end, f"{key}={value}\n")
    else:
        if lines and not lines[-1].endswith("\n"):
            lines[-1] += "\n"
        if lines and lines[-1].strip():
            lines.append("\n")
        lines.append(f"{section}\n")
        lines.append(f"{key}={value}\n")
    return lines

def delete_panel_applet_sections(lines, cid, applet_id):
    prefix = re.escape(f"[Containments][{cid}][Applets][{applet_id}]")
    section_re = re.compile(r'^\s*' + prefix + r'(?:\[.*\])?\s*$')
    all_section_re = re.compile(r'^\s*\[.*\]\s*$')

    ranges = []
    i = 0
    while i < len(lines):
        if section_re.match(lines[i]):
            start = i
            i += 1
            while i < len(lines) and not all_section_re.match(lines[i]):
                i += 1
            ranges.append((start, i))
        else:
            i += 1

    for start, end in reversed(ranges):
        del lines[start:end]
    return lines

lines = read_lines()
sections = parse(lines)

panel_ids = []
for sec, data in sections.items():
    m = re.fullmatch(r'\[Containments\]\[(\d+)\]', sec)
    if m and data["items"].get("plugin", {}).get("value") == "org.kde.panel":
        panel_ids.append(m.group(1))

if not panel_ids:
    raise SystemExit("ERRO: nenhum painel org.kde.panel encontrado.")

cid = panel_ids[0]
general = f"[Containments][{cid}][General]"

applets = {}
for sec, data in sections.items():
    m = re.fullmatch(rf'\[Containments\]\[{re.escape(cid)}\]\[Applets\]\[(\d+)\]', sec)
    if m:
        aid = m.group(1)
        plugin = data["items"].get("plugin", {}).get("value", "")
        applets[aid] = plugin

raw_order = sections.get(general, {}).get("items", {}).get("AppletOrder", {}).get("value", "")
order = [x for x in re.split(r'[;,]', raw_order) if x]
if not order:
    order = sorted(applets, key=lambda x: int(x) if x.isdigit() else 999999)

existing_spacers = [aid for aid in order if applets.get(aid) == "org.kde.plasma.panelspacer"]
existing_spacers += [aid for aid, plugin in applets.items() if plugin == "org.kde.plasma.panelspacer" and aid not in existing_spacers]

selected_spacers = existing_spacers[:2]
extra_spacers = existing_spacers[2:]

for aid in extra_spacers:
    lines = delete_panel_applet_sections(lines, cid, aid)

sections = parse(lines)
applets = {}
all_ids = []
for sec, data in sections.items():
    m_any = re.search(r'\[Applets\]\[(\d+)\]', sec)
    if m_any:
        all_ids.append(int(m_any.group(1)))
    m = re.fullmatch(rf'\[Containments\]\[{re.escape(cid)}\]\[Applets\]\[(\d+)\]', sec)
    if m:
        aid = m.group(1)
        plugin = data["items"].get("plugin", {}).get("value", "")
        applets[aid] = plugin

next_id = max(all_ids or [0]) + 1

while len(selected_spacers) < 2:
    aid = str(next_id)
    next_id += 1
    selected_spacers.append(aid)
    applet_sec = f"[Containments][{cid}][Applets][{aid}]"
    cfg_sec = f"[Containments][{cid}][Applets][{aid}][Configuration][General]"
    lines = set_key(lines, applet_sec, "immutability", "1")
    lines = set_key(lines, applet_sec, "plugin", "org.kde.plasma.panelspacer")
    lines = set_key(lines, cfg_sec, "expanding", "true")

sections = parse(lines)

for aid in selected_spacers:
    cfg_sec = f"[Containments][{cid}][Applets][{aid}][Configuration][General]"
    lines = set_key(lines, cfg_sec, "expanding", "true")

sections = parse(lines)
applets = {}
for sec, data in sections.items():
    m = re.fullmatch(rf'\[Containments\]\[{re.escape(cid)}\]\[Applets\]\[(\d+)\]', sec)
    if m:
        aid = m.group(1)
        plugin = data["items"].get("plugin", {}).get("value", "")
        applets[aid] = plugin

raw_order = sections.get(general, {}).get("items", {}).get("AppletOrder", {}).get("value", "")
order = [x for x in re.split(r'[;,]', raw_order) if x]
if not order:
    order = sorted(applets, key=lambda x: int(x) if x.isdigit() else 999999)

center_plugins = {
    "org.kde.plasma.kickoff",
    "org.kde.plasma.kicker",
    "org.kde.plasma.kickerdash",
    "org.kde.plasma.icontasks",
    "org.kde.plasma.taskmanager",
}

right_plugins = {
    "org.kde.plasma.systemtray",
    "org.kde.plasma.digitalclock",
    "org.kde.plasma.showdesktop",
    "org.kde.plasma.showActivityManager",
}

spacer_set = set(selected_spacers)

known_order = [aid for aid in order if aid in applets]
missing_from_order = [aid for aid in applets if aid not in known_order and aid not in spacer_set]

center = [aid for aid in known_order if applets.get(aid) in center_plugins]
right = [aid for aid in known_order if applets.get(aid) in right_plugins]
left = [
    aid for aid in known_order
    if aid not in spacer_set
    and aid not in center
    and aid not in right
    and applets.get(aid) != "org.kde.plasma.panelspacer"
]

for aid in missing_from_order:
    if applets.get(aid) in center_plugins:
        center.append(aid)
    elif applets.get(aid) in right_plugins:
        right.append(aid)
    elif applets.get(aid) != "org.kde.plasma.panelspacer":
        left.append(aid)

if not center:
    raise SystemExit("ERRO: não encontrei Kickoff/icontasks/taskmanager para centralizar. Backup preservado.")

desired = left + [selected_spacers[0]] + center + [selected_spacers[1]] + right
desired = [aid for i, aid in enumerate(desired) if aid and aid not in desired[:i]]

lines = set_key(lines, general, "AppletOrder", ";".join(desired))
path.write_text("".join(lines), encoding="utf-8")

print(f"Painel ajustado: {cid}")
print("Ordem nova:")
for aid in desired:
    print(f"  {aid}: {applets.get(aid, 'org.kde.plasma.panelspacer')}")
PY

mapfile -t OLD_BACKUPS < <(
  find "$HOME/.config" -maxdepth 1 -type f \
    -name 'plasma-org.kde.plasma.desktop-appletsrc.mocha-backup-*' \
    -printf '%T@ %p\n' 2>/dev/null | sort -rn | awk 'NR>2 {print $2}'
)

if [ "${#OLD_BACKUPS[@]}" -gt 0 ]; then
  for old in "${OLD_BACKUPS[@]}"; do
    rm -f "$old"
  done
fi

if command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 plasmashell || true
else
  killall plasmashell 2>/dev/null || true
fi

sleep 2
nohup plasmashell --replace > "$HOME/plasmashell-mocha-barra-$TS.log" 2>&1 &

echo "Concluído."
echo "Backup: $BACKUP"
echo "Log: $LOG"
