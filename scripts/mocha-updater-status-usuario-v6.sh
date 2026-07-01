#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ROOT="/media/mochafast/MochaArch"
APP="$ROOT/apps/mocha-updater"
STAMP="$(date +%Y%m%d-%H%M%S)"

ok() { printf '[OK] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

[ -d "$APP" ] || fail "Pasta não encontrada: $APP"
[ -f "$APP/Cargo.toml" ] || fail "Cargo.toml não encontrado: $APP/Cargo.toml"
command -v cargo >/dev/null 2>&1 || fail "cargo/rust não encontrado"

cd "$APP"

[ -f src/main.rs ] && cp -a src/main.rs "src/main.rs.bak-status-usuario-v6-$STAMP"

sudo install -d -m 0755 /usr/local/lib/mocha-updater
sudo install -d -m 0755 /var/lib/mocha-updater/snapshots
sudo install -d -m 0755 /var/log/mocha-updater

cat > /tmp/mocha-updater-root.$$ <<'MOCHA_ROOT'
#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ACTION="${1:-help}"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="/var/log/mocha-updater"
SNAP_BASE="/var/lib/mocha-updater/snapshots"
LOG="$LOG_DIR/${ACTION}-${STAMP}.log"

mkdir -p "$LOG_DIR" "$SNAP_BASE"
touch "$LOG"
chmod 0644 "$LOG"

exec > >(tee -a "$LOG") 2>&1

ui() {
  printf 'MOCHA_UI|%s|%s\n' "$1" "${2:-}"
}

trap 'rc=$?; ui ERROR "failed"; echo "[ERRO] ação falhou. Código: $rc"; echo "Log: $LOG"; chmod -R a+rX "$LOG_DIR" "$SNAP_BASE" 2>/dev/null || true; exit $rc' ERR
trap 'chmod -R a+rX "$LOG_DIR" "$SNAP_BASE" 2>/dev/null || true' EXIT

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

pkg_available() {
  timeout 20 pacman -Si "$1" >/dev/null 2>&1
}

count_pacman_updates() {
  pacman -Qu 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l
}

count_flatpak_updates() {
  if ! cmd_exists flatpak; then
    echo 0
    return 0
  fi

  {
    flatpak remote-ls --system --updates 2>/dev/null || true

    local user
    user="$(detect_user || true)"
    if [ -n "$user" ] && id "$user" >/dev/null 2>&1; then
      runuser -u "$user" -- flatpak remote-ls --user --updates 2>/dev/null || true
    fi
  } | sed '/^[[:space:]]*$/d' | wc -l
}

emit_update_summary() {
  ui STATUS "checking_updates"

  local pac_count flat_count
  pac_count="$(count_pacman_updates || echo 0)"
  flat_count="$(count_flatpak_updates || echo 0)"

  printf 'MOCHA_UI|SUMMARY|%s|%s\n' "$pac_count" "$flat_count"

  pacman -Qu 2>/dev/null | head -30 | while IFS= read -r line; do
    [ -n "$line" ] && printf 'MOCHA_UI|ITEM|Pacman: %s\n' "$line"
  done

  if cmd_exists flatpak; then
    flatpak remote-ls --system --updates 2>/dev/null | head -30 | while IFS= read -r line; do
      [ -n "$line" ] && printf 'MOCHA_UI|ITEM|Flatpak system: %s\n' "$line"
    done

    local user
    user="$(detect_user || true)"
    if [ -n "$user" ] && id "$user" >/dev/null 2>&1; then
      runuser -u "$user" -- flatpak remote-ls --user --updates 2>/dev/null | head -30 | while IFS= read -r line; do
        [ -n "$line" ] && printf 'MOCHA_UI|ITEM|Flatpak user: %s\n' "$line"
      done
    fi
  fi
}

pacman_lock_wait() {
  ui STATUS "checking_pacman_lock"

  for _ in $(seq 1 120); do
    if [ ! -e /var/lib/pacman/db.lck ]; then
      echo "[OK] pacman livre"
      return 0
    fi

    echo "[AVISO] pacman ocupado; aguardando..."
    sleep 3
  done

  echo "[ERRO] /var/lib/pacman/db.lck continua presente"
  exit 1
}

detect_user() {
  if [ -n "${SUDO_USER:-}" ] && id "$SUDO_USER" >/dev/null 2>&1; then
    echo "$SUDO_USER"
    return 0
  fi

  if [ -n "${PKEXEC_UID:-}" ]; then
    getent passwd "$PKEXEC_UID" | cut -d: -f1
    return 0
  fi

  who | awk 'NR==1 {print $1}'
}

run_capture() {
  local file="$1"
  shift
  bash -lc "$*" > "$file" 2>&1 || true
}

snapshot() {
  ui STATUS "creating_backup"

  local snap="$SNAP_BASE/$STAMP"
  mkdir -p "$snap"

  run_capture "$snap/uname.txt" "uname -a"
  run_capture "$snap/os-release.txt" "cat /etc/os-release"
  run_capture "$snap/pacman-explicit.txt" "pacman -Qqe"
  run_capture "$snap/pacman-native.txt" "pacman -Qqn"
  run_capture "$snap/pacman-foreign.txt" "pacman -Qqm"
  run_capture "$snap/pacman-updates.txt" "pacman -Qu"
  run_capture "$snap/pacman-repos.txt" "grep -nE '^[[]|^Include|^Server' /etc/pacman.conf /etc/pacman.d/*.conf 2>/dev/null || true"
  run_capture "$snap/kernels.txt" "pacman -Qq | grep -E '^(linux|linux-lts|linux-zen|linux-cachyos|nvidia)' || true"
  run_capture "$snap/gpu.txt" "lspci 2>/dev/null | grep -Ei 'vga|3d|display|nvidia|amd|intel' || true"
  run_capture "$snap/nvidia-smi.txt" "timeout 8 nvidia-smi 2>/dev/null || true"
  run_capture "$snap/flatpak-system.txt" "flatpak list --system --app --columns=application,version,branch,origin 2>/dev/null || true"

  local user
  user="$(detect_user || true)"

  if [ -n "$user" ] && id "$user" >/dev/null 2>&1 && cmd_exists flatpak; then
    runuser -u "$user" -- flatpak list --user --app --columns=application,version,branch,origin > "$snap/flatpak-user.txt" 2>&1 || true
  fi

  tar -C /etc -czf "$snap/etc-pacman.tgz" pacman.conf pacman.d 2>/dev/null || true

  printf 'MOCHA_UI|ITEM|Backup criado: %s\n' "$snap"
  echo "[OK] Snapshot criado: $snap"
}

refresh_mirrors_if_possible() {
  ui STATUS "checking_mirrors"

  if cmd_exists reflector && [ -f /etc/pacman.d/mirrorlist ]; then
    cp -a /etc/pacman.d/mirrorlist "/etc/pacman.d/mirrorlist.mocha-backup-$STAMP"

    if reflector --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist; then
      echo "[OK] mirrorlist atualizada com reflector"
    else
      echo "[AVISO] reflector falhou; restaurando mirrorlist anterior"
      cp -a "/etc/pacman.d/mirrorlist.mocha-backup-$STAMP" /etc/pacman.d/mirrorlist
    fi
  else
    echo "[AVISO] reflector não instalado; mantendo mirrors atuais"
  fi
}

flatpak_update_all() {
  ui STATUS "updating_flatpaks"

  if ! cmd_exists flatpak; then
    echo "[AVISO] flatpak não instalado"
    return 0
  fi

  flatpak update --system -y || true

  local user
  user="$(detect_user || true)"

  if [ -n "$user" ] && id "$user" >/dev/null 2>&1; then
    runuser -u "$user" -- flatpak update --user -y || true
  fi
}

preview() {
  emit_update_summary
  ui DONE "preview_done"
}

update_system() {
  pacman_lock_wait
  emit_update_summary
  snapshot
  refresh_mirrors_if_possible

  ui STATUS "updating_keyring"
  pacman -Sy --needed --noconfirm archlinux-keyring || true

  ui STATUS "installing_system_updates"
  pacman -Syu --noconfirm

  flatpak_update_all

  ui STATUS "finalizing"
  ui DONE "system_updated"
}

has_nvidia() {
  lspci 2>/dev/null | grep -Eiq 'nvidia' && return 0
  pacman -Qq 2>/dev/null | grep -Eq '^nvidia' && return 0
  return 1
}

uses_nvidia_open() {
  pacman -Qq 2>/dev/null | grep -Eq '^nvidia-open' && return 0
  return 1
}

pick_pkg() {
  local p

  for p in "$@"; do
    if pkg_available "$p"; then
      echo "$p"
      return 0
    fi
  done

  return 1
}

recommend_kernel() {
  if has_nvidia && pkg_available linux-cachyos; then
    echo "cachy"
  elif pkg_available linux-zen; then
    echo "zen"
  elif pkg_available linux-lts; then
    echo "lts"
  else
    echo "none"
  fi
}

driver_pkg_for_target() {
  local target="$1"

  if ! has_nvidia; then
    return 0
  fi

  case "$target" in
    cachy)
      if uses_nvidia_open; then
        pick_pkg linux-cachyos-nvidia-open linux-cachyos-nvidia nvidia-open-dkms nvidia-dkms
      else
        pick_pkg linux-cachyos-nvidia linux-cachyos-nvidia-open nvidia-dkms nvidia-open-dkms
      fi
      ;;
    zen)
      if uses_nvidia_open; then
        pick_pkg nvidia-open-dkms nvidia-dkms
      else
        pick_pkg nvidia-dkms nvidia-open-dkms
      fi
      ;;
    lts)
      if uses_nvidia_open; then
        pick_pkg nvidia-open-dkms nvidia-dkms nvidia-lts
      else
        pick_pkg nvidia-lts nvidia-dkms nvidia-open-dkms
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

