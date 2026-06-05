#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch/ativo"
DOC_DIR="$BASE/documentacao"
MANUAL="$DOC_DIR/20260529-154304-MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
REPORT_DIR="$BASE/relatorios"
SCRIPTS_DIR="$BASE/scripts"
BACKUP_DIR="$BASE/backups/configs"
TMP_LOG="/tmp/${TS}-mocha-instalar-pacotes-faltantes-wallpaper-cpu-gpu-max.log"

exec > >(tee -a "$TMP_LOG") 2>&1

echo "== MOCHAARCH — pacotes faltantes + wallpaper + CPU/GPU máximo =="
echo "Timestamp: $TS"
echo "Script: $0"
echo "Log temporário: $TMP_LOG"
echo

echo "== 1/12 Sudo com keepalive =="
sudo -v
while true; do
  sudo -n true 2>/dev/null || exit 0
  sleep 45
done &
SUDO_KEEPALIVE_PID="$!"
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
echo "Sudo OK."
echo

echo "== 2/12 Conferindo FAST, VMSTORE e manual vivo =="
for MP in /media/mochafast /media/vmstore; do
  if mountpoint -q "$MP"; then
    echo "$MP: montado."
  else
    echo "$MP: não montado; tentando montar pela entrada existente do /etc/fstab..."
    sudo mount "$MP"
    mountpoint -q "$MP" || {
      echo "ERRO: $MP não montou. Não vou adivinhar disco."
      exit 1
    }
    echo "$MP: montado OK."
  fi
done

if [[ ! -d "$BASE" ]]; then
  echo "ERRO: base ativa não encontrada: $BASE"
  exit 1
fi

mkdir -p "$REPORT_DIR" "$SCRIPTS_DIR" "$BACKUP_DIR"
LOG="$REPORT_DIR/${TS}-pacotes-faltantes-wallpaper-cpu-gpu-max.log"
cp -f "$TMP_LOG" "$LOG" 2>/dev/null || true
exec > >(tee -a "$LOG") 2>&1

if [[ ! -f "$MANUAL" ]]; then
  echo "ERRO: manual vivo não encontrado:"
  echo "$MANUAL"
  exit 1
fi

echo "Manual vivo:"
echo "$MANUAL"
echo
echo "Trechos relevantes do manual:"
grep -nEi 'pacman|pacotes|steam|mangohud|gamemode|tuned|cpupower|performance|agressividade|wallpaper|papel|MochaSolidCanonico|MochaPanelSolidCanonico|sddm|wayland|firewall|cloudflare' "$MANUAL" | head -n 180 || true
echo

backup_file() {
  local src="$1"
  local label="$2"
  local dir="$BACKUP_DIR/$label"
  [[ -e "$src" ]] || return 0
  mkdir -p "$dir"
  local dst="$dir/$(basename "$src").${TS}.bak"
  sudo cp -a "$src" "$dst"
  echo "Backup: $src -> $dst"

  find "$dir" -maxdepth 1 -type f -name "$(basename "$src").*.bak" -printf '%T@ %p\n' \
    | sort -nr \
    | awk 'NR>2 {sub(/^[^ ]+ /,""); print}' \
    | while IFS= read -r old; do
        [[ -n "$old" ]] && sudo rm -f "$old"
      done
}

write_root_file_from_stdin() {
  local target="$1"
  local mode="${2:-0644}"
  local tmp
  tmp="$(mktemp)"
  cat > "$tmp"
  sudo install -D -m "$mode" "$tmp" "$target"
  rm -f "$tmp"
}

echo "== 3/12 Auditoria antes de instalar =="
echo "-- Pacotes críticos instalados:"
pacman -Q \
  tuned cpupower gamemode lib32-gamemode mangohud lib32-mangohud goverlay steam \
  sddm plasma-workspace plasma-desktop kde-cli-tools powerdevil plasma-firewall \
  firewalld flatpak vivaldi bitwarden \
  nvidia-utils lib32-nvidia-utils opencl-nvidia vulkan-tools vulkan-icd-loader lib32-vulkan-icd-loader \
  2>/dev/null | sort || true
