set -Eeuo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
REAL_USER="${SUDO_USER:-$USER}"
SUDO="sudo"
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
fi

fail() {
  echo
  echo "ERRO: $*"
  exit 1
}

say() { printf '\n== %s ==\n' "$*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "comando ausente: $1"
}

run_sudo() {
  if [ -n "$SUDO" ]; then
    sudo "$@"
  else
    "$@"
  fi
}

backup_keep_two() {
  local file="$1"
  [ -f "$file" ] || return 0
  local backup="${file}.bak-${TS}"
  run_sudo cp -a "$file" "$backup"
  printf 'Backup criado: %s\n' "$backup"
  local dir base
  dir="$(dirname "$file")"
  base="$(basename "$file")"
  run_sudo find "$dir" -maxdepth 1 -type f -name "${base}.bak-*" -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | tail -n +3 \
    | cut -d' ' -f2- \
    | while IFS= read -r old; do
        [ -n "$old" ] && run_sudo rm -f "$old"
      done || true
}

require_cmd findmnt
require_cmd blkid
require_cmd lsblk
require_cmd awk
require_cmd sed
require_cmd sort
require_cmd head
require_cmd find
require_cmd tee
require_cmd mount
require_cmd systemctl

say "Auditoria de discos antes de mexer"
lsblk -o NAME,PATH,FSTYPE,LABEL,PARTLABEL,UUID,SIZE,MOUNTPOINTS,TYPE

ROOT_SRC="$(findmnt -no SOURCE / | sed 's/\[.*\]$//' || true)"
ROOT_UUID=""
if [ -n "${ROOT_SRC:-}" ] && [ -e "$ROOT_SRC" ]; then
  ROOT_UUID="$(blkid -s UUID -o value "$ROOT_SRC" 2>/dev/null || true)"
fi

FAST_SCORE=0
VM_SCORE=0
FAST_DEV=""; FAST_UUID=""; FAST_FS=""; FAST_LABEL=""
VM_DEV=""; VM_UUID=""; VM_FS=""; VM_LABEL=""

reset_blk_vars() {
  DEVNAME=""; UUID=""; TYPE=""; LABEL=""; PARTLABEL=""
}

consider_blk() {
  [ -n "${DEVNAME:-}" ] || return 0
  [ -n "${UUID:-}" ] || return 0
  [ -n "${TYPE:-}" ] || return 0
  [ "$TYPE" != "swap" ] || return 0
  if [ -n "${ROOT_UUID:-}" ] && [ "$UUID" = "$ROOT_UUID" ]; then
    return 0
  fi

  local hay lower score
  hay="${LABEL:-} ${PARTLABEL:-}"
  lower="$(printf '%s' "$hay" | tr '[:upper:]' '[:lower:]')"

  score=0
  case "$lower" in
    *vmstore*|*"vm store"*|*vm-store*|*vm_store*) score=100 ;;
  esac
  if [ "$score" -gt "$VM_SCORE" ]; then
    VM_SCORE="$score"
    VM_DEV="$DEVNAME"
    VM_UUID="$UUID"
    VM_FS="$TYPE"
    VM_LABEL="${LABEL:-${PARTLABEL:-}}"
  fi

  score=0
  case "$lower" in
    *mochafast*|*"mocha fast"*) score=100 ;;
    *fast*) score=70 ;;
  esac
  if [ "$score" -gt "$FAST_SCORE" ]; then
    FAST_SCORE="$score"
    FAST_DEV="$DEVNAME"
    FAST_UUID="$UUID"
    FAST_FS="$TYPE"
    FAST_LABEL="${LABEL:-${PARTLABEL:-}}"
  fi
}

reset_blk_vars
while IFS= read -r line || [ -n "$line" ]; do
  if [ -z "$line" ]; then
    consider_blk
    reset_blk_vars
    continue
  fi
  key="${line%%=*}"
  val="${line#*=}"
  case "$key" in
    DEVNAME) DEVNAME="$val" ;;
    UUID) UUID="$val" ;;
    TYPE) TYPE="$val" ;;
    LABEL) LABEL="$val" ;;
    PARTLABEL) PARTLABEL="$val" ;;
  esac
done < <(run_sudo blkid -o export; printf '\n')

say "Candidatos detectados"
printf 'VMSTORE: dev=%s uuid=%s fs=%s label=%s score=%s\n' "$VM_DEV" "$VM_UUID" "$VM_FS" "$VM_LABEL" "$VM_SCORE"
printf 'FAST:    dev=%s uuid=%s fs=%s label=%s score=%s\n' "$FAST_DEV" "$FAST_UUID" "$FAST_FS" "$FAST_LABEL" "$FAST_SCORE"