test_kernel() {
  ui STATUS "checking_kernel"

  echo "CPU:"
  grep -m1 '^model name' /proc/cpuinfo 2>/dev/null || true

  echo
  echo "GPU:"
  lspci 2>/dev/null | grep -Ei 'vga|3d|display' || true

  echo
  echo "Driver NVIDIA:"
  timeout 8 nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || true

  local target driver
  target="$(recommend_kernel)"
  driver="$(driver_pkg_for_target "$target" || true)"

  printf 'MOCHA_UI|ITEM|Kernel recomendado: %s\n' "$target"
  printf 'MOCHA_UI|ITEM|Driver recomendado: %s\n' "${driver:-nenhum/indisponível}"

  ui DONE "kernel_checked"
}

apply_kernel_driver() {
  pacman_lock_wait
  snapshot

  local target
  target="$(recommend_kernel)"

  ui STATUS "installing_kernel"

  local pkgs=()

  case "$target" in
    cachy)
      pkg_available linux-cachyos || {
        echo "[ERRO] linux-cachyos não está disponível nos repositórios atuais"
        echo "[ERRO] Nenhum repo CachyOS será adicionado automaticamente"
        exit 1
      }

      pkgs+=(linux-cachyos)
      pkg_available linux-cachyos-headers && pkgs+=(linux-cachyos-headers)
      ;;
    zen)
      pkg_available linux-zen || {
        echo "[ERRO] linux-zen não disponível"
        exit 1
      }

      pkgs+=(linux-zen)
      pkg_available linux-zen-headers && pkgs+=(linux-zen-headers)
      ;;
    lts)
      pkg_available linux-lts || {
        echo "[ERRO] linux-lts não disponível"
        exit 1
      }

      pkgs+=(linux-lts)
      pkg_available linux-lts-headers && pkgs+=(linux-lts-headers)
      ;;
    *)
      echo "[ERRO] Nenhum kernel recomendado disponível"
      exit 1
      ;;
  esac

  if has_nvidia; then
    local drv
    drv="$(driver_pkg_for_target "$target" || true)"

    if [ -z "$drv" ]; then
      echo "[ERRO] GPU NVIDIA detectada, mas não achei pacote de driver compatível nos repositórios atuais"
      echo "[ERRO] Nada será instalado para evitar kernel sem módulo NVIDIA"
      exit 1
    fi

    pkgs+=("$drv")
    pkg_available dkms && pkgs+=(dkms)
  fi

  printf 'MOCHA_UI|ITEM|Pacotes: %s\n' "${pkgs[*]}"

  pacman -Sy --needed --noconfirm archlinux-keyring || true
  pacman -S --needed --noconfirm "${pkgs[@]}"

  ui STATUS "finalizing_kernel"

  if cmd_exists mkinitcpio; then
    mkinitcpio -P || true
  fi

  if [ -f /boot/grub/grub.cfg ] && cmd_exists grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif [ -d /boot/loader ] && cmd_exists bootctl; then
    bootctl update || true
  else
    echo "[AVISO] bootloader não detectado automaticamente; verifique entrada de boot"
  fi

  ui DONE "kernel_installed"
}

case "$ACTION" in
  preview)
    preview
    ;;
  update)
    update_system
    ;;
  backup)
    snapshot
    ui DONE "backup_done"
    ;;
  test-kernel)
    test_kernel
    ;;
  apply-kernel)
    apply_kernel_driver
    ;;
  *)
    echo "Uso: mocha-updater-root {preview|update|backup|test-kernel|apply-kernel}"
    exit 2
    ;;
esac

echo "Log: $LOG"
MOCHA_ROOT

