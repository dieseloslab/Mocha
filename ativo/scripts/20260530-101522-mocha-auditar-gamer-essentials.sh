#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
HOST="$(hostname 2>/dev/null || printf '%s' 'host-desconhecido')"
FAST_BASE="/media/mochafast/MochaArch"
VM_BASE="/media/vmstore/MochaArch"
ACTIVE="$FAST_BASE/ativo"
DOC_DIR="$ACTIVE/documentacao"
SCRIPT_DIR="$ACTIVE/scripts"
REPORT_DIR="$ACTIVE/relatorios"
TMP_DIR="/tmp/mocha-gamer-essentials-$TS"

REPORT_MD="$REPORT_DIR/${TS}-mocha-gamer-essentials-auditoria.md"
REPORT_TSV="$REPORT_DIR/${TS}-mocha-gamer-essentials-auditoria.tsv"
POLICY_DOC="$DOC_DIR/${TS}-mocha-gamer-essentials-politica.md"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-auditar-gamer-essentials.sh"

say() { printf '\n== %s ==\n' "$*"; }
warn() { printf 'AVISO: %s\n' "$*" >&2; }
fail() { printf '\nERRO: %s\n' "$*" >&2; exit 1; }
append_line() { printf '%s\n' "$1" >> "$2"; }

cleanup() {
  rm -rf -- "$TMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

say "Validando mounts e pastas do MochaArch"
findmnt /media/mochafast >/dev/null 2>&1 || fail "/media/mochafast não está montado. Monte o FAST antes de registrar documentação ativa."
findmnt /media/vmstore >/dev/null 2>&1 || warn "/media/vmstore não está montado; a auditoria seguirá no FAST, sem tocar no repositório seguro do VMSTORE."

mkdir -p -- "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR" "$TMP_DIR"
[ -w "$DOC_DIR" ] || fail "Sem permissão de escrita em $DOC_DIR."
[ -w "$SCRIPT_DIR" ] || fail "Sem permissão de escrita em $SCRIPT_DIR."
[ -w "$REPORT_DIR" ] || fail "Sem permissão de escrita em $REPORT_DIR."

say "Validando ferramentas locais"
command -v pacman >/dev/null 2>&1 || fail "pacman não encontrado; este passo é para a base Arch/MochaArch."
if ! command -v curl >/dev/null 2>&1; then
  warn "curl não encontrado; a checagem AUR online será marcada como não auditada."
fi
if ! command -v flatpak >/dev/null 2>&1; then
  warn "flatpak não encontrado; a checagem Flatpak será marcada como não auditada."
fi

say "Registrando cópia reutilizável do script"
cp -a -- "$0" "$SCRIPT_COPY" 2>/dev/null || warn "Não consegui copiar $0 para $SCRIPT_COPY; o relatório ainda será gerado."
chmod +x "$SCRIPT_COPY" 2>/dev/null || true

pkg_installed() {
  pacman -Qq "$1" >/dev/null 2>&1
}

pkg_repo() {
  pacman -Si "$1" >/dev/null 2>&1
}

aur_status() {
  local pkg="$1" out
  if ! command -v curl >/dev/null 2>&1; then
    printf '%s' 'NAO_AUDITADO_SEM_CURL'
    return 0
  fi
  out="$(curl -fsS --max-time 10 --retry 1 --get 'https://aur.archlinux.org/rpc/v5/info' --data-urlencode "arg[]=$pkg" 2>/dev/null || true)"
  if printf '%s' "$out" | grep -Eq '"resultcount"[[:space:]]*:[[:space:]]*[1-9]'; then
    printf '%s' 'AUR_DISPONIVEL'
  elif [ -n "$out" ]; then
    printf '%s' 'NAO_ENCONTRADO_AUR'
  else
    printf '%s' 'AUR_INDISPONIVEL_OU_SEM_REDE'
  fi
}

flatpak_remote_status() {
  local appid="$1"
  if [ -z "$appid" ]; then
    printf '%s' 'SEM_APPID_MAPEADO'
    return 0
  fi
  if ! command -v flatpak >/dev/null 2>&1; then
    printf '%s' 'NAO_AUDITADO_SEM_FLATPAK'
    return 0
  fi
  if flatpak info "$appid" >/dev/null 2>&1; then
    printf '%s' 'FLATPAK_INSTALADO'
    return 0
  fi
  if flatpak remote-info flathub "$appid" >/dev/null 2>&1; then
    printf '%s' 'FLATHUB_DISPONIVEL'
  else
    printf '%s' 'NAO_ENCONTRADO_FLATHUB_OU_SEM_REDE'
  fi
}

item_repo_summary() {
  local candidates="$1" p installed_any repo_any aur_any status parts
  installed_any="nao"
  repo_any="nao"
  aur_any=""
  parts=""
  for p in $candidates; do
    status=""
    if pkg_installed "$p"; then
      installed_any="sim"
      status="instalado"
    fi
    if pkg_repo "$p"; then
      repo_any="sim"
      if [ -n "$status" ]; then
        status="$status+repo"
      else
        status="repo"
      fi
    fi
    if [ -z "$status" ]; then
      status="$(aur_status "$p")"
      case "$status" in
        AUR_DISPONIVEL) aur_any="sim" ;;
      esac
    fi
    if [ -z "$parts" ]; then
      parts="$p=$status"
    else
      parts="$parts; $p=$status"
    fi
  done
  if [ -z "$aur_any" ]; then
    aur_any="nao"
  fi
  printf '%s\t%s\t%s\t%s' "$installed_any" "$repo_any" "$aur_any" "$parts"
}

