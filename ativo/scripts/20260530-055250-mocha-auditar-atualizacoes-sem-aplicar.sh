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

LOG="$REPORT_DIR/${TS}-auditoria-atualizacoes-sem-aplicar.log"
DOC="$DOC_DIR/${TS}-auditoria-atualizacoes-sem-aplicar.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-auditar-atualizacoes-sem-aplicar.sh"

RAW_UPDATES="$REPORT_DIR/${TS}-pacman-Qu-bruto.txt"
TSV_UPDATES="$REPORT_DIR/${TS}-pacman-Qu-classificado.tsv"
FOREIGN_LIST="$REPORT_DIR/${TS}-pacotes-foreign-aur-ou-locais.txt"
REPO_LIST="$REPORT_DIR/${TS}-repositorios-ativos-pacman.txt"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

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
printf '%s\n' "Documento: $DOC"

say "Confirmando repositórios ativos"
awk '
  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    sec=$0
    gsub(/^[[:space:]]*\[/, "", sec)
    gsub(/\][[:space:]]*$/, "", sec)
    print sec
  }
' "$PACMAN_CONF" | tee "$REPO_LIST"

grep -q '^mocha-stable$' "$REPO_LIST" || fail "mocha-stable não está ativo no pacman.conf."
if grep -q '^mocha-testing$' "$REPO_LIST"; then
  fail "mocha-testing está ativo, o que não deve acontecer agora."
fi

say "Auditando atualizações disponíveis sem aplicar nada"
printf '%s\n' "Comando usado: pacman -Qu"
printf '%s\n' "Não será executado pacman -Syu."

if pacman -Qu > "$RAW_UPDATES"; then
  true
else
  STATUS="$?"
  if [ "$STATUS" -eq 1 ]; then
    : > "$RAW_UPDATES"
  else
    fail "pacman -Qu falhou com código $STATUS."
  fi
fi

UPDATE_COUNT="$(wc -l < "$RAW_UPDATES" | tr -d ' ')"
printf '%s\n' "Total de atualizações disponíveis: $UPDATE_COUNT"

say "Classificando atualizações"
{
  printf '%s\t%s\t%s\t%s\t%s\n' "classe" "pacote" "versao_instalada" "versao_disponivel" "motivo"

  awk '
    NF >= 4 && $3 == "->" {
      pkg=$1
      old=$2
      new=$4
      classe="CANDIDATO_TESTE"
      motivo="programa comum; pode ser avaliado depois"

      if (pkg ~ /^(linux|linux-[A-Za-z0-9_.+-]+|nvidia|nvidia-[A-Za-z0-9_.+-]+|lib32-nvidia-[A-Za-z0-9_.+-]+|mesa|lib32-mesa|vulkan-[A-Za-z0-9_.+-]+|lib32-vulkan-[A-Za-z0-9_.+-]+|xf86-video-[A-Za-z0-9_.+-]+|egl-wayland|wayland|wayland-protocols|opencl-[A-Za-z0-9_.+-]+|lib32-opencl-[A-Za-z0-9_.+-]+)$/) {
        classe="BLOQUEADO_GRAFICO_KERNEL"
        motivo="kernel, NVIDIA, Mesa, Vulkan, Wayland ou pilha grafica; nao atualizar sem teste especifico"
      } else if (pkg ~ /^(systemd|systemd-libs|systemd-sysvcompat|pacman|pacman-mirrorlist|archlinux-keyring|glibc|gcc-libs|filesystem|bash|coreutils|util-linux|sudo|mkinitcpio|mkinitcpio-[A-Za-z0-9_.+-]+|grub|efibootmgr|os-prober|btrfs-progs|xfsprogs)$/) {
        classe="BLOQUEADO_BASE_BOOT"
        motivo="base critica, boot, initramfs, gerenciador de pacotes ou bibliotecas centrais"
      }

      printf "%s\t%s\t%s\t%s\t%s\n", classe, pkg, old, new, motivo
    }
  ' "$RAW_UPDATES"
} > "$TSV_UPDATES"

say "Resumo por classe"
if [ "$UPDATE_COUNT" -eq 0 ]; then
  printf '%s\n' "Nenhuma atualização disponível no momento."
else
  cut -f1 "$TSV_UPDATES" | tail -n +2 | sort | uniq -c | sort -nr
fi

say "Pacotes bloqueados por segurança"
awk -F '\t' '
  NR == 1 { next }
  $1 ~ /^BLOQUEADO_/ {
    printf "%-28s %-40s %s -> %s\n", $1, $2, $3, $4
  }
' "$TSV_UPDATES" || true

