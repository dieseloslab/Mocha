#!/usr/bin/env python3
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

from PyQt6.QtCore import Qt, QProcess, QTimer, pyqtSignal
from PyQt6.QtGui import QCursor, QIcon, QPixmap
from PyQt6.QtWidgets import (
    QApplication,
    QDialog,
    QFileDialog,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QListWidget,
    QListWidgetItem,
    QMainWindow,
    QMessageBox,
    QPlainTextEdit,
    QProgressBar,
    QPushButton,
    QScrollArea,
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
        "system": "Sistema",
        "kernel": "Kernel / Driver",
        "rollback": "Rollback",
        "about": "Sobre",
        "kernel_card": "Kernel",
        "gpu_card": "GPU",
        "driver_card": "Driver NVIDIA",
        "updates_card": "Updates",
        "flatpak_card": "Flatpak",
        "unknown": "Aguardando",
        "ready": "Pronto",
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
        "summary": "Resumo",
        "system_desc": "Atualiza o sistema sem mexer no kernel e no driver NVIDIA. Kernel e driver ficam em uma área separada.",
        "kernel_desc": "Detecta CPU/GPU e só instala o conjunto kernel/driver quando você pedir explicitamente.",
        "rollback_desc": "Restaura o conjunto estável do Mocha quando um kernel novo se comportar mal.",
        "about_text": "Mocha Updater usa tema Mocha e fluxo gráfico. O usuário vê cards, listas e botões; logs brutos não aparecem na tela principal.",
        "confirm_title": "Confirmar ação sensível",
        "confirm_text": "Esta ação mexe em kernel/driver. Use apenas quando quiser trocar ou restaurar o conjunto casado do Mocha.",
        "auth_note": "A autenticação de administrador usa Polkit/pkexec. Nenhum terminal será aberto.",
        "no_updates": "Sistema em dia",
        "updates_available": "{} disponíveis",
        "updates_title": "Atualizações disponíveis",
        "updates_subtitle": "{} atualizações encontradas. Selecione Atualizar para aplicar o update geral conservador.",
        "update_now": "Atualizar",
        "cancel": "Cancelar",
        "close": "Fechar",
        "no_updates_dialog": "Nenhuma atualização pendente foi encontrada.",
        "gpu_ok": "NVIDIA detectada",
        "gpu_missing": "Não detectada",
        "driver_ok": "Ativo",
        "flatpak_empty": "Sem updates",
        "update_started": "Atualização iniciada. Aguarde a conclusão.",
        "update_finished": "Atualização concluída.",
    },
    "en": {
        "title": "Mocha Updater",
        "subtitle": "Safe updates without accidental kernel changes",
        "system": "System",
        "kernel": "Kernel / Driver",
        "rollback": "Rollback",
        "about": "About",
        "kernel_card": "Kernel",
        "gpu_card": "GPU",
        "driver_card": "NVIDIA Driver",
        "updates_card": "Updates",
        "flatpak_card": "Flatpak",
        "unknown": "Waiting",
        "ready": "Ready",
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
        "summary": "Summary",
        "system_desc": "Updates the system without changing kernel or NVIDIA driver. Kernel and driver are handled separately.",
        "kernel_desc": "Detects CPU/GPU and installs the kernel/driver pair only when explicitly requested.",
        "rollback_desc": "Restores the stable Mocha set when a newer kernel misbehaves.",
        "about_text": "Mocha Updater uses Mocha theme and graphical flow. Users see cards, lists and buttons; raw logs are not shown on the main screen.",
        "confirm_title": "Confirm sensitive action",
        "confirm_text": "This action changes kernel/driver. Use only when you want to change or restore the paired Mocha stack.",
        "auth_note": "Administrator authentication uses Polkit/pkexec. No terminal will be opened.",
        "no_updates": "System up to date",
        "updates_available": "{} available",
        "updates_title": "Available updates",
        "updates_subtitle": "{} updates found. Select Update to apply the conservative general update.",
        "update_now": "Update",
        "cancel": "Cancel",
        "close": "Close",
        "no_updates_dialog": "No pending updates were found.",
        "gpu_ok": "NVIDIA detected",
        "gpu_missing": "Not detected",
        "driver_ok": "Active",
        "flatpak_empty": "No updates",
        "update_started": "Update started. Wait for completion.",
        "update_finished": "Update finished.",
    },
    "fr": {
        "title": "Mocha Updater",
        "subtitle": "Mises à jour sûres sans changement accidentel de noyau",
        "system": "Système",
        "kernel": "Noyau / Pilote",
        "rollback": "Retour",
        "about": "À propos",
        "kernel_card": "Noyau",
        "gpu_card": "GPU",
        "driver_card": "Pilote NVIDIA",
        "updates_card": "Mises à jour",
        "flatpak_card": "Flatpak",
        "unknown": "En attente",
        "ready": "Prêt",
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
        "summary": "Résumé",
        "system_desc": "Met à jour le système sans changer le noyau ni le pilote NVIDIA.",
        "kernel_desc": "Détecte CPU/GPU et installe l’ensemble noyau/pilote seulement sur demande explicite.",
        "rollback_desc": "Restaure l’ensemble stable Mocha si un nouveau noyau pose problème.",
        "about_text": "Mocha Updater utilise le thème Mocha et un flux graphique. Les journaux bruts ne sont pas affichés.",
        "confirm_title": "Confirmer l’action sensible",
        "confirm_text": "Cette action modifie noyau/pilote. À utiliser seulement pour restaurer l’ensemble Mocha.",
        "auth_note": "L’authentification administrateur utilise Polkit/pkexec. Aucun terminal ne sera ouvert.",
        "no_updates": "Système à jour",
        "updates_available": "{} disponibles",
        "updates_title": "Mises à jour disponibles",
        "updates_subtitle": "{} mises à jour trouvées. Sélectionnez Mettre à jour pour appliquer l’opération.",
        "update_now": "Mettre à jour",
        "cancel": "Annuler",
        "close": "Fermer",
        "no_updates_dialog": "Aucune mise à jour en attente.",
        "gpu_ok": "NVIDIA détectée",
        "gpu_missing": "Non détectée",
        "driver_ok": "Actif",
        "flatpak_empty": "Aucune mise à jour",
        "update_started": "Mise à jour lancée. Attendez la fin.",
        "update_finished": "Mise à jour terminée.",
    },
    "es": {
        "title": "Mocha Updater",
        "subtitle": "Actualización segura sin cambiar kernel por accidente",
        "system": "Sistema",
        "kernel": "Kernel / Controlador",
        "rollback": "Reversión",
        "about": "Acerca de",
        "kernel_card": "Kernel",
        "gpu_card": "GPU",
        "driver_card": "Driver NVIDIA",
        "updates_card": "Updates",
        "flatpak_card": "Flatpak",
        "unknown": "Esperando",
        "ready": "Listo",
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
        "summary": "Resumen",
        "system_desc": "Actualiza el sistema sin cambiar kernel ni driver NVIDIA.",
        "kernel_desc": "Detecta CPU/GPU e instala el conjunto kernel/driver solo con pedido explícito.",
        "rollback_desc": "Restaura el conjunto estable de Mocha si un kernel nuevo se comporta mal.",
        "about_text": "Mocha Updater usa tema Mocha y flujo gráfico. Los logs brutos no aparecen en la pantalla principal.",
        "confirm_title": "Confirmar acción sensible",
        "confirm_text": "Esta acción cambia kernel/driver. Úsela solo para restaurar el conjunto Mocha.",
        "auth_note": "La autenticación usa Polkit/pkexec. No se abrirá ninguna terminal.",
        "no_updates": "Sistema al día",
        "updates_available": "{} disponibles",
        "updates_title": "Actualizaciones disponibles",
        "updates_subtitle": "{} actualizaciones encontradas. Seleccione Actualizar para aplicar la operación.",
        "update_now": "Actualizar",
        "cancel": "Cancelar",
        "close": "Cerrar",
        "no_updates_dialog": "No hay actualizaciones pendientes.",
        "gpu_ok": "NVIDIA detectada",
        "gpu_missing": "No detectada",
        "driver_ok": "Activo",
        "flatpak_empty": "Sin updates",
        "update_started": "Actualización iniciada. Espere la conclusión.",
        "update_finished": "Actualización concluida.",
    },
}
EXTRA_TXT = {
    "pt": {
        "details": "Detalhes técnicos",
        "tech_desc": "Área avançada para diagnóstico, suporte e manutenção. O usuário comum não precisa mexer aqui.",
        "tech_refresh": "Atualizar relatório técnico",
        "tech_copy": "Copiar relatório",
        "tech_save": "Salvar relatório",
        "tech_ready": "Relatório técnico pronto.",
        "tech_empty": "Nenhum relatório carregado.",
        "tech_saved": "Relatório salvo.",
        "tech_copied": "Relatório copiado.",
        "tech_generating": "Gerando relatório técnico...",
    },
    "en": {
        "details": "Technical details",
        "tech_desc": "Advanced area for diagnostics, support and maintenance. Regular users do not need this.",
        "tech_refresh": "Refresh technical report",
        "tech_copy": "Copy report",
        "tech_save": "Save report",
        "tech_ready": "Technical report ready.",
        "tech_empty": "No report loaded.",
        "tech_saved": "Report saved.",
        "tech_copied": "Report copied.",
        "tech_generating": "Generating technical report...",
    },
    "fr": {
        "details": "Détails techniques",
        "tech_desc": "Zone avancée pour diagnostic, support et maintenance. L’utilisateur standard n’en a pas besoin.",
        "tech_refresh": "Actualiser le rapport technique",
        "tech_copy": "Copier le rapport",
        "tech_save": "Enregistrer le rapport",
        "tech_ready": "Rapport technique prêt.",
        "tech_empty": "Aucun rapport chargé.",
        "tech_saved": "Rapport enregistré.",
        "tech_copied": "Rapport copié.",
        "tech_generating": "Génération du rapport technique...",
    },
    "es": {
        "details": "Detalles técnicos",
        "tech_desc": "Área avanzada para diagnóstico, soporte y mantenimiento. El usuario común no necesita esto.",
        "tech_refresh": "Actualizar informe técnico",
        "tech_copy": "Copiar informe",
        "tech_save": "Guardar informe",
        "tech_ready": "Informe técnico listo.",
        "tech_empty": "Ningún informe cargado.",
        "tech_saved": "Informe guardado.",
        "tech_copied": "Informe copiado.",
        "tech_generating": "Generando informe técnico...",
    },
}