sudo install -Dm755 /tmp/mocha-updater-root.$$ /usr/local/lib/mocha-updater/mocha-updater-root
rm -f /tmp/mocha-updater-root.$$

sudo tee /usr/share/polkit-1/actions/org.mocha.updater.policy >/dev/null <<'MOCHA_POLICY'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>
  <vendor>Mocha</vendor>

  <action id="org.mocha.updater.root">
    <description>Run Mocha Updater system actions</description>
    <description xml:lang="pt_BR">Executar ações de sistema do Mocha Updater</description>
    <message>Authentication is required to update the system, create snapshots or install kernel and driver packages.</message>
    <message xml:lang="pt_BR">Autenticação necessária para atualizar o sistema, criar snapshots ou instalar kernel e driver.</message>
    <defaults>
      <allow_any>auth_admin</allow_any>
      <allow_inactive>auth_admin</allow_inactive>
      <allow_active>auth_admin_keep</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/usr/local/lib/mocha-updater/mocha-updater-root</annotate>
  </action>
</policyconfig>
MOCHA_POLICY

sudo chmod 0644 /usr/share/polkit-1/actions/org.mocha.updater.policy

cat > src/main.rs <<'MOCHA_RUST'
use eframe::egui;
use egui::{Color32, RichText, Stroke};
use std::env;
use std::fs;
use std::io::{BufRead, BufReader};
use std::process::{Command, Stdio};
use std::sync::mpsc::{self, Receiver};
use std::thread;

#[derive(Clone, Copy, PartialEq, Eq)]
enum Lang {
    Pt,
    En,
    Fr,
    Es,
}

impl Lang {
    fn detect() -> Self {
        let raw = env::var("LC_ALL")
            .ok()
            .filter(|v| !v.trim().is_empty())
            .or_else(|| env::var("LC_MESSAGES").ok().filter(|v| !v.trim().is_empty()))
            .or_else(|| env::var("LANG").ok().filter(|v| !v.trim().is_empty()))
            .unwrap_or_else(|| "en".to_string());

        let lower = raw.to_lowercase();

        if lower.starts_with("pt") {
            Lang::Pt
        } else if lower.starts_with("fr") {
            Lang::Fr
        } else if lower.starts_with("es") {
            Lang::Es
        } else {
            Lang::En
        }
    }

