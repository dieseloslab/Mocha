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

LIQUORIX_REPO_URL="${LIQUORIX_REPO_URL:-https://liquorix.net/archlinux/liquorix/x86_64}"

REPO_BASE="/media/vmstore/mocha-repo/local"
LQX_REPO="$REPO_BASE/kernel-liquorix/x86_64"
NVIDIA_REPO="$REPO_BASE/nvidia/x86_64"

AUDIT_ROOT="/media/vmstore/MochaArch/auditorias"
STAMP="$(date +%Y%m%d-%H%M%S)"
AUDIT_DIR="$AUDIT_ROOT/sincroniza-repo-liquorix-somente-lqx-$STAMP"
WORK="$AUDIT_DIR/work"

MODE="${1:-sync}"

mkdir -p "$LQX_REPO" "$NVIDIA_REPO" "$WORK"
exec > >(tee -a "$AUDIT_DIR/execucao.txt") 2>&1

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Comando ausente: $1"
}

need_cmd find
need_cmd sort
need_cmd grep
need_cmd sed
need_cmd curl
need_cmd repo-add

info "Modo: $MODE"
info "Repo Liquorix local: $LQX_REPO"
info "Repo NVIDIA local: $NVIDIA_REPO"

{
  echo "=== Data ==="
  date -Is
  echo
  echo "=== LQX antes ==="
  find "$LQX_REPO" -maxdepth 1 -type f -printf '%f\n' | sort || true
  echo
  echo "=== NVIDIA antes ==="
  find "$NVIDIA_REPO" -maxdepth 1 -type f -printf '%f\n' | sort || true
} > "$AUDIT_DIR/estado-antes.txt"

info "Movendo para repo NVIDIA qualquer NVIDIA/OpenCL/Vulkan/CUDA que tenha ficado no repo kernel-liquorix..."
shopt -s nullglob
moved=0

for f in \
  "$LQX_REPO"/*nvidia* \
  "$LQX_REPO"/*NVIDIA* \
  "$LQX_REPO"/*opencl* \
  "$LQX_REPO"/*OpenCL* \
  "$LQX_REPO"/*vulkan* \
  "$LQX_REPO"/*Vulkan* \
  "$LQX_REPO"/*cuda* \
  "$LQX_REPO"/*CUDA*
do
  [ -f "$f" ] || continue
  base="$(basename "$f")"

  case "$base" in
    kernel-liquorix.db|kernel-liquorix.db.tar.gz|kernel-liquorix.files|kernel-liquorix.files.tar.gz|kernel-liquorix.old|kernel-liquorix.old.tar.gz|mocha-kernel-liquorix.db|mocha-kernel-liquorix.db.tar.gz|mocha-kernel-liquorix.files|mocha-kernel-liquorix.files.tar.gz)
      continue
      ;;
  esac

  mv -v "$f" "$NVIDIA_REPO"/ | tee -a "$AUDIT_DIR/movidos-para-nvidia.txt"
  moved=$((moved + 1))
done

info "Arquivos movidos para repo NVIDIA: $moved"

if [ "$MODE" != "--cleanup-only" ]; then
  info "Baixando índice remoto Liquorix..."
  curl -fsSL "$LIQUORIX_REPO_URL/" -o "$WORK/index.html"

  info "Selecionando somente linux-lqx/linux-lqx-headers/linux-lqx-docs..."
  sed -n 's/.*href="\([^"]*\)".*/\1/p' "$WORK/index.html" \
    | sed 's#^\./##' \
    | grep -E '^linux-lqx(-headers|-docs)?-[0-9].*x86_64\.pkg\.tar\.(zst|xz)(\.sig)?$' \
    | sort -u > "$AUDIT_DIR/pacotes-liquorix-remotos-selecionados.txt" || true

  [ -s "$AUDIT_DIR/pacotes-liquorix-remotos-selecionados.txt" ] || fail "Nenhum pacote linux-lqx/linux-lqx-headers encontrado no índice remoto."

  cat "$AUDIT_DIR/pacotes-liquorix-remotos-selecionados.txt"

  while IFS= read -r pkg; do
    [ -n "$pkg" ] || continue
    url="$LIQUORIX_REPO_URL/$pkg"
    out="$LQX_REPO/$pkg"

    if [ -s "$out" ]; then
      ok "Já existe: $pkg"
    else
      info "Baixando: $pkg"
      curl -fL --max-time 120 "$url" -o "$out"
      ok "Baixado: $pkg"
    fi
  done < "$AUDIT_DIR/pacotes-liquorix-remotos-selecionados.txt"
