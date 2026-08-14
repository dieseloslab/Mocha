#!/usr/bin/env bash
set -Eeuo pipefail
LANG=C
LC_ALL=C

usuario="$(id -un)"
[[ "$usuario" != root ]] || {
    printf '%s\n' 'ERRO: execute como usuário normal, não como root.' >&2
    exit 1
}

casa="$(getent passwd "$usuario" | awk -F: 'NR == 1 { print $6 }')"
[[ -n "$casa" && -d "$casa" ]] || {
    printf '%s\n' 'ERRO: não foi possível determinar a pasta pessoal.' >&2
    exit 1
}

for comando in awk bash curl date flock getent grep id install kill mkdir mktemp rm sha256sum sleep sudo tee; do
    command -v "$comando" >/dev/null 2>&1 || {
        printf 'ERRO: comando obrigatório ausente: %s\n' "$comando" >&2
        exit 1
    }
done

documentos="$casa/Documentos"
mkdir -p -- "$documentos"
data="$(date +%Y%m%d-%H%M%S)"
relatorio="$documentos/mocha-instala-wrapper-steam-perfis-v1-$data.txt"
exec > >(tee -a "$relatorio") 2>&1

printf '%s\n' '============================================================'
printf '%s\n' 'MOCHA — INSTALA WRAPPER STEAM COM PERFIS POR APPID — V1'
printf '%s\n' '============================================================'
printf 'Início: %s\n' "$(date --iso-8601=seconds)"

printf '%s\n' '[1/8] Validação inicial e credencial administrativa'
sudo -v
(
    while :; do
        sudo -n true >/dev/null 2>&1 || exit 0
        sleep 45
    done
) &
sudo_keepalive_pid=$!

temporario="$(mktemp -d)"
lockfile="${XDG_RUNTIME_DIR:-/tmp}/mocha-wrapper-steam-perfis-v1.lock"
backup=''
wrapper_alterado=0

finalizar() {
    codigo=$?
    kill "$sudo_keepalive_pid" >/dev/null 2>&1 || :
    if [[ -d "$temporario" && "$temporario" == /tmp/tmp.* ]]; then
        rm -rf -- "$temporario"
    fi
    if ((codigo != 0 && wrapper_alterado == 1)) && [[ -n "$backup" && -f "$backup/mocha-steam-game-run" ]]; then
        printf '%s\n' 'FALHA: restaurando automaticamente o wrapper anterior.' >&2
        sudo install -o root -g root -m 0755 -- \
            "$backup/mocha-steam-game-run" /usr/local/bin/mocha-steam-game-run || :
    fi
    printf 'Relatório: %s\n' "$relatorio"
    exit "$codigo"
}
trap finalizar EXIT

exec 9>"$lockfile"
flock -n 9 || {
    printf '%s\n' 'ERRO: outra instalação do wrapper Mocha já está em execução.' >&2
    exit 1
}

wrapper_atual='/usr/local/bin/mocha-steam-game-run'
core='/usr/local/lib/mocha/mocha-steam-game-run-alt-tab-core'
hash_wrapper_antigo='375f8c07b082d3f6eec2c57127350b4779b83e3c80b203d79c8874510cb6499e'
hash_wrapper_novo='fd32df1451019182384964aad556bd70d19373e6fe54b2dc3a889e7a2044a29a'
hash_core='3d58607f9f7c3bd1aaa8e3924a9f4eb7e1f13531bf64c10fd5587aec271b0235'

[[ -f "$wrapper_atual" && ! -L "$wrapper_atual" && -x "$wrapper_atual" ]] || {
    printf 'ERRO: wrapper ausente, não executável ou link simbólico: %s\n' "$wrapper_atual" >&2
    exit 1
}
[[ -f "$core" && ! -L "$core" && -x "$core" ]] || {
    printf 'ERRO: core ausente, não executável ou link simbólico: %s\n' "$core" >&2
    exit 1
}

