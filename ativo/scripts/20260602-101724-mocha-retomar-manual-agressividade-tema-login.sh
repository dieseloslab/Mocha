#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch/ativo"
DOC_DIR="$BASE/documentacao"
MANUAL="$DOC_DIR/20260529-154304-MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
BACKUP_DIR="$DOC_DIR/backups"
REPORT_DIR="$BASE/relatorios"
SCRIPTS_DIR="$BASE/scripts"
TMP_LOG="/tmp/${TS}-mocha-retomar-manual-agressividade-tema-login.log"

exec > >(tee -a "$TMP_LOG") 2>&1

echo "== MOCHAARCH — retomada manual/agressividade/tema/login =="
echo "Timestamp: $TS"
echo "Script: $0"
echo "Log temporário: $TMP_LOG"
echo

echo "== 1/9 Sudo com keepalive =="
sudo -v
while true; do
  sudo -n true 2>/dev/null || exit 0
  sleep 45
done &
SUDO_KEEPALIVE_PID="$!"
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
echo "Sudo OK."
echo

echo "== 2/9 Conferindo/montando FAST e VMSTORE via fstab =="
for MP in /media/mochafast /media/vmstore; do
  if mountpoint -q "$MP"; then
    echo "$MP: já montado."
  else
    if grep -Eq "[[:space:]]${MP//\//\\/}[[:space:]]" /etc/fstab; then
      echo "$MP: não montado; tentando montar pela entrada existente no /etc/fstab..."
      sudo mount "$MP"
      if mountpoint -q "$MP"; then
        echo "$MP: montado OK."
      else
        echo "ERRO: $MP não montou mesmo existindo no /etc/fstab."
        exit 1
      fi
    else
      echo "ERRO: $MP não está montado e não há entrada clara no /etc/fstab."
      echo "Não vou detectar disco por chute nem editar fstab aqui."
      exit 1
    fi
  fi
done
echo

echo "== 3/9 Preparando diretórios ativos =="
if [[ ! -d "$BASE" ]]; then
  echo "ERRO: base ativa não existe: $BASE"
  exit 1
fi

mkdir -p "$REPORT_DIR" "$SCRIPTS_DIR" "$BASE/backups/configs"
LOG="$REPORT_DIR/${TS}-retomar-manual-agressividade-tema-login.log"
cp -f "$TMP_LOG" "$LOG" 2>/dev/null || true
exec > >(tee -a "$LOG") 2>&1

echo "Base ativa: $BASE"
echo "Documentação: $DOC_DIR"
echo "Relatório: $LOG"
echo

backup_file() {
  local src="$1"
  local label="$2"
  local dir="$BASE/backups/configs/$label"
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

write_root_file() {
  local target="$1"
  shift
  local tmp
  tmp="$(mktemp)"
  printf '%s\n' "$@" > "$tmp"
  sudo install -D -m 0644 "$tmp" "$target"
  rm -f "$tmp"
}

echo "== 4/9 Restaurando MANUAL ÚNICO VIVO se necessário =="
if [[ -f "$MANUAL" ]]; then
  echo "Manual vivo já existe:"
  echo "$MANUAL"
else
  echo "Manual vivo não está no caminho ativo. Procurando backup mais recente..."
  if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "ERRO: pasta de backups não existe: $BACKUP_DIR"
    exit 1
  fi

  LATEST_BACKUP="$(
    find "$BACKUP_DIR" -maxdepth 1 -type f \
      -name '*MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md.bak' \
      -printf '%T@ %p\n' \
      | sort -nr \
      | sed -n '1s/^[^ ]* //p'
  )"

  if [[ -z "${LATEST_BACKUP:-}" || ! -f "$LATEST_BACKUP" ]]; then
    echo "ERRO: nenhum backup do MANUAL ÚNICO VIVO foi encontrado."
    exit 1
  fi

  mkdir -p "$DOC_DIR"
  cp -a "$LATEST_BACKUP" "$MANUAL"
  echo "Manual restaurado:"
  echo "$LATEST_BACKUP -> $MANUAL"
fi

echo
echo "Trechos relevantes do manual:"
grep -nEi 'FAST|VMSTORE|agressividade|performance|latency-performance|MochaSolidCanonico|MochaPanelSolidCanonico|barra-win11|sddm|login manager|wayland|firewall|cloudflare' "$MANUAL" | head -n 120 || true
echo

