use std::env;
use std::fs::{self, OpenOptions};
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::Command;

const CACHY_KEY: &str = "F3B607488DB35A47";
const LOG_PATH: &str = "/var/log/mocha-firstboot-stack.log";

#[derive(Clone, Debug)]
struct CpuProfile {
    label: String,
    arch_line: String,
    mirror_arch: String,
    optimized_repos: Vec<String>,
}

#[derive(Clone, Debug)]
struct PackageTarget {
    repo: String,
    pkg: String,
    version: String,
    arch: String,
}

impl PackageTarget {
    fn spec(&self) -> String {
        format!("{}/{}", self.repo, self.pkg)
    }

    fn display(&self) -> String {
        format!("{} {} [{}]", self.spec(), self.version, self.arch)
    }
}

struct Logger {
    file: fs::File,
}

impl Logger {
    fn new() -> Result<Self, String> {
        let owner = env::var("SUDO_USER")
            .or_else(|_| env::var("USER"))
            .unwrap_or_else(|_| "root".to_string());

        let _ = Command::new("sudo")
            .env("LC_ALL", "C")
            .env("LANG", "C")
            .arg("install")
            .arg("-m")
            .arg("0664")
            .arg("-o")
            .arg(&owner)
            .arg("-g")
            .arg(&owner)
            .arg("/dev/null")
            .arg(LOG_PATH)
            .status();

        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(LOG_PATH)
            .map_err(|e| format!("não consegui abrir log {}: {}", LOG_PATH, e))?;

        Ok(Self { file })
    }

    fn line<S: AsRef<str>>(&mut self, text: S) {
        let s = text.as_ref();
        println!("{}", s);
        let _ = writeln!(self.file, "{}", s);
        let _ = self.file.flush();
    }

    fn raw<S: AsRef<str>>(&mut self, text: S) {
        let s = text.as_ref();
        print!("{}", s);
        let _ = write!(self.file, "{}", s);
        let _ = self.file.flush();
    }
}

