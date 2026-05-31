#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
ISO="/home/hal/Downloads/Calam-Arch-Installer-2026-05.iso"

if [ ! -d "$BASE" ]; then
  BASE="$HOME/MochaArch"
fi

OUT="$BASE/auditorias/iso-calam-rootfs-corrigido-$TS"
mkdir -p "$OUT"

LOG="$OUT/auditoria-profunda-calam-corrigida-$TS.log"
MD="$OUT/RELATORIO-AUDITORIA-PROFUNDA-CALAM-CORRIGIDA-$TS.md"

exec > >(tee -a "$LOG") 2>&1

echo "== MOCHA ARCH — AUDITORIA PROFUNDA ISO CALAM =="
echo "Saída: $OUT"
echo

if [ ! -f "$ISO" ]; then
  echo "ERRO: ISO não encontrada:"
  echo "$ISO"
  exit 1
fi

case "$ISO" in
  *"/XU/"*|*" XU "*|*"xu705"*|*"xu704"*|*"xu706"*)
    echo "ERRO: caminho envolve XU, que é intocável por padrão:"
    echo "$ISO"
    exit 1
    ;;
esac

SUDO="$(command -v sudo || true)"
if [ -z "$SUDO" ]; then
  echo "ERRO: sudo não encontrado."
  exit 1
fi

"$SUDO" -v

if ! command -v unsquashfs >/dev/null 2>&1; then
  echo "ERRO: unsquashfs ainda não existe. Instale squashfs-tools e rode de novo."
  exit 1
fi

TMP="$(mktemp -d)"
MNT="$TMP/iso"
ROOTFS="$TMP/rootfs"
mkdir -p "$MNT" "$ROOTFS"