echo

echo "-- CPU atual:"
for GOV in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [[ -r "$GOV" ]] && printf '%s: %s\n' "$GOV" "$(cat "$GOV")"
done | head -n 32
echo

echo "-- GPU atual:"
command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi || echo "nvidia-smi indisponível."
echo

echo "== 4/12 Validando pacotes disponíveis nos repositórios ativos =="
CANDIDATES=(
  tuned
  cpupower
  gamemode
  lib32-gamemode
  mangohud
  lib32-mangohud
  goverlay
  steam
  sddm
  plasma-workspace
  plasma-desktop
  kde-cli-tools
  powerdevil
  plasma-firewall
  firewalld
  flatpak
  discover
  packagekit-qt6
  xdg-desktop-portal-kde
  qt6-tools
  vulkan-tools
  vulkan-icd-loader
  lib32-vulkan-icd-loader
  nvidia-utils
  lib32-nvidia-utils
  opencl-nvidia
  nvidia-settings
  egl-wayland
  btrfs-progs
  xfsprogs
  smartmontools
  lm_sensors
  pciutils
  usbutils
  lsof
  tree
  jq
  yq
  rsync
  ripgrep
  fd
  zstd
  unzip
  zip
  git
  base-devel
  vim
  nano
  htop
  btop
  nvtop
  vivaldi
  bitwarden
)

AVAILABLE=()
MISSING_REPO=()

for P in "${CANDIDATES[@]}"; do
  if pacman -Qi "$P" >/dev/null 2>&1; then
    echo "$P: já instalado."
  elif pacman -Si "$P" >/dev/null 2>&1; then
    echo "$P: disponível e faltando."
    AVAILABLE+=("$P")
  else
    echo "$P: indisponível nos repositórios ativos; ignorado."
    MISSING_REPO+=("$P")
  fi
done
echo

if [[ "${#AVAILABLE[@]}" -gt 0 ]]; then
  echo "Pacotes que serão instalados:"
  printf '%s\n' "${AVAILABLE[@]}" | sort
else
  echo "Nenhum pacote novo disponível/faltante na lista crítica."
fi
echo

if [[ "${#MISSING_REPO[@]}" -gt 0 ]]; then
  echo "Pacotes não encontrados nos repositórios ativos:"
  printf '%s\n' "${MISSING_REPO[@]}" | sort
  echo "Observação: não vou ativar AUR/helper nem repositório extra por chute."
fi
echo

echo "== 5/12 Instalando pacotes faltantes disponíveis =="
if [[ "${#AVAILABLE[@]}" -gt 0 ]]; then
  sudo pacman -S --needed --noconfirm "${AVAILABLE[@]}"
else
  echo "Nada para instalar."
fi
echo

echo "== 6/12 Ativando serviços essenciais sem remover nada =="
if pacman -Qi firewalld >/dev/null 2>&1; then
  sudo systemctl enable --now firewalld.service || true
fi

if pacman -Qi flatpak >/dev/null 2>&1; then
  sudo systemctl enable --now flatpak-system-helper.service 2>/dev/null || true
fi

if pacman -Qi sddm >/dev/null 2>&1; then
  sudo systemctl enable sddm.service || true
fi

if pacman -Qi tuned >/dev/null 2>&1; then
  sudo systemctl enable --now tuned.service || true
  if command -v tuned-adm >/dev/null 2>&1; then
    sudo tuned-adm profile latency-performance || true
  fi
fi

if pacman -Qi cpupower >/dev/null 2>&1; then
  backup_file /etc/default/cpupower cpupower
  cat <<'EOF' | sudo tee /etc/default/cpupower >/dev/null
