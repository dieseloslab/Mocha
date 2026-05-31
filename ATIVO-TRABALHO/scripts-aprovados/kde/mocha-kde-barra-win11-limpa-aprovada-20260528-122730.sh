#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA — KDE/ENDEAVOUR — BARRA ESTILO WINDOWS 11 LIMPA =="
echo "Modo: relê arquivo real, valida painel, centraliza Iniciar + ícones fixados, preserva widgets."
echo "Não usa sudo. Não instala nada. Não mexe no Bluetooth. Não remove programas."
echo

export PATH="$HOME/.local/bin:/usr/lib/qt6/bin:/usr/lib/qt5/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat GIT_PAGER=cat MANPAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
CONF="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
STATE="$HOME/.local/state/mocha-kde-barra-win11"
REPORT="$STATE/barra-win11-limpa-$TS.txt"
BACKUP="$STATE/plasma-org.kde.plasma.desktop-appletsrc.before-barra-win11-$TS.bak"
PYHELPER="/tmp/mocha-kde-barra-win11-limpa-$TS.py"

mkdir -p "$STATE"
exec > >(tee -a "$REPORT") 2>&1

start_plasma() {
  echo "== Iniciando plasmashell =="
  if pgrep -x plasmashell >/dev/null 2>&1; then
    echo "OK — plasmashell já está rodando."
    return 0
  fi

  if command -v kstart6 >/dev/null 2>&1; then
    kstart6 plasmashell >/dev/null 2>&1 || true
  elif command -v kstart >/dev/null 2>&1; then
    kstart plasmashell >/dev/null 2>&1 || true
  else
    nohup plasmashell >/tmp/mocha-plasmashell-barra-win11-$TS.log 2>&1 &
  fi

  for _ in $(seq 1 40); do
    if pgrep -x plasmashell >/dev/null 2>&1; then
      echo "OK — plasmashell voltou."
      return 0
    fi
    sleep 0.25
  done

  echo "ERRO: plasmashell não voltou."
  return 1
}

restore_on_error() {
  rc="$?"
  echo
  echo "ERRO: falha no ajuste da barra. Código: $rc"
  if [ -f "$BACKUP" ]; then
    echo "Restaurando backup:"
    echo "$BACKUP"
    cp -a "$BACKUP" "$CONF" || true
  fi
  start_plasma || true
  echo
  echo "Relatório:"
  echo "$REPORT"
  exit "$rc"
}
trap restore_on_error ERR

if [ ! -f "$CONF" ]; then
  echo "ERRO: arquivo não encontrado:"
  echo "$CONF"
  exit 1
fi

cat > "$PYHELPER" <<'PY'
from pathlib import Path
import re
import sys

mode = sys.argv[1]
conf = Path(sys.argv[2])

section_re = re.compile(r'^\[(.+)\]\s*$')

class KConf:
    def __init__(self, path):
        self.path = Path(path)
        self.lines = self.path.read_text(encoding="utf-8", errors="replace").splitlines()
        self.parse()

    def parse(self):
        self.sections = {}
        starts = []
        for i, line in enumerate(self.lines):
            m = section_re.match(line)
            if m:
                sec = m.group(1)
                self.sections[sec] = {"start": i, "end": len(self.lines)}
                starts.append((sec, i))
        for n, (sec, start) in enumerate(starts):
            self.sections[sec]["end"] = starts[n + 1][1] if n + 1 < len(starts) else len(self.lines)

    def get(self, section, key, default=""):
        info = self.sections.get(section)
        if not info:
            return default
        prefix = key + "="
        for i in range(info["start"] + 1, info["end"]):
            if self.lines[i].startswith(prefix):
                return self.lines[i].split("=", 1)[1]
        return default

    def set_key(self, section, key, value):
        self.parse()
        info = self.sections.get(section)
        if not info:
            if self.lines and self.lines[-1].strip():
                self.lines.append("")
            self.lines.append(f"[{section}]")
            self.lines.append(f"{key}={value}")
            self.parse()
            return

        prefix = key + "="
        for i in range(info["start"] + 1, info["end"]):
            if self.lines[i].startswith(prefix):
                self.lines[i] = f"{key}={value}"
                self.parse()
                return

        self.lines.insert(info["end"], f"{key}={value}")
        self.parse()

    def write(self):
        self.path.write_text("\n".join(self.lines) + "\n", encoding="utf-8")

def split_order(value):
    out = []
    for p in value.split(";"):
        p = p.strip()
        if p and p.isdigit() and p not in out:
            out.append(p)
    return out

