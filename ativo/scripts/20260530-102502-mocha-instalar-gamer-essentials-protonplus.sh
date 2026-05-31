#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"
LC_ALL=C

TS="$(date +%Y%m%d-%H%M%S)"
HOST="$(hostname 2>/dev/null || printf '%s' 'host-desconhecido')"
USER_REAL="${SUDO_USER:-$USER}"

FAST_BASE="/media/mochafast/MochaArch"
ACTIVE="$FAST_BASE/ativo"
DOC_DIR="$ACTIVE/documentacao"
SCRIPT_DIR="$ACTIVE/scripts"
REPORT_DIR="$ACTIVE/relatorios"
AUR_BASE="$ACTIVE/aur/pkgbuilds-auditados"
TMP_DIR="/tmp/mocha-gamer-essentials-protonplus-$TS"

LOG="$REPORT_DIR/${TS}-mocha-gamer-essentials-protonplus-install.log"
REPORT_MD="$REPORT_DIR/${TS}-mocha-gamer-essentials-protonplus-install.md"
REPORT_TSV="$REPORT_DIR/${TS}-mocha-gamer-essentials-protonplus-install.tsv"
POLICY_DOC="$DOC_DIR/${TS}-mocha-gamer-essentials-protonplus-politica.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-instalar-gamer-essentials-protonplus.sh"

SUDO="/usr/bin/sudo"
[ -x /run/wrappers/bin/sudo ] && SUDO="/run/wrappers/bin/sudo"

say() { printf '\n== %s ==\n' "$*"; }
warn() { printf 'AVISO: %s\n' "$*" >&2; }
fail() { printf '\nERRO: %s\n' "$*" >&2; exit 1; }
append_line() { printf '%s\n' "$1" >> "$2"; }

cleanup() {
  if [ -n "${SUDO_KEEPALIVE_PID:-}" ]; then
    kill "$SUDO_KEEPALIVE_PID" >/dev/null 2>&1 || true
  fi
  rm -rf -- "$TMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

[ "${EUID:-$(id -u)}" -ne 0 ] || fail "Rode como usuário normal, não como root. O script usa sudo só quando precisa."

say "Validando mounts e pastas"
findmnt /media/mochafast >/dev/null 2>&1 || fail "/media/mochafast não está montado."

mkdir -p -- "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR" "$AUR_BASE" "$TMP_DIR"

[ -w "$DOC_DIR" ] || fail "Sem permissão de escrita em $DOC_DIR."
[ -w "$SCRIPT_DIR" ] || fail "Sem permissão de escrita em $SCRIPT_DIR."
[ -w "$REPORT_DIR" ] || fail "Sem permissão de escrita em $REPORT_DIR."
[ -w "$AUR_BASE" ] || fail "Sem permissão de escrita em $AUR_BASE."

exec > >(tee -a "$LOG") 2>&1

say "Validando ambiente Arch"
command -v pacman >/dev/null 2>&1 || fail "pacman não encontrado."
if [ -e /var/lib/pacman/db.lck ]; then
  fail "Há lock do pacman em /var/lib/pacman/db.lck. Feche Discover, Pamac, pacman ou outro gerenciador antes de continuar."
fi

say "Obtendo sudo e mantendo sessão ativa"
"$SUDO" -v
while true; do
  "$SUDO" -n true >/dev/null 2>&1 || exit 0
  sleep 45
done &
SUDO_KEEPALIVE_PID="$!"

say "Salvando cópia reutilizável do script"
cp -a -- "$0" "$SCRIPT_COPY" 2>/dev/null || true
chmod +x "$SCRIPT_COPY" 2>/dev/null || true

pkg_installed() {
  pacman -Qq "$1" >/dev/null 2>&1
}

pkg_repo_available() {
  pacman -Si "$1" >/dev/null 2>&1
}

aur_available() {
  local pkg="$1" out
  command -v curl >/dev/null 2>&1 || return 1
  out="$(curl -fsS --max-time 12 --retry 1 --get 'https://aur.archlinux.org/rpc/v5/info' --data-urlencode "arg[]=$pkg" 2>/dev/null || true)"
  printf '%s' "$out" | grep -Eq '"resultcount"[[:space:]]*:[[:space:]]*[1-9]'
}

flatpak_installed() {
  local appid="$1"
  [ -n "$appid" ] || return 1
  command -v flatpak >/dev/null 2>&1 || return 1
  flatpak info "$appid" >/dev/null 2>&1
}

flatpak_available() {
  local appid="$1"
  [ -n "$appid" ] || return 1
  command -v flatpak >/dev/null 2>&1 || return 1
  flatpak remote-info flathub "$appid" >/dev/null 2>&1
}

safe_pkg_for_pacman_install() {
  local pkg="$1" info bad name
  info="$(pacman -Si "$pkg" 2>/dev/null || true)"
  [ -n "$info" ] || return 1

  bad="$(
    printf '%s\n' "$info" \
      | awk -F ':' '/^(Conflicts With|Replaces)/ { print $2 }' \
      | tr ' ' '\n' \
      | sed '/^$/d; /^None$/d; s/[<>=].*$//'
  )"

  while IFS= read -r name; do
    [ -n "$name" ] || continue
    if pkg_installed "$name" && [ "$name" != "$pkg" ]; then
      warn "Pulando $pkg: ele conflita/substitui pacote já instalado ($name). Não vou remover/substituir automaticamente."
      return 1
    fi
  done <<< "$bad"

  return 0
}

