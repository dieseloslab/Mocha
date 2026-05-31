#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

BASE="/media/mochafast/MochaArch"
ACTIVE="$BASE/ativo"
MANUAL="$ACTIVE/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
LOG_DIR="$ACTIVE/logs"
DOC_DIR="$ACTIVE/documentacao"

mkdir -p "$LOG_DIR" "$DOC_DIR"

TS="$(date +%Y%m%d-%H%M%S)"
LOG="$LOG_DIR/${TS}-adicionar-entrada-aprovada-ao-manual.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
fi

if [ ! -f "$MANUAL" ]; then
  echo "ERRO: manual vivo não encontrado:"
  echo "  $MANUAL"
  exit 1
fi

AREA="${1:-}"
TITULO="${2:-}"

if [ -z "$AREA" ]; then
  printf 'Área da entrada aprovada: '
  read -r AREA
fi

if [ -z "$TITULO" ]; then
  printf 'Título curto da entrada aprovada: '
  read -r TITULO
fi

if [ -z "$AREA" ] || [ -z "$TITULO" ]; then
  echo "ERRO: área e título são obrigatórios."
  exit 1
fi

TMP="$(mktemp)"
cat > "$TMP"

BACKUP="$DOC_DIR/${TS}-snapshot-antes-nova-entrada-manual-vivo.md"
cp -a "$MANUAL" "$BACKUP"

{
  echo
  echo "---"
  echo
  echo "## Entrada aprovada — $TS — $AREA — $TITULO"
  echo
  echo "### Área"
  echo
  echo "$AREA"
  echo
  echo "### Título"
  echo
  echo "$TITULO"
  echo
  echo "### Registro"
  echo
  if [ -s "$TMP" ]; then
    cat "$TMP"
  else
    echo "Registro vazio. Preencher depois com comando, arquivos alterados, validação e resultado."
  fi
  echo
  echo "### Modelo obrigatório para completar a entrada"
  echo
  echo '```text'
  echo "O que foi feito:"
  echo "Por que foi feito:"
  echo "Arquivo(s) alterado(s):"
  echo "Comando/script aprovado:"
  echo "Validação:"
  echo "Resultado:"
  echo "Regra de não regressão:"
  echo '```'
} >> "$MANUAL"

rm -f "$TMP"

REF="$DOC_DIR/${TS}-MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE-pos-nova-entrada.md"
cp -a "$MANUAL" "$REF"

echo "Entrada acrescentada ao manual:"
echo "  $MANUAL"
echo "Backup anterior:"
echo "  $BACKUP"
echo "Cópia pós-entrada:"
echo "  $REF"
echo
echo "Uso recomendado:"
echo "  $0 \"Área\" \"Título\" <<'EOF'"
echo "  O que foi feito: ..."
echo "  Arquivo(s) alterado(s): ..."
echo "  Comando/script aprovado: ..."
echo "  Validação: ..."
echo "  Resultado: ..."
echo "  Regra de não regressão: ..."
echo "EOF"
