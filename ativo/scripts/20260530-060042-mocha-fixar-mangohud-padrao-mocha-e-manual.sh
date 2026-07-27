#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"

FAST_BASE="/media/mochafast/MochaArch"
VM_BASE="/media/vmstore/MochaArch"

DOC_DIR="$FAST_BASE/ativo/documentacao"
SCRIPT_DIR="$FAST_BASE/ativo/scripts"
REPORT_DIR="$FAST_BASE/ativo/relatorios"
GAMING_DIR="$FAST_BASE/ativo/gaming"
STEAM_OPTIONS_DIR="$GAMING_DIR/steam-launch-options"
QUAR_DIR="$FAST_BASE/quarentena/mangohud"

LOG="$REPORT_DIR/${TS}-fixar-mangohud-padrao-mocha-e-manual.log"
DOC="$DOC_DIR/${TS}-mangohud-padrao-mocha-fixado.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-fixar-mangohud-padrao-mocha-e-manual.sh"
CANDIDATES="$REPORT_DIR/${TS}-mangohud-configs-candidatos.txt"
SELECTED="$REPORT_DIR/${TS}-mangohud-config-selecionado.txt"
MANUAL_SECTION="$REPORT_DIR/${TS}-secao-manual-mangohud-mocha.txt"
LAUNCH_FILE="$STEAM_OPTIONS_DIR/${TS}-launch-option-mangohud-gamemode-mocha.txt"
FIXED_LAUNCH_FILE="$STEAM_OPTIONS_DIR/launch-option-oficial-mangohud-gamemode-mocha.txt"

REAL_USER="${SUDO_USER:-$(id -un)}"
USER_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6 || true)"

USER_MH_DIR="$USER_HOME/.config/MangoHud"
USER_MOCHA_CONF="$USER_MH_DIR/Mocha-MangoHud.conf"
USER_DEFAULT_CONF="$USER_MH_DIR/MangoHud.conf"
SYSTEM_MH_DIR="/etc/mocha/mangohud"
SYSTEM_MOCHA_CONF="$SYSTEM_MH_DIR/MangoHud.conf"

MANUAL_FIXED="$DOC_DIR/MANUAL-MOCHA-ARCH-ATIVO.md"

START_MARK="<!-- MOCHA-MANGOHUD-INICIO -->"
END_MARK="<!-- MOCHA-MANGOHUD-FIM -->"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

append_line() {
  printf '%s\n' "$1" >> "$1.tmp"
}

if [ "$(id -u)" -eq 0 ]; then
  SUDO=()
else
  command -v sudo >/dev/null 2>&1 || fail "sudo não encontrado."
  SUDO=(sudo)
fi

say "Pré-checagens obrigatórias"
findmnt /media/vmstore >/dev/null || fail "/media/vmstore não está montado."
findmnt /media/mochafast >/dev/null || fail "/media/mochafast não está montado."
[ -n "$USER_HOME" ] || fail "Não consegui detectar home do usuário $REAL_USER."
[ -d "$USER_HOME" ] || fail "Home não existe: $USER_HOME"

mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR" "$STEAM_OPTIONS_DIR" "$QUAR_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Ambiente"
printf '%s\n' "Timestamp: $TS"
printf '%s\n' "Usuário real: $REAL_USER"
printf '%s\n' "Home: $USER_HOME"
printf '%s\n' "Kernel: $(uname -r)"
printf '%s\n' "Log: $LOG"

say "Validando pacotes fundamentais"
pacman -Q mangohud
pacman -Q gamemode

command -v mangohud >/dev/null 2>&1 || fail "Comando mangohud não encontrado."
command -v gamemoderun >/dev/null 2>&1 || fail "Comando gamemoderun não encontrado."

printf '%s\n' "MangoHud versão:"
mangohud --version 2>&1 || true

say "Busca controlada por configurações MangoHud existentes"
: > "$CANDIDATES"

SEARCH_ROOTS=(
  "$USER_MH_DIR"
  "$FAST_BASE/ativo"
  "$FAST_BASE/Legacy"
  "/etc/mocha"
  "$VM_BASE"
)

