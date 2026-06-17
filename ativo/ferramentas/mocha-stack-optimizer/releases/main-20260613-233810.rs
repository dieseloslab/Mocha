use std::env;
use std::fs;
use std::io::{self, Write};
use std::path::Path;
use std::process::{Command, Stdio};

#[derive(Clone, Debug)]
struct RemotePkg {
    repo: String,
    version: String,
    arch: String,
}

#[derive(Clone, Debug)]
struct GpuPlan {
    has_nvidia: bool,
    has_amd: bool,
    has_intel: bool,
    nvidia_legacy_risk: bool,
    raw_lspci: String,
}

fn capture(prog: &str, args: &[&str]) -> Result<String, String> {
    let out = Command::new(prog)
        .args(args)
        .output()
        .map_err(|e| format!("falha ao executar {}: {}", prog, e))?;

    if !out.status.success() {
        let err = String::from_utf8_lossy(&out.stderr).trim().to_string();
        if err.is_empty() {
            return Err(format!("{} retornou status de erro", prog));
        }
        return Err(err);
    }

    Ok(String::from_utf8_lossy(&out.stdout).trim().to_string())
}

fn shell(cmd: &str) -> Result<String, String> {
    capture("bash", &["-lc", cmd])
}

fn status_shell(cmd: &str) -> bool {
    Command::new("bash")
        .arg("-lc")
        .arg(cmd)
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn run_interactive(prog: &str, args: &[&str]) -> bool {
    Command::new(prog)
        .args(args)
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn sudo_status(args: &[&str]) -> bool {
    run_interactive("sudo", args)
}

fn ask_yes_no(prompt: &str) -> bool {
    print!("{} [s/N]: ", prompt);
    let _ = io::stdout().flush();

    let mut line = String::new();
    if io::stdin().read_line(&mut line).is_err() {
        return false;
    }

    let v = line.trim().to_lowercase();
    v == "s" || v == "sim" || v == "y" || v == "yes"
}

fn installed_version(pkg: &str) -> Option<String> {
    let cmd = format!("pacman -Q {} 2>/dev/null | awk '{{print $2}}'", pkg);
    shell(&cmd).ok().filter(|s| !s.trim().is_empty())
}

fn installed(pkg: &str) -> bool {
    installed_version(pkg).is_some()
}

fn remote_pkg_info(conf: &str, pkg: &str) -> Option<RemotePkg> {
    let out = Command::new("pacman")
        .arg("--config")
        .arg(conf)
        .arg("-Si")
        .arg(pkg)
        .output()
        .ok()?;

    if !out.status.success() {
        return None;
    }

    let text = String::from_utf8_lossy(&out.stdout);
    let mut repo = String::new();
    let mut version = String::new();
    let mut arch = String::new();

    for line in text.lines() {
        if let Some(v) = line.strip_prefix("Repository      :") {
            repo = v.trim().to_string();
        }
        if let Some(v) = line.strip_prefix("Version         :") {
            version = v.trim().to_string();
        }
        if let Some(v) = line.strip_prefix("Architecture    :") {
            arch = v.trim().to_string();
        }
    }

    if version.is_empty() {
        None
    } else {
        Some(RemotePkg { repo, version, arch })
    }
}

fn vercmp(a: &str, b: &str) -> i32 {
    let out = capture("vercmp", &[a, b]).unwrap_or_else(|_| "0".to_string());
    out.trim().parse::<i32>().unwrap_or(0)
}

fn current_kernel() -> String {
    capture("uname", &["-r"]).unwrap_or_else(|_| "desconhecido".to_string())
}

fn normalize_running_kernel_version(k: &str) -> String {
    let mut s = k.to_string();

    for marker in [
        "-cachyos",
        "-arch",
        "-zen",
        "-lts",
        "-MANJARO",
        "-generic",
        "-MOCHA",
    ] {
        if let Some(pos) = s.find(marker) {
            s.truncate(pos);
            break;
        }
    }

    s
}

fn cpu_model_name() -> String {
    shell("awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || true")
        .unwrap_or_default()
}

fn cpu_vendor() -> String {
    shell("awk -F': ' '/vendor_id/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || true")
        .unwrap_or_default()
}

fn detect_cpu_tier() -> String {
    let supported = shell("/lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -E 'x86-64-v[234].*supported' || true")
        .unwrap_or_default();

    let vendor = cpu_vendor();
    let model = cpu_model_name();

    let march = shell("if command -v gcc >/dev/null 2>&1; then gcc -march=native -Q --help=target 2>/dev/null | grep -Po '^\\s+-march=\\s+\\K(\\w+)$' | head -n1; fi || true")
        .unwrap_or_default();

    let march_trim = march.trim();

    if vendor.contains("AuthenticAMD") && (march_trim == "znver4" || march_trim == "znver5") {
        return "znver4".to_string();
    }

    let intel_hybrid_or_masked_avx512 =
        vendor.contains("GenuineIntel")
        && (
            model.contains("12th Gen")
            || model.contains("13th Gen")
            || model.contains("14th Gen")
            || model.contains("Core(TM) Ultra")
            || model.contains("Core Ultra")
        );

    if supported.contains("x86-64-v4") && !intel_hybrid_or_masked_avx512 {
        return "v4".to_string();
    }

    if supported.contains("x86-64-v3") {
        return "v3".to_string();
    }

    "generic".to_string()
}

fn cachy_repo_names(tier: &str) -> Vec<&'static str> {
    match tier {
        "v4" => vec!["cachyos-v4", "cachyos-core-v4", "cachyos-extra-v4", "cachyos"],
        "znver4" => vec!["cachyos-znver4", "cachyos-core-znver4", "cachyos-extra-znver4", "cachyos"],
        "v3" => vec!["cachyos-v3", "cachyos-core-v3", "cachyos-extra-v3", "cachyos"],
        _ => vec!["cachyos"],
    }
}

fn cachy_mirrorlist_for_repo(repo: &str) -> &'static str {
    if repo.contains("v4") || repo.contains("znver4") {
        "/etc/pacman.d/cachyos-v4-mirrorlist"
    } else if repo.contains("v3") {
        "/etc/pacman.d/cachyos-v3-mirrorlist"
    } else {
        "/etc/pacman.d/cachyos-mirrorlist"
    }
}

