#!/usr/bin/env bash
set -Eeuo pipefail

export LC_ALL=C
export PAGER=cat
export SYSTEMD_PAGER=cat
export CARGO_TERM_COLOR=always

RAIZ="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
DATA="$(date '+%Y%m%d-%H%M%S')"
BACKUP="/var/backups/mocha/mocha-update-install-${DATA}"
RELATORIO="$RAIZ/mocha-update-install-${DATA}.log"
KEEPALIVE_PID=''

encerra_keepalive() {
    if [[ -n "$KEEPALIVE_PID" ]]; then
        kill "$KEEPALIVE_PID" 2>/dev/null || true
        wait "$KEEPALIVE_PID" 2>/dev/null || true
    fi
}
trap encerra_keepalive EXIT

cd -- "$RAIZ"
exec > >(tee -a "$RELATORIO") 2>&1

falha() {
    printf '\nERRO: %s\n' "$*" >&2
    printf 'RELATORIO=%s\n' "$RELATORIO" >&2
    exit 1
}

printf '%s\n' '============================================================'
printf '%s\n' 'MOCHA UPDATE — COMPILAÇÃO E INSTALAÇÃO LOCAL'
printf '%s\n' '============================================================'
printf 'RAIZ=%s\n' "$RAIZ"
printf 'BACKUP=%s\n' "$BACKUP"
printf 'RELATORIO=%s\n' "$RELATORIO"
printf '%s\n' 'INTERFACE_APROVADA=PRESERVADA'
printf '%s\n' 'BACKEND_REAL=SIM'
printf '%s\n' 'REPOSITORIO_KERNEL=mocha-kernel'
printf '%s\n' 'USA_LINUX_LQX=NAO'
printf '%s\n' 'ATUALIZA_PROPRIO_APLICATIVO=NAO'
printf '%s\n' 'MOCHA_OC=GAMEMODE_CORE_50_MEMORY_400'

for ferramenta in cargo rustfmt sudo pkg-config; do
    command -v "$ferramenta" >/dev/null 2>&1 || falha "$ferramenta não encontrado"
done

pkg-config --exists Qt6Core Qt6Gui Qt6Qml Qt6Quick || \
    falha 'módulos de desenvolvimento Qt 6 incompletos'

FERRAMENTAS_RUNTIME=(
    /usr/bin/pkexec
    /usr/bin/pacman
    /usr/bin/checkupdates
    /usr/bin/vercmp
    /usr/bin/dkms
    /usr/bin/mkinitcpio
    /usr/bin/grub-mkconfig
    /usr/bin/findmnt
    /usr/bin/lvs
    /usr/bin/lvcreate
    /usr/bin/lvconvert
    /usr/bin/lvremove
    /usr/bin/gpg
    /usr/bin/sync
    /usr/bin/date
    /usr/bin/nvidia-settings
    /usr/bin/gamemoded
    /usr/bin/runuser
    /usr/bin/env
    /usr/bin/visudo
)
for ferramenta in "${FERRAMENTAS_RUNTIME[@]}"; do
    [[ -x "$ferramenta" ]] || falha "ferramenta operacional ausente: $ferramenta"
done

bash -n data/mocha-oc/mocha-nvidia-oc-root-helper
/usr/bin/visudo -cf data/sudoers.d/mocha-nvidia-oc-root-helper >/dev/null
[[ -f /etc/gamemode.ini ]] || falha '/etc/gamemode.ini ausente'

# A cadeia OC legacy não é distribuída por este instalador e não pode
# bloquear a instalação do Mocha Update. Os artefatos OC próprios continuam
# sendo compilados e instalados normalmente nas etapas abaixo.
printf 'CADEIA_OC_LEGACY=FORA_DO_ESCOPO_DESTA_INSTALACAO\n'

printf '\n1. FORMATAÇÃO, TESTES E COMPILAÇÃO\n'
command -v cc >/dev/null 2>&1 || falha 'compilador C ausente para o backend NVML'
mkdir -p -- target/release
cc -O2 -std=c11 -Wall -Wextra -Werror \
    data/mocha-oc/mocha-nvidia-oc-nvml.c \
    -ldl \
    -o target/release/mocha-nvidia-oc-nvml
