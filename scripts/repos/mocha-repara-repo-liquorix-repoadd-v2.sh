#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

REPO_NAME="mocha-lqx"
REPO_DIR="/media/vmstore/mocha-repo/local/kernel-liquorix/x86_64"
DB="$REPO_DIR/$REPO_NAME.db.tar.zst"

mapfile -d '' PKGS < <(
  find "$REPO_DIR" -maxdepth 1 -type f \( \
    -name '*.pkg.tar' -o \
    -name '*.pkg.tar.gz' -o \
    -name '*.pkg.tar.xz' -o \
    -name '*.pkg.tar.zst' \
  \) -print0 | sort -z
)

[ "${#PKGS[@]}" -gt 0 ] || {
  echo "[FALHA] Nenhum pacote encontrado em $REPO_DIR" >&2
  exit 1
}

sudo rm -f "$REPO_DIR/$REPO_NAME.db" "$REPO_DIR/$REPO_NAME.db.tar" "$REPO_DIR/$REPO_NAME.db.tar.gz" "$REPO_DIR/$REPO_NAME.db.tar.xz" "$REPO_DIR/$REPO_NAME.db.tar.zst"
sudo repo-add "$DB" "${PKGS[@]}"
cd "$REPO_DIR"
sudo ln -sfn "$(basename "$DB")" "$REPO_NAME.db"
echo "[OK] Repo Liquorix regenerado: $DB"