flatpak_for_item() {
  local item="$1"
  case "$item" in
    "Lutris") printf '%s' 'net.lutris.Lutris' ;;
    "Heroic Games Launcher") printf '%s' 'com.heroicgameslauncher.hgl' ;;
    "Bottles") printf '%s' 'com.usebottles.bottles' ;;
    "ProtonUp-Qt") printf '%s' 'net.davidotek.pupgui2' ;;
    "OBS Studio") printf '%s' 'com.obsproject.Studio' ;;
    "GPU Screen Recorder") printf '%s' 'com.dec05eba.gpu_screen_recorder' ;;
    "Input Remapper") printf '%s' 'io.github.sezanzeb.input_remapper' ;;
    *) printf '%s' '' ;;
  esac
}

say "Auditando lista Gamer Essentials sem instalar/remover pacotes"
append_line "item	grupo	camada_mocha	candidatos_pacman	instalado_pacman	disponivel_repo_oficial	disponivel_aur	flatpak_appid	flatpak_status	detalhe_pacman_aur	observacao" "$REPORT_TSV"

ITEMS=(
"Steam|gamer-essencial|PADRAO|steam|Cliente Steam; base comum de distros gamer."
"GameMode|gamer-essencial|PADRAO|gamemode lib32-gamemode|Ativador de perfil de jogo; linha oficial atual permanece gamemoderun %command% até teste do wrapper MangoHud."
"MangoHud|gamer-essencial|PADRAO|mangohud lib32-mangohud|Overlay fundamental do Mocha; deve usar padrão visual Mocha."
"GOverlay|gamer-essencial|PADRAO|goverlay|Interface para configurar MangoHud/vkBasalt/OptiScaler; instalado não significa ativar vkBasalt no wrapper."
"Gamescope|gamer-ferramenta|DISPONIVEL_SEM_ATIVAR|gamescope|Pode existir para usuário/testes, mas não entra no wrapper oficial sem validação."
"Lutris|launcher|PADRAO|lutris|Launcher importante para jogos fora da Steam."
"Heroic Games Launcher|launcher|PADRAO|heroic-games-launcher heroic-games-launcher-bin|Launcher Epic/GOG/Amazon; nome varia conforme repo/AUR/Flatpak."
"Protontricks|proton-wine|PADRAO|protontricks|Ferramenta de correção por prefixo Proton."
"Winetricks|proton-wine|PADRAO|winetricks|Ferramenta auxiliar Wine/Proton."
"ProtonUp-Qt|proton-wine|PADRAO_OU_FLATPAK|protonup-qt|Gerenciador gráfico de Proton-GE/Wine-GE."
"umu-launcher|proton-wine|PADRAO_SE_DISPONIVEL|umu-launcher|Camada moderna usada por launchers para Proton fora da Steam."
"Vulkan Tools|diagnostico|PADRAO|vulkan-tools|Diagnóstico Vulkan."
"Mesa Utils|diagnostico|PADRAO|mesa-utils|Diagnóstico OpenGL."
"Piper|perifericos|PADRAO|piper|Configuração de mouse gamer via libratbag/ratbagd."
"libratbag|perifericos|PADRAO|libratbag|Backend do Piper para mouse gamer."
"Input Remapper|perifericos|PADRAO|input-remapper|Remapeamento de mouse, teclado, controle e periféricos; útil no Wayland."
"Oversteer|perifericos|PADRAO|oversteer|Gerenciamento de volantes suportados no Linux."
"AntiMicroX|perifericos|DISPONIVEL|antimicrox|Mapeador de controle/teclado útil para jogos antigos."
"jstest-gtk|perifericos|DISPONIVEL|jstest-gtk|Teste/calibração de joystick."
"vkBasalt|visual-opcional|DISPONIVEL_SEM_ATIVAR|vkbasalt vkbasalt-git|Pode ficar disponível, mas não entra no wrapper oficial por padrão."
"vkBasalt CLI|visual-opcional|DISPONIVEL_SEM_ATIVAR|vkbasalt-cli|Ferramenta complementar se existir no repo usado."
"ReShade Shaders|visual-opcional|DISPONIVEL_SEM_ATIVAR|reshade-shaders|Shaders opcionais para usuário avançado."
"LACT|energia-gpu|CANDIDATO_AUDITAR|lact lact-git|Controle de GPU; precisa validação por hardware e serviço antes de virar padrão."
"CoreCtrl|energia-gpu|CANDIDATO_AUDITAR|corectrl|Útil sobretudo para AMD; não substituir política NVIDIA atual sem teste."
"OBS Studio|criacao|PADRAO|obs-studio|Gravação/streaming; comum em distro gamer/criador."
"GPU Screen Recorder|criacao|DISPONIVEL|gpu-screen-recorder gpu-screen-recorder-gtk|Gravação leve; validar com NVIDIA/Wayland antes de padrão final."
"Bottles|launcher|DISPONIVEL|bottles|Wine apps/jogos; bom disponível, mas pode ficar Flatpak."
"Faugus Launcher|launcher|CANDIDATO_AUDITAR|faugus-launcher faugus-launcher-bin|Candidato visto em GLF; auditar maturidade antes de padrão."
)

