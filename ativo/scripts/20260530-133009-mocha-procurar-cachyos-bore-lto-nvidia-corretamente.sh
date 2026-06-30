#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
REAL_USER="${SUDO_USER:-$USER}"
REAL_GROUP="$(id -gn "$REAL_USER")"

FAST_BASE="/media/mochafast/MochaArch"
DOC_DIR="$FAST_BASE/ativo/documentacao"
SCRIPT_DIR="$FAST_BASE/ativo/scripts"
REPORT_DIR="$FAST_BASE/ativo/relatorios"

LOG="$REPORT_DIR/${TS}-procurar-cachyos-bore-lto-nvidia-corretamente.log"
DOC="$DOC_DIR/${TS}-procurar-cachyos-bore-lto-nvidia-corretamente.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-procurar-cachyos-bore-lto-nvidia-corretamente.sh"

PACMAN_CONF="/etc/pacman.conf"

say() { printf '\n== %s ==\n' "$*"; }
fail() { printf '\nERRO: %s\n' "$*" >&2; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || fail "Comando obrigatório ausente: $1"; }

need_cmd sudo
need_cmd pacman
need_cmd pacman-conf
need_cmd grep
need_cmd awk
need_cmd sed
need_cmd findmnt
need_cmd tee
need_cmd install
need_cmd uname
need_cmd cp

findmnt /media/mochafast >/dev/null || fail "/media/mochafast não está montado."
findmnt /media/vmstore >/dev/null || fail "/media/vmstore não está montado."

sudo -v
while true; do sudo -n true 2>/dev/null || exit; sleep 45; done &
SUDO_KEEPALIVE_PID="$!"
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

sudo install -d -o "$REAL_USER" -g "$REAL_GROUP" "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Auditoria corrigida: procurar pacotes CachyOS sem instalar"
date
uname -a
printf 'Log: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
printf 'Script salvo: %s\n' "$SCRIPT_COPY"
printf 'Ação: somente sincronizar bases e consultar pacotes.\n'
printf 'Não instala pacotes.\n'
printf 'Não remove pacotes.\n'
printf 'Não muda bootloader.\n'
printf 'Não reinicia.\n'

say "Architecture efetiva do pacman"
pacman-conf Architecture || true

ARCH_NOW="$(pacman-conf Architecture || true)"
printf '%s\n' "$ARCH_NOW" | grep -qw 'x86_64' || fail "Architecture não contém x86_64."
printf '%s\n' "$ARCH_NOW" | grep -qw 'x86_64_v3' || fail "Architecture não contém x86_64_v3."

say "Blocos CachyOS no pacman.conf"
grep -nE 'BEGIN MOCHA TESTE CACHYOS|END MOCHA TESTE CACHYOS|^\[cachyos.*v3\]' "$PACMAN_CONF" || fail "Não encontrei os blocos CachyOS v3 no pacman.conf."

say "Repositórios vistos pelo pacman-conf"
pacman-conf --repo-list | grep -E '^cachyos|^core$|^extra$|^multilib$' || true

say "Sincronizando SOMENTE as bases dos repositórios"
printf '%s\n' "Isto baixa/atualiza bancos de pacotes. Não instala e não atualiza pacote nenhum."
sudo pacman -Sy --noconfirm

say "Confirmando bancos CachyOS locais"
ls -lh /var/lib/pacman/sync/ | grep -E 'cachyos|core|extra|multilib' || true

say "Procurando nomes reais nos repositórios CachyOS"
for repo in cachyos-v3 cachyos-core-v3 cachyos-extra-v3; do
  printf '\n-- %s --\n' "$repo"
  pacman -Sl "$repo" 2>/dev/null | awk '{print $1 "/" $2 " " $3}' \
    | grep -E '/(linux-cachyos-bore-lto|linux-cachyos-bore-lto-headers|linux-cachyos-bore-lto-nvidia-open|nvidia-utils|lib32-nvidia-utils|nvidia-open-dkms|nvidia-open)( |$)' \
    || true
done

