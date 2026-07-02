#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
OUT="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-frontend-python-tk-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

mkdir -p "$OUT" "$APP/frontend"

echo "============================================================"
echo " Mocha Updater — frontend Python/Tk sem Rust"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup do launcher/binário atual..."
if [ -e /usr/local/bin/mocha-updater ] || [ -L /usr/local/bin/mocha-updater ]; then
  sudo cp -a /usr/local/bin/mocha-updater "$OUT/mocha-updater.before"
fi

cp -a "$APP/Cargo.toml" "$OUT/Cargo.toml.current" 2>/dev/null || true
cp -a "$APP/Cargo.lock" "$OUT/Cargo.lock.current" 2>/dev/null || true
cp -a "$APP/src/main.rs" "$OUT/main.rs.current" 2>/dev/null || true

echo
echo "2) Escrevendo frontend Python com abas..."
cat > "$APP/frontend/mocha-updater.py" <<'PY'
#!/usr/bin/env python3
import os
import shlex
import subprocess
import sys
import textwrap
from pathlib import Path

ACTION = "/usr/local/lib/mocha/mocha-updater/mocha-updater-action"

def detect_lang():
    raw = (os.environ.get("LANG") or os.environ.get("LC_MESSAGES") or "en").lower()
    if raw.startswith("pt"):
        return "pt"
    if raw.startswith("fr"):
        return "fr"
    if raw.startswith("es"):
        return "es"
    return "en"

LANG = detect_lang()