# MochaArch — CPU performance persistente
governor='performance'
min_freq=
max_freq=
EOF
  sudo systemctl enable --now cpupower.service || true
fi
echo

echo "== 7/12 Reaplicando sysctl, THP e agressividade canônica =="
backup_file /etc/sysctl.d/99-mocha-agressividade.conf sysctl

cat <<EOF | sudo tee /etc/sysctl.d/99-mocha-agressividade.conf >/dev/null
# MochaArch — agressividade/performance — $TS
vm.swappiness = 80
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.max_map_count = 16777216
kernel.nmi_watchdog = 0
kernel.sched_autogroup_enabled = 0
EOF

sudo sysctl --system | sed -n '1,220p'

backup_file /etc/tmpfiles.d/99-mocha-thp.conf tmpfiles
cat <<EOF | sudo tee /etc/tmpfiles.d/99-mocha-thp.conf >/dev/null
# MochaArch — THP madvise — $TS
w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise
EOF

if [[ -e /sys/kernel/mm/transparent_hugepage/enabled ]]; then
  printf '%s\n' madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null || true
fi
echo

echo "== 8/12 Forçando CPU em estado máximo agora e no boot =="
RUNTIME_SCRIPT="/usr/local/sbin/mocha-max-performance.sh"
SERVICE_FILE="/etc/systemd/system/mocha-max-performance.service"

cat <<'EOF' | write_root_file_from_stdin "$RUNTIME_SCRIPT" 0755
#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:${PATH:-}"

echo "Mocha max performance: $(date -Is)"

if command -v tuned-adm >/dev/null 2>&1; then
  systemctl enable --now tuned.service >/dev/null 2>&1 || true
  tuned-adm profile latency-performance >/dev/null 2>&1 || true
fi

if command -v cpupower >/dev/null 2>&1; then
  cpupower frequency-set -g performance >/dev/null 2>&1 || true
fi

for GOV in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [[ -e "$GOV" ]] && printf '%s\n' performance > "$GOV" 2>/dev/null || true
done

for PREF in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
  [[ -e "$PREF" ]] && printf '%s\n' performance > "$PREF" 2>/dev/null || true
done

for BOOST in /sys/devices/system/cpu/cpufreq/boost /sys/devices/system/cpu/amd_pstate/cpb_boost; do
  [[ -e "$BOOST" ]] && printf '%s\n' 1 > "$BOOST" 2>/dev/null || true
done

if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi -pm 1 >/dev/null 2>&1 || true

  MAX_POWER="$(
    nvidia-smi --query-gpu=power.max_limit --format=csv,noheader,nounits 2>/dev/null \
      | awk 'NR==1 && $1 ~ /^[0-9.]+$/ {printf "%d\n", $1}'
  )"
  if [[ -n "${MAX_POWER:-}" && "$MAX_POWER" -gt 0 ]]; then
    nvidia-smi -pl "$MAX_POWER" >/dev/null 2>&1 || true
  fi

  MAX_GC="$(
    nvidia-smi --query-supported-clocks=graphics --format=csv,noheader,nounits 2>/dev/null \
      | awk '$1 ~ /^[0-9]+$/ {print $1}' \
      | sort -n \
      | tail -n 1
  )"
  if [[ -n "${MAX_GC:-}" ]]; then
    nvidia-smi -lgc "$MAX_GC,$MAX_GC" >/dev/null 2>&1 || true
  fi

  MAX_MC="$(
    nvidia-smi --query-supported-clocks=memory --format=csv,noheader,nounits 2>/dev/null \
      | awk '$1 ~ /^[0-9]+$/ {print $1}' \
      | sort -n \
      | tail -n 1
  )"
  if [[ -n "${MAX_MC:-}" ]]; then
    nvidia-smi -lmc "$MAX_MC,$MAX_MC" >/dev/null 2>&1 || true
  fi
fi
EOF