fn command_output(program: &str, args: &[&str]) -> Option<String> {
    let output = Command::new(program)
        .env("LC_ALL", "C")
        .env("LANG", "C")
        .args(args)
        .output()
        .ok()?;

    if !output.status.success() {
        return None;
    }

    Some(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

fn local_pkg_version(pkg: &str) -> Option<String> {
    let out = command_output("pacman", &["-Q", pkg])?;
    let mut parts = out.split_whitespace();
    let _name = parts.next()?;
    let version = parts.next()?;
    Some(version.to_string())
}

fn current_kernel_runtime() -> String {
    command_output("uname", &["-r"]).unwrap_or_else(|| "indisponível".to_string())
}

fn current_pkg_line(pkg: &str) -> String {
    match local_pkg_version(pkg) {
        Some(v) => format!("{} {}", pkg, v),
        None => format!("{} não instalado", pkg),
    }
}

fn first_installed_pkg(pkgs: &[&str]) -> String {
    for pkg in pkgs {
        if let Some(v) = local_pkg_version(pkg) {
            return format!("{} {}", pkg, v);
        }
    }

    "não instalado".to_string()
}

fn run_capture(log: &mut Logger, program: &str, args: &[String]) -> Result<String, String> {
    log.line(format!("+ {} {}", program, args.join(" ")));

    let output = Command::new(program)
        .env("LC_ALL", "C")
        .env("LANG", "C")
        .args(args)
        .output()
        .map_err(|e| format!("falha ao executar {}: {}", program, e))?;

    let stdout = String::from_utf8_lossy(&output.stdout).to_string();
    let stderr = String::from_utf8_lossy(&output.stderr).to_string();

    if !stdout.is_empty() {
        log.raw(&stdout);
    }

    if !stderr.is_empty() {
        log.raw(&stderr);
    }

    if output.status.success() {
        Ok(stdout)
    } else {
        Err(format!(
            "comando falhou: {} {}\nstderr: {}",
            program,
            args.join(" "),
            stderr.trim()
        ))
    }
}

fn run(log: &mut Logger, program: &str, args: &[String]) -> Result<(), String> {
    run_capture(log, program, args).map(|_| ())
}

fn sudo_capture(log: &mut Logger, args: &[String]) -> Result<String, String> {
    let mut v = Vec::new();
    v.push("env".to_string());
    v.push("LC_ALL=C".to_string());
    v.push("LANG=C".to_string());
    v.extend_from_slice(args);
    run_capture(log, "sudo", &v)
}

fn sudo(log: &mut Logger, args: &[String]) -> Result<(), String> {
    sudo_capture(log, args).map(|_| ())
}

fn sudo_plain(log: &mut Logger, args: &[String]) -> Result<(), String> {
    run(log, "sudo", args)
}

fn progress(log: &mut Logger, pct: u8, msg: &str) {
    log.line(format!("[{:>3}%] {}", pct, msg));
}

fn yes_no(question: &str, default_yes: bool) -> bool {
    let suffix = if default_yes { "[S/n]" } else { "[s/N]" };
    print!("{} {} ", question, suffix);
    let _ = io::stdout().flush();

    let mut answer = String::new();
    if io::stdin().read_line(&mut answer).is_err() {
        return default_yes;
    }

    let a = answer.trim().to_lowercase();
    if a.is_empty() {
        return default_yes;
    }

    matches!(a.as_str(), "s" | "sim" | "y" | "yes")
}

fn detect_cpu_profile(log: &mut Logger) -> CpuProfile {
    let help = run_capture(log, "/lib/ld-linux-x86-64.so.2", &[String::from("--help")])
        .unwrap_or_default();

    let has_v4 = help
        .lines()
        .any(|l| l.contains("x86-64-v4") && l.contains("supported"));

    let has_v3 = help
        .lines()
        .any(|l| l.contains("x86-64-v3") && l.contains("supported"));

    if has_v4 {
        CpuProfile {
            label: "x86_64_v4".to_string(),
            arch_line: "Architecture = x86_64 x86_64_v4".to_string(),
            mirror_arch: "x86_64_v4".to_string(),
            optimized_repos: vec![
                "cachyos-v4".to_string(),
                "cachyos-core-v4".to_string(),
                "cachyos-extra-v4".to_string(),
            ],
        }
    } else if has_v3 {
        CpuProfile {
            label: "x86_64_v3".to_string(),
            arch_line: "Architecture = x86_64 x86_64_v3".to_string(),
            mirror_arch: "x86_64_v3".to_string(),
            optimized_repos: vec![
                "cachyos-v3".to_string(),
                "cachyos-core-v3".to_string(),
                "cachyos-extra-v3".to_string(),
            ],
        }
    } else {
        CpuProfile {
            label: "x86_64".to_string(),
            arch_line: "Architecture = x86_64".to_string(),
            mirror_arch: "x86_64".to_string(),
            optimized_repos: Vec::new(),
        }
    }
}

fn strip_cachyos_blocks(conf: &str) -> String {
    let mut out = String::new();
    let mut skip = false;

    for line in conf.lines() {
        let trimmed = line.trim();

        if trimmed.starts_with("[cachyos") && trimmed.ends_with(']') {
            skip = true;
            continue;
        }

        if trimmed.starts_with('[') && trimmed.ends_with(']') {
            skip = false;
        }

        if !skip {
            out.push_str(line);
            out.push('\n');
        }
    }

    out
}

fn replace_architecture(conf: &str, arch_line: &str) -> Result<String, String> {
    if !conf.lines().any(|l| l.trim() == "[options]") {
        return Err("pacman.conf sem bloco [options]".to_string());
    }

    let mut out = String::new();
    let mut in_options = false;
    let mut inserted = false;

    for line in conf.lines() {
        let trimmed = line.trim();

        if trimmed == "[options]" {
            in_options = true;
            out.push_str(line);
            out.push('\n');
            continue;
        }

        if in_options && trimmed.starts_with('[') && trimmed.ends_with(']') {
            if !inserted {
                out.push_str(arch_line);
                out.push('\n');
                inserted = true;
            }
            in_options = false;
            out.push_str(line);
            out.push('\n');
            continue;
        }

        if in_options && trimmed.starts_with("Architecture") {
            if !inserted {
                out.push_str(arch_line);
                out.push('\n');
                inserted = true;
            }
            continue;
        }

        out.push_str(line);
        out.push('\n');
    }

    if in_options && !inserted {
        out.push_str(arch_line);
        out.push('\n');
        inserted = true;
    }

    if !inserted {
        return Err("não consegui inserir Architecture no pacman.conf temporário".to_string());
    }

    Ok(out)
}

fn write_temp_pacman_conf(
    log: &mut Logger,
    profile: &CpuProfile,
    work: &Path,
) -> Result<PathBuf, String> {
    let original = fs::read_to_string("/etc/pacman.conf")
        .map_err(|e| format!("não consegui ler /etc/pacman.conf: {}", e))?;

    let sanitized = strip_cachyos_blocks(&original);
    let base = replace_architecture(&sanitized, &profile.arch_line)?;

    let conf_path = work.join("pacman-cachyos-temporario.conf");
    let mirror_opt = work.join("mirrorlist-cachyos-otimizado");
    let mirror_x64 = work.join("mirrorlist-cachyos-x86_64");

    let opt_servers = format!(
        "Server = https://mirror.cachyos.org/repo/{}/$repo\nServer = https://cdn.cachyos.org/repo/{}/$repo\nServer = https://cdn77.cachyos.org/repo/{}/$repo\n",
        profile.mirror_arch, profile.mirror_arch, profile.mirror_arch
    );

    let x64_servers = "Server = https://mirror.cachyos.org/repo/x86_64/$repo\nServer = https://cdn.cachyos.org/repo/x86_64/$repo\nServer = https://cdn77.cachyos.org/repo/x86_64/$repo\n";

    fs::write(&mirror_opt, opt_servers)
        .map_err(|e| format!("não consegui escrever mirrorlist otimizada: {}", e))?;

    fs::write(&mirror_x64, x64_servers)
        .map_err(|e| format!("não consegui escrever mirrorlist x86_64: {}", e))?;

    let mut temp = base;
    temp.push_str("\n# Mocha temporário — CachyOS restrito; não copiar para /etc/pacman.conf\n");

    for repo in &profile.optimized_repos {
        temp.push_str(&format!("[{}]\nInclude = {}\n", repo, mirror_opt.display()));
    }

    temp.push_str(&format!("[cachyos]\nInclude = {}\n", mirror_x64.display()));

    fs::write(&conf_path, temp)
        .map_err(|e| format!("não consegui escrever pacman.conf temporário: {}", e))?;

    log.line(format!("Arquitetura temporária: {}", profile.arch_line));
    log.line(format!("Arquivo temporário: {}", conf_path.display()));

    Ok(conf_path)
}

fn remove_persistent_cachyos(log: &mut Logger, stamp: &str) -> Result<(), String> {
    let original = fs::read_to_string("/etc/pacman.conf")
        .map_err(|e| format!("não consegui ler /etc/pacman.conf: {}", e))?;

    let sanitized = strip_cachyos_blocks(&original);

    if sanitized != original {
        sudo(
            log,
            &[
                "cp".to_string(),
                "-a".to_string(),
                "/etc/pacman.conf".to_string(),
                format!("/etc/pacman.conf.mocha-backup-{}", stamp),
            ],
        )?;

        let tmp = format!("/tmp/mocha-pacman-sem-cachyos-{}.conf", stamp);
        fs::write(&tmp, sanitized).map_err(|e| format!("não consegui escrever {}: {}", tmp, e))?;

        sudo(
            log,
            &[
                "install".to_string(),
                "-m".to_string(),
                "0644".to_string(),
                tmp,
                "/etc/pacman.conf".to_string(),
            ],
        )?;

        log.line("CachyOS permanente removido de /etc/pacman.conf.");
    } else {
        log.line("OK: /etc/pacman.conf sem CachyOS permanente.");
    }

    Ok(())
}

fn package_info(log: &mut Logger, conf: &Path, repo: &str, pkg: &str) -> Result<String, String> {
    run_capture(
        log,
        "pacman",
        &[
            "--config".to_string(),
            conf.display().to_string(),
            "-Si".to_string(),
            format!("{}/{}", repo, pkg),
        ],
    )
}

fn package_exists(log: &mut Logger, conf: &Path, repo: &str, pkg: &str) -> bool {
    package_info(log, conf, repo, pkg).is_ok()
}

fn pkg_field(info: &str, field: &str) -> Result<String, String> {
    for line in info.lines() {
        if let Some((k, v)) = line.split_once(':') {
            if k.trim() == field {
                return Ok(v.trim().to_string());
            }
        }
    }

    Err(format!("campo {} não encontrado no pacman -Si", field))
}

fn find_package(
    log: &mut Logger,
    conf: &Path,
    repos: &[String],
    pkg: &str,
) -> Result<PackageTarget, String> {
    for repo in repos {
        if let Ok(info) = package_info(log, conf, repo, pkg) {
            let version = pkg_field(&info, "Version")?;
            let arch = pkg_field(&info, "Architecture")?;

            return Ok(PackageTarget {
                repo: repo.clone(),
                pkg: pkg.to_string(),
                version,
                arch,
            });
        }
    }

    Err(format!(
        "pacote não encontrado nos repositórios temporários: {}",
        pkg
    ))
}

fn detect_nvidia(log: &mut Logger) -> bool {
    run_capture(log, "lspci", &[String::from("-nn")])
        .map(|s| s.lines().any(|l| l.to_lowercase().contains("nvidia")))
        .unwrap_or(false)
}

fn validate_arch(target: &PackageTarget, profile: &CpuProfile) -> Result<(), String> {
    if target.arch == "x86_64" || target.arch == profile.label {
        Ok(())
    } else {
        Err(format!(
            "arquitetura recusada para {}: pacote={}, computador={}",
            target.spec(),
            target.arch,
            profile.label
        ))
    }
}

fn build_plan(
    log: &mut Logger,
    conf: &Path,
    profile: &CpuProfile,
    nvidia: bool,
) -> Result<Vec<PackageTarget>, String> {
    let mut repos = profile.optimized_repos.clone();
    repos.push("cachyos".to_string());

    let kernel = find_package(log, conf, &repos, "linux-cachyos")?;
    let headers = find_package(log, conf, &repos, "linux-cachyos-headers")?;

    validate_arch(&kernel, profile)?;
    validate_arch(&headers, profile)?;

    if kernel.version != headers.version {
        return Err(format!(
            "kernel e headers não estão casados: linux-cachyos={} headers={}",
            kernel.version, headers.version
        ));
    }

    let mut targets = vec![kernel.clone(), headers];

    if nvidia {
        let module = if package_exists(log, conf, &kernel.repo, "linux-cachyos-nvidia-open") {
            find_package(
                log,
                conf,
                &[kernel.repo.clone()],
                "linux-cachyos-nvidia-open",
            )?
        } else if package_exists(log, conf, &kernel.repo, "linux-cachyos-nvidia") {
            find_package(log, conf, &[kernel.repo.clone()], "linux-cachyos-nvidia")?
        } else {
            find_package(log, conf, &repos, "linux-cachyos-nvidia-open")
                .or_else(|_| find_package(log, conf, &repos, "linux-cachyos-nvidia"))?
        };

        validate_arch(&module, profile)?;

        if module.version != kernel.version {
            return Err(format!(
                "módulo NVIDIA do kernel não casa com o kernel: linux-cachyos={} módulo={}",
                kernel.version, module.version
            ));
        }

        targets.push(module);

        let x64_repos = vec![
            "cachyos".to_string(),
            "extra".to_string(),
            "multilib".to_string(),
        ];

        for pkg in ["nvidia-utils", "lib32-nvidia-utils", "opencl-nvidia"] {
            let t = find_package(log, conf, &x64_repos, pkg)?;
            validate_arch(&t, profile)?;
            targets.push(t);
        }
    }

    Ok(targets)
}

fn find_target<'a>(targets: &'a [PackageTarget], pkg: &str) -> Option<&'a PackageTarget> {
    targets.iter().find(|t| t.pkg == pkg)
}

