#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
FRONT_DIR="$APP/frontend"
HELPER_SRC="$APP/scripts/mocha-updater-action-v1.sh"
HELPER_DST="/usr/local/lib/mocha/mocha-updater/mocha-updater-action"
OUT="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-qt-mocha-sem-terminal-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

mkdir -p "$OUT" "$FRONT_DIR"

echo "============================================================"
echo " Mocha Updater — Qt Mocha sem terminal"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup e retirada do frontend Tk ruim..."
if [ -f "$FRONT_DIR/mocha-updater.py" ]; then
  cp -a "$FRONT_DIR/mocha-updater.py" "$OUT/mocha-updater-tk-ruim.py"
  rm -f "$FRONT_DIR/mocha-updater.py"
  ok "Frontend Tk removido do caminho ativo"
fi

if [ -e /usr/local/bin/mocha-updater ]; then
  sudo cp -a /usr/local/bin/mocha-updater "$OUT/mocha-updater-launcher.before"
fi

cp -a "$HELPER_SRC" "$OUT/mocha-updater-action.before.sh"

echo
echo "2) Instalando runtime Qt/PyQt6, sem update geral..."
if [ -e /var/lib/pacman/db.lck ]; then
  ls -l /var/lib/pacman/db.lck
  fail "Lock do pacman encontrado. Feche qualquer gerenciador de pacotes antes."
fi

if python3 - <<'PY' >/dev/null 2>&1
from PyQt6.QtWidgets import QApplication
PY
then
  ok "PyQt6 já disponível"
else
  sudo pacman -S --needed --noconfirm python-pyqt6 qt6-svg
  ok "PyQt6 instalado"
fi

echo
echo "3) Corrigindo backend para confirmação GUI sem stdin..."
python3 - <<'PY'
from pathlib import Path

p = Path("/media/mochafast/MochaArch/apps/mocha-updater/scripts/mocha-updater-action-v1.sh")
s = p.read_text()

if 'GUI_CONFIRMED="${2:-}"' not in s:
    s = s.replace(
        'ACTION="${1:-}"\nSTAMP="$(date +%Y%m%d-%H%M%S)"',
        'ACTION="${1:-}"\nGUI_CONFIRMED="${2:-}"\nSTAMP="$(date +%Y%m%d-%H%M%S)"'
    )

old = '''confirm_kernel_action() {
  echo
  echo "Esta ação mexe em kernel/driver."
  echo "Ela é separada do update geral para evitar conversão ou troca acidental."
  echo
  printf "Digite SIM para continuar: "
  read -r ans
  [ "$ans" = "SIM" ] || fail "Cancelado pelo usuário."
}
'''

new = '''confirm_kernel_action() {
  echo
  echo "Esta ação mexe em kernel/driver."
  echo "Ela é separada do update geral para evitar conversão ou troca acidental."
  echo

  if [ "${GUI_CONFIRMED:-}" = "--gui-confirmed" ]; then
    ok "Confirmação recebida pela interface gráfica"
    return 0
  fi

  printf "Digite SIM para continuar: "
  read -r ans
  [ "$ans" = "SIM" ] || fail "Cancelado pelo usuário."
}
'''

if old in s:
    s = s.replace(old, new)
elif 'GUI_CONFIRMED' in s and '--gui-confirmed' in s:
    pass
else:
    raise SystemExit("Bloco confirm_kernel_action esperado não encontrado")

p.write_text(s)
print("[OK] Backend corrigido")
PY

sudo mkdir -p /usr/local/lib/mocha/mocha-updater
sudo install -m 755 "$HELPER_SRC" "$HELPER_DST"
ok "Backend instalado: $HELPER_DST"

echo
echo "4) Criando frontend Qt com tema Mocha e logs embutidos..."
cat > "$FRONT_DIR/mocha-updater-qt.py" <<'PY'
#!/usr/bin/env python3
import os
import shlex
import subprocess
import sys
from pathlib import Path