TEXT = {
    "pt": {
        "title": "Mocha Updater",
        "subtitle": "Atualizador conservador de sistema, Flatpak, kernel e driver",
        "system": "Sistema",
        "kernel": "Kernel / Driver",
        "rollback": "Rollback",
        "about": "Sobre",
        "state": "Estado atual",
        "refresh": "Atualizar estado",
        "check_updates": "Verificar updates",
        "system_update": "Rodar update geral conservador",
        "kernel_diag": "Diagnosticar CPU/GPU/kernel",
        "kernel_install": "Instalar/restaurar kernel Mocha estável",
        "rollback_kernel": "Rollback para kernel Mocha estável",
        "show_logs": "Mostrar logs",
        "system_text": "Atualização geral sem troca de kernel/driver. Pacotes de kernel e NVIDIA ficam bloqueados nesta etapa.",
        "kernel_text": "Detecção de CPU/GPU e instalação explícita do kernel Mocha estável com driver NVIDIA casado quando houver NVIDIA.",
        "rollback_text": "Rollback explícito para o trio estável do repo Mocha. Mantém update geral separado de kernel/driver.",
        "about_text": "Mocha Updater separa atualização geral de kernel/driver para evitar conversão acidental do sistema.\n\nIdiomas suportados: português, inglês, francês e espanhol. Outros locales caem para inglês.\n\nFrontend atual: Python/Tk, sem compilar Rust.\nBackend: /usr/local/lib/mocha/mocha-updater/mocha-updater-action",
        "started": "Ação iniciada",
        "no_terminal": "Não foi possível abrir terminal. Instale konsole ou xterm.",
    },
    "en": {
        "title": "Mocha Updater",
        "subtitle": "Conservative updater for system, Flatpak, kernel and driver",
        "system": "System",
        "kernel": "Kernel / Driver",
        "rollback": "Rollback",
        "about": "About",
        "state": "Current state",
        "refresh": "Refresh state",
        "check_updates": "Check updates",
        "system_update": "Run conservative system update",
        "kernel_diag": "Diagnose CPU/GPU/kernel",
        "kernel_install": "Install/restore stable Mocha kernel",
        "rollback_kernel": "Rollback to stable Mocha kernel",
        "show_logs": "Show logs",
        "system_text": "General update without kernel/driver changes. Kernel and NVIDIA packages are held in this step.",
        "kernel_text": "CPU/GPU detection and explicit installation of the stable Mocha kernel with matching NVIDIA driver when NVIDIA exists.",
        "rollback_text": "Explicit rollback to the stable trio from the Mocha repo. Keeps general update separate from kernel/driver.",
        "about_text": "Mocha Updater separates general updates from kernel/driver changes to avoid accidental system conversion.\n\nSupported languages: Portuguese, English, French and Spanish. Other locales fall back to English.\n\nCurrent frontend: Python/Tk, no Rust compilation.\nBackend: /usr/local/lib/mocha/mocha-updater/mocha-updater-action",
        "started": "Action started",
        "no_terminal": "Could not open a terminal. Install konsole or xterm.",
    },
    "fr": {
        "title": "Mocha Updater",
        "subtitle": "Outil prudent de mise à jour système, Flatpak, noyau et pilote",
        "system": "Système",
        "kernel": "Noyau / Pilote",
        "rollback": "Retour arrière",
        "about": "À propos",
        "state": "État actuel",
        "refresh": "Rafraîchir l’état",
        "check_updates": "Vérifier les mises à jour",
        "system_update": "Lancer la mise à jour prudente",
        "kernel_diag": "Diagnostiquer CPU/GPU/noyau",
        "kernel_install": "Installer/restaurer le noyau Mocha stable",
        "rollback_kernel": "Retour au noyau Mocha stable",
        "show_logs": "Afficher les journaux",
        "system_text": "Mise à jour générale sans changement de noyau/pilote. Les paquets noyau et NVIDIA sont bloqués ici.",
        "kernel_text": "Détection CPU/GPU et installation explicite du noyau Mocha stable avec pilote NVIDIA correspondant si NVIDIA existe.",
        "rollback_text": "Retour arrière explicite vers le trio stable du dépôt Mocha. Sépare la mise à jour générale du noyau/pilote.",
        "about_text": "Mocha Updater sépare les mises à jour générales des changements noyau/pilote pour éviter toute conversion accidentelle.\n\nLangues prises en charge : portugais, anglais, français et espagnol. Les autres locales utilisent l’anglais.\n\nFrontend actuel : Python/Tk, sans compilation Rust.\nBackend : /usr/local/lib/mocha/mocha-updater/mocha-updater-action",
        "started": "Action lancée",
        "no_terminal": "Impossible d’ouvrir un terminal. Installez konsole ou xterm.",
    },
    "es": {
        "title": "Mocha Updater",
        "subtitle": "Actualizador conservador de sistema, Flatpak, kernel y controlador",
        "system": "Sistema",
        "kernel": "Kernel / Controlador",
        "rollback": "Reversión",
        "about": "Acerca de",
        "state": "Estado actual",
        "refresh": "Actualizar estado",
        "check_updates": "Verificar actualizaciones",
        "system_update": "Ejecutar actualización conservadora",
        "kernel_diag": "Diagnosticar CPU/GPU/kernel",
        "kernel_install": "Instalar/restaurar kernel Mocha estable",
        "rollback_kernel": "Revertir al kernel Mocha estable",
        "show_logs": "Mostrar logs",
        "system_text": "Actualización general sin cambiar kernel/controlador. Los paquetes de kernel y NVIDIA se bloquean en esta etapa.",
        "kernel_text": "Detección de CPU/GPU e instalación explícita del kernel Mocha estable con controlador NVIDIA emparejado si hay NVIDIA.",
        "rollback_text": "Reversión explícita al trío estable del repo Mocha. Mantiene separada la actualización general del kernel/controlador.",
        "about_text": "Mocha Updater separa las actualizaciones generales de los cambios de kernel/controlador para evitar conversiones accidentales.\n\nIdiomas soportados: portugués, inglés, francés y español. Otros locales usan inglés.\n\nFrontend actual: Python/Tk, sin compilar Rust.\nBackend: /usr/local/lib/mocha/mocha-updater/mocha-updater-action",
        "started": "Acción iniciada",
        "no_terminal": "No se pudo abrir una terminal. Instale konsole o xterm.",
    },
}
T = TEXT.get(LANG, TEXT["en"])

def run_capture(cmd):
    try:
        out = subprocess.run(
            ["bash", "-lc", cmd],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=10,
        )
        return out.stdout.strip() or "(sem saída)"
    except Exception as exc:
        return f"erro: {exc}"

def collect_state():
    cmd = r'''
echo "Kernel: $(uname -r)"
echo
echo "Pacotes:"
pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings 2>/dev/null || true
echo
echo "GPU:"
timeout 4 nvidia-smi --query-gpu=name,driver_version,pstate,temperature.gpu,memory.used,memory.total --format=csv,noheader 2>/dev/null || echo "NVIDIA indisponível"
echo
echo "Locale: ${LANG:-indefinido}"
'''
    return run_capture(cmd)

def terminal_script(action):
    action_q = shlex.quote(action)
    action_path = shlex.quote(ACTION)
    if action in ("system-check", "kernel-check", "logs"):
        run_line = f"{action_path} {action_q}"
    else:
        run_line = f"sudo -v || exit 1\nsudo {action_path} {action_q}"

    return f'''set -Eeuo pipefail
echo "Mocha Updater — {action}"
echo
if [ ! -x {action_path} ]; then
  echo "Helper ausente ou sem execução: {ACTION}"
  echo
  read -rp "Pressione Enter para fechar..."
  exit 1
fi
{run_line}
echo
echo "Ação concluída."
read -rp "Pressione Enter para fechar..."
'''

