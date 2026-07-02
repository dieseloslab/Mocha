#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

PUB="/media/mochafast/MochaArch"
APP="$PUB/apps/mocha-updater"
OUT="${1:-/media/vmstore/MochaArch/auditorias/mocha-updater-refactor-conservador-manual-$(date +%Y%m%d-%H%M%S)}"

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

[ -d "$APP" ] || fail "App ausente: $APP"
mkdir -p "$OUT" "$APP/scripts"

echo "============================================================"
echo " Mocha Updater — refactor conservador"
echo "============================================================"
echo
echo "Auditoria:"
echo "$OUT"
echo

echo "1) Backup do estado anterior..."
cp -a "$APP/Cargo.toml" "$OUT/Cargo.toml.before" 2>/dev/null || true
cp -a "$APP/Cargo.lock" "$OUT/Cargo.lock.before" 2>/dev/null || true
cp -a "$APP/src/main.rs" "$OUT/main.rs.before" 2>/dev/null || true

if compgen -G "$APP/src/main.rs.bak-*" >/dev/null; then
  mkdir -p "$OUT/src-backups-antigos"
  mv -v "$APP"/src/main.rs.bak-* "$OUT/src-backups-antigos"/
  ok "Backups antigos de main.rs movidos para auditoria"
fi

echo
echo "2) Escrevendo helper de ações..."
cat > "$APP/scripts/mocha-updater-action-v1.sh" <<'ACTION_EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

ACTION="${1:-}"
LOGDIR="/var/log/mocha-updater"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$LOGDIR/${ACTION:-acao-desconhecida}-$STAMP.log"

mkdir -p "$LOGDIR"

exec > >(tee -a "$LOG") 2>&1

ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[FALHA] %s\n' "$*"; exit 1; }

need_root() {
  [ "$(id -u)" -eq 0 ] || fail "Esta ação precisa rodar como root."
}

have() { command -v "$1" >/dev/null 2>&1; }

print_header() {
  echo "============================================================"
  echo " Mocha Updater — $1"
  echo "============================================================"
  echo
  echo "Data: $(date -Is)"
  echo "Log: $LOG"
  echo
}

kernel_ignore_args() {
  printf '%s\n' \
    --ignore linux \
    --ignore linux-headers \
    --ignore linux-cachyos \
    --ignore linux-cachyos-headers \
    --ignore linux-cachyos-nvidia-open \
    --ignore linux-cachyos-lts \
    --ignore linux-cachyos-lts-headers \
    --ignore linux-cachyos-lts-nvidia-open \
    --ignore nvidia \
    --ignore nvidia-open \
    --ignore nvidia-utils \
    --ignore lib32-nvidia-utils \
    --ignore opencl-nvidia \
    --ignore lib32-opencl-nvidia \
    --ignore nvidia-settings
}

detect_cpu_level() {
  if /lib64/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v4.*supported'; then
    echo "x86-64-v4"
  elif /lib64/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v3.*supported'; then
    echo "x86-64-v3"
  elif grep -qm1 ' avx2 ' /proc/cpuinfo 2>/dev/null; then
    echo "x86-64-v3-provavel"
  else
    echo "x86-64-v2-ou-basico"
  fi
}

has_nvidia_gpu() {
  lspci -nn 2>/dev/null | grep -Eiq 'vga|3d|display' && \
  lspci -nn 2>/dev/null | grep -Eiq 'nvidia'
}

confirm_kernel_action() {
  echo
  echo "Esta ação mexe em kernel/driver."
  echo "Ela é separada do update geral exatamente para evitar conversão ou troca acidental."
  echo
  printf "Digite SIM para continuar: "
  read -r ans
  [ "$ans" = "SIM" ] || fail "Cancelado pelo usuário."
}

regen_boot() {
  echo
  echo "Regenerando initramfs/GRUB quando disponível..."
  if have mkinitcpio; then
    mkinitcpio -P || fail "mkinitcpio falhou"
  fi
  if have grub-mkconfig && [ -d /boot/grub ]; then
    grub-mkconfig -o /boot/grub/grub.cfg || fail "grub-mkconfig falhou"
  fi
  ok "Boot regenerado"
}

