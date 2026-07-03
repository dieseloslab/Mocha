#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ROOT="/media/mochafast/MochaArch"
APP="$ROOT/apps/mocha-updater"
AUD="/media/vmstore/MochaArch/auditorias"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$AUD/mocha-updater-estado-$STAMP.log"

mkdir -p "$AUD"

{
  echo "============================================================"
  echo " Mocha Updater — auditoria de estado"
  echo "============================================================"
  echo "Data: $(date -Is)"
  echo "ROOT: $ROOT"
  echo "APP:  $APP"
  echo

  echo "============================================================"
  echo " 1) Sistema"
  echo "============================================================"
  uname -a || true
  echo
  pacman -Q rust cargo gtk4 libadwaita 2>/dev/null || true
  echo

  echo "============================================================"
  echo " 2) Repositório público"
  echo "============================================================"
  if [ -d "$ROOT/.git" ]; then
    git -C "$ROOT" status --short --branch || true
    echo
    git -C "$ROOT" log --oneline -n 8 || true
  else
    echo "Repo público não encontrado em $ROOT"
  fi
  echo

  echo "============================================================"
  echo " 3) Estrutura apps/mocha-updater"
  echo "============================================================"
  if [ -d "$APP" ]; then
    find "$APP" -maxdepth 4 -printf '%M %u:%g %p\n' | sort || true
  else
    echo "ERRO: pasta não encontrada: $APP"
  fi
  echo

  echo "============================================================"
  echo " 4) Arquivos principais"
  echo "============================================================"
  for f in \
    "$APP/Cargo.toml" \
    "$APP/Cargo.lock" \
    "$APP/src/main.rs" \
    "$APP/src/lib.rs" \
    "$APP/README.md"
  do
    if [ -e "$f" ]; then
      echo "[OK] $f"
    else
      echo "[AUSENTE] $f"
    fi
  done
  echo

  echo "============================================================"
  echo " 5) Desktop/menu — atalhos Mocha Updater"
  echo "============================================================"
  echo "--- /usr/share/applications ---"
  find /usr/share/applications -maxdepth 1 \
    \( -iname '*mocha*updater*.desktop' -o -iname '*mocha*update*.desktop' -o -iname '*mocha*.desktop' \) \
    -printf '%M %u:%g %p\n' 2>/dev/null | sort || true
  echo

  echo "--- Desktop do usuário ---"
  for d in "$HOME/Desktop" "$HOME/Área de trabalho" "$HOME/Bureau" "$HOME/Escritorio"; do
    [ -d "$d" ] || continue
    echo "Pasta: $d"
    find "$d" -maxdepth 1 \
      \( -iname '*mocha*updater*.desktop' -o -iname '*mocha*update*.desktop' -o -iname '*mocha*.desktop' \) \
      -printf '%M %u:%g %p\n' 2>/dev/null | sort || true
  done
  echo

  echo "============================================================"
  echo " 6) Conteúdo dos atalhos encontrados"
  echo "============================================================"
  while IFS= read -r desktop_file; do
    [ -f "$desktop_file" ] || continue
    echo
    echo "----- $desktop_file -----"
    grep -E '^(Name|Name\[|Comment|Comment\[|Exec|Icon|Categories|Terminal|Type)=' "$desktop_file" || true
  done < <(
    {
      find /usr/share/applications -maxdepth 1 \
        \( -iname '*mocha*updater*.desktop' -o -iname '*mocha*update*.desktop' -o -iname '*mocha*.desktop' \) 2>/dev/null || true
      for d in "$HOME/Desktop" "$HOME/Área de trabalho" "$HOME/Bureau" "$HOME/Escritorio"; do
        [ -d "$d" ] || continue
        find "$d" -maxdepth 1 \
          \( -iname '*mocha*updater*.desktop' -o -iname '*mocha*update*.desktop' -o -iname '*mocha*.desktop' \) 2>/dev/null || true
      done
    } | sort -u
  )
  echo

  echo "============================================================"
  echo " 7) Busca por idiomas suportados"
  echo "============================================================"
  if [ -d "$APP" ]; then
    grep -RInE 'pt|pt_BR|en|fr|es|LANG|locale|gettext|i18n|Name\[|Comment\[' "$APP" 2>/dev/null | head -n 200 || true
  fi
  echo

  echo "============================================================"
  echo " 8) Build/check"
  echo "============================================================"
  if [ -f "$APP/Cargo.toml" ]; then
    cd "$APP"
    echo "Rodando: cargo check"
    timeout 180 cargo check
  else
    echo "Cargo.toml ausente; cargo check ignorado."
  fi
  echo

  echo "============================================================"
  echo " RESUMO_CURTO"
  echo "============================================================"
  echo "Log salvo em: $LOG"
  echo
  echo "Próxima etapa esperada:"
  echo "1. Corrigir build se cargo check falhar."
  echo "2. Remover/normalizar atalhos duplicados."
  echo "3. Implementar primeira função real: aba Atualização Geral com dry-run."
  echo "4. Deixar aba Kernel/Driver inicialmente conservadora: detectar CPU/GPU/kernel/driver e só recomendar."
} 2>&1 | tee "$LOG"