chmod 0755 target/release/mocha-nvidia-oc-nvml
cargo fmt --all
cargo test --all-targets
cargo build --release --bins

test -x target/release/mocha-update || falha 'binário gráfico não foi produzido'
test -x target/release/mocha-update-helper || falha 'helper administrativo não foi produzido'

printf '\n2. AUTORIZAÇÃO ADMINISTRATIVA\n'
sudo -v
(
    while true; do
        sleep 45
        sudo -n true 2>/dev/null || exit 0
    done
) &
KEEPALIVE_PID=$!

printf '\n3. BACKUP DA INSTALAÇÃO ANTERIOR\n'
sudo install -d -m 0700 "$BACKUP"
for arquivo in \
    /usr/bin/mocha-update \
    /usr/lib/mocha-update/mocha-update-helper \
    /usr/share/polkit-1/actions/org.mocha.update.policy \
    /usr/share/applications/org.mocha.update.desktop \
    /usr/local/lib/mocha/mocha-nvidia-oc-root-helper \
    /usr/local/lib/mocha/mocha-nvidia-oc-nvml \
    /etc/sudoers.d/mocha-nvidia-oc-root-helper
do
    if sudo test -e "$arquivo"; then
        sudo cp -a --parents -- "$arquivo" "$BACKUP/"
        printf 'BACKUP_ARQUIVO=%s\n' "$arquivo"
    fi
done

printf '\n4. INSTALAÇÃO ATÔMICA DOS ARTEFATOS\n'
sudo install -d -m 0755 /usr/lib/mocha-update
sudo install -d -m 0755 /usr/local/lib/mocha
sudo install -d -m 0750 /etc/sudoers.d
sudo install -d -m 0755 /var/lib/mocha-update/rollbacks
sudo install -d -m 0755 /var/log/mocha-update

sudo install -o root -g root -m 0755 \
    target/release/mocha-update \
    /usr/bin/.mocha-update.new
sudo install -o root -g root -m 0755 \
    target/release/mocha-update-helper \
    /usr/lib/mocha-update/.mocha-update-helper.new
sudo install -o root -g root -m 0644 \
    data/polkit-1/actions/org.mocha.update.policy \
    /usr/share/polkit-1/actions/.org.mocha.update.policy.new
sudo install -o root -g root -m 0644 \
    data/applications/org.mocha.update.desktop \
    /usr/share/applications/.org.mocha.update.desktop.new
sudo install -o root -g root -m 0755 \
    data/mocha-oc/mocha-nvidia-oc-root-helper \
    /usr/local/lib/mocha/.mocha-nvidia-oc-root-helper.new
sudo install -o root -g root -m 0440 \
    data/sudoers.d/mocha-nvidia-oc-root-helper \
    /etc/sudoers.d/.mocha-nvidia-oc-root-helper.new
sudo /usr/bin/visudo -cf /etc/sudoers.d/.mocha-nvidia-oc-root-helper.new >/dev/null

sudo install -o root -g root -m 0755 \
    target/release/mocha-nvidia-oc-nvml \
    /usr/local/lib/mocha/.mocha-nvidia-oc-nvml.new

sudo mv -f -- /usr/bin/.mocha-update.new /usr/bin/mocha-update
sudo mv -f -- \
    /usr/lib/mocha-update/.mocha-update-helper.new \
    /usr/lib/mocha-update/mocha-update-helper
sudo mv -f -- \
    /usr/share/polkit-1/actions/.org.mocha.update.policy.new \
    /usr/share/polkit-1/actions/org.mocha.update.policy
sudo mv -f -- \
    /usr/share/applications/.org.mocha.update.desktop.new \
    /usr/share/applications/org.mocha.update.desktop
sudo mv -f -- \
    /usr/local/lib/mocha/.mocha-nvidia-oc-root-helper.new \
    /usr/local/lib/mocha/mocha-nvidia-oc-root-helper
