#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

APP="/media/mochafast/MochaArch/apps/mocha-updater"
ROOT="/media/mochafast/MochaArch"
STAMP="$(date +%Y%m%d-%H%M%S)"

ok() { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

[ -d "$APP" ] || fail "Pasta não encontrada: $APP"
[ -f "$APP/Cargo.toml" ] || fail "Cargo.toml não encontrado em $APP"
[ -f "$APP/src/main.rs" ] || fail "src/main.rs não encontrado em $APP"

cd "$APP"

cp -a src/main.rs "src/main.rs.bak-ui-responsiva-$STAMP"

cat > src/main.rs <<'MOCHA_RUST'
use eframe::egui;
use egui::{Color32, RichText, Stroke};
use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

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
                "app.subtitle" => "Atualizações inteligentes para desempenho máximo.",
                "menu.general" => "Atualização Geral",
                "menu.kernel" => "Kernel + Driver",
                "menu.benchmark" => "Benchmark",
                "menu.backup" => "Backup / Fallback",
                "menu.logs" => "Logs",
                "menu.settings" => "Configurações",
                "menu.about" => "Sobre",
                "section.system" => "Informações do Sistema",
                "section.kernel" => "Recomendações de Kernel",
                "section.backup" => "Backup e Fallback",
                "section.status" => "Resumo de Status",
                "field.cpu" => "CPU",
                "field.gpu" => "GPU",
                "field.kernel" => "Kernel Atual",
                "field.driver" => "Driver de Vídeo",
                "field.arch" => "Arquitetura",
                "field.distro" => "Distribuição",
                "field.hostname" => "Hostname",
                "field.uptime" => "Tempo de Atividade",
                "field.pacman" => "Pacman",
                "field.flatpak" => "Flatpak",
                "pending.one" => "pendente",
                "pending.many" => "pendentes",
                "kernel.cachy" => "CachyOS",
                "kernel.zen" => "Arch Zen",
                "kernel.lts" => "Linux LTS",
                "badge.recommended" => "Recomendado",
                "badge.balanced" => "Equilibrado",
                "badge.fallback" => "Fallback",
                "desc.cachy" => "Kernel otimizado para jogos e desktop responsivo. Recomendado quando CPU/GPU e driver estão adequados.",
                "desc.zen" => "Opção equilibrada entre desempenho, responsividade e estabilidade.",
                "desc.lts" => "Opção conservadora para máxima compatibilidade e fallback.",
                "backup.ready" => "Sistema pronto para registro de fallback.",
                "backup.desc" => "O snapshot local registra pacotes, kernel, driver, repositórios e Flatpaks.",
                "backup.boot" => "Rollback real de kernel fica no módulo Kernel + Driver.",
                "button.manage_backups" => "Gerenciar Backups",
                "status.updated" => "Base local consultada",
                "status.driver" => "Driver de vídeo detectado",
                "status.backup" => "Snapshot local disponível",
                "status.conflicts" => "Sem conflitos detectados",
                "status.ok" => "Tudo certo",
                "button.analyze" => "Analisar Sistema",
                "button.analyze.sub" => "Detectar hardware e status",
                "button.update" => "Atualizar Sistema",
                "button.update.sub" => "Prévia segura disponível",
                "button.test_kernel" => "Testar Kernel",
                "button.test_kernel.sub" => "Recomendar kernel",
                "button.create_backup" => "Criar Backup",
                "button.create_backup.sub" => "Salvar estado atual",
                "button.apply" => "Aplicar",
                "button.apply.sub" => "Modo seguro V1",
                "tab.kernel.title" => "Kernel + Driver",
                "tab.kernel.body" => "Esta área faz a leitura de CPU, GPU, kernel e driver para recomendar um caminho seguro. A aplicação real de kernel/driver deve continuar separada e explícita.",
                "tab.benchmark.title" => "Benchmark",
                "tab.benchmark.body" => "Área reservada para testes rápidos antes e depois das atualizações.",
                "tab.backup.title" => "Backups locais",
                "tab.backup.body" => "Os snapshots desta versão registram o estado do sistema para diagnóstico e retorno manual seguro.",
                "tab.settings.title" => "Configurações",
                "tab.settings.lang" => "Idioma detectado",
                "tab.settings.supported" => "Idiomas suportados: português, inglês, francês e espanhol. Qualquer outro locale cai para inglês.",
                "tab.about.title" => "Sobre",
                "tab.about.body" => "Mocha Updater — interface responsiva, detecção, i18n, logs e ações seguras para validação inicial.",
                "log.ready" => "Mocha Updater iniciado.",
                "log.analyze" => "Análise do sistema concluída.",
                "log.preview" => "Prévia de atualizações concluída. Nenhuma alteração foi aplicada.",
                "log.kernel" => "Teste de kernel concluído.",
                "log.backup" => "Snapshot local criado.",
                "log.apply" => "Modo seguro V1: nenhuma atualização real foi aplicada.",
                "unknown" => "Não detectado",
                _ => Lang::En.t(key),
            },
            Lang::En => match key {
                "app.subtitle" => "Smart updates for maximum performance.",
                "menu.general" => "General Update",
                "menu.kernel" => "Kernel + Driver",
                "menu.benchmark" => "Benchmark",
                "menu.backup" => "Backup / Fallback",
                "menu.logs" => "Logs",
                "menu.settings" => "Settings",
                "menu.about" => "About",
                "section.system" => "System Information",
                "section.kernel" => "Kernel Recommendations",
                "section.backup" => "Backup and Fallback",
                "section.status" => "Status Summary",
                "field.cpu" => "CPU",
                "field.gpu" => "GPU",
                "field.kernel" => "Current Kernel",
                "field.driver" => "Video Driver",
                "field.arch" => "Architecture",
                "field.distro" => "Distribution",
                "field.hostname" => "Hostname",
                "field.uptime" => "Uptime",
                "field.pacman" => "Pacman",
                "field.flatpak" => "Flatpak",
                "pending.one" => "pending",
                "pending.many" => "pending",
                "kernel.cachy" => "CachyOS",
                "kernel.zen" => "Arch Zen",
                "kernel.lts" => "Linux LTS",
                "badge.recommended" => "Recommended",
                "badge.balanced" => "Balanced",
                "badge.fallback" => "Fallback",
                "desc.cachy" => "Kernel optimized for gaming and responsive desktop use. Recommended when CPU/GPU and driver are suitable.",
                "desc.zen" => "Balanced option between performance, responsiveness and stability.",
                "desc.lts" => "Conservative option for maximum compatibility and fallback.",
                "backup.ready" => "System ready for fallback record.",
                "backup.desc" => "The local snapshot records packages, kernel, driver, repositories and Flatpaks.",
                "backup.boot" => "Real kernel rollback stays in the Kernel + Driver module.",
                "button.manage_backups" => "Manage Backups",
                "status.updated" => "Local base checked",
                "status.driver" => "Video driver detected",
                "status.backup" => "Local snapshot available",
                "status.conflicts" => "No conflicts detected",
                "status.ok" => "All good",
                "button.analyze" => "Analyze System",
                "button.analyze.sub" => "Detect hardware and status",
                "button.update" => "Update System",
                "button.update.sub" => "Safe preview available",
                "button.test_kernel" => "Test Kernel",
                "button.test_kernel.sub" => "Recommend kernel",
                "button.create_backup" => "Create Backup",
                "button.create_backup.sub" => "Save current state",
                "button.apply" => "Apply",
                "button.apply.sub" => "Safe V1 mode",
                "tab.kernel.title" => "Kernel + Driver",
                "tab.kernel.body" => "This area reads CPU, GPU, kernel and driver information to recommend a safe path. Actual kernel/driver application remains separate and explicit.",
                "tab.benchmark.title" => "Benchmark",
                "tab.benchmark.body" => "Reserved area for quick before/after update tests.",
                "tab.backup.title" => "Local backups",
                "tab.backup.body" => "This version records system state for diagnosis and safe manual return.",
                "tab.settings.title" => "Settings",
                "tab.settings.lang" => "Detected language",
                "tab.settings.supported" => "Supported languages: Portuguese, English, French and Spanish. Any other locale falls back to English.",
                "tab.about.title" => "About",
                "tab.about.body" => "Mocha Updater — responsive interface, detection, i18n, logs and safe actions for initial validation.",
                "log.ready" => "Mocha Updater started.",
                "log.analyze" => "System analysis completed.",
                "log.preview" => "Update preview completed. No changes were applied.",
                "log.kernel" => "Kernel test completed.",
                "log.backup" => "Local snapshot created.",
                "log.apply" => "Safe V1 mode: no real update was applied.",
                "unknown" => "Not detected",
                _ => key,
            },
            Lang::Fr => match key {
                "app.subtitle" => "Mises à jour intelligentes pour performances maximales.",
                "menu.general" => "Mise à jour générale",
                "menu.kernel" => "Noyau + Pilote",
                "menu.benchmark" => "Benchmark",
                "menu.backup" => "Sauvegarde / Repli",
                "menu.logs" => "Journaux",
                "menu.settings" => "Paramètres",
                "menu.about" => "À propos",
                "section.system" => "Informations système",
                "section.kernel" => "Recommandations de noyau",
                "section.backup" => "Sauvegarde et repli",
                "section.status" => "Résumé d'état",
                "field.cpu" => "CPU",
                "field.gpu" => "GPU",
                "field.kernel" => "Noyau actuel",
                "field.driver" => "Pilote vidéo",
                "field.arch" => "Architecture",
                "field.distro" => "Distribution",
                "field.hostname" => "Nom d'hôte",
                "field.uptime" => "Temps de fonctionnement",
                "field.pacman" => "Pacman",
                "field.flatpak" => "Flatpak",
                "pending.one" => "en attente",
                "pending.many" => "en attente",
                "kernel.cachy" => "CachyOS",
                "kernel.zen" => "Arch Zen",
                "kernel.lts" => "Linux LTS",
                "badge.recommended" => "Recommandé",
                "badge.balanced" => "Équilibré",
                "badge.fallback" => "Repli",
                "desc.cachy" => "Noyau optimisé pour le jeu et un bureau réactif. Recommandé quand CPU/GPU et pilote conviennent.",
                "desc.zen" => "Option équilibrée entre performance, réactivité et stabilité.",
                "desc.lts" => "Option conservatrice pour compatibilité maximale et repli.",
                "backup.ready" => "Système prêt pour un enregistrement de repli.",
                "backup.desc" => "Le snapshot local enregistre paquets, noyau, pilote, dépôts et Flatpaks.",
                "backup.boot" => "Le vrai repli de noyau reste dans le module Noyau + Pilote.",
                "button.manage_backups" => "Gérer les sauvegardes",
                "status.updated" => "Base locale consultée",
                "status.driver" => "Pilote vidéo détecté",
                "status.backup" => "Snapshot local disponible",
                "status.conflicts" => "Aucun conflit détecté",
                "status.ok" => "Tout est bon",
                "button.analyze" => "Analyser le système",
                "button.analyze.sub" => "Détecter matériel et état",
                "button.update" => "Mettre à jour",
                "button.update.sub" => "Aperçu sûr disponible",
                "button.test_kernel" => "Tester le noyau",
                "button.test_kernel.sub" => "Recommander un noyau",
                "button.create_backup" => "Créer sauvegarde",
                "button.create_backup.sub" => "Sauver l'état actuel",
                "button.apply" => "Appliquer",
                "button.apply.sub" => "Mode sûr V1",
                "tab.kernel.title" => "Noyau + Pilote",
                "tab.kernel.body" => "Cette zone lit CPU, GPU, noyau et pilote pour recommander un chemin sûr. L'application réelle du noyau/pilote reste séparée et explicite.",
                "tab.benchmark.title" => "Benchmark",
                "tab.benchmark.body" => "Zone réservée aux tests rapides avant/après mise à jour.",
                "tab.backup.title" => "Sauvegardes locales",
                "tab.backup.body" => "Cette version enregistre l'état du système pour diagnostic et retour manuel sûr.",
                "tab.settings.title" => "Paramètres",
                "tab.settings.lang" => "Langue détectée",
                "tab.settings.supported" => "Langues prises en charge : portugais, anglais, français et espagnol. Tout autre locale utilise l'anglais.",
                "tab.about.title" => "À propos",
                "tab.about.body" => "Mocha Updater — interface responsive, détection, i18n, journaux et actions sûres pour validation initiale.",
                "log.ready" => "Mocha Updater démarré.",
                "log.analyze" => "Analyse du système terminée.",
                "log.preview" => "Aperçu des mises à jour terminé. Aucune modification appliquée.",
                "log.kernel" => "Test du noyau terminé.",
                "log.backup" => "Snapshot local créé.",
                "log.apply" => "Mode sûr V1 : aucune mise à jour réelle appliquée.",
                "unknown" => "Non détecté",
                _ => Lang::En.t(key),
            },
            Lang::Es => match key {
                "app.subtitle" => "Actualizaciones inteligentes para máximo rendimiento.",
                "menu.general" => "Actualización general",
                "menu.kernel" => "Kernel + Controlador",
                "menu.benchmark" => "Benchmark",
                "menu.backup" => "Copia / Fallback",
                "menu.logs" => "Registros",
                "menu.settings" => "Configuración",
                "menu.about" => "Acerca de",
                "section.system" => "Información del sistema",
                "section.kernel" => "Recomendaciones de kernel",
                "section.backup" => "Copia y fallback",
                "section.status" => "Resumen de estado",
                "field.cpu" => "CPU",
                "field.gpu" => "GPU",
                "field.kernel" => "Kernel actual",
                "field.driver" => "Controlador de vídeo",
                "field.arch" => "Arquitectura",
                "field.distro" => "Distribución",
                "field.hostname" => "Hostname",
                "field.uptime" => "Tiempo activo",
                "field.pacman" => "Pacman",
                "field.flatpak" => "Flatpak",
                "pending.one" => "pendiente",
                "pending.many" => "pendientes",
                "kernel.cachy" => "CachyOS",
                "kernel.zen" => "Arch Zen",
                "kernel.lts" => "Linux LTS",
                "badge.recommended" => "Recomendado",
                "badge.balanced" => "Equilibrado",
                "badge.fallback" => "Fallback",
                "desc.cachy" => "Kernel optimizado para juegos y escritorio responsivo. Recomendado cuando CPU/GPU y controlador son adecuados.",
                "desc.zen" => "Opción equilibrada entre rendimiento, respuesta y estabilidad.",
                "desc.lts" => "Opción conservadora para máxima compatibilidad y fallback.",
                "backup.ready" => "Sistema listo para registro de fallback.",
                "backup.desc" => "El snapshot local registra paquetes, kernel, controlador, repositorios y Flatpaks.",
                "backup.boot" => "El rollback real de kernel queda en el módulo Kernel + Controlador.",
                "button.manage_backups" => "Gestionar copias",
                "status.updated" => "Base local consultada",
                "status.driver" => "Controlador de vídeo detectado",
                "status.backup" => "Snapshot local disponible",
                "status.conflicts" => "Sin conflictos detectados",
                "status.ok" => "Todo correcto",
                "button.analyze" => "Analizar sistema",
                "button.analyze.sub" => "Detectar hardware y estado",
                "button.update" => "Actualizar sistema",
                "button.update.sub" => "Vista previa segura",
                "button.test_kernel" => "Probar kernel",
                "button.test_kernel.sub" => "Recomendar kernel",
                "button.create_backup" => "Crear copia",
                "button.create_backup.sub" => "Guardar estado actual",
                "button.apply" => "Aplicar",
                "button.apply.sub" => "Modo seguro V1",
                "tab.kernel.title" => "Kernel + Controlador",
                "tab.kernel.body" => "Esta área lee CPU, GPU, kernel y controlador para recomendar una ruta segura. La aplicación real de kernel/controlador permanece separada y explícita.",
                "tab.benchmark.title" => "Benchmark",
                "tab.benchmark.body" => "Área reservada para pruebas rápidas antes/después de actualizar.",
                "tab.backup.title" => "Copias locales",
                "tab.backup.body" => "Esta versión registra el estado del sistema para diagnóstico y retorno manual seguro.",
                "tab.settings.title" => "Configuración",
                "tab.settings.lang" => "Idioma detectado",
                "tab.settings.supported" => "Idiomas soportados: portugués, inglés, francés y español. Cualquier otro locale cae a inglés.",
                "tab.about.title" => "Acerca de",
                "tab.about.body" => "Mocha Updater — interfaz responsiva, detección, i18n, registros y acciones seguras para validación inicial.",
                "log.ready" => "Mocha Updater iniciado.",
                "log.analyze" => "Análisis del sistema concluido.",
                "log.preview" => "Vista previa de actualizaciones concluida. No se aplicó ningún cambio.",
                "log.kernel" => "Prueba de kernel concluida.",
                "log.backup" => "Snapshot local creado.",
                "log.apply" => "Modo seguro V1: no se aplicó ninguna actualización real.",
                "unknown" => "No detectado",
                _ => Lang::En.t(key),
            },
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Tab {
    General,
    Kernel,
    Benchmark,
    Backup,
    Logs,
    Settings,
    About,
}

