set -Eeuo pipefail

export LC_ALL=C
export PAGER=cat
export SYSTEMD_PAGER=cat
export LESS=FRX

PUBLIC_PKG='/media/mochafast/MochaArch/scripts/performance/gamemode-oc-nvidia-nvml'
INTERNAL_PKG='/media/mochafast/MochaArch-Interno/ativo/performance/gamemode-oc-nvidia-nvml'
UNIT='com.system76.Scheduler.service'
PROFILE='mocha-latency-performance'

HELPER='/usr/local/sbin/mocha-system76-authority-helper'
SUDOERS='/etc/sudoers.d/mocha-gamemode-system76-authority'
START_HOOK='/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system'
END_HOOK='/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system'
GAMEMODE_CONF='/etc/gamemode.ini'
USER_GAMEMODE_CONF="$HOME/.config/gamemode.ini"
LEGACY_START_CMD='/etc/mocha/gamemode/legacy-start-system.cmd'
LEGACY_END_CMD='/etc/mocha/gamemode/legacy-end-system.cmd'

SHA_HELPER='58a8e4dc6a4916c9178814086551f3f44bdba7b7a39caf6fcd47d7ba38eec5bb'
SHA_START='7a817389836af6f9c49d5a44ce8204bc5f0fa70497d5a463e4e7a3ba830ca1a2'
SHA_END='7be2a646fe45250794e84dea8fdd0bf48c7a13821452571b29dc15eacae03adb'
SHA_GAMEMODE_CONF='bd41359ec63ebd5b2686b5da4dd707b4dfaab40e5b0e86d8ba39d34bfd74ef1c'

STAMP="$(date '+%Y%m%d-%H%M%S')"
REPORT="$HOME/Documentos/mocha-restaura-autoridade-gamemode-system76-sem-oc-${STAMP}.txt"
BACKUP_DIR="/var/backups/mocha/gamemode-system76-sem-oc-${STAMP}"
WRAPPER_LOG="/tmp/mocha-gamemode-authority-${USER:-unknown}.log"
MARKER="MOCHA_AUTHORITY_NO_OC_TEST_${STAMP}"

KEEPALIVE=''
CLIENT_PID=''
CHANGED=0
COMPLETED=0
TEST_STARTED=0
FAIL=0

TARGETS=(
    "$HELPER"
    "$SUDOERS"
    "$START_HOOK"
    "$END_HOOK"
    "$GAMEMODE_CONF"
)

fail() {
    printf '\nERRO: %s\n' "$*" >&2
    exit 1
}

mark_fail() {
    printf '[FALHA] %s\n' "$*" >&2
    FAIL=$((FAIL + 1))
}

backup_target() {
    local target="$1"
    local backup="$BACKUP_DIR/runtime$target"

    if sudo test -e "$target" || sudo test -L "$target"; then
        sudo install -d -o root -g root -m 0700 "$(dirname "$backup")"
        sudo cp -a -- "$target" "$backup"
        printf 'BACKUP_EXISTENTE %s -> %s\n' "$target" "$backup"
    else
        printf 'AUSENTE_ANTES %s\n' "$target" |
            sudo tee -a "$BACKUP_DIR/ausentes-antes.txt" >/dev/null
    fi
}

restore_target() {
    local target="$1"
    local backup="$BACKUP_DIR/runtime$target"

    if sudo test -e "$backup" || sudo test -L "$backup"; then
        sudo install -d -o root -g root -m 0755 "$(dirname "$target")"
        sudo rm -rf -- "$target"
        sudo cp -a -- "$backup" "$target"
    else
        sudo rm -rf -- "$target"
    fi
}

helper_count() {
    sudo -n "$HELPER" status 2>/dev/null |
        awk -F= '$1 == "count" {print $2; exit}'
}