fn available_line(targets: &[PackageTarget], pkg: &str) -> String {
    match find_target(targets, pkg) {
        Some(t) => t.display(),
        None => format!("{} indisponível", pkg),
    }
}

fn available_video_module_line(targets: &[PackageTarget]) -> String {
    find_target(targets, "linux-cachyos-nvidia-open")
        .or_else(|| find_target(targets, "linux-cachyos-nvidia"))
        .map(|t| t.display())
        .unwrap_or_else(|| "módulo NVIDIA indisponível".to_string())
}

fn show_current_vs_available(
    log: &mut Logger,
    profile: &CpuProfile,
    targets: &[PackageTarget],
    nvidia: bool,
) {
    log.line("");
    log.line("============================================================");
    log.line(" Stack atual vs disponível");
    log.line("============================================================");
    log.line(format!("Arquitetura detectada: {}", profile.label));
    log.line("");

    log.line("Kernel:");
    log.line(format!(" - Em uso agora: {}", current_kernel_runtime()));
    log.line(format!(
        " - Pacote atual: {}",
        current_pkg_line("linux-cachyos")
    ));
    log.line(format!(
        " - Novo disponível: {}",
        available_line(targets, "linux-cachyos")
    ));
    log.line(format!(
        " - Headers atuais: {}",
        current_pkg_line("linux-cachyos-headers")
    ));
    log.line(format!(
        " - Headers disponíveis: {}",
        available_line(targets, "linux-cachyos-headers")
    ));

    log.line("");
    if nvidia {
        log.line("Driver de vídeo NVIDIA:");
        log.line(format!(
            " - Módulo atual do kernel: {}",
            first_installed_pkg(&["linux-cachyos-nvidia-open", "linux-cachyos-nvidia"])
        ));
        log.line(format!(
            " - Módulo disponível do kernel: {}",
            available_video_module_line(targets)
        ));
        log.line(format!(
            " - nvidia-utils atual: {}",
            current_pkg_line("nvidia-utils")
        ));
        log.line(format!(
            " - nvidia-utils disponível: {}",
            available_line(targets, "nvidia-utils")
        ));
        log.line(format!(
            " - lib32-nvidia-utils atual: {}",
            current_pkg_line("lib32-nvidia-utils")
        ));
        log.line(format!(
            " - lib32-nvidia-utils disponível: {}",
            available_line(targets, "lib32-nvidia-utils")
        ));
        log.line(format!(
            " - opencl-nvidia atual: {}",
            current_pkg_line("opencl-nvidia")
        ));
        log.line(format!(
            " - opencl-nvidia disponível: {}",
            available_line(targets, "opencl-nvidia")
        ));
    } else {
        log.line("Driver de vídeo:");
        log.line(" - NVIDIA não detectada; stack NVIDIA não será instalado.");
    }

    log.line("============================================================");
    log.line("");
}