install_pacman_batch() {
  local list_file="$1"
  if [ ! -s "$list_file" ]; then
    say "Nenhum pacote oficial novo para instalar"
    return 0
  fi

  say "Pacotes oficiais que serão instalados via pacman"
  cat "$list_file"

  say "Instalando pacotes oficiais sem atualização geral do sistema"
  "$SUDO" pacman -S --needed --noconfirm --disable-download-timeout $(cat "$list_file")
}

clone_or_refresh_aur() {
  local pkg="$1" dest="$2"

  if [ -d "$dest/.git" ]; then
    say "Atualizando PKGBUILD AUR já existente: $pkg"
    git -C "$dest" fetch --depth=1 origin master
    git -C "$dest" reset --hard origin/master
  else
    say "Clonando PKGBUILD AUR: $pkg"
    rm -rf -- "$dest"
    git clone --depth=1 "https://aur.archlinux.org/${pkg}.git" "$dest"
  fi
}

safe_aur_srcinfo() {
  local pkg="$1" dir="$2" srcinfo="$3" bad name

  (
    cd "$dir"
    makepkg --printsrcinfo > "$srcinfo"
  )

  bad="$(
    awk -F '= ' '/^[[:space:]]*(conflicts|replaces)[[:space:]]*=/ { print $2 }' "$srcinfo" \
      | tr ' ' '\n' \
      | sed '/^$/d; s/[<>=].*$//'
  )"

  while IFS= read -r name; do
    [ -n "$name" ] || continue
    if pkg_installed "$name" && [ "$name" != "$pkg" ]; then
      warn "Pulando AUR $pkg: ele conflita/substitui pacote já instalado ($name). Não vou remover/substituir automaticamente."
      return 1
    fi
  done <<< "$bad"

  return 0
}

