set -Eeuo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
REAL_USER="${SUDO_USER:-$USER}"
BASE="/media/mochafast/MochaArch/ativo"
DOC_DIR="$BASE/documentacao"
SCRIPT_DIR="$BASE/scripts"
LOG_DIR="$BASE/logs"
MANUAL="$DOC_DIR/manual-montagem-mochaarch.md"
LOG="$LOG_DIR/${TS}-reparo-zen-nvidia-sem-carregar.log"

say() { printf '\n== %s ==\n' "$*"; }
fail() { printf '\nERRO: %s\n' "$*"; exit 1; }
run_sudo() { sudo "$@"; }

append_manual_line() {
  printf '%s\n' "$1" >> "$MANUAL"
}

append_manual_blank() {
  printf '\n' >> "$MANUAL"
}

add_manual_section_once() {
  marker="$1"
  shift
  if grep -Fq "$marker" "$MANUAL" 2>/dev/null; then
    return 0
  fi
  append_manual_blank
  append_manual_line '---'
  append_manual_blank
  while [ "$#" -gt 0 ]; do
    append_manual_line "$1"
    shift
  done
}

backup_keep_two() {
  file="$1"
  [ -f "$file" ] || return 0
  backup="${file}.bak-${TS}"
  run_sudo cp -a "$file" "$backup"
  printf '%s\n' "Backup criado: $backup"
  dir="$(dirname "$file")"
  base_name="$(basename "$file")"
  run_sudo find "$dir" -maxdepth 1 -type f -name "${base_name}.bak-*" -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | tail -n +3 \
    | cut -d' ' -f2- \
    | while IFS= read -r old; do
        [ -n "$old" ] && run_sudo rm -f "$old"
      done || true
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "comando ausente: $1"
}

require_cmd sudo
require_cmd pacman
require_cmd mkinitcpio
require_cmd modinfo
require_cmd awk
require_cmd sed
require_cmd findmnt
require_cmd sort
require_cmd tee

say "Validando FAST e VMSTORE antes de qualquer reparo"
findmnt /media/vmstore >/dev/null || fail "/media/vmstore não está montado. Monte antes de continuar."
findmnt /media/mochafast >/dev/null || fail "/media/mochafast não está montado. Monte antes de continuar."

run_sudo install -d -m 775 "$DOC_DIR" "$SCRIPT_DIR" "$LOG_DIR"
run_sudo chown -R "$REAL_USER:$REAL_USER" /media/mochafast/MochaArch 2>/dev/null || true

exec > >(tee -a "$LOG") 2>&1

say "Estado inicial resumido"
printf '%s\n' "Kernel atual: $(uname -r)"
printf '%s\n' "Log: $LOG"
printf '%s\n' "Não vou executar nvidia-smi nem modprobe nvidia nesta sessão."
lsmod | grep -E '^(nvidia|nouveau)' || true

if [ ! -f "$MANUAL" ]; then
  printf '%s\n' '# Manual de montagem - Mocha Arch KDE' > "$MANUAL"
  printf '\n%s\n' "Arquivo operacional criado em $TS." >> "$MANUAL"
fi

say "Registrando congelamento e regra no manual"
add_manual_section_once 'ERRO PROIBIDO - assumir congelamento como pontual sem auditoria' \
'## ERRO PROIBIDO - assumir congelamento como pontual sem auditoria' \
'' \
'Em 2026-05-29 houve congelamento total após instalação parcial do kernel Zen/NVIDIA e montagem FAST/VMSTORE.' \
'' \
'O log do boot anterior mostrou nvidia-modeset com Failed to initialize DMA e NVRM RC watchdog indicando GPU provavelmente travada.' \
'' \
'Regra operacional: após congelamento, não reiniciar nem continuar bootloader/kernel por palpite. Auditar journalctl -b -1, pacman.log, DKMS, mkinitcpio, serviços de performance, mounts e estado real dos módulos antes de qualquer próxima alteração.' \
'' \
'Regra adicional: não rodar nvidia-smi, serviço de persistence mode ou modprobe nvidia na sessão atual enquanto o driver não tiver sido preparado para assumir a GPU desde o boot limpo.'

