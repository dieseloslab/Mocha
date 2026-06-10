#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
FAST_BASE="/media/mochafast/MochaArch"

if findmnt -rn /media/mochafast >/dev/null 2>&1 && [ -d "$FAST_BASE/ativo" ]; then
  REPORT_DIR="$FAST_BASE/ativo/relatorios"
  DOC_DIR="$FAST_BASE/ativo/documentacao"
  SCRIPT_DIR="$FAST_BASE/ativo/scripts"
else
  REPORT_DIR="/tmp"
  DOC_DIR="/tmp"
  SCRIPT_DIR="/tmp"
fi

mkdir -p "$REPORT_DIR" "$DOC_DIR" "$SCRIPT_DIR"

LOG="$REPORT_DIR/${TS}-finalizar-boot-cachyos-bore-lto-nvidia-grub-revisado.log"
DOC="$DOC_DIR/${TS}-finalizar-boot-cachyos-bore-lto-nvidia-grub-revisado.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-finalizar-boot-cachyos-bore-lto-nvidia-grub-revisado.sh"

exec > >(tee -a "$LOG") 2>&1

say() {
  printf '\n== %s ==\n' "$*"
}

warn() {
  printf '\nAVISO: %s\n' "$*" >&2
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  printf 'Log: %s\n' "$LOG" >&2
  printf 'Não reinicie enquanto houver ERRO.\n' >&2
  exit 1
}

say "Pedindo sudo uma vez e mantendo sessão ativa"
sudo -v
while true; do
  sudo -n true 2>/dev/null || exit 0
  sleep 25
done &
KEEPALIVE_PID="$!"
trap 'kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT

say "Estado atual, sem tratar nvidia-smi do Zen como erro"
uname -r || true
pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-headers linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils 2>/dev/null || true
nvidia-smi || true

say "Validando pacotes obrigatórios já instalados"
for pkg in linux-cachyos-bore-lto linux-cachyos-bore-lto-headers linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils; do
  pacman -Q "$pkg" >/dev/null 2>&1 || fail "Pacote não instalado: $pkg"
done

say "Detectando kernel CachyOS Bore LTO instalado"
CACHY_KVER="$({
  find /usr/lib/modules -maxdepth 1 -mindepth 1 -type d -printf '%f\n' 2>/dev/null || true
} | awk 'tolower($0) ~ /cachyos/ && tolower($0) ~ /bore/ && tolower($0) ~ /lto/ { print }' | sort -V | tail -n1)"

[ -n "${CACHY_KVER:-}" ] || fail "Não encontrei diretório do kernel CachyOS Bore LTO em /usr/lib/modules."
CACHY_MODDIR="/usr/lib/modules/$CACHY_KVER"
[ -d "$CACHY_MODDIR" ] || fail "Diretório inexistente: $CACHY_MODDIR"

printf 'Kernel CachyOS detectado: %s\n' "$CACHY_KVER"
printf 'Diretório de módulos: %s\n' "$CACHY_MODDIR"

say "Conferindo módulos NVIDIA kernel-específicos do CachyOS"
NVIDIA_FILES="$(find "$CACHY_MODDIR" -type f -name 'nvidia*.ko*' -print 2>/dev/null | sort || true)"
printf '%s\n' "$NVIDIA_FILES"
[ -n "$NVIDIA_FILES" ] || fail "Não encontrei módulos nvidia*.ko* em $CACHY_MODDIR."

printf '%s\n' "$NVIDIA_FILES" | grep -Eq '/nvidia\.ko(\.|$)' || fail "Faltou nvidia.ko para $CACHY_KVER."
printf '%s\n' "$NVIDIA_FILES" | grep -Eq '/nvidia[-_]modeset\.ko(\.|$)' || fail "Faltou nvidia-modeset.ko para $CACHY_KVER."
printf '%s\n' "$NVIDIA_FILES" | grep -Eq '/nvidia[-_]uvm\.ko(\.|$)' || fail "Faltou nvidia-uvm.ko para $CACHY_KVER."
printf '%s\n' "$NVIDIA_FILES" | grep -Eq '/nvidia[-_]drm\.ko(\.|$)' || fail "Faltou nvidia-drm.ko para $CACHY_KVER."

say "Atualizando dependências de módulos somente para o kernel CachyOS"
sudo depmod -a "$CACHY_KVER"

say "Validando modinfo NVIDIA no kernel CachyOS"
for mod in nvidia nvidia_modeset nvidia_uvm nvidia_drm; do
  modinfo -k "$CACHY_KVER" "$mod" >/dev/null 2>&1 || fail "modinfo não localizou $mod para $CACHY_KVER."
  printf 'OK: modinfo -k %s %s\n' "$CACHY_KVER" "$mod"