install_aur_pkg() {
  local pkg="$1" dest srcinfo aur_copy

  [[ "$pkg" =~ ^[A-Za-z0-9@._+-]+$ ]] || {
    warn "Nome AUR rejeitado por segurança: $pkg"
    return 0
  }

  if pkg_installed "$pkg"; then
    printf 'AUR/local já instalado: %s\n' "$pkg"
    append_line "$pkg	AUR_OU_LOCAL	JA_INSTALADO" "$REPORT_TSV"
    return 0
  fi

  if ! aur_available "$pkg"; then
    warn "AUR não encontrado ou sem rede: $pkg"
    append_line "$pkg	AUR	NAO_ENCONTRADO_OU_SEM_REDE" "$REPORT_TSV"
    return 0
  fi

  dest="$TMP_DIR/aur-$pkg"
  srcinfo="$REPORT_DIR/${TS}-aur-${pkg}.SRCINFO"
  aur_copy="$AUR_BASE/${TS}-${pkg}"

  if ! clone_or_refresh_aur "$pkg" "$dest"; then
    warn "Falha ao clonar AUR $pkg"
    append_line "$pkg	AUR	FALHA_CLONE" "$REPORT_TSV"
    return 0
  fi

  if ! safe_aur_srcinfo "$pkg" "$dest" "$srcinfo"; then
    append_line "$pkg	AUR_PULADO	CONFLITO_OU_REPLACE_DETECTADO" "$REPORT_TSV"
    return 0
  fi

  rm -rf -- "$aur_copy"
  cp -a -- "$dest" "$aur_copy"

  say "Instalando AUR pacote a pacote: $pkg"
  (
    cd "$dest"
    makepkg -si --needed --noconfirm --log
  ) || {
    warn "Falha ao instalar AUR: $pkg. Seguindo para os próximos itens."
    append_line "$pkg	AUR	FALHA_MAKEPKG" "$REPORT_TSV"
    return 0
  }

  append_line "$pkg	AUR	INSTALADO_OU_JA_PRESENTE" "$REPORT_TSV"
}

install_flatpak_app() {
  local appid="$1"
  [ -n "$appid" ] || return 0

  if flatpak_installed "$appid"; then
    printf 'Flatpak já instalado: %s\n' "$appid"
    append_line "$appid	FLATPAK	JA_INSTALADO" "$REPORT_TSV"
    return 0
  fi

  command -v flatpak >/dev/null 2>&1 || {
    warn "flatpak não disponível para instalar $appid"
    append_line "$appid	FLATPAK	SEM_FLATPAK" "$REPORT_TSV"
    return 0
  }

  say "Garantindo Flathub"
  "$SUDO" flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || {
    warn "Não consegui garantir Flathub para $appid"
    append_line "$appid	FLATPAK	FALHA_FLATHUB" "$REPORT_TSV"
    return 0
  }

  if ! flatpak_available "$appid"; then
    warn "Flatpak não encontrado no Flathub ou sem rede: $appid"
    append_line "$appid	FLATPAK	NAO_ENCONTRADO_OU_SEM_REDE" "$REPORT_TSV"
    return 0
  fi

  say "Instalando Flatpak: $appid"
  "$SUDO" flatpak install -y flathub "$appid" || {
    warn "Falha ao instalar Flatpak: $appid"
    append_line "$appid	FLATPAK	FALHA_INSTALL" "$REPORT_TSV"
    return 0
  }

  append_line "$appid	FLATPAK	INSTALADO" "$REPORT_TSV"
}