    fn code(self) -> &'static str {
        match self {
            Lang::Pt => "pt",
            Lang::En => "en",
            Lang::Fr => "fr",
            Lang::Es => "es",
        }
    }

    fn t(self, key: &'static str) -> &'static str {
        match self {
            Lang::Pt => match key {
                "subtitle" => "Atualização real sem terminal. Clique e acompanhe o resultado.",
                "general" => "Atualização",
                "kernel" => "Kernel + Driver",
                "backup" => "Backup",
                "details" => "Detalhes",
                "settings" => "Configurações",
                "about" => "Sobre",
                "available" => "Atualizações disponíveis",
                "current_status" => "Status atual",
                "result" => "Resultado",
                "system" => "Sistema",
                "actions" => "Ações",
                "ready" => "Pronto.",
                "running" => "Executando",
                "done" => "Concluído",
                "failed" => "Falhou",
                "cpu" => "CPU",
                "gpu" => "GPU",
                "current_kernel" => "Kernel atual",
                "driver" => "Driver",
                "distro" => "Distribuição",
                "pacman" => "Pacman",
                "flatpak" => "Flatpak",
                "recommendation" => "Recomendação",
                "unknown" => "Não detectado",
                "preview" => "Ver atualizações",
                "preview_sub" => "Lista o que está disponível",
                "update" => "Atualizar agora",
                "update_sub" => "Instala Pacman + Flatpak",
                "test_kernel" => "Testar kernel",
                "test_kernel_sub" => "Detecta hardware",
                "backup_now" => "Criar backup",
                "backup_sub" => "Salva estado atual",
                "apply_kernel" => "Aplicar Kernel + Driver",
                "apply_kernel_sub" => "Instala recomendado",
                "auth_hint" => "Se pedir senha, é a autorização administrativa do sistema.",
                "technical_details" => "Detalhes técnicos",
                "no_details" => "Nenhum detalhe técnico ainda.",
                "settings_body" => "Idiomas suportados: português, inglês, francês e espanhol. Outros idiomas usam inglês.",
                "about_body" => "Mocha Updater executa atualização real em segundo plano com Polkit. O usuário vê status simples e resultado final.",
                _ => Lang::En.t(key),
            },
            Lang::En => match key {
                "subtitle" => "Real updates without terminal. Click and follow the result.",
                "general" => "Update",
                "kernel" => "Kernel + Driver",
                "backup" => "Backup",
                "details" => "Details",
                "settings" => "Settings",
                "about" => "About",
                "available" => "Available updates",
                "current_status" => "Current status",
                "result" => "Result",
                "system" => "System",
                "actions" => "Actions",
                "ready" => "Ready.",
                "running" => "Running",
                "done" => "Done",
                "failed" => "Failed",
                "cpu" => "CPU",
                "gpu" => "GPU",
                "current_kernel" => "Current kernel",
                "driver" => "Driver",
                "distro" => "Distribution",
                "pacman" => "Pacman",
                "flatpak" => "Flatpak",
                "recommendation" => "Recommendation",
                "unknown" => "Not detected",
                "preview" => "Check updates",
                "preview_sub" => "Lists what is available",
                "update" => "Update now",
                "update_sub" => "Installs Pacman + Flatpak",
                "test_kernel" => "Test kernel",
                "test_kernel_sub" => "Detects hardware",
                "backup_now" => "Create backup",
                "backup_sub" => "Saves current state",
                "apply_kernel" => "Apply Kernel + Driver",
                "apply_kernel_sub" => "Installs recommended",
                "auth_hint" => "If it asks for a password, that is system administrator authorization.",
                "technical_details" => "Technical details",
                "no_details" => "No technical details yet.",
                "settings_body" => "Supported languages: Portuguese, English, French and Spanish. Other languages use English.",
                "about_body" => "Mocha Updater performs real background updates through Polkit. The user sees simple status and final result.",
                _ => key,
            },
            Lang::Fr => match key {
                "subtitle" => "Mises à jour réelles sans terminal. Cliquez et suivez le résultat.",
                "general" => "Mise à jour",
                "kernel" => "Noyau + Pilote",
                "backup" => "Sauvegarde",
                "details" => "Détails",
                "settings" => "Paramètres",
                "about" => "À propos",
                "available" => "Mises à jour disponibles",
                "current_status" => "État actuel",
                "result" => "Résultat",
                "system" => "Système",
                "actions" => "Actions",
                "ready" => "Prêt.",
                "running" => "Exécution",
                "done" => "Terminé",
                "failed" => "Échec",
                "cpu" => "CPU",
                "gpu" => "GPU",
                "current_kernel" => "Noyau actuel",
                "driver" => "Pilote",
                "distro" => "Distribution",
                "pacman" => "Pacman",
                "flatpak" => "Flatpak",
                "recommendation" => "Recommandation",
                "unknown" => "Non détecté",
                "preview" => "Voir mises à jour",
                "preview_sub" => "Liste ce qui est disponible",
                "update" => "Mettre à jour",
                "update_sub" => "Installe Pacman + Flatpak",
                "test_kernel" => "Tester noyau",
                "test_kernel_sub" => "Détecte matériel",
                "backup_now" => "Créer sauvegarde",
                "backup_sub" => "Sauve l'état actuel",
                "apply_kernel" => "Appliquer Noyau + Pilote",
                "apply_kernel_sub" => "Installe recommandé",
                "auth_hint" => "Si un mot de passe est demandé, c'est l'autorisation administrateur.",
                "technical_details" => "Détails techniques",
                "no_details" => "Aucun détail technique.",
                "settings_body" => "Langues prises en charge : portugais, anglais, français et espagnol.",
                "about_body" => "Mocha Updater exécute des mises à jour réelles en arrière-plan via Polkit.",
                _ => Lang::En.t(key),
            },
            Lang::Es => match key {
                "subtitle" => "Actualización real sin terminal. Haga clic y siga el resultado.",
                "general" => "Actualización",
                "kernel" => "Kernel + Controlador",
                "backup" => "Copia",
                "details" => "Detalles",
                "settings" => "Configuración",
                "about" => "Acerca de",
                "available" => "Actualizaciones disponibles",
                "current_status" => "Estado actual",
                "result" => "Resultado",
                "system" => "Sistema",
                "actions" => "Acciones",
                "ready" => "Listo.",
                "running" => "Ejecutando",
                "done" => "Concluido",
                "failed" => "Falló",
                "cpu" => "CPU",
                "gpu" => "GPU",
                "current_kernel" => "Kernel actual",
                "driver" => "Controlador",
                "distro" => "Distribución",
                "pacman" => "Pacman",
                "flatpak" => "Flatpak",
                "recommendation" => "Recomendación",
                "unknown" => "No detectado",
                "preview" => "Ver actualizaciones",
                "preview_sub" => "Lista lo disponible",
                "update" => "Actualizar ahora",
                "update_sub" => "Instala Pacman + Flatpak",
                "test_kernel" => "Probar kernel",
                "test_kernel_sub" => "Detecta hardware",
                "backup_now" => "Crear copia",
                "backup_sub" => "Guarda estado actual",
                "apply_kernel" => "Aplicar Kernel + Controlador",
                "apply_kernel_sub" => "Instala recomendado",
                "auth_hint" => "Si pide contraseña, es la autorización administrativa.",
                "technical_details" => "Detalles técnicos",
                "no_details" => "Sin detalles técnicos.",
                "settings_body" => "Idiomas soportados: portugués, inglés, francés y español.",
                "about_body" => "Mocha Updater ejecuta actualizaciones reales en segundo plano vía Polkit.",
                _ => Lang::En.t(key),
            },
        }
    }

    fn stage(self, code: &str) -> String {
        match self {
            Lang::Pt => match code {
                "checking_updates" => "Verificando atualizações disponíveis...".to_string(),
                "checking_pacman_lock" => "Verificando se o gerenciador de pacotes está livre...".to_string(),
                "creating_backup" => "Criando backup antes de alterar o sistema...".to_string(),
                "checking_mirrors" => "Verificando mirrors de download...".to_string(),
                "updating_keyring" => "Atualizando chaves do sistema...".to_string(),
                "installing_system_updates" => "Instalando atualizações do sistema...".to_string(),
                "updating_flatpaks" => "Atualizando aplicativos Flatpak...".to_string(),
                "finalizing" => "Finalizando atualização...".to_string(),
                "checking_kernel" => "Detectando hardware e kernel recomendado...".to_string(),
                "installing_kernel" => "Instalando kernel e driver recomendados...".to_string(),
                "finalizing_kernel" => "Finalizando kernel e bootloader...".to_string(),
                _ => code.to_string(),
            },
            Lang::En => match code {
                "checking_updates" => "Checking available updates...".to_string(),
                "checking_pacman_lock" => "Checking package manager lock...".to_string(),
                "creating_backup" => "Creating backup before changing the system...".to_string(),
                "checking_mirrors" => "Checking download mirrors...".to_string(),
                "updating_keyring" => "Updating system keys...".to_string(),
                "installing_system_updates" => "Installing system updates...".to_string(),
                "updating_flatpaks" => "Updating Flatpak applications...".to_string(),
                "finalizing" => "Finalizing update...".to_string(),
                "checking_kernel" => "Detecting hardware and recommended kernel...".to_string(),
                "installing_kernel" => "Installing recommended kernel and driver...".to_string(),
                "finalizing_kernel" => "Finalizing kernel and bootloader...".to_string(),
                _ => code.to_string(),
            },
            _ => Lang::En.stage(code),
        }
    }

    fn done(self, code: &str) -> String {
        match self {
            Lang::Pt => match code {
                "preview_done" => "Verificação concluída.".to_string(),
                "system_updated" => "Atualização instalada com sucesso.".to_string(),
                "backup_done" => "Backup criado com sucesso.".to_string(),
                "kernel_checked" => "Teste de kernel concluído.".to_string(),
                "kernel_installed" => "Kernel e driver instalados com sucesso. Reinicie para usar o novo kernel.".to_string(),
                _ => "Concluído.".to_string(),
            },
            Lang::En => match code {
                "preview_done" => "Check completed.".to_string(),
                "system_updated" => "Update installed successfully.".to_string(),
                "backup_done" => "Backup created successfully.".to_string(),
                "kernel_checked" => "Kernel test completed.".to_string(),
                "kernel_installed" => "Kernel and driver installed successfully. Reboot to use the new kernel.".to_string(),
                _ => "Done.".to_string(),
            },
            _ => Lang::En.done(code),
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Tab {
    General,
    Kernel,
    Backup,
    Details,
    Settings,
    About,
}

enum RunnerMsg {
    Ui(String),
    Raw(String),
    Done(i32),
}

struct Runner {
    action: String,
    rx: Receiver<RunnerMsg>,
}

struct SystemInfo {
    cpu: String,
    gpu: String,
    kernel: String,
    driver: String,
    distro: String,
    pacman_pending: usize,
    flatpak_pending: usize,
    recommendation: String,
}

impl SystemInfo {
    fn collect(lang: Lang) -> Self {
        let unknown = lang.t("unknown").to_string();

        let cpu = first_cpu().unwrap_or_else(|| unknown.clone());

        let gpu = shell("lspci 2>/dev/null | grep -Ei 'vga|3d|display' | head -1 || true")
            .filter(|s| !s.trim().is_empty())
            .unwrap_or_else(|| unknown.clone());

        let kernel = cmd("uname", &["-r"]).unwrap_or_else(|| unknown.clone());

        let driver = shell("nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 || true")
            .filter(|s| !s.trim().is_empty())
            .map(|s| format!("NVIDIA {}", s.trim()))
            .unwrap_or_else(|| unknown.clone());

        let distro = os_pretty_name().unwrap_or_else(|| unknown.clone());
        let pacman_pending = shell_count("pacman -Qu 2>/dev/null || true");
        let flatpak_pending = shell_count("flatpak remote-ls --updates 2>/dev/null || true");
        let recommendation = local_recommendation();

        Self {
            cpu,
            gpu,
            kernel,
            driver,
            distro,
            pacman_pending,
            flatpak_pending,
            recommendation,
        }
    }
}

struct MochaUpdater {
    lang: Lang,
    tab: Tab,
    info: SystemInfo,
    user_events: Vec<String>,
    technical_logs: Vec<String>,
    runner: Option<Runner>,
    status: String,
    result: String,
}

impl MochaUpdater {
    fn new(cc: &eframe::CreationContext<'_>) -> Self {
        apply_visuals(&cc.egui_ctx);

        let lang = Lang::detect();
        let info = SystemInfo::collect(lang);

        Self {
            lang,
            tab: Tab::General,
            info,
            user_events: vec![lang.t("ready").to_string()],
            technical_logs: Vec::new(),
            runner: None,
            status: lang.t("ready").to_string(),
            result: String::new(),
        }
    }

    fn running(&self) -> bool {
        self.runner.is_some()
    }

    fn push_user(&mut self, msg: String) {
        self.user_events.push(msg);

        if self.user_events.len() > 80 {
            let drop_count = self.user_events.len().saturating_sub(80);
            self.user_events.drain(0..drop_count);
        }
    }

    fn push_technical(&mut self, msg: String) {
        self.technical_logs.push(msg);

        if self.technical_logs.len() > 1000 {
            let drop_count = self.technical_logs.len().saturating_sub(1000);
            self.technical_logs.drain(0..drop_count);
        }
    }

    fn refresh(&mut self) {
        self.info = SystemInfo::collect(self.lang);
    }

    fn handle_ui_line(&mut self, line: &str) {
        let parts: Vec<&str> = line.splitn(4, '|').collect();

        if parts.len() < 3 {
            return;
        }

        let kind = parts[1];

        match kind {
            "STATUS" => {
                let msg = self.lang.stage(parts[2]);
                self.status = msg.clone();
                self.push_user(msg);
            }
            "SUMMARY" => {
                let pacman = parts.get(2).and_then(|v| v.parse::<usize>().ok()).unwrap_or(0);
                let flatpak = parts.get(3).and_then(|v| v.parse::<usize>().ok()).unwrap_or(0);

                self.info.pacman_pending = pacman;
                self.info.flatpak_pending = flatpak;

                let msg = match self.lang {
                    Lang::Pt => format!("Atualizações disponíveis: Pacman: {}, Flatpak: {}.", pacman, flatpak),
                    Lang::En => format!("Available updates: Pacman: {}, Flatpak: {}.", pacman, flatpak),
                    Lang::Fr => format!("Mises à jour disponibles : Pacman : {}, Flatpak : {}.", pacman, flatpak),
                    Lang::Es => format!("Actualizaciones disponibles: Pacman: {}, Flatpak: {}.", pacman, flatpak),
                };

                self.status = msg.clone();
                self.push_user(msg);
            }
            "ITEM" => {
                if let Some(v) = parts.get(2) {
                    self.push_user((*v).to_string());
                }
            }
            "DONE" => {
                let msg = self.lang.done(parts[2]);
                self.status = msg.clone();
                self.result = msg.clone();
                self.push_user(msg);
            }
            "ERROR" => {
                let msg = match self.lang {
                    Lang::Pt => "A ação falhou. Veja Detalhes técnicos.".to_string(),
                    Lang::En => "The action failed. See technical details.".to_string(),
                    Lang::Fr => "L'action a échoué. Voir les détails techniques.".to_string(),
                    Lang::Es => "La acción falló. Vea detalles técnicos.".to_string(),
                };

                self.status = msg.clone();
                self.result = msg.clone();
                self.push_user(msg);
            }
            _ => {}
        }
    }

    fn poll_runner(&mut self) {
        let mut finished_code: Option<i32> = None;
        let mut drained = Vec::new();

        if let Some(runner) = &self.runner {
            while let Ok(msg) = runner.rx.try_recv() {
                drained.push(msg);
            }
        }

        for msg in drained {
            match msg {
                RunnerMsg::Ui(line) => self.handle_ui_line(&line),
                RunnerMsg::Raw(line) => self.push_technical(line),
                RunnerMsg::Done(code) => finished_code = Some(code),
            }
        }

        if let Some(code) = finished_code {
            let action = self.runner.as_ref().map(|r| r.action.clone()).unwrap_or_default();
            self.runner = None;

            if code != 0 {
                let msg = match self.lang {
                    Lang::Pt => format!("Falhou: {}.", action),
                    Lang::En => format!("Failed: {}.", action),
                    Lang::Fr => format!("Échec : {}.", action),
                    Lang::Es => format!("Falló: {}.", action),
                };

                self.status = msg.clone();
                self.result = msg.clone();
                self.push_user(msg);
            }

            self.refresh();
        }
    }

    fn start_action(&mut self, action: &str) {
        if self.running() {
            return;
        }

        let safe = match action {
            "preview" => "preview",
            "update" => "update",
            "backup" => "backup",
            "test-kernel" => "test-kernel",
            "apply-kernel" => "apply-kernel",
            _ => "preview",
        }
        .to_string();

        let (tx, rx) = mpsc::channel::<RunnerMsg>();

        self.status = format!("{}: {}", self.lang.t("running"), safe);
        self.result.clear();
        self.push_user(self.status.clone());

        thread::spawn(move || {
            let spawn = Command::new("pkexec")
                .arg("/usr/local/lib/mocha-updater/mocha-updater-root")
                .arg(&safe)
                .stdout(Stdio::piped())
                .stderr(Stdio::null())
                .spawn();

            let mut child = match spawn {
                Ok(child) => child,
                Err(err) => {
                    let _ = tx.send(RunnerMsg::Ui("MOCHA_UI|ERROR|failed".to_string()));
                    let _ = tx.send(RunnerMsg::Raw(format!("[ERRO] falha ao iniciar ação: {}", err)));
                    let _ = tx.send(RunnerMsg::Done(127));
                    return;
                }
            };

            if let Some(stdout) = child.stdout.take() {
                let reader = BufReader::new(stdout);

                for line in reader.lines() {
                    match line {
                        Ok(line) => {
                            if line.starts_with("MOCHA_UI|") {
                                let _ = tx.send(RunnerMsg::Ui(line));
                            } else {
                                let _ = tx.send(RunnerMsg::Raw(line));
                            }
                        }
                        Err(err) => {
                            let _ = tx.send(RunnerMsg::Raw(format!("[ERRO] leitura de saída: {}", err)));
                        }
                    }
                }
            }

            let code = child.wait().ok().and_then(|s| s.code()).unwrap_or(1);
            let _ = tx.send(RunnerMsg::Done(code));
        });

        self.runner = Some(Runner {
            action: action.to_string(),
            rx,
        });
    }
}

impl eframe::App for MochaUpdater {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        apply_visuals(ctx);
        self.poll_runner();

        if self.running() {
            ctx.request_repaint_after(std::time::Duration::from_millis(250));
        }

        egui::TopBottomPanel::top("top")
            .exact_height(96.0)
            .frame(egui::Frame::none().fill(mocha_panel()).stroke(Stroke::new(1.0, mocha_border())))
            .show(ctx, |ui| {
                ui.add_space(8.0);

                ui.horizontal_wrapped(|ui| {
                    ui.label(RichText::new("☕").size(30.0).color(mocha_orange()));

                    ui.vertical(|ui| {
                        ui.label(RichText::new("Mocha Updater").size(25.0).color(mocha_title()));
                        ui.label(RichText::new(self.lang.t("subtitle")).size(13.0).color(mocha_orange()));
                    });

                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        if self.running() {
                            ui.spinner();
                        }

                        ui.label(RichText::new(&self.status).size(14.0).color(mocha_text()).strong());
                    });
                });

                ui.add_space(8.0);

                ui.horizontal_wrapped(|ui| {
                    tab_button(ui, &mut self.tab, Tab::General, self.lang.t("general"));
                    tab_button(ui, &mut self.tab, Tab::Kernel, self.lang.t("kernel"));
                    tab_button(ui, &mut self.tab, Tab::Backup, self.lang.t("backup"));
                    tab_button(ui, &mut self.tab, Tab::Details, self.lang.t("details"));
                    tab_button(ui, &mut self.tab, Tab::Settings, self.lang.t("settings"));
                    tab_button(ui, &mut self.tab, Tab::About, self.lang.t("about"));
                });
            });

        egui::CentralPanel::default()
            .frame(egui::Frame::none().fill(mocha_bg()))
            .show(ctx, |ui| {
                egui::ScrollArea::vertical()
                    .auto_shrink([false, false])
                    .show(ui, |ui| {
                        ui.add_space(14.0);

                        match self.tab {
                            Tab::General => self.ui_general(ui),
                            Tab::Kernel => self.ui_text(ui, self.lang.t("kernel"), "Kernel + Driver usa a recomendação detectada e instala apenas pacotes disponíveis nos repositórios configurados."),
                            Tab::Backup => self.ui_text(ui, self.lang.t("backup"), "Backups são criados em /var/lib/mocha-updater/snapshots antes de ações críticas."),
                            Tab::Details => self.ui_details(ui),
                            Tab::Settings => self.ui_text(ui, self.lang.t("settings"), self.lang.t("settings_body")),
                            Tab::About => self.ui_text(ui, self.lang.t("about"), self.lang.t("about_body")),
                        }

                        ui.add_space(24.0);
                    });
            });
    }
}