if [ -z "$VM_UUID" ] || [ -z "$FAST_UUID" ]; then
  echo
  echo "Não consegui detectar VMSTORE e FAST por LABEL/PARTLABEL."
  echo "Não vou chutar disco nem escrever fstab às cegas."
  echo "Ajuste labels ou informe quais UUIDs são VMSTORE e FAST."
  exit 2
fi

if [ "$VM_UUID" = "$FAST_UUID" ]; then
  fail "VMSTORE e FAST apontaram para o mesmo UUID; abortado para não montar disco errado."
fi

opts_for() {
  local role="$1" fs="$2"
  case "$role:$fs" in
    fast:btrfs) printf '%s' 'rw,noatime,compress=zstd:3,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show,x-gvfs-name=MochaFAST' ;;
    fast:xfs|fast:ext4) printf '%s' 'rw,noatime,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show,x-gvfs-name=MochaFAST' ;;
    vm:btrfs) printf '%s' 'rw,noatime,compress=zstd:3,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show,x-gvfs-name=VMSTORE' ;;
    vm:xfs|vm:ext4) printf '%s' 'rw,noatime,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show,x-gvfs-name=VMSTORE' ;;
    *) printf '%s' 'rw,noatime,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show' ;;
  esac
}

FAST_OPTS="$(opts_for fast "$FAST_FS")"
VM_OPTS="$(opts_for vm "$VM_FS")"

say "Preparando pontos de montagem"
run_sudo install -d -m 0755 /media/vmstore /media/mochafast

for pair in "/media/vmstore:$VM_UUID" "/media/mochafast:$FAST_UUID"; do
  mp="${pair%%:*}"
  expected="${pair#*:}"
  if mountpoint -q "$mp"; then
    current="$(findmnt -no UUID "$mp" 2>/dev/null || true)"
    if [ -n "$current" ] && [ "$current" != "$expected" ]; then
      fail "$mp já está montado com UUID $current, mas o esperado é $expected. Não vou desmontar automaticamente."
    fi
  fi
done

say "Atualizando /etc/fstab sem empilhar entradas antigas desses mountpoints"
backup_keep_two /etc/fstab
TMP_FSTAB="$(mktemp)"
awk '
  /^[[:space:]]*#/ { print; next }
  NF >= 2 && ($2 == "/media/vmstore" || $2 == "/media/mochafast") { next }
  /MOCHA_AUTO_MOUNT_FAST_VM/ { next }
  { print }
' /etc/fstab > "$TMP_FSTAB"

{
  printf '\n# MOCHA_AUTO_MOUNT_FAST_VM atualizado em %s\n' "$TS"
  printf 'UUID=%s /media/vmstore %s %s 0 0\n' "$VM_UUID" "$VM_FS" "$VM_OPTS"
  printf 'UUID=%s /media/mochafast %s %s 0 0\n' "$FAST_UUID" "$FAST_FS" "$FAST_OPTS"
} >> "$TMP_FSTAB"

run_sudo install -m 0644 "$TMP_FSTAB" /etc/fstab
rm -f "$TMP_FSTAB"

say "Recarregando systemd e montando agora"
run_sudo systemctl daemon-reload
run_sudo mount /media/vmstore || true
run_sudo mount /media/mochafast || true
ls /media/vmstore >/dev/null 2>&1 || true
ls /media/mochafast >/dev/null 2>&1 || true

say "Validação dos mounts"
findmnt /media/vmstore || fail "/media/vmstore não montou. Verifique o fstab e o disco."
findmnt /media/mochafast || fail "/media/mochafast não montou. Verifique o fstab e o disco."

say "Criando estrutura ativa no FAST"
run_sudo install -d -m 775 \
  /media/mochafast/MochaArch/ativo/documentacao \
  /media/mochafast/MochaArch/ativo/scripts \
  /media/mochafast/MochaArch/ativo/logs

run_sudo chown "$REAL_USER:$REAL_USER" \
  /media/mochafast/MochaArch \
  /media/mochafast/MochaArch/ativo \
  /media/mochafast/MochaArch/ativo/documentacao \
  /media/mochafast/MochaArch/ativo/scripts \
  /media/mochafast/MochaArch/ativo/logs 2>/dev/null || true

