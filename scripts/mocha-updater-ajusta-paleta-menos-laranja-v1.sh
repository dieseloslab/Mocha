#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
FRONT="$APP/frontend/mocha-updater-qt.py"
OUT="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-ajusta-paleta-menos-laranja-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

mkdir -p "$OUT"

echo "============================================================"
echo " Mocha Updater — paleta menos laranja/amarela"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup do frontend atual..."
cp -a "$FRONT" "$OUT/mocha-updater-qt.before.py"

echo
echo "2) Substituindo stylesheet por paleta mocha mais neutra..."
python3 - <<'PY'
from pathlib import Path

p = Path("/media/mochafast/MochaArch/apps/mocha-updater/frontend/mocha-updater-qt.py")
s = p.read_text()

start = s.find('    app.setStyleSheet("""')
if start == -1:
    raise SystemExit("app.setStyleSheet não encontrado")

end = s.find('    """)', start)
if end == -1:
    raise SystemExit("fim do stylesheet não encontrado")

end += len('    """)')

new_css = r'''    app.setStyleSheet("""
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
    """)'''

s = s[:start] + new_css + s[end:]
p.write_text(s)
print("[OK] Stylesheet substituído")
PY

echo
echo "3) Validação sintática..."
python3 -m py_compile "$FRONT"

echo
echo "4) Git status:"
git -C "$PUB" status --short || true

ok "Paleta ajustada"