impl MochaUpdater {
    fn ui_general(&mut self, ui: &mut egui::Ui) {
        card(ui, ui.available_width(), |ui| {
            title(ui, self.lang.t("available"));

            metric(ui, self.lang.t("pacman"), &format!("{} pacote(s)", self.info.pacman_pending));
            metric(ui, self.lang.t("flatpak"), &format!("{} aplicativo(s)", self.info.flatpak_pending));
            metric(ui, self.lang.t("recommendation"), &self.info.recommendation);
        });

        ui.add_space(12.0);

        card(ui, ui.available_width(), |ui| {
            title(ui, self.lang.t("current_status"));

            if self.running() {
                ui.horizontal(|ui| {
                    ui.spinner();
                    ui.label(RichText::new(&self.status).size(18.0).color(mocha_orange()).strong());
                });
            } else {
                ui.label(RichText::new(&self.status).size(18.0).color(mocha_text()).strong());
            }

            if !self.result.is_empty() {
                ui.add_space(8.0);
                ui.label(RichText::new(format!("{}: {}", self.lang.t("result"), self.result)).size(16.0).color(mocha_orange()).strong());
            }

            ui.add_space(8.0);
            ui.label(RichText::new(self.lang.t("auth_hint")).size(13.0).color(mocha_muted()));
        });

        ui.add_space(12.0);

        card(ui, ui.available_width(), |ui| self.actions_card(ui));

        ui.add_space(12.0);

        card(ui, ui.available_width(), |ui| {
            title(ui, "Andamento");

            let start = self.user_events.len().saturating_sub(12);

            for event in self.user_events.iter().skip(start) {
                ui.label(RichText::new(wrap_words(event, 180, 110)).size(14.0).color(mocha_text()));
                ui.add_space(4.0);
            }
        });

        ui.add_space(12.0);

        card(ui, ui.available_width(), |ui| {
            title(ui, self.lang.t("system"));

            metric(ui, self.lang.t("cpu"), &self.info.cpu);
            metric(ui, self.lang.t("gpu"), &self.info.gpu);
            metric(ui, self.lang.t("current_kernel"), &self.info.kernel);
            metric(ui, self.lang.t("driver"), &self.info.driver);
            metric(ui, self.lang.t("distro"), &self.info.distro);
        });
    }

