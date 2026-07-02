#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
FRONT="$APP/frontend/mocha-updater-qt.py"
OUT="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-aba-detalhes-tecnicos-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

mkdir -p "$OUT"

echo "============================================================"
echo " Mocha Updater — aba Detalhes Técnicos"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup do frontend atual..."
cp -a "$FRONT" "$OUT/mocha-updater-qt.before.py"

echo
echo "2) Aplicando patch da aba avançada..."
python3 - <<'PY'
from pathlib import Path

p = Path("/media/mochafast/MochaArch/apps/mocha-updater/frontend/mocha-updater-qt.py")
s = p.read_text()

def replace_once(old, new, label):
    global s
    if old not in s:
        raise SystemExit(f"[FALHA] marcador não encontrado: {label}")
    s = s.replace(old, new, 1)

# Imports
replace_once(
'''import os
import re
import subprocess
import sys
from pathlib import Path
''',
'''import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
''',
"import datetime",
)

replace_once(
'''    QApplication,
    QDialog,
''',
'''    QApplication,
    QDialog,
    QFileDialog,
''',
"import QFileDialog",
)

replace_once(
'''    QMessageBox,
    QProgressBar,
''',
'''    QMessageBox,
    QPlainTextEdit,
    QProgressBar,
''',
"import QPlainTextEdit",
)

# Extra translations inserted before T assignment.
replace_once(
'''T = TXT.get(LANG, TXT["en"])
''',
'''EXTRA_TXT = {
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
''',
"extra translations",
)

# Nav: add details before About
replace_once(
'''        for label, index in [(T["system"], 0), (T["kernel"], 1), (T["rollback"], 2), (T["about"], 3)]:
''',
'''        for label, index in [(T["system"], 0), (T["kernel"], 1), (T["rollback"], 2), (T["details"], 3), (T["about"], 4)]:
''',
"nav details",
)

# Insert details page before about page
replace_once(
'''        page_about = QWidget()
        about_layout = QVBoxLayout(page_about)
''',
'''        page_details = QWidget()
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
''',
"details page",
)

# Add stack widget
replace_once(
'''        self.stack.addWidget(page_system)
        self.stack.addWidget(page_kernel)
        self.stack.addWidget(page_rollback)
        self.stack.addWidget(page_about)
''',
'''        self.stack.addWidget(page_system)
        self.stack.addWidget(page_kernel)
        self.stack.addWidget(page_rollback)
        self.stack.addWidget(page_details)
        self.stack.addWidget(page_about)
''',
"stack details",
)

# Add technical methods before set_cards
replace_once(
'''    def set_cards(self, parsed):
''',
'''    def make_technical_report(self):
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
find /usr/share/applications /etc/skel/Desktop "/etc/skel/Área de Trabalho" "$HOME/Desktop" "$HOME/Área de Trabalho" -maxdepth 1 -type f -name 'mocha-updater.desktop' -printf '%m %u:%g %p\\n' 2>/dev/null | sort || true
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
''',
"technical methods",
)

# Style: add technical widgets before QDialog style
replace_once(
'''    QDialog {
        background: #15110f;
    }
''',
'''    QLabel#TechSummary {
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
''',
"style technical",
)

p.write_text(s)
print("[OK] Patch aplicado")
PY

echo
echo "3) Validação sintática..."
python3 -m py_compile "$FRONT"

echo
echo "4) Git status:"
git -C "$PUB" status --short || true

ok "Aba Detalhes Técnicos adicionada"