action_system_check() {
  print_header "verificação geral sem alterações"

  echo "Sistema:"
  uname -a || true
  cat /etc/os-release 2>/dev/null || true
  echo

  echo "Pacman lock:"
  if [ -e /var/lib/pacman/db.lck ]; then
    ls -l /var/lib/pacman/db.lck
    warn "Há lock do pacman. Não rode update enquanto existir."
  else
    ok "Sem lock do pacman"
  fi
  echo

  echo "Pacotes instalados relevantes:"
  pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open nvidia-utils lib32-nvidia-utils opencl-nvidia nvidia-settings 2>/dev/null || true
  echo

  echo "Atualizações pendentes:"
  if have checkupdates; then
    checkupdates || true
  else
    pacman -Qu || true
  fi
  echo

  echo "Flatpak:"
  if have flatpak; then
    flatpak remote-ls --updates 2>/dev/null || true
  else
    warn "flatpak ausente"
  fi
  echo

  echo "NVIDIA:"
  timeout 8 nvidia-smi 2>/dev/null || warn "nvidia-smi indisponível"
  echo

  echo "Kernel atual:"
  uname -r
  echo

  ok "Verificação concluída sem alterar o sistema"
}

action_system_update() {
  need_root
  print_header "update geral conservador"

  echo "Update geral NÃO troca kernel/driver NVIDIA."
  echo "Pacotes de kernel/driver serão ignorados e tratados na guia própria."
  echo

  mapfile -t IGN < <(kernel_ignore_args)

  pacman -Syu --needed "${IGN[@]}" || fail "pacman -Syu conservador falhou"

  if have flatpak; then
    flatpak update -y || fail "flatpak update falhou"
  else
    warn "flatpak ausente"
  fi

  ok "Update geral conservador concluído"
}

action_kernel_check() {
  print_header "diagnóstico kernel/driver"

  echo "CPU:"
  lscpu 2>/dev/null || true
  echo
  echo "Nível detectado:"
  detect_cpu_level
  echo

  echo "GPU:"
  lspci -nnk 2>/dev/null | grep -EA4 -i 'vga|3d|display' || true
  echo

  echo "NVIDIA runtime:"
  timeout 8 nvidia-smi 2>/dev/null || true
  echo

  echo "Pacotes instalados:"
  pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open nvidia-utils lib32-nvidia-utils opencl-nvidia nvidia-settings 2>/dev/null || true
  echo

  echo "Candidatos do repo Mocha:"
  pacman -Si mocha/linux-cachyos mocha/linux-cachyos-headers mocha/linux-cachyos-nvidia-open 2>/dev/null | grep -E '^(Repository|Name|Version|Architecture)' || warn "Pacotes mocha/linux-cachyos não encontrados via pacman -Si"
  echo

  echo "Módulos carregados:"
  lsmod | grep -E '^nvidia|^nouveau' || true
  echo

  ok "Diagnóstico concluído"
}

action_kernel_install_mocha_stable() {
  need_root
  print_header "instalar/restaurar kernel Mocha estável casado"

  confirm_kernel_action

  CPU_LEVEL="$(detect_cpu_level)"
  echo "CPU detectada: $CPU_LEVEL"

  case "$CPU_LEVEL" in
    x86-64-v3*|x86-64-v4*) ok "CPU compatível com pacote v3/provável" ;;
    *) fail "CPU não parece compatível com x86-64-v3. Abortando para segurança." ;;
  esac

  echo
  echo "Backup pré-transação:"
  BK="/var/backups/mocha-updater/kernel-driver-pre-$STAMP"
  mkdir -p "$BK"
  pacman -Q > "$BK/pacman-Q.txt"
  pacman -Qqe > "$BK/pacman-Qqe.txt"
  cp -a /boot "$BK/boot-copy" 2>/dev/null || warn "Não foi possível copiar /boot inteiro"
  ok "Backup salvo em $BK"

  echo
  echo "Validando repo Mocha..."
  pacman -Si mocha/linux-cachyos mocha/linux-cachyos-headers >/dev/null || fail "Repo/pacotes Mocha linux-cachyos indisponíveis"

  PKGS=(mocha/linux-cachyos mocha/linux-cachyos-headers)

  if has_nvidia_gpu; then
    echo "GPU NVIDIA detectada: instalando driver casado do kernel Mocha."
    pacman -Si mocha/linux-cachyos-nvidia-open >/dev/null || fail "mocha/linux-cachyos-nvidia-open indisponível"
    PKGS+=(mocha/linux-cachyos-nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings opencl-nvidia lib32-opencl-nvidia egl-wayland libxnvctrl)
  else
    warn "GPU NVIDIA não detectada. Instalando apenas kernel/headers."
  fi

  echo
  echo "Instalando:"
  printf '  %s\n' "${PKGS[@]}"
  echo

  pacman -S --needed --noconfirm "${PKGS[@]}" || fail "Instalação kernel/driver falhou"

  regen_boot

  echo
  echo "Estado final:"
  uname -r || true
  pacman -Q linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open nvidia-utils 2>/dev/null || true
  timeout 8 nvidia-smi 2>/dev/null || true

  ok "Kernel/driver Mocha estável aplicado. Reinicie antes de validar FPS."
}