for root in "${SEARCH_ROOTS[@]}"; do
  if [ -d "$root" ]; then
    printf '%s\n' "Procurando em: $root"
    timeout 25s find "$root" -maxdepth 8 -type f \( -iname '*mangohud*.conf' -o -iname 'MangoHud.conf' \) -print 2>/dev/null >> "$CANDIDATES" || true
  fi
done

sort -u "$CANDIDATES" -o "$CANDIDATES"

if [ ! -s "$CANDIDATES" ]; then
  fail "Nenhum arquivo de configuração MangoHud foi encontrado. Não vou inventar visual Mocha."
fi

say "Candidatos encontrados"
cat "$CANDIDATES"

say "Selecionando configuração Mocha preferencial"
SOURCE_CONF="$(
  awk '
    {
      p=$0
      lp=tolower(p)
      score=10000

      if (lp ~ /mocha/) score-=5000
      if (p ~ /\/\.config\/MangoHud\//) score-=1000
      if (p ~ /Mocha-MangoHud/) score-=800
      if (p ~ /FPS-Comparacao/) score-=700
      if (p ~ /MangoHud.conf$/) score-=300
      if (lp ~ /backup|bak|quarentena|erro|old|antigo/) score+=3000

      printf "%06d\t%s\n", score, p
    }
  ' "$CANDIDATES" | sort -n | head -n1 | cut -f2-
)"

[ -n "$SOURCE_CONF" ] || fail "Não foi possível selecionar configuração MangoHud."
[ -f "$SOURCE_CONF" ] || fail "Configuração selecionada não existe: $SOURCE_CONF"
[ -s "$SOURCE_CONF" ] || fail "Configuração selecionada está vazia: $SOURCE_CONF"

printf '%s\n' "$SOURCE_CONF" > "$SELECTED"

printf '%s\n' "Configuração selecionada:"
printf '%s\n' "$SOURCE_CONF"

say "Preparando diretório local do MangoHud"
mkdir -p "$USER_MH_DIR"
chmod 0755 "$USER_MH_DIR"

say "Backups controlados das configurações atuais"
backup_if_exists() {
  local file="$1"
  local base
  base="$(basename "$file")"

  if [ -f "$file" ]; then
    local backup="$QUAR_DIR/${TS}-${base}.backup"
    cp -a "$file" "$backup"
    printf '%s\n' "Backup criado: $backup"

    mapfile -t old_backups < <(find "$QUAR_DIR" -maxdepth 1 -type f -name "*-${base}.backup" -printf '%T@ %p\n' 2>/dev/null | sort -nr | tail -n +3 | cut -d' ' -f2- || true)
    if [ "${#old_backups[@]}" -gt 0 ]; then
      printf '%s\n' "Removendo backups excedentes de $base:"
      printf '%s\n' "${old_backups[@]}"
      rm -f -- "${old_backups[@]}"
    fi
  fi
}

backup_if_exists "$USER_MOCHA_CONF"
backup_if_exists "$USER_DEFAULT_CONF"

say "Fixando configuração Mocha do usuário"
if [ "$SOURCE_CONF" != "$USER_MOCHA_CONF" ]; then
  cp -a "$SOURCE_CONF" "$USER_MOCHA_CONF"
fi

cp -a "$USER_MOCHA_CONF" "$USER_DEFAULT_CONF"

chown "$REAL_USER:$REAL_USER" "$USER_MOCHA_CONF" "$USER_DEFAULT_CONF"
chmod 0644 "$USER_MOCHA_CONF" "$USER_DEFAULT_CONF"

say "Instalando cópia canônica em /etc/mocha/mangohud"
"${SUDO[@]}" mkdir -p "$SYSTEM_MH_DIR"
"${SUDO[@]}" install -o root -g root -m 0644 "$USER_MOCHA_CONF" "$SYSTEM_MOCHA_CONF"

say "Validando arquivos fixados"
[ -s "$USER_MOCHA_CONF" ] || fail "$USER_MOCHA_CONF ficou vazio."
[ -s "$USER_DEFAULT_CONF" ] || fail "$USER_DEFAULT_CONF ficou vazio."
[ -s "$SYSTEM_MOCHA_CONF" ] || fail "$SYSTEM_MOCHA_CONF ficou vazio."

