#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
FRONT_DIR="$APP/frontend"
HELPER_DST="/usr/local/lib/mocha/mocha-updater/mocha-updater-action"
OUT="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-qt-mocha-cards-sem-log-bruto-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

mkdir -p "$OUT" "$FRONT_DIR"

echo "============================================================"
echo " Mocha Updater — UI cards, sem log bruto por padrão"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup da interface anterior..."
cp -a "$FRONT_DIR/mocha-updater-qt.py" "$OUT/mocha-updater-qt.before.py" 2>/dev/null || true
cp -a /usr/local/bin/mocha-updater "$OUT/mocha-updater-launcher.before" 2>/dev/null || true

echo
echo "2) Garantindo PyQt6..."
if python3 - <<'PY' >/dev/null 2>&1
from PyQt6.QtWidgets import QApplication
PY
then
  ok "PyQt6 disponível"
else
  if [ -e /var/lib/pacman/db.lck ]; then
    ls -l /var/lib/pacman/db.lck
    fail "Lock do pacman encontrado."
  fi
  sudo pacman -S --needed --noconfirm python-pyqt6 qt6-svg
  ok "PyQt6 instalado"
fi

echo
echo "3) Escrevendo interface Mocha com cards e resumo..."
cat > "$FRONT_DIR/mocha-updater-qt.py" <<'PY'
#!/usr/bin/env python3
import os
import re
import subprocess
import sys
from pathlib import Path

from PyQt6.QtCore import Qt, QProcess, QTimer
from PyQt6.QtGui import QIcon, QPixmap
from PyQt6.QtWidgets import (
    QApplication,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QMessageBox,
    QPlainTextEdit,
    QProgressBar,
    QPushButton,
    QStackedWidget,
    QVBoxLayout,
    QWidget,
)

ACTION = "/usr/local/lib/mocha/mocha-updater/mocha-updater-action"
ICON = "/usr/share/icons/hicolor/scalable/apps/mocha-updater.svg"

