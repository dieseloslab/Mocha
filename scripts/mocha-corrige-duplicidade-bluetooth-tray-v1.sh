#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
info() { printf '[INFO] %s\n' "$*"; }

FAST="/media/mochafast/MochaArch"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$FAST/auditorias/backup-duplicidade-bluetooth-tray-$STAMP"

mkdir -p "$BACKUP_DIR"

echo
echo "============================================================"
echo " Mocha — corrigir duplicidade Bluetooth na bandeja"
echo "============================================================"
echo

echo "Serviço Bluetooth:"
systemctl is-enabled bluetooth 2>/dev/null || true
systemctl is-active bluetooth 2>/dev/null || true

echo
echo "Pacotes relacionados:"
pacman -Q bluez bluez-utils bluedevil blueman 2>/dev/null || true

echo
echo "Processos Bluetooth/Tray antes:"
pgrep -a -f 'blueman|bluedevil|bluez|kded|plasma' | grep -Ei 'blueman|bluedevil|bluez|bluetooth' || true

echo
echo "Arquivos de autostart encontrados:"
find /etc/xdg/autostart "$HOME/.config/autostart" /etc/skel/.config/autostart \
  -maxdepth 1 -type f \( -iname '*blueman*.desktop' -o -iname '*blue*.desktop' -o -iname '*bluetooth*.desktop' \) \
  -print 2>/dev/null || true

echo
echo "============================================================"
echo " Ação"
echo "============================================================"
echo

USER_AUTOSTART="$HOME/.config/autostart"
SKEL_AUTOSTART="/etc/skel/.config/autostart"
USER_BLUEMAN="$USER_AUTOSTART/blueman.desktop"
SKEL_BLUEMAN="$SKEL_AUTOSTART/blueman.desktop"
SYSTEM_BLUEMAN="/etc/xdg/autostart/blueman.desktop"

mkdir -p "$USER_AUTOSTART"

if [ -f "$USER_BLUEMAN" ]; then
  cp -a "$USER_BLUEMAN" "$BACKUP_DIR/user-blueman.desktop.bak"
elif [ -f "$SYSTEM_BLUEMAN" ]; then
  cp -a "$SYSTEM_BLUEMAN" "$BACKUP_DIR/system-blueman.desktop.bak"
fi

cat > "$USER_BLUEMAN" <<'EOF'
[Desktop Entry]
Type=Application
Name=Blueman Applet
Comment=Disabled by Mocha: KDE/BlueDevil is the canonical Bluetooth tray manager
Exec=blueman-applet
Hidden=true
X-Mocha-Disabled-Reason=Duplicate Bluetooth tray applet; keep KDE BlueDevil
EOF

ok "Autostart do blueman-applet desativado para o usuário atual: $USER_BLUEMAN"

sudo mkdir -p "$SKEL_AUTOSTART"

if [ -f "$SKEL_BLUEMAN" ]; then
  sudo cp -a "$SKEL_BLUEMAN" "$BACKUP_DIR/skel-blueman.desktop.bak"
fi

sudo tee "$SKEL_BLUEMAN" >/dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=Blueman Applet
Comment=Disabled by Mocha: KDE/BlueDevil is the canonical Bluetooth tray manager
Exec=blueman-applet
Hidden=true
X-Mocha-Disabled-Reason=Duplicate Bluetooth tray applet; keep KDE BlueDevil
EOF

ok "Autostart do blueman-applet desativado para novos usuários via /etc/skel."

if systemctl --user list-unit-files 2>/dev/null | grep -q '^blueman-applet'; then
  systemctl --user disable --now blueman-applet.service 2>/dev/null || true
  ok "Serviço user blueman-applet desativado quando existente."
fi

if pgrep -x blueman-applet >/dev/null 2>&1; then
  pkill -x blueman-applet || true
  ok "Processo blueman-applet encerrado nesta sessão."
else
  info "blueman-applet não estava rodando como processo separado."
fi

sudo systemctl enable --now bluetooth >/dev/null 2>&1 || true
ok "Serviço bluetooth preservado/ativo."

echo
echo "============================================================"
echo " Estado depois"
echo "============================================================"
echo

echo "Bluetooth:"
systemctl is-enabled bluetooth 2>/dev/null || true
systemctl is-active bluetooth 2>/dev/null || true

echo
echo "Processos Bluetooth/Tray depois:"
pgrep -a -f 'blueman|bluedevil|bluez|kded|plasma' | grep -Ei 'blueman|bluedevil|bluez|bluetooth' || true

echo
echo "Autostart efetivo do Blueman:"
grep -HnE '^(Name|Exec|Hidden|X-Mocha)' "$USER_BLUEMAN" "$SKEL_BLUEMAN" 2>/dev/null || true

echo
echo "============================================================"
echo " Concluído"
echo "============================================================"
ok "Duplicidade corrigida sem remover bluez/blueman."
ok "Backup: $BACKUP_DIR"
echo
echo "Se o segundo ícone ainda aparecer, reinicie a sessão Plasma:"
echo "qdbus org.kde.Shutdown /Shutdown logout"