for _lang, _vals in EXTRA_TXT.items():
    TXT.setdefault(_lang, TXT["en"]).update(_vals)

T = TXT.get(LANG, TXT["en"])

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

def line_after(raw, marker):
    lines = raw.splitlines()
    for i, line in enumerate(lines):
        if line.strip() == marker:
            for nxt in lines[i + 1:]:
                val = nxt.strip()
                if val:
                    return val
    return ""

def parse_update_line(line):
    if " -> " not in line:
        return None
    left, new = line.split(" -> ", 1)
    parts = left.rsplit(" ", 1)
    if len(parts) != 2:
        return {"name": left.strip(), "old": "", "new": new.strip()}
    return {"name": parts[0].strip(), "old": parts[1].strip(), "new": new.strip()}

def parse_system(raw):
    kernel = line_after(raw, "Kernel atual:")
    updates_block = block_between(raw, "Atualizações pendentes:", "Flatpak:")
    update_items = []
    for line in updates_block.splitlines():
        line = line.strip()
        item = parse_update_line(line)
        if item:
            update_items.append(item)

    gpu = T["gpu_missing"]
    for line in raw.splitlines():
        if "NVIDIA GeForce" in line:
            m = re.search(r"NVIDIA GeForce[^\|]+", line)
            gpu = m.group(0).strip() if m else T["gpu_ok"]
            break

    m = re.search(r"NVIDIA-SMI\s+([0-9.]+)", raw)
    driver = f"{T['driver_ok']} · {m.group(1)}" if m else T["unknown"]

    flatpak_block = block_between(raw, "Flatpak:", "NVIDIA:")
    flatpak = T["flatpak_empty"] if not flatpak_block.strip() else flatpak_block.splitlines()[0].strip()

    updates = T["no_updates"] if not update_items else T["updates_available"].format(len(update_items))

    summary = "\n".join([
        f"Kernel: {kernel or T['unknown']}",
        f"{T['updates_card']}: {updates}",
        f"GPU: {gpu}",
        f"{T['driver_card']}: {driver}",
        f"Flatpak: {flatpak}",
    ])

    return {
        "kernel": kernel or T["unknown"],
        "gpu": gpu,
        "driver": driver,
        "updates": updates,
        "flatpak": flatpak,
        "updates_items": update_items,
        "summary": summary,
    }