ROOT_ACTIONS = {"system-update", "kernel-install-mocha-stable", "rollback-mocha-stable"}
CONFIRM_ACTIONS = {"kernel-install-mocha-stable", "rollback-mocha-stable"}

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
        "subtitle": "Atualização segura, sem trocar kernel por acidente",
        "dashboard": "Painel",
        "system": "Sistema",
        "kernel": "Kernel / Driver",
        "rollback": "Rollback",
        "about": "Sobre",
        "kernel_card": "Kernel",
        "gpu_card": "GPU",
        "driver_card": "Driver NVIDIA",
        "updates_card": "Updates",
        "flatpak_card": "Flatpak",
        "status_ready": "Pronto",
        "checking": "Verificando...",
        "running": "Executando...",
        "done": "Concluído",
        "failed": "Falhou",
        "refresh": "Verificar estado",
        "system_check": "Procurar atualizações",
        "system_update": "Atualizar sistema",
        "kernel_check": "Analisar hardware",
        "kernel_install": "Instalar kernel Mocha estável",
        "rollback_btn": "Restaurar kernel Mocha estável",
        "logs": "Ver histórico",
        "details_show": "Mostrar detalhes técnicos",
        "details_hide": "Ocultar detalhes técnicos",
        "no_details": "Nenhum detalhe técnico carregado.",
        "summary": "Resumo",
        "system_desc": "Atualiza o sistema sem mexer no kernel e no driver NVIDIA. Kernel e driver ficam em uma área separada.",
        "kernel_desc": "Detecta CPU/GPU e só instala o conjunto kernel/driver quando você pedir explicitamente.",
        "rollback_desc": "Restaura o conjunto estável do Mocha quando um kernel novo se comportar mal.",
        "about_text": "Mocha Updater usa uma interface Qt com tema Mocha. A tela principal mostra resultado resumido em cards. Logs brutos ficam ocultos em detalhes técnicos.",
        "confirm_title": "Confirmar ação sensível",
        "confirm_text": "Esta ação mexe em kernel/driver. Use apenas quando quiser trocar ou restaurar o conjunto casado do Mocha.",
        "auth_note": "A autenticação de administrador usa Polkit/pkexec. Nenhum terminal será aberto.",
        "unknown": "Aguardando",
        "no_updates": "Sistema em dia",
        "updates_available": "{} disponíveis",
        "gpu_ok": "NVIDIA detectada",
        "gpu_missing": "Não detectada",
        "driver_ok": "Ativo",
        "flatpak_empty": "Sem updates",
    },
    "en": {
        "title": "Mocha Updater",
        "subtitle": "Safe updates without accidental kernel changes",
        "dashboard": "Dashboard",
        "system": "System",
        "kernel": "Kernel / Driver",
        "rollback": "Rollback",
        "about": "About",
        "kernel_card": "Kernel",
        "gpu_card": "GPU",
        "driver_card": "NVIDIA Driver",
        "updates_card": "Updates",
        "flatpak_card": "Flatpak",
        "status_ready": "Ready",
        "checking": "Checking...",
        "running": "Running...",
        "done": "Done",
        "failed": "Failed",
        "refresh": "Check state",
        "system_check": "Check updates",
        "system_update": "Update system",
        "kernel_check": "Analyze hardware",
        "kernel_install": "Install stable Mocha kernel",
        "rollback_btn": "Restore stable Mocha kernel",
        "logs": "View history",
        "details_show": "Show technical details",
        "details_hide": "Hide technical details",
        "no_details": "No technical details loaded.",
        "summary": "Summary",
        "system_desc": "Updates the system without changing kernel or NVIDIA driver. Kernel and driver are handled separately.",
        "kernel_desc": "Detects CPU/GPU and installs the kernel/driver pair only when explicitly requested.",
        "rollback_desc": "Restores the stable Mocha set when a newer kernel misbehaves.",
        "about_text": "Mocha Updater uses a Qt interface with Mocha theme. The main screen shows card summaries. Raw logs are hidden under technical details.",
        "confirm_title": "Confirm sensitive action",
        "confirm_text": "This action changes kernel/driver. Use only when you want to change or restore the paired Mocha stack.",
        "auth_note": "Administrator authentication uses Polkit/pkexec. No terminal will be opened.",
        "unknown": "Waiting",
        "no_updates": "System up to date",
        "updates_available": "{} available",
        "gpu_ok": "NVIDIA detected",
        "gpu_missing": "Not detected",
        "driver_ok": "Active",
        "flatpak_empty": "No updates",
    },
    "fr": {
        "title": "Mocha Updater",
        "subtitle": "Mises à jour sûres sans changement accidentel de noyau",
        "dashboard": "Panneau",
        "system": "Système",
        "kernel": "Noyau / Pilote",
        "rollback": "Retour",
        "about": "À propos",
        "kernel_card": "Noyau",
        "gpu_card": "GPU",
        "driver_card": "Pilote NVIDIA",
        "updates_card": "Mises à jour",
        "flatpak_card": "Flatpak",
        "status_ready": "Prêt",
        "checking": "Vérification...",
        "running": "Exécution...",
        "done": "Terminé",
        "failed": "Échec",
        "refresh": "Vérifier l’état",
        "system_check": "Chercher les mises à jour",
        "system_update": "Mettre à jour le système",
        "kernel_check": "Analyser le matériel",
        "kernel_install": "Installer le noyau Mocha stable",
        "rollback_btn": "Restaurer le noyau Mocha stable",
        "logs": "Voir l’historique",
        "details_show": "Afficher les détails techniques",
        "details_hide": "Masquer les détails techniques",
        "no_details": "Aucun détail technique chargé.",
        "summary": "Résumé",
        "system_desc": "Met à jour le système sans changer le noyau ni le pilote NVIDIA.",
        "kernel_desc": "Détecte CPU/GPU et installe l’ensemble noyau/pilote seulement sur demande explicite.",
        "rollback_desc": "Restaure l’ensemble stable Mocha si un nouveau noyau pose problème.",
        "about_text": "Mocha Updater utilise une interface Qt avec thème Mocha. Les journaux bruts sont masqués dans les détails techniques.",
        "confirm_title": "Confirmer l’action sensible",
        "confirm_text": "Cette action modifie noyau/pilote. À utiliser seulement pour restaurer l’ensemble Mocha.",
        "auth_note": "L’authentification administrateur utilise Polkit/pkexec. Aucun terminal ne sera ouvert.",
        "unknown": "En attente",
        "no_updates": "Système à jour",
        "updates_available": "{} disponibles",
        "gpu_ok": "NVIDIA détectée",
        "gpu_missing": "Non détectée",
        "driver_ok": "Actif",
        "flatpak_empty": "Aucune mise à jour",
    },
    "es": {
        "title": "Mocha Updater",
        "subtitle": "Actualización segura sin cambiar kernel por accidente",
        "dashboard": "Panel",
        "system": "Sistema",
        "kernel": "Kernel / Controlador",
        "rollback": "Reversión",
        "about": "Acerca de",
        "kernel_card": "Kernel",
        "gpu_card": "GPU",
        "driver_card": "Driver NVIDIA",
        "updates_card": "Updates",
        "flatpak_card": "Flatpak",
        "status_ready": "Listo",
        "checking": "Verificando...",
        "running": "Ejecutando...",
        "done": "Concluido",
        "failed": "Falló",
        "refresh": "Verificar estado",
        "system_check": "Buscar actualizaciones",
        "system_update": "Actualizar sistema",
        "kernel_check": "Analizar hardware",
        "kernel_install": "Instalar kernel Mocha estable",
        "rollback_btn": "Restaurar kernel Mocha estable",
        "logs": "Ver historial",
        "details_show": "Mostrar detalles técnicos",
        "details_hide": "Ocultar detalles técnicos",
        "no_details": "Ningún detalle técnico cargado.",
        "summary": "Resumen",
        "system_desc": "Actualiza el sistema sin cambiar kernel ni driver NVIDIA.",
        "kernel_desc": "Detecta CPU/GPU e instala el conjunto kernel/driver solo con pedido explícito.",
        "rollback_desc": "Restaura el conjunto estable de Mocha si un kernel nuevo se comporta mal.",
        "about_text": "Mocha Updater usa una interfaz Qt con tema Mocha. Los logs brutos quedan ocultos en detalles técnicos.",
        "confirm_title": "Confirmar acción sensible",
        "confirm_text": "Esta acción cambia kernel/driver. Úsela solo para restaurar el conjunto Mocha.",
        "auth_note": "La autenticación usa Polkit/pkexec. No se abrirá ninguna terminal.",
        "unknown": "Esperando",
        "no_updates": "Sistema al día",
        "updates_available": "{} disponibles",
        "gpu_ok": "NVIDIA detectada",
        "gpu_missing": "No detectada",
        "driver_ok": "Activo",
        "flatpak_empty": "Sin updates",
    },
}
T = TXT.get(LANG, TXT["en"])