struct SystemInfo {
    cpu: String,
    gpu: String,
    kernel: String,
    driver: String,
    arch: String,
    distro: String,
    hostname: String,
    uptime: String,
    pacman_pending: usize,
    flatpak_pending: usize,
    kernel_rec: String,
    kernel_version_hint: String,
}

impl SystemInfo {
    fn collect(lang: Lang) -> Self {
        let unknown = lang.t("unknown").to_string();

        let cpu = first_cpu().unwrap_or_else(|| unknown.clone());
        let gpu = first_gpu().unwrap_or_else(|| unknown.clone());
        let kernel = cmd("uname", &["-r"]).unwrap_or_else(|| unknown.clone());
        let arch = cmd("uname", &["-m"]).unwrap_or_else(|| unknown.clone());
        let driver = nvidia_driver().unwrap_or_else(|| unknown.clone());
        let distro = os_pretty_name().unwrap_or_else(|| unknown.clone());
        let hostname = hostname().unwrap_or_else(|| unknown.clone());
        let uptime = uptime_human().unwrap_or_else(|| unknown.clone());
        let pacman_pending = shell_count("pacman -Qu 2>/dev/null || true");
        let flatpak_pending = shell_count("flatpak remote-ls --updates 2>/dev/null || true");

        let (kernel_rec, kernel_version_hint) = recommend_kernel(&cpu, &gpu, &driver, &kernel, lang);

        Self {
            cpu,
            gpu,
            kernel,
            driver,
            arch,
            distro,
            hostname,
            uptime,
            pacman_pending,
            flatpak_pending,
            kernel_rec,
            kernel_version_hint,
        }
    }
}

