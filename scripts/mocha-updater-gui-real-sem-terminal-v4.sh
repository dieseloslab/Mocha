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

[ -f src/main.rs ] && cp -a src/main.rs "src/main.rs.bak-gui-real-sem-terminal-$STAMP"

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

trap 'rc=$?; echo "[ERRO] ação falhou. Código: $rc"; echo "Log: $LOG"; chmod -R a+rX "$LOG_DIR" "$SNAP_BASE" 2>/dev/null || true; exit $rc' ERR
trap 'chmod -R a+rX "$LOG_DIR" "$SNAP_BASE" 2>/dev/null || true' EXIT

step() {
  echo
  echo "== $* =="
}

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

pkg_available() {
  timeout 20 pacman -Si "$1" >/dev/null 2>&1
}

pacman_lock_wait() {
  step "Verificando trava do pacman"
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
  step "Criando snapshot real"

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

  echo "[OK] Snapshot criado: $snap"
}

refresh_mirrors_if_possible() {
  step "Validando mirrors"

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
  step "Atualizando Flatpaks"

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
  step "Prévia real de atualizações"

  echo
  echo "Pacman:"
  pacman -Qu 2>/dev/null || true

  echo
  echo "Flatpak system:"
  flatpak remote-ls --system --updates 2>/dev/null || true

  local user
  user="$(detect_user || true)"
  if [ -n "$user" ] && id "$user" >/dev/null 2>&1 && cmd_exists flatpak; then
    echo
    echo "Flatpak user:"
    runuser -u "$user" -- flatpak remote-ls --user --updates 2>/dev/null || true
  fi
}

update_system() {
  pacman_lock_wait
  snapshot
  refresh_mirrors_if_possible

  step "Atualizando chaveiro Arch"
  pacman -Sy --needed --noconfirm archlinux-keyring || true

  step "Atualizando sistema com pacman"
  pacman -Syu --noconfirm

  flatpak_update_all

  step "Atualização concluída"
  echo "[OK] Sistema atualizado"
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
  step "Detectando hardware"

  echo "CPU:"
  grep -m1 '^model name' /proc/cpuinfo 2>/dev/null || true

  echo
  echo "Flags relevantes:"
  grep -m1 '^flags' /proc/cpuinfo 2>/dev/null | tr ' ' '\n' | grep -E 'avx|avx2|avx512|sse4|aes|fma|bmi|sha' | sort -u | tr '\n' ' ' || true
  echo

  echo
  echo "GPU:"
  lspci 2>/dev/null | grep -Ei 'vga|3d|display' || true

  echo
  echo "Driver NVIDIA:"
  timeout 8 nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || true

  local target driver
  target="$(recommend_kernel)"
  driver="$(driver_pkg_for_target "$target" || true)"

  echo
  echo "Recomendação:"
  echo "kernel_target=$target"
  echo "driver_package=${driver:-nenhum/indisponível}"
}