def applet_ids(k, panel_id):
    pat = re.compile(rf"^Containments\]\[{re.escape(panel_id)}\]\[Applets\]\[(\d+)$")
    ids = []
    for sec in k.sections:
        m = pat.match(sec)
        if m:
            ids.append(m.group(1))
    return sorted(set(ids), key=lambda x: int(x))

def max_applet_id(k):
    pat = re.compile(r"^Containments\]\[\d+\]\[Applets\]\[(\d+)$")
    nums = []
    for sec in k.sections:
        m = pat.match(sec)
        if m:
            nums.append(int(m.group(1)))
    return max(nums) if nums else 0

def plugin_of(k, panel_id, applet_id):
    return k.get(f"Containments][{panel_id}][Applets][{applet_id}", "plugin", "")

def first_plugin(k, panel_id, plugins):
    for aid in applet_ids(k, panel_id):
        if plugin_of(k, panel_id, aid) in plugins:
            return aid
    return ""

def all_plugin(k, panel_id, plugin):
    return [aid for aid in applet_ids(k, panel_id) if plugin_of(k, panel_id, aid) == plugin]

def find_panel(k):
    panels = []
    for sec in k.sections:
        m = re.match(r"^Containments\]\[(\d+)$", sec)
        if not m:
            continue
        cid = m.group(1)
        if k.get(sec, "plugin", "") == "org.kde.panel":
            panels.append(cid)

    if not panels:
        raise SystemExit("ERRO: nenhum painel com plugin=org.kde.panel encontrado.")

    bottom = [
        p for p in panels
        if k.get(f"Containments][{p}", "location", "") == "4"
        and k.get(f"Containments][{p}", "formfactor", "") == "2"
    ]

    if len(bottom) == 1:
        return bottom[0]

    if len(panels) == 1:
        return panels[0]

    raise SystemExit(f"ERRO: mais de um painel encontrado e não há alvo único claro: {','.join(panels)}")

def print_audit(k):
    panel = find_panel(k)
    order_section = f"Containments][{panel}][General"
    order = split_order(k.get(order_section, "AppletOrder", ""))
    ids = applet_ids(k, panel)

    print(f"painel_alvo={panel}")
    print(f"location={k.get(f'Containments][{panel}', 'location', '(vazio)')}")
    print(f"formfactor={k.get(f'Containments][{panel}', 'formfactor', '(vazio)')}")
    print(f"ordem_atual={';'.join(order) if order else '(vazio)'}")
    print("applets_detectados:")
    for aid in ids:
        print(f"  {aid}={plugin_of(k, panel, aid) or '(plugin vazio)'}")

def build_layout(k):
    panel = find_panel(k)
    order_section = f"Containments][{panel}][General"

    existing_order = split_order(k.get(order_section, "AppletOrder", ""))
    ids = applet_ids(k, panel)

    if not existing_order:
        existing_order = ids[:]

    for aid in ids:
        if aid not in existing_order:
            existing_order.append(aid)

    kickoff = first_plugin(k, panel, {"org.kde.plasma.kickoff", "org.kde.plasma.kicker"})
    tasks = first_plugin(k, panel, {"org.kde.plasma.icontasks", "org.kde.plasma.taskmanager"})
    pager = first_plugin(k, panel, {"org.kde.plasma.pager"})
    margins = first_plugin(k, panel, {"org.kde.plasma.marginsseparator"})
    tray = first_plugin(k, panel, {"org.kde.plasma.systemtray"})
    clock = first_plugin(k, panel, {"org.kde.plasma.digitalclock"})
    showdesktop = first_plugin(k, panel, {"org.kde.plasma.showdesktop"})

    if not kickoff:
        raise SystemExit("ERRO: kickoff/kicker não encontrado. Não vou aplicar no painel errado.")
    if not tasks:
        raise SystemExit("ERRO: icontasks/taskmanager não encontrado. Não vou aplicar no painel errado.")
    if not tray:
        raise SystemExit("ERRO: systemtray não encontrado. Não vou aplicar layout arriscado.")
    if not clock:
        raise SystemExit("ERRO: digitalclock não encontrado. Não vou aplicar layout arriscado.")

    spacers = all_plugin(k, panel, "org.kde.plasma.panelspacer")
    next_id = max_applet_id(k) + 1

    while len(spacers) < 2:
        sid = str(next_id)
        next_id += 1
        spacers.append(sid)

    left_spacer, right_spacer = spacers[0], spacers[1]

    for sid in (left_spacer, right_spacer):
        k.set_key(f"Containments][{panel}][Applets][{sid}", "immutability", "1")
        k.set_key(f"Containments][{panel}][Applets][{sid}", "plugin", "org.kde.plasma.panelspacer")
        k.set_key(f"Containments][{panel}][Applets][{sid}][Configuration][General", "expanding", "true")
        k.set_key(f"Containments][{panel}][Applets][{sid}][Configuration][General", "length", "0")

    left_group = []
    for aid in existing_order:
        if aid == pager and aid not in left_group:
            left_group.append(aid)

    right_group = []
    for aid in (margins, tray, clock, showdesktop):
        if aid and aid not in right_group:
            right_group.append(aid)

    center_group = [kickoff, tasks]

    reserved = set(left_group + center_group + right_group + [left_spacer, right_spacer])

    extras_left = []
    for aid in existing_order:
        if aid not in reserved and plugin_of(k, panel, aid) != "org.kde.plasma.panelspacer":
            extras_left.append(aid)

    final_order = extras_left + left_group + [left_spacer] + center_group + [right_spacer] + right_group

    print(f"painel={panel}")
    print(f"ordem_antiga={';'.join(existing_order)}")
    print(f"grupo_esquerdo={';'.join(extras_left + left_group) if extras_left + left_group else '(vazio)'}")
    print(f"grupo_central={';'.join(center_group)}")
    print(f"grupo_direito={';'.join(right_group)}")
    print(f"spacer_esquerdo={left_spacer}")
    print(f"spacer_direito={right_spacer}")
    print(f"ordem_nova={';'.join(final_order)}")

    return panel, order_section, final_order