def parse_kernel(raw):
    cpu_level = line_after(raw, "Nível detectado:") or T["unknown"]
    gpu = "NVIDIA" if "NVIDIA" in raw else T["gpu_missing"]
    installed = []
    for line in raw.splitlines():
        if line.startswith(("linux-cachyos ", "linux-cachyos-headers ", "linux-cachyos-nvidia-open ", "nvidia-utils ")):
            installed.append(line.strip())

    return {
        "kernel": installed[0] if installed else T["unknown"],
        "gpu": gpu,
        "driver": T["driver_ok"] if "nvidia" in raw.lower() else T["unknown"],
        "updates": "Diagnóstico OK" if "[OK]" in raw else T["unknown"],
        "flatpak": "-",
        "updates_items": [],
        "summary": f"CPU: {cpu_level}\nGPU: {gpu}\nConjunto: {'; '.join(installed[:4]) if installed else T['unknown']}",
    }

class Card(QFrame):
    clicked = pyqtSignal()

    def __init__(self, title, value, clickable=False):
        super().__init__()
        self.setObjectName("Card")
        self.clickable = clickable
        if clickable:
            self.setCursor(QCursor(Qt.CursorShape.PointingHandCursor))
            self.setProperty("clickable", True)

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

    def mousePressEvent(self, event):
        if self.clickable and event.button() == Qt.MouseButton.LeftButton:
            self.clicked.emit()
        super().mousePressEvent(event)