fn grub_default_entry_from_cfg(cfg: &str) -> Option<String> {
    let mut submenu = String::new();

    for line in cfg.lines() {
        let trimmed = line.trim_start();

        if trimmed.starts_with("submenu ") {
            if let Some(title) = trimmed.split('\'').nth(1) {
                submenu = title.to_string();
            }
        }

        if trimmed.starts_with("menuentry ") {
            if let Some(title) = trimmed.split('\'').nth(1) {
                if title.contains("linux-cachyos")
                    && !title.to_lowercase().contains("bore")
                    && !title.to_lowercase().contains("fallback")
                {
                    if submenu.is_empty() {
                        return Some(title.to_string());
                    }

                    return Some(format!("{}>{}", submenu, title));
                }
            }
        }
    }

    None
}

fn install_stack(
    log: &mut Logger,
    conf: &Path,
    targets: &[PackageTarget],
    reinstall: bool,
) -> Result<(), String> {
    let mut args = vec![
        "pacman".to_string(),
        "--config".to_string(),
        conf.display().to_string(),
        "-S".to_string(),
        "--noconfirm".to_string(),
    ];

    if !reinstall {
        args.push("--needed".to_string());
    }

    for target in targets {
        args.push(target.spec());
    }

    sudo(log, &args)
}