fn needed_mirrorlist(tier: &str) -> &'static str {
    match tier {
        "v4" | "znver4" => "/etc/pacman.d/cachyos-v4-mirrorlist",
        "v3" => "/etc/pacman.d/cachyos-v3-mirrorlist",
        _ => "/etc/pacman.d/cachyos-mirrorlist",
    }
}

fn architecture_line(tier: &str) -> &'static str {
    match tier {
        "v4" | "znver4" => "Architecture = x86_64 x86_64_v4",
        "v3" => "Architecture = x86_64 x86_64_v3",
        _ => "Architecture = auto",
    }
}

fn multilib_enabled() -> bool {
    status_shell("grep -Eq '^\\s*\\[multilib\\]' /etc/pacman.conf")
}

fn detect_gpu_plan() -> GpuPlan {
    let raw = shell("if command -v lspci >/dev/null 2>&1; then lspci -nn | grep -Ei 'VGA|3D|Display' || true; fi")
        .unwrap_or_default();

    let upper = raw.to_uppercase();

    let has_nvidia = upper.contains("NVIDIA");
    let has_amd =
        upper.contains("ADVANCED MICRO DEVICES")
        || upper.contains("AMD/ATI")
        || upper.contains("ATI TECHNOLOGIES")
        || upper.contains("RADEON");

    let has_intel =
        upper.contains("INTEL CORPORATION")
        || upper.contains("INTEL ")
        || upper.contains(" IRIS ")
        || upper.contains(" UHD ")
        || upper.contains(" XE ");

    let nvidia_legacy_risk =
        has_nvidia
        && (
            upper.contains("GTX 10")
            || upper.contains("GTX 9")
            || upper.contains("GTX 8")
            || upper.contains("GTX 7")
            || upper.contains("GTX 6")
            || upper.contains("GTX 5")
            || upper.contains("GTX 4")
            || upper.contains("MAXWELL")
            || upper.contains("PASCAL")
            || upper.contains("KEPLER")
            || upper.contains("FERMI")
        );

    GpuPlan {
        has_nvidia,
        has_amd,
        has_intel,
        nvidia_legacy_risk,
        raw_lspci: raw,
    }
}

fn ensure_lspci() {
    if !status_shell("command -v lspci >/dev/null 2>&1") {
        println!("lspci ausente. Instalando pciutils para detectar GPU...");
        let _ = sudo_status(&["pacman", "-S", "--needed", "pciutils"]);
    }
}