for row in "${ITEMS[@]}"; do
  IFS='|' read -r item group layer candidates obs <<< "$row"
  summary="$(item_repo_summary "$candidates")"
  IFS=$'\t' read -r installed_any repo_any aur_any detail <<< "$summary"
  appid="$(flatpak_for_item "$item")"
  fp_status="$(flatpak_remote_status "$appid")"
  append_line "$item	$group	$layer	$candidates	$installed_any	$repo_any	$aur_any	$appid	$fp_status	$detail	$obs" "$REPORT_TSV"
  printf '%-24s instalado=%-3s repo=%-3s aur=%-3s flatpak=%s\n' "$item" "$installed_any" "$repo_any" "$aur_any" "$fp_status"
done

say "Coletando estado MangoHud/GameMode/Steam sem alterar configuração"
MANGOHUD_LOCATIONS="$TMP_DIR/mangohud-locations.txt"
{
  printf '%s\n' "HOME=${HOME:-desconhecido}"
  for p in \
    "${HOME:-}/.config/MangoHud/MangoHud.conf" \
    "${HOME:-}/.config/MangoHud/Mocha-MangoHud.conf" \
    "${HOME:-}/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf" \
    "/etc/MangoHud/MangoHud.conf" \
    "/etc/mangohud/MangoHud.conf" \
    "/etc/mocha/mangohud/MangoHud.conf" \
    "/etc/mocha/mangohud/Mocha-MangoHud.conf"; do
    if [ -e "$p" ]; then
      printf '%s\n' "EXISTE $p"
    else
      printf '%s\n' "AUSENTE $p"
    fi
  done
  if command -v gamemoderun >/dev/null 2>&1; then
    printf '%s\n' "gamemoderun=OK $(command -v gamemoderun)"
  else
    printf '%s\n' "gamemoderun=AUSENTE"
  fi
  if command -v mangohud >/dev/null 2>&1; then
    printf '%s\n' "mangohud=OK $(command -v mangohud)"
  else
    printf '%s\n' "mangohud=AUSENTE"
  fi
} > "$MANGOHUD_LOCATIONS"