say "Validando pacotes já instalados"
pacman -Q linux-zen linux-zen-headers nvidia-open-dkms nvidia-utils lib32-nvidia-utils egl-wayland vulkan-icd-loader >/dev/null || {
  echo "Pacotes esperados ausentes. Instalando somente os ausentes com pacman --needed."
  run_sudo pacman -S --needed linux-zen linux-zen-headers dkms nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland vulkan-icd-loader lib32-vulkan-icd-loader
}

say "Validando DKMS do NVIDIA para o Zen sem carregar módulo"
ZEN_KREL="$(find /usr/lib/modules -maxdepth 1 -type d -name '*-zen*' -printf '%f\n' | sort -V | tail -n1 || true)"
[ -n "${ZEN_KREL:-}" ] || fail "não encontrei kernel Zen em /usr/lib/modules."
printf '%s\n' "Kernel Zen detectado: $ZEN_KREL"
modinfo -k "$ZEN_KREL" nvidia >/dev/null 2>&1 || fail "módulo nvidia não existe para $ZEN_KREL."
modinfo -k "$ZEN_KREL" nvidia_drm >/dev/null 2>&1 || fail "módulo nvidia_drm não existe para $ZEN_KREL."

dkms status || true

say "Escrevendo configuração segura NVIDIA Wayland sem carregar driver agora"
run_sudo install -d -m 0755 /etc/modprobe.d
backup_keep_two /etc/modprobe.d/mocha-nvidia-wayland.conf
{
  printf '%s\n' '# Mocha Arch - NVIDIA Wayland/KDE'
  printf '%s\n' '# Preparado para boot limpo: NVIDIA assume a GPU cedo e nouveau fica fora.'
  printf '%s\n' 'blacklist nouveau'
  printf '%s\n' 'options nouveau modeset=0'
  printf '%s\n' 'options nvidia_drm modeset=1 fbdev=1'
  printf '%s\n' 'options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp'
} | run_sudo tee /etc/modprobe.d/mocha-nvidia-wayland.conf >/dev/null

