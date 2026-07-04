#!/usr/bin/env python3
import os
import re
import sys
import shutil
import subprocess
from datetime import datetime

QT_API = None
try:
    from PySide6.QtCore import Qt, QThread, Signal, QTimer
    from PySide6.QtWidgets import (
        QApplication, QWidget, QMainWindow, QLabel, QPushButton, QVBoxLayout,
        QHBoxLayout, QGridLayout, QTextEdit, QProgressBar, QFrame, QStackedWidget
    )
    QT_API = "PySide6"
except Exception:
    try:
        from PyQt6.QtCore import Qt, QThread, pyqtSignal as Signal, QTimer
        from PyQt6.QtWidgets import (
            QApplication, QWidget, QMainWindow, QLabel, QPushButton, QVBoxLayout,
            QHBoxLayout, QGridLayout, QTextEdit, QProgressBar, QFrame, QStackedWidget
        )
        QT_API = "PyQt6"
    except Exception as e:
        print("ERRO: PySide6/PyQt6 não encontrado:", e, file=sys.stderr)
        sys.exit(1)

APP_TITLE = "Mocha Updater"

KERNEL_PKGS = {
    "linux", "linux-headers",
    "linux-lts", "linux-lts-headers",
    "linux-zen", "linux-zen-headers",
    "linux-lqx", "linux-lqx-headers",
    "linux-cachyos", "linux-cachyos-headers",
    "linux-cachyos-nvidia-open",
}
NVIDIA_PKGS = {
    "nvidia-open-dkms", "nvidia-dkms", "nvidia-open",
    "nvidia-utils", "lib32-nvidia-utils", "nvidia-settings",
    "nvidia-prime", "opencl-nvidia",
}

def run(cmd, timeout=10):
    try:
        p = subprocess.run(
            cmd, shell=True, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            timeout=timeout
        )
        return p.returncode, p.stdout.strip()
    except subprocess.TimeoutExpired:
        return 124, "timeout"

def first_line(text):
    return (text or "").splitlines()[0].strip() if text else ""

def pkg_installed(pkg):
    return run(f"pacman -Q {pkg} >/dev/null 2>&1", timeout=4)[0] == 0

def pkg_version(pkg):
    rc, out = run(f"pacman -Q {pkg} 2>/dev/null", timeout=4)
    if rc == 0 and out:
        parts = out.split()
        if len(parts) >= 2:
            return parts[1]
    return ""

def detect_kernel():
    rc, kernel = run("uname -r", timeout=4)
    kernel = kernel if rc == 0 and kernel else "indisponível"

    lqx_pkg = pkg_version("linux-lqx")
    lqx_headers = pkg_version("linux-lqx-headers")

    if "lqx" in kernel:
        title = "LQX ativo"
    else:
        title = "Ativo"

    details = kernel
    if lqx_pkg:
        details += f" | linux-lqx {lqx_pkg}"
    if lqx_headers and lqx_headers != lqx_pkg:
        details += f" | headers {lqx_headers}"

    return title, details

def detect_gpu():
    rc, name = run("nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1", timeout=5)
    if rc == 0 and name:
        return "NVIDIA", name

    rc, lspci = run("lspci 2>/dev/null | grep -Ei 'vga|3d|display' | head -n1", timeout=5)
    if lspci:
        short = re.sub(r"^.*: ", "", lspci)
        if "NVIDIA" in short.upper():
            return "NVIDIA", short
        return "GPU", short

    return "GPU", "não detectada"

def detect_nvidia():
    rc, ver = run("nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -n1", timeout=5)
    if rc == 0 and ver:
        return "Ativo", ver

    rc, modver = run("modinfo -F version nvidia 2>/dev/null | head -n1", timeout=5)
    if rc == 0 and modver:
        return "Módulo presente", modver

    rc, lspci = run("lspci 2>/dev/null | grep -Ei 'nvidia' | head -n1", timeout=5)
    if rc == 0 and lspci:
        return "GPU detectada", "driver inativo"

    return "Ausente", "-"