cat <<EOF | write_root_file_from_stdin "$SERVICE_FILE" 0644
[Unit]
Description=MochaArch CPU/GPU maximum performance
After=multi-user.target graphical.target systemd-modules-load.service
Wants=multi-user.target

[Service]
Type=oneshot
ExecStart=$RUNTIME_SCRIPT
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target graphical.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now mocha-max-performance.service || true
sudo "$RUNTIME_SCRIPT" || true
echo

echo "== 9/12 Aplicando papel de parede Mocha =="
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
WALLPAPER_TARGET_DIR="$USER_HOME/.local/share/wallpapers/Mocha"
mkdir -p "$WALLPAPER_TARGET_DIR"

echo "Procurando wallpaper aprovado no ativo..."
WALLPAPER_SRC="$(
  find "$BASE" \
    -path "$BASE/quarentena" -prune -o \
    -path "$BASE/backups" -prune -o \
    -path "$BASE/relatorios" -prune -o \
    -path "$BASE/logs" -prune -o \
    -path "$BASE/auditorias" -prune -o \
    -type f \( -iname '*wallpaper*.png' -o -iname '*wallpaper*.jpg' -o -iname '*wallpaper*.jpeg' -o -iname '*wallpaper*.webp' -o -iname '*papel*.png' -o -iname '*papel*.jpg' -o -iname '*fundo*.png' -o -iname '*fundo*.jpg' -o -iname '*mocha*.png' -o -iname '*mocha*.jpg' -o -iname '*mocha*.webp' \) \
    -printf '%T@ %p\n' \
    | sort -nr \
    | sed -n '1s/^[^ ]* //p'
)"

if [[ -z "${WALLPAPER_SRC:-}" || ! -f "$WALLPAPER_SRC" ]]; then
  echo "AVISO: nenhum wallpaper Mocha foi encontrado no ativo."
  echo "Nada foi aplicado."
else
  WALLPAPER_EXT="${WALLPAPER_SRC##*.}"
  WALLPAPER_DST="$WALLPAPER_TARGET_DIR/MochaWallpaper-${TS}.${WALLPAPER_EXT}"
  install -D -m 0644 "$WALLPAPER_SRC" "$WALLPAPER_DST"
  chown "$USER_NAME:$USER_NAME" "$WALLPAPER_DST" 2>/dev/null || true

  echo "Wallpaper selecionado:"
  echo "$WALLPAPER_SRC"
  echo "Instalado em:"
  echo "$WALLPAPER_DST"

  if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
    sudo -u "$USER_NAME" DISPLAY="${DISPLAY:-:0}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}" XDG_RUNTIME_DIR="/run/user/$(id -u "$USER_NAME")" \
      plasma-apply-wallpaperimage "$WALLPAPER_DST" || true
  fi

  if command -v qdbus6 >/dev/null 2>&1; then
    JS_FILE="/tmp/${TS}-mocha-apply-wallpaper.js"
    cat > "$JS_FILE" <<EOF
var wallpaper = "file://$WALLPAPER_DST";
var desktopsArray = desktops();
for (var i = 0; i < desktopsArray.length; i++) {
  var d = desktopsArray[i];
  d.wallpaperPlugin = "org.kde.image";
  d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
  d.writeConfig("Image", wallpaper);
}
EOF
    sudo -u "$USER_NAME" DISPLAY="${DISPLAY:-:0}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}" XDG_RUNTIME_DIR="/run/user/$(id -u "$USER_NAME")" \
      qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$JS_FILE")" || true
    rm -f "$JS_FILE"
  fi

  sudo -u "$USER_NAME" kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$WALLPAPER_DST" 2>/dev/null || true

  echo "Wallpaper aplicado ao desktop e registrado para tela de bloqueio quando suportado."
fi
echo

