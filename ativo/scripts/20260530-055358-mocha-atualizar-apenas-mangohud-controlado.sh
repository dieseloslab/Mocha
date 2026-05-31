#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"

FAST_BASE="/media/mochafast/MochaArch"
VM_BASE="/media/vmstore/MochaArch"

DOC_DIR="$FAST_BASE/ativo/documentacao"
SCRIPT_DIR="$FAST_BASE/ativo/scripts"
REPORT_DIR="$FAST_BASE/ativo/relatorios"

PACMAN_CONF="/etc/pacman.conf"

LOG="$REPORT_DIR/${TS}-atualizacao-controlada-apenas-mangohud.log"
DOC="$DOC_DIR/${TS}-atualizacao-controlada-apenas-mangohud.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-atualizar-apenas-mangohud-controlado.sh"

UPDATES_BEFORE="$REPORT_DIR/${TS}-pacman-Qu-antes-mangohud.txt"
UPDATES_AFTER="$REPORT_DIR/${TS}-pacman-Qu-depois-mangohud.txt"
MANGOHUD_BEFORE="$REPORT_DIR/${TS}-mangohud-antes.txt"
MANGOHUD_SYNC="$REPORT_DIR/${TS}-mangohud-sync-repo.txt"
MANGOHUD_AFTER="$REPORT_DIR/${TS}-mangohud-depois.txt"
FOREIGN_LIST="$REPORT_DIR/${TS}-pacotes-foreign-pos-mangohud.txt"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

if [ "$(id -u)" -eq 0 ]; then
  SUDO=()
else
  command -v sudo >/dev/null 2>&1 || fail "sudo não encontrado."
  SUDO=(sudo)
fi

append_doc() {
  printf '%s\n' "$1" >> "$DOC"
}

say "Pré-checagens obrigatórias"
findmnt /media/vmstore >/dev/null || fail "/media/vmstore não está montado."
findmnt /media/mochafast >/dev/null || fail "/media/mochafast não está montado."
[ -f "$PACMAN_CONF" ] || fail "$PACMAN_CONF não existe."
[ -r "$PACMAN_CONF" ] || fail "$PACMAN_CONF não pode ser lido."

mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Ambiente"
printf '%s\n' "Timestamp: $TS"
printf '%s\n' "Usuário: $(id -un)"
printf '%s\n' "Kernel: $(uname -r)"
printf '%s\n' "Pacman: $(pacman -V | sed -n '/Pacman v/{s/^[[:space:]]*//;p;q}')"
printf '%s\n' "Log: $LOG"

say "Confirmando repositórios ativos"
awk '
  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    sec=$0
    gsub(/^[[:space:]]*\[/, "", sec)
    gsub(/\][[:space:]]*$/, "", sec)
    print sec
  }
' "$PACMAN_CONF"

awk '
  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    sec=$0
    gsub(/^[[:space:]]*\[/, "", sec)
    gsub(/\][[:space:]]*$/, "", sec)
    print sec
  }
' "$PACMAN_CONF" | grep -q '^mocha-stable$' || fail "mocha-stable não está ativo."

if awk '
  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    sec=$0
    gsub(/^[[:space:]]*\[/, "", sec)
    gsub(/\][[:space:]]*$/, "", sec)
    print sec
  }
' "$PACMAN_CONF" | grep -q '^mocha-testing$'; then
  fail "mocha-testing está ativo. Não vou prosseguir."
fi

say "Listando atualizações antes da alteração"
if pacman -Qu > "$UPDATES_BEFORE"; then
  true
else
  STATUS="$?"
  if [ "$STATUS" -eq 1 ]; then
    : > "$UPDATES_BEFORE"
  else
    fail "pacman -Qu falhou com código $STATUS."
  fi
fi

cat "$UPDATES_BEFORE"

UPDATE_COUNT="$(wc -l < "$UPDATES_BEFORE" | tr -d ' ')"
printf '%s\n' "Total de atualizações antes: $UPDATE_COUNT"

say "Bloqueio de segurança contra atualização crítica"
if awk '
  {
    pkg=$1
    if (pkg ~ /^(linux|linux-[A-Za-z0-9_.+-]+|nvidia|nvidia-[A-Za-z0-9_.+-]+|lib32-nvidia-[A-Za-z0-9_.+-]+|mesa|lib32-mesa|vulkan-[A-Za-z0-9_.+-]+|lib32-vulkan-[A-Za-z0-9_.+-]+|xf86-video-[A-Za-z0-9_.+-]+|egl-wayland|wayland|wayland-protocols|opencl-[A-Za-z0-9_.+-]+|lib32-opencl-[A-Za-z0-9_.+-]+|systemd|systemd-libs|systemd-sysvcompat|pacman|archlinux-keyring|glibc|gcc-libs|filesystem|bash|coreutils|util-linux|sudo|mkinitcpio|mkinitcpio-[A-Za-z0-9_.+-]+|grub|efibootmgr|os-prober|btrfs-progs|xfsprogs)$/) {
      print
      found=1
    }
  }
  END { exit found ? 0 : 1 }
' "$UPDATES_BEFORE"; then
  fail "A lista de atualizações contém pacote crítico. Não vou atualizar nada."
else
  printf '%s\n' "Nenhum pacote crítico apareceu em pacman -Qu."
fi

say "Validando que MangoHud está instalado e tem atualização"
pacman -Q mangohud | tee "$MANGOHUD_BEFORE"