def line_after(raw, marker):
    lines = raw.splitlines()
    for i, line in enumerate(lines):
        if line.strip() == marker:
            for nxt in lines[i + 1:]:
                val = nxt.strip()
                if val:
                    return val
    return ""

def block_between(raw, start, end):
    lines = raw.splitlines()
    out = []
    active = False
    for line in lines:
        if line.strip() == start:
            active = True
            continue
        if active and line.strip() == end:
            break
        if active:
            out.append(line)
    return "\n".join(out).strip()

def parse_system(raw):
    kernel = line_after(raw, "Kernel atual:") or re.search(r"Kernel:\s*(.+)", raw).group(1) if re.search(r"Kernel:\s*(.+)", raw) else ""
    updates_block = block_between(raw, "Atualizações pendentes:", "Flatpak:")
    update_lines = [
        l.strip() for l in updates_block.splitlines()
        if l.strip() and "->" in l and not l.startswith("[")
    ]

    gpu = T["gpu_missing"]
    gpu_model = ""
    for line in raw.splitlines():
        if "NVIDIA GeForce" in line:
            gpu = T["gpu_ok"]
            m = re.search(r"NVIDIA GeForce[^\|]+", line)
            gpu_model = m.group(0).strip() if m else "NVIDIA"
            break

    driver = ""
    m = re.search(r"NVIDIA-SMI\s+([0-9.]+)", raw)
    if m:
        driver = f"{T['driver_ok']} · {m.group(1)}"
    else:
        m = re.search(r"nvidia-utils\s+([^\s]+)", raw)
        driver = f"{T['driver_ok']} · {m.group(1)}" if m else T["unknown"]

    flatpak_block = block_between(raw, "Flatpak:", "NVIDIA:")
    flatpak = T["flatpak_empty"] if not flatpak_block.strip() else flatpak_block.splitlines()[0].strip()

    updates = T["no_updates"] if not update_lines else T["updates_available"].format(len(update_lines))

    summary = []
    summary.append(f"Kernel atual: {kernel or T['unknown']}.")
    summary.append(f"Atualizações do sistema: {updates}.")
    summary.append(f"GPU: {gpu_model or gpu}.")
    summary.append(f"Driver NVIDIA: {driver}.")
    summary.append(f"Flatpak: {flatpak}.")

    return {
        "kernel": kernel or T["unknown"],
        "gpu": gpu_model or gpu,
        "driver": driver,
        "updates": updates,
        "flatpak": flatpak,
        "summary": "\n".join(summary),
    }