apply_kernel_driver() {
  pacman_lock_wait
  snapshot

  local target
  target="$(recommend_kernel)"

  step "Aplicando kernel + driver recomendado"
  echo "Alvo detectado: $target"

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

  echo
  echo "Pacotes a instalar:"
  printf '  %s\n' "${pkgs[@]}"

  pacman -Sy --needed --noconfirm archlinux-keyring || true
  pacman -S --needed --noconfirm "${pkgs[@]}"

  step "Recriando initramfs e bootloader"

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

  step "Kernel + driver aplicado"
  echo "[OK] Kernel antigo preservado para fallback"
  echo "[OK] Reinicie e escolha o kernel novo no bootloader se necessário"
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

echo
echo "== Ação concluída =="
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
                "subtitle" => "Atualização real sem terminal: clique, autorize e acompanhe aqui.",
                "general" => "Atualização Geral",
                "kernel" => "Kernel + Driver",
                "backup" => "Backup / Fallback",
                "logs" => "Logs",
                "settings" => "Configurações",
                "about" => "Sobre",
                "system" => "Sistema",
                "actions" => "Ações",
                "status" => "Status",
                "running" => "Executando",
                "idle" => "Pronto",
                "done" => "Concluído",
                "failed" => "Falhou",
                "cpu" => "CPU",
                "gpu" => "GPU",
                "current_kernel" => "Kernel atual",
                "driver" => "Driver",
                "distro" => "Distribuição",
                "arch" => "Arquitetura",
                "hostname" => "Hostname",
                "uptime" => "Tempo ativo",
                "pacman" => "Pacman",
                "flatpak" => "Flatpak",
                "unknown" => "Não detectado",
                "pending" => "pendentes",
                "preview" => "Prévia",
                "preview_sub" => "Ver atualizações",
                "update" => "Atualizar Sistema",
                "update_sub" => "Pacman + Flatpak",
                "test_kernel" => "Testar Kernel",
                "test_kernel_sub" => "Detectar hardware",
                "backup_now" => "Criar Backup",
                "backup_sub" => "Snapshot real",
                "apply_kernel" => "Aplicar Kernel + Driver",
                "apply_kernel_sub" => "Instalar recomendado",
                "kernel_body" => "Instala somente pacotes existentes nos repositórios já configurados. Nenhum repositório CachyOS é adicionado automaticamente.",
                "backup_body" => "Snapshots reais são gravados em /var/lib/mocha-updater/snapshots. O programa cria snapshot antes de atualizar sistema ou aplicar kernel.",
                "settings_body" => "Idiomas suportados: português, inglês, francês e espanhol. Outros locales caem para inglês.",
                "about_body" => "Mocha Updater real sem terminal. As ações rodam via Polkit em segundo plano, com progresso exibido dentro da interface.",
                "auth_hint" => "Se o sistema pedir senha, é a autorização Polkit da ação administrativa.",
                _ => Lang::En.t(key),
            },
            Lang::En => match key {
                "subtitle" => "Real updates without terminal: click, authorize and follow progress here.",
                "general" => "General Update",
                "kernel" => "Kernel + Driver",
                "backup" => "Backup / Fallback",
                "logs" => "Logs",
                "settings" => "Settings",
                "about" => "About",
                "system" => "System",
                "actions" => "Actions",
                "status" => "Status",
                "running" => "Running",
                "idle" => "Ready",
                "done" => "Done",
                "failed" => "Failed",
                "cpu" => "CPU",
                "gpu" => "GPU",
                "current_kernel" => "Current kernel",
                "driver" => "Driver",
                "distro" => "Distribution",
                "arch" => "Architecture",
                "hostname" => "Hostname",
                "uptime" => "Uptime",
                "pacman" => "Pacman",
                "flatpak" => "Flatpak",
                "unknown" => "Not detected",
                "pending" => "pending",
                "preview" => "Preview",
                "preview_sub" => "Check updates",
                "update" => "Update System",
                "update_sub" => "Pacman + Flatpak",
                "test_kernel" => "Test Kernel",
                "test_kernel_sub" => "Detect hardware",
                "backup_now" => "Create Backup",
                "backup_sub" => "Real snapshot",
                "apply_kernel" => "Apply Kernel + Driver",
                "apply_kernel_sub" => "Install recommended",
                "kernel_body" => "Installs only packages already available in configured repositories. No CachyOS repository is added automatically.",
                "backup_body" => "Real snapshots are written to /var/lib/mocha-updater/snapshots. The program creates a snapshot before system update or kernel application.",
                "settings_body" => "Supported languages: Portuguese, English, French and Spanish. Other locales fall back to English.",
                "about_body" => "Real Mocha Updater without terminal. Actions run through Polkit in background, with progress displayed inside the interface.",
                "auth_hint" => "If the system asks for a password, that is the Polkit authorization for the administrative action.",
                _ => key,
            },
            Lang::Fr => match key {
                "subtitle" => "Mises à jour réelles sans terminal : cliquez, autorisez et suivez ici.",
                "general" => "Mise à jour générale",
                "kernel" => "Noyau + Pilote",
                "backup" => "Sauvegarde / Repli",
                "logs" => "Journaux",
                "settings" => "Paramètres",
                "about" => "À propos",
                "system" => "Système",
                "actions" => "Actions",
                "status" => "État",
                "running" => "Exécution",
                "idle" => "Prêt",
                "done" => "Terminé",
                "failed" => "Échec",
                "cpu" => "CPU",
                "gpu" => "GPU",
                "current_kernel" => "Noyau actuel",
                "driver" => "Pilote",
                "distro" => "Distribution",
                "arch" => "Architecture",
                "hostname" => "Hostname",
                "uptime" => "Temps actif",
                "pacman" => "Pacman",
                "flatpak" => "Flatpak",
                "unknown" => "Non détecté",
                "pending" => "en attente",
                "preview" => "Aperçu",
                "preview_sub" => "Voir mises à jour",
                "update" => "Mettre à jour",
                "update_sub" => "Pacman + Flatpak",
                "test_kernel" => "Tester le noyau",
                "test_kernel_sub" => "Détecter matériel",
                "backup_now" => "Créer sauvegarde",
                "backup_sub" => "Snapshot réel",
                "apply_kernel" => "Appliquer Noyau + Pilote",
                "apply_kernel_sub" => "Installer recommandé",
                "kernel_body" => "Installe uniquement les paquets déjà disponibles dans les dépôts configurés. Aucun dépôt CachyOS n'est ajouté automatiquement.",
                "backup_body" => "Les snapshots réels sont écrits dans /var/lib/mocha-updater/snapshots.",
                "settings_body" => "Langues prises en charge : portugais, anglais, français et espagnol. Les autres locales utilisent l'anglais.",
                "about_body" => "Mocha Updater réel sans terminal. Les actions tournent via Polkit en arrière-plan.",
                "auth_hint" => "Si le système demande un mot de passe, c'est l'autorisation Polkit.",
                _ => Lang::En.t(key),
            },
            Lang::Es => match key {
                "subtitle" => "Actualización real sin terminal: haga clic, autorice y siga aquí.",
                "general" => "Actualización general",
                "kernel" => "Kernel + Controlador",
                "backup" => "Copia / Fallback",
                "logs" => "Registros",
                "settings" => "Configuración",
                "about" => "Acerca de",
                "system" => "Sistema",
                "actions" => "Acciones",
                "status" => "Estado",
                "running" => "Ejecutando",
                "idle" => "Listo",
                "done" => "Concluido",
                "failed" => "Falló",
                "cpu" => "CPU",
                "gpu" => "GPU",
                "current_kernel" => "Kernel actual",
                "driver" => "Controlador",
                "distro" => "Distribución",
                "arch" => "Arquitectura",
                "hostname" => "Hostname",
                "uptime" => "Tiempo activo",
                "pacman" => "Pacman",
                "flatpak" => "Flatpak",
                "unknown" => "No detectado",
                "pending" => "pendientes",
                "preview" => "Vista previa",
                "preview_sub" => "Ver actualizaciones",
                "update" => "Actualizar sistema",
                "update_sub" => "Pacman + Flatpak",
                "test_kernel" => "Probar kernel",
                "test_kernel_sub" => "Detectar hardware",
                "backup_now" => "Crear copia",
                "backup_sub" => "Snapshot real",
                "apply_kernel" => "Aplicar Kernel + Controlador",
                "apply_kernel_sub" => "Instalar recomendado",
                "kernel_body" => "Instala solo paquetes existentes en los repositorios configurados. No se añade ningún repo CachyOS automáticamente.",
                "backup_body" => "Los snapshots reales se guardan en /var/lib/mocha-updater/snapshots.",
                "settings_body" => "Idiomas soportados: portugués, inglés, francés y español. Otros locales caen a inglés.",
                "about_body" => "Mocha Updater real sin terminal. Las acciones se ejecutan vía Polkit en segundo plano.",
                "auth_hint" => "Si el sistema pide contraseña, es la autorización Polkit.",
                _ => Lang::En.t(key),
            },
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Tab {
    General,
    Kernel,
    Backup,
    Logs,
    Settings,
    About,
}

