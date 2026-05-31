#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"
LC_ALL=C

TS="$(date +%Y%m%d-%H%M%S)"
FAST_BASE="/media/mochafast/MochaArch"
ACTIVE="$FAST_BASE/ativo"
DOC_DIR="$ACTIVE/documentacao"
REPORT_DIR="$ACTIVE/relatorios"
SCRIPT_DIR="$ACTIVE/scripts"

REPORT="$REPORT_DIR/${TS}-regra-sudo-keepalive-instalacoes.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-registrar-regra-sudo-keepalive-instalacoes.sh"

say() { printf '\n== %s ==\n' "$*"; }
fail() { printf '\nERRO: %s\n' "$*" >&2; exit 1; }
append_line() { printf '%s\n' "$1" >> "$2"; }

say "Validando FAST e estrutura MochaArch"
findmnt /media/mochafast >/dev/null 2>&1 || fail "/media/mochafast não está montado."

mkdir -p -- "$DOC_DIR" "$REPORT_DIR" "$SCRIPT_DIR"

[ -w "$DOC_DIR" ] || fail "Sem permissão de escrita em $DOC_DIR."
[ -w "$REPORT_DIR" ] || fail "Sem permissão de escrita em $REPORT_DIR."
[ -w "$SCRIPT_DIR" ] || fail "Sem permissão de escrita em $SCRIPT_DIR."

say "Salvando cópia reutilizável deste script"
cp -a -- "$0" "$SCRIPT_COPY" 2>/dev/null || true
chmod +x "$SCRIPT_COPY" 2>/dev/null || true

say "Localizando manual principal"
MANUAL=""
if find "$DOC_DIR" -maxdepth 1 -type f -iname '*manual*.md' -print -quit | grep -q .; then
  MANUAL="$(find "$DOC_DIR" -maxdepth 1 -type f -iname '*manual*.md' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
fi

if [ -z "$MANUAL" ]; then
  MANUAL="$DOC_DIR/${TS}-manual-operacional-mocha-arch.md"
  append_line "# Manual Operacional Mocha Arch" "$MANUAL"
  append_line "" "$MANUAL"
  append_line "Criado em: $TS" "$MANUAL"
fi

[ -f "$MANUAL" ] || fail "Manual não encontrado/criado corretamente: $MANUAL"

say "Manual selecionado"
printf '%s\n' "$MANUAL"

say "Auditando final atual do manual antes da alteração"
tail -n 30 "$MANUAL" || true

say "Criando backup controlado do manual"
BACKUP="${MANUAL}.bak-${TS}"
cp -a -- "$MANUAL" "$BACKUP"

say "Anotando regra operacional de sudo/keepalive para instalações"
append_line "" "$MANUAL"
append_line "---" "$MANUAL"
append_line "" "$MANUAL"
append_line "# Entrada $TS - Regra obrigatória para sudo, keepalive e instalações" "$MANUAL"
append_line "" "$MANUAL"
append_line "## Problema corrigido" "$MANUAL"
append_line "" "$MANUAL"
append_line "Comandos de instalação não podem pedir senha sudo repetidamente, especialmente durante instalação de vários pacotes oficiais, Flatpak ou AUR." "$MANUAL"
append_line "" "$MANUAL"
append_line "Se o usuário mandou instalar pacotes, o fluxo correto é assumir uma instalação não interativa depois da autenticação inicial." "$MANUAL"
append_line "" "$MANUAL"
append_line "## Regra obrigatória" "$MANUAL"
append_line "" "$MANUAL"
append_line "1. Todo comando de instalação deve chamar sudo -v no começo." "$MANUAL"
append_line "2. Todo comando de instalação demorado deve manter sudo vivo com keepalive até o fim." "$MANUAL"
append_line "3. Depois da senha inicial, o comando não deve pedir senha pacote por pacote." "$MANUAL"
append_line "4. Em NixOS, quando aplicável, usar /run/wrappers/bin/sudo como sudo preferencial." "$MANUAL"
append_line "5. Em Arch/MochaArch, pacotes oficiais devem ser instalados em lote com pacman -S --needed." "$MANUAL"
append_line "6. AUR nunca deve ser instalado por atualização geral." "$MANUAL"
append_line "7. AUR só pode ser instalado pacote a pacote ou por lista explícita aprovada." "$MANUAL"
append_line "8. Para AUR, evitar deixar makepkg -si chamar sudo interativamente a cada pacote." "$MANUAL"
append_line "9. O fluxo preferido para AUR é construir como usuário normal e instalar os artefatos finais com sudo pacman -U --noconfirm em lote, ou usar sudo -n/PACMAN_AUTH equivalente com keepalive já ativo." "$MANUAL"
append_line "10. Se sudo -n falhar durante o script, o script deve parar com erro claro, não voltar a pedir senha repetidamente." "$MANUAL"
append_line "11. Antes de entregar comando de instalação, revisar especificamente se algum trecho pode chamar sudo por dentro sem respeitar o keepalive." "$MANUAL"
append_line "" "$MANUAL"
append_line "## Forma correta de esqueleto para comandos futuros" "$MANUAL"
append_line "" "$MANUAL"
append_line "SUDO deve ser definido preferindo /run/wrappers/bin/sudo quando existir." "$MANUAL"
append_line "O comando deve executar sudo -v uma vez." "$MANUAL"
append_line "Um processo keepalive deve rodar sudo -n true periodicamente." "$MANUAL"
append_line "Pacotes oficiais devem ser instalados juntos, não um por um." "$MANUAL"
append_line "Pacotes AUR devem ser clonados/auditados/construídos como usuário normal." "$MANUAL"
append_line "A instalação final de pacotes AUR gerados deve ser feita com sudo pacman -U --noconfirm, preferencialmente em lote." "$MANUAL"
append_line "" "$MANUAL"
append_line "## Proibição operacional" "$MANUAL"
append_line "" "$MANUAL"
append_line "Não entregar novamente comando que deixe makepkg -si, flatpak ou pacman pedir senha repetidamente durante uma instalação aprovada pelo usuário." "$MANUAL"

say "Gerando relatório separado"
append_line "# Regra registrada - sudo keepalive em instalações" "$REPORT"
append_line "" "$REPORT"
append_line "Data: $TS" "$REPORT"
append_line "" "$REPORT"
append_line "Manual atualizado: $MANUAL" "$REPORT"
append_line "Backup criado: $BACKUP" "$REPORT"
append_line "Script salvo: $SCRIPT_COPY" "$REPORT"
append_line "" "$REPORT"
append_line "Regra: comandos de instalação do Mocha devem pedir senha sudo no máximo uma vez no início, manter keepalive e impedir prompts repetidos por pacote, especialmente em AUR/makepkg." "$REPORT"

say "Limitando backups do manual a no máximo 2"
find "$DOC_DIR" -maxdepth 1 -type f -name "$(basename "$MANUAL").bak-*" -printf '%T@ %p\n' \
  | sort -nr \
  | tail -n +3 \
  | cut -d' ' -f2- \
  | while IFS= read -r old_backup; do
      [ -n "$old_backup" ] || continue
      rm -f -- "$old_backup"
      printf 'Backup antigo removido: %s\n' "$old_backup"
    done

say "Resumo"
printf 'Manual atualizado: %s\n' "$MANUAL"
printf 'Backup:           %s\n' "$BACKUP"
printf 'Relatório:        %s\n' "$REPORT"
printf 'Script salvo:     %s\n' "$SCRIPT_COPY"
printf '\n%s\n' "Nada foi instalado, removido ou atualizado."
