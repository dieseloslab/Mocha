#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
FAST_BASE="/media/mochafast/MochaArch"
ACTIVE="$FAST_BASE/ativo"
DOC_DIR="$ACTIVE/documentacao"
REPORT_DIR="$ACTIVE/relatorios"
SCRIPT_DIR="$ACTIVE/scripts"
MANGOHUD_DIR="$ACTIVE/mangohud"

REAL_USER="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$REAL_USER" | cut -d: -f6 || true)"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*"
  exit 1
}

line() {
  printf '%s\n' "${1:-}"
}

say "Validando base MochaArch"
findmnt /media/mochafast >/dev/null || fail "/media/mochafast não está montado."
[ -d "$ACTIVE" ] || fail "Pasta ativa não encontrada: $ACTIVE"
[ -d "$DOC_DIR" ] || fail "Pasta de documentação não encontrada: $DOC_DIR"

mkdir -p "$REPORT_DIR" "$SCRIPT_DIR" "$MANGOHUD_DIR"

REPORT="$REPORT_DIR/${TS}-mangohud-mocha-documentacao-corrigida.md"
HITS="$REPORT_DIR/${TS}-mangohud-mocha-ocorrencias-documentacao.txt"
CONFIG_LIST="$REPORT_DIR/${TS}-mangohud-mocha-configs-encontradas.txt"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-corrigir-documentacao-mangohud.sh"

say "Localizando manual vivo"
MANUAL_MAIN=""

if [ -f "$DOC_DIR/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md" ]; then
  MANUAL_MAIN="$DOC_DIR/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
else
  MANUAL_MAIN="$(find "$DOC_DIR" -maxdepth 1 -type f \( -iname '*manual*.md' -o -iname '*montagem*.md' \) -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2- || true)"
fi

[ -n "${MANUAL_MAIN:-}" ] && [ -f "$MANUAL_MAIN" ] || fail "Manual vivo não encontrado em $DOC_DIR"

printf 'Manual principal: %s\n' "$MANUAL_MAIN"

say "Auditando pacotes e comandos"
PACMAN_STATE="$(pacman -Q mangohud gamemode 2>&1 || true)"
MANGOHUD_BIN="$(command -v mangohud 2>/dev/null || true)"
GAMEMODE_BIN="$(command -v gamemoderun 2>/dev/null || true)"

say "Auditando configurações MangoHud existentes"
: > "$CONFIG_LIST"

for CANDIDATE in \
  "$HOME_DIR/.config/MangoHud/Mocha-MangoHud.conf" \
  "$HOME_DIR/.config/MangoHud/MangoHud.conf" \
  "/etc/mocha/mangohud/MangoHud.conf" \
  "/etc/MangoHud.conf"
do
  if [ -f "$CANDIDATE" ]; then
    printf 'ENCONTRADO: %s\n' "$CANDIDATE" | tee -a "$CONFIG_LIST"
  else
    printf 'ausente: %s\n' "$CANDIDATE" >> "$CONFIG_LIST"
  fi
done

find "$ACTIVE" -maxdepth 5 -type f \( -iname '*mangohud*' -o -iname 'MangoHud.conf' \) -print 2>/dev/null | sort >> "$CONFIG_LIST" || true

if [ -f "/etc/mocha/mangohud/MangoHud.conf" ]; then
  CANON_CONFIG="/etc/mocha/mangohud/MangoHud.conf"
elif [ -f "$HOME_DIR/.config/MangoHud/Mocha-MangoHud.conf" ]; then
  CANON_CONFIG="$HOME_DIR/.config/MangoHud/Mocha-MangoHud.conf"
elif [ -f "$HOME_DIR/.config/MangoHud/MangoHud.conf" ]; then
  CANON_CONFIG="$HOME_DIR/.config/MangoHud/MangoHud.conf"
else
  CANON_CONFIG="/etc/mocha/mangohud/MangoHud.conf"
fi

OFFICIAL_LAUNCH="MANGOHUD=1 MANGOHUD_CONFIGFILE=$CANON_CONFIG mangohud gamemoderun %command%"
SECTION_MARKER="SEÇÃO OPERACIONAL APROVADA — MangoHud Mocha obrigatório"

say "Auditando ocorrências no manual e na pasta ativa"
: > "$HITS"

for DIR in "$DOC_DIR" "$ACTIVE/mangohud" "$ACTIVE/gaming" "$ACTIVE/steam" "$ACTIVE/scripts"; do
  if [ -d "$DIR" ]; then
    printf '\n--- %s ---\n' "$DIR" >> "$HITS"
    grep -RInE 'MangoHud|MANGOHUD|mangohud|gamemoderun|Launch Option|LaunchOptions|Steam|MANGOHUD_DLSYM|vkbasalt|gamescope' "$DIR" 2>/dev/null >> "$HITS" || true
  fi
done

say "Classificando documentação atual"
DOC_HAS_MANGO="não"
DOC_HAS_CONFIGFILE="não"
DOC_HAS_GAMEMODE_ONLY="não"
DOC_HAS_OFFICIAL="não"
DOC_HAS_MARKER="não"

grep -qiE 'MangoHud|MANGOHUD|mangohud' "$MANUAL_MAIN" && DOC_HAS_MANGO="sim" || true
grep -qiE 'MANGOHUD_CONFIGFILE|Mocha-MangoHud|/etc/mocha/mangohud/MangoHud.conf' "$MANUAL_MAIN" && DOC_HAS_CONFIGFILE="sim" || true
grep -qF 'gamemoderun %command%' "$MANUAL_MAIN" && DOC_HAS_GAMEMODE_ONLY="sim" || true
grep -qF "$OFFICIAL_LAUNCH" "$MANUAL_MAIN" && DOC_HAS_OFFICIAL="sim" || true
grep -qF "$SECTION_MARKER" "$MANUAL_MAIN" && DOC_HAS_MARKER="sim" || true