def detect_updates():
    if shutil.which("checkupdates"):
        rc, out = run("checkupdates 2>/dev/null || true", timeout=30)
        lines = [x for x in out.splitlines() if x.strip()]
        filtered = []
        held = []
        for line in lines:
            name = line.split()[0]
            if name in KERNEL_PKGS or name in NVIDIA_PKGS or name.startswith("nvidia-"):
                held.append(name)
            else:
                filtered.append(name)
        if filtered:
            return f"{len(filtered)} pendente(s)", f"{len(held)} kernel/driver separado(s)"
        if held:
            return "Sistema em dia", f"{len(held)} kernel/driver separado(s)"
        return "Sistema em dia", "pacman"
    return "Indisponível", "pacman-contrib/checkupdates ausente"

def detect_flatpak():
    if not shutil.which("flatpak"):
        return "Ausente", "flatpak não instalado"

    rc_apps, apps = run("flatpak list --app --columns=application 2>/dev/null || true", timeout=15)
    rc_run, runtimes = run("flatpak list --runtime --columns=application 2>/dev/null || true", timeout=15)

    app_count = len([x for x in apps.splitlines() if x.strip()])
    runtime_count = len([x for x in runtimes.splitlines() if x.strip()])

    rc_breeze, breeze = run("flatpak list --runtime --columns=application,branch,arch 2>/dev/null | grep -E '^org\\.gtk\\.Gtk3theme\\.Breeze\\b' | head -n1 || true", timeout=15)
    if breeze:
        return "OK", f"{app_count} app(s), {runtime_count} runtime(s), Breeze GTK presente"

    return "OK", f"{app_count} app(s), {runtime_count} runtime(s)"

class Worker(QThread):
    line = Signal(str)
    progress = Signal(int, str)
    done = Signal(int)

    def __init__(self, script):
        super().__init__()
        self.script = script

    def run(self):
        p = subprocess.Popen(
            ["bash", "-lc", self.script],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )
        for raw in p.stdout:
            line = raw.rstrip("\n")
            m = re.match(r"^MOCHA_PROGRESS[ \t]+([0-9]{1,3})[ \t]+(.*)$", line)
            if m:
                pct = max(0, min(100, int(m.group(1))))
                self.progress.emit(pct, m.group(2))
            else:
                self.line.emit(line)
        p.wait()
        self.done.emit(p.returncode)

class Card(QFrame):
    def __init__(self, title):
        super().__init__()
        self.setObjectName("card")
        self.title = QLabel(title)
        self.title.setObjectName("cardTitle")
        self.value = QLabel("...")
        self.value.setObjectName("cardValue")
        self.value.setWordWrap(True)
        self.detail = QLabel("")
        self.detail.setObjectName("cardDetail")
        self.detail.setWordWrap(True)

        lay = QVBoxLayout(self)
        lay.setContentsMargins(12, 10, 12, 10)
        lay.setSpacing(4)
        lay.addWidget(self.title)
        lay.addWidget(self.value)
        lay.addWidget(self.detail)

    def set(self, value, detail=""):
        self.value.setText(str(value))
        self.detail.setText(str(detail))