cleanup() {
    local rc=$?
    local count=''
    local i

    set +e

    if [[ -n "${CLIENT_PID:-}" ]] && kill -0 "$CLIENT_PID" 2>/dev/null; then
        kill "$CLIENT_PID" 2>/dev/null || true
        wait "$CLIENT_PID" 2>/dev/null || true
    fi

    if (( TEST_STARTED == 1 )) && sudo test -x "$HELPER"; then
        for i in $(seq 1 32); do
            count="$(helper_count || true)"
            [[ "$count" =~ ^[0-9]+$ ]] || break
            (( count > 0 )) || break
            sudo -n "$HELPER" end >/dev/null 2>&1 || break
        done

        sudo systemctl start "$UNIT" >/dev/null 2>&1 || true
        sudo tuned-adm profile "$PROFILE" >/dev/null 2>&1 || true
    fi

    if (( rc != 0 && CHANGED == 1 && COMPLETED == 0 )); then
        printf '\nFalha detectada; restaurando exatamente os alvos anteriores...\n' >&2

        systemctl --user stop gamemoded.service >/dev/null 2>&1 || true

        for target in "${TARGETS[@]}"; do
            restore_target "$target"
        done

        sudo systemctl start "$UNIT" >/dev/null 2>&1 || true
        sudo tuned-adm profile "$PROFILE" >/dev/null 2>&1 || true
        systemctl --user stop gamemoded.service >/dev/null 2>&1 || true
    fi

    if [[ -n "${KEEPALIVE:-}" ]]; then
        kill "$KEEPALIVE" 2>/dev/null || true
        wait "$KEEPALIVE" 2>/dev/null || true
    fi

    exit "$rc"
}
trap cleanup EXIT INT TERM

mkdir -p "$(dirname "$REPORT")"
exec > >(tee "$REPORT") 2>&1

printf '%s\n' '============================================================'
printf '%s\n' 'MOCHA — RESTAURA AUTORIDADE GAMEMODE/SYSTEM76 SEM OC'
printf '%s\n' '============================================================'
printf 'Data: %s\n' "$(date --iso-8601=seconds)"
printf 'Relatório: %s\n' "$REPORT"
printf 'Backup: %s\n' "$BACKUP_DIR"
printf '%s\n' 'Fonte: payloads canônicos público e interno.'
printf '%s\n' 'Escopo instalado: helper, sudoers, wrappers de autoridade e gamemode.ini.'
printf '%s\n' 'OC NVIDIA: não habilitado nem executado; nenhum artefato de OC é instalado nesta etapa.'
printf '%s\n' 'Manuais/repos Git: não alterados.'

for cmd in \
    awk bash cmp flock gamemoded gamemoderun grep install journalctl \
    pacman sed seq sha256sum sleep stat systemctl tee timeout tuned-adm visudo
do
    command -v "$cmd" >/dev/null 2>&1 ||
        fail "comando obrigatório ausente: $cmd"
done

sudo -v ||
    fail 'não foi possível validar sudo.'

(
    while sudo -n true 2>/dev/null; do
        sleep 50
    done
) &
KEEPALIVE=$!

sudo install -d -o root -g root -m 0700 "$BACKUP_DIR"

printf '\n1. PRÉ-CONDIÇÕES DO SISTEMA\n'

GM_BEFORE="$(timeout 10 gamemoded -s 2>&1 || true)"
printf 'GameMode antes: %s\n' "$GM_BEFORE"

grep -Fq 'gamemode is inactive' <<<"$GM_BEFORE" ||
    fail 'GameMode está ativo; feche o jogo antes desta etapa.'

[[ ! -e "$USER_GAMEMODE_CONF" ]] ||
    fail "existe override de usuário não auditado: $USER_GAMEMODE_CONF"

for bridge in "$LEGACY_START_CMD" "$LEGACY_END_CMD"; do
    if sudo test -s "$bridge"; then
        printf 'Conteúdo bloqueante de %s:\n' "$bridge"
        sudo sed -n '1,20p' "$bridge"
        fail 'ponte legacy ativa encontrada; o teste sem OC foi bloqueado.'
    fi
done

pacman -Q gamemode system76-scheduler tuned