def parse_kernel(raw):
    cpu = ""
    for line in raw.splitlines():
        if line.startswith("Model name:"):
            cpu = line.split(":", 1)[1].strip()
            break

    level = line_after(raw, "Nível detectado:")
    gpu = T["gpu_missing"]
    for line in raw.splitlines():
        if "NVIDIA" in line and ("VGA" in line or "3D" in line or "Display" in line or "GeForce" in line):
            gpu = line.strip()
            break

    installed = []
    for line in raw.splitlines():
        if line.startswith(("linux-cachyos ", "linux-cachyos-headers ", "linux-cachyos-nvidia-open ", "nvidia-utils ")):
            installed.append(line.strip())

    summary = []
    summary.append(f"CPU: {cpu or T['unknown']}.")
    summary.append(f"Nível de CPU: {level or T['unknown']}.")
    summary.append(f"GPU: {gpu}.")
    if installed:
        summary.append("Conjunto instalado: " + "; ".join(installed[:4]) + ".")
    else:
        summary.append("Conjunto instalado: não identificado.")

    return {
        "kernel": line_after(raw, "Kernel atual:") or T["unknown"],
        "gpu": "NVIDIA" if "NVIDIA" in raw else T["gpu_missing"],
        "driver": T["driver_ok"] if "nvidia" in raw.lower() else T["unknown"],
        "updates": "Diagnóstico OK" if "[OK]" in raw else T["unknown"],
        "flatpak": "-",
        "summary": "\n".join(summary),
    }

class Card(QFrame):
    def __init__(self, title, value):
        super().__init__()
        self.setObjectName("Card")
        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 14, 16, 14)
        layout.setSpacing(6)

        self.title = QLabel(title)
        self.title.setObjectName("CardTitle")
        self.value = QLabel(value)
        self.value.setObjectName("CardValue")
        self.value.setWordWrap(True)

        layout.addWidget(self.title)
        layout.addWidget(self.value)

    def set_value(self, value):
        self.value.setText(value)

class ActionPage(QWidget):
    def __init__(self, desc):
        super().__init__()
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(18, 18, 18, 18)
        self.layout.setSpacing(14)

        self.desc = QLabel(desc)
        self.desc.setWordWrap(True)
        self.desc.setObjectName("Description")
        self.layout.addWidget(self.desc)

    def add_action(self, text, callback, danger=False):
        btn = QPushButton(text)
        btn.setMinimumHeight(48)
        btn.setProperty("danger", danger)
        btn.clicked.connect(callback)
        self.layout.addWidget(btn)
        return btn

