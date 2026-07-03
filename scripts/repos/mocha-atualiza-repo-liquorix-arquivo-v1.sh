#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

MODE="${1:-update}"

REPO_NAME="mocha-lqx"
VM_REPO_BASE="/media/vmstore/mocha-repo"
REPO_DIR="$VM_REPO_BASE/local/kernel-liquorix/x86_64"
SNAP_ROOT="$VM_REPO_BASE/snapshots/kernel-liquorix"
MANIFEST_ROOT="$VM_REPO_BASE/manifestos/kernel-liquorix"
LOG_ROOT="$VM_REPO_BASE/logs/kernel-liquorix"

TS="$(date +%Y%m%d-%H%M%S)"
DL_DIR="/tmp/mocha-lqx-download-$TS"
SNAP_DIR="$SNAP_ROOT/$TS"
LOG="$LOG_ROOT/atualiza-repo-liquorix-$TS.log"
MANIFEST="$MANIFEST_ROOT/manifesto-liquorix-$TS.txt"
LATEST_MANIFEST="$MANIFEST_ROOT/manifesto-liquorix-latest.txt"
DB="$REPO_DIR/$REPO_NAME.db.tar.zst"
SNIPPET="$REPO_DIR/$REPO_NAME.pacman.conf.snippet"

REQUIRED_PKGS=(
  linux-lqx
  linux-lqx-headers
)

OPTIONAL_PKGS=(
  nvidia-open-dkms
  nvidia-utils
  lib32-nvidia-utils
  nvidia-settings
  opencl-nvidia
  lib32-opencl-nvidia
  vulkan-icd-loader
  lib32-vulkan-icd-loader
)

ok()   { printf '[OK] %s\n' "$*"; }
info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*" >&2; exit 1; }

[ -d "$VM_REPO_BASE" ] || fail "Base repo ausente: $VM_REPO_BASE"
command -v repo-add >/dev/null 2>&1 || fail "repo-add não encontrado"
command -v sha256sum >/dev/null 2>&1 || fail "sha256sum não encontrado"

mkdir -p "$REPO_DIR" "$SNAP_DIR" "$MANIFEST_ROOT" "$LOG_ROOT" "$DL_DIR"