[[ "$(systemctl show "$UNIT" -p FragmentPath --value 2>/dev/null || true)" == \
    '/usr/lib/systemd/system/com.system76.Scheduler.service' ]] ||
    fail 'a unit efetiva do scheduler não é a unit auditada do pacote.'

systemctl is-enabled --quiet "$UNIT" ||
    fail 'system76-scheduler não está habilitado.'

systemctl is-active --quiet "$UNIT" ||
    fail 'system76-scheduler não está ativo fora do GameMode.'

ACTIVE_PROFILE="$(
    sudo tuned-adm active 2>/dev/null |
        sed -n 's/^Current active profile: //p' |
        head -n1
)"

printf 'Perfil TuneD ativo: %s\n' "${ACTIVE_PROFILE:-NENHUM}"

[[ "$ACTIVE_PROFILE" == "$PROFILE" ]] ||
    fail "perfil TuneD ativo inesperado: ${ACTIVE_PROFILE:-NENHUM}"

sudo tuned-adm verify

printf '\n2. VALIDAÇÃO DOS PAYLOADS CANÔNICOS\n'

for pkg in "$PUBLIC_PKG" "$INTERNAL_PKG"; do
    [[ -d "$pkg/files" ]] ||
        fail "árvore files ausente: $pkg"

    [[ -f "$pkg/manifest-files.txt" ]] ||
        fail "manifesto ausente: $pkg/manifest-files.txt"

    [[ -f "$pkg/sha256-files.txt" ]] ||
        fail "lista SHA256 ausente: $pkg/sha256-files.txt"
done

if ! cmp -s \
    "$PUBLIC_PKG/manifest-files.txt" \
    "$INTERNAL_PKG/manifest-files.txt"
then
    fail 'manifest-files público e interno divergem.'
fi

AUTH_RUNTIME_FILES=(
    '/usr/local/sbin/mocha-system76-authority-helper'
    '/etc/sudoers.d/mocha-gamemode-system76-authority'
    '/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system'
    '/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system'
    '/etc/gamemode.ini'
)

for runtime in "${AUTH_RUNTIME_FILES[@]}"; do
    pub="$PUBLIC_PKG/files$runtime"
    int="$INTERNAL_PKG/files$runtime"

    [[ -f "$pub" ]] ||
        fail "arquivo público ausente: $pub"

    [[ -f "$int" ]] ||
        fail "arquivo interno ausente: $int"

    cmp -s "$pub" "$int" ||
        fail "payload público/interno diverge em: $runtime"

    for pkg in "$PUBLIC_PKG" "$INTERNAL_PKG"; do
        src="$pkg/files$runtime"

        expected="$(
            {
                awk -v p="$runtime" \
                    '$2 == p {print $1; exit}' \
                    "$pkg/sha256-files.txt"
            } || true
        )"

        actual="$(sha256sum "$src" | awk '{print $1}')"

        [[ -n "$expected" ]] ||
            fail "hash não declarado em $pkg/sha256-files.txt para $runtime"

        printf '%s | esperado=%s atual=%s\n' \
            "$src" \
            "$expected" \
            "$actual"

        [[ "$actual" == "$expected" ]] ||
            fail "hash do payload diverge para $runtime em $pkg"
    done
done

[[ "$(sha256sum "$PUBLIC_PKG/files$HELPER" | awk '{print $1}')" == \
    "$SHA_HELPER" ]] ||
    fail 'helper do payload não corresponde ao hash aprovado.'

[[ "$(sha256sum "$PUBLIC_PKG/files$START_HOOK" | awk '{print $1}')" == \
    "$SHA_START" ]] ||
    fail 'wrapper start do payload não corresponde ao hash aprovado.'

[[ "$(sha256sum "$PUBLIC_PKG/files$END_HOOK" | awk '{print $1}')" == \
    "$SHA_END" ]] ||
    fail 'wrapper end do payload não corresponde ao hash aprovado.'

[[ "$(sha256sum "$PUBLIC_PKG/files$GAMEMODE_CONF" | awk '{print $1}')" == \
    "$SHA_GAMEMODE_CONF" ]] ||
    fail 'gamemode.ini do payload não corresponde ao hash aprovado.'

