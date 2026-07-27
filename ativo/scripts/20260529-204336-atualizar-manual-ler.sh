set -Eeuo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
REAL_USER="${SUDO_USER:-$USER}"
BASE="/media/mochafast/MochaArch/ativo"
DOC_DIR="$BASE/documentacao"
SCRIPT_DIR="$BASE/scripts"
LOG_DIR="$BASE/logs"
MANUAL="$DOC_DIR/manual-montagem-mochaarch.md"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*"
  exit 1
}

append_line() {
  printf '%s\n' "$1" >> "$MANUAL"
}

append_blank() {
  printf '\n' >> "$MANUAL"
}

append_section_start() {
  append_blank
  append_line '---'
  append_blank
}

add_section_once() {
  marker="$1"
  shift
  if grep -Fq "$marker" "$MANUAL" 2>/dev/null; then
    return 0
  fi
  append_section_start
  while [ "$#" -gt 0 ]; do
    append_line "$1"
    shift
  done
}

say "Validando FAST e VMSTORE"
findmnt /media/vmstore || fail "/media/vmstore não está montado."
findmnt /media/mochafast || fail "/media/mochafast não está montado."

say "Validando persistência no fstab"
grep -E '[[:space:]]/media/vmstore[[:space:]]' /etc/fstab || fail "/media/vmstore não está no /etc/fstab."
grep -E '[[:space:]]/media/mochafast[[:space:]]' /etc/fstab || fail "/media/mochafast não está no /etc/fstab."

say "Garantindo estrutura ativa"
sudo install -d -m 775 "$DOC_DIR" "$SCRIPT_DIR" "$LOG_DIR"
sudo chown -R "$REAL_USER:$REAL_USER" /media/mochafast/MochaArch 2>/dev/null || true

if [ ! -f "$MANUAL" ]; then
  printf '%s\n' '# Manual de montagem - Mocha Arch KDE' > "$MANUAL"
  printf '\n%s\n' "Arquivo operacional criado em $TS." >> "$MANUAL"
fi

say "Registrando regras obrigatórias no manual"

add_section_once 'PASSO ZERO - montar FAST e VMSTORE' \
'## PASSO ZERO - montar FAST e VMSTORE' \
'' \
'Antes de procurar manual, aplicar tema, ajustar KDE, instalar kernel, mexer no driver NVIDIA, aplicar receita de performance ou documentar qualquer etapa, montar obrigatoriamente:' \
'' \
'- VMSTORE em /media/vmstore;' \
'- FAST em /media/mochafast;' \
'- ambos de forma persistente em /etc/fstab;' \
'- ambos visíveis no Dolphin com x-gvfs-show ou nome GVFS quando aplicável;' \
'- sem tocar na pasta XU salvo ordem explícita.' \
'' \
'Regra operacional: se FAST/VMSTORE não estiverem montados, o assistente deve montar primeiro e só depois procurar, editar ou criar o manual.'

add_section_once 'ERRO PROIBIDO - comando grande sem validação de sintaxe' \
'## ERRO PROIBIDO - comando grande sem validação de sintaxe' \
'' \
'Não entregar blocos shell grandes com Python, heredocs ou aspas complexas sem gravar script temporário e validar com bash -n antes de executar ações reais.' \
'' \
'Erro ocorrido em 2026-05-29: um bloco de instalação do kernel Zen/NVIDIA instalou pacotes e rodou DKMS/mkinitcpio, mas quebrou depois com erro de sintaxe perto de GRUB_CMDLINE_LINUX_DEFAULT=. Isso deixou o sistema em estado parcial.' \
'' \
'Regra de reparo: depois de erro assim, auditar o estado real e completar/reparar. Não reinstalar às cegas, não reiniciar antes de validar bootloader, initramfs e módulos NVIDIA.'

add_section_once 'ERRO PROIBIDO - printf com texto começando por hífen' \
'## ERRO PROIBIDO - printf com texto começando por hífen' \
'' \
'Não usar printf diretamente com texto literal começando por hífen, como printf "- texto".' \
'' \
'Forma correta: printf "%s\n" "- texto".' \
'' \
'Regra operacional: em scripts Mocha, toda saída textual começando com hífen deve usar formato explícito ou outra forma segura.'

add_section_once 'ERRO PROIBIDO - markdown fence ou heredoc aninhado dentro de heredoc colável' \
'## ERRO PROIBIDO - markdown fence ou heredoc aninhado dentro de heredoc colável' \
'' \
'Não colocar documentação com cercas de Markdown nem heredocs internos dentro de um script que já está sendo entregue ao usuário como heredoc colável no terminal.' \
'' \
'Erro ocorrido em 2026-05-29: ao tentar registrar no manual um exemplo com bloco de Markdown dentro do script, a colagem ficou presa no prompt secundário do shell.' \
'' \
'Regra operacional: para escrever manual dentro de script colável, usar função append_line com printf "%s\n" "$texto" linha por linha, sem heredoc aninhado e sem cercas de Markdown.'

SCRIPT_COPY="$SCRIPT_DIR/${TS}-atualizar-manual-ler.sh"
cp -a /tmp/mocha-atualizar-manual-ler-20260529.sh "$SCRIPT_COPY" 2>/dev/null || true

say "Manuais encontrados"
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

if [ "${#FILES[@]}" -eq 0 ]; then
  FILES=("$MANUAL")
fi

for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  printf '\n================================================================\n'
  printf 'ARQUIVO: %s\n' "$f"
  printf '================================================================\n'
  sed -n '1,280p' "$f"
done

say "Resumo"
printf '%s\n' "VMSTORE: $(findmnt -no SOURCE,FSTYPE,TARGET /media/vmstore)"
printf '%s\n' "FAST:    $(findmnt -no SOURCE,FSTYPE,TARGET /media/mochafast)"
printf '%s\n' "Manual atualizado: $MANUAL"
printf '%s\n' "Script salvo: $SCRIPT_COPY"
printf '%s\n' "Próximo passo: auditar o estado parcial Zen/NVIDIA e completar o reparo sem reiniciar antes da validação."