class MochaUpdater(QMainWindow):
    def __init__(self):
        super().__init__()
        self.proc = None
        self.current_action = ""
        self.raw_last = ""

        self.setWindowTitle(T["title"])
        self.setMinimumSize(1120, 760)
        if Path(ICON).exists():
            self.setWindowIcon(QIcon(ICON))

        root = QWidget()
        self.setCentralWidget(root)
        outer = QVBoxLayout(root)
        outer.setContentsMargins(20, 20, 20, 20)
        outer.setSpacing(14)

        header = QHBoxLayout()
        if Path(ICON).exists():
            logo = QLabel()
            logo.setPixmap(QPixmap(ICON).scaled(62, 62, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation))
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

        refresh = QPushButton(T["refresh"])
        refresh.clicked.connect(lambda: self.run_action("system-check", silent_dashboard=True))
        header.addWidget(refresh)
        outer.addLayout(header)

        grid = QGridLayout()
        grid.setSpacing(12)
        self.card_kernel = Card(T["kernel_card"], T["unknown"])
        self.card_gpu = Card(T["gpu_card"], T["unknown"])
        self.card_driver = Card(T["driver_card"], T["unknown"])
        self.card_updates = Card(T["updates_card"], T["unknown"])
        self.card_flatpak = Card(T["flatpak_card"], T["unknown"])

        grid.addWidget(self.card_kernel, 0, 0)
        grid.addWidget(self.card_gpu, 0, 1)
        grid.addWidget(self.card_driver, 0, 2)
        grid.addWidget(self.card_updates, 0, 3)
        grid.addWidget(self.card_flatpak, 0, 4)
        outer.addLayout(grid)

        body = QHBoxLayout()
        body.setSpacing(14)
        outer.addLayout(body, 1)

        nav = QVBoxLayout()
        body.addLayout(nav, 0)

        self.stack = QStackedWidget()
        body.addWidget(self.stack, 1)

        self.nav_buttons = []
        for label, index in [
            (T["system"], 0),
            (T["kernel"], 1),
            (T["rollback"], 2),
            (T["about"], 3),
        ]:
            b = QPushButton(label)
            b.setMinimumWidth(180)
            b.setMinimumHeight(44)
            b.setProperty("nav", True)
            b.clicked.connect(lambda _=False, i=index: self.stack.setCurrentIndex(i))
            nav.addWidget(b)
            self.nav_buttons.append(b)
        nav.addStretch()

        page_system = ActionPage(T["system_desc"])
        page_system.add_action(T["system_check"], lambda: self.run_action("system-check"))
        page_system.add_action(T["system_update"], lambda: self.run_action("system-update"), danger=True)
        page_system.layout.addStretch()

        page_kernel = ActionPage(T["kernel_desc"])
        page_kernel.add_action(T["kernel_check"], lambda: self.run_action("kernel-check"))
        page_kernel.add_action(T["kernel_install"], lambda: self.run_action("kernel-install-mocha-stable"), danger=True)
        page_kernel.layout.addStretch()

        page_rollback = ActionPage(T["rollback_desc"])
        page_rollback.add_action(T["rollback_btn"], lambda: self.run_action("rollback-mocha-stable"), danger=True)
        page_rollback.add_action(T["logs"], lambda: self.run_action("logs"))
        page_rollback.layout.addStretch()

        page_about = QWidget()
        about_layout = QVBoxLayout(page_about)
        about_layout.setContentsMargins(18, 18, 18, 18)
        about = QLabel(T["about_text"])
        about.setObjectName("Description")
        about.setWordWrap(True)
        about_layout.addWidget(about)
        about_layout.addStretch()

        self.stack.addWidget(page_system)
        self.stack.addWidget(page_kernel)
        self.stack.addWidget(page_rollback)
        self.stack.addWidget(page_about)

        result_panel = QFrame()
        result_panel.setObjectName("ResultPanel")
        result_layout = QVBoxLayout(result_panel)
        result_layout.setContentsMargins(16, 14, 16, 14)
        result_layout.setSpacing(10)

        result_title = QLabel(T["summary"])
        result_title.setObjectName("SectionTitle")
        result_layout.addWidget(result_title)

        self.summary = QLabel(T["status_ready"])
        self.summary.setObjectName("Summary")
        self.summary.setWordWrap(True)
        result_layout.addWidget(self.summary)

        self.progress = QProgressBar()
        self.progress.setRange(0, 100)
        self.progress.setValue(0)
        self.progress.setTextVisible(False)
        result_layout.addWidget(self.progress)

        self.details_btn = QPushButton(T["details_show"])
        self.details_btn.clicked.connect(self.toggle_details)
        result_layout.addWidget(self.details_btn)

        self.details = QPlainTextEdit()
        self.details.setObjectName("Details")
        self.details.setReadOnly(True)
        self.details.setPlainText(T["no_details"])
        self.details.setVisible(False)
        result_layout.addWidget(self.details)

        outer.addWidget(result_panel)

        self.statusBar().showMessage(T["status_ready"])

        QTimer.singleShot(300, lambda: self.run_action("system-check", silent_dashboard=True))

    def toggle_details(self):
        visible = not self.details.isVisible()
        self.details.setVisible(visible)
        self.details_btn.setText(T["details_hide"] if visible else T["details_show"])

    def set_cards(self, parsed):
        self.card_kernel.set_value(parsed.get("kernel", T["unknown"]))
        self.card_gpu.set_value(parsed.get("gpu", T["unknown"]))
        self.card_driver.set_value(parsed.get("driver", T["unknown"]))
        self.card_updates.set_value(parsed.get("updates", T["unknown"]))
        self.card_flatpak.set_value(parsed.get("flatpak", T["unknown"]))
        self.summary.setText(parsed.get("summary", T["done"]))

    def confirm_if_needed(self, action):
        if action not in CONFIRM_ACTIONS:
            return True
        msg = QMessageBox(self)
        msg.setWindowTitle(T["confirm_title"])
        msg.setText(T["confirm_text"])
        msg.setInformativeText(T["auth_note"])
        msg.setIcon(QMessageBox.Icon.Warning)
        msg.setStandardButtons(QMessageBox.StandardButton.Cancel | QMessageBox.StandardButton.Ok)
        msg.setDefaultButton(QMessageBox.StandardButton.Cancel)
        return msg.exec() == QMessageBox.StandardButton.Ok

    def run_action(self, action, silent_dashboard=False):
        if self.proc and self.proc.state() != QProcess.ProcessState.NotRunning:
            return

        if not self.confirm_if_needed(action):
            return

        self.current_action = action
        self.raw_last = ""
        self.details.setPlainText("")
        self.summary.setText(T["checking"] if action in ("system-check", "kernel-check", "logs") else T["running"])
        self.progress.setRange(0, 0)
        self.statusBar().showMessage(f"{T['running']}: {action}")

        self.proc = QProcess(self)
        self.proc.setProcessChannelMode(QProcess.ProcessChannelMode.MergedChannels)
        self.proc.readyReadStandardOutput.connect(self.collect_output)
        self.proc.finished.connect(self.finish_action)

        if action in ROOT_ACTIONS:
            args = [ACTION, action]
            if action in CONFIRM_ACTIONS:
                args.append("--gui-confirmed")
            self.proc.start("pkexec", args)
        else:
            self.proc.start(ACTION, [action])

    def collect_output(self):
        data = bytes(self.proc.readAllStandardOutput()).decode(errors="replace")
        self.raw_last += data

    def finish_action(self, code, status):
        self.progress.setRange(0, 100)
        self.progress.setValue(100 if code == 0 else 0)
        self.details.setPlainText(self.raw_last.strip() or T["no_details"])

        if self.current_action == "system-check":
            parsed = parse_system(self.raw_last)
            self.set_cards(parsed)
        elif self.current_action == "kernel-check":
            parsed = parse_kernel(self.raw_last)
            self.set_cards(parsed)
        elif self.current_action == "logs":
            count = len([l for l in self.raw_last.splitlines() if "/mocha-updater" in l or "/pacman.log" in l or "/boot/" in l])
            self.summary.setText(f"Histórico consultado. {count} itens técnicos encontrados.")
        else:
            if code == 0:
                self.summary.setText(T["done"])
                QTimer.singleShot(300, lambda: self.run_action("system-check", silent_dashboard=True))
            else:
                self.summary.setText(f"{T['failed']} — exit {code}")

        self.statusBar().showMessage(T["done"] if code == 0 else T["failed"])

