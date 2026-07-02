#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
BIN="/usr/local/bin/mocha-updater"
DESKTOP_SYS="/usr/share/applications/mocha-updater.desktop"

[ -d "$APP" ] || fail "App não encontrado em $APP"

echo
echo "============================================================"
echo " Mocha — teste canônico do Mocha Updater"
echo "============================================================"
echo

if [ -f "$APP/Cargo.toml" ]; then
  command -v cargo >/dev/null 2>&1 || fail "cargo não encontrado"
  cd "$APP"
  cargo check
  ok "cargo check passou"

  if rustup component list --installed 2>/dev/null | grep -qx 'clippy'; then
    cargo clippy -- -D warnings
    ok "cargo clippy passou"
  else
    warn "clippy não instalado; pulando"
  fi
else
  warn "Cargo.toml ausente; pulando testes Rust"
fi

if [ -x "$BIN" ]; then
  ok "Binário instalado encontrado: $BIN"
else
  warn "Binário canônico ainda não instalado em $BIN"
fi

if [ -f "$DESKTOP_SYS" ]; then
  ok "Atalho do menu encontrado: $DESKTOP_SYS"

  grep -q '^Categories=.*System.*Settings' "$DESKTOP_SYS" \
    && ok "Categoria System/Settings presente" \
    || warn "Categoria System/Settings não encontrada"

  grep -q '^Exec=/usr/local/bin/mocha-updater' "$DESKTOP_SYS" \
    && ok "Exec canônico presente" \
    || warn "Exec canônico não encontrado"
else
  warn "Atalho do menu ainda não instalado: $DESKTOP_SYS"
fi

DUPES="$(find /usr/share/applications -maxdepth 1 -type f \
  \( -iname '*mocha*updat*.desktop' -o -iname '*mocha*atualiz*.desktop' -o -iname '*updater*mocha*.desktop' \) \
  ! -name 'mocha-updater.desktop' \
  -print 2>/dev/null || true)"

if [ -n "$DUPES" ]; then
  warn "Atalhos duplicados/antigos ainda encontrados:"
  printf '%s\n' "$DUPES"
else
  ok "Sem atalhos antigos/duplicados no menu"
fi

if command -v desktop-file-validate >/dev/null 2>&1 && [ -f "$DESKTOP_SYS" ]; then
  desktop-file-validate "$DESKTOP_SYS"
  ok "desktop-file-validate passou"
fi

echo
ok "Teste canônico concluído"