fn ensure_cachy_support(tier: &str) -> bool {
    let needed = needed_mirrorlist(tier);

    if Path::new("/usr/share/pacman/keyrings/cachyos.gpg").exists()
        && Path::new("/etc/pacman.d/cachyos-mirrorlist").exists()
        && Path::new(needed).exists()
    {
        return true;
    }

    println!("Suporte CachyOS local incompleto.");
    println!("Instalando somente keyring/mirrorlists necessários, sem ativar repositório permanente.");

    let _ = sudo_status(&[
        "pacman-key",
        "--recv-keys",
        "F3B607488DB35A47",
        "--keyserver",
        "keyserver.ubuntu.com",
    ]);

    let _ = sudo_status(&[
        "pacman-key",
        "--lsign-key",
        "F3B607488DB35A47",
    ]);

    let ok = run_interactive(
        "sudo",
        &[
            "pacman",
            "-U",
            "https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst",
            "https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst",
            "https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst",
            "https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-27-1-any.pkg.tar.zst",
        ],
    );

    ok
        && Path::new("/usr/share/pacman/keyrings/cachyos.gpg").exists()
        && Path::new("/etc/pacman.d/cachyos-mirrorlist").exists()
        && Path::new(needed).exists()
}

fn make_temp_pacman_conf(tier: &str) -> Result<String, String> {
    let pid = std::process::id();
    let path = format!("/tmp/mocha-stack-optimizer-pacman-{}.conf", pid);

    let mut conf = String::new();

    conf.push_str("[options]\n");
    conf.push_str("HoldPkg = pacman glibc\n");
    conf.push_str(architecture_line(tier));
    conf.push('\n');
    conf.push_str("SigLevel = Required DatabaseOptional\n");
    conf.push_str("LocalFileSigLevel = Optional\n");
    conf.push_str("ParallelDownloads = 5\n");
    conf.push_str("CheckSpace\n\n");

    for repo in cachy_repo_names(tier) {
        conf.push_str(&format!("[{}]\n", repo));
        conf.push_str(&format!("Include = {}\n\n", cachy_mirrorlist_for_repo(repo)));
    }

    conf.push_str("[core]\n");
    conf.push_str("Include = /etc/pacman.d/mirrorlist\n\n");

    conf.push_str("[extra]\n");
    conf.push_str("Include = /etc/pacman.d/mirrorlist\n\n");

    if multilib_enabled() {
        conf.push_str("[multilib]\n");
        conf.push_str("Include = /etc/pacman.d/mirrorlist\n\n");
    }

    fs::write(&path, conf).map_err(|e| e.to_string())?;
    Ok(path)
}

fn sync_temp_db(conf: &str) -> bool {
    println!("Sincronizando bancos temporários CachyOS/Arch...");
    run_interactive("sudo", &["pacman", "--config", conf, "-Sy"])
}

fn sync_arch_system() -> bool {
    println!("Atualizando sistema base Arch antes de mexer em kernel/driver...");
    run_interactive("sudo", &["pacman", "-Syu"])
}

fn push_unique(vec: &mut Vec<String>, pkg: &str) {
    if !vec.iter().any(|p| p == pkg) {
        vec.push(pkg.to_string());
    }
}

fn install_pkgs_with_conf(conf: &str, pkgs: &[String]) -> bool {
    if pkgs.is_empty() {
        return true;
    }

    println!("Instalando via pacman temporário:");
    for p in pkgs {
        println!(" - {}", p);
    }

    let mut args: Vec<String> = vec![
        "pacman".to_string(),
        "--config".to_string(),
        conf.to_string(),
        "-S".to_string(),
        "--needed".to_string(),
    ];

    for p in pkgs {
        args.push(p.clone());
    }

    let args_ref: Vec<&str> = args.iter().map(|s| s.as_str()).collect();
    run_interactive("sudo", &args_ref)
}

fn install_pkgs_arch(pkgs: &[String]) -> bool {
    if pkgs.is_empty() {
        return true;
    }

    println!("Instalando via Arch oficial:");
    for p in pkgs {
        println!(" - {}", p);
    }

    let mut args: Vec<String> = vec![
        "pacman".to_string(),
        "-S".to_string(),
        "--needed".to_string(),
    ];

    for p in pkgs {
        args.push(p.clone());
    }

    let args_ref: Vec<&str> = args.iter().map(|s| s.as_str()).collect();
    run_interactive("sudo", &args_ref)
}

