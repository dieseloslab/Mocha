set -Eeuo pipefail

export PATH="/run/wrappers/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"
REAL_USER="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$REAL_USER" | cut -d: -f6 || printf '%s\n' "$HOME")"

if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
else
  SUDO="$(command -v sudo || true)"
fi

say() {
  printf '\n===== %s =====\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "comando obrigatório ausente: $1"
}

run() {
  printf '\n>> %s\n' "$*"
  "$@"
}

write_autostart_hidden_user() {
  file="$1"
  name="$2"
  exec_cmd="$3"
  {
    printf '%s\n' '[Desktop Entry]'
    printf '%s\n' 'Type=Application'
    printf 'Name=%s\n' "$name"
    printf 'Exec=%s\n' "$exec_cmd"
    printf '%s\n' 'Hidden=true'
    printf '%s\n' 'X-Mocha-Reason=Evitar applet redundante; Plasma nativo permanece ativo.'
  } > "$file"
  chmod 0644 "$file"
}

write_autostart_hidden_root() {
  file="$1"
  name="$2"
  exec_cmd="$3"
  tmp="$(mktemp)"
  {
    printf '%s\n' '[Desktop Entry]'
    printf '%s\n' 'Type=Application'
    printf 'Name=%s\n' "$name"
    printf 'Exec=%s\n' "$exec_cmd"
    printf '%s\n' 'Hidden=true'
    printf '%s\n' 'X-Mocha-Reason=Evitar applet redundante; Plasma nativo permanece ativo.'
  } > "$tmp"
  "$SUDO" install -Dm0644 "$tmp" "$file"
  rm -f "$tmp"
}

append_manual_entry() {
  doc="$1"
  [ -n "$doc" ] || return 0
  mkdir -p "$(dirname "$doc")"
  {
    printf '\n%s\n' "## ${TS} - Base de jogos e correções leves pós-auditoria"
    printf '%s\n' "Estado lido antes da alteração: NVIDIA 595.71.05 carregada no boot auditado, receita Mocha de agressividade ativa, mas Steam/MangoHud/wrapper ausentes e overrides de blueman/kmix ausentes."
    printf '%s\n' "Ação aplicada: sem mexer em boot, kernel ou driver; apenas instalou pacotes de jogos disponíveis, recriou overrides Hidden=true para blueman/kmix no usuário atual e em /etc/skel, criou MangoHud config local e wrapper limpo /home/hal/.local/bin/mocha-steam-game-run."
    printf '%s\n' "Regra preservada: nenhuma Launch Option da Steam foi alterada automaticamente. O baseline sem linha continua preservado; o wrapper fica disponível apenas para teste controlado."
    printf '%s\n' "Proibições preservadas no wrapper: sem MANGOHUD_DLSYM, sem gamescope, sem vkbasalt e sem variáveis PRIME de notebook."
  } >> "$doc"
}

need_cmd bash
need_cmd pacman
need_cmd grep
need_cmd awk
need_cmd findmnt
need_cmd tee
need_cmd install
need_cmd mktemp

[ -n "${SUDO:-}" ] || fail "sudo não encontrado."
"$SUDO" -v

FAST="/media/mochafast"
VMSTORE="/media/vmstore"
BASE="$FAST/MochaArch"
ACTIVE="$BASE/ativo"
DOC_MAIN="$ACTIVE/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md"
DOC_ALT="$ACTIVE/documentacao/manual-montagem-mochaarch.md"
DOC_EVENT="$ACTIVE/documentacao/${TS}-base-jogos-wrapper-limpo-autostarts.md"
SCRIPT_DIR="$ACTIVE/scripts"
LOG_DIR="$ACTIVE/logs"
REL_DIR="$ACTIVE/relatorios"

say "Pré-checagem: mounts obrigatórios"
findmnt "$FAST" >/dev/null 2>&1 || fail "$FAST não está montado."
findmnt "$VMSTORE" >/dev/null 2>&1 || fail "$VMSTORE não está montado."
mkdir -p "$SCRIPT_DIR" "$LOG_DIR" "$REL_DIR" "$ACTIVE/documentacao"

LOG="$LOG_DIR/${TS}-seguir-manual-base-jogos-wrapper-autostarts.log"
exec > >(tee -a "$LOG") 2>&1

say "Contexto"
printf '%s\n' "Log: $LOG"
printf '%s\n' "Usuário real: $REAL_USER"
printf '%s\n' "Home: $HOME_DIR"
printf '%s\n' "Kernel: $(uname -r)"
printf '%s\n' "Não será alterado: boot, GRUB, systemd-boot, kernel, DKMS, mkinitcpio, driver NVIDIA."

say "Conferindo pacman.conf e multilib para Steam"
PACMAN_CONF="/etc/pacman.conf"
[ -r "$PACMAN_CONF" ] || fail "não consegui ler $PACMAN_CONF"