    fn actions_card(&mut self, ui: &mut egui::Ui) {
        title(ui, self.lang.t("actions"));

        let running = self.running();
        let width = ui.available_width();
        let gap = 8.0;

        let cols = if width >= 980.0 {
            3usize
        } else if width >= 640.0 {
            2usize
        } else {
            1usize
        };

        let bw = ((width - gap * (cols.saturating_sub(1) as f32)) / cols as f32).max(220.0);

        let actions = [
            (self.lang.t("preview"), self.lang.t("preview_sub"), "preview", false),
            (self.lang.t("update"), self.lang.t("update_sub"), "update", true),
            (self.lang.t("backup_now"), self.lang.t("backup_sub"), "backup", false),
            (self.lang.t("test_kernel"), self.lang.t("test_kernel_sub"), "test-kernel", false),
            (self.lang.t("apply_kernel"), self.lang.t("apply_kernel_sub"), "apply-kernel", true),
        ];

        egui::Grid::new("actions_grid")
            .num_columns(cols)
            .spacing([gap, gap])
            .show(ui, |ui| {
                for (idx, (a, b, cmd, primary)) in actions.iter().enumerate() {
                    if action_button(ui, a, b, bw, *primary, running) {
                        self.start_action(cmd);
                    }

                    if (idx + 1) % cols == 0 {
                        ui.end_row();
                    }
                }
            });
    }