echo "== 10/12 Reaplicando tema Mocha aprovado se ferramentas existem =="
COLOR_NAME="MochaSolidCanonico"
PLASMA_THEME_NAME="MochaPanelSolidCanonico"
LOCAL_COLOR_DIR="$USER_HOME/.local/share/color-schemes"
LOCAL_PLASMA_THEME_DIR="$USER_HOME/.local/share/plasma/desktoptheme"
mkdir -p "$LOCAL_COLOR_DIR" "$LOCAL_PLASMA_THEME_DIR"

COLOR_SRC="$(
  find "$BASE" \
    -path "$BASE/quarentena" -prune -o \
    -path "$BASE/backups" -prune -o \
    -type f -name 'MochaSolidCanonico.colors' -print -quit
)"
if [[ -n "${COLOR_SRC:-}" && -f "$COLOR_SRC" ]]; then
  install -D -m 0644 "$COLOR_SRC" "$LOCAL_COLOR_DIR/MochaSolidCanonico.colors"
  chown "$USER_NAME:$USER_NAME" "$LOCAL_COLOR_DIR/MochaSolidCanonico.colors" 2>/dev/null || true
fi

PLASMA_THEME_SRC="$(
  find "$BASE" \
    -path "$BASE/quarentena" -prune -o \
    -path "$BASE/backups" -prune -o \
    -type d -name 'MochaPanelSolidCanonico' -print -quit
)"
if [[ -n "${PLASMA_THEME_SRC:-}" && -d "$PLASMA_THEME_SRC" ]]; then
  rm -rf "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico.tmp.${TS}"
  cp -a "$PLASMA_THEME_SRC" "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico.tmp.${TS}"
  rm -rf "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico"
  mv "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico.tmp.${TS}" "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico"
  chown -R "$USER_NAME:$USER_NAME" "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico" 2>/dev/null || true
fi

if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
  sudo -u "$USER_NAME" DISPLAY="${DISPLAY:-:0}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}" XDG_RUNTIME_DIR="/run/user/$(id -u "$USER_NAME")" \
    plasma-apply-colorscheme "$COLOR_NAME" || true
fi

if command -v plasma-apply-desktoptheme >/dev/null 2>&1; then
  sudo -u "$USER_NAME" DISPLAY="${DISPLAY:-:0}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}" XDG_RUNTIME_DIR="/run/user/$(id -u "$USER_NAME")" \
    plasma-apply-desktoptheme "$PLASMA_THEME_NAME" || true
fi
echo

echo "== 11/12 Documentando no manual vivo =="
DOC_SCRIPT="$BASE/scripts/mocha-adicionar-entrada-aprovada-ao-manual.sh"

if [[ -x "$DOC_SCRIPT" ]]; then
  TMP_DOC="/tmp/${TS}-manual-pacotes-wallpaper-cpu-gpu.txt"
  {
    printf '%s\n' 'Correção aplicada para pacotes faltantes, wallpaper e estado máximo de CPU/GPU.'
    printf '%s\n' ''
    printf '%s\n' '- Pacotes críticos foram validados contra os repositórios ativos com `pacman -Si` antes da instalação.'
    printf '%s\n' '- `tuned` e `cpupower` foram instalados quando disponíveis e configurados para `latency-performance`/`performance`.'
    printf '%s\n' '- Serviço persistente `mocha-max-performance.service` força governor/EPP da CPU em performance e aplica NVIDIA persistence mode, power limit máximo e lock de clocks quando suportado pelo driver/GPU.'
    printf '%s\n' '- Wallpaper Mocha encontrado no ativo foi copiado para `~/.local/share/wallpapers/Mocha/` e aplicado no Plasma.'
    printf '%s\n' '- Nenhum pacote foi removido; kernel, GRUB e entrada padrão de boot não foram alterados por esta correção.'
    printf '%s\n' "- Relatório: $LOG"
    printf '%s\n' "- Script: $SCRIPTS_DIR/${TS}-mocha-instalar-pacotes-faltantes-wallpaper-cpu-gpu-max.sh"
  } > "$TMP_DOC"

  "$DOC_SCRIPT" "Pacotes / visual / performance" "Pacotes faltantes, wallpaper e CPU/GPU máximo" < "$TMP_DOC" || true
  rm -f "$TMP_DOC"
