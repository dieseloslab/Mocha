#!/usr/bin/env bash
set -Eeuo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
REAL_USER="${SUDO_USER:-$USER}"
REAL_GROUP="$(id -gn "$REAL_USER" 2>/dev/null || echo "$REAL_USER")"

BASE="/media/mochafast/MochaArch"
ACTIVE="$BASE/ativo"
DOC_DIR="$ACTIVE/documentacao"
SCRIPT_DIR="$ACTIVE/scripts"
LOG_DIR="$ACTIVE/logs"
REPORT_DIR="$ACTIVE/relatorios"

LOG="$LOG_DIR/${TS}-login-manager-plasmalogin.log"
REPORT="$REPORT_DIR/${TS}-login-manager-plasmalogin-auditoria.txt"
DOC="$DOC_DIR/${TS}-login-manager-plasmalogin-aplicado-pendente-pos-boot.md"
FINAL_SCRIPT="$SCRIPT_DIR/${TS}-mocha-ativar-plasma-login-manager.sh"
VERIFY_SCRIPT="$SCRIPT_DIR/${TS}-mocha-verificar-plasmalogin-pos-boot.sh"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

append_line() {
  printf '%s\n' "$2" >> "$1"
}

unit_exists() {
  systemctl list-unit-files "$1" --no-legend --no-pager 2>/dev/null | awk '{print $1}' | grep -qx "$1"
}

enabled_state() {
  systemctl is-enabled "$1" 2>/dev/null || true
}

say "Pré-validação: mounts obrigatórios do Mocha"
findmnt -rno TARGET /media/mochafast >/dev/null || fail "/media/mochafast não está montado. Pare aqui e monte o FAST antes de mexer no login manager."
findmnt -rno TARGET /media/vmstore >/dev/null || fail "/media/vmstore não está montado. Pare aqui e monte o VMSTORE antes de mexer no login manager."

say "Preparando diretórios de log/documentação no MochaArch"
sudo -v
sudo install -d -o "$REAL_USER" -g "$REAL_GROUP" -m 0755 "$DOC_DIR" "$SCRIPT_DIR" "$LOG_DIR" "$REPORT_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Escopo fixo deste comando"
printf '%s\n' "Este comando NÃO altera teclado, localectl, /etc/vconsole.conf, keymap, ABNT2, layout X11 ou layout Wayland."
printf '%s\n' "Este comando NÃO remove pacotes."
printf '%s\n' "Este comando NÃO reinicia/paralisa o gerenciador gráfico atual durante esta sessão."
printf '%s\n' "Este comando só deixa plasmalogin.service como display-manager.service para o próximo boot."

say "Auditoria inicial do sistema"
{
  printf '%s\n' "timestamp=$TS"
  printf '%s\n' "usuario_real=$REAL_USER"
  printf '%s\n' "kernel=$(uname -r)"
  printf '%s\n' "default_target=$(systemctl get-default 2>/dev/null || true)"
  printf '%s\n' ""
  printf '%s\n' "os-release:"
  sed -n '1,120p' /etc/os-release 2>/dev/null || true
  printf '%s\n' ""
  printf '%s\n' "display-manager.service antes:"
  if [ -L /etc/systemd/system/display-manager.service ]; then
    readlink -v /etc/systemd/system/display-manager.service || true
    readlink -f /etc/systemd/system/display-manager.service || true
  else
    printf '%s\n' "sem symlink /etc/systemd/system/display-manager.service"
  fi
  printf '%s\n' ""
  printf '%s\n' "servicos de login conhecidos antes:"
  for svc in sddm.service gdm.service lightdm.service ly.service lxdm.service xdm.service greetd.service emptty.service lemurs.service plasmalogin.service; do
    if unit_exists "$svc"; then
      printf '%s %s\n' "$svc" "$(enabled_state "$svc")"
    fi
  done
  printf '%s\n' ""
  printf '%s\n' "pacotes relevantes antes:"
  pacman -Q plasma-login-manager sddm sddm-kcm plasma-desktop plasma-workspace 2>/dev/null || true
} > "$REPORT"

cat "$REPORT"

say "Validando repositório/pacote local"
if ! pacman -Q plasma-login-manager >/dev/null 2>&1; then
  pacman -Si plasma-login-manager >/dev/null 2>&1 || fail "O pacman local não enxerga plasma-login-manager. Não vou improvisar com AUR, git ou pacote externo."
  say "Instalando plasma-login-manager pelo pacman, sem AUR e sem remover SDDM"
  sudo pacman -S --needed plasma-login-manager