say "Preparando correção do manual, se necessária"
WORK="$(mktemp)"
awk -v official="$OFFICIAL_LAUNCH" '
  /gamemoderun %command%/ && $0 !~ /(MANGOHUD|mangohud|MangoHud)/ {
    gsub(/gamemoderun %command%/, official)
    print
    next
  }
  { print }
' "$MANUAL_MAIN" > "$WORK"

REPLACED_GAMEMODE_ONLY="não"
if ! cmp -s "$MANUAL_MAIN" "$WORK"; then
  REPLACED_GAMEMODE_ONLY="sim"
fi

APPENDED_SECTION="não"

if ! grep -qF "$SECTION_MARKER" "$WORK" || ! grep -qF "$OFFICIAL_LAUNCH" "$WORK"; then
  {
    line ""
    line "## $SECTION_MARKER"
    line ""
    line "Registro acrescentado em: $TS"
    line ""
    line "MangoHud faz parte da montagem gamer do Mocha Arch/KDE e deve respeitar o padrão visual/configuração Mocha."
    line ""
    line "Configuração canônica encontrada para esta instalação:"
    line ""
    line "- $CANON_CONFIG"
    line ""
    line "Launch Option oficial para jogos Steam quando o overlay MangoHud for obrigatório:"
    line ""
    line "$OFFICIAL_LAUNCH"
    line ""
    line "Regras preservadas:"
    line ""
    line "- Não usar MANGOHUD_DLSYM=1."
    line "- Não reintroduzir vkbasalt no wrapper/linha canônica."
    line "- Não reintroduzir gamescope no wrapper/linha canônica."
    line "- A linha gamemoderun %command% sozinha chama GameMode, mas não garante MangoHud."
    line "- Para teste comparativo sem overlay, deixar Launch Options vazias deve ser tratado como teste, não como linha canônica MangoHud."
  } >> "$WORK"
  APPENDED_SECTION="sim"
fi

MANUAL_CHANGED="não"
BACKUP_PATH="não criado"

if ! cmp -s "$MANUAL_MAIN" "$WORK"; then
  BASENAME="$(basename "$MANUAL_MAIN")"
  BACKUP_PATH="$DOC_DIR/${BASENAME}.backup-${TS}.md"

  cp -a "$MANUAL_MAIN" "$BACKUP_PATH"
  cp "$WORK" "$MANUAL_MAIN"
  MANUAL_CHANGED="sim"

  mapfile -t OLD_BACKUPS < <(
    find "$DOC_DIR" -maxdepth 1 -type f -name "${BASENAME}.backup-*.md" -printf '%T@ %p\n' 2>/dev/null \
      | sort -nr \
      | tail -n +3 \
      | cut -d' ' -f2- || true
  )

  if [ "${#OLD_BACKUPS[@]}" -gt 0 ]; then
    for OLD in "${OLD_BACKUPS[@]}"; do
      rm -f -- "$OLD"
    done
  fi
fi

rm -f "$WORK"

say "Copiando script corrigido para a pasta ativa"
cp -a "$0" "$SCRIPT_COPY"

say "Gerando relatório"
{
  line "# MangoHud Mocha — auditoria e correção de documentação"
  line ""
  line "- Timestamp: $TS"
  line "- Manual vivo: $MANUAL_MAIN"
  line "- Manual alterado: $MANUAL_CHANGED"
  line "- Backup criado: $BACKUP_PATH"
  line "- Substituiu ocorrência exata de gamemoderun %command% sem MangoHud: $REPLACED_GAMEMODE_ONLY"
  line "- Acrescentou seção MangoHud Mocha: $APPENDED_SECTION"
  line "- Configuração canônica usada na documentação: $CANON_CONFIG"
  line "- Launch Option oficial registrada: $OFFICIAL_LAUNCH"
  line "- Arquivo de ocorrências: $HITS"
  line "- Arquivo de configs encontradas: $CONFIG_LIST"
  line "- Script salvo: $SCRIPT_COPY"
  line ""
  line "## Estado antes da correção"
  line ""
  line "- Manual mencionava MangoHud: $DOC_HAS_MANGO"
  line "- Manual apontava configuração Mocha do MangoHud: $DOC_HAS_CONFIGFILE"
  line "- Manual continha gamemoderun %command%: $DOC_HAS_GAMEMODE_ONLY"
  line "- Manual continha a linha oficial completa calculada agora: $DOC_HAS_OFFICIAL"
  line "- Manual continha marcador operacional aprovado: $DOC_HAS_MARKER"
  line ""
  line "## Pacotes e comandos"
  line ""
  line "pacman -Q mangohud gamemode:"
  line "$PACMAN_STATE"
  line ""
  line "command -v mangohud:"
  line "${MANGOHUD_BIN:-não encontrado}"
  line ""
  line "command -v gamemoderun:"
  line "${GAMEMODE_BIN:-não encontrado}"
  line ""
  line "## Regras confirmadas"
  line ""
  line "- MangoHud é parte obrigatória da configuração gamer Mocha."
  line "- GameMode sozinho não chama MangoHud."
  line "- A linha oficial com overlay precisa chamar MangoHud e apontar para a configuração Mocha."
  line "- MANGOHUD_DLSYM=1 não deve voltar."
  line "- vkbasalt e gamescope não entram na linha/wrapper canônico."
} > "$REPORT"

say "Resumo"
cat "$REPORT"

say "Concluído"
printf '%s\n' "$REPORT"