fn usage() {
    println!("Mocha Stack Optimizer");
    println!("Uso:");
    println!("  mocha-firstboot-stack");
    println!("  mocha-firstboot-stack --yes");
    println!("  mocha-firstboot-stack --yes --reinstall");
    println!();
    println!("Antes de instalar, mostra:");
    println!("  - kernel em uso e pacote linux-cachyos atual");
    println!("  - kernel CachyOS novo disponível para a arquitetura detectada");
    println!("  - driver NVIDIA atual e driver disponível correspondente");
    println!();
    println!("Sem --yes, pede confirmação antes de aplicar.");
    println!("Com --reinstall, reinstala o stack mesmo quando já estiver atualizado.");
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.iter().any(|a| a == "--help" || a == "-h") {
        usage();
        return;
    }

    let mut log = match Logger::new() {
        Ok(l) => l,
        Err(e) => {
            eprintln!("ERRO: {}", e);
            std::process::exit(1);
        }
    };

    let assume_yes = args.iter().any(|a| a == "--yes" || a == "--noconfirm");
    let mut reinstall = args
        .iter()
        .any(|a| a == "--reinstall" || a == "--force-reinstall");

    log.line("============================================================");
    log.line(" Mocha Stack Optimizer — kernel CachyOS/NVIDIA dinâmico");
    log.line(format!(" Log: {}", LOG_PATH));
    log.line("============================================================");

    if let Err(e) = real_main(&mut log, assume_yes, &mut reinstall) {
        log.line(format!("[100%] Erro: {}", e));
        std::process::exit(1);
    }

    log.line("[100%] Concluído. Reinicie para entrar no kernel CachyOS escolhido.");
}