echo "== 5/9 Auditoria antes de aplicar =="
echo "-- Kernel/driver/boot: apenas leitura; não serão alterados."
uname -a || true
command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi || echo "nvidia-smi indisponível/falhou."
echo

echo "-- Montagens:"
findmnt /media/mochafast /media/vmstore || true
echo

echo "-- Sysctl atual:"
for K in \
  vm.swappiness \
  vm.vfs_cache_pressure \
  vm.page-cluster \
  vm.dirty_background_bytes \
  vm.dirty_bytes \
  vm.max_map_count \
  kernel.nmi_watchdog \
  kernel.sched_autogroup_enabled
do
  sysctl "$K" 2>/dev/null || true
done
echo

echo "-- THP atual:"
if [[ -r /sys/kernel/mm/transparent_hugepage/enabled ]]; then
  cat /sys/kernel/mm/transparent_hugepage/enabled
else
  echo "THP indisponível neste kernel."
fi
echo

echo "-- TuneD/CPU atual:"
systemctl is-enabled tuned.service 2>/dev/null | sed 's/^/tuned enabled: /' || echo "tuned enabled: indisponível"
systemctl is-active tuned.service 2>/dev/null | sed 's/^/tuned active: /' || echo "tuned active: indisponível"
command -v tuned-adm >/dev/null 2>&1 && tuned-adm active || true
for GOV in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [[ -r "$GOV" ]] && printf '%s: %s\n' "$GOV" "$(cat "$GOV")"
done | head -n 32
echo

echo "-- Tema atual:"
command -v kreadconfig6 >/dev/null 2>&1 && kreadconfig6 --file kdeglobals --group General --key ColorScheme || true
command -v kreadconfig6 >/dev/null 2>&1 && kreadconfig6 --file plasmarc --group Theme --key name || true
echo

echo "-- Login manager atual:"
systemctl is-enabled display-manager.service 2>/dev/null | sed 's/^/display-manager enabled: /' || true
systemctl status display-manager.service --no-pager 2>/dev/null | sed -n '1,12p' || true
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || true
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || true
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || true
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || true
echo

echo "== 6/9 Aplicando receita de agressividade/performance =="
SYSCTL_CONF="/etc/sysctl.d/99-mocha-agressividade.conf"
backup_file "$SYSCTL_CONF" "sysctl"

write_root_file "$SYSCTL_CONF" \
  "# MochaArch — agressividade/performance — $TS" \
  "vm.swappiness = 80" \
  "vm.vfs_cache_pressure = 50" \
  "vm.page-cluster = 0" \
  "vm.dirty_background_bytes = 67108864" \
  "vm.dirty_bytes = 268435456" \
  "vm.max_map_count = 16777216" \
  "kernel.nmi_watchdog = 0" \
  "kernel.sched_autogroup_enabled = 0"

echo "Aplicando sysctl..."
sudo sysctl --system | sed -n '1,180p'

THP_CONF="/etc/tmpfiles.d/99-mocha-thp.conf"
backup_file "$THP_CONF" "tmpfiles"
write_root_file "$THP_CONF" \
  "# MochaArch — THP madvise — $TS" \
  "w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise"

if [[ -w /sys/kernel/mm/transparent_hugepage/enabled || -e /sys/kernel/mm/transparent_hugepage/enabled ]]; then
  echo "Aplicando THP=madvise em runtime..."
  printf '%s\n' madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null || true
fi

if command -v tuned-adm >/dev/null 2>&1; then
  echo "Ativando TuneD latency-performance..."
  sudo systemctl enable --now tuned.service
  sudo tuned-adm profile latency-performance
else
  echo "AVISO: tuned-adm não encontrado; TuneD não foi alterado."
fi

echo "Aplicando governor performance em runtime quando disponível..."
COUNT_GOV=0
for GOV in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  if [[ -e "$GOV" ]]; then
    printf '%s\n' performance | sudo tee "$GOV" >/dev/null || true
    COUNT_GOV=$((COUNT_GOV + 1))
  fi
done
echo "Governors ajustados: $COUNT_GOV"

if command -v nvidia-smi >/dev/null 2>&1; then
  echo "Ativando NVIDIA persistence mode quando suportado..."
  sudo nvidia-smi -pm 1 || true