schedule_item() {
  local item="$1" official_pkg="$2" aur_pkg="$3" flatpak_id="$4" preference="$5" layer="$6" note="$7"

  printf '\nItem: %s\n' "$item"
  printf 'Camada: %s\n' "$layer"
  printf 'Preferência: %s\n' "$preference"
  printf 'Observação: %s\n' "$note"

  if [ -n "$official_pkg" ] && pkg_installed "$official_pkg"; then
    printf 'Status: já instalado via pacman: %s\n' "$official_pkg"
    append_line "$item	PACMAN_JA_INSTALADO	$official_pkg" "$REPORT_TSV"
    return 0
  fi

  if [ -n "$aur_pkg" ] && pkg_installed "$aur_pkg"; then
    printf 'Status: já instalado via AUR/local: %s\n' "$aur_pkg"
    append_line "$item	AUR_OU_LOCAL_JA_INSTALADO	$aur_pkg" "$REPORT_TSV"
    return 0
  fi

  if [ -n "$flatpak_id" ] && flatpak_installed "$flatpak_id"; then
    printf 'Status: já instalado via Flatpak: %s\n' "$flatpak_id"
    append_line "$item	FLATPAK_JA_INSTALADO	$flatpak_id" "$REPORT_TSV"
    return 0
  fi

  case "$preference" in
    repo_then_flatpak_then_aur)
      if [ -n "$official_pkg" ] && pkg_repo_available "$official_pkg" && safe_pkg_for_pacman_install "$official_pkg"; then
        printf '%s\n' "$official_pkg" >> "$PACMAN_LIST"
        append_line "$item	PACMAN_AGENDADO	$official_pkg" "$REPORT_TSV"
      elif [ -n "$flatpak_id" ]; then
        printf '%s\n' "$flatpak_id" >> "$FLATPAK_LIST"
        append_line "$item	FLATPAK_AGENDADO	$flatpak_id" "$REPORT_TSV"
      elif [ -n "$aur_pkg" ]; then
        printf '%s\n' "$aur_pkg" >> "$AUR_LIST"
        append_line "$item	AUR_AGENDADO	$aur_pkg" "$REPORT_TSV"
      else
        append_line "$item	SEM_CANDIDATO	-" "$REPORT_TSV"
      fi
      ;;

    repo_then_aur_then_flatpak)
      if [ -n "$official_pkg" ] && pkg_repo_available "$official_pkg" && safe_pkg_for_pacman_install "$official_pkg"; then
        printf '%s\n' "$official_pkg" >> "$PACMAN_LIST"
        append_line "$item	PACMAN_AGENDADO	$official_pkg" "$REPORT_TSV"
      elif [ -n "$aur_pkg" ]; then
        printf '%s\n' "$aur_pkg" >> "$AUR_LIST"
        append_line "$item	AUR_AGENDADO	$aur_pkg" "$REPORT_TSV"
      elif [ -n "$flatpak_id" ]; then
        printf '%s\n' "$flatpak_id" >> "$FLATPAK_LIST"
        append_line "$item	FLATPAK_AGENDADO	$flatpak_id" "$REPORT_TSV"
      else
        append_line "$item	SEM_CANDIDATO	-" "$REPORT_TSV"
      fi
      ;;

    flatpak_then_aur)
      if [ -n "$flatpak_id" ]; then
        printf '%s\n' "$flatpak_id" >> "$FLATPAK_LIST"
        append_line "$item	FLATPAK_AGENDADO	$flatpak_id" "$REPORT_TSV"
      elif [ -n "$aur_pkg" ]; then
        printf '%s\n' "$aur_pkg" >> "$AUR_LIST"
        append_line "$item	AUR_AGENDADO	$aur_pkg" "$REPORT_TSV"
      else
        append_line "$item	SEM_CANDIDATO	-" "$REPORT_TSV"
      fi
      ;;

    aur_then_flatpak)
      if [ -n "$aur_pkg" ]; then
        printf '%s\n' "$aur_pkg" >> "$AUR_LIST"
        append_line "$item	AUR_AGENDADO	$aur_pkg" "$REPORT_TSV"
      elif [ -n "$flatpak_id" ]; then
        printf '%s\n' "$flatpak_id" >> "$FLATPAK_LIST"
        append_line "$item	FLATPAK_AGENDADO	$flatpak_id" "$REPORT_TSV"
      else
        append_line "$item	SEM_CANDIDATO	-" "$REPORT_TSV"
      fi
      ;;

    *)
      warn "Preferência desconhecida para $item: $preference"
      append_line "$item	ERRO_PREFERENCIA	$preference" "$REPORT_TSV"
      ;;
  esac
}

say "Instalando pré-requisitos mínimos para auditoria/AUR/Flatpak"
"$SUDO" pacman -S --needed --noconfirm --disable-download-timeout base-devel git curl flatpak

