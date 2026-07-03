#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ok()   { printf '[OK] %s\n' "$*"; }
info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -ne 0 ]; then
  fail "Execute com sudo: sudo $0"
fi

LIQUORIX_REPO_URL="${1:-https://liquorix.net/archlinux/liquorix/x86_64}"

AUDIT_ROOT="/media/vmstore/MochaArch/auditorias"
STAMP="$(date +%Y%m%d-%H%M%S)"
AUDIT_DIR="$AUDIT_ROOT/audita-repo-liquorix-remoto-nvidia-$STAMP"
WORK="$AUDIT_DIR/work"

mkdir -p "$WORK"
exec > >(tee -a "$AUDIT_DIR/execucao.txt") 2>&1

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Comando ausente: $1"
}

need_cmd curl
need_cmd sed
need_cmd grep
need_cmd sort
need_cmd tar
need_cmd basename

info "Repo remoto alvo:"
echo "$LIQUORIX_REPO_URL"

info "Baixando índice HTTP do repo..."
curl -fsSL "$LIQUORIX_REPO_URL/" -o "$WORK/index.html"

sed -n 's/.*href="\([^"]*\)".*/\1/p' "$WORK/index.html" \
  | sed 's#^\./##' \
  | grep -E '(\.pkg\.tar|\.db|\.files)' \
  | sort -u > "$AUDIT_DIR/nomes-no-indice.txt" || true

info "Pacotes/arquivos visíveis no índice HTTP:"
cat "$AUDIT_DIR/nomes-no-indice.txt" || true

echo
info "Procurando NVIDIA/OpenCL/CUDA/Vulkan no índice HTTP..."
grep -Ei 'nvidia|opencl|cuda|nvenc|nvdec|vulkan' "$AUDIT_DIR/nomes-no-indice.txt" \
  | tee "$AUDIT_DIR/suspeitos-no-indice.txt" || true

echo
info "Descobrindo bancos pacman remotos..."
grep -E '\.(db|db\.tar\.gz|files|files\.tar\.gz)$' "$AUDIT_DIR/nomes-no-indice.txt" \
  | sort -u > "$AUDIT_DIR/dbs-descobertos.txt" || true

if [ ! -s "$AUDIT_DIR/dbs-descobertos.txt" ]; then
  warn "Nenhum .db/.files apareceu no índice. Tentando nomes padrão: liquorix.db e liquorix.files"
  printf '%s\n' "liquorix.db" "liquorix.files" > "$AUDIT_DIR/dbs-descobertos.txt"
fi

cat "$AUDIT_DIR/dbs-descobertos.txt"

echo
info "Baixando e lendo bancos pacman encontrados..."
: > "$AUDIT_DIR/conteudo-dbs.txt"
: > "$AUDIT_DIR/suspeitos-nos-dbs.txt"

while IFS= read -r dbname; do
  [ -n "$dbname" ] || continue

  clean_name="$(basename "$dbname")"
  url="$LIQUORIX_REPO_URL/$clean_name"
  out="$WORK/$clean_name"

  echo
  info "Tentando baixar: $url"

  if curl -fL --max-time 30 "$url" -o "$out"; then
    ok "Baixado: $clean_name"

    echo "=== $clean_name ===" >> "$AUDIT_DIR/conteudo-dbs.txt"

    if tar -tf "$out" >> "$AUDIT_DIR/conteudo-dbs.txt" 2>>"$AUDIT_DIR/tar-erros.txt"; then
      tar -tf "$out" \
        | grep -Ei 'nvidia|opencl|cuda|nvenc|nvdec|vulkan' \
        | sed "s#^#$clean_name: #" \
        | tee -a "$AUDIT_DIR/suspeitos-nos-dbs.txt" || true
    else
      warn "Não consegui listar como tar: $clean_name"
    fi
  else
    warn "Não baixou: $url"
  fi
done < "$AUDIT_DIR/dbs-descobertos.txt"

echo
info "Resumo final:"

indice_hits="$(grep -c . "$AUDIT_DIR/suspeitos-no-indice.txt" 2>/dev/null || true)"
db_hits="$(grep -c . "$AUDIT_DIR/suspeitos-nos-dbs.txt" 2>/dev/null || true)"

indice_hits="${indice_hits:-0}"
db_hits="${db_hits:-0}"

echo "Suspeitos no índice HTTP: $indice_hits"
echo "Suspeitos nos bancos pacman: $db_hits"

echo
if [ "$indice_hits" -eq 0 ] && [ "$db_hits" -eq 0 ]; then
  ok "Nada encontrado com nomes NVIDIA/OpenCL/CUDA/Vulkan no repo remoto Liquorix."
  ok "Conclusão prática: o repo remoto Liquorix não parece fornecer driver NVIDIA."
else
  warn "Foram encontrados nomes suspeitos. Verifique:"
  echo "$AUDIT_DIR/suspeitos-no-indice.txt"
  echo "$AUDIT_DIR/suspeitos-nos-dbs.txt"
fi

echo
ok "Auditoria salva em: $AUDIT_DIR"