struct MochaUpdater {
    lang: Lang,
    tab: Tab,
    info: SystemInfo,
    logs: Vec<String>,
}

impl MochaUpdater {
    fn new(cc: &eframe::CreationContext<'_>) -> Self {
        apply_visuals(&cc.egui_ctx);

        let lang = Lang::detect();
        let info = SystemInfo::collect(lang);
        let mut app = Self {
            lang,
            tab: Tab::General,
            info,
            logs: Vec::new(),
        };
        app.push_log(lang.t("log.ready"));
        app
    }

    fn push_log(&mut self, msg: &str) {
        let stamp = cmd("date", &["+%F %T"]).unwrap_or_else(|| "time-unknown".to_string());
        self.logs.push(format!("[{}] {}", stamp.trim(), msg));
        if self.logs.len() > 400 {
            let keep_from = self.logs.len().saturating_sub(400);
            self.logs.drain(0..keep_from);
        }
    }

    fn analyze(&mut self) {
        self.info = SystemInfo::collect(self.lang);
        self.push_log(self.lang.t("log.analyze"));
    }

    fn preview_updates(&mut self) {
        let pacman = shell("pacman -Qu 2>/dev/null | head -80 || true").unwrap_or_default();
        let flatpak = shell("flatpak remote-ls --updates 2>/dev/null | head -80 || true").unwrap_or_default();

        self.push_log(self.lang.t("log.preview"));

        if pacman.trim().is_empty() {
            self.push_log("pacman: 0");
        } else {
            self.push_log("pacman:");
            for line in pacman.lines().take(20) {
                self.push_log(&format!("  {}", line));
            }
        }

        if flatpak.trim().is_empty() {
            self.push_log("flatpak: 0");
        } else {
            self.push_log("flatpak:");
            for line in flatpak.lines().take(20) {
                self.push_log(&format!("  {}", line));
            }
        }

        self.info = SystemInfo::collect(self.lang);
    }