fn repair_grub_preference() {
    if !Path::new("/boot/grub/grub.cfg").exists() {
        println!("GRUB não encontrado em /boot/grub/grub.cfg. Pulei ajuste de boot.");
        return;
    }

    println!("Regenerando GRUB...");
    let _ = sudo_status(&["grub-mkconfig", "-o", "/boot/grub/grub.cfg"]);

    let entry = shell("awk -F\"'\" '/^menuentry / && tolower($2) ~ /cachyos/ {print $2; exit}' /boot/grub/grub.cfg")
        .unwrap_or_default();

    if entry.trim().is_empty() {
        println!("Não encontrei menuentry CachyOS explícita no GRUB.");
        return;
    }

    println!("Definindo entrada CachyOS como padrão salvo:");
    println!(" - {}", entry.trim());

    let _ = Command::new("sudo")
        .arg("grub-set-default")
        .arg(entry.trim())
        .status();

    let _ = status_shell("sudo cp -a /etc/default/grub /etc/default/grub.mocha-stack.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true");

    let _ = status_shell("if grep -q '^GRUB_DEFAULT=' /etc/default/grub; then sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub; else echo 'GRUB_DEFAULT=saved' | sudo tee -a /etc/default/grub >/dev/null; fi");

    let _ = status_shell("if grep -q '^GRUB_SAVEDEFAULT=' /etc/default/grub; then sudo sed -i 's/^GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/' /etc/default/grub; else echo 'GRUB_SAVEDEFAULT=true' | sudo tee -a /etc/default/grub >/dev/null; fi");

    let _ = sudo_status(&["grub-mkconfig", "-o", "/boot/grub/grub.cfg"]);
}

fn print_pkg_line(name: &str, local: Option<&String>, remote: Option<&RemotePkg>) {
    let local_s = local.map(|s| s.as_str()).unwrap_or("não instalado");
    let remote_s = remote.map(|r| r.version.as_str()).unwrap_or("não encontrado");
    let repo_s = remote.map(|r| r.repo.as_str()).unwrap_or("-");
    let arch_s = remote.map(|r| r.arch.as_str()).unwrap_or("-");

    println!(
        "{:<22} local: {:<20} remoto: {:<20} repo: {:<22} arch: {}",
        name, local_s, remote_s, repo_s, arch_s
    );
}

fn self_test() {
    println!("Otimizador de Stack Mocha — self-test");
    println!("rust/bin ok");
    println!("CPU modelo: {}", cpu_model_name());
    println!("CPU vendor: {}", cpu_vendor());
    println!("CPU tier detectado: {}", detect_cpu_tier());
    println!("Architecture temporária: {}", architecture_line(&detect_cpu_tier()));
    println!("Self-test concluído.");
}

