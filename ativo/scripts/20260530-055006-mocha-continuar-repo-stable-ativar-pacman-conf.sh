#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"

PACMAN_CONF="/etc/pacman.conf"

FAST_BASE="/media/mochafast/MochaArch"
VM_BASE="/media/vmstore/MochaArch"
REPO_DIR="$VM_BASE/repos/mocha-stable/os/x86_64"

DOC_DIR="$FAST_BASE/ativo/documentacao"
SCRIPT_DIR="$FAST_BASE/ativo/scripts"
REPORT_DIR="$FAST_BASE/ativo/relatorios"

LOG="$REPORT_DIR/${TS}-continuar-repo-stable-ativar-pacman-conf.log"
DOC="$DOC_DIR/${TS}-repo-stable-validado-e-pacman-conf-ativado.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-continuar-repo-stable-ativar-pacman-conf.sh"

DB_TAR="$REPO_DIR/mocha-stable.db.tar.zst"
FILES_TAR="$REPO_DIR/mocha-stable.files.tar.zst"
DB_LINK="$REPO_DIR/mocha-stable.db"
FILES_LINK="$REPO_DIR/mocha-stable.files"

if [ "$(id -u)" -eq 0 ]; then
  SUDO=()
else
  command -v sudo >/dev/null 2>&1 || {
    echo "ERRO: sudo não encontrado."
    exit 1
  }
  SUDO=(sudo)
fi

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
[ -d "$REPO_DIR" ] || fail "Diretório do mocha-stable não existe: $REPO_DIR"
[ -f "$DB_TAR" ] || fail "Banco principal não existe: $DB_TAR"

mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Ambiente"
printf '%s\n' "Timestamp: $TS"
printf '%s\n' "Usuário: $(id -un)"
printf '%s\n' "Kernel: $(uname -r)"
printf '%s\n' "Pacman: $(pacman -V | sed -n '/Pacman v/{s/^[[:space:]]*//;p;q}')"
printf '%s\n' "Repositório Mocha stable: $REPO_DIR"
printf '%s\n' "Log: $LOG"

say "Estado atual do repositório mocha-stable"
find "$REPO_DIR" -maxdepth 1 \( -type f -o -type l \) | sort

say "Garantindo links esperados pelo pacman"
cd "$REPO_DIR"

ln -sfn "mocha-stable.db.tar.zst" "mocha-stable.db"

if [ ! -f "$FILES_TAR" ]; then
  printf '%s\n' "Banco files não existia. Criando vazio."
  bsdtar -cf - --files-from /dev/null | zstd -q -T0 -19 > "$FILES_TAR"
fi

ln -sfn "mocha-stable.files.tar.zst" "mocha-stable.files"

say "Ajustando permissões de leitura do repositório local"
chmod -R a+rX "$VM_BASE/repos"

say "Lendo seções ativas atuais do pacman.conf"
awk '
  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    sec=$0
    gsub(/^[[:space:]]*\[/, "", sec)
    gsub(/\][[:space:]]*$/, "", sec)
    print sec
  }
' "$PACMAN_CONF"

say "Validando banco local com pacman em ambiente temporário usando sudo"
TMPDIR="$(mktemp -d "/tmp/mocha-repo-stable-test-${TS}.XXXXXX")"
trap 'rm -rf "$TMPDIR"' EXIT

TEST_CONF="$TMPDIR/pacman.conf"
TEST_DB="$TMPDIR/db"
TEST_CACHE="$TMPDIR/cache"
TEST_LOG="$TMPDIR/pacman-test.log"

mkdir -p "$TEST_DB" "$TEST_CACHE"

cat > "$TEST_CONF" <<EOF
[options]
Architecture = auto
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional
CacheDir = $TEST_CACHE

[mocha-stable]
SigLevel = Optional TrustAll
Server = file://$REPO_DIR
EOF

"${SUDO[@]}" pacman -Sy \
  --config "$TEST_CONF" \
  --dbpath "$TEST_DB" \
  --cachedir "$TEST_CACHE" \
  --logfile "$TEST_LOG" \
  --noconfirm

say "Banco local validado em dbpath temporário"

SANITIZED="$TMPDIR/pacman.conf.sem-mocha"
NEWCONF="$TMPDIR/pacman.conf.novo"
BLOCK="$TMPDIR/mocha-stable.block"

cat > "$BLOCK" <<EOF
# MOCHA ARCH - repositório estável controlado
# Ativado em: $TS
# Origem local: $REPO_DIR
[mocha-stable]
SigLevel = Optional TrustAll
Server = file://$REPO_DIR

EOF

say "Removendo blocos ativos antigos de mocha-stable/mocha-testing do novo arquivo"
awk '
  BEGIN { drop=0 }
  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    repo=$0
    gsub(/^[[:space:]]*\[/, "", repo)
    gsub(/\][[:space:]]*$/, "", repo)
    if (repo == "mocha-stable" || repo == "mocha-testing") {
      drop=1
      next
    }
    drop=0
  }
  drop == 0 { print }
' "$PACMAN_CONF" > "$SANITIZED"

say "Inserindo mocha-stable antes de core/extra/multilib"
awk -v block="$BLOCK" '
  BEGIN { inserted=0 }
  inserted == 0 && /^[[:space:]]*\[(core|extra|multilib)\][[:space:]]*$/ {
    while ((getline line < block) > 0) print line
    close(block)
    inserted=1
  }
  { print }
  END {
    if (inserted == 0) {
      print ""
      while ((getline line < block) > 0) print line
      close(block)
    }
  }