    fn test_kernel(&mut self) {
        let flags = shell("grep -m1 '^flags' /proc/cpuinfo 2>/dev/null || true").unwrap_or_default();
        let gpu = shell("lspci 2>/dev/null | grep -Ei 'vga|3d|display' || true").unwrap_or_default();

        self.push_log(self.lang.t("log.kernel"));
        self.push_log(&format!("CPU flags: {}", shorten_single_line(&flags, 180)));
        self.push_log(&format!("GPU: {}", shorten_single_line(&gpu, 180)));
        self.push_log(&format!("Recomendação: {}", self.info.kernel_rec));
    }

    fn create_backup(&mut self) {
        match create_snapshot() {
            Ok(path) => {
                self.push_log(self.lang.t("log.backup"));
                self.push_log(&format!("snapshot: {}", path.display()));
            }
            Err(err) => {
                self.push_log(&format!("snapshot erro: {}", err));
            }
        }
    }

    fn apply_safe(&mut self) {
        self.push_log(self.lang.t("log.apply"));
    }
}

impl eframe::App for MochaUpdater {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        apply_visuals(ctx);

        egui::TopBottomPanel::top("top_bar")
            .exact_height(34.0)
            .frame(egui::Frame::none().fill(mocha_panel()))
            .show(ctx, |ui| {
                ui.horizontal_centered(|ui| {
                    ui.label(RichText::new("☕  Mocha Updater").color(mocha_text()).size(16.0));
                });
            });