printf '%s\n' "Arquivo Mocha do usuário: $USER_MOCHA_CONF"
printf '%s\n' "Arquivo padrão do MangoHud: $USER_DEFAULT_CONF"
printf '%s\n' "Arquivo canônico do sistema: $SYSTEM_MOCHA_CONF"

if grep -RIn 'MANGOHUD_DLSYM' "$USER_MOCHA_CONF" "$USER_DEFAULT_CONF" "$SYSTEM_MOCHA_CONF" 2>/dev/null; then
  fail "MANGOHUD_DLSYM apareceu na configuração; isso não é permitido no padrão Mocha."
fi

say "Criando Launch Option oficial MangoHud + GameMode + padrão Mocha"
LAUNCH_OPTION="MANGOHUD_CONFIGFILE=$USER_MOCHA_CONF mangohud gamemoderun %command%"

printf '%s\n' "$LAUNCH_OPTION" > "$LAUNCH_FILE"
printf '%s\n' "$LAUNCH_OPTION" > "$FIXED_LAUNCH_FILE"

printf '%s\n' "Launch Option oficial:"
printf '%s\n' "$LAUNCH_OPTION"

say "Localizando manual ativo"
if [ -f "$MANUAL_FIXED" ]; then
  MANUAL="$MANUAL_FIXED"
else
  MANUAL="$(
    find "$DOC_DIR" -maxdepth 1 -type f \( -iname '*manual*.md' -o -iname '*montagem*.md' \) -printf '%T@ %p\n' 2>/dev/null \
      | sort -nr \
      | head -n1 \
      | cut -d' ' -f2-
  )"

  if [ -z "${MANUAL:-}" ]; then
    MANUAL="$MANUAL_FIXED"
    printf '%s\n' "# Manual Mocha Arch ativo" > "$MANUAL"
    printf '%s\n' "" >> "$MANUAL"
    printf '%s\n' "Criado em: $TS" >> "$MANUAL"
  fi
fi

printf '%s\n' "Manual que será atualizado:"
printf '%s\n' "$MANUAL"

say "Criando seção correta para o manual"
: > "$MANUAL_SECTION"

printf '%s\n' "$START_MARK" >> "$MANUAL_SECTION"
printf '%s\n' "## MangoHud padrão Mocha" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "Data da última revisão: $TS" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "### Pacotes obrigatórios" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "- \`mangohud\`" >> "$MANUAL_SECTION"
printf '%s\n' "- \`gamemode\`" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "### Arquivos de configuração obrigatórios" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "- Configuração Mocha do usuário: \`$USER_MOCHA_CONF\`" >> "$MANUAL_SECTION"
printf '%s\n' "- Configuração padrão carregada pelo MangoHud: \`$USER_DEFAULT_CONF\`" >> "$MANUAL_SECTION"
printf '%s\n' "- Cópia canônica do sistema: \`$SYSTEM_MOCHA_CONF\`" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "Regra: o MangoHud do Mocha não deve depender de configuração genérica ou incerta. O arquivo Mocha precisa estar instalado e o \`MANGOHUD_CONFIGFILE\` deve apontar explicitamente para ele quando a Steam for usada em teste controlado." >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "### Launch Option oficial para Steam" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "\`$LAUNCH_OPTION\`" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "### Linha limpa sem overlay" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "\`gamemoderun %command%\`" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "Essa linha limpa só ativa GameMode. Ela não chama MangoHud." >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "### Proibições do padrão Mocha" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "- Não usar \`MANGOHUD_DLSYM=1\`." >> "$MANUAL_SECTION"
printf '%s\n' "- Não colocar \`vkbasalt\` ou \`gamescope\` no wrapper/Launch Option canônico do Mocha." >> "$MANUAL_SECTION"
printf '%s\n' "- Não trocar o arquivo de configuração do MangoHud sem registrar no manual." >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "### Validação pós-instalação" >> "$MANUAL_SECTION"
printf '%s\n' "" >> "$MANUAL_SECTION"
printf '%s\n' "- Rodar \`pacman -Q mangohud gamemode\`." >> "$MANUAL_SECTION"
printf '%s\n' "- Rodar \`mangohud --version\`." >> "$MANUAL_SECTION"
printf '%s\n' "- Abrir jogo pela Steam com a Launch Option oficial." >> "$MANUAL_SECTION"
printf '%s\n' "- Confirmar overlay, FPS, frametime, fluidez, imagem e estabilidade." >> "$MANUAL_SECTION"
printf '%s\n' "$END_MARK" >> "$MANUAL_SECTION"

