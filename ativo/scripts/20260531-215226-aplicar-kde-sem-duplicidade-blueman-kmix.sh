#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
USER_AUTOSTART="$HOME/.config/autostart"
mkdir -p "$USER_AUTOSTART"

echo "== MOCHAARCH — remover duplicidade KDE Bluetooth/volume por autostart redundante =="
echo "Timestamp: $TS"

cat > "$USER_AUTOSTART/blueman.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=blueman-applet
Hidden=true
EOF

cat > "$USER_AUTOSTART/kmix_autostart.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=KMix
Hidden=true
EOF

echo "Aplicado ao usuário atual: $USER_AUTOSTART"

if command -v sudo >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null || sudo -v; then
    sudo mkdir -p /etc/skel/.config/autostart
    sudo install -m 0644 "$USER_AUTOSTART/blueman.desktop" /etc/skel/.config/autostart/blueman.desktop
    sudo install -m 0644 "$USER_AUTOSTART/kmix_autostart.desktop" /etc/skel/.config/autostart/kmix_autostart.desktop
    echo "Aplicado também ao /etc/skel para novos usuários."
  else
    echo "Aviso: sem sudo disponível; /etc/skel não foi alterado."
  fi
else
  echo "Aviso: sudo não encontrado; /etc/skel não foi alterado."
fi

echo "Concluído. Reinicie a sessão Plasma se algum ícone redundante ainda estiver visível."