sudo mv -f -- \
    /etc/sudoers.d/.mocha-nvidia-oc-root-helper.new \
    /etc/sudoers.d/mocha-nvidia-oc-root-helper

sudo mv -f -- \
    /usr/local/lib/mocha/.mocha-nvidia-oc-nvml.new \
    /usr/local/lib/mocha/mocha-nvidia-oc-nvml

if command -v update-desktop-database >/dev/null 2>&1; then
    sudo update-desktop-database /usr/share/applications
fi

printf '\n5. VALIDAÇÃO DA INSTALAÇÃO\n'
sudo test -O /usr/bin/mocha-update
sudo test -O /usr/local/lib/mocha/mocha-nvidia-oc-nvml
sudo test "$(sudo stat -c '%a' /usr/local/lib/mocha/mocha-nvidia-oc-nvml)" = 755
sudo /usr/local/lib/mocha/mocha-nvidia-oc-nvml status |
    grep -Fxq 'STATUS_BACKEND=NVML'
sudo test -O /usr/lib/mocha-update/mocha-update-helper
sudo test -O /usr/share/polkit-1/actions/org.mocha.update.policy
sudo test -O /usr/share/applications/org.mocha.update.desktop
sudo test -O /usr/local/lib/mocha/mocha-nvidia-oc-root-helper
sudo test -O /etc/sudoers.d/mocha-nvidia-oc-root-helper
sudo test "$(sudo stat -c '%a' /usr/bin/mocha-update)" = 755
sudo test "$(sudo stat -c '%a' /usr/lib/mocha-update/mocha-update-helper)" = 755
sudo test "$(sudo stat -c '%a' /usr/share/polkit-1/actions/org.mocha.update.policy)" = 644
sudo test "$(sudo stat -c '%a' /usr/share/applications/org.mocha.update.desktop)" = 644
sudo test "$(sudo stat -c '%a' /usr/local/lib/mocha/mocha-nvidia-oc-root-helper)" = 755
sudo test "$(sudo stat -c '%a' /etc/sudoers.d/mocha-nvidia-oc-root-helper)" = 440
sudo /usr/bin/visudo -cf /etc/sudoers.d/mocha-nvidia-oc-root-helper >/dev/null

sha256sum \
    target/release/mocha-update \
    target/release/mocha-update-helper
sudo sha256sum \
    /usr/bin/mocha-update \
    /usr/lib/mocha-update/mocha-update-helper \
    /usr/local/lib/mocha/mocha-nvidia-oc-root-helper

printf '%s\n' '============================================================'

# MOCHA_UPDATE_V7_BOOT_RESTORE_BEGIN
sudo install -d -o root -g root -m 0755 \
    /usr/lib/mocha-update \
    /usr/lib/systemd/system

sudo install -o root -g root -m 0755 \
    data/mocha-rollback/mocha-boot-restore \
    /usr/lib/mocha-update/.mocha-boot-restore.new

sudo install -o root -g root -m 0644 \
    data/systemd/system/mocha-update-boot-restore.service \
    /usr/lib/systemd/system/.mocha-update-boot-restore.service.new

sudo mv -f -- \
    /usr/lib/mocha-update/.mocha-boot-restore.new \
    /usr/lib/mocha-update/mocha-boot-restore

sudo mv -f -- \
    /usr/lib/systemd/system/.mocha-update-boot-restore.service.new \
    /usr/lib/systemd/system/mocha-update-boot-restore.service

sudo systemctl daemon-reload
sudo systemctl enable mocha-update-boot-restore.service >/dev/null

sudo test -x /usr/lib/mocha-update/mocha-boot-restore
sudo test "$(sudo stat -c '%a' /usr/lib/mocha-update/mocha-boot-restore)" = 755
sudo test -f /usr/lib/systemd/system/mocha-update-boot-restore.service
sudo test "$(sudo stat -c '%a' /usr/lib/systemd/system/mocha-update-boot-restore.service)" = 644
sudo systemctl is-enabled mocha-update-boot-restore.service >/dev/null
# MOCHA_UPDATE_V7_BOOT_RESTORE_END