if ! pacman -Si steam >/dev/null 2>&1; then
  say "Steam não está visível; verificando se multilib precisa ser habilitado"
  if grep -Eq '^[[:space:]]*#?[[:space:]]*\[multilib\][[:space:]]*$' "$PACMAN_CONF"; then
    BAK="/etc/pacman.conf.mocha-bak-${TS}"
    run "$SUDO" cp -a "$PACMAN_CONF" "$BAK"
    TMP_CONF="$(mktemp)"
    awk '
      BEGIN { in_multi = 0; saw_multi = 0; saw_multi_include = 0 }
      /^[[:space:]]*#?[[:space:]]*\[multilib\][[:space:]]*$/ {
        print "[multilib]"
        in_multi = 1
        saw_multi = 1
        next
      }
      in_multi && /^[[:space:]]*#?[[:space:]]*Include[[:space:]]*=[[:space:]]*\/etc\/pacman.d\/mirrorlist[[:space:]]*$/ {
        print "Include = /etc/pacman.d/mirrorlist"
        in_multi = 0
        saw_multi_include = 1
        next
      }
      { print }
      END {
        if (saw_multi == 0) {
          print ""
          print "[multilib]"
          print "Include = /etc/pacman.d/mirrorlist"
        } else if (saw_multi == 1 && saw_multi_include == 0) {
          print ""
          print "[multilib]"
          print "Include = /etc/pacman.d/mirrorlist"
        }
      }
    ' "$PACMAN_CONF" > "$TMP_CONF"
    run "$SUDO" install -m0644 "$TMP_CONF" "$PACMAN_CONF"
    rm -f "$TMP_CONF"

    say "Limpando backups excedentes de pacman.conf, mantendo no máximo 2"
    mapfile -t PAC_BAKS < <(find /etc -maxdepth 1 -type f -name 'pacman.conf.mocha-bak-*' -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR>2 {print $2}')
    if [ "${#PAC_BAKS[@]}" -gt 0 ]; then
      for old in "${PAC_BAKS[@]}"; do
        run "$SUDO" rm -f "$old"
      done
    fi

    say "Sincronizando base de pacotes após habilitar multilib"
    run "$SUDO" pacman -Sy --noconfirm
  else
    printf '%s\n' "AVISO: não encontrei bloco multilib em $PACMAN_CONF."
  fi
fi

say "Selecionando pacotes disponíveis sem remover nada"
CANDIDATES=(steam mangohud lib32-mangohud gamemode lib32-gamemode)
INSTALL_PKGS=()
for pkg in "${CANDIDATES[@]}"; do
  if pacman -Si "$pkg" >/dev/null 2>&1; then
    INSTALL_PKGS+=("$pkg")
    printf '%s\n' "OK: pacote disponível: $pkg"
  else
    printf '%s\n' "AVISO: pacote não visível no pacman atual: $pkg"
  fi
done

if [ "${#INSTALL_PKGS[@]}" -gt 0 ]; then
  say "Instalando apenas pacotes ausentes/necessários"
  run "$SUDO" pacman -S --needed --noconfirm "${INSTALL_PKGS[@]}"
else
  fail "nenhum pacote de jogos ficou disponível; verificar repositórios antes de seguir."
fi

say "Criando overrides permanentes para não duplicar Bluetooth/volume"
run mkdir -p "$HOME_DIR/.config/autostart"
write_autostart_hidden_user "$HOME_DIR/.config/autostart/blueman.desktop" "Blueman Applet" "blueman-applet"
write_autostart_hidden_user "$HOME_DIR/.config/autostart/kmix_autostart.desktop" "KMix" "kmix"
run "$SUDO" mkdir -p /etc/skel/.config/autostart
write_autostart_hidden_root "/etc/skel/.config/autostart/blueman.desktop" "Blueman Applet" "blueman-applet"
write_autostart_hidden_root "/etc/skel/.config/autostart/kmix_autostart.desktop" "KMix" "kmix"

say "Criando configuração MangoHud local do Mocha"
MANGOHUD_DIR="$HOME_DIR/.config/MangoHud"
MANGOHUD_CONF="$MANGOHUD_DIR/Mocha-MangoHud-FPS-Comparacao.conf"
run mkdir -p "$MANGOHUD_DIR"
{
  printf '%s\n' 'legacy_layout=0'
  printf '%s\n' 'horizontal'
  printf '%s\n' 'table_columns=20'
  printf '%s\n' 'fps'
  printf '%s\n' 'frametime'
  printf '%s\n' 'gpu_stats'
  printf '%s\n' 'gpu_temp'
  printf '%s\n' 'gpu_power'
  printf '%s\n' 'cpu_stats'
  printf '%s\n' 'cpu_temp'
  printf '%s\n' 'ram'
  printf '%s\n' 'vram'
  printf '%s\n' 'gamemode'
  printf '%s\n' 'vulkan_driver'
  printf '%s\n' 'wine'
  printf '%s\n' 'time'
  printf '%s\n' 'time_format=%H:%M'
} > "$MANGOHUD_CONF"
chmod 0644 "$MANGOHUD_CONF"

say "Criando wrapper limpo para teste controlado"
WRAPPER="$HOME_DIR/.local/bin/mocha-steam-game-run"
run mkdir -p "$HOME_DIR/.local/bin"
{
  printf '%s\n' '#!/usr/bin/env bash'
  printf '%s\n' 'set -Eeuo pipefail'
  printf '%s\n' ''
  printf '%s\n' 'export MANGOHUD=1'
  printf '%s\n' 'export MANGOHUD_CONFIGFILE="${MANGOHUD_CONFIGFILE:-$HOME/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf}"'
  printf '%s\n' 'unset MANGOHUD_DLSYM'
  printf '%s\n' 'unset ENABLE_VKBASALT'
  printf '%s\n' 'unset VKBASALT_CONFIG_FILE'
  printf '%s\n' 'unset __NV_PRIME_RENDER_OFFLOAD'
  printf '%s\n' 'unset __VK_LAYER_NV_optimus'
  printf '%s\n' 'unset DRI_PRIME'
  printf '%s\n' ''
  printf '%s\n' 'if [ "$#" -eq 0 ]; then'
  printf '%s\n' '  printf "%s\n" "Uso Steam Launch Options: /home/hal/.local/bin/mocha-steam-game-run %command%" >&2'
  printf '%s\n' '  exit 64'
  printf '%s\n' 'fi'
  printf '%s\n' ''
  printf '%s\n' 'if command -v gamemoderun >/dev/null 2>&1 && command -v mangohud >/dev/null 2>&1; then'
  printf '%s\n' '  exec gamemoderun mangohud "$@"'
  printf '%s\n' 'elif command -v mangohud >/dev/null 2>&1; then'
  printf '%s\n' '  exec mangohud "$@"'
  printf '%s\n' 'elif command -v gamemoderun >/dev/null 2>&1; then'
  printf '%s\n' '  exec gamemoderun "$@"'
  printf '%s\n' 'else'
  printf '%s\n' '  exec "$@"'
  printf '%s\n' 'fi'
} > "$WRAPPER"
chmod 0755 "$WRAPPER"

say "Validando wrapper contra instruções proibidas/legadas"
if grep -nE 'MANGOHUD_DLSYM=1|gamescope|vkbasalt|prime-run|__NV_PRIME_RENDER_OFFLOAD=1|__VK_LAYER_NV_optimus=NVIDIA_only' "$WRAPPER"; then
  fail "wrapper contém instrução proibida ou legada."
fi

say "Registrando documentação sem acumular lixo"
append_manual_entry "$DOC_MAIN"
append_manual_entry "$DOC_ALT"
{
  printf '%s\n' "# ${TS} - Base de jogos, wrapper limpo e autostarts permanentes"
  printf '%s\n' ""
  printf '%s\n' "Este registro foi criado após auditoria pós-congelamento."
  printf '%s\n' "Não houve alteração de boot, kernel, DKMS, mkinitcpio, NVIDIA ou gerenciador de login."
  printf '%s\n' "Foram aplicadas apenas correções leves e reversíveis: pacotes de jogos disponíveis, autostarts Hidden=true para blueman/kmix, MangoHud config e wrapper limpo."
  printf '%s\n' "Launch Options não foram alteradas automaticamente."
} > "$DOC_EVENT"

say "Salvando cópia reutilizável deste script"
SELF_TARGET="$SCRIPT_DIR/${TS}-seguir-manual-base-jogos-wrapper-autostarts.sh"
run install -m0755 "$0" "$SELF_TARGET"

say "Validação final"
printf '%s\n' "Pacotes:"
pacman -Q steam mangohud lib32-mangohud gamemode lib32-gamemode 2>/dev/null || true

printf '\n%s\n' "Autostarts:"
for f in "$HOME_DIR/.config/autostart/blueman.desktop" "$HOME_DIR/.config/autostart/kmix_autostart.desktop" "/etc/skel/.config/autostart/blueman.desktop" "/etc/skel/.config/autostart/kmix_autostart.desktop"; do
  printf '%s\n' "$f"
  grep -nE '^(Name|Exec|Hidden|X-Mocha-Reason)=' "$f" || true
done

printf '\n%s\n' "Wrapper:"
ls -l "$WRAPPER"
sed -n '1,80p' "$WRAPPER"

printf '\n%s\n' "MangoHud config:"
sed -n '1,80p' "$MANGOHUD_CONF"

printf '\n%s\n' "Documentos atualizados:"
printf '%s\n' "$DOC_MAIN"
printf '%s\n' "$DOC_ALT"
printf '%s\n' "$DOC_EVENT"

printf '\n%s\n' "Script salvo:"
printf '%s\n' "$SELF_TARGET"

printf '\n%s\n' "Próximo teste manual opcional na Steam, sem aplicar automaticamente:"
printf '%s\n' "/home/hal/.local/bin/mocha-steam-game-run %command%"