cleanup() {
  set +e
  if mountpoint -q "$MNT"; then
    "$SUDO" umount "$MNT" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "== ISO =="
ls -lh "$ISO"
file "$ISO" || true
sha256sum "$ISO" | tee "$OUT/SHA256SUM-local-$TS.txt"
echo

echo "== Montando ISO read-only =="
"$SUDO" mount -o loop,ro "$ISO" "$MNT"
echo "Montada em: $MNT"
echo

echo "== Procurando SquashFS =="
mapfile -t SFS_LIST < <(find "$MNT" -type f \( -iname "*.sfs" -o -iname "*.squashfs" \) -print | sort)

if [ "${#SFS_LIST[@]}" -eq 0 ]; then
  echo "ERRO: nenhum SquashFS encontrado dentro da ISO."
  exit 1
fi

printf '%s\n' "${SFS_LIST[@]}" | sed "s#^$MNT#/ISO#" | tee "$OUT/squashfs-encontrados-$TS.txt"
SFS="${SFS_LIST[0]}"
echo

echo "== Informações do SquashFS =="
unsquashfs -s "$SFS" | tee "$OUT/info-squashfs-$TS.txt"
echo

echo "== Listando rootfs interno =="
unsquashfs -ll "$SFS" > "$OUT/lista-rootfs-squashfs-$TS.txt"
echo "Lista salva: $OUT/lista-rootfs-squashfs-$TS.txt"
echo

echo "== Extraindo arquivos relevantes do rootfs =="
unsquashfs -f -d "$ROOTFS" "$SFS" \
  etc/pacman.conf \
  etc/pacman.d \
  etc/os-release \
  etc/lsb-release \
  etc/calamares \
  usr/share/calamares \
  usr/share/applications/calamares.desktop \
  var/lib/pacman/local \
  >/dev/null 2>&1 || true

mkdir -p "$OUT/rootfs-extraido"
cp -a "$ROOTFS"/. "$OUT/rootfs-extraido/" 2>/dev/null || true
echo "Extração relevante salva: $OUT/rootfs-extraido"
echo

echo "== Detectando pacotes no rootfs live =="
{
  find "$OUT/rootfs-extraido/var/lib/pacman/local" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null || true
} | sort -u > "$OUT/pacotes-rootfs-live-$TS.txt"

echo "Total de pacotes detectados:"
wc -l "$OUT/pacotes-rootfs-live-$TS.txt"
echo

echo "== Pacotes relevantes/suspeitos =="
grep -Ei \
  "calamares|pamac|yay|paru|endeavour|endeavouros|arco|arcolinux|garuda|manjaro|cachy|chaotic|blackarch|alci|blue|keyring|mirrorlist|branding|theme|wallpaper|nvidia|linux|zen|headers" \
  "$OUT/pacotes-rootfs-live-$TS.txt" \
  | tee "$OUT/pacotes-relevantes-suspeitos-$TS.txt" || true
echo

echo "== Pacman/repos extraídos =="
{
  find "$OUT/rootfs-extraido" -type f \( -name "pacman.conf" -o -name "mirrorlist" \) -print0 |
    while IFS= read -r -d "" f; do
      echo "----- $f -----"
      grep -nE "^\s*(\[|Server|Include|SigLevel|ParallelDownloads|ILoveCandy)" "$f" || true
      echo
    done
} | tee "$OUT/repos-pacman-rootfs-$TS.txt"
echo

echo "== Identidade os-release/lsb-release =="
{
  find "$OUT/rootfs-extraido" -type f \( -name "os-release" -o -name "lsb-release" \) -print0 |
    while IFS= read -r -d "" f; do
      echo "----- $f -----"
      cat "$f"
      echo
    done
} | tee "$OUT/os-release-rootfs-$TS.txt"
echo

echo "== Calamares configs =="
find "$OUT/rootfs-extraido" -path "*calamares*" -type f | sort | tee "$OUT/arquivos-calamares-extraidos-$TS.txt" || true
echo

echo "== Marcadores de identidade/repo/branding =="
grep -RInE \
  "pamac|yay|paru|endeavour|endeavouros|arcolinux|garuda|manjaro|cachy|chaotic|blackarch|alci|blue|third.?party|AUR|keyring|branding|welcome|greeter" \
  "$OUT/rootfs-extraido" \
  > "$OUT/marcadores-identidade-repos-pacotes-$TS.txt" 2>/dev/null || true

if [ -s "$OUT/marcadores-identidade-repos-pacotes-$TS.txt" ]; then
  sed -n "1,220p" "$OUT/marcadores-identidade-repos-pacotes-$TS.txt"
else
  echo "Nenhum marcador forte encontrado nos arquivos extraídos."
fi
echo

echo "== Boot entries da ISO =="
{
  find "$MNT/loader/entries" "$MNT/boot/syslinux" -maxdepth 1 -type f 2>/dev/null | sort |
    while read -r f; do
      echo "----- ${f#$MNT/} -----"
      sed -n "1,120p" "$f" || true
      echo
    done
} | tee "$OUT/boot-entries-iso-$TS.txt"
echo

echo "== Gerando relatório Markdown =="
{
  echo "# Auditoria profunda Calam-Arch corrigida — $TS"
  echo
  echo "## ISO"
  echo
  echo "- Caminho: $ISO"
  echo "- Hash SHA256:"
  echo
  sed -n "1p" "$OUT/SHA256SUM-local-$TS.txt"
  echo
  echo "## Identidade do sistema live"
  echo
  sed -n "1,120p" "$OUT/os-release-rootfs-$TS.txt" 2>/dev/null || true
  echo
  echo "## Repositórios/pacman"
  echo
  sed -n "1,180p" "$OUT/repos-pacman-rootfs-$TS.txt" 2>/dev/null || true
  echo
  echo "## Pacotes relevantes/suspeitos"
  echo
  if [ -s "$OUT/pacotes-relevantes-suspeitos-$TS.txt" ]; then
    sed -n "1,180p" "$OUT/pacotes-relevantes-suspeitos-$TS.txt"
  else
    echo "Nenhum pacote suspeito/relevante encontrado pelo filtro."
  fi
  echo
  echo "## Marcadores de identidade/repo/branding"
  echo
  if [ -s "$OUT/marcadores-identidade-repos-pacotes-$TS.txt" ]; then
    sed -n "1,260p" "$OUT/marcadores-identidade-repos-pacotes-$TS.txt"
  else
    echo "Nenhum marcador forte encontrado nos arquivos extraídos."
  fi
  echo
  echo "## Critério Mocha"
  echo
  echo "- Aprovável: repositórios Arch oficiais core, extra e opcionalmente multilib."
  echo "- Atenção: pamac no live não reprova sozinho; pamac instalado no sistema final ou repo próprio reprova."
  echo "- Rejeitar ou exigir limpeza pesada: repo próprio, keyring próprio, branding persistente, welcome app ou identidade de derivada."
  echo
  echo "## Arquivos gerados"
  echo
  echo "- Log: $LOG"
  echo "- Pacotes rootfs live: $OUT/pacotes-rootfs-live-$TS.txt"
  echo "- Pacotes relevantes: $OUT/pacotes-relevantes-suspeitos-$TS.txt"
  echo "- Repos pacman: $OUT/repos-pacman-rootfs-$TS.txt"
  echo "- Marcadores: $OUT/marcadores-identidade-repos-pacotes-$TS.txt"
  echo "- Boot entries: $OUT/boot-entries-iso-$TS.txt"
} > "$MD"

echo "== RESUMO FINAL =="
echo "Relatório: $MD"
echo

echo "-- Identidade --"
sed -n "1,80p" "$OUT/os-release-rootfs-$TS.txt" 2>/dev/null || true
echo

echo "-- Repositórios --"
sed -n "1,120p" "$OUT/repos-pacman-rootfs-$TS.txt" 2>/dev/null || true
echo

echo "-- Pacotes relevantes/suspeitos --"
if [ -s "$OUT/pacotes-relevantes-suspeitos-$TS.txt" ]; then
  sed -n "1,120p" "$OUT/pacotes-relevantes-suspeitos-$TS.txt"
else
  echo "Nenhum pacote suspeito/relevante encontrado pelo filtro."
fi
echo

echo "-- Marcadores --"
if [ -s "$OUT/marcadores-identidade-repos-pacotes-$TS.txt" ]; then
  sed -n "1,80p" "$OUT/marcadores-identidade-repos-pacotes-$TS.txt"
else
  echo "Nenhum marcador forte encontrado nos arquivos extraídos."
fi
echo

echo "== Concluído =="