class UpdatesDialog(QDialog):
    update_clicked = pyqtSignal()

    def __init__(self, updates, parent=None):
        super().__init__(parent)
        self.updates = updates
        self.setWindowTitle(T["updates_title"])
        self.setMinimumSize(620, 480)
        if Path(ICON).exists():
            self.setWindowIcon(QIcon(ICON))

        layout = QVBoxLayout(self)
        layout.setContentsMargins(18, 18, 18, 18)
        layout.setSpacing(12)

        title = QLabel(T["updates_title"])
        title.setObjectName("DialogTitle")
        layout.addWidget(title)

        subtitle = QLabel(T["updates_subtitle"].format(len(updates)))
        subtitle.setWordWrap(True)
        subtitle.setObjectName("DialogSubtitle")
        layout.addWidget(subtitle)

        self.list = QListWidget()
        self.list.setObjectName("UpdateList")
        for item in updates:
            text = f"{item['name']}\n{item['old']}  →  {item['new']}"
            li = QListWidgetItem(text)
            li.setSizeHint(li.sizeHint())
            self.list.addItem(li)
        layout.addWidget(self.list, 1)

        buttons = QHBoxLayout()
        buttons.addStretch()

        cancel = QPushButton(T["cancel"])
        cancel.clicked.connect(self.reject)
        buttons.addWidget(cancel)

        update = QPushButton(T["update_now"])
        update.setProperty("danger", True)
        update.clicked.connect(self.accept_update)
        buttons.addWidget(update)

        layout.addLayout(buttons)

    def accept_update(self):
        self.update_clicked.emit()
        self.accept()

