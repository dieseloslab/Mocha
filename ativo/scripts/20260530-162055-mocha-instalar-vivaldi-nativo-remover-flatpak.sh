#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:${PATH:-}"

APPID="com.vivaldi.Vivaldi"
TS="$(date +%Y%m%d-%H%M%S)"

FAST_BASE="/media/mochafast/MochaArch/ativo"
if [[ -d "$FAST_BASE" ]]; then
  REPORT_DIR="$FAST_BASE/relatorios"
  DOC_DIR="$FAST_BASE/documentacao"
  SCRIPT_DIR="$FAST_BASE/scripts"
else
  REPORT_DIR="$HOME"
  DOC_DIR="$HOME"
  SCRIPT_DIR="$HOME"
fi

echo "==== MOCHA — Instalar Vivaldi nativo e remover Vivaldi Flatpak ===="
echo
echo "[1/8] Obtendo sudo uma vez"
sudo -v
(
  while true; do
    sudo -n true 2>/dev/null || exit
    sleep 60
  done
) &
KEEPALIVE_PID="$!"
trap 'kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT

for d in "$REPORT_DIR" "$DOC_DIR" "$SCRIPT_DIR"; do
  if [[ ! -d "$d" ]]; then
    sudo install -d -m 0755 -o "$USER" -g "$(id -gn)" "$d"
  fi
done

LOG="$REPORT_DIR/${TS}-instalar-vivaldi-nativo-remover-flatpak.log"
DOC="$DOC_DIR/${TS}-vivaldi-nativo-plasma-browser-integration.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-instalar-vivaldi-nativo-remover-flatpak.sh"

exec > >(tee -a "$LOG") 2>&1

echo
echo "[2/8] Registrando script usado"
cp -f "$0" "$SCRIPT_COPY"
chmod +x "$SCRIPT_COPY"

echo
echo "[3/8] Auditando pacotes disponíveis nos repositórios ativos"
if ! pacman -Si vivaldi >/dev/null 2>&1; then
  echo "ERRO: pacote 'vivaldi' não aparece nos repositórios ativos do pacman."
  echo "Nada foi removido."
  exit 1
fi

if ! pacman -Si plasma-browser-integration >/dev/null 2>&1; then
  echo "ERRO: pacote 'plasma-browser-integration' não aparece nos repositórios ativos do pacman."
  echo "Nada foi removido."
  exit 1
fi

echo "Pacotes encontrados:"
pacman -Si vivaldi plasma-browser-integration | awk '
  /^(Repository|Name|Version|Description)/ { print }
'

echo
echo "[4/8] Instalando Vivaldi nativo e Plasma Browser Integration"
echo "Sem pacman -Syu aqui: não será feita atualização geral de sistema, kernel ou driver."
sudo pacman -S --needed --noconfirm vivaldi plasma-browser-integration

echo
echo "[5/8] Validando executável nativo"
NATIVE_BIN=""
if command -v vivaldi-stable >/dev/null 2>&1; then
  NATIVE_BIN="$(command -v vivaldi-stable)"
elif command -v vivaldi >/dev/null 2>&1; then
  NATIVE_BIN="$(command -v vivaldi)"
else
  echo "ERRO: pacote instalado, mas nenhum executável vivaldi/vivaldi-stable foi encontrado."
  echo "Nada será removido do Flatpak."
  exit 1
fi

echo "Vivaldi nativo encontrado em: $NATIVE_BIN"

DESKTOP_ID=""
if [[ -f /usr/share/applications/vivaldi-stable.desktop ]]; then
  DESKTOP_ID="vivaldi-stable.desktop"
elif [[ -f /usr/share/applications/vivaldi.desktop ]]; then
  DESKTOP_ID="vivaldi.desktop"
else
  DESKTOP_ID="$(pacman -Qlq vivaldi | grep -E '/share/applications/.*vivaldi.*\.desktop$' | sed 's#^.*/##' | head -n 1 || true)"
fi

if [[ -z "$DESKTOP_ID" ]]; then
  echo "AVISO: não encontrei desktop file do Vivaldi. O navegador nativo existe, mas não vou alterar xdg-mime."