say "Ajustando mkinitcpio: módulos NVIDIA cedo e sem hook kms puxando nouveau"
backup_keep_two /etc/mkinitcpio.conf
TMP_MK="$(mktemp)"
awk '
function emit_modules(line, s,n,a,i,tok,out,m,mods) {
  s=line
  sub(/^[[:space:]]*MODULES=\(/,"",s)
  sub(/\)[[:space:]]*$/,"",s)
  n=split(s,a,/[[:space:]]+/)
  out=""
  for (i=1;i<=n;i++) {
    tok=a[i]
    gsub(/["'\'']/, "", tok)
    if (tok=="" || tok=="nouveau") continue
    if (!(tok in seen)) { seen[tok]=1; out=out (out=="" ? "" : " ") tok }
  }
  split("nvidia nvidia_modeset nvidia_uvm nvidia_drm",mods," ")
  for (i=1;i<=4;i++) {
    tok=mods[i]
    if (!(tok in seen)) { seen[tok]=1; out=out (out=="" ? "" : " ") tok }
  }
  print "MODULES=(" out ")"
}
function emit_hooks(line, s,n,a,i,tok,out,hasmodconf) {
  s=line
  sub(/^[[:space:]]*HOOKS=\(/,"",s)
  sub(/\)[[:space:]]*$/,"",s)
  n=split(s,a,/[[:space:]]+/)
  out=""
  hasmodconf=0
  for (i=1;i<=n;i++) {
    tok=a[i]
    gsub(/["'\'']/, "", tok)
    if (tok=="" || tok=="kms") continue
    if (tok=="modconf") hasmodconf=1
    out=out (out=="" ? "" : " ") tok
  }
  if (!hasmodconf) {
    n=split(out,a," ")
    out=""
    for (i=1;i<=n;i++) {
      out=out (out=="" ? "" : " ") a[i]
      if (a[i]=="udev") { out=out " modconf"; hasmodconf=1 }
    }
    if (!hasmodconf) out=out (out=="" ? "" : " ") "modconf"
  }
  print "HOOKS=(" out ")"
}
/^[[:space:]]*MODULES=\(/ && $0 !~ /^[[:space:]]*#/ { delete seen; emit_modules($0); modules_done=1; next }
/^[[:space:]]*HOOKS=\(/ && $0 !~ /^[[:space:]]*#/ { emit_hooks($0); hooks_done=1; next }
{ print }
END {
  if (!modules_done) print "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)"
}
' /etc/mkinitcpio.conf > "$TMP_MK"
run_sudo install -m 0644 "$TMP_MK" /etc/mkinitcpio.conf
rm -f "$TMP_MK"

grep -E '^(MODULES|HOOKS)=' /etc/mkinitcpio.conf || true

say "Aplicando receita Mocha CPU/memória/zram sem mexer em GPU runtime"
{
  printf '%s\n' '# Mocha Arch - receita meio termo turbo vigente'
  printf '%s\n' 'vm.swappiness=80'
  printf '%s\n' 'vm.vfs_cache_pressure=50'
  printf '%s\n' 'vm.page-cluster=0'
  printf '%s\n' 'vm.dirty_background_bytes=67108864'
  printf '%s\n' 'vm.dirty_bytes=268435456'
  printf '%s\n' 'vm.max_map_count=16777216'
  printf '%s\n' 'kernel.nmi_watchdog=0'
  printf '%s\n' 'kernel.sched_autogroup_enabled=0'
} | run_sudo tee /etc/sysctl.d/90-mocha-performance.conf >/dev/null

{
  printf '%s\n' '# Mocha Arch - zram canônico'
  printf '%s\n' '[zram0]'
  printf '%s\n' 'zram-size = ram'
  printf '%s\n' 'compression-algorithm = zstd'
  printf '%s\n' 'swap-priority = 32767'
} | run_sudo tee /etc/systemd/zram-generator.conf >/dev/null

{
  printf '%s\n' '# Mocha Arch - THP madvise'
  printf '%s\n' 'w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise'
} | run_sudo tee /etc/tmpfiles.d/mocha-thp.conf >/dev/null

{
  printf '%s\n' '# Mocha Arch - CPU sempre em desempenho'
  printf '%s\n' "governor='performance'"
  printf '%s\n' "min_freq='0'"
  printf '%s\n' "max_freq='0'"
} | run_sudo tee /etc/default/cpupower >/dev/null

say "Ativando CPU/tuned/zram; GPU persistence fica para depois da validação"
run_sudo systemctl daemon-reload
run_sudo systemctl enable cpupower.service tuned.service >/dev/null || true
run_sudo systemctl start cpupower.service tuned.service || true
run_sudo tuned-adm profile latency-performance || true
run_sudo sysctl --system >/dev/null || true
if [ -e /sys/kernel/mm/transparent_hugepage/enabled ]; then
  printf '%s\n' madvise | run_sudo tee /sys/kernel/mm/transparent_hugepage/enabled >/dev/null || true
fi
run_sudo systemctl restart systemd-zram-setup@zram0.service 2>/dev/null || true

say "Recriando initramfs"
run_sudo mkinitcpio -P

say "Configurando bootloader para Zen como primeira entrada"
if [ -f /etc/default/grub ] && command -v grub-mkconfig >/dev/null 2>&1; then
  echo "GRUB detectado."
  backup_keep_two /etc/default/grub
  TMP_GRUB="$(mktemp)"
  awk '
  BEGIN {
    top_done=0; def_done=0; cmd_done=0
  }
  /^GRUB_TOP_LEVEL=/ { print "GRUB_TOP_LEVEL=\"/boot/vmlinuz-linux-zen\""; top_done=1; next }
  /^GRUB_DEFAULT=/ { print "GRUB_DEFAULT=0"; def_done=1; next }
  /^GRUB_CMDLINE_LINUX_DEFAULT=/ {
    line=$0
    sub(/^GRUB_CMDLINE_LINUX_DEFAULT=/,"",line)
    gsub(/^\"|\"$/,"",line)
    n=split(line,a,/[[:space:]]+/)
    out=""
    for (i=1;i<=n;i++) {
      tok=a[i]
      if (tok=="" || tok ~ /^nvidia_drm\.modeset=/ || tok ~ /^nvidia_drm\.fbdev=/ || tok ~ /^modprobe\.blacklist=nouveau/ || tok ~ /^nouveau\.modeset=/) continue
      out=out (out=="" ? "" : " ") tok
    }
    extra="nvidia_drm.modeset=1 nvidia_drm.fbdev=1 modprobe.blacklist=nouveau nouveau.modeset=0"
    if (out=="") out=extra; else out=out " " extra
    print "GRUB_CMDLINE_LINUX_DEFAULT=\"" out "\""
    cmd_done=1
    next
  }
  { print }
  END {
    if (!top_done) print "GRUB_TOP_LEVEL=\"/boot/vmlinuz-linux-zen\""
    if (!def_done) print "GRUB_DEFAULT=0"
    if (!cmd_done) print "GRUB_CMDLINE_LINUX_DEFAULT=\"nvidia_drm.modeset=1 nvidia_drm.fbdev=1 modprobe.blacklist=nouveau nouveau.modeset=0\""
  }
  ' /etc/default/grub > "$TMP_GRUB"
  run_sudo install -m 0644 "$TMP_GRUB" /etc/default/grub
  rm -f "$TMP_GRUB"
  run_sudo grub-mkconfig -o /boot/grub/grub.cfg
elif [ -d /boot/loader/entries ] && command -v bootctl >/dev/null 2>&1; then
  echo "systemd-boot detectado."
  SRC="$(find /boot/loader/entries -maxdepth 1 -type f -name '*.conf' | sort | head -n1 || true)"
  [ -n "${SRC:-}" ] || fail "systemd-boot detectado, mas sem entrada base em /boot/loader/entries."
  ENTRY="/boot/loader/entries/mocha-arch-zen-nvidia.conf"
  TMP_ENTRY="$(mktemp)"
  awk '
  BEGIN { title_done=0; linux_done=0; initrd_done=0; options_done=0 }
  /^title[[:space:]]+/ { print "title Mocha Arch Zen NVIDIA"; title_done=1; next }
  /^[[:space:]]*linux[[:space:]]+/ { print "linux /vmlinuz-linux-zen"; linux_done=1; next }
  /^[[:space:]]*initrd[[:space:]]+\/initramfs-linux.*\.img/ { if (!initrd_done) { print "initrd /initramfs-linux-zen.img"; initrd_done=1 }; next }
  /^[[:space:]]*options[[:space:]]+/ {
    line=$0
    if (line !~ /nvidia_drm\.modeset=1/) line=line " nvidia_drm.modeset=1"
    if (line !~ /nvidia_drm\.fbdev=1/) line=line " nvidia_drm.fbdev=1"
    if (line !~ /modprobe\.blacklist=nouveau/) line=line " modprobe.blacklist=nouveau"
    if (line !~ /nouveau\.modeset=0/) line=line " nouveau.modeset=0"
    print line
    options_done=1
    next
  }
  { print }
  END {
    if (!title_done) print "title Mocha Arch Zen NVIDIA"
    if (!linux_done) print "linux /vmlinuz-linux-zen"
    if (!initrd_done) print "initrd /initramfs-linux-zen.img"
    if (!options_done) print "options nvidia_drm.modeset=1 nvidia_drm.fbdev=1 modprobe.blacklist=nouveau nouveau.modeset=0"
  }
  ' "$SRC" > "$TMP_ENTRY"
  run_sudo install -m 0644 "$TMP_ENTRY" "$ENTRY"
  rm -f "$TMP_ENTRY"
  backup_keep_two /boot/loader/loader.conf
  TMP_LOADER="$(mktemp)"
  if [ -f /boot/loader/loader.conf ]; then
    awk '
    /^default[[:space:]]+/ { print "default mocha-arch-zen-nvidia.conf"; d=1; next }
    /^timeout[[:space:]]+/ { print "timeout 5"; t=1; next }
    { print }
    END { if (!d) print "default mocha-arch-zen-nvidia.conf"; if (!t) print "timeout 5" }
    ' /boot/loader/loader.conf > "$TMP_LOADER"
  else
    printf '%s\n' 'default mocha-arch-zen-nvidia.conf' 'timeout 5' > "$TMP_LOADER"
  fi
  run_sudo install -m 0644 "$TMP_LOADER" /boot/loader/loader.conf
  rm -f "$TMP_LOADER"
  run_sudo bootctl update || true
else
  fail "não detectei GRUB nem systemd-boot com segurança. Não vou improvisar bootloader."
fi

say "Validação final sem carregar NVIDIA"
[ -f /boot/vmlinuz-linux-zen ] || fail "/boot/vmlinuz-linux-zen ausente."
[ -f /boot/initramfs-linux-zen.img ] || fail "/boot/initramfs-linux-zen.img ausente."
modinfo -k "$ZEN_KREL" nvidia >/dev/null 2>&1 || fail "modinfo nvidia falhou para $ZEN_KREL."
modinfo -k "$ZEN_KREL" nvidia_drm >/dev/null 2>&1 || fail "modinfo nvidia_drm falhou para $ZEN_KREL."
grep -E '^MODULES=.*nvidia.*nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf >/dev/null || fail "MODULES do mkinitcpio não contém cadeia NVIDIA completa."
if grep -E '^HOOKS=.*(^|[[:space:]])kms([[:space:]]|\))' /etc/mkinitcpio.conf >/dev/null; then
  fail "HOOKS ainda contém kms; isso pode puxar nouveau cedo."
fi
if ! grep -Eq 'blacklist[[:space:]]+nouveau|modprobe\.blacklist=nouveau' /etc/modprobe.d/mocha-nvidia-wayland.conf /etc/default/grub 2>/dev/null; then
  fail "não encontrei blacklist do nouveau."
fi

if [ -f "$MANUAL" ]; then
  add_manual_section_once 'PASSO DE REPARO - Zen NVIDIA após congelamento' \
  '## PASSO DE REPARO - Zen NVIDIA após congelamento' \
  '' \
  'Em 2026-05-29 foi preparado boot limpo com linux-zen e nvidia-open-dkms sem carregar NVIDIA na sessão atual.' \
  '' \
  'A correção aplicada coloca módulos nvidia, nvidia_modeset, nvidia_uvm e nvidia_drm cedo no mkinitcpio, remove o hook kms para evitar nouveau cedo, adiciona blacklist nouveau e configura nvidia_drm.modeset=1 e nvidia_drm.fbdev=1 no bootloader.' \
  '' \
  'GPU persistence mode e nvidia-smi não devem ser ativados antes do primeiro boot Zen validado.'
fi

SCRIPT_COPY="$SCRIPT_DIR/${TS}-reparar-zen-nvidia-sem-carregar.sh"
cp -a /tmp/mocha-reparar-zen-nvidia-sem-carregar-20260529.sh "$SCRIPT_COPY" 2>/dev/null || true

say "Resumo"
printf '%s\n' "Zen preparado: $ZEN_KREL"
printf '%s\n' "Initramfs Zen: /boot/initramfs-linux-zen.img"
printf '%s\n' "Driver: nvidia-open-dkms 595.71.05"
printf '%s\n' "Log: $LOG"
printf '%s\n' "Script salvo: $SCRIPT_COPY"
printf '%s\n' "Agora reinicie manualmente e escolha a primeira entrada Zen. Se falhar, use a entrada antiga fallback."