def main():
    app = QApplication(sys.argv)
    app.setApplicationName(T["title"])

    app.setStyleSheet("""
    QWidget {
        background: #18110d;
        color: #f4eadf;
        font-family: Noto Sans, Inter, Sans;
        font-size: 14px;
    }

    QMainWindow {
        background: #18110d;
    }

    QLabel#Title {
        font-size: 32px;
        font-weight: 900;
        color: #f5c981;
    }

    QLabel#Subtitle {
        font-size: 15px;
        color: #caa98a;
    }

    QLabel#CardTitle {
        color: #caa98a;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
    }

    QLabel#CardValue {
        color: #fff2e4;
        font-size: 16px;
        font-weight: 800;
    }

    QLabel#Description {
        background: #251912;
        border: 1px solid #704226;
        border-radius: 18px;
        padding: 18px;
        color: #f4eadf;
        font-size: 16px;
    }

    QLabel#SectionTitle {
        color: #f5c981;
        font-size: 17px;
        font-weight: 900;
    }

    QLabel#Summary {
        color: #f4eadf;
        font-size: 15px;
        background: transparent;
        padding: 4px;
    }

    QFrame#Card {
        background: #241812;
        border: 1px solid #704226;
        border-radius: 18px;
    }

    QFrame#ResultPanel {
        background: #211711;
        border: 1px solid #704226;
        border-radius: 18px;
    }

    QPushButton {
        background: #7b4023;
        color: #fff1df;
        border: 1px solid #c07845;
        border-radius: 14px;
        padding: 11px 16px;
        font-weight: 800;
    }

    QPushButton:hover {
        background: #9a552b;
    }

    QPushButton:pressed {
        background: #5f2f19;
    }

    QPushButton[danger="true"] {
        background: #8a332b;
        border: 1px solid #d07d61;
    }

    QPushButton[nav="true"] {
        text-align: left;
        background: #241812;
        border: 1px solid #704226;
    }

    QPushButton[nav="true"]:hover {
        background: #3a2418;
    }

    QStackedWidget {
        background: #211711;
        border: 1px solid #704226;
        border-radius: 18px;
    }

    QProgressBar {
        background: #120c09;
        border: 1px solid #704226;
        border-radius: 9px;
        height: 12px;
    }

    QProgressBar::chunk {
        background: #d28548;
        border-radius: 9px;
    }

    QPlainTextEdit#Details {
        background: #120c09;
        color: #d9c6b5;
        border: 1px solid #704226;
        border-radius: 12px;
        padding: 10px;
        font-family: JetBrains Mono, Noto Sans Mono, monospace;
        font-size: 12px;
    }

    QStatusBar {
        background: #18110d;
        color: #caa98a;
    }

    QMessageBox {
        background: #18110d;
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
ok "Interface atualizada: $FRONT_DIR/mocha-updater-qt.py"

echo
echo "4) Garantindo launcher canônico..."
sudo tee /usr/local/bin/mocha-updater >/dev/null <<'LAUNCHER'
#!/usr/bin/env bash
set -Eeuo pipefail
exec /usr/bin/env python3 /media/mochafast/MochaArch/apps/mocha-updater/frontend/mocha-updater-qt.py "$@"
LAUNCHER
sudo chmod 755 /usr/local/bin/mocha-updater

echo
echo "5) Revalidando atalhos..."
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

if [ -f "$APP/assets/mocha-updater.svg" ]; then
  sudo mkdir -p /usr/share/icons/hicolor/scalable/apps
  sudo install -m 644 "$APP/assets/mocha-updater.svg" /usr/share/icons/hicolor/scalable/apps/mocha-updater.svg
  timeout 10 sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi

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
echo "6) Validação sintática..."
python3 -m py_compile "$FRONT_DIR/mocha-updater-qt.py"

echo
echo "7) Estado final:"
echo "Launcher:"
ls -lh /usr/local/bin/mocha-updater
echo
echo "Frontend:"
ls -lh "$FRONT_DIR/mocha-updater-qt.py"
echo
echo "Git status:"
git -C "$PUB" status --short || true

ok "Interface com cards instalada"