enum RunnerMsg {
    Line(String),
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
    arch: String,
    hostname: String,
    uptime: String,
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
        let arch = cmd("uname", &["-m"]).unwrap_or_else(|| unknown.clone());
        let hostname = cmd("hostname", &[]).unwrap_or_else(|| unknown.clone());
        let uptime = uptime_human().unwrap_or_else(|| unknown.clone());
        let pacman_pending = shell_count("pacman -Qu 2>/dev/null || true");
        let flatpak_pending = shell_count("flatpak remote-ls --updates 2>/dev/null || true");
        let recommendation = local_recommendation();

        Self {
            cpu,
            gpu,
            kernel,
            driver,
            distro,
            arch,
            hostname,
            uptime,
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
    logs: Vec<String>,
    runner: Option<Runner>,
    last_result: String,
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
            logs: vec!["Mocha Updater iniciado em modo GUI real sem terminal.".to_string()],
            runner: None,
            last_result: String::new(),
        }
    }

    fn running(&self) -> bool {
        self.runner.is_some()
    }

    fn log(&mut self, msg: String) {
        let stamp = cmd("date", &["+%F %T"]).unwrap_or_else(|| "time-unknown".to_string());
        self.logs.push(format!("[{}] {}", stamp.trim(), msg));
        if self.logs.len() > 900 {
            let drop_count = self.logs.len().saturating_sub(900);
            self.logs.drain(0..drop_count);
        }
    }

    fn refresh(&mut self) {
        self.info = SystemInfo::collect(self.lang);
    }

    fn poll_runner(&mut self) {
        let mut finished_code: Option<i32> = None;
        let mut drained = Vec::new();

        if let Some(runner) = &self.runner {
            while let Ok(msg) = runner.rx.try_recv() {
                match msg {
                    RunnerMsg::Line(line) => drained.push(line),
                    RunnerMsg::Done(code) => finished_code = Some(code),
                }
            }
        }

        for line in drained {
            self.logs.push(line);
        }

        if self.logs.len() > 900 {
            let drop_count = self.logs.len().saturating_sub(900);
            self.logs.drain(0..drop_count);
        }

        if let Some(code) = finished_code {
            let action = self.runner.as_ref().map(|r| r.action.clone()).unwrap_or_default();
            self.runner = None;

            if code == 0 {
                self.last_result = format!("{}: {}", self.lang.t("done"), action);
            } else {
                self.last_result = format!("{}: {} ({})", self.lang.t("failed"), action, code);
            }

            self.refresh();
            self.log(self.last_result.clone());
        }
    }

    fn start_action(&mut self, action: &str) {
        if self.running() {
            return;
        }

        let action_string = action.to_string();
        let (tx, rx) = mpsc::channel::<RunnerMsg>();

        self.log(format!("{}: {}", self.lang.t("running"), action));

        thread::spawn(move || {
            let command = format!(
                "pkexec /usr/local/lib/mocha-updater/mocha-updater-root {} 2>&1",
                shell_escape_action(&action_string)
            );

            let spawn = Command::new("sh")
                .arg("-c")
                .arg(command)
                .stdout(Stdio::piped())
                .stderr(Stdio::null())
                .spawn();

            let mut child = match spawn {
                Ok(child) => child,
                Err(err) => {
                    let _ = tx.send(RunnerMsg::Line(format!("[ERRO] falha ao iniciar ação: {}", err)));
                    let _ = tx.send(RunnerMsg::Done(127));
                    return;
                }
            };

            if let Some(stdout) = child.stdout.take() {
                let reader = BufReader::new(stdout);
                for line in reader.lines() {
                    match line {
                        Ok(line) => {
                            let _ = tx.send(RunnerMsg::Line(line));
                        }
                        Err(err) => {
                            let _ = tx.send(RunnerMsg::Line(format!("[ERRO] leitura de saída: {}", err)));
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
            ctx.request_repaint_after(std::time::Duration::from_millis(300));
        }

        egui::TopBottomPanel::top("top")
            .exact_height(38.0)
            .frame(egui::Frame::none().fill(mocha_panel()))
            .show(ctx, |ui| {
                ui.horizontal_centered(|ui| {
                    let state = if let Some(runner) = &self.runner {
                        format!("{}: {}", self.lang.t("running"), runner.action)
                    } else if self.last_result.is_empty() {
                        self.lang.t("idle").to_string()
                    } else {
                        self.last_result.clone()
                    };

                    ui.label(RichText::new(format!("☕  Mocha Updater — {}", state)).size(16.0).color(mocha_text()));
                });
            });

        egui::SidePanel::left("side")
            .resizable(false)
            .exact_width(220.0)
            .frame(egui::Frame::none().fill(mocha_sidebar()).stroke(Stroke::new(1.0, mocha_border())))
            .show(ctx, |ui| {
                ui.add_space(12.0);
                nav(ui, &mut self.tab, Tab::General, &format!("▣  {}", self.lang.t("general")));
                nav(ui, &mut self.tab, Tab::Kernel, &format!("⚙  {}", self.lang.t("kernel")));
                nav(ui, &mut self.tab, Tab::Backup, &format!("▣  {}", self.lang.t("backup")));
                nav(ui, &mut self.tab, Tab::Logs, &format!("□  {}", self.lang.t("logs")));

                ui.with_layout(egui::Layout::bottom_up(egui::Align::Min), |ui| {
                    nav(ui, &mut self.tab, Tab::About, &format!("□  {}", self.lang.t("about")));
                    nav(ui, &mut self.tab, Tab::Settings, &format!("⚙  {}", self.lang.t("settings")));
                    ui.label(RichText::new("GUI real sem terminal").size(12.0).color(mocha_orange()));
                });
            });

        egui::CentralPanel::default()
            .frame(egui::Frame::none().fill(mocha_bg()))
            .show(ctx, |ui| {
                egui::ScrollArea::vertical()
                    .auto_shrink([false, false])
                    .show(ui, |ui| {
                        ui.add_space(18.0);

                        ui.horizontal_wrapped(|ui| {
                            ui.label(RichText::new("☕").size(40.0).color(mocha_orange()));
                            ui.vertical(|ui| {
                                ui.label(RichText::new("Mocha Updater").size(32.0).color(mocha_title()));
                                ui.label(RichText::new(self.lang.t("subtitle")).size(14.0).color(mocha_orange()));
                                ui.label(RichText::new(self.lang.t("auth_hint")).size(12.0).color(mocha_muted()));
                            });
                        });

                        ui.add_space(18.0);

                        match self.tab {
                            Tab::General => self.ui_general(ui),
                            Tab::Kernel => self.ui_text(ui, self.lang.t("kernel"), self.lang.t("kernel_body")),
                            Tab::Backup => self.ui_text(ui, self.lang.t("backup"), self.lang.t("backup_body")),
                            Tab::Logs => self.ui_logs(ui),
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
        let w = ui.available_width();
        let two = w >= 980.0;
        let gap = 14.0;
        let cw = if two { (w - gap) / 2.0 } else { w };

        if two {
            ui.horizontal_top(|ui| {
                card(ui, cw, |ui| self.system_card(ui));
                ui.add_space(gap);
                card(ui, cw, |ui| self.status_card(ui));
            });
        } else {
            card(ui, cw, |ui| self.system_card(ui));
            ui.add_space(gap);
            card(ui, cw, |ui| self.status_card(ui));
        }

        ui.add_space(gap);
        card(ui, ui.available_width(), |ui| self.actions_card(ui));

        ui.add_space(gap);
        self.progress_card(ui);
    }

    fn system_card(&self, ui: &mut egui::Ui) {
        title(ui, self.lang.t("system"));
        row(ui, self.lang.t("cpu"), &self.info.cpu);
        row(ui, self.lang.t("gpu"), &self.info.gpu);
        row(ui, self.lang.t("current_kernel"), &self.info.kernel);
        row(ui, self.lang.t("driver"), &self.info.driver);
        row(ui, self.lang.t("distro"), &self.info.distro);
        row(ui, self.lang.t("arch"), &self.info.arch);
        row(ui, self.lang.t("hostname"), &self.info.hostname);
        row(ui, self.lang.t("uptime"), &self.info.uptime);
    }

    fn status_card(&self, ui: &mut egui::Ui) {
        title(ui, self.lang.t("status"));
        row(ui, self.lang.t("pacman"), &format!("{} {}", self.info.pacman_pending, self.lang.t("pending")));
        row(ui, self.lang.t("flatpak"), &format!("{} {}", self.info.flatpak_pending, self.lang.t("pending")));
        row(ui, self.lang.t("kernel"), &self.info.recommendation);
        ui.add_space(8.0);
        ui.label(RichText::new("Logs: /var/log/mocha-updater").color(mocha_orange()));
        ui.label(RichText::new("Snapshots: /var/lib/mocha-updater/snapshots").color(mocha_orange()));
    }

    fn actions_card(&mut self, ui: &mut egui::Ui) {
        title(ui, self.lang.t("actions"));

        let running = self.running();
        let width = ui.available_width();
        let gap = 8.0;
        let cols = ((width + gap) / 190.0).floor().clamp(1.0, 5.0) as usize;
        let bw = ((width - gap * (cols.saturating_sub(1) as f32)) / cols as f32).max(170.0);

        let actions = [
            (self.lang.t("preview"), self.lang.t("preview_sub"), "preview", false),
            (self.lang.t("update"), self.lang.t("update_sub"), "update", true),
            (self.lang.t("test_kernel"), self.lang.t("test_kernel_sub"), "test-kernel", false),
            (self.lang.t("backup_now"), self.lang.t("backup_sub"), "backup", false),
            (self.lang.t("apply_kernel"), self.lang.t("apply_kernel_sub"), "apply-kernel", true),
        ];

        egui::Grid::new("actions")
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

    fn progress_card(&self, ui: &mut egui::Ui) {
        card(ui, ui.available_width(), |ui| {
            title(ui, self.lang.t("logs"));

            let max_lines = 22usize;
            let start = self.logs.len().saturating_sub(max_lines);

            egui::ScrollArea::vertical()
                .max_height(300.0)
                .stick_to_bottom(true)
                .show(ui, |ui| {
                    for line in self.logs.iter().skip(start) {
                        ui.label(RichText::new(line).monospace().size(13.0).color(mocha_text()));
                    }
                });
        });
    }

    fn ui_logs(&self, ui: &mut egui::Ui) {
        card(ui, ui.available_width(), |ui| {
            title(ui, self.lang.t("logs"));

            egui::ScrollArea::vertical()
                .max_height(620.0)
                .stick_to_bottom(true)
                .show(ui, |ui| {
                    for line in &self.logs {
                        ui.label(RichText::new(line).monospace().size(13.0).color(mocha_text()));
                    }
                });
        });
    }

    fn ui_text(&self, ui: &mut egui::Ui, heading: &str, body: &str) {
        card(ui, ui.available_width(), |ui| {
            title(ui, heading);
            ui.label(RichText::new(body).size(16.0).color(mocha_text()));
            ui.add_space(10.0);
            ui.label(RichText::new(format!("Idioma: {}", self.lang.code())).color(mocha_orange()));
        });
    }
}

fn nav(ui: &mut egui::Ui, current: &mut Tab, tab: Tab, label: &str) {
    let fill = if *current == tab { mocha_button_active() } else { mocha_button() };
    let button = egui::Button::new(RichText::new(label).size(15.0).color(mocha_text())).fill(fill);

    if ui.add_sized([ui.available_width(), 42.0], button).clicked() {
        *current = tab;
    }

    ui.add_space(5.0);
}

fn card<R>(ui: &mut egui::Ui, width: f32, f: impl FnOnce(&mut egui::Ui) -> R) -> R {
    egui::Frame::none()
        .fill(mocha_card())
        .stroke(Stroke::new(1.0, mocha_border()))
        .inner_margin(egui::Margin::same(12))
        .show(ui, |ui| {
            ui.set_width(width.max(240.0));
            f(ui)
        })
        .inner
}

fn title(ui: &mut egui::Ui, text: &str) {
    ui.label(RichText::new(text).strong().size(18.0).color(mocha_text()));
    ui.add_space(8.0);
}

fn row(ui: &mut egui::Ui, k: &str, v: &str) {
    ui.horizontal_wrapped(|ui| {
        ui.label(RichText::new(format!("{}:", k)).color(mocha_orange()).size(13.0));
        ui.label(RichText::new(shorten(v, 120)).color(mocha_text()).size(13.0));
    });
}

fn action_button(ui: &mut egui::Ui, title: &str, sub: &str, width: f32, primary: bool, disabled: bool) -> bool {
    let fill = if disabled {
        mocha_button_disabled()
    } else if primary {
        mocha_button_active()
    } else {
        mocha_button()
    };

    let text = RichText::new(format!("{}\n{}", title, sub)).strong().size(13.0).color(mocha_text());
    ui.add_enabled(!disabled, egui::Button::new(text).fill(fill).min_size(egui::vec2(width, 70.0))).clicked()
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
    if s.is_empty() { None } else { Some(s) }
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

fn uptime_human() -> Option<String> {
    let data = fs::read_to_string("/proc/uptime").ok()?;
    let first = data.split_whitespace().next()?;
    let secs = first.split('.').next()?.parse::<u64>().ok()?;
    let days = secs / 86400;
    let hours = (secs % 86400) / 3600;
    let mins = (secs % 3600) / 60;

    if days > 0 {
        Some(format!("{}d {:02}h {:02}m", days, hours, mins))
    } else {
        Some(format!("{}h {:02}m", hours, mins))
    }
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

fn shorten(input: &str, max_chars: usize) -> String {
    let one = input.split_whitespace().collect::<Vec<_>>().join(" ");
    let mut out = String::new();

    for ch in one.chars() {
        if out.chars().count() >= max_chars {
            out.push('…');
            return out;
        }

        out.push(ch);
    }

    out
}

fn shell_escape_action(action: &str) -> &'static str {
    match action {
        "preview" => "preview",
        "update" => "update",
        "backup" => "backup",
        "test-kernel" => "test-kernel",
        "apply-kernel" => "apply-kernel",
        _ => "preview",
    }
}

fn mocha_bg() -> Color32 { Color32::from_rgb(12, 9, 7) }
fn mocha_sidebar() -> Color32 { Color32::from_rgb(18, 14, 11) }
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
            .with_inner_size([1180.0, 760.0])
            .with_min_inner_size([860.0, 560.0]),
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

## Mocha Updater GUI real sem terminal V4 — $STAMP

Script canônico:
- $ROOT/scripts/mocha-updater-gui-real-sem-terminal-v4.sh

Função:
- recompila o Mocha Updater;
- remove o fluxo com terminal;
- executa ações reais via Polkit em segundo plano;
- mostra progresso e resultado dentro da própria interface;
- mantém helper administrativo em /usr/local/lib/mocha-updater/mocha-updater-root;
- mantém policy Polkit em /usr/share/polkit-1/actions/org.mocha.updater.policy;
- instala binário em /usr/local/bin/mocha-updater;
- mantém atalho canônico no menu Sistema e na área de trabalho;
- remove atalhos legados/duplicados.

Ações reais:
- preview: lista pacman e Flatpak;
- update: snapshot + pacman -Syu + Flatpak update;
- backup: snapshot em /var/lib/mocha-updater/snapshots;
- test-kernel: detecção real de CPU/GPU/driver;
- apply-kernel: instala kernel + driver disponível nos repositórios já configurados, sem adicionar repo CachyOS automaticamente.
EOF

ok "Mocha Updater GUI real sem terminal compilado"
ok "Binário instalado em /usr/local/bin/mocha-updater"
ok "Helper instalado em /usr/local/lib/mocha-updater/mocha-updater-root"
ok "Policy Polkit instalada"
ok "Atalho do menu: /usr/share/applications/mocha-updater.desktop"
ok "Atalho da área de trabalho: $DESKTOP_DIR/mocha-updater.desktop"
ok "Script canônico: $ROOT/scripts/mocha-updater-gui-real-sem-terminal-v4.sh"

nohup /usr/local/bin/mocha-updater >/tmp/mocha-updater-gui-real-sem-terminal.log 2>&1 &