hash_wrapper_obtido="$(sha256sum -- "$wrapper_atual" | awk '{print $1}')"
hash_core_obtido="$(sha256sum -- "$core" | awk '{print $1}')"
[[ "$hash_wrapper_obtido" == "$hash_wrapper_antigo" || "$hash_wrapper_obtido" == "$hash_wrapper_novo" ]] || {
    printf 'ERRO: wrapper local desconhecido; nenhuma alteração foi feita. SHA-256=%s\n' "$hash_wrapper_obtido" >&2
    exit 1
}
[[ "$hash_core_obtido" == "$hash_core" ]] || {
    printf 'ERRO: core Alt+Tab/input divergente; nenhuma alteração foi feita. SHA-256=%s\n' "$hash_core_obtido" >&2
    exit 1
}

printf '%s\n' '[2/8] Obtenção dos arquivos versionados'
base='https://raw.githubusercontent.com/dieseloslab/Mocha/codex/wrapper-steam-perfis-v1/ativo/steam-wrapper-perfis-v1'

baixar() {
    local nome="$1"
    local destino="$2"
    curl --fail --location --silent --show-error \
        --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 120 \
        "$base/$nome" --output "$destino"
}

baixar 'usr/local/bin/mocha-steam-game-run' "$temporario/mocha-steam-game-run"
baixar 'usr/local/lib/mocha/mocha-steam-profile-loader' "$temporario/mocha-steam-profile-loader"
baixar 'usr/local/share/mocha/steam-profiles/690790.conf' "$temporario/690790.conf"
baixar 'usr/local/share/mocha/steam-profiles/1029690.conf' "$temporario/1029690.conf"
baixar 'usr/local/share/mocha/steam-profiles/2169200.conf' "$temporario/2169200.conf"
baixar 'README.md' "$temporario/README.md"

printf '%s\n' '[3/8] Verificação criptográfica e sintática'
verificar_hash() {
    local arquivo="$1"
    local esperado="$2"
    local obtido
    obtido="$(sha256sum -- "$arquivo" | awk '{print $1}')"
    [[ "$obtido" == "$esperado" ]] || {
        printf 'ERRO: SHA-256 divergente em %s. ESPERADO=%s OBTIDO=%s\n' \
            "$arquivo" "$esperado" "$obtido" >&2
        exit 1
    }
}

verificar_hash "$temporario/mocha-steam-game-run" "$hash_wrapper_novo"
verificar_hash "$temporario/mocha-steam-profile-loader" 'a96d1f2601e75802e76c538496786ea674277af92bc06dcb8294527c9ff27209'
verificar_hash "$temporario/690790.conf" 'b84ea47864e82dcebfea0656c81cf2db82486b5eadfaffc3b8a0b2e7fd4f3fd0'
verificar_hash "$temporario/1029690.conf" '83f591e76408e2a61b131eeb334ea64d876515841797360e2e1d35f2326d8f8a'
verificar_hash "$temporario/2169200.conf" '44146f7a5711bd2c9f9d7da878796bc8e70590cd4dd1da0b4026912882e94eb8'
verificar_hash "$temporario/README.md" '7cbc07a3bd24fbc5f717ea739e77b7bf544148b3cbd668babd41c1634878b321'
bash -n "$temporario/mocha-steam-game-run"
bash -n "$temporario/mocha-steam-profile-loader"

printf '%s\n' '[4/8] Backup persistente do estado anterior'
backup="/var/lib/mocha/backups/steam-wrapper-perfis-v1-$data"
sudo install -d -o root -g root -m 0755 -- "$backup"
sudo install -o root -g root -m 0755 -- "$wrapper_atual" "$backup/mocha-steam-game-run"
sudo install -o root -g root -m 0755 -- "$core" "$backup/mocha-steam-game-run-alt-tab-core"

printf '%s\n' '[5/8] Instalação atômica da camada de perfis'
sudo install -d -o root -g root -m 0755 -- \
    /usr/local/lib/mocha \
    /usr/local/share/mocha/steam-profiles \
    /usr/local/share/doc/mocha
sudo install -o root -g root -m 0755 -- \
    "$temporario/mocha-steam-profile-loader" \
    /usr/local/lib/mocha/mocha-steam-profile-loader