' "$SANITIZED" > "$NEWCONF"

say "Validação estática do novo pacman.conf"
grep -n '^\[mocha-stable\]' "$NEWCONF" || fail "Bloco [mocha-stable] não foi criado."
grep -n "^Server = file://$REPO_DIR" "$NEWCONF" || fail "Server do mocha-stable não aponta para o VMSTORE."
if grep -n '^\[mocha-testing\]' "$NEWCONF"; then
  fail "Bloco ativo [mocha-testing] apareceu no novo arquivo."
fi

for repo in core extra multilib; do
  if grep -q "^\[$repo\]" "$PACMAN_CONF"; then
    grep -q "^\[$repo\]" "$NEWCONF" || fail "O repositório [$repo] sumiu do novo pacman.conf."
  fi
done

say "Diferença Mocha que será aplicada"
diff -u "$PACMAN_CONF" "$NEWCONF" | sed -n '/mocha-stable/,+10p; /mocha-testing/,+10p' || true

say "Criando backup controlado do pacman.conf"
BACKUP="/etc/pacman.conf.mocha-backup-${TS}"
"${SUDO[@]}" cp -a "$PACMAN_CONF" "$BACKUP"
printf '%s\n' "Backup criado: $BACKUP"

say "Limitando backups do pacman.conf a no máximo 2"
mapfile -t OLD_BACKUPS < <(ls -1t /etc/pacman.conf.mocha-backup-* 2>/dev/null | tail -n +3 || true)
if [ "${#OLD_BACKUPS[@]}" -gt 0 ]; then
  printf '%s\n' "Backups excedentes removidos:"
  printf '%s\n' "${OLD_BACKUPS[@]}"
  "${SUDO[@]}" rm -f "${OLD_BACKUPS[@]}"
else
  printf '%s\n' "Nenhum backup excedente."
fi

say "Aplicando novo pacman.conf"
"${SUDO[@]}" install -o root -g root -m 0644 "$NEWCONF" "$PACMAN_CONF"

say "Checagem final do pacman.conf real"
grep -n '^\[mocha-stable\]' "$PACMAN_CONF" || fail "mocha-stable não ficou ativo."
grep -n "^Server = file://$REPO_DIR" "$PACMAN_CONF" || fail "Server real do mocha-stable incorreto."
if grep -n '^\[mocha-testing\]' "$PACMAN_CONF"; then
  fail "mocha-testing ficou ativo, o que não era permitido."
fi

say "Seções ativas finais"
awk '
  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    sec=$0
    gsub(/^[[:space:]]*\[/, "", sec)
    gsub(/\][[:space:]]*$/, "", sec)
    print sec
  }
' "$PACMAN_CONF"

say "Sincronizando bancos sem atualizar pacotes"
printf '%s\n' "Será executado apenas pacman -Sy. Não será executado pacman -Syu."
"${SUDO[@]}" pacman -Sy

say "Listagem inicial do mocha-stable"
pacman -Sl mocha-stable 2>/dev/null | head -n 30 || printf '%s\n' "mocha-stable ativo, mas vazio no momento."

say "Gerando documentação"
: > "$DOC"
append_doc "# Mocha Arch - repositório mocha-stable validado e ativado"
append_doc ""
append_doc "Data: $TS"
append_doc ""
append_doc "## Resultado"
append_doc ""
append_doc "- O repositório local mocha-stable foi validado no VMSTORE."
append_doc "- Caminho: $REPO_DIR"
append_doc "- Banco principal: $DB_TAR"
append_doc "- Link usado pelo pacman: $DB_LINK"
append_doc "- O arquivo real auditado e alterado foi /etc/pacman.conf."
append_doc "- Somente [mocha-stable] foi ativado."
append_doc "- [mocha-testing] não foi habilitado."
append_doc "- [core], [extra] e [multilib] foram preservados quando já existiam."
append_doc "- Não foi executado pacman -Syu."
append_doc "- Foi executado somente pacman -Sy para sincronizar bancos."
append_doc ""
append_doc "## Correção aplicada"
append_doc ""
append_doc "- A tentativa anterior criou o banco do repositório, mas falhou na validação porque pacman -Sy com dbpath temporário também precisa de root."
append_doc "- Este script corrigiu a validação usando sudo apenas para o pacman temporário e para a escrita final do pacman.conf."
append_doc ""
append_doc "## Política"
append_doc ""
append_doc "- mocha-stable é a camada local controlada do Mocha."
append_doc "- core/extra/multilib continuam fornecendo a base Arch rolling nesta fase."
append_doc "- mocha-testing permanece fora do uso normal."
append_doc "- A promoção para mocha-stable deve ser feita pacote a pacote, após teste."
append_doc "- AUR não entra em atualização geral do sistema."
append_doc ""
append_doc "## Arquivos"
append_doc ""
append_doc "- Backup do pacman.conf: $BACKUP"
append_doc "- Log: $LOG"
append_doc "- Script reutilizável: $SCRIPT_COPY"

say "Salvando script reutilizável"
install -m 0755 "$0" "$SCRIPT_COPY"

say "Concluído"
printf '%s\n' "Documentação: $DOC"
printf '%s\n' "Log: $LOG"
printf '%s\n' "Script: $SCRIPT_COPY"
