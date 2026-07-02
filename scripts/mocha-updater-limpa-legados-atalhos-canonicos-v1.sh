#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
QUAR="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-legados-quarentena-$(date +%Y%m%d-%H%M%S)}"

mkdir -p "$QUAR/system" "$QUAR/calamares" "$QUAR/skel" "$QUAR/home"

move_if_exists() {
  local src="$1"
  local bucket="$2"
  if [ -e "$src" ] || [ -L "$src" ]; then
    local safe
    safe="$(printf '%s' "$src" | sed 's#^/##; s#[/ ]#__#g')"
    mkdir -p "$QUAR/$bucket"
    sudo mv -v "$src" "$QUAR/$bucket/$safe"
    ok "Retirado de caminho ativo: $src"
  else
    warn "Já ausente: $src"
  fi
}

write_desktop_file() {
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
  ok "Atalho canônico escrito: $dst"
}

echo "============================================================"
echo " Mocha Updater — limpeza de legados e atalhos canônicos"
echo "============================================================"
echo
echo "Quarentena:"
echo "$QUAR"
echo

echo "1) Retirando binários antigos ativos..."
move_if_exists "/usr/local/bin/mocha-kernel-driver-updater" "system"
move_if_exists "/usr/local/bin/mocha-kernel-driver-updater-gui" "system"
move_if_exists "/usr/local/sbin/mocha-kernel-driver-updater" "system"
move_if_exists "/usr/local/sbin/mocha-kernel-driver-updater.bloqueado-apply-amplo-20260630-191244" "system"

echo
echo "2) Retirando atalhos antigos do skel..."
move_if_exists "/etc/skel/Desktop/Atualizador Mocha Kernel e Driver.desktop" "skel"
move_if_exists "/etc/skel/Área de Trabalho/Atualizador Mocha Kernel e Driver.desktop" "skel"
move_if_exists "/etc/skel/Desktop/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "skel"
move_if_exists "/etc/skel/Área de Trabalho/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "skel"
move_if_exists "/etc/skel/Área de trabalho/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "skel"

echo
echo "3) Retirando payload antigo do Calamares, se existir..."
move_if_exists "$PUB/calamares/mocha-calamares/usr/local/bin/mocha-kernel-driver-updater" "calamares"
move_if_exists "$PUB/calamares/mocha-calamares/etc/skel/Desktop/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "calamares"
move_if_exists "$PUB/calamares/mocha-calamares/etc/skel/Área de trabalho/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "calamares"
move_if_exists "$PUB/calamares/mocha-calamares/etc/skel/Área de Trabalho/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "calamares"
move_if_exists "$PUB/calamares/mocha-calamares/home/mocha/Desktop/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "calamares"
move_if_exists "$PUB/calamares/mocha-calamares/home/mocha/Área de trabalho/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "calamares"
move_if_exists "$PUB/calamares/mocha-calamares/home/mocha/Área de Trabalho/Atualizar ou Reinstalar Kernel e Driver Mocha.desktop" "calamares"

echo
echo "4) Instalando ícone canônico..."
if [ -f "$APP/assets/mocha-updater.svg" ]; then
  sudo mkdir -p /usr/share/icons/hicolor/scalable/apps
  sudo install -m 644 "$APP/assets/mocha-updater.svg" /usr/share/icons/hicolor/scalable/apps/mocha-updater.svg
  timeout 10 sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
  ok "Ícone instalado: /usr/share/icons/hicolor/scalable/apps/mocha-updater.svg"
else
  warn "SVG ausente: $APP/assets/mocha-updater.svg"
fi

echo
echo "5) Recriando atalhos canônicos..."
write_desktop_file "/usr/share/applications/mocha-updater.desktop"
write_desktop_file "/etc/skel/Desktop/mocha-updater.desktop"
write_desktop_file "/etc/skel/Área de Trabalho/mocha-updater.desktop"

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
else
  USER_HOME="$HOME"
fi

if [ -d "$USER_HOME/Desktop" ]; then
  write_desktop_file "$USER_HOME/Desktop/mocha-updater.desktop"
  sudo chown "$(id -u "${SUDO_USER:-$USER}")":"$(id -g "${SUDO_USER:-$USER}")" "$USER_HOME/Desktop/mocha-updater.desktop" 2>/dev/null || true
fi

if [ -d "$USER_HOME/Área de Trabalho" ]; then
  write_desktop_file "$USER_HOME/Área de Trabalho/mocha-updater.desktop"
  sudo chown "$(id -u "${SUDO_USER:-$USER}")":"$(id -g "${SUDO_USER:-$USER}")" "$USER_HOME/Área de Trabalho/mocha-updater.desktop" 2>/dev/null || true
fi

echo
echo "6) Verificação final..."
echo
echo "Binário canônico:"
ls -l /usr/local/bin/mocha-updater 2>/dev/null || warn "Binário /usr/local/bin/mocha-updater ausente"

echo
echo "Legados ainda ativos:"
find /usr/local/bin /usr/local/sbin -maxdepth 1 \
  \( -name 'mocha-kernel-driver-updater' -o -name 'mocha-kernel-driver-updater-gui' -o -name 'mocha-kernel-driver-updater.bloqueado-apply-amplo-20260630-191244' \) \
  -printf '%p\n' 2>/dev/null | sort || true

echo
echo "Atalhos Mocha Updater ativos:"
find \
  /usr/share/applications \
  /etc/skel/Desktop \
  "/etc/skel/Área de Trabalho" \
  "$USER_HOME/Desktop" \
  "$USER_HOME/Área de Trabalho" \
  -maxdepth 1 -type f -name 'mocha-updater.desktop' \
  -printf '%m %u:%g %p\n' 2>/dev/null | sort || true

echo
echo "Conteúdo dos atalhos canônicos:"
for f in \
  /usr/share/applications/mocha-updater.desktop \
  /etc/skel/Desktop/mocha-updater.desktop \
  "/etc/skel/Área de Trabalho/mocha-updater.desktop" \
  "$USER_HOME/Desktop/mocha-updater.desktop" \
  "$USER_HOME/Área de Trabalho/mocha-updater.desktop"
do
  [ -f "$f" ] || continue
  echo
  echo "----- $f -----"
  grep -E '^(Name|Name\[|Comment|Comment\[|Exec|Icon|Terminal|Categories)=' "$f" || true
done

echo
echo "Quarentena criada em:"
echo "$QUAR"
echo
ok "Limpeza concluída"