append_line "item	status	alvo" "$REPORT_TSV"

PACMAN_LIST="$TMP_DIR/pacman-packages.txt"
AUR_LIST="$TMP_DIR/aur-packages.txt"
FLATPAK_LIST="$TMP_DIR/flatpak-apps.txt"
: > "$PACMAN_LIST"
: > "$AUR_LIST"
: > "$FLATPAK_LIST"

say "Montando lista Mocha Gamer Essentials corrigida com ProtonPlus como principal"

ITEMS=(
"Steam|steam|steam|com.valvesoftware.Steam|repo_then_aur_then_flatpak|PADRAO|Cliente Steam."
"GameMode|gamemode|gamemode||repo_then_aur_then_flatpak|PADRAO|Otimização por jogo."
"GameMode 32-bit|lib32-gamemode|lib32-gamemode||repo_then_aur_then_flatpak|PADRAO|Suporte 32-bit."
"MangoHud|mangohud|mangohud||repo_then_aur_then_flatpak|PADRAO|Overlay fundamental do Mocha."
"MangoHud 32-bit|lib32-mangohud|lib32-mangohud||repo_then_aur_then_flatpak|PADRAO|Suporte 32-bit."
"GOverlay|goverlay|goverlay||repo_then_aur_then_flatpak|PADRAO|Interface para MangoHud/vkBasalt/OptiScaler."
"Gamescope|gamescope|gamescope||repo_then_aur_then_flatpak|DISPONIVEL_SEM_ATIVAR|Disponível, mas fora do wrapper oficial."
"Lutris|lutris|lutris|net.lutris.Lutris|repo_then_aur_then_flatpak|PADRAO|Launcher para jogos fora da Steam."
"Heroic Games Launcher|heroic-games-launcher|heroic-games-launcher-bin|com.heroicgameslauncher.hgl|repo_then_aur_then_flatpak|PADRAO|Launcher Epic/GOG/Amazon."
"ProtonPlus|protonplus|protonplus|com.vysp3r.ProtonPlus|repo_then_flatpak_then_aur|PADRAO_PRINCIPAL|Gerenciador principal de Proton/Wine do Mocha."
"ProtonUp-Qt|protonup-qt|protonup-qt-bin|net.davidotek.pupgui2|repo_then_aur_then_flatpak|ALTERNATIVA_DISPONIVEL|Alternativa madura; não é o principal."
"Protontricks|protontricks|protontricks||repo_then_aur_then_flatpak|PADRAO|Correções por prefixo Proton."
"Winetricks|winetricks|winetricks||repo_then_aur_then_flatpak|PADRAO|Correções Wine."
"umu-launcher|umu-launcher|umu-launcher||repo_then_aur_then_flatpak|PADRAO_SE_DISPONIVEL|Camada Proton moderna para launchers."
"Vulkan Tools|vulkan-tools|vulkan-tools||repo_then_aur_then_flatpak|PADRAO|Diagnóstico Vulkan."
"Mesa Utils|mesa-utils|mesa-utils||repo_then_aur_then_flatpak|PADRAO|Diagnóstico OpenGL."
"Piper|piper|piper||repo_then_aur_then_flatpak|PADRAO|Mouse gamer."
"libratbag|libratbag|libratbag||repo_then_aur_then_flatpak|PADRAO|Backend do Piper."
"Input Remapper|input-remapper|input-remapper|io.github.sezanzeb.input_remapper|repo_then_aur_then_flatpak|PADRAO|Mapeamento de mouse/teclado/controles."
"Oversteer|oversteer|oversteer||repo_then_aur_then_flatpak|PADRAO|Volantes."
"AntiMicroX|antimicrox|antimicrox||repo_then_aur_then_flatpak|DISPONIVEL|Mapeador de controle."
"jstest-gtk|jstest-gtk|jstest-gtk||repo_then_aur_then_flatpak|DISPONIVEL|Teste/calibração de joystick."
"LACT|lact|lact||repo_then_aur_then_flatpak|PADRAO|Controle de GPU disponível ao usuário; serviço não será ativado automaticamente."
"CoreCtrl|corectrl|corectrl||repo_then_aur_then_flatpak|DISPONIVEL|Controle de GPU/perfis; não será configurado automaticamente."
"vkBasalt|vkbasalt|vkbasalt||repo_then_aur_then_flatpak|DISPONIVEL_SEM_ATIVAR|Disponível ao usuário; fora do wrapper oficial."
"vkBasalt 32-bit|lib32-vkbasalt|lib32-vkbasalt||repo_then_aur_then_flatpak|DISPONIVEL_SEM_ATIVAR|Suporte 32-bit se disponível."
"vkBasalt CLI|vkbasalt-cli|vkbasalt-cli||repo_then_aur_then_flatpak|DISPONIVEL_SEM_ATIVAR|Ferramenta complementar se disponível."
"ReShade Shaders|reshade-shaders|reshade-shaders||repo_then_aur_then_flatpak|DISPONIVEL_SEM_ATIVAR|Shaders opcionais."
"OBS Studio|obs-studio|obs-studio|com.obsproject.Studio|repo_then_aur_then_flatpak|PADRAO|Criação/streaming."
"OBS VkCapture|obs-vkcapture|obs-vkcapture||repo_then_aur_then_flatpak|DISPONIVEL|Captura Vulkan/OpenGL quando disponível."
"GPU Screen Recorder|gpu-screen-recorder|gpu-screen-recorder||repo_then_aur_then_flatpak|DISPONIVEL|Gravação leve."
"GPU Screen Recorder GTK|gpu-screen-recorder-gtk|gpu-screen-recorder-gtk|com.dec05eba.gpu_screen_recorder|repo_then_aur_then_flatpak|DISPONIVEL|Interface gráfica do gravador."
"Bottles|bottles|bottles|com.usebottles.bottles|repo_then_aur_then_flatpak|DISPONIVEL|Wine apps/jogos."
"Faugus Launcher|faugus-launcher|faugus-launcher-bin|io.github.Faugus.faugus-launcher|repo_then_aur_then_flatpak|CANDIDATO_AUDITAR|Launcher candidato visto em distros gamer."
"Discover|discover|discover||repo_then_aur_then_flatpak|PADRAO_SE_KDE|Central gráfica KDE."
)