printf '%s\n' 'ETAPA_BASE=SUCESSO'
printf '%s\n' 'EXECUTAVEL=/usr/bin/mocha-update'
printf '%s\n' 'HELPER=/usr/lib/mocha-update/mocha-update-helper'
printf '%s\n' 'POLKIT=org.mocha.update.manage'
printf '%s\n' 'MOCHA_OC_HELPER=/usr/local/lib/mocha/mocha-nvidia-oc-root-helper'
printf 'BACKUP=%s\n' "$BACKUP"
printf 'RELATORIO=%s\n' "$RELATORIO"
printf '%s\n' '============================================================'

# MOCHA_UPDATE_R2_RUNTIME_BEGIN
sudo install -d -o root -g root -m 0755 \
    /usr/lib/mocha-update \
    /etc/mocha-update \
    /usr/share/mocha-update/keys

sudo install -o root -g root -m 0755 \
    target/release/mocha-update-catalog-check \
    /usr/lib/mocha-update/.mocha-update-catalog-check.new
sudo install -o root -g root -m 0755 \
    data/update/mocha-update-r2-check \
    /usr/lib/mocha-update/.mocha-update-r2-check.new
sudo install -o root -g root -m 0644 \
    config/update-components-v1.json \
    /etc/mocha-update/.update-components-v1.json.new
sudo install -o root -g root -m 0644 \
    data/update/update-endpoint.conf \
    /etc/mocha-update/.update-endpoint.conf.new
sudo install -o root -g root -m 0644 \
    data/update/keys/mocha-release-signing.gpg \
    /usr/share/mocha-update/keys/.mocha-release-signing.gpg.new
sudo install -o root -g root -m 0644 \
    data/update/keys/mocha-release-signing-public.asc \
    /usr/share/mocha-update/keys/.mocha-release-signing-public.asc.new

sudo mv -f -- /usr/lib/mocha-update/.mocha-update-catalog-check.new \
    /usr/lib/mocha-update/mocha-update-catalog-check
sudo mv -f -- /usr/lib/mocha-update/.mocha-update-r2-check.new \
    /usr/lib/mocha-update/mocha-update-r2-check
sudo mv -f -- /etc/mocha-update/.update-components-v1.json.new \
    /etc/mocha-update/update-components-v1.json
sudo mv -f -- /etc/mocha-update/.update-endpoint.conf.new \
    /etc/mocha-update/update-endpoint.conf
sudo mv -f -- /usr/share/mocha-update/keys/.mocha-release-signing.gpg.new \
    /usr/share/mocha-update/keys/mocha-release-signing.gpg
sudo mv -f -- /usr/share/mocha-update/keys/.mocha-release-signing-public.asc.new \
    /usr/share/mocha-update/keys/mocha-release-signing-public.asc

sudo test -x /usr/lib/mocha-update/mocha-update-catalog-check
sudo test -x /usr/lib/mocha-update/mocha-update-r2-check
sudo test -s /etc/mocha-update/update-components-v1.json
sudo test -s /etc/mocha-update/update-endpoint.conf
sudo test -s /usr/share/mocha-update/keys/mocha-release-signing.gpg
sudo test -s /usr/share/mocha-update/keys/mocha-release-signing-public.asc
sudo gpg --show-keys --with-colons \
    /usr/share/mocha-update/keys/mocha-release-signing-public.asc |
    grep -q '^pub:'

printf 'R2_RUNTIME_INSTALADO=SIM\n'
printf 'RESULTADO=SUCESSO\n'
printf 'EXECUTAVEL=/usr/bin/mocha-update\n'
printf 'HELPER=/usr/lib/mocha-update/mocha-update-helper\n'
printf 'CATALOG_CHECK=/usr/lib/mocha-update/mocha-update-catalog-check\n'
printf 'R2_CHECK=/usr/lib/mocha-update/mocha-update-r2-check\n'
printf 'BACKUP=%s\n' "$BACKUP"
printf 'RELATORIO=%s\n' "$RELATORIO"
printf '%s\n' '============================================================'
# MOCHA_UPDATE_R2_RUNTIME_END