action_rollback_mocha_stable() {
  need_root
  print_header "rollback para kernel Mocha estável"

  confirm_kernel_action

  echo "Este rollback reinstala o trio estável do repo Mocha:"
  echo "  mocha/linux-cachyos"
  echo "  mocha/linux-cachyos-headers"
  echo "  mocha/linux-cachyos-nvidia-open, se houver NVIDIA"
  echo

  action_kernel_install_mocha_stable
}

action_logs() {
  print_header "logs recentes"
  echo "Logs do Mocha Updater:"
  find "$LOGDIR" -maxdepth 1 -type f -printf '%TY-%Tm-%Td %TH:%TM %p\n' 2>/dev/null | sort | tail -n 40 || true
  echo

  echo "Pacman kernel/driver recente:"
  grep -Ei 'linux-cachyos|nvidia|kernel|mkinitcpio|grub' /var/log/pacman.log 2>/dev/null | tail -n 120 || true
  echo

  echo "Boots disponíveis:"
  find /boot -maxdepth 2 -type f \( -name 'vmlinuz-*' -o -name 'initramfs-*' -o -name 'grub.cfg' \) -printf '%p\n' 2>/dev/null | sort || true
  echo

  ok "Coleta de logs concluída"
}

case "$ACTION" in
  system-check) action_system_check ;;
  system-update) action_system_update ;;
  kernel-check) action_kernel_check ;;
  kernel-install-mocha-stable) action_kernel_install_mocha_stable ;;
  rollback-mocha-stable) action_rollback_mocha_stable ;;
  logs) action_logs ;;
  *)
    echo "Uso: $0 {system-check|system-update|kernel-check|kernel-install-mocha-stable|rollback-mocha-stable|logs}"
    exit 2
    ;;
esac
ACTION_EOF

chmod +x "$APP/scripts/mocha-updater-action-v1.sh"

echo
echo "3) Escrevendo main.rs novo..."
cat > "$APP/src/main.rs" <<'RUST_EOF'
use eframe::egui;
use std::process::Command;

const ACTION: &str = "/usr/local/lib/mocha/mocha-updater/mocha-updater-action";