else
  say "plasma-login-manager já está instalado"
fi

say "Validando versão e arquivos reais instalados"
PLM_VER="$(pacman -Q plasma-login-manager | awk '{print $2}')"
printf 'plasma-login-manager=%s\n' "$PLM_VER"

if command -v vercmp >/dev/null 2>&1; then
  if [ "$(vercmp "$PLM_VER" "6.5.90-1")" -lt 0 ]; then
    fail "plasma-login-manager está abaixo de 6.5.90-1. Não vou ativar versão antiga."
  fi
fi

for required_path in \
  /usr/lib/systemd/system/plasmalogin.service \
  /usr/bin/plasmalogin \
  /usr/bin/startplasma-login-wayland \
  /usr/lib/pam.d/plasmalogin \
  /usr/lib/sysusers.d/plasmalogin.conf
do
  [ -e "$required_path" ] || fail "Arquivo obrigatório ausente: $required_path"
  printf 'OK: %s\n' "$required_path"
done

say "Criando usuário/arquivos auxiliares do Plasma Login Manager"
sudo systemd-sysusers
sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/plasmalogin.conf

say "Recarregando systemd"
sudo systemctl daemon-reload

say "Desativando apenas serviços antigos de display manager, sem parar a sessão atual"
for oldsvc in sddm.service gdm.service lightdm.service ly.service lxdm.service xdm.service greetd.service emptty.service lemurs.service; do
  if unit_exists "$oldsvc"; then
    state="$(enabled_state "$oldsvc")"
    printf '%s estava: %s\n' "$oldsvc" "${state:-desconhecido}"
    case "$state" in
      enabled|enabled-runtime|linked|linked-runtime|alias)
        sudo systemctl disable "$oldsvc" || true
        ;;
      *)
        printf '%s não estava habilitado; nada a desativar.\n' "$oldsvc"
        ;;
    esac
  fi
done

say "Ativando Plasma Login Manager como display-manager.service para o próximo boot"
sudo systemctl enable --force plasmalogin.service

say "Validação final da troca"
FINAL_TARGET="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
PLM_ENABLED="$(systemctl is-enabled plasmalogin.service 2>/dev/null || true)"
DEFAULT_TARGET="$(systemctl get-default 2>/dev/null || true)"

printf 'display-manager.service aponta para: %s\n' "$FINAL_TARGET"
printf 'plasmalogin.service is-enabled: %s\n' "$PLM_ENABLED"
printf 'default target: %s\n' "$DEFAULT_TARGET"

[ "$FINAL_TARGET" = "/usr/lib/systemd/system/plasmalogin.service" ] || fail "display-manager.service não aponta para plasmalogin.service."
case "$PLM_ENABLED" in
  enabled|alias|linked|static)
    printf '%s\n' "OK: plasmalogin.service está habilitado/associado corretamente."
    ;;
  *)
    fail "plasmalogin.service não ficou habilitado corretamente."
    ;;
esac

if [ "$DEFAULT_TARGET" != "graphical.target" ]; then
  printf '%s\n' "AVISO: default target não é graphical.target. Não alterei isso para não improvisar fora do manual."
fi

say "Criando script de verificação pós-boot"
: > "$VERIFY_SCRIPT"
append_line "$VERIFY_SCRIPT" '#!/usr/bin/env bash'
append_line "$VERIFY_SCRIPT" 'set -Eeuo pipefail'
append_line "$VERIFY_SCRIPT" 'printf "\n== display-manager.service ==\n"'
append_line "$VERIFY_SCRIPT" 'readlink -v /etc/systemd/system/display-manager.service 2>/dev/null || true'
append_line "$VERIFY_SCRIPT" 'readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true'
append_line "$VERIFY_SCRIPT" 'printf "\n== plasmalogin.service ==\n"'
append_line "$VERIFY_SCRIPT" 'systemctl is-enabled plasmalogin.service 2>/dev/null || true'
append_line "$VERIFY_SCRIPT" 'systemctl is-active plasmalogin.service 2>/dev/null || true'
append_line "$VERIFY_SCRIPT" 'systemctl status plasmalogin.service --no-pager -l || true'
append_line "$VERIFY_SCRIPT" 'printf "\n== sessão atual ==\n"'
append_line "$VERIFY_SCRIPT" 'if [ -n "${XDG_SESSION_ID:-}" ]; then loginctl show-session "$XDG_SESSION_ID" -p Type -p Desktop -p Name 2>/dev/null || true; else loginctl list-sessions || true; fi'
append_line "$VERIFY_SCRIPT" 'printf "\n== logs do boot atual do plasmalogin ==\n"'
append_line "$VERIFY_SCRIPT" 'journalctl -b -u plasmalogin.service --no-pager -n 120 || true'
chmod +x "$VERIFY_SCRIPT"