bash -n "$PUBLIC_PKG/files$HELPER"
bash -n "$PUBLIC_PKG/files$START_HOOK"
bash -n "$PUBLIC_PKG/files$END_HOOK"
sudo visudo -cf "$PUBLIC_PKG/files$SUDOERS"

grep -Fq \
    '/etc/mocha/gamemode/legacy-start-system.cmd' \
    "$PUBLIC_PKG/files$START_HOOK" ||
    fail 'wrapper start não contém a ponte legacy esperada.'

grep -Fq \
    '/etc/mocha/gamemode/legacy-end-system.cmd' \
    "$PUBLIC_PKG/files$END_HOOK" ||
    fail 'wrapper end não contém a ponte legacy esperada.'

grep -Fq \
    'mocha-latency-performance' \
    "$PUBLIC_PKG/files$END_HOOK" ||
    fail 'wrapper end não reasserta o perfil TuneD esperado.'

printf '\n3. BACKUP DOS ALVOS ATUAIS\n'

for target in "${TARGETS[@]}"; do
    backup_target "$target"
done

printf '\n4. INSTALAÇÃO EXATA DA AUTORIDADE — SEM ARTEFATOS DE OC\n'

[[ -d /usr/local/sbin ]] ||
    fail 'diretório obrigatório ausente: /usr/local/sbin'

[[ -d /etc/sudoers.d ]] ||
    fail 'diretório obrigatório ausente: /etc/sudoers.d'

sudo install -d \
    -o root \
    -g root \
    -m 0755 \
    /usr/local/lib/mocha/performance

sudo install \
    -o root \
    -g root \
    -m 0755 \
    "$PUBLIC_PKG/files$HELPER" \
    "$HELPER"

sudo install \
    -o root \
    -g root \
    -m 0440 \
    "$PUBLIC_PKG/files$SUDOERS" \
    "$SUDOERS"

sudo install \
    -o root \
    -g root \
    -m 0755 \
    "$PUBLIC_PKG/files$START_HOOK" \
    "$START_HOOK"

sudo install \
    -o root \
    -g root \
    -m 0755 \
    "$PUBLIC_PKG/files$END_HOOK" \
    "$END_HOOK"

sudo install \
    -o root \
    -g root \
    -m 0644 \
    "$PUBLIC_PKG/files$GAMEMODE_CONF" \
    "$GAMEMODE_CONF"

CHANGED=1

sudo visudo -cf "$SUDOERS"
sudo bash -n "$HELPER"
sudo bash -n "$START_HOOK"
sudo bash -n "$END_HOOK"

[[ "$(sudo sha256sum "$HELPER" | awk '{print $1}')" == \
    "$SHA_HELPER" ]] ||
    fail 'hash final do helper divergiu.'

[[ "$(sudo sha256sum "$START_HOOK" | awk '{print $1}')" == \
    "$SHA_START" ]] ||
    fail 'hash final do wrapper start divergiu.'

[[ "$(sudo sha256sum "$END_HOOK" | awk '{print $1}')" == \
    "$SHA_END" ]] ||
    fail 'hash final do wrapper end divergiu.'

[[ "$(sudo sha256sum "$GAMEMODE_CONF" | awk '{print $1}')" == \
    "$SHA_GAMEMODE_CONF" ]] ||
    fail 'hash final do gamemode.ini divergiu.'

for bridge in "$LEGACY_START_CMD" "$LEGACY_END_CMD"; do
    sudo test ! -s "$bridge" ||
        fail "ponte legacy ficou ativa inesperadamente: $bridge"
done

printf '\nArquivos instalados:\n'

sudo stat \
    --printf='%n | %A (%a) | %U:%G | %s bytes\n' \
    "$HELPER" \
    "$SUDOERS" \
    "$START_HOOK" \
    "$END_HOOK" \
    "$GAMEMODE_CONF"

printf '\nSeção custom efetiva:\n'