{
  echo "============================================================"
  echo " Mocha — atualização repo Liquorix/lqx"
  echo " Data: $(date -Is)"
  echo " Modo: $MODE"
  echo " Repo: $REPO_DIR"
  echo " Snapshot: $SNAP_DIR"
  echo "============================================================"
  echo

  if [ "$MODE" = "update" ]; then
    command -v pacman >/dev/null 2>&1 || fail "pacman não encontrado"

    echo "[1/6] Sincronizando bancos remotos"
    echo "------------------------------------------------------------"
    pacman -Sy --noconfirm

    echo
    echo "[2/6] Verificando pacotes"
    echo "------------------------------------------------------------"

    TARGETS=()

    for P in "${REQUIRED_PKGS[@]}"; do
      if pacman -Spdd --noconfirm "$P" >/dev/null 2>&1; then
        TARGETS+=("$P")
        echo "[OK] obrigatório disponível: $P"
      else
        fail "Pacote obrigatório ausente: $P"
      fi
    done

    for P in "${OPTIONAL_PKGS[@]}"; do
      if pacman -Spdd --noconfirm "$P" >/dev/null 2>&1; then
        TARGETS+=("$P")
        echo "[OK] opcional disponível: $P"
      else
        echo "[AVISO] opcional ausente/ignorado: $P"
      fi
    done

    echo
    echo "[3/6] Baixando pacotes sem instalar"
    echo "------------------------------------------------------------"
    printf ' - %s\n' "${TARGETS[@]}"
    pacman -Sddw --noconfirm --cachedir "$DL_DIR" "${TARGETS[@]}"

    echo
    echo "[4/6] Copiando novos pacotes para repo arquivo"
    echo "------------------------------------------------------------"

    while IFS= read -r -d '' F; do
      BN="$(basename "$F")"
      DEST="$REPO_DIR/$BN"

      if [ -e "$DEST" ]; then
        echo "[MANTIDO] $BN"
      else
        cp -a "$F" "$DEST"
        echo "[NOVO] $BN"
      fi

      cp -a "$F" "$SNAP_DIR/$BN"
    done < <(find "$DL_DIR" -maxdepth 1 -type f -name '*.pkg.tar*' -print0 | sort -z)

  elif [ "$MODE" = "rebuild-only" ]; then
    echo "[1/6] Modo rebuild-only"
    echo "------------------------------------------------------------"
    echo "Sem download. Apenas regenerando banco com pacotes já existentes."
  else
    fail "Modo inválido: $MODE. Use update ou rebuild-only."
  fi

  echo
  echo "[5/6] Regenerando banco repo-add sem --files"
  echo "------------------------------------------------------------"

  mapfile -d '' PKGS < <(
    find "$REPO_DIR" -maxdepth 1 -type f \( \
      -name '*.pkg.tar' -o \
      -name '*.pkg.tar.gz' -o \
      -name '*.pkg.tar.xz' -o \
      -name '*.pkg.tar.zst' \
    \) -print0 | sort -z
  )

  [ "${#PKGS[@]}" -gt 0 ] || fail "Nenhum pacote real encontrado em $REPO_DIR"

  ls "$REPO_DIR"/linux-lqx-*.pkg.tar.* >/dev/null 2>&1 || fail "linux-lqx ausente no repo"
  ls "$REPO_DIR"/linux-lqx-headers-*.pkg.tar.* >/dev/null 2>&1 || fail "linux-lqx-headers ausente no repo"

  rm -f \
    "$REPO_DIR/$REPO_NAME.db" \
    "$REPO_DIR/$REPO_NAME.db.tar" \
    "$REPO_DIR/$REPO_NAME.db.tar.gz" \
    "$REPO_DIR/$REPO_NAME.db.tar.xz" \
    "$REPO_DIR/$REPO_NAME.db.tar.zst" \
    "$REPO_DIR/$REPO_NAME.files" \
    "$REPO_DIR/$REPO_NAME.files.tar" \
    "$REPO_DIR/$REPO_NAME.files.tar.gz" \
    "$REPO_DIR/$REPO_NAME.files.tar.xz" \
    "$REPO_DIR/$REPO_NAME.files.tar.zst"

  repo-add "$DB" "${PKGS[@]}"

  cd "$REPO_DIR"
  ln -sfn "$(basename "$DB")" "$REPO_NAME.db"

  cat > "$SNIPPET" <<EOF
[$REPO_NAME]
SigLevel = Optional TrustAll
Server = file://$REPO_DIR
EOF

  echo
  echo "[6/6] Gerando manifesto"
  echo "------------------------------------------------------------"

  {
    echo "============================================================"
    echo " Mocha — manifesto Liquorix/lqx"
    echo " Data: $(date -Is)"
    echo " Modo: $MODE"
    echo " Repo: $REPO_DIR"
    echo " Banco: $DB"
    echo " Política: repo arquivo; não apagar versões antigas"
    echo "============================================================"
    echo
    echo "[Pacotes no repo]"
    for P in "${PKGS[@]}"; do
      echo
      echo "Arquivo: $(basename "$P")"
      sha256sum "$P"
    done
  } > "$MANIFEST"

  cp -a "$MANIFEST" "$LATEST_MANIFEST"
  cp -a "$MANIFEST" "$SNAP_DIR/$(basename "$MANIFEST")"
  cp -a "$DB" "$SNAP_DIR/$(basename "$DB")"
  cp -a "$SNIPPET" "$SNAP_DIR/$(basename "$SNIPPET")"

  echo
  echo "============================================================"
  echo " Resumo"
  echo "============================================================"
  echo "Repo: $REPO_DIR"
  echo "Banco: $DB"
  echo "Symlink: $REPO_DIR/$REPO_NAME.db"
  echo "Snippet: $SNIPPET"
  echo "Manifesto: $MANIFEST"
  echo "Pacotes: ${#PKGS[@]}"
  echo
  ok "Repo Liquorix/lqx atualizado/regenerado."

} 2>&1 | tee "$LOG"

rm -rf "$DL_DIR" 2>/dev/null || true