done

NVIDIA_MODULE_VERSION="$(modinfo -k "$CACHY_KVER" -F version nvidia 2>/dev/null | head -n1 | tr -d '[:space:]')"
NVIDIA_UTILS_VERSION="$(pacman -Q nvidia-utils | awk '{print $2}' | sed -E 's/^[0-9]+://; s/-[^-]+$//')"
LIB32_NVIDIA_UTILS_VERSION="$(pacman -Q lib32-nvidia-utils | awk '{print $2}' | sed -E 's/^[0-9]+://; s/-[^-]+$//')"

printf 'Versão módulo NVIDIA: %s\n' "$NVIDIA_MODULE_VERSION"
printf 'Versão nvidia-utils: %s\n' "$NVIDIA_UTILS_VERSION"
printf 'Versão lib32-nvidia-utils: %s\n' "$LIB32_NVIDIA_UTILS_VERSION"

[ "$NVIDIA_MODULE_VERSION" = "$NVIDIA_UTILS_VERSION" ] || fail "Versão do módulo NVIDIA ($NVIDIA_MODULE_VERSION) difere de nvidia-utils ($NVIDIA_UTILS_VERSION)."
[ "$NVIDIA_MODULE_VERSION" = "$LIB32_NVIDIA_UTILS_VERSION" ] || fail "Versão do módulo NVIDIA ($NVIDIA_MODULE_VERSION) difere de lib32-nvidia-utils ($LIB32_NVIDIA_UTILS_VERSION)."

say "Garantindo NVIDIA Wayland/KMS e bloqueio do nouveau"
sudo mkdir -p /etc/modprobe.d
printf '%s\n' \
  '# Mocha Arch - NVIDIA open / Wayland KMS' \
  'options nvidia NVreg_PreserveVideoMemoryAllocations=1' \
  'options nvidia_drm modeset=1 fbdev=1' \
  'blacklist nouveau' \
  'options nouveau modeset=0' \
  | sudo tee /etc/modprobe.d/mocha-nvidia-open.conf >/dev/null

say "Gerando initramfs somente do CachyOS Bore LTO"
[ -f /etc/mkinitcpio.d/linux-cachyos-bore-lto.preset ] || fail "Preset ausente: /etc/mkinitcpio.d/linux-cachyos-bore-lto.preset"
sudo mkinitcpio -p linux-cachyos-bore-lto

say "Verificando arquivos de boot do CachyOS Bore LTO"
[ -f /boot/vmlinuz-linux-cachyos-bore-lto ] || fail "Faltou /boot/vmlinuz-linux-cachyos-bore-lto"
[ -f /boot/initramfs-linux-cachyos-bore-lto.img ] || fail "Faltou /boot/initramfs-linux-cachyos-bore-lto.img"
ls -lh /boot/vmlinuz-linux-cachyos-bore-lto /boot/initramfs-linux-cachyos-bore-lto.img

set_grub_var() {
  local key="$1"
  local value="$2"
  local tmp
  tmp="$(mktemp)"

  sudo awk -v key="$key" -v value="$value" '
    BEGIN { done = 0 }
    $0 ~ "^" key "=" {
      print key "=" value
      done = 1
      next
    }
    { print }
    END {
      if (done == 0) {
        print key "=" value
      }
    }
  ' /etc/default/grub > "$tmp"

  sudo install -m 644 "$tmp" /etc/default/grub
  rm -f "$tmp"
}

say "Configurando GRUB com CachyOS Bore LTO como padrão e Zen preservado como fallback"
[ -d /boot/grub ] || fail "/boot/grub não existe. Este comando corrigido é para o GRUB detectado no log anterior."
command -v grub-mkconfig >/dev/null 2>&1 || fail "grub-mkconfig não encontrado."
[ -f /etc/default/grub ] || fail "/etc/default/grub não encontrado."

sudo cp -a /etc/default/grub "/etc/default/grub.bak-${TS}"

CURRENT_CMDLINE="$(
  sudo awk -F= '/^GRUB_CMDLINE_LINUX_DEFAULT=/{print substr($0, index($0, "=")+1)}' /etc/default/grub \
    | tail -n1 \
    | sed -e 's/^"//' -e 's/"$//' || true
)"

for param in nvidia_drm.modeset=1 nvidia_drm.fbdev=1; do
  case " $CURRENT_CMDLINE " in
    *" $param "*) ;;
    *) CURRENT_CMDLINE="${CURRENT_CMDLINE:+$CURRENT_CMDLINE }$param" ;;
  esac
done