sudo awk '
    /^[[:space:]]*\[custom\][[:space:]]*$/ {
        show=1
    }

    show &&
    /^[[:space:]]*\[/ &&
    $0 !~ /^[[:space:]]*\[custom\][[:space:]]*$/ {
        exit
    }

    show {
        print
    }
' "$GAMEMODE_CONF"

printf '\n5. RECARGA CONTROLADA DO GAMEMODE\n'

systemctl --user stop gamemoded.service 2>/dev/null || true
sudo systemctl start "$UNIT"

systemctl is-active --quiet "$UNIT" ||
    fail 'scheduler não ficou ativo antes do teste.'

STATUS_BEFORE="$(sudo "$HELPER" status 2>&1 || true)"
printf '%s\n' "$STATUS_BEFORE"

COUNT_BEFORE="$(
    printf '%s\n' "$STATUS_BEFORE" |
        awk -F= '$1 == "count" {print $2; exit}'
)"

[[ "$COUNT_BEFORE" == '0' ]] ||
    fail "contador transitório não está zerado: ${COUNT_BEFORE:-INDETERMINADO}"

printf '\n6. TESTE REAL DA EXCLUSÃO MÚTUA — SEM OC\n'

printf '\n%s\n' "$MARKER" >> "$WRAPPER_LOG"

JOURNAL_SINCE="$(date --iso-8601=seconds)"
TEST_STARTED=1

gamemoderun /usr/bin/sleep 12 &
CLIENT_PID=$!

printf 'Cliente de teste PID=%s\n' "$CLIENT_PID"

OBS_GM_ACTIVE=0
OBS_SCHED_INACTIVE=0
OBS_COUNT_POSITIVE=0

for _ in $(seq 1 80); do
    GM_NOW="$(timeout 3 gamemoded -s 2>&1 || true)"
    SCHED_NOW="$(systemctl is-active "$UNIT" 2>/dev/null || true)"
    COUNT_NOW="$(helper_count || true)"

    grep -Fq 'gamemode is active' <<<"$GM_NOW" &&
        OBS_GM_ACTIVE=1

    [[ "$SCHED_NOW" == 'inactive' ]] &&
        OBS_SCHED_INACTIVE=1

    [[ "$COUNT_NOW" =~ ^[0-9]+$ ]] &&
        (( COUNT_NOW > 0 )) &&
        OBS_COUNT_POSITIVE=1

    if (( OBS_GM_ACTIVE == 1 &&
          OBS_SCHED_INACTIVE == 1 &&
          OBS_COUNT_POSITIVE == 1 )); then
        break
    fi

    sleep 0.25
done

printf \
    'durante: gamemode_ativo=%d scheduler_inativo=%d contador_positivo=%d\n' \
    "$OBS_GM_ACTIVE" \
    "$OBS_SCHED_INACTIVE" \
    "$OBS_COUNT_POSITIVE"

sudo "$HELPER" status 2>&1 || true

(( OBS_GM_ACTIVE == 1 )) ||
    mark_fail 'GameMode não foi observado ativo.'

(( OBS_SCHED_INACTIVE == 1 )) ||
    mark_fail 'scheduler não foi observado inativo durante o GameMode.'

(( OBS_COUNT_POSITIVE == 1 )) ||
    mark_fail 'contador da autoridade não foi observado positivo.'

wait "$CLIENT_PID" || true
CLIENT_PID=''

OBS_GM_INACTIVE=0
OBS_SCHED_ACTIVE=0
OBS_COUNT_ZERO=0

for _ in $(seq 1 80); do
    GM_NOW="$(timeout 3 gamemoded -s 2>&1 || true)"
    SCHED_NOW="$(systemctl is-active "$UNIT" 2>/dev/null || true)"
    COUNT_NOW="$(helper_count || true)"

    grep -Fq 'gamemode is inactive' <<<"$GM_NOW" &&
        OBS_GM_INACTIVE=1

    [[ "$SCHED_NOW" == 'active' ]] &&
        OBS_SCHED_ACTIVE=1

    [[ "$COUNT_NOW" == '0' ]] &&
        OBS_COUNT_ZERO=1

    if (( OBS_GM_INACTIVE == 1 &&
          OBS_SCHED_ACTIVE == 1 &&
          OBS_COUNT_ZERO == 1 )); then
        break
    fi

    sleep 0.25