else
  info "Modo cleanup-only: não baixando índice remoto."
fi

info "Recriando banco do repo kernel-liquorix..."
rm -f \
  "$LQX_REPO"/kernel-liquorix.db \
  "$LQX_REPO"/kernel-liquorix.db.tar.gz \
  "$LQX_REPO"/kernel-liquorix.files \
  "$LQX_REPO"/kernel-liquorix.files.tar.gz \
  "$LQX_REPO"/kernel-liquorix.old \
  "$LQX_REPO"/kernel-liquorix.old.tar.gz \
  "$LQX_REPO"/mocha-kernel-liquorix.db \
  "$LQX_REPO"/mocha-kernel-liquorix.db.tar.gz \
  "$LQX_REPO"/mocha-kernel-liquorix.files \
  "$LQX_REPO"/mocha-kernel-liquorix.files.tar.gz \
  "$LQX_REPO"/mocha-kernel-liquorix.old \
  "$LQX_REPO"/mocha-kernel-liquorix.old.tar.gz

(
  cd "$LQX_REPO"
  mapfile -t pkgs < <(find . -maxdepth 1 -type f -name 'linux-lqx*.pkg.tar.zst' -printf '%f\n' | sort)
  [ "${#pkgs[@]}" -gt 0 ] || fail "Nenhum linux-lqx*.pkg.tar.zst em $LQX_REPO"
  repo-add kernel-liquorix.db.tar.gz "${pkgs[@]}"
  repo-add mocha-kernel-liquorix.db.tar.gz "${pkgs[@]}"
)

info "Recriando banco do repo NVIDIA, se houver pacotes..."
(
  cd "$NVIDIA_REPO"
  mapfile -t npkgs < <(find . -maxdepth 1 -type f -name '*.pkg.tar.zst' -printf '%f\n' | sort)
  if [ "${#npkgs[@]}" -gt 0 ]; then
    rm -f nvidia.db nvidia.db.tar.gz nvidia.files nvidia.files.tar.gz nvidia.old nvidia.old.tar.gz mocha-nvidia.db mocha-nvidia.db.tar.gz mocha-nvidia.files mocha-nvidia.files.tar.gz
    repo-add nvidia.db.tar.gz "${npkgs[@]}"
    repo-add mocha-nvidia.db.tar.gz "${npkgs[@]}"
  else
    warn "Repo NVIDIA sem pacotes; banco não recriado."
  fi
)

{
  echo "=== Data ==="
  date -Is
  echo
  echo "=== LQX depois ==="
  find "$LQX_REPO" -maxdepth 1 -type f -printf '%f\n' | sort || true
  echo
  echo "=== NVIDIA depois ==="
  find "$NVIDIA_REPO" -maxdepth 1 -type f -printf '%f\n' | sort || true
  echo
  echo "=== Suspeitos restantes no LQX ==="
  find "$LQX_REPO" -maxdepth 1 -type f \( -iname '*nvidia*' -o -iname '*opencl*' -o -iname '*vulkan*' -o -iname '*cuda*' \) -printf '%f\n' | sort || true
} > "$AUDIT_DIR/estado-depois.txt"

leftovers="$(find "$LQX_REPO" -maxdepth 1 -type f \( -iname '*nvidia*' -o -iname '*opencl*' -o -iname '*vulkan*' -o -iname '*cuda*' \) -printf '%f\n' | sort || true)"

if [ -n "$leftovers" ]; then
  warn "Ainda há suspeitos no repo Liquorix:"
  printf '%s\n' "$leftovers"
else
  ok "Repo Liquorix limpo: sem NVIDIA/OpenCL/Vulkan/CUDA."
fi

ok "Auditoria salva em: $AUDIT_DIR"