sudo install -o root -g root -m 0644 -- \
    "$temporario/690790.conf" \
    /usr/local/share/mocha/steam-profiles/690790.conf
sudo install -o root -g root -m 0644 -- \
    "$temporario/1029690.conf" \
    /usr/local/share/mocha/steam-profiles/1029690.conf
sudo install -o root -g root -m 0644 -- \
    "$temporario/2169200.conf" \
    /usr/local/share/mocha/steam-profiles/2169200.conf
sudo install -o root -g root -m 0644 -- \
    "$temporario/README.md" \
    /usr/local/share/doc/mocha/WRAPPER-STEAM-PERFIS.md
sudo install -o root -g root -m 0755 -- \
    "$temporario/mocha-steam-game-run" \
    "$wrapper_atual"
wrapper_alterado=1

printf '%s\n' '[6/8] Testes funcionais sem iniciar jogos'
MOCHA_MANGOHUD_DEBUG=1 "$wrapper_atual" >"$temporario/wrapper-debug.txt"
grep -Fx 'MANGOHUD=1' "$temporario/wrapper-debug.txt" >/dev/null
grep -Fx "MANGOHUD_CONFIGFILE=$casa/.config/MangoHud/mocha-active.conf" \
    "$temporario/wrapper-debug.txt" >/dev/null

HOME="$casa" SteamAppId=690790 STEAM_COMPAT_TOOL_PATHS='/teste/DW-Proton' \
    bash -c 'set -Eeuo pipefail; source /usr/local/lib/mocha/mocha-steam-profile-loader; [[ ${PROTON_DXVK_LOWLATENCY:-} == 1 ]]; [[ -z ${PROTON_VKD3D_LOWLATENCY:-} ]]'
HOME="$casa" SteamAppId=690790 STEAM_COMPAT_TOOL_PATHS='/teste/GE-Proton11-5' \
    bash -c 'set -Eeuo pipefail; source /usr/local/lib/mocha/mocha-steam-profile-loader; [[ -z ${PROTON_DXVK_LOWLATENCY:-} ]]'
HOME="$casa" SteamAppId=1029690 STEAM_COMPAT_TOOL_PATHS='/teste/EM-10.0-37-HDR+' \
    bash -c 'set -Eeuo pipefail; source /usr/local/lib/mocha/mocha-steam-profile-loader; [[ -z ${PROTON_VKD3D_LOWLATENCY:-} ]]'
HOME="$casa" SteamAppId=2169200 STEAM_COMPAT_TOOL_PATHS='/teste/DW-Proton' \
    bash -c 'set -Eeuo pipefail; source /usr/local/lib/mocha/mocha-steam-profile-loader; [[ ${PROTON_VKD3D_LOWLATENCY:-} == 1 ]]; [[ -z ${PROTON_DXVK_LOWLATENCY:-} ]]'

printf '%s\n' '[7/8] Verificação final de integridade'
[[ "$(sha256sum -- "$wrapper_atual" | awk '{print $1}')" == "$hash_wrapper_novo" ]]
[[ "$(sha256sum -- "$core" | awk '{print $1}')" == "$hash_core" ]]
[[ "$(sha256sum -- /usr/local/lib/mocha/mocha-steam-profile-loader | awk '{print $1}')" == \
    'a96d1f2601e75802e76c538496786ea674277af92bc06dcb8294527c9ff27209' ]]

printf '%s\n' '[8/8] Resultado'
printf '%s\n' 'OK: wrapper frontal atualizado com perfis por AppID.'
printf '%s\n' 'OK: core Alt+Tab/input permaneceu byte a byte intacto.'
printf '%s\n' 'OK: MangoHud continua usando mocha-active.conf, sem configuração inline.'
printf '%s\n' 'OK: nenhum limite de FPS, Wayland, HDR, Reflex ou WoW64 foi ativado globalmente.'
printf 'Backup: %s\n' "$backup"
printf 'Fim: %s\n' "$(date --iso-8601=seconds)"

wrapper_alterado=0