for row in "${ITEMS[@]}"; do
  IFS='|' read -r item official_pkg aur_pkg flatpak_id preference layer note <<< "$row"
  schedule_item "$item" "$official_pkg" "$aur_pkg" "$flatpak_id" "$preference" "$layer" "$note"
done

sort -u "$PACMAN_LIST" > "$PACMAN_LIST.sorted"
sort -u "$AUR_LIST" > "$AUR_LIST.sorted"
sort -u "$FLATPAK_LIST" > "$FLATPAK_LIST.sorted"

install_pacman_batch "$PACMAN_LIST.sorted"

say "Instalando Flatpaks agendados"
if [ -s "$FLATPAK_LIST.sorted" ]; then
  while IFS= read -r appid; do
    [ -n "$appid" ] || continue
    install_flatpak_app "$appid"
  done < "$FLATPAK_LIST.sorted"
else
  printf 'Nenhum Flatpak agendado.\n'
fi

say "Instalando itens AUR permitidos, pacote a pacote, sem helper e sem atualização geral"
if [ -s "$AUR_LIST.sorted" ]; then
  while IFS= read -r aur_pkg; do
    [ -n "$aur_pkg" ] || continue
    install_aur_pkg "$aur_pkg"
  done < "$AUR_LIST.sorted"
else
  printf 'Nenhum item AUR agendado.\n'
fi