        egui::SidePanel::left("sidebar")
            .resizable(false)
            .exact_width(218.0)
            .frame(egui::Frame::none().fill(mocha_sidebar()).stroke(Stroke::new(1.0, mocha_border())))
            .show(ctx, |ui| {
                ui.add_space(10.0);

                sidebar_button(ui, &mut self.tab, Tab::General, &format!("▣  {}", self.lang.t("menu.general")));
                sidebar_button(ui, &mut self.tab, Tab::Kernel, &format!("⚙  {}", self.lang.t("menu.kernel")));
                sidebar_button(ui, &mut self.tab, Tab::Benchmark, &format!("◷  {}", self.lang.t("menu.benchmark")));
                sidebar_button(ui, &mut self.tab, Tab::Backup, &format!("▣  {}", self.lang.t("menu.backup")));
                sidebar_button(ui, &mut self.tab, Tab::Logs, &format!("□  {}", self.lang.t("menu.logs")));

                ui.with_layout(egui::Layout::bottom_up(egui::Align::Min), |ui| {
                    ui.add_space(10.0);
                    ui.label(RichText::new("Mocha Updater v1.0.0").color(mocha_orange()).size(12.0));
                    sidebar_button(ui, &mut self.tab, Tab::About, &format!("□  {}", self.lang.t("menu.about")));
                    sidebar_button(ui, &mut self.tab, Tab::Settings, &format!("⚙  {}", self.lang.t("menu.settings")));
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
                                ui.label(RichText::new(self.lang.t("app.subtitle")).size(14.0).color(mocha_orange()));
                            });
                        });

                        ui.add_space(18.0);

                        match self.tab {
                            Tab::General => self.ui_general(ui),
                            Tab::Kernel => self.ui_simple(ui, self.lang.t("tab.kernel.title"), self.lang.t("tab.kernel.body")),
                            Tab::Benchmark => self.ui_simple(ui, self.lang.t("tab.benchmark.title"), self.lang.t("tab.benchmark.body")),
                            Tab::Backup => self.ui_simple(ui, self.lang.t("tab.backup.title"), self.lang.t("tab.backup.body")),
                            Tab::Logs => self.ui_logs(ui),
                            Tab::Settings => self.ui_settings(ui),
                            Tab::About => self.ui_simple(ui, self.lang.t("tab.about.title"), self.lang.t("tab.about.body")),
                        }

                        ui.add_space(24.0);
                    });
            });
    }
}

impl MochaUpdater {
    fn ui_general(&mut self, ui: &mut egui::Ui) {
        let width = ui.available_width();
        let two_cols = width >= 980.0;
        let gap = 14.0;
        let card_width = if two_cols { (width - gap) / 2.0 } else { width };

        if two_cols {
            ui.horizontal_top(|ui| {
                card(ui, card_width, |ui| self.ui_system_card(ui));
                ui.add_space(gap);
                card(ui, card_width, |ui| self.ui_kernel_card(ui));
            });
            ui.add_space(gap);
            ui.horizontal_top(|ui| {
                card(ui, card_width, |ui| self.ui_backup_card(ui));
                ui.add_space(gap);
                card(ui, card_width, |ui| self.ui_status_card(ui));
            });
        } else {
            card(ui, card_width, |ui| self.ui_system_card(ui));
            ui.add_space(gap);
            card(ui, card_width, |ui| self.ui_kernel_card(ui));
            ui.add_space(gap);
            card(ui, card_width, |ui| self.ui_backup_card(ui));
            ui.add_space(gap);
            card(ui, card_width, |ui| self.ui_status_card(ui));
        }

        ui.add_space(16.0);
        self.ui_actions(ui);
    }

    fn ui_system_card(&self, ui: &mut egui::Ui) {
        section_title(ui, self.lang.t("section.system"));
        ui.add_space(8.0);

        info_row(ui, self.lang.t("field.cpu"), &self.info.cpu);
        info_row(ui, self.lang.t("field.gpu"), &self.info.gpu);
        info_row(ui, self.lang.t("field.kernel"), &self.info.kernel);
        info_row(ui, self.lang.t("field.driver"), &self.info.driver);
        info_row(ui, self.lang.t("field.arch"), &self.info.arch);
        info_row(ui, self.lang.t("field.distro"), &self.info.distro);
        info_row(ui, self.lang.t("field.hostname"), &self.info.hostname);
        info_row(ui, self.lang.t("field.uptime"), &self.info.uptime);
        info_row(ui, self.lang.t("field.pacman"), &pending_text(self.lang, self.info.pacman_pending));
        info_row(ui, self.lang.t("field.flatpak"), &pending_text(self.lang, self.info.flatpak_pending));
    }

    fn ui_kernel_card(&self, ui: &mut egui::Ui) {
        section_title(ui, self.lang.t("section.kernel"));
        ui.add_space(8.0);

        kernel_option(
            ui,
            self.lang.t("kernel.cachy"),
            self.lang.t("badge.recommended"),
            mocha_green(),
            &self.info.kernel_version_hint,
            self.lang.t("desc.cachy"),
        );

        ui.separator();

        kernel_option(
            ui,
            self.lang.t("kernel.zen"),
            self.lang.t("badge.balanced"),
            mocha_orange(),
            "linux-zen",
            self.lang.t("desc.zen"),
        );

        ui.separator();

        kernel_option(
            ui,
            self.lang.t("kernel.lts"),
            self.lang.t("badge.fallback"),
            mocha_muted(),
            "linux-lts",
            self.lang.t("desc.lts"),
        );
    }

    fn ui_backup_card(&mut self, ui: &mut egui::Ui) {
        section_title(ui, self.lang.t("section.backup"));
        ui.add_space(8.0);

        ui.label(RichText::new(self.lang.t("backup.ready")).strong().color(mocha_text()).size(15.0));
        ui.add_space(4.0);
        ui.label(RichText::new(self.lang.t("backup.desc")).color(mocha_muted()).size(13.0));
        ui.add_space(4.0);
        ui.label(RichText::new(self.lang.t("backup.boot")).color(mocha_orange()).size(13.0));

        ui.add_space(12.0);
        if ui.add_sized(
            [ui.available_width().min(220.0), 38.0],
            egui::Button::new(RichText::new(self.lang.t("button.manage_backups")).color(mocha_text()))
                .fill(mocha_button()),
        ).clicked() {
            self.create_backup();
        }
    }