done

printf \
    'depois: gamemode_inativo=%d scheduler_ativo=%d contador_zero=%d\n' \
    "$OBS_GM_INACTIVE" \
    "$OBS_SCHED_ACTIVE" \
    "$OBS_COUNT_ZERO"

sudo "$HELPER" status 2>&1 || true

(( OBS_GM_INACTIVE == 1 )) ||
    mark_fail 'GameMode não ficou inativo ao final.'

(( OBS_SCHED_ACTIVE == 1 )) ||
    mark_fail 'scheduler não foi restaurado ao final.'

(( OBS_COUNT_ZERO == 1 )) ||
    mark_fail 'contador da autoridade não voltou a zero.'

printf '\nTrecho do log do wrapper deste teste:\n'

TEST_LOG="$(
    {
        awk \
            -v marker="$MARKER" '
                $0 == marker {
                    show=1
                    next
                }

                show {
                    print
                }
            ' "$WRAPPER_LOG"
    } || true
)"

printf '%s\n' "$TEST_LOG"

if grep -Eiq \
    'executando legacy|NVC_(START|END)|nvidia-oc|GraphicsClockOffset|MemoryTransferRateOffset|PowerMizer' \
    <<<"$TEST_LOG"
then
    mark_fail 'foi detectada tentativa de OC no teste sem OC.'
else
    printf '[OK] nenhuma chamada de OC foi detectada no log do teste.\n'
fi

printf '\n7. VALIDAÇÕES FINAIS\n'

FINAL_PROFILE="$(
    sudo tuned-adm active 2>/dev/null |
        sed -n 's/^Current active profile: //p' |
        head -n1
)"

printf 'Perfil TuneD final: %s\n' "${FINAL_PROFILE:-NENHUM}"

[[ "$FINAL_PROFILE" == "$PROFILE" ]] ||
    mark_fail 'perfil TuneD final divergiu.'

sudo tuned-adm verify ||
    mark_fail 'tuned-adm verify falhou após o teste.'

systemctl is-enabled --quiet "$UNIT" ||
    mark_fail 'scheduler não está habilitado ao final.'

systemctl is-active --quiet "$UNIT" ||
    mark_fail 'scheduler não está ativo ao final.'

NEW_COREDUMPS="$(
    {
        journalctl \
            -b \
            --since "$JOURNAL_SINCE" \
            --no-pager \
            2>/dev/null |
            grep -Ei \
                'systemd-coredump.*system76|Process .*system76-schedu.*dumped core' ||
            true
    }
)"

if [[ -n "$NEW_COREDUMPS" ]]; then
    printf '%s\n' "$NEW_COREDUMPS"
    mark_fail 'houve novo coredump do system76-scheduler durante o teste.'
else
    printf '[OK] nenhum novo coredump do system76-scheduler durante o teste.\n'
fi

printf '\nHashes finais:\n'

sudo sha256sum \
    "$HELPER" \
    "$SUDOERS" \
    "$START_HOOK" \
    "$END_HOOK" \
    "$GAMEMODE_CONF"

if (( FAIL != 0 )); then
    fail "validação final reprovada; total de falhas=$FAIL"
fi

COMPLETED=1

printf '\n%s\n' '============================================================'
printf '%s\n' 'RESULTADO=AUTORIDADE_GAMEMODE_SYSTEM76_SEM_OC_APROVADA'
printf 'OC_STATUS=NAO_HABILITADO_NAO_CHAMADO\n'
printf 'Perfil_TuneD=%s\n' "$PROFILE"
printf 'Relatório=%s\n' "$REPORT"
printf 'Backup=%s\n' "$BACKUP_DIR"
printf '%s\n' \
    'Manuais e repositórios canônicos não foram alterados nesta etapa.'
printf '%s\n' '============================================================'