class ActionPage(QWidget):
    def __init__(self, desc):
        super().__init__()
        self.layout = QVBoxLayout(self)
        self.layout.setContentsMargins(18, 18, 18, 18)
        self.layout.setSpacing(14)

        label = QLabel(desc)
        label.setWordWrap(True)
        label.setObjectName("Description")
        self.layout.addWidget(label)

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
        self.last_updates = []

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
        refresh.clicked.connect(lambda: self.run_action("system-check"))
        header.addWidget(refresh)
        outer.addLayout(header)

        grid = QGridLayout()
        grid.setSpacing(12)

        self.card_kernel = Card(T["kernel_card"], T["unknown"])
        self.card_gpu = Card(T["gpu_card"], T["unknown"])
        self.card_driver = Card(T["driver_card"], T["unknown"])
        self.card_updates = Card(T["updates_card"], T["unknown"], clickable=True)
        self.card_flatpak = Card(T["flatpak_card"], T["unknown"])

        self.card_updates.clicked.connect(self.show_updates_dialog)

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

        for label, index in [(T["system"], 0), (T["kernel"], 1), (T["rollback"], 2), (T["details"], 3), (T["about"], 4)]:
            b = QPushButton(label)
            b.setMinimumWidth(180)
            b.setMinimumHeight(44)
            b.setProperty("nav", True)
            b.clicked.connect(lambda _=False, i=index: self.stack.setCurrentIndex(i))
            nav.addWidget(b)
        nav.addStretch()

        page_system = ActionPage(T["system_desc"])
        page_system.add_action(T["system_check"], lambda: self.run_action("system-check"))
        page_system.add_action(T["system_update"], lambda: self.show_updates_dialog(), danger=True)
        page_system.layout.addStretch()

        page_kernel = ActionPage(T["kernel_desc"])
        page_kernel.add_action(T["kernel_check"], lambda: self.run_action("kernel-check"))
        page_kernel.add_action(T["kernel_install"], lambda: self.run_action("kernel-install-mocha-stable"), danger=True)
        page_kernel.layout.addStretch()

        page_rollback = ActionPage(T["rollback_desc"])
        page_rollback.add_action(T["rollback_btn"], lambda: self.run_action("rollback-mocha-stable"), danger=True)
        page_rollback.layout.addStretch()

        page_details = QWidget()
        details_layout = QVBoxLayout(page_details)
        details_layout.setContentsMargins(18, 18, 18, 18)
        details_layout.setSpacing(12)

        tech_desc = QLabel(T["tech_desc"])
        tech_desc.setObjectName("Description")
        tech_desc.setWordWrap(True)
        details_layout.addWidget(tech_desc)

        tech_buttons = QHBoxLayout()

        tech_refresh = QPushButton(T["tech_refresh"])
        tech_refresh.clicked.connect(self.refresh_technical_report)
        tech_buttons.addWidget(tech_refresh)

        tech_copy = QPushButton(T["tech_copy"])
        tech_copy.clicked.connect(self.copy_technical_report)
        tech_buttons.addWidget(tech_copy)

        tech_save = QPushButton(T["tech_save"])
        tech_save.clicked.connect(self.save_technical_report)
        tech_buttons.addWidget(tech_save)

        tech_buttons.addStretch()
        details_layout.addLayout(tech_buttons)

        self.tech_summary = QLabel(T["tech_empty"])
        self.tech_summary.setObjectName("TechSummary")
        details_layout.addWidget(self.tech_summary)

        self.tech_text = QPlainTextEdit()
        self.tech_text.setObjectName("TechDetails")
        self.tech_text.setReadOnly(True)
        self.tech_text.setPlainText(T["tech_empty"])
        details_layout.addWidget(self.tech_text, 1)

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
        self.stack.addWidget(page_details)
        self.stack.addWidget(page_about)

        result_panel = QFrame()
        result_panel.setObjectName("ResultPanel")
        result_layout = QVBoxLayout(result_panel)
        result_layout.setContentsMargins(16, 14, 16, 14)
        result_layout.setSpacing(10)

        result_title = QLabel(T["summary"])
        result_title.setObjectName("SectionTitle")
        result_layout.addWidget(result_title)

        self.summary = QLabel(T["ready"])
        self.summary.setObjectName("Summary")
        self.summary.setWordWrap(True)
        result_layout.addWidget(self.summary)

        self.progress = QProgressBar()
        self.progress.setRange(0, 100)
        self.progress.setValue(0)
        self.progress.setTextVisible(False)
        result_layout.addWidget(self.progress)

        outer.addWidget(result_panel)

        self.statusBar().showMessage(T["ready"])
        QTimer.singleShot(300, lambda: self.run_action("system-check"))

    def make_technical_report(self):
        cmd = r"""
echo "============================================================"
echo "Mocha Updater — relatório técnico"
echo "============================================================"
echo
echo "Data:"
date -Is
echo
echo "Sistema:"
uname -a
cat /etc/os-release 2>/dev/null || true
echo
echo "Kernel ativo:"
uname -r
echo
echo "Pacman lock:"
if [ -e /var/lib/pacman/db.lck ]; then
  ls -l /var/lib/pacman/db.lck
else
  echo "sem lock"
fi
echo
echo "Pacotes kernel/NVIDIA:"
pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open nvidia-utils lib32-nvidia-utils opencl-nvidia nvidia-settings 2>/dev/null || true
echo
echo "Atualizações pendentes:"
if command -v checkupdates >/dev/null 2>&1; then
  checkupdates || true
else
  pacman -Qu || true
fi
echo
echo "Flatpak:"
if command -v flatpak >/dev/null 2>&1; then
  flatpak remote-ls --updates 2>/dev/null || true
else
  echo "flatpak ausente"
fi
echo
echo "GPU PCI:"
lspci -nnk 2>/dev/null | grep -EA4 -i 'vga|3d|display' || true
echo
echo "NVIDIA-SMI:"
timeout 8 nvidia-smi 2>/dev/null || true
echo
echo "Módulos NVIDIA/Nouveau:"
lsmod | grep -E '^nvidia|^nouveau' || true
echo
echo "Mocha Updater:"
ls -l /usr/local/bin/mocha-updater 2>/dev/null || true
ls -l /usr/local/lib/mocha/mocha-updater/mocha-updater-action 2>/dev/null || true
echo
echo "Atalhos Mocha Updater:"
find /usr/share/applications /etc/skel/Desktop "/etc/skel/Área de Trabalho" "$HOME/Desktop" "$HOME/Área de Trabalho" -maxdepth 1 -type f -name 'mocha-updater.desktop' -printf '%m %u:%g %p\n' 2>/dev/null | sort || true
echo
echo "Git status público:"
git -C /media/mochafast/MochaArch status --short 2>/dev/null || true
"""
        try:
            out = subprocess.run(
                ["bash", "-lc", cmd],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                timeout=25,
            )
            return out.stdout.strip() or T["tech_empty"]
        except Exception as exc:
            return f"erro: {exc}"

    def refresh_technical_report(self):
        self.tech_summary.setText(T["tech_generating"])
        QApplication.setOverrideCursor(Qt.CursorShape.WaitCursor)
        try:
            report = self.make_technical_report()
            self.tech_text.setPlainText(report)
            self.tech_summary.setText(T["tech_ready"])
        finally:
            QApplication.restoreOverrideCursor()

    def copy_technical_report(self):
        text = self.tech_text.toPlainText().strip()
        if not text:
            text = T["tech_empty"]
        QApplication.clipboard().setText(text)
        self.tech_summary.setText(T["tech_copied"])

    def save_technical_report(self):
        text = self.tech_text.toPlainText().strip()
        if not text or text == T["tech_empty"]:
            text = self.make_technical_report()
            self.tech_text.setPlainText(text)

        stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        default_dir = Path("/media/vmstore/MochaArch/auditorias")
        if not default_dir.exists():
            default_dir = Path.home()

        default_path = str(default_dir / f"mocha-updater-relatorio-tecnico-{stamp}.txt")
        path, _ = QFileDialog.getSaveFileName(
            self,
            T["tech_save"],
            default_path,
            "Text files (*.txt);;All files (*)",
        )
        if not path:
            return

        Path(path).write_text(text)
        self.tech_summary.setText(f"{T['tech_saved']} {path}")

    def set_cards(self, parsed):
        self.card_kernel.set_value(parsed.get("kernel", T["unknown"]))
        self.card_gpu.set_value(parsed.get("gpu", T["unknown"]))
        self.card_driver.set_value(parsed.get("driver", T["unknown"]))
        self.card_updates.set_value(parsed.get("updates", T["unknown"]))
        self.card_flatpak.set_value(parsed.get("flatpak", T["unknown"]))
        self.last_updates = parsed.get("updates_items", [])
        self.summary.setText(parsed.get("summary", T["done"]))

    def show_updates_dialog(self):
        if not self.last_updates:
            QMessageBox.information(self, T["updates_title"], T["no_updates_dialog"])
            return

        dialog = UpdatesDialog(self.last_updates, self)
        dialog.update_clicked.connect(lambda: self.run_action("system-update"))
        dialog.exec()

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

    def run_action(self, action):
        if self.proc and self.proc.state() != QProcess.ProcessState.NotRunning:
            return

        if not self.confirm_if_needed(action):
            return

        self.current_action = action
        self.raw_last = ""

        if action == "system-update":
            self.summary.setText(T["update_started"])
        else:
            self.summary.setText(T["checking"] if action in ("system-check", "kernel-check") else T["running"])

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

        if self.current_action == "system-check":
            self.set_cards(parse_system(self.raw_last))
        elif self.current_action == "kernel-check":
            self.set_cards(parse_kernel(self.raw_last))
        elif self.current_action == "system-update":
            if code == 0:
                self.summary.setText(T["update_finished"])
                QTimer.singleShot(500, lambda: self.run_action("system-check"))
            else:
                self.summary.setText(f"{T['failed']} — exit {code}")
        else:
            self.summary.setText(T["done"] if code == 0 else f"{T['failed']} — exit {code}")

        self.statusBar().showMessage(T["done"] if code == 0 else T["failed"])