SCRIPT_DEST="/media/mochafast/MochaArch/ativo/scripts/${TS}-montar-fast-vm-ler-manual.sh"
if [ -f "${BASH_SOURCE[0]}" ]; then
  cp -a "${BASH_SOURCE[0]}" "$SCRIPT_DEST" 2>/dev/null || true
fi

MANUAL="/media/mochafast/MochaArch/ativo/documentacao/manual-montagem-mochaarch.md"
if [ ! -f "$MANUAL" ]; then
  {
    printf '# Manual de montagem - Mocha Arch KDE\n\n'
    printf 'Arquivo canônico operacional criado em %s.\n\n' "$TS"
  } > "$MANUAL"
fi

if ! grep -Fq 'PASSO ZERO - montar FAST e VMSTORE' "$MANUAL"; then
  {
    printf '\n---\n\n'
    printf '## PASSO ZERO - montar FAST e VMSTORE\n\n'
    printf 'Antes de procurar manual, aplicar tema, ajustar KDE, instalar kernel, mexer no driver NVIDIA ou documentar qualquer etapa, montar obrigatoriamente:\n\n'
    printf '- VMSTORE em `/media/vmstore`;\n'
    printf '- FAST em `/media/mochafast`;\n'
    printf '- ambos de forma persistente em `/etc/fstab`;\n'
    printf '- ambos visíveis no Dolphin com `x-gvfs-show`;\n'
    printf '- sem tocar na pasta `XU` salvo ordem explícita.\n\n'
    printf 'Regra operacional: se FAST/VMSTORE não estiverem montados, o assistente deve montar primeiro e só depois procurar ou editar o manual.\n'
  } >> "$MANUAL"
fi

if ! grep -Fq 'ERRO PROIBIDO - comando grande sem validação de sintaxe' "$MANUAL"; then
  {
    printf '\n---\n\n'
    printf '## ERRO PROIBIDO - comando grande sem validação de sintaxe\n\n'
    printf 'Não entregar blocos shell grandes com Python/heredocs/aspas complexas sem gravar script temporário e validar com `bash -n` antes de executar ações reais.\n\n'
    printf 'Erro ocorrido em 2026-05-29: um bloco de instalação do kernel Zen/NVIDIA instalou pacotes e rodou DKMS/mkinitcpio, mas quebrou depois com erro de sintaxe perto de `GRUB_CMDLINE_LINUX_DEFAULT=`. Isso deixou o sistema em estado parcial.\n\n'
    printf 'Regra de reparo: depois de erro assim, auditar o estado real e completar/reparar. Não reinstalar às cegas, não reiniciar antes de validar bootloader, initramfs e módulos NVIDIA.\n'
  } >> "$MANUAL"
fi

say "Manuais encontrados agora que FAST/VMSTORE estão montados"
find /media/mochafast/MochaArch /media/mochafast/MochaCanonico /media/vmstore/MochaCanonico \
  -path '*/XU/*' -prune -o \
  -type f \( -iname '*manual*.md' -o -iname '*montagem*.md' -o -iname '*mocha*.md' -o -iname '*passo*.md' -o -iname '*kernel*.md' -o -iname '*nvidia*.md' \) \
  -printf '%T@ %TY-%Tm-%Td %TH:%TM %p\n' 2>/dev/null \
  | sort -nr \
  | head -n 40

say "Conteúdo dos manuais mais prováveis"
mapfile -t FILES < <(
  find /media/mochafast/MochaArch /media/mochafast/MochaCanonico /media/vmstore/MochaCanonico \
    -path '*/XU/*' -prune -o \
    -type f \( -iname '*manual*.md' -o -iname '*montagem*.md' -o -iname '*mocha*.md' -o -iname '*passo*.md' -o -iname '*kernel*.md' -o -iname '*nvidia*.md' \) \
    -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | head -n 10 \
    | cut -d' ' -f2-
)

for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  printf '\n================================================================\n'
  printf 'ARQUIVO: %s\n' "$f"
  printf '================================================================\n'
  sed -n '1,260p' "$f"
done

say "Resumo final"
printf 'VMSTORE montado em: /media/vmstore\n'
printf 'FAST montado em:    /media/mochafast\n'
printf 'Manual atualizado:  %s\n' "$MANUAL"
printf 'Script salvo em:    %s\n' "$SCRIPT_DEST"
printf 'Próximo passo: com o manual visível, completar o reparo Zen/NVIDIA sem reiniciar antes da validação.\n'