else
  echo "Desktop file nativo: $DESKTOP_ID"
fi

echo
echo "[6/8] Conferindo native host do Plasma Browser Integration"
HOST_JSON="/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json"

if [[ -f "$HOST_JSON" ]]; then
  echo "Native host Chromium/Vivaldi encontrado:"
  echo "  $HOST_JSON"
else
  echo "AVISO: native host esperado não encontrado em:"
  echo "  $HOST_JSON"
  echo
  echo "Arquivos do pacote plasma-browser-integration relacionados a native messaging:"
  pacman -Ql plasma-browser-integration | grep -E 'native|browser_integration|chromium|chrome|mozilla' || true
  echo
  echo "O pacote foi instalado, mas se o erro persistir será preciso corrigir o caminho do native host."
fi

echo
echo "[7/8] Fechando Vivaldi e removendo somente o Flatpak, se existir"
pkill -x vivaldi-bin 2>/dev/null || true
pkill -x vivaldi 2>/dev/null || true
pkill -x vivaldi-stable 2>/dev/null || true
sleep 2

USER_INSTALLED=0
SYSTEM_INSTALLED=0

if command -v flatpak >/dev/null 2>&1; then
  if flatpak info --user "$APPID" >/dev/null 2>&1; then
    USER_INSTALLED=1
    echo "Detectado Vivaldi Flatpak no escopo do usuário."
  fi

  if flatpak info --system "$APPID" >/dev/null 2>&1; then
    SYSTEM_INSTALLED=1
    echo "Detectado Vivaldi Flatpak no escopo do sistema."
  fi

  if [[ "$USER_INSTALLED" -eq 1 ]]; then
    echo "Removendo Vivaldi Flatpak do usuário..."
    flatpak uninstall --user -y "$APPID"
  fi

  if [[ "$SYSTEM_INSTALLED" -eq 1 ]]; then
    echo "Removendo Vivaldi Flatpak do sistema..."
    sudo flatpak uninstall --system -y "$APPID"
  fi

  if [[ "$USER_INSTALLED" -eq 0 && "$SYSTEM_INSTALLED" -eq 0 ]]; then
    echo "Nenhum Vivaldi Flatpak estava instalado."
  fi
else
  echo "Flatpak não encontrado. Nada a remover via Flatpak."
fi

echo
echo "[8/8] Ajustando navegador padrão e cache do KDE"
if [[ -n "$DESKTOP_ID" ]] && command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default "$DESKTOP_ID" x-scheme-handler/http || true
  xdg-mime default "$DESKTOP_ID" x-scheme-handler/https || true
  xdg-mime default "$DESKTOP_ID" text/html || true
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
  kbuildsycoca5 --noincremental || true
fi

cat > "$DOC" <<EOF
# Mocha — Vivaldi nativo e Plasma Browser Integration — $TS

## Ação feita

- Instalado/preservado pacote nativo: vivaldi
- Instalado/preservado pacote KDE: plasma-browser-integration
- Executável nativo detectado: $NATIVE_BIN
- Desktop file usado: ${DESKTOP_ID:-não detectado}
- Flatpak removido, se existia: $APPID
- Perfil Flatpak preservado por segurança em: ~/.var/app/$APPID
- Atualização geral do sistema não foi feita.
- Kernel e driver de vídeo não foram alterados por este script.

## Motivo

O Vivaldi Flatpak pode atrapalhar a integração nativa do KDE Plasma Browser Integration por causa da sandbox e também confunde qual navegador está sendo aberto.

## Verificação

Abrir o Vivaldi nativo com:

$NATIVE_BIN

Depois conferir a extensão Plasma Integration dentro do Vivaldi nativo.

Se a extensão ainda reclamar de native host, conferir:

$HOST_JSON
EOF

echo
echo "==== CONCLUÍDO ===="
echo "Vivaldi nativo instalado/preservado."
echo "Vivaldi Flatpak removido se estava instalado."
echo
echo "Abrir Vivaldi nativo:"
echo "  $NATIVE_BIN"
echo
echo "Log: $LOG"
echo "Registro: $DOC"
echo "Script salvo: $SCRIPT_COPY"
