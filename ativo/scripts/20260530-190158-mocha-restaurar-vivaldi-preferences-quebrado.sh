#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
FAST_BASE="/media/mochafast/MochaArch/ativo"

if [[ -d "$FAST_BASE" && -w "$FAST_BASE" ]]; then
  BASE="$FAST_BASE"
else
  BASE="$HOME/.local/share/MochaArch-ativo"
fi

REPORT_DIR="$BASE/relatorios"
DOC_DIR="$BASE/documentacao"
SCRIPT_DIR="$BASE/scripts"

mkdir -p "$REPORT_DIR" "$DOC_DIR" "$SCRIPT_DIR"

LOG="$REPORT_DIR/${TS}-restaurar-vivaldi-preferences.log"
DOC="$DOC_DIR/${TS}-restaurar-vivaldi-preferences.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-restaurar-vivaldi-preferences-quebrado.sh"

exec > >(tee -a "$LOG") 2>&1

step() {
  printf '\n==> %s\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  printf 'Log: %s\n' "$LOG" >&2
  exit 1
}

step "Encerrando Vivaldi se ainda houver processo preso"
if pgrep -u "$USER" -a -f '(^|/)(vivaldi|vivaldi-bin|vivaldi-stable|vivaldi-snapshot)( |$)' >/tmp/mocha-vivaldi-processos-"$TS".txt 2>/dev/null; then
  cat /tmp/mocha-vivaldi-processos-"$TS".txt
  pkill -TERM -u "$USER" -f '(^|/)(vivaldi|vivaldi-bin|vivaldi-stable|vivaldi-snapshot)( |$)' || true

  for i in 1 2 3 4 5 6 7 8 9 10; do
    if ! pgrep -u "$USER" -f '(^|/)(vivaldi|vivaldi-bin|vivaldi-stable|vivaldi-snapshot)( |$)' >/dev/null 2>&1; then
      break
    fi
    printf 'Aguardando Vivaldi fechar... %s/10\n' "$i"
    sleep 1
  done

  if pgrep -u "$USER" -f '(^|/)(vivaldi|vivaldi-bin|vivaldi-stable|vivaldi-snapshot)( |$)' >/dev/null 2>&1; then
    fail "Vivaldi ainda está rodando. Feche pelo monitor do sistema e rode o comando novamente."
  fi
fi

step "Validando ferramentas"
command -v python3 >/dev/null 2>&1 || fail "python3 não encontrado."

step "Procurando perfis nativos do Vivaldi"
PROFILE_ROOTS=()

for root in \
  "$HOME/.config/vivaldi" \
  "$HOME/.config/vivaldi-snapshot" \
  "$HOME/.config/vivaldi-unstable"
do
  [[ -d "$root" ]] && PROFILE_ROOTS+=("$root")
done