fi
echo

echo "== 7/9 Aplicando tema KDE/Mocha aprovado =="
COLOR_NAME="MochaSolidCanonico"
PLASMA_THEME_NAME="MochaPanelSolidCanonico"

USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
LOCAL_COLOR_DIR="$USER_HOME/.local/share/color-schemes"
LOCAL_PLASMA_THEME_DIR="$USER_HOME/.local/share/plasma/desktoptheme"

mkdir -p "$LOCAL_COLOR_DIR" "$LOCAL_PLASMA_THEME_DIR"

echo "Procurando MochaSolidCanonico.colors no ativo..."
COLOR_SRC="$(
  find "$BASE" \
    -path "$BASE/quarentena" -prune -o \
    -path "$BASE/documentacao/backups" -prune -o \
    -type f -name 'MochaSolidCanonico.colors' -print -quit
)"
if [[ -n "${COLOR_SRC:-}" && -f "$COLOR_SRC" ]]; then
  install -D -m 0644 "$COLOR_SRC" "$LOCAL_COLOR_DIR/MochaSolidCanonico.colors"
  echo "Color scheme instalado em: $LOCAL_COLOR_DIR/MochaSolidCanonico.colors"
else
  echo "AVISO: MochaSolidCanonico.colors não encontrado no ativo."
fi

echo "Procurando MochaPanelSolidCanonico no ativo..."
PLASMA_THEME_SRC="$(
  find "$BASE" \
    -path "$BASE/quarentena" -prune -o \
    -path "$BASE/documentacao/backups" -prune -o \
    -type d -name 'MochaPanelSolidCanonico' -print -quit
)"
if [[ -n "${PLASMA_THEME_SRC:-}" && -d "$PLASMA_THEME_SRC" ]]; then
  rm -rf "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico.tmp.${TS}"
  cp -a "$PLASMA_THEME_SRC" "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico.tmp.${TS}"
  rm -rf "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico"
  mv "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico.tmp.${TS}" "$LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico"
  echo "Plasma theme instalado em: $LOCAL_PLASMA_THEME_DIR/MochaPanelSolidCanonico"
else
  echo "AVISO: MochaPanelSolidCanonico não encontrado no ativo."
fi

if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
  echo "Aplicando color scheme: $COLOR_NAME"
  plasma-apply-colorscheme "$COLOR_NAME" || true
else
  echo "AVISO: plasma-apply-colorscheme não encontrado."
fi

if command -v plasma-apply-desktoptheme >/dev/null 2>&1; then
  echo "Aplicando Plasma desktop theme: $PLASMA_THEME_NAME"
  plasma-apply-desktoptheme "$PLASMA_THEME_NAME" || true
else
  echo "AVISO: plasma-apply-desktoptheme não encontrado."
fi

APPROVED_APPLETSRC="$BASE/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
if [[ ! -f "$APPROVED_APPLETSRC" ]]; then
  APPROVED_APPLETSRC="$(
    find "$BASE/kde" \
      -path "$BASE/kde/quarentena" -prune -o \
      -type f -name 'plasma-org.kde.plasma.desktop-appletsrc-aprovado-*' -print -quit 2>/dev/null || true
  )"
fi

CURRENT_APPLETSRC="$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
if [[ -n "${APPROVED_APPLETSRC:-}" && -f "$APPROVED_APPLETSRC" && -f "$CURRENT_APPLETSRC" ]]; then
  if cmp -s "$APPROVED_APPLETSRC" "$CURRENT_APPLETSRC"; then
    echo "Barra Win11 aprovada: já está igual ao arquivo aprovado."
  else
    echo "Aplicando barra Win11 aprovada a partir de:"
    echo "$APPROVED_APPLETSRC"
    backup_file "$CURRENT_APPLETSRC" "plasma-appletsrc"
    kquitapp6 plasmashell 2>/dev/null || true
    sleep 2
    cp -a "$APPROVED_APPLETSRC" "$CURRENT_APPLETSRC"
    chown "$USER_NAME:$USER_NAME" "$CURRENT_APPLETSRC" 2>/dev/null || true
    if command -v kstart >/dev/null 2>&1; then
      kstart plasmashell >/dev/null 2>&1 || true
    elif command -v kstart6 >/dev/null 2>&1; then
      kstart6 plasmashell >/dev/null 2>&1 || true
    else
      plasmashell >/tmp/${TS}-plasmashell-restart.log 2>&1 &
    fi
    echo "Barra Win11 aprovada aplicada."
  fi