say "Gerando relatório Markdown"
append_line "# Auditoria Mocha Gamer Essentials" "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "Data: $TS" "$REPORT_MD"
append_line "Máquina: $HOST" "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "## Escopo" "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "Este relatório não instala, remove nem atualiza pacotes." "$REPORT_MD"
append_line "Ele apenas audita o estado local via pacman, consulta disponibilidade no AUR por RPC quando há curl/rede e verifica alguns AppIDs Flatpak conhecidos quando há flatpak/flathub." "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "## Regra Mocha para ferramentas gamer" "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "Instalar ou disponibilizar uma ferramenta não significa ativá-la automaticamente no wrapper oficial." "$REPORT_MD"
append_line "O wrapper/LaunchOptions oficial deve continuar limpo, testado e sem MANGOHUD_DLSYM, sem vkBasalt e sem gamescope por padrão." "$REPORT_MD"
append_line "vkBasalt e gamescope podem existir para uso escolhido pelo usuário ou receitas específicas validadas." "$REPORT_MD"
append_line "MangoHud é obrigatório no padrão Mocha e precisa respeitar a configuração visual Mocha." "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "## Resumo por item" "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "| Item | Camada | Pacman instalado | Repo oficial | AUR | Flatpak | Observação |" "$REPORT_MD"
append_line "|---|---:|---:|---:|---:|---:|---|" "$REPORT_MD"
awk -F '\t' 'NR>1 { gsub(/\|/, "\\|", $11); printf "| %s | %s | %s | %s | %s | %s | %s |\n", $1, $3, $5, $6, $7, $9, $11 }' "$REPORT_TSV" >> "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "## Estado MangoHud/GameMode" "$REPORT_MD"
append_line "" "$REPORT_MD"
while IFS= read -r line; do
  append_line "$(printf '%s' "$line")" "$REPORT_MD"
done < "$MANGOHUD_LOCATIONS"
append_line "" "$REPORT_MD"
append_line "## Arquivos gerados" "$REPORT_MD"
append_line "" "$REPORT_MD"
append_line "Relatório TSV: $REPORT_TSV" "$REPORT_MD"
append_line "Script reutilizável: $SCRIPT_COPY" "$REPORT_MD"