if (( ${#PROFILE_ROOTS[@]} == 0 )); then
  fail "não encontrei ~/.config/vivaldi, ~/.config/vivaldi-snapshot nem ~/.config/vivaldi-unstable."
fi

PREFS_FILES=()
for root in "${PROFILE_ROOTS[@]}"; do
  while IFS= read -r prefs; do
    PREFS_FILES+=("$prefs")
  done < <(
    find "$root" -maxdepth 3 -type f -name Preferences \
      ! -path '*/System Profile/*' \
      ! -path '*/Guest Profile/*' \
      2>/dev/null | sort
  )
done

if (( ${#PREFS_FILES[@]} == 0 )); then
  fail "não encontrei arquivos Preferences dentro dos perfis do Vivaldi."
fi

printf 'Preferences encontrados:\n'
printf '%s\n' "${PREFS_FILES[@]}"

RESTORED_COUNT=0
PATCHED_COUNT=0

step "Restaurando backups criados antes da alteração de tema"
for prefs in "${PREFS_FILES[@]}"; do
  dir="$(dirname "$prefs")"

  latest_backup="$(
    find "$dir" -maxdepth 1 -type f -name 'Preferences.backup-mocha-vivaldi-tema-*' -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | head -n 1 \
    | cut -d' ' -f2-
  )"

  printf '\nPerfil: %s\n' "$dir"

  if [[ -n "$latest_backup" && -f "$latest_backup" ]]; then
    broken_copy="$dir/Preferences.quebrado-mocha-tema-${TS}"

    cp -a "$prefs" "$broken_copy"
    cp -a "$latest_backup" "$prefs"

    python3 -m json.tool "$prefs" >/dev/null

    printf 'Restaurado backup:\n%s\n' "$latest_backup"
    printf 'Preferences quebrado salvo em:\n%s\n' "$broken_copy"

    RESTORED_COUNT=$((RESTORED_COUNT + 1))
  else
    printf 'Sem backup automático neste perfil. Vou tentar remover apenas o tema Mocha injetado.\n'

    python3 - "$prefs" "$TS" <<'PY'
import sys, json, shutil
from pathlib import Path

prefs = Path(sys.argv[1])
ts = sys.argv[2]

data = json.loads(prefs.read_text(encoding="utf-8", errors="replace"))

backup = prefs.with_name(f"Preferences.pre-patch-tema-mocha-{ts}")
shutil.copy2(prefs, backup)

vivaldi = data.get("vivaldi")
if isinstance(vivaldi, dict):
    themes = vivaldi.get("themes")
    if isinstance(themes, dict):
        for key in ("user", "custom"):
            if isinstance(themes.get(key), list):
                themes[key] = [
                    item for item in themes[key]
                    if not (
                        isinstance(item, dict)
                        and (
                            str(item.get("name", "")).startswith("Mocha KDE Direto")
                            or str(item.get("id", "")).startswith("Mocha KDE Direto")
                            or str(item.get("themeName", "")).startswith("Mocha KDE Direto")
                            or str(item.get("name", "")).startswith("Mocha KDE Vivaldi")
                            or str(item.get("themeName", "")).startswith("Mocha KDE Vivaldi")
                        )
                    )
                ]

        for key in ("current", "selected", "theme", "currentId", "private"):
            if isinstance(themes.get(key), str) and themes[key].startswith(("Mocha KDE Direto", "Mocha KDE Vivaldi")):
                themes.pop(key, None)

tmp = prefs.with_name(f"Preferences.mocha-repair-tmp-{ts}")
tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
json.loads(tmp.read_text(encoding="utf-8"))
tmp.replace(prefs)

print(f"Backup antes do patch: {backup}")
PY

    PATCHED_COUNT=$((PATCHED_COUNT + 1))
  fi
done

step "Removendo arquivos de trava antigos do Chromium/Vivaldi se existirem"
for root in "${PROFILE_ROOTS[@]}"; do
  for lock in SingletonLock SingletonSocket SingletonCookie; do
    if [[ -e "$root/$lock" || -L "$root/$lock" ]]; then
      rm -f "$root/$lock" || true
      printf 'Removido: %s\n' "$root/$lock"
    fi
  done
done

step "Registrando correção"
{
  printf '%s\n' "# Vivaldi - restauração de Preferences após erro de tema"
  printf '\n'
  printf '%s\n' "Data: $TS"
  printf '%s\n' "Backups restaurados: $RESTORED_COUNT"
  printf '%s\n' "Perfis corrigidos por patch sem backup: $PATCHED_COUNT"
  printf '\n'
  printf '%s\n' "Preferences processados:"
  printf '%s\n' "${PREFS_FILES[@]}"
  printf '\n'
  printf '%s\n' "Motivo provável:"
  printf '%s\n' "A edição direta do Preferences criou estrutura de tema incompatível com o Vivaldi atual, causando erro JavaScript interno ao iniciar."
  printf '\n'
  printf '%s\n' "Arquivos Preferences quebrados foram preservados com timestamp quando houve restauração por backup."
} > "$DOC"

cp -f "${BASH_SOURCE[0]}" "$SCRIPT_COPY"

step "Abrindo Vivaldi novamente"
if command -v vivaldi-stable >/dev/null 2>&1; then
  nohup vivaldi-stable >/dev/null 2>&1 &
elif command -v vivaldi >/dev/null 2>&1; then
  nohup vivaldi >/dev/null 2>&1 &
elif command -v vivaldi-snapshot >/dev/null 2>&1; then
  nohup vivaldi-snapshot >/dev/null 2>&1 &
else
  printf 'Vivaldi não encontrado no PATH. Abra manualmente pelo menu.\n'
fi

printf '\nPRONTO.\n'
printf 'Restaurados por backup: %s\n' "$RESTORED_COUNT"
printf 'Corrigidos por patch sem backup: %s\n' "$PATCHED_COUNT"
printf 'Log: %s\n' "$LOG"
printf 'Documento: %s\n' "$DOC"