set_grub_var GRUB_DEFAULT 0
set_grub_var GRUB_SAVEDEFAULT false
set_grub_var GRUB_TOP_LEVEL '"/boot/vmlinuz-linux-cachyos-bore-lto"'
set_grub_var GRUB_CMDLINE_LINUX_DEFAULT "\"$CURRENT_CMDLINE\""

say "Regenerando GRUB"
sudo grub-mkconfig -o /boot/grub/grub.cfg

say "Conferindo entradas do GRUB com sudo"
sudo awk '
  BEGIN { IGNORECASE = 1; count = 0 }
  /cachyos|bore|lto|linux-cachyos-bore-lto|linux-zen/ {
    printf "%d:%s\n", NR, $0
    count++
    if (count >= 60) exit
  }
' /boot/grub/grub.cfg || true

sudo grep -qiE 'linux-cachyos-bore-lto|cachyos.*bore.*lto|bore.*lto.*cachyos' /boot/grub/grub.cfg || fail "GRUB foi gerado, mas não encontrei entrada do CachyOS Bore LTO."

FIRST_LINUX_LINE="$(sudo awk '
  /^menuentry / && seen == 0 { in_first = 1; seen = 1; next }
  in_first == 1 && /^[[:space:]]*linux[[:space:]]/ { print; exit }
' /boot/grub/grub.cfg || true)"

printf 'Primeira linha linux do primeiro menuentry: %s\n' "${FIRST_LINUX_LINE:-NÃO ENCONTRADA}"
printf '%s\n' "$FIRST_LINUX_LINE" | grep -q 'vmlinuz-linux-cachyos-bore-lto' || fail "A primeira entrada do GRUB não aponta para vmlinuz-linux-cachyos-bore-lto."

if pacman -Q linux-zen >/dev/null 2>&1; then
  sudo grep -qi 'vmlinuz-linux-zen' /boot/grub/grub.cfg || fail "linux-zen está instalado, mas não apareceu no GRUB como fallback."
  echo "OK: Zen continua presente como fallback."
else
  warn "linux-zen não está instalado; nada a preservar como fallback Zen."
fi

say "Preservando no máximo 2 backups de GRUB"
while IFS= read -r old; do
  [ -n "$old" ] && sudo rm -f "$old"
done < <(ls -1t /etc/default/grub.bak-* 2>/dev/null | tail -n +3 || true)

say "Gravando documentação operacional"
: > "$DOC"
append_doc() {
  printf '%s\n' "$*" >> "$DOC"
}

append_doc "# Mocha Arch - finalização revisada do boot CachyOS Bore LTO + NVIDIA open"
append_doc ""
append_doc "Data: $TS"
append_doc ""
append_doc "## O que foi corrigido"
append_doc ""
append_doc "- O erro anterior era a leitura de /boot/grub/grub.cfg sem sudo na etapa de verificação."
append_doc "- O GRUB foi regenerado com verificação privilegiada."
append_doc "- CachyOS Bore LTO foi colocado como primeira entrada via GRUB_TOP_LEVEL."
append_doc "- Zen foi preservado como fallback quando instalado."
append_doc "- mkinitcpio foi executado somente para linux-cachyos-bore-lto."
append_doc "- Nenhum pacote foi removido."
append_doc ""
append_doc "## Kernel e NVIDIA"
append_doc ""
append_doc "Kernel CachyOS detectado: $CACHY_KVER"
append_doc "Versão módulo NVIDIA: $NVIDIA_MODULE_VERSION"
append_doc "Versão nvidia-utils: $NVIDIA_UTILS_VERSION"
append_doc "Versão lib32-nvidia-utils: $LIB32_NVIDIA_UTILS_VERSION"
append_doc ""
append_doc "## Validação pós-reboot"
append_doc ""
append_doc "Rodar:"
append_doc ""
append_doc "uname -r"
append_doc "nvidia-smi"
append_doc "pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils"
append_doc ""
append_doc "Esperado:"
append_doc ""
append_doc "- uname -r deve mostrar o kernel CachyOS Bore LTO."
append_doc "- nvidia-smi deve funcionar."
append_doc "- Zen deve continuar disponível como fallback no GRUB."

cp -f "$0" "$SCRIPT_COPY" 2>/dev/null || true

say "Resumo final"
echo "Log: $LOG"
echo "Documento: $DOC"
echo "Script salvo: $SCRIPT_COPY"
echo
echo "OK: se não apareceu ERRO acima, pode reiniciar."
echo "Depois do reboot, rode:"
echo "  uname -r"
echo "  nvidia-smi"
echo "  pacman -Q linux-cachyos-bore-lto linux-cachyos-bore-lto-nvidia-open nvidia-utils lib32-nvidia-utils"