def launch_action(action):
    script = terminal_script(action)
    for cmd in (
        ["konsole", "--hold", "-e", "bash", "-lc", script],
        ["xterm", "-hold", "-e", "bash", "-lc", script],
    ):
        try:
            subprocess.Popen(cmd)
            return f"{T['started']}: {action}"
        except FileNotFoundError:
            continue
        except Exception as exc:
            return f"erro: {exc}"
    return T["no_terminal"]

def kdialog_fallback():
    while True:
        try:
            result = subprocess.run([
                "kdialog", "--title", T["title"], "--menu", T["subtitle"],
                "system-check", T["check_updates"],
                "system-update", T["system_update"],
                "kernel-check", T["kernel_diag"],
                "kernel-install-mocha-stable", T["kernel_install"],
                "rollback-mocha-stable", T["rollback_kernel"],
                "logs", T["show_logs"],
            ], text=True, stdout=subprocess.PIPE)
        except FileNotFoundError:
            print("Tkinter e kdialog indisponíveis.")
            sys.exit(1)

        action = result.stdout.strip()
        if not action:
            break
        launch_action(action)

def main_tk():
    import tkinter as tk
    from tkinter import ttk

    root = tk.Tk()
    root.title(T["title"])
    root.geometry("1020x690")
    root.minsize(860, 560)

    outer = ttk.Frame(root, padding=12)
    outer.pack(fill="both", expand=True)

    title = ttk.Label(outer, text=f"☕ {T['title']}", font=("Sans", 18, "bold"))
    title.pack(anchor="w")

    subtitle = ttk.Label(outer, text=T["subtitle"])
    subtitle.pack(anchor="w", pady=(0, 10))

    body = ttk.PanedWindow(outer, orient="horizontal")
    body.pack(fill="both", expand=True)

    left = ttk.Frame(body, padding=(0, 0, 10, 0))
    right = ttk.Frame(body, padding=(10, 0, 0, 0))
    body.add(left, weight=3)
    body.add(right, weight=2)

    notebook = ttk.Notebook(left)
    notebook.pack(fill="both", expand=True)

    status_var = tk.StringVar(value="")

    def add_button(parent, text, action):
        def cb():
            status_var.set(launch_action(action))
        btn = ttk.Button(parent, text=text, command=cb)
        btn.pack(anchor="w", fill="x", pady=5)

    tab_system = ttk.Frame(notebook, padding=14)
    tab_kernel = ttk.Frame(notebook, padding=14)
    tab_rollback = ttk.Frame(notebook, padding=14)
    tab_about = ttk.Frame(notebook, padding=14)

    notebook.add(tab_system, text=T["system"])
    notebook.add(tab_kernel, text=T["kernel"])
    notebook.add(tab_rollback, text=T["rollback"])
    notebook.add(tab_about, text=T["about"])

    ttk.Label(tab_system, text=T["system_text"], wraplength=500, justify="left").pack(anchor="w", pady=(0, 12))
    add_button(tab_system, T["check_updates"], "system-check")
    add_button(tab_system, T["system_update"], "system-update")

    ttk.Label(tab_kernel, text=T["kernel_text"], wraplength=500, justify="left").pack(anchor="w", pady=(0, 12))
    add_button(tab_kernel, T["kernel_diag"], "kernel-check")
    add_button(tab_kernel, T["kernel_install"], "kernel-install-mocha-stable")

    ttk.Label(tab_rollback, text=T["rollback_text"], wraplength=500, justify="left").pack(anchor="w", pady=(0, 12))
    add_button(tab_rollback, T["rollback_kernel"], "rollback-mocha-stable")
    add_button(tab_rollback, T["show_logs"], "logs")

    ttk.Label(tab_about, text=T["about_text"], wraplength=560, justify="left").pack(anchor="w")

    ttk.Label(right, text=T["state"], font=("Sans", 13, "bold")).pack(anchor="w")

    state_text = tk.Text(right, height=24, width=45, wrap="word")
    state_text.pack(fill="both", expand=True, pady=(8, 8))

    def refresh_state():
        state_text.delete("1.0", "end")
        state_text.insert("1.0", collect_state())

    ttk.Button(right, text=T["refresh"], command=refresh_state).pack(anchor="e")
    refresh_state()

    ttk.Separator(outer).pack(fill="x", pady=8)
    ttk.Label(outer, textvariable=status_var).pack(anchor="w")

    root.mainloop()