    fn ui_status_card(&self, ui: &mut egui::Ui) {
        section_title(ui, self.lang.t("section.status"));
        ui.add_space(8.0);

        status_line(ui, self.lang.t("status.updated"));
        status_line(ui, self.lang.t("status.driver"));
        status_line(ui, self.lang.t("status.backup"));
        status_line(ui, self.lang.t("status.conflicts"));

        ui.add_space(10.0);
        ui.label(RichText::new(format!("✓  {}", self.lang.t("status.ok"))).size(24.0).color(mocha_orange()));
    }

    fn ui_actions(&mut self, ui: &mut egui::Ui) {
        let width = ui.available_width();
        let min_button = 176.0;
        let gap = 8.0;
        let columns = ((width + gap) / (min_button + gap)).floor().clamp(1.0, 5.0) as usize;
        let button_width = ((width - gap * (columns.saturating_sub(1) as f32)) / columns as f32).max(160.0);

        let actions = [
            (self.lang.t("button.analyze"), self.lang.t("button.analyze.sub"), 0usize),
            (self.lang.t("button.update"), self.lang.t("button.update.sub"), 1usize),
            (self.lang.t("button.test_kernel"), self.lang.t("button.test_kernel.sub"), 2usize),
            (self.lang.t("button.create_backup"), self.lang.t("button.create_backup.sub"), 3usize),
            (self.lang.t("button.apply"), self.lang.t("button.apply.sub"), 4usize),
        ];

        egui::Grid::new("actions_grid")
            .num_columns(columns)
            .spacing([gap, gap])
            .show(ui, |ui| {
                for (idx, (title, subtitle, action)) in actions.iter().enumerate() {
                    if action_button(ui, title, subtitle, button_width, *action == 4) {
                        match action {
                            0 => self.analyze(),
                            1 => self.preview_updates(),
                            2 => self.test_kernel(),
                            3 => self.create_backup(),
                            4 => self.apply_safe(),
                            _ => {}
                        }
                    }

                    if (idx + 1) % columns == 0 {
                        ui.end_row();
                    }
                }
            });
    }

    fn ui_logs(&self, ui: &mut egui::Ui) {
        section_title(ui, self.lang.t("menu.logs"));
        ui.add_space(8.0);

        egui::Frame::none()
            .fill(mocha_card())
            .stroke(Stroke::new(1.0, mocha_border()))
            .inner_margin(egui::Margin::same(12))
            .show(ui, |ui| {
                egui::ScrollArea::vertical()
                    .max_height(520.0)
                    .auto_shrink([false, false])
                    .stick_to_bottom(true)
                    .show(ui, |ui| {
                        for line in &self.logs {
                            ui.label(RichText::new(line).monospace().color(mocha_text()).size(13.0));
                        }
                    });
            });
    }

    fn ui_settings(&self, ui: &mut egui::Ui) {
        self.ui_simple(ui, self.lang.t("tab.settings.title"), self.lang.t("tab.settings.supported"));
        ui.add_space(10.0);
        ui.label(RichText::new(format!("{}: {}", self.lang.t("tab.settings.lang"), self.lang.code())).color(mocha_text()));
        ui.label(RichText::new("LC_ALL → LC_MESSAGES → LANG → fallback en").color(mocha_orange()));
    }