say "Coletando estado final"
{
  printf '# Mocha Gamer Essentials - instalação corrigida com ProtonPlus\n\n'
  printf 'Data: %s\n\n' "$TS"
  printf 'Máquina: %s\n\n' "$HOST"
  printf 'Usuário: %s\n\n' "$USER_REAL"

  printf '## Política aplicada\n\n'
  printf '1. ProtonPlus é o gerenciador principal de Proton/Wine do Mocha.\n'
  printf '2. ProtonUp-Qt fica instalado/disponível como alternativa, não como padrão principal.\n'
  printf '3. Pacotes oficiais foram preferidos quando disponíveis.\n'
  printf '4. Para ProtonPlus, a preferência é repo oficial se existir, depois Flatpak, depois AUR.\n'
  printf '5. AUR foi usado apenas pacote a pacote para itens da lista.\n'
  printf '6. Não foi executada atualização geral do sistema.\n'
  printf '7. Nenhum serviço opcional foi ativado automaticamente.\n'
  printf '8. vkBasalt, gamescope, LACT e CoreCtrl ficaram disponíveis, mas não foram inseridos no wrapper oficial.\n'
  printf '9. O wrapper/LaunchOptions oficial continua sem MANGOHUD_DLSYM, sem vkBasalt e sem gamescope por padrão.\n\n'

  printf '## Pacotes oficiais agendados\n\n'
  if [ -s "$PACMAN_LIST.sorted" ]; then
    sed 's/^/- /' "$PACMAN_LIST.sorted"
  else
    printf 'Nenhum.\n'
  fi

  printf '\n## Flatpaks agendados\n\n'
  if [ -s "$FLATPAK_LIST.sorted" ]; then
    sed 's/^/- /' "$FLATPAK_LIST.sorted"
  else
    printf 'Nenhum.\n'
  fi

  printf '\n## AUR agendado\n\n'
  if [ -s "$AUR_LIST.sorted" ]; then
    sed 's/^/- /' "$AUR_LIST.sorted"
  else
    printf 'Nenhum.\n'
  fi

  printf '\n## Verificações úteis\n\n'
  printf 'gamemoderun: '
  command -v gamemoderun || true
  printf 'mangohud: '
  command -v mangohud || true
  printf 'goverlay: '
  command -v goverlay || true
  printf 'lact: '
  command -v lact || true
  printf 'gamescope: '
  command -v gamescope || true
  printf 'flatpak ProtonPlus: '
  flatpak info com.vysp3r.ProtonPlus >/dev/null 2>&1 && printf 'instalado\n' || printf 'não instalado via Flatpak\n'
  printf 'flatpak ProtonUp-Qt: '
  flatpak info net.davidotek.pupgui2 >/dev/null 2>&1 && printf 'instalado\n' || printf 'não instalado via Flatpak\n'

  printf '\n## Serviços encontrados, sem ativação automática\n\n'
  systemctl list-unit-files 2>/dev/null | grep -Ei 'lact|input-remapper|ratbag|corectrl|gamemode' || true

  printf '\n## Arquivos\n\n'
  printf 'Log: %s\n' "$LOG"
  printf 'TSV: %s\n' "$REPORT_TSV"
  printf 'Script: %s\n' "$SCRIPT_COPY"
  printf 'AUR PKGBUILDs auditados: %s\n' "$AUR_BASE"
} > "$REPORT_MD"

say "Gerando documento de política"
{
  printf '# Mocha Gamer Essentials - ProtonPlus como padrão\n\n'
  printf 'Data: %s\n\n' "$TS"
  printf 'Decisão: ProtonPlus passa a ser o gerenciador principal de ferramentas Proton/Wine do Mocha.\n\n'
  printf '## Regras\n\n'
  printf '1. ProtonPlus é o padrão principal.\n'
  printf '2. ProtonUp-Qt continua disponível como alternativa madura.\n'
  printf '3. A presença de ProtonUp-Qt não muda a preferência visual/operacional do Mocha.\n'
  printf '4. AUR é permitido pacote a pacote, mas nunca em atualização geral.\n'
  printf '5. Flatpak é aceitável quando for o método principal ou mais estável para o aplicativo.\n'
  printf '6. vkBasalt, gamescope, LACT, CoreCtrl, Oversteer, Input Remapper, GOverlay e ferramentas similares podem estar presentes para escolha do usuário, mas não devem alterar o wrapper oficial nem as LaunchOptions canônicas sem teste específico.\n'
  printf '7. MangoHud continua sendo componente fundamental do Mocha e deve respeitar o padrão visual Mocha.\n\n'
  printf '## Relatório associado\n\n'
  printf '%s\n' "$REPORT_MD"
} > "$POLICY_DOC"

