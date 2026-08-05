#!/usr/bin/env bash
set -Eeuo pipefail

export LC_ALL=C
export PAGER=cat
export SYSTEMD_PAGER=cat
export LESS=FRX
umask 077

MAX_CATALOG_BYTES=2097152
MAX_SIGNATURE_BYTES=262144
USER_AGENT='Mocha-Update-R2-Client/1'
TMP_WORK=''

cleanup() {
    local codigo=$?
    trap - EXIT INT TERM HUP
    if [[ -n "$TMP_WORK" && -d "$TMP_WORK" ]]; then
        rm -rf -- "$TMP_WORK"
    fi
    exit "$codigo"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

erro() {
    printf 'RESULTADO=FALHA\n' >&2
    printf 'ERRO=%s\n' "$*" >&2
    exit 1
}

uso() {
    cat >&2 <<'USAGE'
Uso:
  mocha-update-r2-check.sh --validate-config CONFIG
  mocha-update-r2-check.sh --local CATALOGO ASSINATURA KEYRING ALLOWLIST ESTADO [ARQUITETURA]
  mocha-update-r2-check.sh --remote CONFIG ALLOWLIST ESTADO CACHE [ARQUITETURA]
USAGE
    exit 2
}

arquivo_regular_confiavel() {
    local caminho="$1"
    local rotulo="$2"
    [[ -f "$caminho" ]] || erro "$rotulo ausente: $caminho"
    [[ ! -L "$caminho" ]] || erro "$rotulo não pode ser link simbólico: $caminho"
    [[ -r "$caminho" ]] || erro "$rotulo sem permissão de leitura: $caminho"
}

validador_catalogo() {
    local projeto candidato
    projeto="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
    for candidato in \
        "$projeto/target/release/mocha-update-catalog-check" \
        /usr/lib/mocha-update/mocha-update-catalog-check
    do
        if [[ -x "$candidato" && ! -L "$candidato" ]]; then
            printf '%s\n' "$candidato"
            return 0
        fi
    done
    erro 'validador mocha-update-catalog-check não foi encontrado'
}

parse_config() {
    local config="$1"
    arquivo_regular_confiavel "$config" 'configuração do endpoint'

    mapfile -t CONFIG_VALUES < <(
        python3 - "$config" <<'PY_CONFIG'
from pathlib import Path, PurePosixPath
from urllib.parse import urlsplit, urlunsplit
import re
import sys

path = Path(sys.argv[1])
allowed = {
    "BASE_URL",
    "CHANNEL",
    "CATALOG_OBJECT",
    "CATALOG_SIGNATURE_OBJECT",
    "RELEASE_KEYRING",
}
values: dict[str, str] = {}

for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
    line = raw.strip()
    if not line or line.startswith("#"):
        continue
    if "=" not in line:
        raise SystemExit(f"linha {number} sem '='")
    key, value = line.split("=", 1)
    key = key.strip()
    value = value.strip()
    if key not in allowed:
        raise SystemExit(f"chave desconhecida na linha {number}: {key}")
    if key in values:
        raise SystemExit(f"chave duplicada: {key}")
    if not value or any(ord(char) < 32 or ord(char) == 127 for char in value):
        raise SystemExit(f"valor inválido para {key}")
    values[key] = value

missing = sorted(allowed.difference(values))
if missing:
    raise SystemExit("chaves ausentes: " + ", ".join(missing))

parts = urlsplit(values["BASE_URL"])
if parts.scheme != "https":
    raise SystemExit("BASE_URL precisa usar https")
if not parts.hostname or parts.username or parts.password:
    raise SystemExit("BASE_URL contém autoridade inválida")
if parts.query or parts.fragment:
    raise SystemExit("BASE_URL não pode conter consulta ou fragmento")
try:
    port = parts.port
except ValueError as error:
    raise SystemExit(f"porta inválida em BASE_URL: {error}")
if port is not None and not (1 <= port <= 65535):
    raise SystemExit("porta fora do intervalo")
if any(char.isspace() for char in values["BASE_URL"]):
    raise SystemExit("BASE_URL contém espaço")
base_path = parts.path.rstrip("/")
base_parts = PurePosixPath(base_path).parts
if "//" in parts.path or any(part in {".", ".."} for part in base_parts):
    raise SystemExit("BASE_URL contém caminho inseguro")
base_url = urlunsplit((parts.scheme, parts.netloc, base_path, "", ""))

if values["CHANNEL"] not in {"stable", "testing"}:
    raise SystemExit("CHANNEL inválido")

def validate_object(name: str, value: str) -> str:
    if (
        value.startswith("/")
        or "\\" in value
        or "?" in value
        or "#" in value
        or "//" in value
    ):
        raise SystemExit(f"{name} possui caminho inválido")
    pure = PurePosixPath(value)
    if not value or any(part in {"", ".", ".."} for part in pure.parts):
        raise SystemExit(f"{name} possui componente inseguro")
    if not re.fullmatch(r"[A-Za-z0-9._~!$&'()+,;=:@%/-]+", value):
        raise SystemExit(f"{name} contém caractere não permitido")
    return value

catalog = validate_object("CATALOG_OBJECT", values["CATALOG_OBJECT"])
signature = validate_object(
    "CATALOG_SIGNATURE_OBJECT", values["CATALOG_SIGNATURE_OBJECT"]
)
channel = values["CHANNEL"]
if not catalog.startswith(channel + "/"):
    raise SystemExit("CATALOG_OBJECT não pertence ao CHANNEL")
if not signature.startswith(channel + "/"):
    raise SystemExit("CATALOG_SIGNATURE_OBJECT não pertence ao CHANNEL")

keyring = Path(values["RELEASE_KEYRING"])
if not keyring.is_absolute():
    raise SystemExit("RELEASE_KEYRING precisa ser absoluto")

for value in (base_url, channel, catalog, signature, str(keyring)):
    print(value)
PY_CONFIG
    ) || erro 'configuração do endpoint inválida'

    [[ "${#CONFIG_VALUES[@]}" -eq 5 ]] ||
        erro 'parser da configuração não retornou os cinco valores esperados'

    BASE_URL="${CONFIG_VALUES[0]}"
    CHANNEL="${CONFIG_VALUES[1]}"
    CATALOG_OBJECT="${CONFIG_VALUES[2]}"
    CATALOG_SIGNATURE_OBJECT="${CONFIG_VALUES[3]}"
    RELEASE_KEYRING="${CONFIG_VALUES[4]}"
}

verifica_assinatura_e_classifica() {
    local catalogo="$1"
    local assinatura="$2"
    local keyring="$3"
    local allowlist="$4"
    local estado="$5"
    local arquitetura="$6"
    local validador

    arquivo_regular_confiavel "$catalogo" 'catálogo'
    arquivo_regular_confiavel "$assinatura" 'assinatura do catálogo'
    arquivo_regular_confiavel "$keyring" 'keyring de releases'
    arquivo_regular_confiavel "$allowlist" 'allowlist local'
    arquivo_regular_confiavel "$estado" 'estado instalado'

    [[ "$(stat -c '%s' "$catalogo")" -le "$MAX_CATALOG_BYTES" ]] ||
        erro 'catálogo excede o limite local'
    [[ "$(stat -c '%s' "$assinatura")" -le "$MAX_SIGNATURE_BYTES" ]] ||
        erro 'assinatura excede o limite local'

    command -v gpgv >/dev/null 2>&1 || erro 'gpgv ausente'
    gpgv --keyring "$keyring" "$assinatura" "$catalogo" >/dev/null 2>&1 ||
        erro 'assinatura do catálogo inválida'

    validador="$(validador_catalogo)"
    "$validador" "$catalogo" "$allowlist" "$estado" "$arquitetura"
}

baixa_https() {
    local url="$1"
    local destino="$2"
    local limite="$3"

    command -v curl >/dev/null 2>&1 || erro 'curl ausente'
    curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --max-redirs 3 \
        --proto '=https' \
        --proto-redir '=https' \
        --tlsv1.2 \
        --connect-timeout 15 \
        --max-time 120 \
        --retry 2 \
        --retry-delay 1 \
        --retry-connrefused \
        --max-filesize "$limite" \
        --user-agent "$USER_AGENT" \
        --output "$destino" \
        -- "$url" || erro "falha ao baixar: $url"

    [[ -s "$destino" ]] || erro "download vazio: $url"
    [[ "$(stat -c '%s' "$destino")" -le "$limite" ]] ||
        erro "download excedeu o limite: $url"
}

modo="${1:-}"
case "$modo" in
    --validate-config)
        [[ "$#" -eq 2 ]] || uso
        parse_config "$2"
        printf 'RESULTADO=SUCESSO\n'
        printf 'BASE_URL=%s\n' "$BASE_URL"
        printf 'CHANNEL=%s\n' "$CHANNEL"
        printf 'CATALOG_OBJECT=%s\n' "$CATALOG_OBJECT"
        printf 'CATALOG_SIGNATURE_OBJECT=%s\n' "$CATALOG_SIGNATURE_OBJECT"
        printf 'RELEASE_KEYRING=%s\n' "$RELEASE_KEYRING"
        ;;

    --local)
        [[ "$#" -eq 6 || "$#" -eq 7 ]] || uso
        arquitetura="${7:-$(uname -m)}"
        verifica_assinatura_e_classifica "$2" "$3" "$4" "$5" "$6" "$arquitetura"
        ;;

    --remote)
        [[ "$#" -eq 5 || "$#" -eq 6 ]] || uso
        config="$2"
        allowlist="$3"
        estado="$4"
        cache="$5"
        arquitetura="${6:-$(uname -m)}"

        parse_config "$config"
        arquivo_regular_confiavel "$RELEASE_KEYRING" 'keyring de releases'
        arquivo_regular_confiavel "$allowlist" 'allowlist local'
        arquivo_regular_confiavel "$estado" 'estado instalado'

        [[ ! -L "$cache" ]] || erro "cache não pode ser link simbólico: $cache"
        mkdir -p -m 0700 -- "$cache"
        chmod 0700 -- "$cache"
        TMP_WORK="$(mktemp -d -- "$cache/.consulta-r2.XXXXXX")"
        catalogo="$TMP_WORK/catalog-v1.json"
        assinatura="$TMP_WORK/catalog-v1.json.asc"
        catalog_url="${BASE_URL%/}/${CATALOG_OBJECT}"
        signature_url="${BASE_URL%/}/${CATALOG_SIGNATURE_OBJECT}"

        baixa_https "$catalog_url" "$catalogo" "$MAX_CATALOG_BYTES"
        baixa_https "$signature_url" "$assinatura" "$MAX_SIGNATURE_BYTES"

        resultado="$TMP_WORK/resultado.txt"
        verifica_assinatura_e_classifica \
            "$catalogo" "$assinatura" "$RELEASE_KEYRING" \
            "$allowlist" "$estado" "$arquitetura" > "$resultado"

        install -m 0600 -- "$catalogo" "$cache/.catalog-v1.json.new.$$"
        install -m 0600 -- "$assinatura" "$cache/.catalog-v1.json.asc.new.$$"
        mv -f -- "$cache/.catalog-v1.json.new.$$" "$cache/catalog-v1.json"
        mv -f -- "$cache/.catalog-v1.json.asc.new.$$" "$cache/catalog-v1.json.asc"

        printf 'ORIGEM=R2_HTTPS_ASSINADO\n'
        printf 'BASE_URL=%s\n' "$BASE_URL"
        printf 'CACHE_CATALOGO=%s\n' "$cache/catalog-v1.json"
        printf 'CACHE_ASSINATURA=%s\n' "$cache/catalog-v1.json.asc"
        cat -- "$resultado"
        ;;

    *)
        uso
        ;;
esac
