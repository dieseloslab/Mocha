#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
INT="/media/mochafast/MochaArch-Interno"
APP="$PUB/apps/mocha-updater"

echo "============================================================"
echo " Mocha Updater — auditoria pre-refatoracao"
echo "============================================================"
echo
echo "Data:"
date -Is
echo

echo "Sistema:"
uname -a || true
echo
cat /etc/os-release 2>/dev/null || true
echo

echo "Kernel/pacotes principais:"
pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open nvidia-open nvidia-utils 2>/dev/null || true
echo

echo "NVIDIA:"
timeout 8 nvidia-smi 2>/dev/null || true
echo

echo "Locale atual:"
locale || true
echo

echo "Repo publico:"
if [ -d "$PUB/.git" ]; then
  git -C "$PUB" status --short
  git -C "$PUB" rev-parse --short HEAD
  git -C "$PUB" rev-list --left-right --count HEAD...origin/main 2>/dev/null || true
else
  echo "Repo publico sem .git"
fi
echo

echo "Repo interno:"
if [ -d "$INT/.git" ]; then
  git -C "$INT" status --short
  git -C "$INT" rev-parse --short HEAD
  git -C "$INT" rev-list --left-right --count HEAD...origin/main 2>/dev/null || true
else
  echo "Repo interno sem .git"
fi
echo

echo "Arvore apps/mocha-updater:"
if [ -d "$APP" ]; then
  find "$APP" -maxdepth 4 -type f | sort
else
  echo "AUSENTE: $APP"
fi
echo

echo "Cargo/Rust:"
if [ -f "$APP/Cargo.toml" ]; then
  sed -n '1,220p' "$APP/Cargo.toml"
else
  echo "Cargo.toml ausente"
fi
echo

echo "Binarios Mocha relacionados:"
find /usr/local/bin /usr/local/sbin -maxdepth 1 \
  \( -iname '*mocha*update*' -o -iname '*mocha*kernel*' -o -iname '*mocha*driver*' \) \
  -printf '%m %u:%g %p -> %l\n' 2>/dev/null | sort || true
echo

echo "Desktop/menu Mocha relacionados:"
find \
  /usr/share/applications \
  /usr/local/share/applications \
  "$HOME/Desktop" \
  "$HOME/Área de Trabalho" \
  /etc/skel/Desktop \
  "/etc/skel/Área de Trabalho" \
  -maxdepth 1 -type f \
  \( -iname '*mocha*.desktop' -o -iname '*updater*.desktop' -o -iname '*kernel*.desktop' -o -iname '*driver*.desktop' \) \
  -printf '%m %u:%g %p\n' 2>/dev/null | sort || true
echo

echo "Conteudo dos .desktop encontrados:"
while IFS= read -r f; do
  echo
  echo "----- $f -----"
  sed -n '1,220p' "$f" 2>/dev/null || true
done < <(
  find \
    /usr/share/applications \
    /usr/local/share/applications \
    "$HOME/Desktop" \
    "$HOME/Área de Trabalho" \
    /etc/skel/Desktop \
    "/etc/skel/Área de Trabalho" \
    -maxdepth 1 -type f \
    \( -iname '*mocha*.desktop' -o -iname '*updater*.desktop' -o -iname '*kernel*.desktop' -o -iname '*driver*.desktop' \) \
    2>/dev/null | sort
)
echo

echo "Possiveis arquivos antigos/duplicados no projeto:"
find "$PUB" "$INT" -type f \
  \( -iname '*updater*' -o -iname '*kernel*driver*' -o -iname '*mocha*update*' \) \
  2>/dev/null | sort || true
echo

echo "Ultimos logs/pacman relevantes:"
grep -Ei 'linux-cachyos|nvidia|mocha|kernel|driver|updater' /var/log/pacman.log 2>/dev/null | tail -n 120 || true
echo

echo "dmesg storage/nvidia recente:"
timeout 8 dmesg -T 2>/dev/null | grep -Ei 'xfs|ext4|nvme|sda|sdb|i/o error|metadata corruption|nvidia|gpu' | tail -n 160 || true
echo

echo "============================================================"
echo " Fim da auditoria"
echo "============================================================"