class MochaUpdater(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(APP_TITLE)
        self.resize(1180, 780)
        self.worker = None
        self.cards = {}

        root = QWidget()
        self.setCentralWidget(root)
        main = QVBoxLayout(root)
        main.setContentsMargins(20, 18, 20, 14)
        main.setSpacing(14)

        top = QHBoxLayout()
        title_box = QVBoxLayout()
        title = QLabel("Mocha Updater")
        title.setObjectName("title")
        subtitle = QLabel("Atualização segura, sem trocar kernel por acidente")
        subtitle.setObjectName("subtitle")
        title_box.addWidget(title)
        title_box.addWidget(subtitle)
        top.addLayout(title_box)
        top.addStretch(1)
        self.btn_refresh = QPushButton("Verificar estado")
        self.btn_refresh.clicked.connect(self.refresh_status)
        top.addWidget(self.btn_refresh)
        main.addLayout(top)

        grid = QGridLayout()
        grid.setSpacing(12)
        for i, key in enumerate(["KERNEL", "GPU", "DRIVER NVIDIA", "UPDATES", "FLATPAK"]):
            card = Card(key)
            self.cards[key] = card
            grid.addWidget(card, 0, i)
        grid.setColumnStretch(4, 2)
        main.addLayout(grid)

        body = QHBoxLayout()
        body.setSpacing(14)

        nav = QVBoxLayout()
        nav.setSpacing(10)
        self.stack = QStackedWidget()
        self.nav_buttons = []
        pages = [
            ("Sistema", self.page_system()),
            ("Kernel / Driver", self.page_kernel()),
            ("Rollback", self.page_rollback()),
            ("Detalhes técnicos", self.page_details()),
            ("Sobre", self.page_about()),
        ]
        for idx, (name, page) in enumerate(pages):
            b = QPushButton(name)
            b.setObjectName("navButton")
            b.clicked.connect(lambda checked=False, n=idx: self.stack.setCurrentIndex(n))
            nav.addWidget(b)
            self.nav_buttons.append(b)
            self.stack.addWidget(page)
        nav.addStretch(1)

        body.addLayout(nav, 0)
        body.addWidget(self.stack, 1)
        main.addLayout(body, 1)

        self.log = QTextEdit()
        self.log.setReadOnly(True)
        self.log.setObjectName("log")
        self.log.setMinimumHeight(145)
        main.addWidget(self.log)

        self.progress = QProgressBar()
        self.progress.setRange(0, 100)
        self.progress.setValue(0)
        main.addWidget(self.progress)

        self.statusBar().showMessage("Concluído")
        self.apply_style()
        QTimer.singleShot(100, self.refresh_status)

    def panel(self, text):
        w = QFrame()
        w.setObjectName("panel")
        lay = QVBoxLayout(w)
        lay.setContentsMargins(18, 18, 18, 18)
        msg = QLabel(text)
        msg.setWordWrap(True)
        lay.addWidget(msg)
        return w, lay

    def page_system(self):
        w, lay = self.panel("Atualiza o sistema sem mexer no kernel e no driver NVIDIA. Kernel e driver ficam em uma etapa separada.")
        b1 = QPushButton("Procurar atualizações")
        b2 = QPushButton("Atualizar sistema")
        b1.clicked.connect(self.action_check_updates)
        b2.clicked.connect(self.action_update_system)
        lay.addWidget(b1)
        lay.addWidget(b2)
        lay.addStretch(1)
        return w

    def page_kernel(self):
        w, lay = self.panel("Instala ou reinstala o kernel Mocha recomendado. Em máquinas NVIDIA, recasa também o driver DKMS e utilitários NVIDIA.")
        b1 = QPushButton("Instalar / reinstalar kernel Mocha recomendado")
        b2 = QPushButton("Regerar initramfs e GRUB")
        b1.clicked.connect(self.action_kernel_driver)
        b2.clicked.connect(self.action_regen_boot)
        lay.addWidget(b1)
        lay.addWidget(b2)
        lay.addStretch(1)
        return w

    def page_rollback(self):
        w, lay = self.panel("Rollback não executa troca cega de kernel. Primeiro lista kernels instalados e estado do bootloader.")
        b = QPushButton("Listar kernels instalados")
        b.clicked.connect(self.action_list_kernels)
        lay.addWidget(b)
        lay.addStretch(1)
        return w

    def page_details(self):
        w, lay = self.panel("Mostra estado técnico real lido por comandos locais.")
        b = QPushButton("Gerar detalhes técnicos")
        b.clicked.connect(self.action_details)
        lay.addWidget(b)
        lay.addStretch(1)
        return w

    def page_about(self):
        w, lay = self.panel("Mocha Updater — frontend local do Mocha. Esta versão corrige leitura imediata de kernel, resumo Flatpak e barra determinada.")
        lay.addStretch(1)
        return w

    def apply_style(self):
        self.setStyleSheet("""
        QMainWindow, QWidget {
            background: #15100d;
            color: #e8d8c3;
            font-size: 14px;
        }
        QLabel#title {
            font-size: 30px;
            font-weight: 800;
            color: #ead8be;
        }
        QLabel#subtitle {
            color: #bda48d;
        }
        QFrame#card, QFrame#panel {
            border: 1px solid #5b4235;
            border-radius: 14px;
            background: #211713;
        }
        QLabel#cardTitle {
            font-size: 12px;
            font-weight: 700;
            color: #c8ad91;
            background: #100b09;
            padding: 3px;
        }
        QLabel#cardValue {
            font-size: 16px;
            font-weight: 800;
            color: #f0dfc9;
        }
        QLabel#cardDetail {
            color: #d0b89d;
            font-size: 12px;
        }
        QPushButton {
            background: #5a3d31;
            border: 1px solid #8a6654;
            border-radius: 10px;
            color: #f2e1cc;
            padding: 12px;
            font-weight: 700;
        }
        QPushButton:hover {
            background: #6f493c;
        }
        QPushButton#navButton {
            text-align: left;
            min-width: 160px;
        }
        QTextEdit#log {
            background: #120d0b;
            border: 1px solid #5b4235;
            border-radius: 10px;
            color: #e8d8c3;
            font-family: monospace;
        }
        QProgressBar {
            border: 1px solid #5b4235;
            border-radius: 8px;
            background: #120d0b;
            height: 18px;
            text-align: center;
        }
        QProgressBar::chunk {
            border-radius: 8px;
            background: #b89478;
        }
        """)

    def refresh_status(self):
        k, kd = detect_kernel()
        gpu, gpud = detect_gpu()
        nv, nvd = detect_nvidia()
        up, upd = detect_updates()
        fp, fpd = detect_flatpak()

        self.cards["KERNEL"].set(k, kd)
        self.cards["GPU"].set(gpu, gpud)
        self.cards["DRIVER NVIDIA"].set(nv, nvd)
        self.cards["UPDATES"].set(up, upd)
        self.cards["FLATPAK"].set(fp, fpd)

        self.log.setPlainText(
            "Resumo\n"
            f"Kernel: {k} - {kd}\n"
            f"GPU: {gpu} - {gpud}\n"
            f"Driver NVIDIA: {nv} - {nvd}\n"
            f"Updates: {up} - {upd}\n"
            f"Flatpak: {fp} - {fpd}\n"
        )
        self.progress.setValue(100)
        self.statusBar().showMessage("Estado atualizado")

    def run_script(self, script):
        if self.worker and self.worker.isRunning():
            self.append_log("ERRO: já existe uma operação em execução.")
            return
        self.progress.setValue(0)
        self.statusBar().showMessage("Executando")
        self.worker = Worker(script)
        self.worker.line.connect(self.append_log)
        self.worker.progress.connect(self.set_progress)
        self.worker.done.connect(self.finished)
        self.worker.start()

    def append_log(self, line):
        self.log.append(line)

    def set_progress(self, pct, msg):
        self.progress.setValue(pct)
        self.statusBar().showMessage(msg)
        self.append_log(f"[{pct}%] {msg}")

    def finished(self, rc):
        self.progress.setValue(100 if rc == 0 else self.progress.value())
        self.statusBar().showMessage("Concluído" if rc == 0 else f"Falhou: código {rc}")
        self.append_log(f"Processo finalizado com código {rc}")
        self.refresh_status()

    def action_check_updates(self):
        self.run_script(r'''
set -Eeuo pipefail
echo "MOCHA_PROGRESS 5 Iniciando checagem"
echo "== pacman/checkupdates =="
if command -v checkupdates >/dev/null 2>&1; then
  checkupdates 2>/dev/null || true
else
  echo "checkupdates ausente; instale pacman-contrib para checagem sem pacman -Sy."
fi
echo "MOCHA_PROGRESS 55 Checando Flatpak"
echo
echo "== flatpak =="
if command -v flatpak >/dev/null 2>&1; then
  flatpak remote-ls --updates 2>/dev/null || true
else
  echo "flatpak ausente"
fi
echo "MOCHA_PROGRESS 100 Checagem concluída"
''')

    def action_update_system(self):
        self.run_script(r'''
set -Eeuo pipefail
echo "MOCHA_PROGRESS 5 Preparando atualização segura"
IGNORE=()
for p in linux linux-headers linux-lts linux-lts-headers linux-zen linux-zen-headers linux-lqx linux-lqx-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open nvidia-open-dkms nvidia-dkms nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime opencl-nvidia; do
  if pacman -Q "$p" >/dev/null 2>&1; then
    IGNORE+=(--ignore "$p")
  fi
done
echo "Pacotes preservados desta etapa: ${IGNORE[*]:-(nenhum)}"
echo "MOCHA_PROGRESS 20 Rodando pacman -Syu com kernel/driver separados"
sudo pacman -Syu --noconfirm "${IGNORE[@]}"
echo "MOCHA_PROGRESS 78 Atualizando Flatpak"
if command -v flatpak >/dev/null 2>&1; then
  flatpak update -y || true
fi
echo "MOCHA_PROGRESS 100 Atualização de sistema concluída"
''')

    def action_kernel_driver(self):
        self.run_script(r'''
set -Eeuo pipefail
echo "MOCHA_PROGRESS 5 Instalando/reinstalando LQX"
sudo pacman -Sy --noconfirm linux-lqx linux-lqx-headers
echo "MOCHA_PROGRESS 45 Verificando NVIDIA"
if lspci 2>/dev/null | grep -qi nvidia; then
  echo "NVIDIA detectada: recasando DKMS/utilitários"
  sudo pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings
  if command -v dkms >/dev/null 2>&1; then
    sudo dkms autoinstall || true
  fi
else
  echo "NVIDIA não detectada: driver NVIDIA não será instalado."
fi
echo "MOCHA_PROGRESS 78 Regerando initramfs"
sudo mkinitcpio -P
echo "MOCHA_PROGRESS 90 Regerando GRUB, se existir"
if [ -d /boot/grub ] && command -v grub-mkconfig >/dev/null 2>&1; then
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
echo "MOCHA_PROGRESS 100 Kernel/driver concluído"
''')

    def action_regen_boot(self):
        self.run_script(r'''
set -Eeuo pipefail
echo "MOCHA_PROGRESS 20 Regerando initramfs"
sudo mkinitcpio -P
echo "MOCHA_PROGRESS 75 Regerando GRUB, se existir"
if [ -d /boot/grub ] && command -v grub-mkconfig >/dev/null 2>&1; then
  sudo grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "GRUB não detectado em /boot/grub."
fi
echo "MOCHA_PROGRESS 100 Boot regenerado"
''')

    def action_list_kernels(self):
        self.run_script(r'''
set -Eeuo pipefail
echo "MOCHA_PROGRESS 20 Lendo kernel ativo"
echo "Kernel ativo:"
uname -r
echo
echo "Pacotes de kernel instalados:"
pacman -Q | grep -E '^(linux|linux-lts|linux-zen|linux-lqx|linux-cachyos)( |-|$)' || true
echo
echo "Boot entries:"
if command -v bootctl >/dev/null 2>&1; then bootctl list 2>/dev/null || true; fi
if [ -d /boot/grub ]; then find /boot -maxdepth 3 -type f | grep -Ei 'vmlinuz|initramfs|grub.cfg' | sort; fi
echo "MOCHA_PROGRESS 100 Lista concluída"
''')

    def action_details(self):
        self.run_script(r'''
set -Eeuo pipefail
echo "MOCHA_PROGRESS 10 Coletando detalhes"
echo "== data =="
date
echo
echo "== kernel =="
uname -a
echo
echo "== pacotes kernel/nvidia =="
pacman -Q linux-lqx linux-lqx-headers nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings 2>/dev/null || true
echo
echo "== nvidia-smi =="
nvidia-smi 2>/dev/null || true
echo
echo "== dkms =="
dkms status 2>/dev/null || true
echo
echo "== flatpak resumo =="
if command -v flatpak >/dev/null 2>&1; then
  echo "Apps: $(flatpak list --app --columns=application 2>/dev/null | sed '/^$/d' | wc -l)"
  echo "Runtimes: $(flatpak list --runtime --columns=application 2>/dev/null | sed '/^$/d' | wc -l)"
  flatpak list --runtime --columns=application,branch,arch 2>/dev/null | grep -E '^org\.gtk\.Gtk3theme\.Breeze\b' || true
fi
echo "MOCHA_PROGRESS 100 Detalhes concluídos"
''')

def main():
    app = QApplication(sys.argv)
    win = MochaUpdater()
    win.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