#[derive(Clone, Copy, PartialEq, Eq)]
enum Lang {
    Pt,
    En,
    Fr,
    Es,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Tab {
    System,
    Kernel,
    Rollback,
    About,
}

struct MochaUpdater {
    lang: Lang,
    tab: Tab,
    status: String,
    system_info: String,
}

impl Default for MochaUpdater {
    fn default() -> Self {
        let lang = detect_lang();
        let system_info = collect_status();
        Self {
            lang,
            tab: Tab::System,
            status: String::new(),
            system_info,
        }
    }
}

fn detect_lang() -> Lang {
    let raw = std::env::var("LANG")
        .or_else(|_| std::env::var("LC_MESSAGES"))
        .unwrap_or_else(|_| "en".to_string())
        .to_lowercase();

    if raw.starts_with("pt") {
        Lang::Pt
    } else if raw.starts_with("fr") {
        Lang::Fr
    } else if raw.starts_with("es") {
        Lang::Es
    } else {
        Lang::En
    }
}

fn t(lang: Lang, key: &str) -> &'static str {
    match (lang, key) {
        (_, "title") => "Mocha Updater",

        (Lang::Pt, "subtitle") => "Atualizador conservador de sistema, Flatpak, kernel e driver",
        (Lang::En, "subtitle") => "Conservative updater for system, Flatpak, kernel and driver",
        (Lang::Fr, "subtitle") => "Outil prudent de mise à jour système, Flatpak, noyau et pilote",
        (Lang::Es, "subtitle") => "Actualizador conservador de sistema, Flatpak, kernel y controlador",

        (Lang::Pt, "tab_system") => "Sistema",
        (Lang::En, "tab_system") => "System",
        (Lang::Fr, "tab_system") => "Système",
        (Lang::Es, "tab_system") => "Sistema",

        (Lang::Pt, "tab_kernel") => "Kernel / Driver",
        (Lang::En, "tab_kernel") => "Kernel / Driver",
        (Lang::Fr, "tab_kernel") => "Noyau / Pilote",
        (Lang::Es, "tab_kernel") => "Kernel / Controlador",

        (Lang::Pt, "tab_rollback") => "Rollback",
        (Lang::En, "tab_rollback") => "Rollback",
        (Lang::Fr, "tab_rollback") => "Retour arrière",
        (Lang::Es, "tab_rollback") => "Reversión",

        (Lang::Pt, "tab_about") => "Sobre",
        (Lang::En, "tab_about") => "About",
        (Lang::Fr, "tab_about") => "À propos",
        (Lang::Es, "tab_about") => "Acerca de",

        (Lang::Pt, "current_state") => "Estado atual",
        (Lang::En, "current_state") => "Current state",
        (Lang::Fr, "current_state") => "État actuel",
        (Lang::Es, "current_state") => "Estado actual",

        (Lang::Pt, "refresh") => "Atualizar estado",
        (Lang::En, "refresh") => "Refresh state",
        (Lang::Fr, "refresh") => "Rafraîchir l’état",
        (Lang::Es, "refresh") => "Actualizar estado",

        (Lang::Pt, "system_text") => "Atualização geral sem troca de kernel/driver. Pacotes de kernel e NVIDIA ficam bloqueados aqui e são tratados na guia própria.",
        (Lang::En, "system_text") => "General update without kernel/driver changes. Kernel and NVIDIA packages are held here and handled in their own tab.",
        (Lang::Fr, "system_text") => "Mise à jour générale sans changement de noyau/pilote. Les paquets noyau et NVIDIA sont bloqués ici et traités dans leur onglet.",
        (Lang::Es, "system_text") => "Actualización general sin cambiar kernel/controlador. Los paquetes de kernel y NVIDIA se bloquean aquí y se tratan en su pestaña.",

        (Lang::Pt, "check_system") => "Verificar updates",
        (Lang::En, "check_system") => "Check updates",
        (Lang::Fr, "check_system") => "Vérifier les mises à jour",
        (Lang::Es, "check_system") => "Verificar actualizaciones",

        (Lang::Pt, "run_system_update") => "Rodar update geral conservador",
        (Lang::En, "run_system_update") => "Run conservative system update",
        (Lang::Fr, "run_system_update") => "Lancer la mise à jour prudente",
        (Lang::Es, "run_system_update") => "Ejecutar actualización conservadora",

        (Lang::Pt, "kernel_text") => "Detecção de CPU/GPU e instalação explícita do kernel Mocha estável com driver NVIDIA casado quando houver NVIDIA.",
        (Lang::En, "kernel_text") => "CPU/GPU detection and explicit installation of the stable Mocha kernel with matching NVIDIA driver when NVIDIA exists.",
        (Lang::Fr, "kernel_text") => "Détection CPU/GPU et installation explicite du noyau Mocha stable avec pilote NVIDIA correspondant si NVIDIA existe.",
        (Lang::Es, "kernel_text") => "Detección de CPU/GPU e instalación explícita del kernel Mocha estable con controlador NVIDIA emparejado si hay NVIDIA.",

        (Lang::Pt, "diagnose_kernel") => "Diagnosticar CPU/GPU/kernel",
        (Lang::En, "diagnose_kernel") => "Diagnose CPU/GPU/kernel",
        (Lang::Fr, "diagnose_kernel") => "Diagnostiquer CPU/GPU/noyau",
        (Lang::Es, "diagnose_kernel") => "Diagnosticar CPU/GPU/kernel",

        (Lang::Pt, "install_kernel") => "Instalar/restaurar kernel Mocha estável",
        (Lang::En, "install_kernel") => "Install/restore stable Mocha kernel",
        (Lang::Fr, "install_kernel") => "Installer/restaurer le noyau Mocha stable",
        (Lang::Es, "install_kernel") => "Instalar/restaurar kernel Mocha estable",

        (Lang::Pt, "rollback_text") => "Rollback explícito para o trio estável do repo Mocha. Mantém a separação entre update geral e kernel/driver.",
        (Lang::En, "rollback_text") => "Explicit rollback to the stable trio from the Mocha repo. Keeps general update separate from kernel/driver.",
        (Lang::Fr, "rollback_text") => "Retour arrière explicite vers le trio stable du dépôt Mocha. Sépare la mise à jour générale du noyau/pilote.",
        (Lang::Es, "rollback_text") => "Reversión explícita al trío estable del repo Mocha. Mantiene separada la actualización general del kernel/controlador.",

        (Lang::Pt, "rollback_kernel") => "Rollback para kernel Mocha estável",
        (Lang::En, "rollback_kernel") => "Rollback to stable Mocha kernel",
        (Lang::Fr, "rollback_kernel") => "Retour au noyau Mocha stable",
        (Lang::Es, "rollback_kernel") => "Revertir al kernel Mocha estable",

        (Lang::Pt, "show_logs") => "Mostrar logs",
        (Lang::En, "show_logs") => "Show logs",
        (Lang::Fr, "show_logs") => "Afficher les journaux",
        (Lang::Es, "show_logs") => "Mostrar logs",

        (Lang::Pt, "about_text") => "Mocha Updater separa atualização geral de kernel/driver para evitar conversão acidental do sistema. Idiomas suportados: português, inglês, francês e espanhol. Outros locales caem para inglês.",
        (Lang::En, "about_text") => "Mocha Updater separates general updates from kernel/driver changes to avoid accidental system conversion. Supported languages: Portuguese, English, French and Spanish. Other locales fall back to English.",
        (Lang::Fr, "about_text") => "Mocha Updater sépare les mises à jour générales des changements noyau/pilote pour éviter toute conversion accidentelle. Langues prises en charge : portugais, anglais, français et espagnol. Les autres locales utilisent l’anglais.",
        (Lang::Es, "about_text") => "Mocha Updater separa las actualizaciones generales de los cambios de kernel/controlador para evitar conversiones accidentales. Idiomas soportados: portugués, inglés, francés y español. Otros locales usan inglés.",

        (Lang::Pt, "open_terminal") => "A ação abre um terminal com log e progresso.",
        (Lang::En, "open_terminal") => "The action opens a terminal with log and progress.",
        (Lang::Fr, "open_terminal") => "L’action ouvre un terminal avec journal et progression.",
        (Lang::Es, "open_terminal") => "La acción abre una terminal con log y progreso.",

        _ => "Unsupported text",
    }
}