if __name__ == "__main__":
    if not Path(ACTION).exists():
        print(f"Backend ausente: {ACTION}", file=sys.stderr)
        sys.exit(1)

    try:
        main_tk()
    except ModuleNotFoundError:
        kdialog_fallback()
PY

chmod +x "$APP/frontend/mocha-updater.py"
ok "Frontend salvo: $APP/frontend/mocha-updater.py"

echo
echo "3) Instalando launcher /usr/local/bin/mocha-updater..."
sudo tee /usr/local/bin/mocha-updater >/dev/null <<'LAUNCHER'
#!/usr/bin/env bash
set -Eeuo pipefail
exec /usr/bin/env python3 /media/mochafast/MochaArch/apps/mocha-updater/frontend/mocha-updater.py "$@"
LAUNCHER
sudo chmod 755 /usr/local/bin/mocha-updater
ok "Launcher instalado: /usr/local/bin/mocha-updater"

echo
echo "4) Reinstalando ícone e atalhos..."
if [ -f "$APP/assets/mocha-updater.svg" ]; then
  sudo mkdir -p /usr/share/icons/hicolor/scalable/apps
  sudo install -m 644 "$APP/assets/mocha-updater.svg" /usr/share/icons/hicolor/scalable/apps/mocha-updater.svg
  timeout 10 sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi

write_desktop() {
  local dst="$1"
  sudo mkdir -p "$(dirname "$dst")"
  sudo tee "$dst" >/dev/null <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Mocha Updater
Name[pt_BR]=Mocha Updater
Name[pt]=Mocha Updater
Name[fr]=Mocha Updater
Name[es]=Mocha Updater
Comment=Real Mocha system, Flatpak, kernel and driver updater
Comment[pt_BR]=Atualizador real de sistema, Flatpak, kernel e driver do Mocha
Comment[pt]=Atualizador real de sistema, Flatpak, kernel e driver do Mocha
Comment[fr]=Outil réel de mise à jour système, Flatpak, noyau et pilote pour Mocha
Comment[es]=Actualizador real de sistema, Flatpak, kernel y controlador para Mocha
Exec=/usr/local/bin/mocha-updater
Icon=mocha-updater
Terminal=false
Categories=System;Settings;
StartupNotify=true
DESKTOP
  sudo chmod 755 "$dst"
}

write_desktop /usr/share/applications/mocha-updater.desktop
write_desktop /etc/skel/Desktop/mocha-updater.desktop
write_desktop "/etc/skel/Área de Trabalho/mocha-updater.desktop"

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  USER_ID="$(id -u "$SUDO_USER")"
  USER_GID="$(id -g "$SUDO_USER")"
else
  USER_HOME="$HOME"
  USER_ID="$(id -u)"
  USER_GID="$(id -g)"
fi

if [ -d "$USER_HOME/Desktop" ]; then
  write_desktop "$USER_HOME/Desktop/mocha-updater.desktop"
  sudo chown "$USER_ID:$USER_GID" "$USER_HOME/Desktop/mocha-updater.desktop"
fi

if [ -d "$USER_HOME/Área de Trabalho" ]; then
  write_desktop "$USER_HOME/Área de Trabalho/mocha-updater.desktop"
  sudo chown "$USER_ID:$USER_GID" "$USER_HOME/Área de Trabalho/mocha-updater.desktop"
fi

echo
echo "5) Validação backend sem alteração de sistema..."
/usr/local/lib/mocha/mocha-updater/mocha-updater-action system-check | tee "$OUT/system-check.txt"

echo
echo "6) Validação launcher..."
head -n 5 /usr/local/bin/mocha-updater
python3 -m py_compile "$APP/frontend/mocha-updater.py"
ok "Python frontend sintaticamente válido"

echo
echo "7) Estado final:"
echo
echo "Launcher:"
ls -lh /usr/local/bin/mocha-updater
echo
echo "Backend:"
ls -lh /usr/local/lib/mocha/mocha-updater/mocha-updater-action
echo
echo "Atalhos:"
find /usr/share/applications /etc/skel/Desktop "/etc/skel/Área de Trabalho" "$USER_HOME/Desktop" "$USER_HOME/Área de Trabalho" \
  -maxdepth 1 -type f -name 'mocha-updater.desktop' \
  -printf '%m %u:%g %p\n' 2>/dev/null | sort || true
echo
echo "Git status:"
git -C "$PUB" status --short || true

ok "Frontend Python/Tk instalado"
