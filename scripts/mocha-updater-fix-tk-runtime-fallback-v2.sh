#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
FRONT="$APP/frontend/mocha-updater.py"
OUT="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-fix-tk-runtime-fallback-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

mkdir -p "$OUT"

echo "============================================================"
echo " Mocha Updater — fix runtime Tk e fallback"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup do frontend atual..."
cp -a "$FRONT" "$OUT/mocha-updater.py.before"

echo
echo "2) Instalando runtime Tk, sem atualizar o sistema inteiro..."
if [ -e /var/lib/pacman/db.lck ]; then
  ls -l /var/lib/pacman/db.lck
  fail "Lock do pacman encontrado. Feche pacman/octopi/discover antes de instalar tk."
fi

if pacman -Q tk >/dev/null 2>&1; then
  ok "Pacote tk já instalado"
else
  sudo pacman -S --needed --noconfirm tk
  ok "Pacote tk instalado"
fi

echo
echo "3) Corrigindo fallback Python: ImportError também cai para kdialog..."
python3 - <<'PY'
from pathlib import Path

path = Path("/media/mochafast/MochaArch/apps/mocha-updater/frontend/mocha-updater.py")
s = path.read_text()

old = '''    try:
        main_tk()
    except ModuleNotFoundError:
        kdialog_fallback()
'''

new = '''    try:
        main_tk()
    except (ModuleNotFoundError, ImportError) as exc:
        print(f"Tk indisponível: {exc}", file=sys.stderr)
        kdialog_fallback()
'''

if old not in s:
    if "except (ModuleNotFoundError, ImportError) as exc:" in s:
        print("[OK] Fallback já estava corrigido")
    else:
        raise SystemExit("[FALHA] Bloco de fallback esperado não encontrado")
else:
    path.write_text(s.replace(old, new))
    print("[OK] Fallback corrigido")
PY

echo
echo "4) Validando Python/Tk..."
python3 -m py_compile "$FRONT"
ok "Frontend compila sintaticamente"

python3 - <<'PY'
import tkinter
import _tkinter
print("[OK] tkinter importado")
print("TkVersion:", tkinter.TkVersion)
PY

echo
echo "5) Conferindo kdialog como fallback..."
if command -v kdialog >/dev/null 2>&1; then
  ok "kdialog disponível: $(command -v kdialog)"
else
  warn "kdialog ausente. Com Tk funcionando, isso não impede o app."
fi

echo
echo "6) Conferindo launcher e atalhos..."
head -n 5 /usr/local/bin/mocha-updater

find \
  /usr/share/applications \
  /etc/skel/Desktop \
  "/etc/skel/Área de Trabalho" \
  "$HOME/Desktop" \
  "$HOME/Área de Trabalho" \
  -maxdepth 1 -type f -name 'mocha-updater.desktop' \
  -printf '%m %u:%g %p\n' 2>/dev/null | sort || true

echo
echo "7) Validação backend sem alteração de sistema..."
/usr/local/lib/mocha/mocha-updater/mocha-updater-action system-check | tee "$OUT/system-check.txt"

echo
echo "8) Git status:"
git -C "$PUB" status --short || true

ok "Fix Tk/fallback concluído"