if ! grep -q '^mangohud ' "$UPDATES_BEFORE"; then
  fail "mangohud não aparece como atualização pendente. Não vou forçar instalação."
fi

if grep -v '^mangohud ' "$UPDATES_BEFORE" | grep -q .; then
  printf '%s\n' "Há outras atualizações não críticas pendentes, mas elas NÃO serão instaladas agora:"
  grep -v '^mangohud ' "$UPDATES_BEFORE"
else
  printf '%s\n' "MangoHud é a única atualização pendente."
fi

say "Consultando versão disponível no repositório"
pacman -Si mangohud | tee "$MANGOHUD_SYNC"

say "Verificando pacote antigo em cache para eventual rollback"
find /var/cache/pacman/pkg -maxdepth 1 -type f -name 'mangohud-*.pkg.tar.*' -printf '%T@ %p\n' 2>/dev/null \
  | sort -nr \
  | sed 's/^[^ ]* //' \
  | head -n 10 || true

say "Atualizando somente mangohud"
printf '%s\n' "Comando: sudo pacman -S --needed --noconfirm mangohud"
printf '%s\n' "Não será executado pacman -Syu."
"${SUDO[@]}" pacman -S --needed --noconfirm mangohud

say "Validando MangoHud após atualização"
pacman -Q mangohud | tee "$MANGOHUD_AFTER"

if command -v mangohud >/dev/null 2>&1; then
  mangohud --version 2>&1 || true
else
  printf '%s\n' "Comando mangohud não encontrado no PATH, mas pacote pacman foi validado."
fi

say "Listando atualizações restantes"
if pacman -Qu > "$UPDATES_AFTER"; then
  true
else
  STATUS="$?"
  if [ "$STATUS" -eq 1 ]; then
    : > "$UPDATES_AFTER"
  else
    fail "pacman -Qu pós-atualização falhou com código $STATUS."
  fi
fi

cat "$UPDATES_AFTER" || true

say "Auditando pacotes foreign/AUR/locais sem atualizar"
if pacman -Qm > "$FOREIGN_LIST"; then
  true
else
  STATUS="$?"
  if [ "$STATUS" -eq 1 ]; then
    : > "$FOREIGN_LIST"
  else
    fail "pacman -Qm falhou com código $STATUS."
  fi
fi

cat "$FOREIGN_LIST" || true

say "Gerando documentação"
: > "$DOC"

append_doc "# Mocha Arch - atualização controlada apenas do MangoHud"
append_doc ""
append_doc "Data: $TS"
append_doc ""
append_doc "## Resultado"
append_doc ""
append_doc "- Foi atualizada somente a família alvo: \`mangohud\`."
append_doc "- Não foi executado \`pacman -Syu\`."
append_doc "- Não foi feita atualização geral do sistema."
append_doc "- Kernel, NVIDIA, Mesa, Vulkan, Wayland, boot e base crítica foram bloqueados por auditoria antes da alteração."
append_doc "- Pacotes AUR/foreign foram apenas listados, sem atualização."
append_doc ""
append_doc "## Antes"
append_doc ""
append_doc "\`\`\`"
cat "$MANGOHUD_BEFORE" >> "$DOC"
append_doc "\`\`\`"
append_doc ""
append_doc "## Depois"
append_doc ""
append_doc "\`\`\`"
cat "$MANGOHUD_AFTER" >> "$DOC"
append_doc "\`\`\`"
append_doc ""
append_doc "## Atualizações restantes após o teste"
append_doc ""
append_doc "\`\`\`"
if [ -s "$UPDATES_AFTER" ]; then
  cat "$UPDATES_AFTER" >> "$DOC"
else
  printf '%s\n' "Nenhuma atualização restante." >> "$DOC"
fi
append_doc "\`\`\`"
append_doc ""
append_doc "## Pacotes foreign/AUR/locais registrados"
append_doc ""
append_doc "\`\`\`"
if [ -s "$FOREIGN_LIST" ]; then
  cat "$FOREIGN_LIST" >> "$DOC"
else
  printf '%s\n' "Nenhum pacote foreign/AUR/local detectado." >> "$DOC"
fi
append_doc "\`\`\`"
append_doc ""
append_doc "## Arquivos"
append_doc ""
append_doc "- Log: \`$LOG\`"
append_doc "- Atualizações antes: \`$UPDATES_BEFORE\`"
append_doc "- Atualizações depois: \`$UPDATES_AFTER\`"
append_doc "- MangoHud antes: \`$MANGOHUD_BEFORE\`"
append_doc "- MangoHud repo sync: \`$MANGOHUD_SYNC\`"
append_doc "- MangoHud depois: \`$MANGOHUD_AFTER\`"
append_doc "- Foreign/AUR: \`$FOREIGN_LIST\`"
append_doc "- Script reutilizável: \`$SCRIPT_COPY\`"
append_doc ""
append_doc "## Próximo teste manual"
append_doc ""
append_doc "- Abrir um jogo pela Steam."
append_doc "- Confirmar se o overlay do MangoHud aparece."
append_doc "- Confirmar se FPS/frametime continuam bons."
append_doc "- Se houver regressão, usar o pacote antigo em \`/var/cache/pacman/pkg\` para rollback."

say "Salvando script reutilizável"
install -m 0755 "$0" "$SCRIPT_COPY"

say "Concluído"
printf '%s\n' "Documentação: $DOC"
printf '%s\n' "Log: $LOG"
printf '%s\n' "Script: $SCRIPT_COPY"