    fn ui_details(&self, ui: &mut egui::Ui) {
        card(ui, ui.available_width(), |ui| {
            title(ui, self.lang.t("technical_details"));

            if self.technical_logs.is_empty() {
                ui.label(RichText::new(self.lang.t("no_details")).size(14.0).color(mocha_muted()));
                return;
            }

            egui::ScrollArea::vertical()
                .max_height(620.0)
                .stick_to_bottom(true)
                .show(ui, |ui| {
                    for line in &self.technical_logs {
                        ui.label(RichText::new(wrap_words(line, 220, 130)).monospace().size(12.0).color(mocha_text()));
                    }
                });
        });
    }

    fn ui_text(&self, ui: &mut egui::Ui, heading: &str, body: &str) {
        card(ui, ui.available_width(), |ui| {
            title(ui, heading);
            ui.label(RichText::new(wrap_words(body, 500, 110)).size(16.0).color(mocha_text()));
            ui.add_space(10.0);
            ui.label(RichText::new(format!("Idioma: {}", self.lang.code())).color(mocha_orange()).size(13.0));
        });
    }
}

fn tab_button(ui: &mut egui::Ui, current: &mut Tab, tab: Tab, label: &str) {
    let selected = *current == tab;
    let fill = if selected { mocha_button_active() } else { mocha_button() };

    let button = egui::Button::new(RichText::new(label).size(14.0).color(mocha_text()).strong()).fill(fill);

    if ui.add_sized([150.0, 34.0], button).clicked() {
        *current = tab;
    }
}

fn card<R>(ui: &mut egui::Ui, width: f32, f: impl FnOnce(&mut egui::Ui) -> R) -> R {
    egui::Frame::none()
        .fill(mocha_card())
        .stroke(Stroke::new(1.0, mocha_border()))
        .inner_margin(egui::Margin::same(14))
        .show(ui, |ui| {
            ui.set_width(width.max(320.0));
            f(ui)
        })
        .inner
}

fn title(ui: &mut egui::Ui, text: &str) {
    ui.label(RichText::new(text).strong().size(18.0).color(mocha_text()));
    ui.add_space(10.0);
}

fn metric(ui: &mut egui::Ui, key: &str, value: &str) {
    ui.label(RichText::new(format!("{}:", key)).color(mocha_orange()).size(13.5).strong());
    ui.label(RichText::new(wrap_words(value, 260, 110)).color(mocha_text()).size(14.0));
    ui.add_space(8.0);
}

fn action_button(ui: &mut egui::Ui, title: &str, sub: &str, width: f32, primary: bool, disabled: bool) -> bool {
    let fill = if disabled {
        mocha_button_disabled()
    } else if primary {
        mocha_button_active()
    } else {
        mocha_button()
    };

    let text = RichText::new(format!("{}\n{}", title, sub)).strong().size(14.0).color(mocha_text());
    let button = egui::Button::new(text).fill(fill);

    if disabled {
        ui.add_sized([width, 74.0], button);
        false
    } else {
        ui.add_sized([width, 74.0], button).clicked()
    }
}

fn apply_visuals(ctx: &egui::Context) {
    let mut visuals = egui::Visuals::dark();

    visuals.override_text_color = Some(mocha_text());
    visuals.panel_fill = mocha_bg();
    visuals.window_fill = mocha_card();
    visuals.extreme_bg_color = mocha_bg();
    visuals.faint_bg_color = mocha_card();
    visuals.hyperlink_color = mocha_orange();
    visuals.selection.bg_fill = mocha_button_active();
    visuals.widgets.inactive.bg_fill = mocha_button();
    visuals.widgets.hovered.bg_fill = mocha_button_hover();
    visuals.widgets.active.bg_fill = mocha_button_active();

    ctx.set_visuals(visuals);
}

fn cmd(program: &str, args: &[&str]) -> Option<String> {
    let out = Command::new(program).args(args).output().ok()?;

    if !out.status.success() {
        return None;
    }

    let s = String::from_utf8_lossy(&out.stdout).trim().to_string();

    if s.is_empty() {
        None
    } else {
        Some(s)
    }
}

fn shell(command: &str) -> Option<String> {
    let out = Command::new("sh").arg("-c").arg(command).output().ok()?;
    Some(String::from_utf8_lossy(&out.stdout).trim_end().to_string())
}

fn shell_count(command: &str) -> usize {
    shell(command)
        .unwrap_or_default()
        .lines()
        .filter(|l| !l.trim().is_empty())
        .count()
}

fn first_cpu() -> Option<String> {
    let data = fs::read_to_string("/proc/cpuinfo").ok()?;

    for line in data.lines() {
        if let Some(rest) = line.strip_prefix("model name") {
            return rest.split_once(':').map(|(_, v)| v.trim().to_string());
        }
    }

    None
}

fn os_pretty_name() -> Option<String> {
    let data = fs::read_to_string("/etc/os-release").ok()?;

    for line in data.lines() {
        if let Some(v) = line.strip_prefix("PRETTY_NAME=") {
            return Some(v.trim_matches('"').to_string());
        }
    }

    None
}

fn local_recommendation() -> String {
    let gpu = shell("lspci 2>/dev/null | grep -Ei 'nvidia|vga|3d|display' || true").unwrap_or_default();

    let cachy = Command::new("sh")
        .arg("-c")
        .arg("pacman -Si linux-cachyos >/dev/null 2>&1")
        .status()
        .map(|s| s.success())
        .unwrap_or(false);

    let zen = Command::new("sh")
        .arg("-c")
        .arg("pacman -Si linux-zen >/dev/null 2>&1")
        .status()
        .map(|s| s.success())
        .unwrap_or(false);

    if gpu.to_lowercase().contains("nvidia") && cachy {
        "linux-cachyos + driver NVIDIA correspondente".to_string()
    } else if zen {
        "linux-zen + DKMS quando necessário".to_string()
    } else {
        "linux-lts fallback".to_string()
    }
}

fn wrap_words(input: &str, max_chars: usize, line_len: usize) -> String {
    let clean = input.split_whitespace().collect::<Vec<_>>().join(" ");
    let mut limited = String::new();

    for ch in clean.chars() {
        if limited.chars().count() >= max_chars {
            limited.push('…');
            break;
        }

        limited.push(ch);
    }

    let mut out = String::new();
    let mut current = 0usize;

    for word in limited.split_whitespace() {
        let wlen = word.chars().count();

        if current > 0 && current + 1 + wlen > line_len {
            out.push('\n');
            current = 0;
        } else if current > 0 {
            out.push(' ');
            current += 1;
        }

        out.push_str(word);
        current += wlen;
    }

    out
}