else
  DOC_FALLBACK="$DOC_DIR/${TS}-pacotes-wallpaper-cpu-gpu-max.md"
  {
    printf '%s\n' '# MochaArch — pacotes faltantes, wallpaper e CPU/GPU máximo'
    printf '%s\n' ''
    printf '%s\n' "- Timestamp: $TS"
    printf '%s\n' "- Relatório: $LOG"
    printf '%s\n' "- Nenhum pacote foi removido."
    printf '%s\n' "- Kernel, GRUB e entrada padrão de boot não foram alterados."
  } > "$DOC_FALLBACK"
  echo "Documentação fallback criada: $DOC_FALLBACK"
fi
echo

echo "== 12/12 Auditoria final =="
echo "-- Pacotes críticos finais:"
pacman -Q \
  tuned cpupower gamemode lib32-gamemode mangohud lib32-mangohud goverlay steam \
  sddm plasma-workspace plasma-desktop kde-cli-tools powerdevil plasma-firewall \
  firewalld flatpak vivaldi bitwarden \
  nvidia-utils lib32-nvidia-utils opencl-nvidia vulkan-tools vulkan-icd-loader lib32-vulkan-icd-loader \
  2>/dev/null | sort || true
echo

echo "-- Serviços finais:"
systemctl is-enabled tuned.service 2>/dev/null | sed 's/^/tuned enabled: /' || true
systemctl is-active tuned.service 2>/dev/null | sed 's/^/tuned active: /' || true
systemctl is-enabled cpupower.service 2>/dev/null | sed 's/^/cpupower enabled: /' || true
systemctl is-active cpupower.service 2>/dev/null | sed 's/^/cpupower active: /' || true
systemctl is-enabled mocha-max-performance.service 2>/dev/null | sed 's/^/mocha-max-performance enabled: /' || true
systemctl is-active mocha-max-performance.service 2>/dev/null | sed 's/^/mocha-max-performance active: /' || true
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || true
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || true
echo

echo "-- CPU final:"
for GOV in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [[ -r "$GOV" ]] && printf '%s: %s\n' "$GOV" "$(cat "$GOV")"
done | head -n 32
for PREF in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
  [[ -r "$PREF" ]] && printf '%s: %s\n' "$PREF" "$(cat "$PREF")"
done | head -n 32
echo

echo "-- GPU final:"
command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -q -d PERFORMANCE,POWER,CLOCK | sed -n '1,220p' || true
echo

echo "-- Tema/wallpaper final:"
command -v kreadconfig6 >/dev/null 2>&1 && kreadconfig6 --file kdeglobals --group General --key ColorScheme | sed 's/^/ColorScheme: /' || true
command -v kreadconfig6 >/dev/null 2>&1 && kreadconfig6 --file plasmarc --group Theme --key name | sed 's/^/PlasmaTheme: /' || true
if [[ -n "${WALLPAPER_DST:-}" && -f "${WALLPAPER_DST:-}" ]]; then
  echo "Wallpaper: $WALLPAPER_DST"
else
  echo "Wallpaper: não aplicado; arquivo não encontrado no ativo."
fi
echo

cp -f "$0" "$SCRIPTS_DIR/${TS}-mocha-instalar-pacotes-faltantes-wallpaper-cpu-gpu-max.sh"
chmod +x "$SCRIPTS_DIR/${TS}-mocha-instalar-pacotes-faltantes-wallpaper-cpu-gpu-max.sh"

echo "Relatório final:"
echo "$LOG"
echo "Script salvo:"
echo "$SCRIPTS_DIR/${TS}-mocha-instalar-pacotes-faltantes-wallpaper-cpu-gpu-max.sh"
echo
echo "== CONCLUÍDO =="
