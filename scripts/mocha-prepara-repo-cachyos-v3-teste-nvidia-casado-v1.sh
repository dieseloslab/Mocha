#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

TS="$(date +%Y%m%d-%H%M%S)"
WORK="$HOME/.local/share/mocha/prepara-repo-cachyos-v3-$TS"
LOG="$WORK/run.log"
PACMAN_CONF="/etc/pacman.conf"
BACKUP="$WORK/pacman.conf.before"

mkdir -p "$WORK"
exec > >(tee -a "$LOG") 2>&1

SUDO_KEEPALIVE_PID=""
(
  while true; do
    sudo -n true || exit
    sleep 30
  done
) &
SUDO_KEEPALIVE_PID="$!"

cleanup() {
  set +e
  [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*"; exit 1; }

printf '\n============================================================\n'
printf ' Mocha — preparar repo CachyOS v3 para teste NVIDIA casado\n'
printf '============================================================\n\n'

if ! /lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v3 (supported'; then
  fail "CPU/libc não reportou x86-64-v3 suportado. Não vou habilitar repo v3."
fi
ok "CPU compatível com x86-64-v3."

sudo cp -a "$PACMAN_CONF" "$BACKUP"
ok "Backup salvo em: $BACKUP"

ok "Importando chave do repositório CachyOS."
sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key F3B607488DB35A47

ok "Instalando keyring/mirrorlists oficiais do CachyOS sem instalar pacman do CachyOS."
sudo pacman -U --needed --noconfirm \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-27-1-any.pkg.tar.zst'

if grep -q '^\[cachyos-v3\]' "$PACMAN_CONF"; then
  ok "Repo cachyos-v3 já existe no pacman.conf."
else
  ok "Adicionando repos CachyOS v3 no FINAL do pacman.conf para reduzir risco de conversão."
  {
    printf '\n'
    printf '# --- Mocha teste CachyOS v3 NVIDIA casado: inicio ---\n'
    printf '# Repos adicionados embaixo de core/extra/multilib de propósito.\n'
    printf '# Não adicionar [cachyos] aqui para evitar pacman modificado do CachyOS.\n'
    printf '[cachyos-v3]\n'
    printf 'Include = /etc/pacman.d/cachyos-v3-mirrorlist\n'
    printf '\n'
    printf '[cachyos-core-v3]\n'
    printf 'Include = /etc/pacman.d/cachyos-v3-mirrorlist\n'
    printf '\n'
    printf '[cachyos-extra-v3]\n'
    printf 'Include = /etc/pacman.d/cachyos-v3-mirrorlist\n'
    printf '# --- Mocha teste CachyOS v3 NVIDIA casado: fim ---\n'
  } | sudo tee -a "$PACMAN_CONF" >/dev/null
fi

ok "Sincronizando bases."
sudo pacman -Sy

printf '\nRepos CachyOS detectados:\n'
grep -nE '^\[(cachyos-v3|cachyos-core-v3|cachyos-extra-v3)\]' "$PACMAN_CONF" || true

printf '\nPacotes de teste disponíveis:\n'
pacman -Si linux-cachyos linux-cachyos-nvidia-open linux-cachyos-lts linux-cachyos-lts-nvidia-open nvidia-utils lib32-nvidia-utils 2>/dev/null \
  | awk '
    /^Repository/ || /^Name/ || /^Version/ || /^Description/ || /^Depends On/ {print}
  '

printf '\n============================================================\n'
printf ' RESULTADO\n'
printf '============================================================\n\n'
ok "Repo v3 preparado para o teste."
ok "Nenhum manual foi alterado."
ok "Nenhum pacman do CachyOS foi instalado propositalmente."
ok "Log: $LOG"

printf '\nAgora rode novamente:\n'
printf '  /media/mochafast/MochaArch/scripts/mocha-testa-cachyos-nvidia-open-casado-v1.sh run\n'