say "Primeiros candidatos não críticos"
awk -F '\t' '
  NR == 1 { next }
  $1 == "CANDIDATO_TESTE" {
    printf "%-40s %s -> %s\n", $2, $3, $4
  }
' "$TSV_UPDATES" | head -n 80 || true

say "Auditando pacotes foreign/AUR/locais instalados"
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

FOREIGN_COUNT="$(wc -l < "$FOREIGN_LIST" | tr -d ' ')"
printf '%s\n' "Total de pacotes foreign/AUR/locais instalados: $FOREIGN_COUNT"

if [ "$FOREIGN_COUNT" -gt 0 ]; then
  sed -n '1,120p' "$FOREIGN_LIST"
else
  printf '%s\n' "Nenhum pacote foreign/AUR/local detectado."
fi

say "Gerando documentação"
: > "$DOC"

append_doc "# Mocha Arch - auditoria de atualizações sem aplicar"
append_doc ""
append_doc "Data: $TS"
append_doc ""
append_doc "## Resultado"
append_doc ""
append_doc "- O sistema foi auditado sem aplicar atualizações."
append_doc "- Não foi executado \`pacman -Syu\`."
append_doc "- O comando usado para atualizações disponíveis foi \`pacman -Qu\`."
append_doc "- O repositório \`mocha-stable\` está ativo."
append_doc "- O repositório \`mocha-testing\` não está ativo."
append_doc ""
append_doc "## Totais"
append_doc ""
append_doc "- Atualizações disponíveis: $UPDATE_COUNT"
append_doc "- Pacotes foreign/AUR/locais instalados: $FOREIGN_COUNT"
append_doc ""
append_doc "## Política aplicada"
append_doc ""
append_doc "- Kernel, NVIDIA, Mesa, Vulkan, Wayland e pilha gráfica foram classificados como bloqueados."
append_doc "- Base crítica, boot, initramfs, pacman, keyring, glibc, systemd e sudo foram classificados como bloqueados."
append_doc "- Programas comuns foram classificados apenas como candidatos de teste."
append_doc "- AUR/foreign foi apenas listado; não entra em atualização geral."
append_doc "- A promoção para o Mocha deve continuar pacote a pacote, primeiro em teste, depois em stable."
append_doc ""
append_doc "## Arquivos gerados"
append_doc ""
append_doc "- Log: \`$LOG\`"
append_doc "- Repositórios ativos: \`$REPO_LIST\`"
append_doc "- Saída bruta do \`pacman -Qu\`: \`$RAW_UPDATES\`"
append_doc "- Classificação TSV: \`$TSV_UPDATES\`"
append_doc "- Pacotes foreign/AUR/locais: \`$FOREIGN_LIST\`"
append_doc "- Script reutilizável: \`$SCRIPT_COPY\`"
append_doc ""
append_doc "## Resumo por classe"
append_doc ""

if [ "$UPDATE_COUNT" -eq 0 ]; then
  append_doc "- Nenhuma atualização disponível."
else
  cut -f1 "$TSV_UPDATES" | tail -n +2 | sort | uniq -c | sort -nr | while read -r count classe; do
    append_doc "- $classe: $count"
  done
fi

append_doc ""
append_doc "## Bloqueados"
append_doc ""

if awk -F '\t' 'NR > 1 && $1 ~ /^BLOQUEADO_/ { found=1 } END { exit found ? 0 : 1 }' "$TSV_UPDATES"; then
  awk -F '\t' '
    NR > 1 && $1 ~ /^BLOQUEADO_/ {
      printf "- `%s`: `%s` -> `%s` — %s\n", $2, $3, $4, $5
    }
  ' "$TSV_UPDATES" >> "$DOC"
else
  append_doc "- Nenhum pacote bloqueado apareceu na lista de atualizações."
fi

append_doc ""
append_doc "## Próxima ação recomendada"
append_doc ""
append_doc "- Não atualizar ainda."
append_doc "- Revisar a lista de candidatos comuns."
append_doc "- Escolher um lote pequeno de pacotes não críticos para teste controlado."
append_doc "- Manter kernel/NVIDIA/Mesa/Vulkan/boot congelados até teste específico."

say "Salvando script reutilizável"
install -m 0755 "$0" "$SCRIPT_COPY"

say "Concluído"
printf '%s\n' "Documentação: $DOC"
printf '%s\n' "Log: $LOG"
printf '%s\n' "Classificação: $TSV_UPDATES"
printf '%s\n' "Foreign/AUR: $FOREIGN_LIST"
printf '%s\n' "Script: $SCRIPT_COPY"