else
  echo "AVISO: arquivo aprovado da barra Win11 não encontrado ou appletsrc atual ausente; barra não foi alterada."
fi
echo

echo "== 8/9 Conferindo/configurando login manager Wayland =="
SDDM_CONF="/etc/sddm.conf.d/10-mocha-wayland.conf"
HAS_PLASMA_LOGIN=0
HAS_SDDM=0

systemctl list-unit-files plasma-login.service >/dev/null 2>&1 && HAS_PLASMA_LOGIN=1 || true
systemctl list-unit-files sddm.service >/dev/null 2>&1 && HAS_SDDM=1 || true

if [[ "$HAS_PLASMA_LOGIN" -eq 1 ]]; then
  echo "plasma-login.service existe neste sistema."
  echo "Não vou substituir automaticamente por SDDM para evitar conflito de login manager."
  systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || true
  systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || true
elif [[ "$HAS_SDDM" -eq 1 ]]; then
  echo "Configurando SDDM para Wayland."
  backup_file "$SDDM_CONF" "sddm"
  sudo mkdir -p /etc/sddm.conf.d

  write_root_file "$SDDM_CONF" \
    "# MochaArch — SDDM Wayland — $TS" \
    "[General]" \
    "DisplayServer=wayland" \
    "GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell" \
    "" \
    "[Wayland]" \
    "CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1"

  echo "Habilitando sddm.service para o próximo boot sem reiniciar agora..."
  sudo systemctl enable sddm.service
else
  echo "AVISO: nem plasma-login.service nem sddm.service foram encontrados."
  echo "Login manager não foi alterado."
fi
echo

echo "== 9/9 Auditoria final =="
echo "-- Manual:"
ls -lh "$MANUAL"
echo

echo "-- Sysctl final:"
for K in \
  vm.swappiness \
  vm.vfs_cache_pressure \
  vm.page-cluster \
  vm.dirty_background_bytes \
  vm.dirty_bytes \
  vm.max_map_count \
  kernel.nmi_watchdog \
  kernel.sched_autogroup_enabled
do
  sysctl "$K" 2>/dev/null || true
done
echo

echo "-- THP final:"
[[ -r /sys/kernel/mm/transparent_hugepage/enabled ]] && cat /sys/kernel/mm/transparent_hugepage/enabled || true
echo

echo "-- TuneD/CPU final:"
systemctl is-enabled tuned.service 2>/dev/null | sed 's/^/tuned enabled: /' || true
systemctl is-active tuned.service 2>/dev/null | sed 's/^/tuned active: /' || true
command -v tuned-adm >/dev/null 2>&1 && tuned-adm active || true
for GOV in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [[ -r "$GOV" ]] && printf '%s: %s\n' "$GOV" "$(cat "$GOV")"
done | head -n 32
echo

echo "-- Tema final:"
command -v kreadconfig6 >/dev/null 2>&1 && kreadconfig6 --file kdeglobals --group General --key ColorScheme | sed 's/^/ColorScheme: /' || true
command -v kreadconfig6 >/dev/null 2>&1 && kreadconfig6 --file plasmarc --group Theme --key name | sed 's/^/PlasmaTheme: /' || true
echo

echo "-- Login manager final:"
systemctl is-enabled display-manager.service 2>/dev/null | sed 's/^/display-manager enabled: /' || true
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || true
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || true
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || true
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || true
echo

echo "-- Kernel/NVIDIA/GRUB não alterados por este script."
echo "Relatório final: $LOG"

cp -f "$0" "$SCRIPTS_DIR/${TS}-mocha-retomar-manual-agressividade-tema-login.sh"
chmod +x "$SCRIPTS_DIR/${TS}-mocha-retomar-manual-agressividade-tema-login.sh"
echo "Script reutilizável salvo em:"
echo "$SCRIPTS_DIR/${TS}-mocha-retomar-manual-agressividade-tema-login.sh"

echo
echo "== CONCLUÍDO =="