k = KConf(conf)

if mode == "audit":
    print_audit(k)
elif mode == "apply":
    panel, order_section, final_order = build_layout(k)
    k.set_key(order_section, "AppletOrder", ";".join(final_order))
    k.write()
    print("OK — arquivo gravado.")
elif mode == "verify":
    print_audit(k)
    panel, order_section, final_order = build_layout(k)
    current = split_order(k.get(order_section, "AppletOrder", ""))
    if current != final_order:
        raise SystemExit(f"ERRO: verificação falhou. atual={';'.join(current)} esperado={';'.join(final_order)}")
    print("OK — verificação da ordem aplicada passou.")
else:
    raise SystemExit("modo inválido")
PY

echo "== 1) Auditoria antes de mexer =="
python3 "$PYHELPER" audit "$CONF"

echo
echo "== 2) Encerrando plasmashell para evitar sobrescrita do appletsrc =="
if pgrep -x plasmashell >/dev/null 2>&1; then
  if command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 plasmashell >/dev/null 2>&1 || true
  elif command -v kquitapp5 >/dev/null 2>&1; then
    kquitapp5 plasmashell >/dev/null 2>&1 || true
  else
    killall plasmashell >/dev/null 2>&1 || true
  fi

  for _ in $(seq 1 40); do
    if ! pgrep -x plasmashell >/dev/null 2>&1; then
      break
    fi
    sleep 0.25
  done

  if pgrep -x plasmashell >/dev/null 2>&1; then
    echo "plasmashell ainda ativo; encerrando com killall."
    killall plasmashell >/dev/null 2>&1 || true
    sleep 1
  fi
else
  echo "plasmashell já não estava rodando."
fi

echo
echo "== 3) Backup depois do Plasma parar =="
cp -a "$CONF" "$BACKUP"
echo "backup=$BACKUP"

echo
echo "== 4) Mantendo no máximo 2 backups deste ajuste =="
python3 - "$STATE" <<'PY'
from pathlib import Path
import sys

state = Path(sys.argv[1])
backups = sorted(
    state.glob("plasma-org.kde.plasma.desktop-appletsrc.before-barra-win11-*.bak"),
    key=lambda p: p.stat().st_mtime,
    reverse=True,
)

for old in backups[2:]:
    print(f"apagando_backup_excedente={old}")
    old.unlink()

print(f"backups_mantidos={min(len(backups), 2)}")
PY

echo
echo "== 5) Reauditando o arquivo salvo antes de aplicar =="
python3 "$PYHELPER" audit "$CONF"

echo
echo "== 6) Aplicando layout =="
python3 "$PYHELPER" apply "$CONF"

echo
echo "== 7) Verificando gravação =="
python3 "$PYHELPER" verify "$CONF"

echo
start_plasma

echo
echo "OK — barra ajustada."
echo "Relatório salvo em:"
echo "$REPORT"
echo
echo "Resultado esperado:"
echo "esquerda: pager/outros"
echo "centro: Iniciar + aplicativos fixados"
echo "direita: bandeja + relógio + mostrar área de trabalho"