fn main() {
    let args: Vec<String> = env::args().collect();

    let check_only = args.iter().any(|a| a == "--check");
    let auto_yes = args.iter().any(|a| a == "--yes");
    let self_test_mode = args.iter().any(|a| a == "--self-test");

    if self_test_mode {
        self_test();
        return;
    }

    println!("============================================================");
    println!(" Otimizador de Stack Mocha");
    println!(" CPU escolhe kernel/repo. GPU escolhe driver.");
    println!("============================================================");
    println!();

    if !sudo_status(&["-v"]) {
        println!("ERRO: sudo não autorizado.");
        std::process::exit(1);
    }

    ensure_lspci();

    let tier = detect_cpu_tier();
    let vendor = cpu_vendor();
    let model = cpu_model_name();

    println!("CPU:");
    println!(" - Vendor: {}", if vendor.trim().is_empty() { "desconhecido" } else { vendor.trim() });
    println!(" - Modelo: {}", if model.trim().is_empty() { "desconhecido" } else { model.trim() });
    println!(" - Tier Mocha/CachyOS: {}", tier);
    println!(" - Architecture temporária: {}", architecture_line(&tier));
    println!();

    let gpu = detect_gpu_plan();

    println!("GPU detectada por lspci:");
    if gpu.raw_lspci.trim().is_empty() {
        println!(" - nenhuma linha VGA/3D/Display encontrada");
    } else {
        for line in gpu.raw_lspci.lines() {
            println!(" - {}", line);
        }
    }

    println!();
    println!("Plano por GPU:");
    println!(" - NVIDIA: {}", if gpu.has_nvidia { "sim" } else { "não" });
    println!(" - AMD:    {}", if gpu.has_amd { "sim" } else { "não" });
    println!(" - Intel:  {}", if gpu.has_intel { "sim" } else { "não" });

    if gpu.nvidia_legacy_risk {
        println!(" - Aviso: NVIDIA antiga/legacy aparente. Driver novo oficial pode não servir.");
    }

    println!();

    if !ensure_cachy_support(&tier) {
        println!("ERRO: não consegui preparar keyring/mirrorlists CachyOS.");
        println!("Não alterei kernel nem driver.");
        std::process::exit(1);
    }

    let conf = match make_temp_pacman_conf(&tier) {
        Ok(c) => c,
        Err(e) => {
            println!("ERRO: não consegui criar pacman.conf temporário: {}", e);
            std::process::exit(1);
        }
    };

    println!("pacman.conf temporário:");
    println!(" - {}", conf);
    println!("Observação: /etc/pacman.conf permanente NÃO será alterado.");
    println!();

    if !sync_temp_db(&conf) {
        println!("ERRO: falha ao sincronizar bancos temporários.");
        std::process::exit(1);
    }

    println!();
    println!("Estado do kernel:");

    let running = current_kernel();
    let running_norm = normalize_running_kernel_version(&running);

    let local_kernel = installed_version("linux-cachyos");
    let local_headers = installed_version("linux-cachyos-headers");
    let remote_kernel = remote_pkg_info(&conf, "linux-cachyos");
    let remote_headers = remote_pkg_info(&conf, "linux-cachyos-headers");

    println!("Kernel em uso agora: {}  [comparável: {}]", running, running_norm);
    print_pkg_line("linux-cachyos", local_kernel.as_ref(), remote_kernel.as_ref());
    print_pkg_line("headers", local_headers.as_ref(), remote_headers.as_ref());

    let mut temp_pkgs: Vec<String> = Vec::new();
    let mut arch_pkgs: Vec<String> = Vec::new();
    let mut repair_boot = false;

    match (&local_kernel, &remote_kernel) {
        (None, Some(_)) => {
            println!("Decisão kernel: linux-cachyos não instalado. Instalar.");
            push_unique(&mut temp_pkgs, "linux-cachyos");
            push_unique(&mut temp_pkgs, "linux-cachyos-headers");
        }
        (Some(local), Some(remote)) => {
            let cmp_remote_local = vercmp(&remote.version, local);
            let cmp_local_running = vercmp(local, &running_norm);

            if cmp_remote_local > 0 {
                println!("Decisão kernel: há kernel remoto mais novo que o instalado. Atualizar.");
                push_unique(&mut temp_pkgs, "linux-cachyos");
                push_unique(&mut temp_pkgs, "linux-cachyos-headers");
            } else if cmp_remote_local == 0 && cmp_local_running > 0 {
                println!("Decisão kernel: kernel melhor já está instalado, mas o sistema não está bootado nele.");
                repair_boot = true;
            } else if cmp_remote_local == 0 {
                println!("Decisão kernel: instalado e remoto estão iguais.");
            } else {
                println!("Decisão kernel: instalado parece mais novo que remoto. Não farei downgrade.");
            }
        }
        (_, None) => {
            println!("Decisão kernel: não achei linux-cachyos remoto. Não instalarei às cegas.");
        }
    }

    println!();
    println!("Estado/decisão de driver gráfico:");

    if gpu.has_amd {
        println!("AMD GPU: usar stack Mesa/RADV.");
        for p in ["mesa", "vulkan-radeon", "libva-mesa-driver", "mesa-vdpau"] {
            if !installed(p) {
                push_unique(&mut arch_pkgs, p);
            }
        }

        if multilib_enabled() {
            for p in ["lib32-mesa", "lib32-vulkan-radeon"] {
                if !installed(p) {
                    push_unique(&mut arch_pkgs, p);
                }
            }
        }
    }

    if gpu.has_intel {
        println!("Intel GPU: usar stack Mesa/ANV.");
        for p in ["mesa", "vulkan-intel", "intel-media-driver"] {
            if !installed(p) {
                push_unique(&mut arch_pkgs, p);
            }
        }

        if multilib_enabled() {
            for p in ["lib32-mesa", "lib32-vulkan-intel"] {
                if !installed(p) {
                    push_unique(&mut arch_pkgs, p);
                }
            }
        }
    }

    if gpu.has_nvidia {
        if gpu.nvidia_legacy_risk {
            println!("NVIDIA: hardware aparenta ser legacy. Não instalarei driver NVIDIA novo automaticamente.");
            println!("Motivo: evitar quebrar GPUs Maxwell/Pascal/Kepler com driver incompatível.");
        } else {
            println!("NVIDIA: usar nvidia-open-dkms + utils.");

            let local_nv = installed_version("nvidia-open-dkms");
            let local_utils = installed_version("nvidia-utils");
            let remote_nv = remote_pkg_info(&conf, "nvidia-open-dkms");
            let remote_utils = remote_pkg_info(&conf, "nvidia-utils");

            print_pkg_line("nvidia-open-dkms", local_nv.as_ref(), remote_nv.as_ref());
            print_pkg_line("nvidia-utils", local_utils.as_ref(), remote_utils.as_ref());

            match (&local_nv, &remote_nv) {
                (None, Some(_)) => {
                    push_unique(&mut temp_pkgs, "nvidia-open-dkms");
                    push_unique(&mut temp_pkgs, "nvidia-utils");
                }
                (Some(local), Some(remote)) => {
                    if vercmp(&remote.version, local) > 0 {
                        push_unique(&mut temp_pkgs, "nvidia-open-dkms");
                        push_unique(&mut temp_pkgs, "nvidia-utils");
                    }
                }
                (_, None) => {
                    println!("Aviso: nvidia-open-dkms não encontrado no pacman temporário.");
                }
            }

            if local_utils.is_none() && remote_utils.is_some() {
                push_unique(&mut temp_pkgs, "nvidia-utils");
            }

            if multilib_enabled() {
                let local_lib32 = installed_version("lib32-nvidia-utils");
                let remote_lib32 = remote_pkg_info(&conf, "lib32-nvidia-utils");

                print_pkg_line("lib32-nvidia-utils", local_lib32.as_ref(), remote_lib32.as_ref());

                if local_lib32.is_none() && remote_lib32.is_some() {
                    push_unique(&mut temp_pkgs, "lib32-nvidia-utils");
                }
            }
        }
    }

    println!();

    if temp_pkgs.is_empty() && arch_pkgs.is_empty() && !repair_boot {
        println!("Nada a fazer. Stack parece coerente.");
        return;
    }

    println!("Ações propostas:");
    if !temp_pkgs.is_empty() {
        println!("Via CachyOS temporário:");
        for p in &temp_pkgs {
            println!(" - {}", p);
        }
    }

    if !arch_pkgs.is_empty() {
        println!("Via Arch oficial:");
        for p in &arch_pkgs {
            println!(" - {}", p);
        }
    }

    if repair_boot {
        println!("Boot:");
        println!(" - regenerar GRUB e tentar definir CachyOS como padrão");
    }

    println!();

    if check_only {
        println!("Modo --check: não executei instalação.");
        std::process::exit(2);
    }

    let proceed = auto_yes || ask_yes_no("Executar ações propostas agora?");

    if !proceed {
        println!("Abortado pelo usuário.");
        return;
    }

    if !sync_arch_system() {
        println!("ERRO: atualização base falhou. Abortando para não misturar estados.");
        std::process::exit(1);
    }

    if !install_pkgs_arch(&arch_pkgs) {
        println!("ERRO: instalação de pacotes Arch falhou.");
        std::process::exit(1);
    }

    if !install_pkgs_with_conf(&conf, &temp_pkgs) {
        println!("ERRO: instalação via pacman temporário falhou.");
        std::process::exit(1);
    }

    if !temp_pkgs.is_empty() {
        println!("Regenerando initramfs...");
        let _ = sudo_status(&["mkinitcpio", "-P"]);
    }

    if repair_boot || temp_pkgs.iter().any(|p| p == "linux-cachyos") {
        repair_grub_preference();
    }

    println!();
    println!("Concluído.");
    println!("Se kernel ou driver foram alterados, reinicie antes de medir FPS.");
}