from PyQt6.QtCore import Qt, QProcess, QTimer
from PyQt6.QtGui import QIcon, QPixmap
from PyQt6.QtWidgets import (
    QApplication,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QPlainTextEdit,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

ACTION = "/usr/local/lib/mocha/mocha-updater/mocha-updater-action"
ICON = "/usr/share/icons/hicolor/scalable/apps/mocha-updater.svg"

ROOT_ACTIONS = {
    "system-update",
    "kernel-install-mocha-stable",
    "rollback-mocha-stable",
}

CONFIRM_ACTIONS = {
    "kernel-install-mocha-stable",
    "rollback-mocha-stable",
}

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

TXT = {
    "pt": {
        "title": "Mocha Updater",
        "subtitle": "Atualizador conservador do Mocha",
        "system": "Sistema",
        "kernel": "Kernel / Driver",
        "rollback": "Rollback",
        "about": "Sobre",
        "state": "Estado atual",
        "output": "Saída da ação",
        "refresh": "Atualizar estado",
        "check": "Verificar updates",
        "update": "Update geral conservador",
        "diag": "Diagnosticar CPU/GPU/kernel",
        "install": "Instalar/restaurar kernel Mocha estável",
        "rollback_btn": "Rollback para kernel Mocha estável",
        "logs": "Mostrar logs",
        "clear": "Limpar saída",
        "running": "Rodando ação",
        "finished": "Ação concluída",
        "failed": "Ação falhou",
        "confirm_title": "Confirmar ação sensível",
        "confirm_text": "Esta ação mexe em kernel/driver. Ela só deve ser usada quando você decidiu trocar ou restaurar o conjunto casado do Mocha.",
        "root_note": "Ações privilegiadas usam autenticação gráfica via Polkit/pkexec, sem terminal.",
        "system_desc": "Atualização geral separada de kernel/driver. Aqui o programa evita trocar kernel e NVIDIA por acidente.",
        "kernel_desc": "Diagnóstico e instalação explícita do kernel Mocha estável com driver NVIDIA casado.",
        "rollback_desc": "Rollback explícito para o conjunto estável do repo Mocha.",
        "about_text": "Mocha Updater\n\nInterface Qt com tema Mocha. Sem terminal preto. Saída e progresso ficam dentro do programa.\n\nIdiomas: português, inglês, francês e espanhol. Outros locales usam inglês.\n\nBackend conservador:\n/usr/local/lib/mocha/mocha-updater/mocha-updater-action",
    },
    "en": {
        "title": "Mocha Updater",
        "subtitle": "Conservative Mocha updater",
        "system": "System",
        "kernel": "Kernel / Driver",
        "rollback": "Rollback",
        "about": "About",
        "state": "Current state",
        "output": "Action output",
        "refresh": "Refresh state",
        "check": "Check updates",
        "update": "Conservative system update",
        "diag": "Diagnose CPU/GPU/kernel",
        "install": "Install/restore stable Mocha kernel",
        "rollback_btn": "Rollback to stable Mocha kernel",
        "logs": "Show logs",
        "clear": "Clear output",
        "running": "Running action",
        "finished": "Action finished",
        "failed": "Action failed",
        "confirm_title": "Confirm sensitive action",
        "confirm_text": "This action changes kernel/driver. Use it only when you decided to change or restore the paired Mocha stack.",
        "root_note": "Privileged actions use graphical Polkit/pkexec authentication, without a terminal.",
        "system_desc": "General update separated from kernel/driver. This avoids accidental kernel and NVIDIA changes.",
        "kernel_desc": "Diagnosis and explicit installation of stable Mocha kernel with paired NVIDIA driver.",
        "rollback_desc": "Explicit rollback to the stable set from the Mocha repo.",
        "about_text": "Mocha Updater\n\nQt interface with Mocha theme. No black terminal. Output and progress stay inside the program.\n\nLanguages: Portuguese, English, French and Spanish. Other locales use English.\n\nConservative backend:\n/usr/local/lib/mocha/mocha-updater/mocha-updater-action",
    },
    "fr": {
        "title": "Mocha Updater",
        "subtitle": "Outil prudent de mise à jour Mocha",
        "system": "Système",
        "kernel": "Noyau / Pilote",
        "rollback": "Retour arrière",
        "about": "À propos",
        "state": "État actuel",
        "output": "Sortie de l’action",
        "refresh": "Rafraîchir l’état",
        "check": "Vérifier les mises à jour",
        "update": "Mise à jour prudente",
        "diag": "Diagnostiquer CPU/GPU/noyau",
        "install": "Installer/restaurer le noyau Mocha stable",
        "rollback_btn": "Retour au noyau Mocha stable",
        "logs": "Afficher les journaux",
        "clear": "Effacer la sortie",
        "running": "Action en cours",
        "finished": "Action terminée",
        "failed": "Échec de l’action",
        "confirm_title": "Confirmer l’action sensible",
        "confirm_text": "Cette action modifie le noyau/pilote. À utiliser seulement pour changer ou restaurer l’ensemble Mocha apparié.",
        "root_note": "Les actions privilégiées utilisent Polkit/pkexec graphique, sans terminal.",
        "system_desc": "Mise à jour générale séparée du noyau/pilote pour éviter les changements accidentels.",
        "kernel_desc": "Diagnostic et installation explicite du noyau Mocha stable avec pilote NVIDIA apparié.",
        "rollback_desc": "Retour arrière explicite vers l’ensemble stable du dépôt Mocha.",
        "about_text": "Mocha Updater\n\nInterface Qt avec thème Mocha. Pas de terminal noir. La sortie et la progression restent dans le programme.\n\nLangues : portugais, anglais, français et espagnol. Les autres locales utilisent l’anglais.\n\nBackend prudent :\n/usr/local/lib/mocha/mocha-updater/mocha-updater-action",
    },
    "es": {
        "title": "Mocha Updater",
        "subtitle": "Actualizador conservador de Mocha",
        "system": "Sistema",
        "kernel": "Kernel / Controlador",
        "rollback": "Reversión",
        "about": "Acerca de",
        "state": "Estado actual",
        "output": "Salida de la acción",
        "refresh": "Actualizar estado",
        "check": "Verificar actualizaciones",
        "update": "Actualización conservadora",
        "diag": "Diagnosticar CPU/GPU/kernel",
        "install": "Instalar/restaurar kernel Mocha estable",
        "rollback_btn": "Revertir al kernel Mocha estable",
        "logs": "Mostrar logs",
        "clear": "Limpiar salida",
        "running": "Ejecutando acción",
        "finished": "Acción concluida",
        "failed": "La acción falló",
        "confirm_title": "Confirmar acción sensible",
        "confirm_text": "Esta acción cambia kernel/controlador. Úsela solo para cambiar o restaurar el conjunto emparejado de Mocha.",
        "root_note": "Las acciones privilegiadas usan autenticación gráfica Polkit/pkexec, sin terminal.",
        "system_desc": "Actualización general separada del kernel/controlador para evitar cambios accidentales.",
        "kernel_desc": "Diagnóstico e instalación explícita del kernel Mocha estable con controlador NVIDIA emparejado.",
        "rollback_desc": "Reversión explícita al conjunto estable del repo Mocha.",
        "about_text": "Mocha Updater\n\nInterfaz Qt con tema Mocha. Sin terminal negra. La salida y el progreso quedan dentro del programa.\n\nIdiomas: portugués, inglés, francés y español. Otros locales usan inglés.\n\nBackend conservador:\n/usr/local/lib/mocha/mocha-updater/mocha-updater-action",
    },
}
T = TXT.get(LANG, TXT["en"])

def capture_state():
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
    try:
        out = subprocess.run(
            ["bash", "-lc", cmd],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=8,
        )
        return out.stdout.strip()
    except Exception as exc:
        return f"erro: {exc}"

class MochaUpdater(QMainWindow):
    def __init__(self):
        super().__init__()
        self.proc = None

        self.setWindowTitle(T["title"])
        self.setMinimumSize(1080, 720)

        if Path(ICON).exists():
            self.setWindowIcon(QIcon(ICON))

        root = QWidget()
        self.setCentralWidget(root)

        main = QVBoxLayout(root)
        main.setContentsMargins(18, 18, 18, 18)
        main.setSpacing(12)

        header = QHBoxLayout()
        logo = QLabel()
        if Path(ICON).exists():
            pix = QPixmap(ICON).scaled(58, 58, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation)
            logo.setPixmap(pix)
        else:
            logo.setText("☕")
            logo.setObjectName("LogoText")
        header.addWidget(logo)

        title_box = QVBoxLayout()
        title = QLabel(T["title"])
        title.setObjectName("Title")
        subtitle = QLabel(T["subtitle"])
        subtitle.setObjectName("Subtitle")
        title_box.addWidget(title)
        title_box.addWidget(subtitle)
        header.addLayout(title_box)
        header.addStretch()
        main.addLayout(header)

        content = QHBoxLayout()
        content.setSpacing(14)
        main.addLayout(content, 1)

        self.tabs = QTabWidget()
        self.tabs.setObjectName("Tabs")
        content.addWidget(self.tabs, 3)

        side = QVBoxLayout()
        content.addLayout(side, 2)

        state_title = QLabel(T["state"])
        state_title.setObjectName("SectionTitle")
        side.addWidget(state_title)

        self.state = QPlainTextEdit()
        self.state.setReadOnly(True)
        self.state.setObjectName("StateBox")
        side.addWidget(self.state, 1)

        refresh = QPushButton(T["refresh"])
        refresh.clicked.connect(self.refresh_state)
        side.addWidget(refresh)

        output_title = QLabel(T["output"])
        output_title.setObjectName("SectionTitle")
        side.addWidget(output_title)

        self.output = QPlainTextEdit()
        self.output.setReadOnly(True)
        self.output.setObjectName("OutputBox")
        side.addWidget(self.output, 2)

        clear = QPushButton(T["clear"])
        clear.clicked.connect(self.output.clear)
        side.addWidget(clear)

        self.status = QLabel("")
        self.status.setObjectName("Status")
        main.addWidget(self.status)

        self.make_tabs()
        self.refresh_state()

    def make_tabs(self):
        self.tabs.addTab(self.tab_system(), T["system"])
        self.tabs.addTab(self.tab_kernel(), T["kernel"])
        self.tabs.addTab(self.tab_rollback(), T["rollback"])
        self.tabs.addTab(self.tab_about(), T["about"])

    def make_page(self, desc):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(18, 18, 18, 18)
        layout.setSpacing(12)

        label = QLabel(desc)
        label.setWordWrap(True)
        label.setObjectName("Description")
        layout.addWidget(label)

        note = QLabel(T["root_note"])
        note.setWordWrap(True)
        note.setObjectName("Note")
        layout.addWidget(note)

        return page, layout

    def add_action_button(self, layout, label, action, danger=False):
        btn = QPushButton(label)
        btn.setMinimumHeight(46)
        btn.setProperty("danger", danger)
        btn.clicked.connect(lambda: self.run_action(action))
        layout.addWidget(btn)
        return btn

    def tab_system(self):
        page, layout = self.make_page(T["system_desc"])
        self.add_action_button(layout, T["check"], "system-check")
        self.add_action_button(layout, T["update"], "system-update", danger=True)
        layout.addStretch()
        return page

    def tab_kernel(self):
        page, layout = self.make_page(T["kernel_desc"])
        self.add_action_button(layout, T["diag"], "kernel-check")
        self.add_action_button(layout, T["install"], "kernel-install-mocha-stable", danger=True)
        layout.addStretch()
        return page

    def tab_rollback(self):
        page, layout = self.make_page(T["rollback_desc"])
        self.add_action_button(layout, T["rollback_btn"], "rollback-mocha-stable", danger=True)
        self.add_action_button(layout, T["logs"], "logs")
        layout.addStretch()
        return page

    def tab_about(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(18, 18, 18, 18)
        text = QLabel(T["about_text"])
        text.setWordWrap(True)
        text.setObjectName("Description")
        layout.addWidget(text)
        layout.addStretch()
        return page

    def refresh_state(self):
        self.state.setPlainText(capture_state())

    def run_action(self, action):
        if self.proc and self.proc.state() != QProcess.ProcessState.NotRunning:
            return

        if action in CONFIRM_ACTIONS:
            msg = QMessageBox(self)
            msg.setWindowTitle(T["confirm_title"])
            msg.setText(T["confirm_text"])
            msg.setIcon(QMessageBox.Icon.Warning)
            msg.setStandardButtons(QMessageBox.StandardButton.Cancel | QMessageBox.StandardButton.Ok)
            msg.setDefaultButton(QMessageBox.StandardButton.Cancel)
            if msg.exec() != QMessageBox.StandardButton.Ok:
                return

        self.output.clear()
        self.output.appendPlainText(f"$ mocha-updater-action {action}\n")
        self.status.setText(f"{T['running']}: {action}")

        self.proc = QProcess(self)
        self.proc.setProcessChannelMode(QProcess.ProcessChannelMode.MergedChannels)
        self.proc.readyReadStandardOutput.connect(self.read_output)
        self.proc.finished.connect(self.finished)

        args = []
        if action in ROOT_ACTIONS:
            args = [ACTION, action]
            if action in CONFIRM_ACTIONS:
                args.append("--gui-confirmed")
            self.proc.start("pkexec", args)
        else:
            self.proc.start(ACTION, [action])

    def read_output(self):
        data = bytes(self.proc.readAllStandardOutput()).decode(errors="replace")
        self.output.appendPlainText(data.rstrip())
        self.output.verticalScrollBar().setValue(self.output.verticalScrollBar().maximum())

    def finished(self, code, status):
        if code == 0:
            self.status.setText(T["finished"])
        else:
            self.status.setText(f"{T['failed']} — exit {code}")
        self.refresh_state()

def main():
    app = QApplication(sys.argv)
    app.setApplicationName(T["title"])

    app.setStyleSheet("""
    QWidget {
        background: #1b1410;
        color: #f2e8dc;
        font-family: Noto Sans, Inter, Sans;
        font-size: 14px;
    }

    QMainWindow {
        background: #1b1410;
    }

    QLabel#Title {
        font-size: 30px;
        font-weight: 800;
        color: #f4d2a0;
    }

    QLabel#Subtitle {
        font-size: 15px;
        color: #c9aa86;
    }

    QLabel#SectionTitle {
        font-size: 16px;
        font-weight: 700;
        color: #f4d2a0;
        margin-top: 4px;
    }

    QLabel#Description {
        background: #2a1d17;
        border: 1px solid #6b3f26;
        border-radius: 14px;
        padding: 16px;
        color: #f2e8dc;
        font-size: 15px;
    }

    QLabel#Note {
        color: #d0af8f;
        padding: 6px;
    }

    QLabel#Status {
        color: #f4d2a0;
        font-weight: 700;
    }

    QTabWidget::pane {
        border: 1px solid #6b3f26;
        border-radius: 14px;
        background: #211711;
        top: -1px;
    }

    QTabBar::tab {
        background: #2a1d17;
        color: #c9aa86;
        padding: 11px 18px;
        border-top-left-radius: 10px;
        border-top-right-radius: 10px;
        margin-right: 4px;
        border: 1px solid #4d2d1d;
    }

    QTabBar::tab:selected {
        background: #7a3f20;
        color: #fff1df;
        border: 1px solid #b86f3d;
    }

    QPushButton {
        background: #7a3f20;
        color: #fff1df;
        border: 1px solid #b86f3d;
        border-radius: 12px;
        padding: 11px 16px;
        font-weight: 700;
    }

    QPushButton:hover {
        background: #9a552b;
    }

    QPushButton:pressed {
        background: #5e2f18;
    }

    QPushButton[danger="true"] {
        background: #8f3b2e;
        border: 1px solid #d38463;
    }

    QPlainTextEdit#StateBox,
    QPlainTextEdit#OutputBox {
        background: #120d0a;
        color: #f2e8dc;
        border: 1px solid #6b3f26;
        border-radius: 12px;
        padding: 10px;
        font-family: JetBrains Mono, Noto Sans Mono, monospace;
        font-size: 12px;
    }

    QScrollBar:vertical {
        background: #1b1410;
        width: 12px;
        margin: 0px;
    }

    QScrollBar::handle:vertical {
        background: #7a3f20;
        border-radius: 6px;
        min-height: 28px;
    }

    QMessageBox {
        background: #1b1410;
    }
    """)

    win = MochaUpdater()
    win.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    if not Path(ACTION).exists():
        print(f"Backend ausente: {ACTION}", file=sys.stderr)
        sys.exit(1)
    main()
PY

chmod +x "$FRONT_DIR/mocha-updater-qt.py"
ok "Frontend Qt salvo: $FRONT_DIR/mocha-updater-qt.py"

echo
echo "5) Instalando launcher canônico sem terminal..."
sudo tee /usr/local/bin/mocha-updater >/dev/null <<'LAUNCHER'
#!/usr/bin/env bash
set -Eeuo pipefail
exec /usr/bin/env python3 /media/mochafast/MochaArch/apps/mocha-updater/frontend/mocha-updater-qt.py "$@"
LAUNCHER
sudo chmod 755 /usr/local/bin/mocha-updater
ok "Launcher instalado: /usr/local/bin/mocha-updater"

echo
echo "6) Ícone e atalhos canônicos..."
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
Comment=Atualizador Mocha com interface gráfica
Comment[pt_BR]=Atualizador Mocha com interface gráfica
Comment[pt]=Atualizador Mocha com interface gráfica
Comment[fr]=Outil graphique de mise à jour Mocha
Comment[es]=Actualizador gráfico de Mocha
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
echo "7) Validação sem abrir terminal preto..."
python3 -m py_compile "$FRONT_DIR/mocha-updater-qt.py"

python3 - <<'PY'
from PyQt6.QtWidgets import QApplication
from PyQt6.QtCore import QProcess
print("[OK] PyQt6 Widgets/QProcess disponível")
PY

echo
echo "8) Backend: validação sem alteração de sistema..."
"$HELPER_DST" system-check | tee "$OUT/system-check.txt"

echo
echo "9) Estado final:"
echo
echo "Launcher:"
ls -lh /usr/local/bin/mocha-updater
echo
echo "Frontend:"
ls -lh "$FRONT_DIR/mocha-updater-qt.py"
echo
echo "Backend:"
ls -lh "$HELPER_DST"
echo
echo "Atalhos:"
find /usr/share/applications /etc/skel/Desktop "/etc/skel/Área de Trabalho" "$USER_HOME/Desktop" "$USER_HOME/Área de Trabalho" \
  -maxdepth 1 -type f -name 'mocha-updater.desktop' \
  -printf '%m %u:%g %p\n' 2>/dev/null | sort || true
echo
echo "Frontend antigo ativo:"
find "$FRONT_DIR" -maxdepth 1 -type f -name 'mocha-updater.py' -printf '%p\n' 2>/dev/null || true
echo
echo "Git status:"
git -C "$PUB" status --short || true

ok "Mocha Updater Qt instalado"
