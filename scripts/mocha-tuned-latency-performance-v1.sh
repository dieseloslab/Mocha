#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

sudo -v

SUDO_KEEPALIVE_PID=""
(
  while true; do
    sudo -n true || exit
    sleep 30
  done
) &
SUDO_KEEPALIVE_PID="$!"

cleanup() {
  set +e
  [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*" >&2; exit 1; }

FAST="/media/mochafast/MochaArch"
INTERNO="/media/mochafast/MochaArch-Interno"
MANUAL_VIVO="$INTERNO/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"

SCRIPT_DIR="$FAST/scripts"
SCRIPT_CANONICO="$SCRIPT_DIR/mocha-tuned-latency-performance-v1.sh"

PROFILE="mocha-latency-performance"
PROFILE_DIR="/etc/tuned/profiles/$PROFILE"
CONF="$PROFILE_DIR/tuned.conf"

STAMP="$(date +%Y%m%d-%H%M%S)"
AUDIT_DIR="$FAST/auditorias/tuned-mocha-latency-performance-$STAMP"
LOG="$AUDIT_DIR/execucao.log"

[ -d "$FAST" ] || fail "FAST não montado em $FAST"
mkdir -p "$SCRIPT_DIR" "$AUDIT_DIR"

exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo " Mocha — TuneD mocha-latency-performance"
echo "============================================================"
echo

if ! command -v tuned-adm >/dev/null 2>&1; then
  warn "tuned-adm ausente; instalando tuned via pacman sem atualizar base isoladamente."
  sudo pacman -S --needed --noconfirm tuned
fi

command -v tuned-adm >/dev/null 2>&1 || fail "tuned-adm ainda ausente após tentativa de instalação"

echo
echo "TuneD atual:"
timeout 10 tuned-adm active || true
timeout 10 systemctl is-active tuned.service || true
timeout 10 systemctl is-enabled tuned.service || true

echo
echo "Perfis TuneD disponíveis antes:"
timeout 10 tuned-adm list | sed -n '1,120p' || true

if ! timeout 10 tuned-adm list | grep -qE "^[[:space:]]*-[[:space:]]+latency-performance[[:space:]]"; then
  fail "Perfil base latency-performance não apareceu em tuned-adm list. Não vou criar perfil filho sem base válida."
fi

echo
echo "Backup de perfil anterior, se existir:"
if [ -d "$PROFILE_DIR" ]; then
  sudo cp -a "$PROFILE_DIR" "$AUDIT_DIR/${PROFILE}.bak"
  ok "Backup salvo em $AUDIT_DIR/${PROFILE}.bak"
else
  ok "Perfil anterior não existia"
fi

echo
echo "Criando perfil TuneD Mocha:"
sudo install -d -m 0755 "$PROFILE_DIR"

sudo tee "$CONF" >/dev/null <<'EOF'
[main]
summary=Mocha low-latency/performance base profile for gamer desktop
include=latency-performance

[mocha_sysctl]
type=sysctl

# Mocha canonical VM/memory policy.
vm.swappiness=133
vm.vfs_cache_pressure=50
vm.page-cluster=0
vm.dirty_background_bytes=67108864
vm.dirty_bytes=268435456
vm.max_map_count=8388608

# Preserve interactive desktop grouping outside GameMode.
kernel.sched_autogroup_enabled=1
EOF

sudo chmod 0644 "$CONF"
ok "Perfil escrito em $CONF"

echo
echo "Conteúdo do perfil:"
sed -n '1,160p' "$CONF"

echo
echo "Ativando TuneD:"
sudo systemctl enable --now tuned.service
timeout 10 systemctl is-active tuned.service || fail "tuned.service não ficou ativo"
timeout 10 systemctl is-enabled tuned.service || true

echo
echo "Aplicando perfil $PROFILE:"
sudo tuned-adm profile "$PROFILE"

echo
echo "Perfil ativo:"
timeout 10 tuned-adm active || true

if timeout 20 tuned-adm verify; then
  ok "tuned-adm verify passou"
else
  warn "tuned-adm verify retornou aviso/falha. Ver log do TuneD e $LOG antes de tratar como canônico definitivo."
fi

echo
echo "Sysctl Mocha aplicados:"
for key in \
  vm.swappiness \
  vm.vfs_cache_pressure \
  vm.page-cluster \
  vm.dirty_background_bytes \
  vm.dirty_bytes \
  vm.max_map_count \
  kernel.sched_autogroup_enabled
do
  printf '%s = ' "$key"
  sysctl -n "$key" 2>/dev/null || true
done

echo
echo "Salvando este script como canônico:"
install -Dm755 "$0" "$SCRIPT_CANONICO"
ok "$SCRIPT_CANONICO"

echo
echo "Documentando no manual vivo interno, se existir:"
MANUAL_BLOCK="$(mktemp)"
cat > "$MANUAL_BLOCK" <<EOF
<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_START -->
## TuneD canônico Mocha: mocha-latency-performance

Perfil canônico: \`mocha-latency-performance\`.

Caminho do perfil no sistema instalado:

    /etc/tuned/profiles/mocha-latency-performance/tuned.conf

Script canônico:

    $SCRIPT_CANONICO

Como aplicar/reaplicar:

    sudo bash $SCRIPT_CANONICO

Modelo de autoridade de performance:

    TuneD mantém o chão permanente de baixa latência/performance.
    system76-scheduler administra responsividade normal do desktop.
    GameMode assume autoridade máxima durante jogos.
    Ao fechar o jogo, GameMode reverte ajustes temporários e o sistema volta ao estado normal.

O perfil Mocha herda de \`latency-performance\` e fixa os sysctl canônicos do projeto:

    vm.swappiness=133
    vm.vfs_cache_pressure=50
    vm.page-cluster=0
    vm.dirty_background_bytes=67108864
    vm.dirty_bytes=268435456
    vm.max_map_count=8388608
    kernel.sched_autogroup_enabled=1

Regra: o perfil TuneD não deve ser mais fraco que a base exigida pelo GameMode. Durante jogo, GameMode prevalece.
<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_END -->
EOF

upsert_block() {
  local file="$1"
  local block_file="$2"
  local start='<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_START -->'
  local end='<!-- MOCHA_TUNED_LATENCY_PERFORMANCE_END -->'
  local tmp
  tmp="$(mktemp)"

  sudo install -d -m 0755 "$(dirname "$file")"

  if [ -f "$file" ]; then
    sudo cp -a "$file" "$AUDIT_DIR/$(basename "$file").bak"
    awk -v start="$start" -v end="$end" -v block_file="$block_file" '
      BEGIN {
        while ((getline line < block_file) > 0) {
          block = block line ORS
        }
        close(block_file)
        inblock = 0
        done = 0
      }
      $0 == start {
        if (!done) {
          printf "%s", block
          done = 1
        }
        inblock = 1
        next
      }
      $0 == end {
        inblock = 0
        next
      }
      !inblock {
        print
      }
      END {
        if (!done) {
          print ""
          printf "%s", block
        }
      }
    ' "$file" > "$tmp"
  else
    cat "$block_file" > "$tmp"
  fi

  sudo install -m 0644 "$tmp" "$file"
  rm -f "$tmp"
}

if [ -f "$MANUAL_VIVO" ]; then
  upsert_block "$MANUAL_VIVO" "$MANUAL_BLOCK"
  ok "Manual vivo atualizado: $MANUAL_VIVO"
else
  warn "Manual vivo não encontrado em $MANUAL_VIVO"
fi

PUBLIC_MANUAL="$FAST/MANUAL-MOCHA-CURTO.md"
upsert_block "$PUBLIC_MANUAL" "$MANUAL_BLOCK"
ok "Manual curto/nota pública atualizado: $PUBLIC_MANUAL"

rm -f "$MANUAL_BLOCK"

echo
echo "Resumo final:"
echo "  Perfil TuneD: $PROFILE"
echo "  Configuração: $CONF"
echo "  Script canônico: $SCRIPT_CANONICO"
echo "  Log: $LOG"
echo
ok "TuneD Mocha latency-performance criado/aplicado/canonizado"