fn real_main(log: &mut Logger, assume_yes: bool, reinstall: &mut bool) -> Result<(), String> {
    let stamp = run_capture(log, "date", &[String::from("+%Y%m%d-%H%M%S")])
        .unwrap_or_else(|_| "sem-data".to_string())
        .trim()
        .to_string();

    progress(log, 1, "Iniciando Mocha Stack Optimizer");

    sudo_plain(log, &["-v".to_string()])?;

    let work = PathBuf::from(format!("/tmp/mocha-firstboot-stack-{}", stamp));
    fs::create_dir_all(&work)
        .map_err(|e| format!("não consegui criar {}: {}", work.display(), e))?;

    progress(
        log,
        5,
        "Removendo qualquer canal CachyOS permanente antes da atualização",
    );
    remove_persistent_cachyos(log, &stamp)?;

    progress(log, 10, "Sincronizando bases oficiais Arch/Mocha");
    sudo(
        log,
        &[
            "pacman".to_string(),
            "-Syy".to_string(),
            "--noconfirm".to_string(),
        ],
    )?;

    progress(log, 16, "Atualizando totalmente o sistema antes do kernel");
    sudo(
        log,
        &[
            "pacman".to_string(),
            "-Syu".to_string(),
            "--noconfirm".to_string(),
        ],
    )?;

    progress(log, 30, "Detectando arquitetura do processador");
    let profile = detect_cpu_profile(log);
    log.line(format!("Arquitetura escolhida: {}", profile.label));

    progress(
        log,
        38,
        "Importando chave CachyOS somente para esta transação",
    );
    sudo(
        log,
        &[
            "pacman-key".to_string(),
            "--recv-keys".to_string(),
            CACHY_KEY.to_string(),
            "--keyserver".to_string(),
            "keyserver.ubuntu.com".to_string(),
        ],
    )?;

    sudo(
        log,
        &[
            "pacman-key".to_string(),
            "--lsign-key".to_string(),
            CACHY_KEY.to_string(),
        ],
    )?;

    progress(log, 44, "Criando pacman.conf temporário restrito");
    let conf = write_temp_pacman_conf(log, &profile, &work)?;

    progress(log, 50, "Sincronizando bases temporárias CachyOS");
    sudo(
        log,
        &[
            "sh".to_string(),
            "-c".to_string(),
            "rm -f /var/lib/pacman/sync/cachyos*.db /var/lib/pacman/sync/cachyos*.db.sig"
                .to_string(),
        ],
    )?;

    sudo(
        log,
        &[
            "pacman".to_string(),
            "--config".to_string(),
            conf.display().to_string(),
            "-Syy".to_string(),
            "--noconfirm".to_string(),
        ],
    )?;

    progress(log, 58, "Montando plano dinâmico de kernel/driver");
    let nvidia = detect_nvidia(log);
    log.line(format!(
        "GPU NVIDIA detectada: {}",
        if nvidia { "sim" } else { "não" }
    ));

    let targets = build_plan(log, &conf, &profile, nvidia)?;

    show_current_vs_available(log, &profile, &targets, nvidia);

    log.line("Plano de instalação:");
    for t in &targets {
        log.line(format!(" - {}", t.display()));
    }

    if !assume_yes {
        if !*reinstall {
            *reinstall = yes_no(
                "Reinstalar todo o stack mesmo se já estiver atualizado?",
                false,
            );
        }

        if !yes_no("Aplicar este plano agora?", true) {
            return Err("operação cancelada pelo usuário".to_string());
        }
    }

    progress(
        log,
        60,
        if *reinstall {
            "Reinstalando todo o stack escolhido"
        } else {
            "Instalando/atualizando somente o necessário"
        },
    );

    install_stack(log, &conf, &targets, *reinstall)?;

    progress(log, 78, "Regerando initramfs");
    sudo(log, &["mkinitcpio".to_string(), "-P".to_string()])?;

    progress(
        log,
        86,
        "Regerando GRUB e definindo linux-cachyos não-Bore como default",
    );

    if Path::new("/boot/grub").is_dir() {
        sudo(
            log,
            &[
                "sed".to_string(),
                "-i".to_string(),
                "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/".to_string(),
                "/etc/default/grub".to_string(),
            ],
        )?;

        sudo(
            log,
            &[
                "grub-mkconfig".to_string(),
                "-o".to_string(),
                "/boot/grub/grub.cfg".to_string(),
            ],
        )?;

        let cfg = sudo_capture(log, &["cat".to_string(), "/boot/grub/grub.cfg".to_string()])?;

        if let Some(entry) = grub_default_entry_from_cfg(&cfg) {
            log.line(format!("GRUB default escolhido: {}", entry));
            sudo(log, &["grub-set-default".to_string(), entry])?;
        } else {
            log.line("AVISO: não encontrei entrada linux-cachyos não-Bore para grub-set-default.");
        }
    } else {
        log.line("AVISO: /boot/grub ausente; etapa GRUB pulada.");
    }

    progress(
        log,
        94,
        "Garantindo que CachyOS não ficou permanente no pacman.conf",
    );
    remove_persistent_cachyos(log, &stamp)?;

    progress(log, 98, "Verificação final");
    for pkg in [
        "linux-cachyos",
        "linux-cachyos-headers",
        "linux-cachyos-nvidia-open",
        "nvidia-utils",
        "lib32-nvidia-utils",
        "opencl-nvidia",
    ] {
        let _ = run_capture(log, "pacman", &["-Q".to_string(), pkg.to_string()]);
    }

    Ok(())
}
