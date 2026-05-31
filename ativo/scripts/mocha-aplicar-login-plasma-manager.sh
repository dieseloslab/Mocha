#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi

echo "== Aplicando esquema aprovado =="
"$SUDO" systemctl disable --now sddm.service 2>/dev/null || true
"$SUDO" systemctl enable plasma-login.service
"$SUDO" systemctl set-default graphical.target

echo
echo "== Verificação depois da alteração =="
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || true
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || true
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || true
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || true
echo
echo "Concluído. Reinicie apenas quando quiser testar o login pelo plasma-login."