fn shell_output(cmd: &str) -> String {
    match Command::new("bash").args(["-lc", cmd]).output() {
        Ok(out) => {
            let mut s = String::new();
            s.push_str(&String::from_utf8_lossy(&out.stdout));
            s.push_str(&String::from_utf8_lossy(&out.stderr));
            if s.trim().is_empty() {
                "(sem saída)".to_string()
            } else {
                s
            }
        }
        Err(e) => format!("erro: {e}"),
    }
}

fn collect_status() -> String {
    let cmd = r#"
echo "Kernel: $(uname -r)"
echo
echo "Pacotes:"
pacman -Q linux linux-headers linux-cachyos linux-cachyos-headers linux-cachyos-nvidia-open linux-cachyos-lts linux-cachyos-lts-headers linux-cachyos-lts-nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings 2>/dev/null || true
echo
echo "GPU:"
timeout 4 nvidia-smi --query-gpu=name,driver_version,pstate,temperature.gpu,memory.used,memory.total --format=csv,noheader 2>/dev/null || echo "NVIDIA indisponível"
echo
echo "Locale: ${LANG:-indefinido}"
"#;
    shell_output(cmd)
}

fn terminal_cmd_for(action: &str) -> String {
    format!(
        r#"set -Eeuo pipefail
echo "Mocha Updater — {action}"
echo
if [ ! -x "{ACTION}" ]; then
  echo "Helper ausente ou sem execução: {ACTION}"
  echo
  read -rp "Pressione Enter para fechar..."
  exit 1
fi
if [ "{action}" = "system-check" ] || [ "{action}" = "kernel-check" ] || [ "{action}" = "logs" ]; then
  "{ACTION}" "{action}"
else
  sudo -v || exit 1
  sudo "{ACTION}" "{action}"
fi
echo
echo "Ação concluída."
read -rp "Pressione Enter para fechar..."
"#,
        action = action,
    )
}