say "Atualizando manual principal se encontrado"
MANUAL=""
if find "$DOC_DIR" -maxdepth 1 -type f -iname '*manual*.md' -print -quit | grep -q .; then
  MANUAL="$(find "$DOC_DIR" -maxdepth 1 -type f -iname '*manual*.md' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
fi

if [ -n "$MANUAL" ] && [ -f "$MANUAL" ]; then
  BACKUP="${MANUAL}.bak-${TS}"
  cp -a -- "$MANUAL" "$BACKUP"

  {
    printf '\n---\n\n'
    printf '# Entrada %s - Gamer Essentials corrigido com ProtonPlus\n\n' "$TS"
    printf 'Foi aplicada a correção da camada Mocha Gamer Essentials.\n\n'
    printf 'Decisões registradas:\n\n'
    printf '1. ProtonPlus passa a ser o gerenciador principal de Proton/Wine.\n'
    printf '2. ProtonUp-Qt permanece disponível apenas como alternativa.\n'
    printf '3. Pacotes oficiais continuam tendo prioridade.\n'
    printf '4. Para ProtonPlus, a preferência é repo oficial se existir, depois Flatpak, depois AUR.\n'
    printf '5. AUR é permitido somente pacote a pacote, sem atualização geral.\n'
    printf '6. Softwares como vkBasalt, gamescope, LACT, CoreCtrl, Input Remapper, Oversteer e GOverlay ficam disponíveis ao usuário.\n'
    printf '7. Disponível não significa ativado automaticamente.\n'
    printf '8. O wrapper oficial permanece sem MANGOHUD_DLSYM, sem vkBasalt e sem gamescope por padrão.\n'
    printf '9. MangoHud continua sendo componente fundamental do Mocha e deve respeitar o padrão visual Mocha.\n\n'
    printf 'Relatório: %s\n\n' "$REPORT_MD"
    printf 'Política: %s\n\n' "$POLICY_DOC"
    printf 'TSV: %s\n\n' "$REPORT_TSV"
  } >> "$MANUAL"

  find "$DOC_DIR" -maxdepth 1 -type f -name "$(basename "$MANUAL").bak-*" -printf '%T@ %p\n' \
    | sort -nr \
    | tail -n +3 \
    | cut -d' ' -f2- \
    | while IFS= read -r old_backup; do
        [ -n "$old_backup" ] || continue
        rm -f -- "$old_backup"
        printf 'Backup antigo removido: %s\n' "$old_backup"
      done
else
  warn "Nenhum manual com 'manual' no nome foi encontrado. A política ficou em documento separado."
fi

say "Resumo final"
printf 'Log:        %s\n' "$LOG"
printf 'Relatório:  %s\n' "$REPORT_MD"
printf 'TSV:        %s\n' "$REPORT_TSV"
printf 'Política:   %s\n' "$POLICY_DOC"
printf 'Script:     %s\n' "$SCRIPT_COPY"
printf 'AUR audit:  %s\n' "$AUR_BASE"
[ -n "${MANUAL:-}" ] && printf 'Manual:     %s\n' "$MANUAL"

printf '\n%s\n' "Concluído. ProtonPlus foi priorizado; ProtonUp-Qt ficou como alternativa; wrapper oficial não foi alterado."