say "Consulta direta dos pacotes esperados"
CANDIDATES=(
  "cachyos-v3/linux-cachyos-bore-lto"
  "cachyos-v3/linux-cachyos-bore-lto-headers"
  "cachyos-v3/linux-cachyos-bore-lto-nvidia-open"
  "cachyos-v3/nvidia-utils"
  "cachyos-v3/lib32-nvidia-utils"
  "cachyos-v3/nvidia-open-dkms"
  "cachyos-extra-v3/nvidia-open"
)

FOUND_ANY=0

for pkg in "${CANDIDATES[@]}"; do
  printf '\n==== %s ====\n' "$pkg"
  if pacman -Si "$pkg" >/tmp/mocha-pkginfo-"$TS".txt 2>/tmp/mocha-pkgerr-"$TS".txt; then
    FOUND_ANY=1
    awk '
      /^(Repository|Name|Version|Description|Depends On|Provides|Conflicts With|Replaces)[[:space:]]*:/ {
        print
        keep=1
        next
      }
      keep == 1 && /^[[:space:]]/ {
        print
        next
      }
      keep == 1 && /^[^[:space:]]/ {
        keep=0
      }
    ' /tmp/mocha-pkginfo-"$TS".txt
  else
    printf 'NAO_ENCONTRADO_LOCALMENTE\n'
    cat /tmp/mocha-pkgerr-"$TS".txt || true
  fi
done

say "Estado instalado atual"
pacman -Q \
  linux \
  linux-headers \
  linux-zen \
  linux-zen-headers \
  linux-cachyos-bore-lto \
  linux-cachyos-bore-lto-headers \
  linux-cachyos-bore-lto-nvidia-open \
  nvidia-utils \
  lib32-nvidia-utils \
  nvidia-open-dkms \
  nvidia-open \
  2>/dev/null || true

say "Estado DKMS atual"
if command -v dkms >/dev/null 2>&1; then
  dkms status || true
else
  printf '%s\n' "dkms não encontrado."
fi

say "Módulos NVIDIA carregados agora"
uname -r
lsmod | grep -E '^nvidia' || true

say "Gerando documento"
{
  printf '# Auditoria Mocha Arch — procura correta do CachyOS BORE LTO NVIDIA\n\n'
  printf 'Timestamp: %s\n\n' "$TS"
  printf '## O que este comando fez\n\n'
  printf -- '- Sincronizou somente as bases dos repositórios com `pacman -Sy`.\n'
  printf -- '- Procurou os pacotes reais em `cachyos-v3`, `cachyos-core-v3` e `cachyos-extra-v3`.\n'
  printf -- '- Não instalou pacote nenhum.\n'
  printf -- '- Não removeu pacote nenhum.\n'
  printf -- '- Não mudou bootloader.\n'
  printf -- '- Não reiniciou.\n\n'
  printf '## Pacotes procurados\n\n'
  printf -- '- linux-cachyos-bore-lto\n'
  printf -- '- linux-cachyos-bore-lto-headers\n'
  printf -- '- linux-cachyos-bore-lto-nvidia-open\n'
  printf -- '- nvidia-utils\n'
  printf -- '- lib32-nvidia-utils\n'
  printf -- '- nvidia-open-dkms\n'
  printf -- '- nvidia-open\n\n'
  printf '## Próxima decisão\n\n'
  printf 'Se os pacotes aparecerem, a instalação real deve ser feita em comando separado, preservando kernel atual e sem mudar default de boot automaticamente.\n\n'
  printf '## Arquivos\n\n'
  printf -- '- Log: %s\n' "$LOG"
  printf -- '- Script salvo: %s\n' "$SCRIPT_COPY"
} > "$DOC"

cp -a "$0" "$SCRIPT_COPY"

say "Resultado final"
if [ "$FOUND_ANY" -eq 1 ]; then
  printf '%s\n' "Pacotes encontrados localmente após sincronizar as bases."
else
  printf '%s\n' "Nenhum pacote candidato foi encontrado localmente, apesar dos repositórios estarem configurados."
  printf '%s\n' "Nesse caso, o problema é mirror/base local/configuração do repo, não inexistência do pacote."
fi

printf 'Log: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
printf 'Script salvo: %s\n' "$SCRIPT_COPY"