def main():
    app = QApplication(sys.argv)
    app.setApplicationName(T["title"])

    app.setStyleSheet("""
    QWidget {
        background: #15110f;
        color: #e8ded2;
        font-family: Noto Sans, Inter, Sans;
        font-size: 14px;
    }

    QMainWindow {
        background: #15110f;
    }

    QLabel#Title {
        font-size: 32px;
        font-weight: 900;
        color: #d8c3aa;
    }

    QLabel#Subtitle {
        font-size: 15px;
        color: #aa9784;
    }

    QLabel#CardTitle {
        color: #a99684;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
    }

    QLabel#CardValue {
        color: #eee3d7;
        font-size: 16px;
        font-weight: 800;
    }

    QLabel#Description {
        background: #211916;
        border: 1px solid #4c3930;
        border-radius: 18px;
        padding: 18px;
        color: #e8ded2;
        font-size: 16px;
    }

    QLabel#SectionTitle {
        color: #d8c3aa;
        font-size: 17px;
        font-weight: 900;
    }

    QLabel#Summary {
        color: #e8ded2;
        font-size: 15px;
        background: transparent;
        padding: 4px;
    }

    QLabel#DialogTitle {
        font-size: 24px;
        font-weight: 900;
        color: #d8c3aa;
    }

    QLabel#DialogSubtitle {
        color: #aa9784;
        font-size: 14px;
    }

    QFrame#Card {
        background: #201815;
        border: 1px solid #4c3930;
        border-radius: 18px;
    }

    QFrame#Card[clickable="true"] {
        border: 1px solid #7c6251;
        background: #241b17;
    }

    QFrame#Card[clickable="true"]:hover {
        background: #2b201b;
        border: 1px solid #9b7b66;
    }

    QFrame#ResultPanel {
        background: #1d1613;
        border: 1px solid #4c3930;
        border-radius: 18px;
    }

    QPushButton {
        background: #4b352b;
        color: #eee3d7;
        border: 1px solid #715749;
        border-radius: 14px;
        padding: 11px 16px;
        font-weight: 800;
    }

    QPushButton:hover {
        background: #5a4034;
        border: 1px solid #8a6b59;
    }

    QPushButton:pressed {
        background: #382720;
    }

    QPushButton[danger="true"] {
        background: #5a302d;
        border: 1px solid #84514b;
        color: #f0dfd8;
    }

    QPushButton[danger="true"]:hover {
        background: #6a3935;
        border: 1px solid #9b625a;
    }

    QPushButton[nav="true"] {
        text-align: left;
        background: #201815;
        border: 1px solid #4c3930;
        color: #e8ded2;
    }

    QPushButton[nav="true"]:hover {
        background: #2b201b;
        border: 1px solid #6d5143;
    }

    QStackedWidget {
        background: #1d1613;
        border: 1px solid #4c3930;
        border-radius: 18px;
    }

    QProgressBar {
        background: #100c0a;
        border: 1px solid #4c3930;
        border-radius: 9px;
        height: 12px;
    }

    QProgressBar::chunk {
        background: #8b6f5b;
        border-radius: 9px;
    }

    QListWidget#UpdateList {
        background: #100c0a;
        color: #e8ded2;
        border: 1px solid #4c3930;
        border-radius: 14px;
        padding: 8px;
        font-size: 14px;
    }

    QListWidget#UpdateList::item {
        background: #201815;
        border: 1px solid #4c3930;
        border-radius: 10px;
        padding: 10px;
        margin: 4px;
    }

    QListWidget#UpdateList::item:selected {
        background: #4b352b;
        color: #eee3d7;
        border: 1px solid #8a6b59;
    }

    QLabel#TechSummary {
        color: #aa9784;
        font-size: 13px;
        padding: 4px;
    }

    QPlainTextEdit#TechDetails {
        background: #100c0a;
        color: #d8c9bb;
        border: 1px solid #4c3930;
        border-radius: 14px;
        padding: 12px;
        font-family: JetBrains Mono, Noto Sans Mono, monospace;
        font-size: 12px;
    }

    QDialog {
        background: #15110f;
    }

    QStatusBar {
        background: #15110f;
        color: #aa9784;
    }

    QMessageBox {
        background: #15110f;
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