    fn ui_simple(&self, ui: &mut egui::Ui, title: &str, body: &str) {
        card(ui, ui.available_width(), |ui| {
            section_title(ui, title);
            ui.add_space(10.0);
            ui.label(RichText::new(body).color(mocha_text()).size(16.0));
        });
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
    visuals.selection.stroke = Stroke::new(1.0, mocha_orange());
    visuals.widgets.noninteractive.bg_fill = mocha_card();
    visuals.widgets.inactive.bg_fill = mocha_button();
    visuals.widgets.hovered.bg_fill = mocha_button_hover();
    visuals.widgets.active.bg_fill = mocha_button_active();
    visuals.widgets.inactive.fg_stroke = Stroke::new(1.0, mocha_text());
    visuals.widgets.hovered.fg_stroke = Stroke::new(1.0, mocha_text());
    visuals.widgets.active.fg_stroke = Stroke::new(1.0, mocha_text());
    ctx.set_visuals(visuals);
}

fn sidebar_button(ui: &mut egui::Ui, current: &mut Tab, tab: Tab, label: &str) {
    let selected = *current == tab;
    let fill = if selected { mocha_button_active() } else { mocha_button() };

    let button = egui::Button::new(
        RichText::new(label).color(mocha_text()).size(15.0)
    )
    .fill(fill);

    if ui.add_sized([ui.available_width(), 42.0], button).clicked() {
        *current = tab;
    }

    ui.add_space(5.0);
}

fn card<R>(ui: &mut egui::Ui, width: f32, add_contents: impl FnOnce(&mut egui::Ui) -> R) -> R {
    egui::Frame::none()
        .fill(mocha_card())
        .stroke(Stroke::new(1.0, mocha_border()))
        .inner_margin(egui::Margin::same(12))
        .show(ui, |ui| {
            ui.set_width(width.max(240.0));
            add_contents(ui)
        })
        .inner
}

fn section_title(ui: &mut egui::Ui, title: &str) {
    ui.label(RichText::new(title).strong().size(18.0).color(mocha_text()));
}

fn info_row(ui: &mut egui::Ui, key: &str, val: &str) {
    ui.horizontal_wrapped(|ui| {
        ui.set_min_height(22.0);
        ui.label(RichText::new(format!("{}:", key)).color(mocha_orange()).size(13.0));
        ui.label(RichText::new(shorten_single_line(val, 90)).color(mocha_text()).size(13.0));
    });
}

fn kernel_option(ui: &mut egui::Ui, name: &str, badge: &str, badge_color: Color32, version: &str, desc: &str) {
    ui.vertical(|ui| {
        ui.horizontal_wrapped(|ui| {
            ui.label(RichText::new(name).strong().color(mocha_text()).size(15.0));
            ui.label(RichText::new(format!("({})", badge)).color(badge_color).size(13.0));
            ui.label(RichText::new(version).color(mocha_text()).size(13.0));
        });
        ui.add_space(3.0);
        ui.label(RichText::new(desc).color(mocha_muted()).size(13.0));
    });
}

fn status_line(ui: &mut egui::Ui, text: &str) {
    ui.horizontal_wrapped(|ui| {
        ui.label(RichText::new("✓").color(mocha_orange()).strong());
        ui.label(RichText::new(text).color(mocha_text()).size(13.0));
    });
}

fn action_button(ui: &mut egui::Ui, title: &str, subtitle: &str, width: f32, primary: bool) -> bool {
    let fill = if primary { mocha_button_active() } else { mocha_button() };
    let text = RichText::new(format!("{}\n{}", title, subtitle))
        .color(mocha_text())
        .strong()
        .size(13.0);

    ui.add_sized(
        [width, 68.0],
        egui::Button::new(text).fill(fill),
    ).clicked()
}

fn pending_text(lang: Lang, count: usize) -> String {
    let word = if count == 1 {
        lang.t("pending.one")
    } else {
        lang.t("pending.many")
    };
    format!("{} {}", count, word)
}

fn recommend_kernel(cpu: &str, gpu: &str, driver: &str, kernel: &str, lang: Lang) -> (String, String) {
    let cpu_l = cpu.to_lowercase();
    let gpu_l = gpu.to_lowercase();
    let driver_l = driver.to_lowercase();
    let kernel_l = kernel.to_lowercase();

    let has_nvidia = gpu_l.contains("nvidia") || driver_l.contains("nvidia");
    let modern_cpu = cpu_l.contains("ryzen")
        || cpu_l.contains("i9")
        || cpu_l.contains("i7")
        || cpu_l.contains("i5")
        || cpu_l.contains("xeon");

    if has_nvidia && modern_cpu {
        let hint = if kernel_l.contains("cachyos") {
            kernel.to_string()
        } else {
            "linux-cachyos / linux-cachyos-nvidia".to_string()
        };
        (lang.t("kernel.cachy").to_string(), hint)
    } else if modern_cpu {
        (lang.t("kernel.zen").to_string(), "linux-zen".to_string())
    } else {
        (lang.t("kernel.lts").to_string(), "linux-lts".to_string())
    }
}

fn create_snapshot() -> Result<PathBuf, String> {
    let home = env::var("HOME").unwrap_or_else(|_| ".".to_string());
    let stamp = cmd("date", &["+%Y%m%d-%H%M%S"]).unwrap_or_else(|| "snapshot".to_string());
    let dir = PathBuf::from(home)
        .join(".local/share/mocha-updater/snapshots")
        .join(stamp.trim());

    fs::create_dir_all(&dir).map_err(|e| e.to_string())?;

    let items = [
        ("uname.txt", "uname -a 2>/dev/null || true"),
        ("os-release.txt", "cat /etc/os-release 2>/dev/null || true"),
        ("pacman-explicit.txt", "pacman -Qqe 2>/dev/null || true"),
        ("pacman-native.txt", "pacman -Qqn 2>/dev/null || true"),
        ("pacman-foreign.txt", "pacman -Qqm 2>/dev/null || true"),
        ("pacman-updates.txt", "pacman -Qu 2>/dev/null || true"),
        ("flatpak-list.txt", "flatpak list --app --columns=application,version,branch,origin 2>/dev/null || true"),
        ("repos.txt", "grep -nE '^[[]|^Include|^Server' /etc/pacman.conf /etc/pacman.d/*.conf 2>/dev/null || true"),
        ("gpu.txt", "lspci 2>/dev/null | grep -Ei 'vga|3d|display|nvidia|amd|intel' || true"),
        ("nvidia.txt", "nvidia-smi 2>/dev/null || true"),
    ];

    for (name, command) in items {
        let out = shell(command).unwrap_or_default();
        fs::write(dir.join(name), out).map_err(|e| e.to_string())?;
    }

    Ok(dir)
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
        .filter(|line| !line.trim().is_empty())
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

fn first_gpu() -> Option<String> {
    let out = shell("lspci 2>/dev/null | grep -Ei 'vga|3d|display' | head -1 || true")?;
    if out.trim().is_empty() {
        None
    } else {
        Some(out.trim().to_string())
    }
}

fn nvidia_driver() -> Option<String> {
    let out = shell("nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 || true")?;
    if out.trim().is_empty() {
        None
    } else {
        Some(format!("NVIDIA {} (Proprietário)", out.trim()))
    }
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

fn hostname() -> Option<String> {
    cmd("hostname", &[])
}

fn uptime_human() -> Option<String> {
    let data = fs::read_to_string("/proc/uptime").ok()?;
    let first = data.split_whitespace().next()?;
    let secs = first.split('.').next()?.parse::<u64>().ok()?;
    let days = secs / 86_400;
    let hours = (secs % 86_400) / 3_600;
    let minutes = (secs % 3_600) / 60;

    if days > 0 {
        Some(format!("{}d {:02}h {:02}m", days, hours, minutes))
    } else {
        Some(format!("{}h {:02}m", hours, minutes))
    }
}

fn shorten_single_line(input: &str, max_chars: usize) -> String {
    let one_line = input.split_whitespace().collect::<Vec<_>>().join(" ");
    let mut out = String::new();

    for ch in one_line.chars() {
        if out.chars().count() >= max_chars {
            out.push('…');
            return out;
        }
        out.push(ch);
    }

    out
}

fn mocha_bg() -> Color32 {
    Color32::from_rgb(12, 9, 7)
}

fn mocha_sidebar() -> Color32 {
    Color32::from_rgb(18, 14, 11)
}

fn mocha_panel() -> Color32 {
    Color32::from_rgb(26, 21, 17)
}

fn mocha_card() -> Color32 {
    Color32::from_rgb(28, 23, 18)
}

fn mocha_button() -> Color32 {
    Color32::from_rgb(34, 28, 23)
}

fn mocha_button_hover() -> Color32 {
    Color32::from_rgb(80, 46, 24)
}

fn mocha_button_active() -> Color32 {
    Color32::from_rgb(139, 76, 35)
}

fn mocha_border() -> Color32 {
    Color32::from_rgb(92, 55, 31)
}

fn mocha_text() -> Color32 {
    Color32::from_rgb(232, 222, 211)
}

fn mocha_title() -> Color32 {
    Color32::from_rgb(244, 201, 155)
}

fn mocha_muted() -> Color32 {
    Color32::from_rgb(185, 171, 157)
}

fn mocha_orange() -> Color32 {
    Color32::from_rgb(230, 132, 45)
}

fn mocha_green() -> Color32 {
    Color32::from_rgb(83, 190, 92)
}

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

ICON_DIR="/usr/share/pixmaps"
sudo mkdir -p "$ICON_DIR"

if [ ! -f "$ICON_DIR/mocha-updater.svg" ]; then
  sudo tee "$ICON_DIR/mocha-updater.svg" >/dev/null <<'MOCHA_ICON'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="128" height="128" rx="24" fill="#1c1712"/>
  <circle cx="64" cy="64" r="46" fill="#8b4c23"/>
  <path d="M39 72c4 14 16 23 31 23 17 0 31-12 33-28H39z" fill="#0c0907"/>
  <path d="M39 55h62v15H39z" fill="#f4c99b"/>
  <path d="M89 48c8 0 15 6 15 14s-7 14-15 14" fill="none" stroke="#f4c99b" stroke-width="8" stroke-linecap="round"/>
  <path d="M51 26c-7 8 7 12 0 21M67 24c-7 8 7 12 0 21M83 26c-7 8 7 12 0 21" fill="none" stroke="#e6842d" stroke-width="6" stroke-linecap="round"/>
</svg>
MOCHA_ICON
fi

DESKTOP_CANON="/usr/share/applications/mocha-updater.desktop"
sudo tee "$DESKTOP_CANON" >/dev/null <<'MOCHA_DESKTOP'
[Desktop Entry]
Type=Application
Name=Mocha Updater
Name[pt_BR]=Mocha Updater
Name[pt]=Mocha Updater
Name[fr]=Mocha Updater
Name[es]=Mocha Updater
Comment=Safe system, kernel and driver updater for Mocha
Comment[pt_BR]=Atualizador seguro de sistema, kernel e driver do Mocha
Comment[pt]=Atualizador seguro de sistema, kernel e driver do Mocha
Comment[fr]=Outil de mise à jour sûr du système, du noyau et du pilote pour Mocha
Comment[es]=Actualizador seguro de sistema, kernel y controlador para Mocha
Exec=/usr/local/bin/mocha-updater
Icon=mocha-updater
Terminal=false
Categories=System;Settings;
StartupNotify=true
MOCHA_DESKTOP

sudo chmod 0644 "$DESKTOP_CANON"

DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
mkdir -p "$DESKTOP_DIR"
install -m 0755 "$DESKTOP_CANON" "$DESKTOP_DIR/mocha-updater.desktop"

# Remove atalhos ultrapassados/duplicados do updater antigo e kernel-driver antigo.
LEGACY_NAMES=(
  "mocha-kernel-driver-manager.desktop"
  "mocha-kernel-driver-updater.desktop"
  "mocha-kernel-driver.desktop"
  "mocha-updater-gui.desktop"
  "mocha-updater-old.desktop"
)

for name in "${LEGACY_NAMES[@]}"; do
  rm -f "$DESKTOP_DIR/$name"
  sudo rm -f "/usr/share/applications/$name"
done

# Remove atalhos duplicados do próprio Mocha Updater, mantendo só o canônico.
find "$DESKTOP_DIR" -maxdepth 1 -type f -name '*mocha*updater*.desktop' ! -name 'mocha-updater.desktop' -delete 2>/dev/null || true
sudo find /usr/share/applications -maxdepth 1 -type f -name '*mocha*updater*.desktop' ! -name 'mocha-updater.desktop' -delete 2>/dev/null || true

update-desktop-database /usr/share/applications >/dev/null 2>&1 || true

ok "Mocha Updater recompilado e instalado em /usr/local/bin/mocha-updater"
ok "Atalho canônico do menu: /usr/share/applications/mocha-updater.desktop"
ok "Atalho canônico da área de trabalho: $DESKTOP_DIR/mocha-updater.desktop"
ok "Backup do main.rs anterior: $APP/src/main.rs.bak-ui-responsiva-$STAMP"

echo
echo "Teste agora com:"
echo "  /usr/local/bin/mocha-updater"