say "Atualizando manual sem duplicar seção"
MANUAL_TMP="$REPORT_DIR/${TS}-manual-atualizado.tmp"

awk -v start="$START_MARK" -v end="$END_MARK" '
  $0 == start { drop=1; next }
  $0 == end { drop=0; next }
  drop != 1 { print }
' "$MANUAL" > "$MANUAL_TMP"

{
  cat "$MANUAL_TMP"
  printf '\n'
  cat "$MANUAL_SECTION"
  printf '\n'
} > "$MANUAL"

say "Gerando documentação específica desta correção"
: > "$DOC"

printf '%s\n' "# Mocha Arch - MangoHud fixado no padrão Mocha" >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "Data: $TS" >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "## Resultado" >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "- MangoHud e GameMode foram validados como pacotes obrigatórios." >> "$DOC"
printf '%s\n' "- A configuração Mocha foi fixada no usuário atual." >> "$DOC"
printf '%s\n' "- O arquivo padrão \`MangoHud.conf\` agora recebe a configuração Mocha." >> "$DOC"
printf '%s\n' "- Uma cópia canônica foi instalada em \`/etc/mocha/mangohud/MangoHud.conf\`." >> "$DOC"
printf '%s\n' "- A Launch Option oficial foi gravada em arquivo próprio." >> "$DOC"
printf '%s\n' "- O manual ativo foi atualizado sem duplicar a seção anterior." >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "## Configuração selecionada como origem" >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "\`$SOURCE_CONF\`" >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "## Launch Option oficial" >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "\`$LAUNCH_OPTION\`" >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "## Arquivos" >> "$DOC"
printf '%s\n' "" >> "$DOC"
printf '%s\n' "- Log: \`$LOG\`" >> "$DOC"
printf '%s\n' "- Candidatos encontrados: \`$CANDIDATES\`" >> "$DOC"
printf '%s\n' "- Configuração selecionada: \`$SELECTED\`" >> "$DOC"
printf '%s\n' "- Configuração Mocha do usuário: \`$USER_MOCHA_CONF\`" >> "$DOC"
printf '%s\n' "- Configuração padrão do MangoHud: \`$USER_DEFAULT_CONF\`" >> "$DOC"
printf '%s\n' "- Configuração canônica do sistema: \`$SYSTEM_MOCHA_CONF\`" >> "$DOC"
printf '%s\n' "- Launch Option com timestamp: \`$LAUNCH_FILE\`" >> "$DOC"
printf '%s\n' "- Launch Option fixa: \`$FIXED_LAUNCH_FILE\`" >> "$DOC"
printf '%s\n' "- Manual atualizado: \`$MANUAL\`" >> "$DOC"
printf '%s\n' "- Script reutilizável: \`$SCRIPT_COPY\`" >> "$DOC"

say "Salvando script reutilizável"
install -m 0755 "$0" "$SCRIPT_COPY"

say "Resumo final"
printf '%s\n' "Configuração origem: $SOURCE_CONF"
printf '%s\n' "Configuração Mocha usuário: $USER_MOCHA_CONF"
printf '%s\n' "Configuração padrão MangoHud: $USER_DEFAULT_CONF"
printf '%s\n' "Configuração sistema: $SYSTEM_MOCHA_CONF"
printf '%s\n' "Launch Option oficial:"
printf '%s\n' "$LAUNCH_OPTION"
printf '%s\n' "Manual atualizado: $MANUAL"
printf '%s\n' "Documentação: $DOC"
printf '%s\n' "Log: $LOG"
printf '%s\n' "Script: $SCRIPT_COPY"

say "Concluído"