fn mocha_bg() -> Color32 { Color32::from_rgb(12, 9, 7) }
fn mocha_panel() -> Color32 { Color32::from_rgb(26, 21, 17) }
fn mocha_card() -> Color32 { Color32::from_rgb(28, 23, 18) }
fn mocha_button() -> Color32 { Color32::from_rgb(34, 28, 23) }
fn mocha_button_hover() -> Color32 { Color32::from_rgb(80, 46, 24) }
fn mocha_button_active() -> Color32 { Color32::from_rgb(139, 76, 35) }
fn mocha_button_disabled() -> Color32 { Color32::from_rgb(52, 45, 39) }
fn mocha_border() -> Color32 { Color32::from_rgb(92, 55, 31) }
fn mocha_text() -> Color32 { Color32::from_rgb(232, 222, 211) }
fn mocha_title() -> Color32 { Color32::from_rgb(244, 201, 155) }
fn mocha_muted() -> Color32 { Color32::from_rgb(185, 171, 157) }
fn mocha_orange() -> Color32 { Color32::from_rgb(230, 132, 45) }

fn main() -> eframe::Result<()> {
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_title("Mocha Updater")
            .with_inner_size([1040.0, 760.0])
            .with_min_inner_size([760.0, 560.0]),
        ..Default::default()
    };

    eframe::run_native(
        "Mocha Updater",
        options,
        Box::new(|cc| Ok(Box::new(MochaUpdater::new(cc)))),
    )
}
MOCHA_RUST

cargo fmt
cargo build --release

sudo install -Dm755 target/release/mocha-updater /usr/local/bin/mocha-updater

sudo mkdir -p /usr/share/pixmaps

sudo tee /usr/share/pixmaps/mocha-updater.svg >/dev/null <<'MOCHA_ICON'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="128" height="128" rx="24" fill="#1c1712"/>
  <circle cx="64" cy="64" r="46" fill="#8b4c23"/>
  <path d="M39 72c4 14 16 23 31 23 17 0 31-12 33-28H39z" fill="#0c0907"/>
  <path d="M39 55h62v15H39z" fill="#f4c99b"/>
  <path d="M89 48c8 0 15 6 15 14s-7 14-15 14" fill="none" stroke="#f4c99b" stroke-width="8" stroke-linecap="round"/>
  <path d="M51 26c-7 8 7 12 0 21M67 24c-7 8 7 12 0 21M83 26c-7 8 7 12 0 21" fill="none" stroke="#e6842d" stroke-width="6" stroke-linecap="round"/>
</svg>
MOCHA_ICON

sudo tee /usr/share/applications/mocha-updater.desktop >/dev/null <<'MOCHA_DESKTOP'
[Desktop Entry]
Type=Application
Name=Mocha Updater
Name[pt_BR]=Mocha Updater
Name[pt]=Mocha Updater
Name[fr]=Mocha Updater
Name[es]=Mocha Updater
Comment=Real Mocha system, Flatpak, kernel and driver updater
Comment[pt_BR]=Atualizador real de sistema, Flatpak, kernel e driver do Mocha
Comment[pt]=Atualizador real de sistema, Flatpak, kernel e driver do Mocha
Comment[fr]=Outil réel de mise à jour système, Flatpak, noyau et pilote pour Mocha
Comment[es]=Actualizador real de sistema, Flatpak, kernel y controlador para Mocha
Exec=/usr/local/bin/mocha-updater
Icon=mocha-updater
Terminal=false
Categories=System;Settings;
StartupNotify=true
MOCHA_DESKTOP

sudo chmod 0644 /usr/share/applications/mocha-updater.desktop

DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
mkdir -p "$DESKTOP_DIR"
install -m 0755 /usr/share/applications/mocha-updater.desktop "$DESKTOP_DIR/mocha-updater.desktop"

rm -f "$DESKTOP_DIR/mocha-kernel-driver-manager.desktop" \
      "$DESKTOP_DIR/mocha-kernel-driver-updater.desktop" \
      "$DESKTOP_DIR/mocha-kernel-driver.desktop" \
      "$DESKTOP_DIR/mocha-updater-gui.desktop" \
      "$DESKTOP_DIR/mocha-updater-old.desktop"

sudo rm -f /usr/share/applications/mocha-kernel-driver-manager.desktop \
           /usr/share/applications/mocha-kernel-driver-updater.desktop \
           /usr/share/applications/mocha-kernel-driver.desktop \
           /usr/share/applications/mocha-updater-gui.desktop \
           /usr/share/applications/mocha-updater-old.desktop

find "$DESKTOP_DIR" -maxdepth 1 -type f -iname '*mocha*updater*.desktop' ! -name 'mocha-updater.desktop' -delete 2>/dev/null || true
sudo find /usr/share/applications -maxdepth 1 -type f -iname '*mocha*updater*.desktop' ! -name 'mocha-updater.desktop' -delete 2>/dev/null || true

sudo rm -f /usr/local/lib/mocha-updater/mocha-updater-terminal

update-desktop-database /usr/share/applications >/dev/null 2>&1 || true

README="$ROOT/scripts/README-SCRIPTS-APROVADOS-MOCHA.md"
mkdir -p "$(dirname "$README")"

cat >> "$README" <<EOF

## Mocha Updater status de usuário V6 — $STAMP

Script canônico:
- $ROOT/scripts/mocha-updater-status-usuario-v6.sh

Função:
- substitui log cru por status compreensível para usuário final;
- mostra "Atualizações disponíveis: Pacman X, Flatpak Y";
- mostra "Verificando", "Criando backup", "Instalando", "Finalizando";
- mostra resultado final: "Atualização instalada com sucesso" ou falha;
- move saída técnica para aba Detalhes;
- mantém ações reais sem terminal via Polkit;
- mantém atalho canônico no menu Sistema e na área de trabalho;
- remove atalhos legados/duplicados.
EOF

ok "Mocha Updater V6 compilado com status de usuário"
ok "Binário instalado em /usr/local/bin/mocha-updater"
ok "Helper instalado em /usr/local/lib/mocha-updater/mocha-updater-root"
ok "Policy Polkit instalada em /usr/share/polkit-1/actions/org.mocha.updater.policy"
ok "Atalho do menu: /usr/share/applications/mocha-updater.desktop"
ok "Atalho da área de trabalho: $DESKTOP_DIR/mocha-updater.desktop"
ok "Script canônico: $ROOT/scripts/mocha-updater-status-usuario-v6.sh"

pkill -f '/usr/local/bin/mocha-updater' >/dev/null 2>&1 || true
nohup /usr/local/bin/mocha-updater >/tmp/mocha-updater-status-usuario-v6.log 2>&1 &
