#!/usr/bin/env bash
set -u

FAIL=0
TS="$(date +%Y%m%d-%H%M%S)"
PKG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AUD="/media/mochafast/MochaArch-Interno/ativo/auditorias/reaplica-gamemode-oc-nvidia-nvml-$TS"

START_HOOK="/usr/local/lib/mocha/gamemode-start-agressivo-oc.sh"
END_HOOK="/usr/local/lib/mocha/gamemode-end-agressivo-oc.sh"

sudo -v || exit 1
mkdir -p "$AUD" || exit 1

echo "================================================================"
echo "Mocha — aplica GameMode OC NVIDIA NVML"
echo "Pacote: $PKG_DIR"
echo "Auditoria: $AUD"
echo "================================================================"

if [ ! -d "$PKG_DIR/files" ]; then
  echo "FALHA: diretorio files ausente no pacote."
  exit 1
fi

if sudo test -f "/etc/gamemode.ini"; then
  sudo cp -a "/etc/gamemode.ini" "$AUD/gamemode.ini.antes"
fi

install_payload_file() {
  src="$1"
  rel="${src#"$PKG_DIR/files/"}"
  dest="/$rel"

  sudo mkdir -p "$(dirname "$dest")" || return 1

  if [ -L "$src" ]; then
    target="$(readlink -- "$src")" || return 1

    if sudo test -e "$dest" || sudo test -L "$dest"; then
      sudo rm -f -- "$dest" || return 1
    fi

    sudo ln -s -- "$target" "$dest" || return 1
    sudo chown -h root:root "$dest" || return 1

    echo "INSTALADO_LINK: $dest -> $target"
    return 0
  fi

  case "$dest" in
    /etc/sudoers.d/mocha-nvidia-oc-root-helper)
      sudo install -o root -g root -m 0440 "$src" "$dest" || return 1
      ;;
    /usr/local/lib/mocha/mocha-nvidia-oc-root-helper|/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system|/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system)
      sudo install -o root -g root -m 0755 "$src" "$dest" || return 1
      ;;
    /etc/mocha/nvidia-game-oc.conf)
      sudo install -o root -g root -m 0644 "$src" "$dest" || return 1
      ;;
    *)
      sudo install -o root -g root -m 0644 "$src" "$dest" || return 1
      ;;
  esac

  echo "INSTALADO: $dest"
  return 0
}

while IFS= read -r -d '' src; do
  install_payload_file "$src" || FAIL=1
done < <(find "$PKG_DIR/files" \( -type f -o -type l \) -print0 | sort -z)

if sudo test -f "/etc/sudoers.d/mocha-nvidia-oc-root-helper"; then
  sudo visudo -cf "/etc/sudoers.d/mocha-nvidia-oc-root-helper" >/dev/null 2>&1 || FAIL=1
else
  echo "FALHA: sudoers do helper NVML ausente."
  FAIL=1
fi

for f in \
  "/usr/local/lib/mocha/mocha-nvidia-oc-root-helper" \
  "$START_HOOK" \
  "$END_HOOK"
do
  if sudo test -x "$f"; then
    echo "OK: executavel: $f"
  else
    echo "FALHA: arquivo requerido ausente ou sem execucao: $f"
    FAIL=1
  fi
done

TMP="$(mktemp)"
if sudo test -f "/etc/gamemode.ini"; then
  sudo cat "/etc/gamemode.ini" > "$TMP"
else
  : > "$TMP"
fi

awk -v start="$START_HOOK" -v end="$END_HOOK" '
BEGIN { in_custom=0; wrote=0 }
/^[[:space:]]*\[custom\][[:space:]]*$/ {
  print "[custom]"
  print "start=" start
  print "end=" end
  in_custom=1
  wrote=1
  next
}
/^[[:space:]]*\[/ {
  in_custom=0
}
in_custom && /^[[:space:]]*(start|end)[[:space:]]*=/ {
  next
}
{
  print
}
END {
  if (wrote == 0) {
    print ""
    print "[custom]"
    print "start=" start
    print "end=" end
  }
}
' "$TMP" > "$TMP.novo"

sudo install -o root -g root -m 0644 "$TMP.novo" "/etc/gamemode.ini" || FAIL=1
rm -f "$TMP" "$TMP.novo"

sudo grep -nE "^\[custom\]|^start=|^end=" "/etc/gamemode.ini" | tee "$AUD/gamemode-custom-depois.txt" >/dev/null || true

echo
echo "================================================================"
echo "Permissoes finais"
echo "================================================================"
for f in \
  "/etc/mocha/nvidia-game-oc.conf" \
  "/etc/sudoers.d/mocha-nvidia-oc-root-helper" \
  "/usr/local/lib/mocha/mocha-nvidia-oc-root-helper" \
  "$START_HOOK" \
  "$END_HOOK" \
  "/etc/gamemode.ini"
do
  if sudo test -e "$f"; then
    sudo ls -l "$f"
  else
    echo "FALHA: ausente: $f"
    FAIL=1
  fi
done | tee "$AUD/permissoes-finais.txt"

if [ "$FAIL" -ne 0 ]; then
  echo "FALHA: aplicacao terminou com erro. Veja: $AUD"
  exit 1
fi

echo "OK: GameMode OC NVIDIA NVML aplicado com donos e modos corretos."
echo "OK: start=$START_HOOK"
echo "OK: end=$END_HOOK"