say "Gerando documento de política Gamer Essentials"
append_line "# Mocha Gamer Essentials - política de seleção de softwares" "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "Data: $TS" "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "## Decisão" "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "O Mocha deve entregar ao usuário uma seleção comparável às distros gamer modernas, incluindo Steam, GameMode, MangoHud, GOverlay, launchers, ferramentas Proton/Wine, periféricos gamer e ferramentas de captura." "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "## Camadas" "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "PADRAO: candidato a vir instalado por padrão quando estiver em repositório confiável ou empacotamento Mocha controlado." "$POLICY_DOC"
append_line "DISPONIVEL_SEM_ATIVAR: pode estar instalado ou disponível, mas não é chamado automaticamente pelo wrapper oficial." "$POLICY_DOC"
append_line "CANDIDATO_AUDITAR: precisa teste prático antes de entrar como padrão." "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "## Regras permanentes" "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "1. AUR não entra em atualização geral do sistema." "$POLICY_DOC"
append_line "2. AUR só pode ser usado pacote a pacote, com auditoria e justificativa." "$POLICY_DOC"
append_line "3. Se um pacote AUR virar parte oficial do Mocha, o caminho preferido é promover para repositório Mocha controlado." "$POLICY_DOC"
append_line "4. vkBasalt e gamescope podem estar disponíveis para o usuário, mas não entram no wrapper oficial por padrão." "$POLICY_DOC"
append_line "5. MangoHud é parte fundamental do padrão gamer Mocha e deve usar configuração visual Mocha." "$POLICY_DOC"
append_line "6. A linha oficial atual de teste permanece gamemoderun %command% até validação específica do wrapper/integração MangoHud, sem MANGOHUD_DLSYM." "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "## Auditoria associada" "$POLICY_DOC"
append_line "" "$POLICY_DOC"
append_line "$REPORT_MD" "$POLICY_DOC"

say "Localizando manual principal para acrescentar a seção"
MANUAL=""
if find "$DOC_DIR" -maxdepth 1 -type f -iname '*manual*.md' -print -quit | grep -q .; then
  MANUAL="$(find "$DOC_DIR" -maxdepth 1 -type f -iname '*manual*.md' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
fi

if [ -n "$MANUAL" ] && [ -f "$MANUAL" ]; then
  say "Auditando manual antes de editar"
  printf 'Manual selecionado: %s\n' "$MANUAL"
  printf 'Últimas linhas antes da alteração:\n'
  tail -n 20 "$MANUAL" || true

  BACKUP="${MANUAL}.bak-${TS}"
  cp -a -- "$MANUAL" "$BACKUP"

  {
    printf '\n%s\n' "---"
    printf '%s\n' ""
    printf '%s\n' "# Entrada $TS - Mocha Gamer Essentials"
    printf '%s\n' ""
    printf '%s\n' "Foi registrada a política de seleção Gamer Essentials sem instalar/remover pacotes."
    printf '%s\n' ""
    printf '%s\n' "Regras adicionadas ao manual:"
    printf '%s\n' "1. O Mocha deve oferecer ferramentas comparáveis às distros gamer modernas: Steam, GameMode, MangoHud, GOverlay, launchers, Proton/Wine, periféricos gamer e captura."
    printf '%s\n' "2. Disponibilizar vkBasalt/gamescope não significa ativar essas ferramentas no wrapper oficial."
    printf '%s\n' "3. Wrapper/LaunchOptions oficial permanece limpo: sem MANGOHUD_DLSYM, sem vkBasalt e sem gamescope por padrão."
    printf '%s\n' "4. MangoHud é componente fundamental e precisa respeitar o padrão visual Mocha."
    printf '%s\n' "5. AUR não deve ser usado para atualização geral; somente pacote a pacote, auditado, ou promovido depois para repositório Mocha controlado."
    printf '%s\n' ""
    printf '%s\n' "Documentos desta etapa:"
    printf '%s\n' "Relatório: $REPORT_MD"
    printf '%s\n' "Política: $POLICY_DOC"
    printf '%s\n' "TSV: $REPORT_TSV"
  } >> "$MANUAL"

  say "Limitando backups do manual a no máximo 2"
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
  say "Nenhum manual com nome contendo 'manual' foi encontrado; mantendo documento separado"
  warn "Política salva em $POLICY_DOC. Quando o manual principal existir/for identificado, anexar esta seção nele."
fi

say "Resumo final"
printf 'Relatório Markdown: %s\n' "$REPORT_MD"
printf 'Relatório TSV:      %s\n' "$REPORT_TSV"
printf 'Política:           %s\n' "$POLICY_DOC"
printf 'Script salvo:       %s\n' "$SCRIPT_COPY"
if [ -n "${MANUAL:-}" ]; then
  printf 'Manual atualizado:  %s\n' "$MANUAL"
fi
printf '\n%s\n' "Nada foi instalado, removido ou atualizado."