fn spawn_action(action: &str) -> String {
    let script = terminal_cmd_for(action);

    let try_konsole = Command::new("konsole")
        .args(["--hold", "-e", "bash", "-lc", &script])
        .spawn();

    if try_konsole.is_ok() {
        return format!("Ação iniciada: {action}");
    }

    let try_xterm = Command::new("xterm")
        .args(["-hold", "-e", "bash", "-lc", &script])
        .spawn();

    if try_xterm.is_ok() {
        return format!("Ação iniciada: {action}");
    }

    format!("Não foi possível abrir terminal para: {action}. Instale konsole ou xterm.")
}

impl eframe::App for MochaUpdater {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::TopBottomPanel::top("top").show(ctx, |ui| {
            ui.horizontal(|ui| {
                ui.heading(t(self.lang, "title"));
                ui.separator();
                ui.label(t(self.lang, "subtitle"));
            });

            ui.add_space(6.0);

            ui.horizontal(|ui| {
                ui.selectable_value(&mut self.tab, Tab::System, t(self.lang, "tab_system"));
                ui.selectable_value(&mut self.tab, Tab::Kernel, t(self.lang, "tab_kernel"));
                ui.selectable_value(&mut self.tab, Tab::Rollback, t(self.lang, "tab_rollback"));
                ui.selectable_value(&mut self.tab, Tab::About, t(self.lang, "tab_about"));
            });
        });

        egui::SidePanel::right("state")
            .resizable(true)
            .default_width(330.0)
            .show(ctx, |ui| {
                ui.heading(t(self.lang, "current_state"));
                if ui.button(t(self.lang, "refresh")).clicked() {
                    self.system_info = collect_status();
                }
                ui.separator();
                egui::ScrollArea::vertical().show(ui, |ui| {
                    ui.monospace(&self.system_info);
                });
            });

        egui::CentralPanel::default().show(ctx, |ui| {
            ui.add_space(8.0);

            match self.tab {
                Tab::System => {
                    ui.heading(t(self.lang, "tab_system"));
                    ui.label(t(self.lang, "system_text"));
                    ui.add_space(12.0);

                    if ui.button(t(self.lang, "check_system")).clicked() {
                        self.status = spawn_action("system-check");
                    }

                    if ui.button(t(self.lang, "run_system_update")).clicked() {
                        self.status = spawn_action("system-update");
                    }

                    ui.add_space(12.0);
                    ui.label(t(self.lang, "open_terminal"));
                }
                Tab::Kernel => {
                    ui.heading(t(self.lang, "tab_kernel"));
                    ui.label(t(self.lang, "kernel_text"));
                    ui.add_space(12.0);

                    if ui.button(t(self.lang, "diagnose_kernel")).clicked() {
                        self.status = spawn_action("kernel-check");
                    }

                    if ui.button(t(self.lang, "install_kernel")).clicked() {
                        self.status = spawn_action("kernel-install-mocha-stable");
                    }

                    ui.add_space(12.0);
                    ui.label(t(self.lang, "open_terminal"));
                }
                Tab::Rollback => {
                    ui.heading(t(self.lang, "tab_rollback"));
                    ui.label(t(self.lang, "rollback_text"));
                    ui.add_space(12.0);

                    if ui.button(t(self.lang, "rollback_kernel")).clicked() {
                        self.status = spawn_action("rollback-mocha-stable");
                    }

                    if ui.button(t(self.lang, "show_logs")).clicked() {
                        self.status = spawn_action("logs");
                    }

                    ui.add_space(12.0);
                    ui.label(t(self.lang, "open_terminal"));
                }
                Tab::About => {
                    ui.heading(t(self.lang, "tab_about"));
                    ui.label(t(self.lang, "about_text"));
                    ui.add_space(12.0);
                    ui.monospace(format!("Helper: {ACTION}"));
                    ui.monospace("Logs: /var/log/mocha-updater");
                }
            }

            ui.add_space(18.0);
            ui.separator();
            ui.label(&self.status);
        });
    }
}