say "Documentando etapa aplicada, ainda pendente de validação após reboot"
: > "$DOC"
append_line "$DOC" "# Mocha Arch - Login Manager - Plasma Login Manager"
append_line "$DOC" ""
append_line "$DOC" "Data: $TS"
append_line "$DOC" ""
append_line "$DOC" "Estado: aplicado; pendente de validação após reboot/login."
append_line "$DOC" ""
append_line "$DOC" "O que foi feito:"
append_line "$DOC" "- Validado que /media/mochafast e /media/vmstore estavam montados."
append_line "$DOC" "- Validado/instalado o pacote plasma-login-manager pelo pacman."
append_line "$DOC" "- Validada a presença de /usr/lib/systemd/system/plasmalogin.service."
append_line "$DOC" "- Validada a presença de /usr/bin/startplasma-login-wayland."
append_line "$DOC" "- Executado systemd-sysusers e systemd-tmpfiles para o plasmalogin."
append_line "$DOC" "- Desativados apenas serviços antigos de display manager que estivessem habilitados, sem parar a sessão atual."
append_line "$DOC" "- Ativado plasmalogin.service com systemctl enable --force para substituir display-manager.service."
append_line "$DOC" ""
append_line "$DOC" "O que NÃO foi feito:"
append_line "$DOC" "- Não foi alterado teclado."
append_line "$DOC" "- Não foi alterado localectl."
append_line "$DOC" "- Não foi alterado /etc/vconsole.conf."
append_line "$DOC" "- Não foi removido SDDM nem qualquer outro pacote."
append_line "$DOC" "- Não foi usado X11 como fallback."
append_line "$DOC" "- Não foi reiniciado o login manager durante a sessão atual."
append_line "$DOC" ""
append_line "$DOC" "Validação final antes do reboot:"
append_line "$DOC" "- display-manager.service -> $FINAL_TARGET"
append_line "$DOC" "- plasmalogin.service is-enabled -> $PLM_ENABLED"
append_line "$DOC" "- default target -> $DEFAULT_TARGET"
append_line "$DOC" ""
append_line "$DOC" "Arquivos gerados:"
append_line "$DOC" "- Log: $LOG"
append_line "$DOC" "- Auditoria: $REPORT"
append_line "$DOC" "- Script de verificação pós-boot: $VERIFY_SCRIPT"

MANUAL="$(find "$DOC_DIR" -maxdepth 1 -type f \( -iname '*manual*mocha*.md' -o -iname '*montagem*mocha*.md' -o -iname '*mocha*manual*.md' \) -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2- || true)"
if [ -n "${MANUAL:-}" ] && [ -f "$MANUAL" ]; then
  say "Acrescentando entrada pendente ao manual existente"
  append_line "$MANUAL" ""
  append_line "$MANUAL" "## $TS - Login manager Plasma Login Manager aplicado, pendente de validação pós-boot"
  append_line "$MANUAL" ""
  append_line "$MANUAL" "- Aplicado plasmalogin.service como display-manager.service."
  append_line "$MANUAL" "- Não houve alteração de teclado."
  append_line "$MANUAL" "- Não houve remoção de pacotes."
  append_line "$MANUAL" "- Não houve uso de X11 como fallback."
  append_line "$MANUAL" "- Verificação pós-boot: $VERIFY_SCRIPT"
else
  say "Manual existente não encontrado por nome; mantendo documentação desta etapa em arquivo próprio"
fi

say "Salvando cópia reutilizável do script aplicado"
cp -f "$0" "$FINAL_SCRIPT"
chmod +x "$FINAL_SCRIPT"

say "Resumo final"
printf 'OK: Plasma Login Manager ficou configurado para o próximo boot.\n'
printf 'NÃO reiniciei a sessão atual.\n'
printf 'NÃO alterei teclado.\n'
printf 'NÃO removi pacotes.\n'
printf 'Log: %s\n' "$LOG"
printf 'Auditoria: %s\n' "$REPORT"
printf 'Documento: %s\n' "$DOC"
printf 'Script reutilizável: %s\n' "$FINAL_SCRIPT"
printf 'Verificação pós-boot: %s\n' "$VERIFY_SCRIPT"
printf '\nDepois de reiniciar e entrar no KDE, rode:\n'
printf '%s\n' "$VERIFY_SCRIPT"