fn main() -> eframe::Result<()> {
    let native_options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([980.0, 680.0])
            .with_min_inner_size([820.0, 560.0]),
        ..Default::default()
    };

    eframe::run_native(
        "Mocha Updater",
        native_options,
        Box::new(|_cc| Ok(Box::<MochaUpdater>::default())),
    )
}
RUST_EOF

echo
echo "4) Ajustando Cargo.toml..."
cat > "$APP/Cargo.toml" <<'CARGO_EOF'
[package]
name = "mocha-updater"
version = "0.2.0"
edition = "2021"

[dependencies]
eframe = "0.31"
egui = "0.31"
CARGO_EOF

echo
echo "5) Instalando helper..."
sudo mkdir -p /usr/local/lib/mocha/mocha-updater
sudo install -m 755 "$APP/scripts/mocha-updater-action-v1.sh" /usr/local/lib/mocha/mocha-updater/mocha-updater-action
ok "Helper instalado: /usr/local/lib/mocha/mocha-updater/mocha-updater-action"

echo
echo "6) Build release..."
cd "$APP"
cargo build --release --locked

echo
echo "7) Instalando binário..."
sudo install -m 755 "$APP/target/release/mocha-updater" /usr/local/bin/mocha-updater
ok "Binário instalado: /usr/local/bin/mocha-updater"

echo
echo "8) Instalando ícone e atalhos..."
if [ -f "$APP/assets/mocha-updater.svg" ]; then
  sudo mkdir -p /usr/share/icons/hicolor/scalable/apps
  sudo install -m 644 "$APP/assets/mocha-updater.svg" /usr/share/icons/hicolor/scalable/apps/mocha-updater.svg
  timeout 10 sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
fi

write_desktop() {
  local dst="$1"
  sudo mkdir -p "$(dirname "$dst")"
  sudo tee "$dst" >/dev/null <<'DESKTOP_EOF'
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
DESKTOP_EOF
  sudo chmod 755 "$dst"
}

write_desktop /usr/share/applications/mocha-updater.desktop
write_desktop /etc/skel/Desktop/mocha-updater.desktop
write_desktop "/etc/skel/Área de Trabalho/mocha-updater.desktop"

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  USER_ID="$(id -u "$SUDO_USER")"
  USER_GID="$(id -g "$SUDO_USER")"
else
  USER_HOME="$HOME"
  USER_ID="$(id -u)"
  USER_GID="$(id -g)"
fi

if [ -d "$USER_HOME/Desktop" ]; then
  write_desktop "$USER_HOME/Desktop/mocha-updater.desktop"
  sudo chown "$USER_ID:$USER_GID" "$USER_HOME/Desktop/mocha-updater.desktop"
fi

if [ -d "$USER_HOME/Área de Trabalho" ]; then
  write_desktop "$USER_HOME/Área de Trabalho/mocha-updater.desktop"
  sudo chown "$USER_ID:$USER_GID" "$USER_HOME/Área de Trabalho/mocha-updater.desktop"
fi

echo
echo "9) Validação..."
/usr/local/lib/mocha/mocha-updater/mocha-updater-action system-check | tee "$OUT/system-check.txt"

echo
echo "Binário:"
ls -lh /usr/local/bin/mocha-updater

echo
echo "Helper:"
ls -lh /usr/local/lib/mocha/mocha-updater/mocha-updater-action

echo
echo "Atalhos:"
find /usr/share/applications /etc/skel/Desktop "/etc/skel/Área de Trabalho" "$USER_HOME/Desktop" "$USER_HOME/Área de Trabalho" \
  -maxdepth 1 -type f -name 'mocha-updater.desktop' \
  -printf '%m %u:%g %p\n' 2>/dev/null | sort || true

echo
echo "Git status:"
git -C "$PUB" status --short || true

echo
ok "Refactor conservador concluído"
