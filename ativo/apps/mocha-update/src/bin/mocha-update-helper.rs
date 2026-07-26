use mocha_update::protocol::{
    encode_data, encode_progress, encode_result, is_protected_general_package, safe_snapshot_id,
    Operation, KERNEL_PACKAGES, NVIDIA_OPTIONAL_PACKAGES, NVIDIA_REQUIRED_PACKAGES,
    PROTECTED_GENERAL_PACKAGES, REPOSITORY_FINGERPRINT, REPOSITORY_NAME, REPOSITORY_URL,
};
use std::collections::BTreeMap;
use std::env;
use std::fs::{self, File, OpenOptions};
use std::io::{self, BufWriter, Write};
use std::os::fd::AsRawFd;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};

const PACMAN: &str = "/usr/bin/pacman";
const CHECKUPDATES: &str = "/usr/bin/checkupdates";
const FLATPAK: &str = "/usr/bin/flatpak";
const DKMS: &str = "/usr/bin/dkms";
const MKINITCPIO: &str = "/usr/bin/mkinitcpio";
const DEPMOD: &str = "/usr/bin/depmod";
const MODINFO: &str = "/usr/bin/modinfo";
const GRUB_MKCONFIG: &str = "/usr/bin/grub-mkconfig";
const FINDMNT: &str = "/usr/bin/findmnt";
const LVS: &str = "/usr/bin/lvs";
const LVCREATE: &str = "/usr/bin/lvcreate";
const LVCONVERT: &str = "/usr/bin/lvconvert";
const LVREMOVE: &str = "/usr/bin/lvremove";
const GPG: &str = "/usr/bin/gpg";
const SYNC: &str = "/usr/bin/sync";
const RUNUSER: &str = "/usr/bin/runuser";
const ENV: &str = "/usr/bin/env";
const DATE: &str = "/usr/bin/date";
const NVIDIA_SETTINGS: &str = "/usr/bin/nvidia-settings";
const GAMEMODED: &str = "/usr/bin/gamemoded";

const OC_SESSION_MARKER: &str = "/run/mocha-update/mocha-oc-session.enabled";
const OC_PERSISTENT_CONFIG: &str = "/etc/mocha/nvidia-game-oc.conf";
const OC_RUNTIME_STATE: &str = "/run/mocha-update/mocha-oc-runtime.conf";
const OC_ROOT_HELPER: &str = "/usr/local/lib/mocha/mocha-nvidia-oc-root-helper";
const GAMEMODE_CONFIG: &str = "/etc/gamemode.ini";
const GAMEMODE_START_LINK: &str = "/usr/local/lib/mocha/gamemode-start-agressivo-oc.sh";
const GAMEMODE_END_LINK: &str = "/usr/local/lib/mocha/gamemode-end-agressivo-oc.sh";
const GAMEMODE_START_AUTHORITY: &str =
    "/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system";
const GAMEMODE_END_AUTHORITY: &str =
    "/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system";
const OC_GPU_INDEX: i32 = 0;
const OC_CORE_OFFSET: i32 = 50;
const OC_MEMORY_TRANSFER_OFFSET: i32 = 400;

const ROOT_STATE: &str = "/var/lib/mocha-update";
const ROOT_LOGS: &str = "/var/log/mocha-update";
const ROLLBACKS: &str = "/var/lib/mocha-update/rollbacks";
const OPERATION_LOCK: &str = "/run/lock/mocha-update.lock";

const LOCK_EX: i32 = 2;
const LOCK_NB: i32 = 4;

unsafe extern "C" {
    fn flock(fd: i32, operation: i32) -> i32;
}

struct OperationLock {
    _file: File,
}

impl OperationLock {
    fn acquire() -> Result<Self, String> {
        let file = OpenOptions::new()
            .create(true)
            .read(true)
            .write(true)
            .open(OPERATION_LOCK)
            .map_err(|error| format!("não foi possível abrir {OPERATION_LOCK}: {error}"))?;
        let result = unsafe { flock(file.as_raw_fd(), LOCK_EX | LOCK_NB) };
        if result != 0 {
            return Err(
                "outra operação administrativa do Mocha Update já está em execução".to_owned(),
            );
        }
        Ok(Self { _file: file })
    }
}

struct Reporter {
    log: BufWriter<File>,
    log_path: PathBuf,
}

impl Reporter {
    fn new(operation: Operation) -> Result<Self, String> {
        let root = effective_uid() == 0;
        let log_dir = if root {
            PathBuf::from(ROOT_LOGS)
        } else {
            user_state_dir().join("logs")
        };
        fs::create_dir_all(&log_dir)
            .map_err(|error| format!("não foi possível criar {}: {error}", log_dir.display()))?;

        let stamp = timestamp()?;
        let log_path = log_dir.join(format!("{}-{}.log", stamp, operation.argument()));
        let file = OpenOptions::new()
            .create_new(true)
            .write(true)
            .open(&log_path)
            .map_err(|error| format!("não foi possível criar {}: {error}", log_path.display()))?;

        Ok(Self {
            log: BufWriter::new(file),
            log_path,
        })
    }

    fn progress(&mut self, progress: i32, message: &str) {
        emit_protocol(encode_progress(progress, message));
        let _ = writeln!(self.log, "PROGRESS={} MESSAGE={}", progress, message);
        let _ = self.log.flush();
    }

    fn data(&mut self, key: &str, value: &str) {
        emit_protocol(encode_data(key, value));
        let _ = writeln!(self.log, "DATA={} VALUE={}", key, value);
        let _ = self.log.flush();
    }

    fn record(&mut self, text: &str) {
        let _ = writeln!(self.log, "{text}");
        let _ = self.log.flush();
    }

    fn command(&mut self, label: &str, program: &str, args: &[String]) -> Result<Output, String> {
        self.record(&format!("COMMAND_LABEL={label}"));
        self.record(&format!("COMMAND={} {}", program, shell_free_display(args)));

        let output = Command::new(program)
            .args(args)
            .env("LC_ALL", "C")
            .env("LANG", "C")
            .env("PAGER", "cat")
            .env("SYSTEMD_PAGER", "cat")
            .env("PACMAN", PACMAN)
            .output()
            .map_err(|error| format!("falha ao executar {label}: {error}"))?;

        self.record(&format!("STATUS={}", output.status));
        self.record("STDOUT_BEGIN");
        self.record(&String::from_utf8_lossy(&output.stdout));
        self.record("STDOUT_END");
        self.record("STDERR_BEGIN");
        self.record(&String::from_utf8_lossy(&output.stderr));
        self.record("STDERR_END");

        Ok(output)
    }

    fn required(&mut self, label: &str, program: &str, args: &[String]) -> Result<String, String> {
        let output = self.command(label, program, args)?;
        if !output.status.success() {
            return Err(command_failure(label, &output));
        }
        Ok(String::from_utf8_lossy(&output.stdout).trim().to_owned())
    }

    fn finish(mut self, success: bool, message: &str) -> i32 {
        let log_path = self.log_path.to_string_lossy().into_owned();
        self.data("log_path", &log_path);
        self.record(&format!(
            "RESULT={} MESSAGE={}",
            if success { "SUCCESS" } else { "FAILURE" },
            message
        ));
        let _ = self.log.flush();
        emit_protocol(encode_result(success, message));
        if success {
            0
        } else {
            1
        }
    }
}

fn emit_protocol(line: String) {
    println!("{line}");
    let _ = io::stdout().flush();
}

fn main() {
    let code = run();
    std::process::exit(code);
}

fn run() -> i32 {
    let mut args = env::args().skip(1);
    let operation_arg = match args.next() {
        Some(value) => value,
        None => {
            eprintln!("uso: mocha-update-helper <operação> [identificador]");
            return 2;
        }
    };

    if operation_arg.starts_with("oc-runtime-") {
        if args.next().is_some() {
            eprintln!("argumentos excedentes");
            return 2;
        }
        return run_oc_runtime(&operation_arg);
    }

    let operation = match Operation::try_from(operation_arg.as_str()) {
        Ok(value) => value,
        Err(error) => {
            eprintln!("{error}");
            return 2;
        }
    };

    let rollback_id = args.next();
    if args.next().is_some() {
        eprintln!("argumentos excedentes");
        return 2;
    }

    if operation.requires_root() && effective_uid() != 0 {
        emit_protocol(encode_result(
            false,
            "autorização administrativa necessária",
        ));
        return 1;
    }

    let mut reporter = match Reporter::new(operation) {
        Ok(value) => value,
        Err(error) => {
            emit_protocol(encode_result(false, &error));
            return 1;
        }
    };

    reporter.data("operation", operation.argument());
    reporter.data("repository", REPOSITORY_NAME);
    reporter.data("repository_url", REPOSITORY_URL);

    let _operation_lock = if operation.requires_root() {
        match OperationLock::acquire() {
            Ok(lock) => Some(lock),
            Err(error) => return reporter.finish(false, &error),
        }
    } else {
        None
    };

    let result = match operation {
        Operation::CheckGeneral => check_general(&mut reporter),
        Operation::ApplyGeneral => apply_general(&mut reporter),
        Operation::CheckKernel => check_kernel(&mut reporter),
        Operation::ApplyKernel => apply_kernel(&mut reporter),
        Operation::Remarry => remarry(&mut reporter),
        Operation::CheckRollbacks => check_rollbacks(&mut reporter),
        Operation::ApplyRollback => match rollback_id {
            Some(id) => apply_rollback(&mut reporter, &id),
            None => Err("nenhum ponto de restauração foi selecionado".to_owned()),
        },
        Operation::CheckOc => check_oc(&mut reporter),
        Operation::EnableOcSession => enable_oc_session(&mut reporter),
        Operation::EnableOcPersistent => enable_oc_persistent(&mut reporter),
        Operation::DisableOc => disable_oc(&mut reporter),
    };

    match result {
        Ok(message) => reporter.finish(true, &message),
        Err(error) => reporter.finish(false, &error),
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum OcMode {
    Disabled,
    Session,
    Persistent,
}

impl OcMode {
    fn status(self) -> &'static str {
        match self {
            Self::Disabled => "Desativado",
            Self::Session => "Ativo nesta sessão",
            Self::Persistent => "Ativo permanentemente no GameMode",
        }
    }

    fn mode_text(self) -> &'static str {
        match self {
            Self::Disabled => "Nenhum OC será aplicado quando o GameMode iniciar",
            Self::Session => "A preferência temporária será removida no próximo reinício",
            Self::Persistent => "A preferência permanece após reinicializações",
        }
    }
}

fn current_oc_mode() -> OcMode {
    if Path::new(OC_PERSISTENT_CONFIG).is_file() {
        OcMode::Persistent
    } else if Path::new(OC_SESSION_MARKER).is_file() {
        OcMode::Session
    } else {
        OcMode::Disabled
    }
}

fn emit_oc_state(reporter: &mut Reporter) {
    let mode = current_oc_mode();
    let runtime_active = Path::new(OC_RUNTIME_STATE).is_file();
    reporter.data("oc_status", mode.status());
    reporter.data("oc_mode", mode.mode_text());
    reporter.data(
        "oc_detail",
        if runtime_active {
            "OC aplicado agora: +50 MHz GPU e +400 no controlador de memória (cerca de +200 MHz no clock real)"
        } else {
            "Perfil: +50 MHz GPU e +400 no controlador de memória (cerca de +200 MHz no clock real), somente durante o GameMode"
        },
    );
    reporter.data(
        "oc_enabled",
        if mode == OcMode::Disabled {
            "false"
        } else {
            "true"
        },
    );
}

fn check_oc(reporter: &mut Reporter) -> Result<String, String> {
    reporter.progress(15, "Validando a integração do Mocha OC com o GameMode");
    validate_oc_integration()?;
    reporter.progress(70, "Lendo o modo configurado");
    emit_oc_state(reporter);
    reporter.progress(100, "Estado do Mocha OC carregado");
    Ok(format!("Mocha OC: {}", current_oc_mode().status()))
}

fn enable_oc_session(reporter: &mut Reporter) -> Result<String, String> {
    validate_oc_integration()?;
    reporter.progress(20, "Preparando o modo temporário do Mocha OC");
    fs::create_dir_all("/run/mocha-update")
        .map_err(|error| format!("não foi possível criar /run/mocha-update: {error}"))?;
    if Path::new(OC_PERSISTENT_CONFIG).exists() {
        fs::remove_file(OC_PERSISTENT_CONFIG)
            .map_err(|error| format!("não foi possível remover o modo persistente: {error}"))?;
    }
    write_root_file(OC_SESSION_MARKER, "SESSION=1\n", 0o644)?;
    reporter.progress(60, "Modo temporário habilitado somente para o GameMode");
    apply_oc_if_gamemode_active(reporter)?;
    emit_oc_state(reporter);
    reporter.progress(100, "Mocha OC temporário ativado");
    Ok("Mocha OC ativado nesta sessão; o modo normal será restaurado ao sair do GameMode e a preferência desaparecerá no reinício".to_owned())
}

fn enable_oc_persistent(reporter: &mut Reporter) -> Result<String, String> {
    validate_oc_integration()?;
    reporter.progress(20, "Preparando o modo persistente do Mocha OC");
    if Path::new(OC_SESSION_MARKER).exists() {
        fs::remove_file(OC_SESSION_MARKER)
            .map_err(|error| format!("não foi possível remover o modo temporário: {error}"))?;
    }
    fs::create_dir_all("/etc/mocha")
        .map_err(|error| format!("não foi possível criar /etc/mocha: {error}"))?;
    write_root_file(
        OC_PERSISTENT_CONFIG,
        "# Gerenciado pelo Mocha Update\nOC_ENABLED=1\nGPU_INDEX=0\nCORE_OFFSET=50\nMEMORY_TRANSFER_RATE_OFFSET=400\n",
        0o644,
    )?;
    reporter.progress(60, "Modo persistente habilitado somente para o GameMode");
    apply_oc_if_gamemode_active(reporter)?;
    emit_oc_state(reporter);
    reporter.progress(100, "Mocha OC permanente no GameMode ativado");
    Ok("Mocha OC configurado permanentemente no GameMode; fora dos jogos os clocks permanecem no padrão".to_owned())
}

fn disable_oc(reporter: &mut Reporter) -> Result<String, String> {
    reporter.progress(15, "Removendo os modos temporário e persistente");
    for path in [OC_SESSION_MARKER, OC_PERSISTENT_CONFIG] {
        if Path::new(path).exists() {
            fs::remove_file(path)
                .map_err(|error| format!("não foi possível remover {path}: {error}"))?;
        }
    }
    reporter.progress(55, "Restaurando os clocks normais");
    match restore_oc_offsets() {
        Ok(()) => {}
        Err(error) if !Path::new(NVIDIA_SETTINGS).is_file() => {
            reporter.record(&format!("OC_RESET_SKIPPED={error}"));
        }
        Err(error) => return Err(error),
    }
    emit_oc_state(reporter);
    reporter.progress(100, "Mocha OC totalmente desativado");
    Ok("Mocha OC desativado; offsets de GPU e memória restaurados ao modo normal".to_owned())
}

fn validate_oc_integration() -> Result<(), String> {
    const START_BRIDGE: &str = "/etc/mocha/gamemode/legacy-start-system.cmd";
    const END_BRIDGE: &str = "/etc/mocha/gamemode/legacy-end-system.cmd";
    const START_LEGACY: &str = "/usr/local/lib/mocha/gamemode-start-agressivo-oc.sh";
    const END_LEGACY: &str = "/usr/local/lib/mocha/gamemode-end-agressivo-oc.sh";

    require_tools(&[NVIDIA_SETTINGS, GAMEMODED, RUNUSER, ENV])?;

    for path in [OC_ROOT_HELPER, GAMEMODE_CONFIG] {
        if !Path::new(path).is_file() {
            return Err(format!(
                "integração obrigatória do Mocha OC ausente: {path}"
            ));
        }
    }

    for path in [GAMEMODE_START_AUTHORITY, GAMEMODE_END_AUTHORITY] {
        let metadata = fs::metadata(path)
            .map_err(|error| format!("integração do GameMode ausente em {path}: {error}"))?;
        if metadata.permissions().mode() & 0o111 == 0 {
            return Err(format!("hook do GameMode não é executável: {path}"));
        }
    }

    let config = fs::read_to_string(GAMEMODE_CONFIG)
        .map_err(|error| format!("não foi possível ler {GAMEMODE_CONFIG}: {error}"))?;
    let start_ok =
        config.contains(GAMEMODE_START_AUTHORITY) || config.contains(GAMEMODE_START_LINK);
    let end_ok = config.contains(GAMEMODE_END_AUTHORITY) || config.contains(GAMEMODE_END_LINK);
    if !start_ok || !end_ok {
        return Err(
            "os hooks canônicos de autoridade não estão configurados em /etc/gamemode.ini"
                .to_owned(),
        );
    }

    let start_authority = fs::read_to_string(GAMEMODE_START_AUTHORITY)
        .map_err(|error| format!("não foi possível auditar {GAMEMODE_START_AUTHORITY}: {error}"))?;
    let end_authority = fs::read_to_string(GAMEMODE_END_AUTHORITY)
        .map_err(|error| format!("não foi possível auditar {GAMEMODE_END_AUTHORITY}: {error}"))?;

    let direct_chain =
        start_authority.contains(OC_ROOT_HELPER) && end_authority.contains(OC_ROOT_HELPER);

    let indirect_chain = (|| -> Result<bool, String> {
        if !start_authority.contains(START_BRIDGE)
            || !end_authority.contains(END_BRIDGE)
            || !start_authority.contains("run_legacy")
            || !end_authority.contains("run_legacy")
        {
            return Ok(false);
        }

        for path in [START_BRIDGE, END_BRIDGE] {
            if !Path::new(path).is_file() {
                return Ok(false);
            }
        }

        let start_bridge = fs::read_to_string(START_BRIDGE)
            .map_err(|error| format!("não foi possível ler {START_BRIDGE}: {error}"))?;
        let end_bridge = fs::read_to_string(END_BRIDGE)
            .map_err(|error| format!("não foi possível ler {END_BRIDGE}: {error}"))?;

        if !start_bridge.contains(START_LEGACY) || !end_bridge.contains(END_LEGACY) {
            return Ok(false);
        }

        for path in [START_LEGACY, END_LEGACY] {
            let metadata = fs::metadata(path)
                .map_err(|error| format!("script legacy ausente em {path}: {error}"))?;
            if metadata.permissions().mode() & 0o111 == 0 {
                return Err(format!("script legacy não é executável: {path}"));
            }
        }

        let start_legacy = fs::read_to_string(START_LEGACY)
            .map_err(|error| format!("não foi possível auditar {START_LEGACY}: {error}"))?;
        let end_legacy = fs::read_to_string(END_LEGACY)
            .map_err(|error| format!("não foi possível auditar {END_LEGACY}: {error}"))?;

        Ok(start_legacy.contains(OC_ROOT_HELPER) && end_legacy.contains(OC_ROOT_HELPER))
    })()?;

    if !direct_chain && !indirect_chain {
        return Err("a cadeia do GameMode não alcança o executor fixo do Mocha OC".to_owned());
    }

    Ok(())
}

fn write_root_file(path: &str, contents: &str, mode: u32) -> Result<(), String> {
    let target = Path::new(path);
    let parent = target
        .parent()
        .ok_or_else(|| format!("caminho sem diretório pai: {path}"))?;
    fs::create_dir_all(parent)
        .map_err(|error| format!("não foi possível criar {}: {error}", parent.display()))?;
    let temp = parent.join(format!(
        ".{}.tmp-{}",
        target.file_name().unwrap_or_default().to_string_lossy(),
        std::process::id()
    ));
    fs::write(&temp, contents)
        .map_err(|error| format!("não foi possível gravar {}: {error}", temp.display()))?;
    fs::set_permissions(&temp, fs::Permissions::from_mode(mode))
        .map_err(|error| format!("não foi possível ajustar {}: {error}", temp.display()))?;
    fs::rename(&temp, target)
        .map_err(|error| format!("não foi possível instalar {path}: {error}"))?;
    Ok(())
}

fn apply_oc_if_gamemode_active(reporter: &mut Reporter) -> Result<(), String> {
    let Some(user) = invoking_user()? else {
        reporter.record("GAMEMODE_STATUS=invoking-user-unavailable");
        return Ok(());
    };
    if gamemode_active(&user)? {
        reporter.progress(78, "GameMode ativo; aplicando o perfil agora");
        apply_oc_offsets(&user)?;
    } else {
        reporter.progress(78, "Perfil preparado para a próxima ativação do GameMode");
    }
    Ok(())
}

fn run_oc_runtime(command: &str) -> i32 {
    if effective_uid() != 0 {
        eprintln!("o runtime do Mocha OC exige EUID 0");
        return 1;
    }

    let action = match command {
        "oc-runtime-start" => {
            if current_oc_mode() == OcMode::Disabled {
                println!("STATUS_BACKEND=NVML");
                println!("RUNTIME_ACTIVE=false");
                return 0;
            }
            "start"
        }
        "oc-runtime-end" => "end",
        "oc-runtime-status" => "status",
        _ => {
            eprintln!("comando de runtime desconhecido: {command}");
            return 1;
        }
    };

    match run_native_nvml(action) {
        Ok(output) => {
            print!("{output}");
            0
        }
        Err(error) => {
            eprintln!("{error}");
            1
        }
    }
}

fn gamemode_active(user: &InvokingUser) -> Result<bool, String> {
    let output = run_as_user(user, GAMEMODED, &["-s"])?;
    let combined = format!(
        "{}\n{}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    )
    .to_ascii_lowercase();
    if combined.contains("inactive") || combined.contains("not active") {
        return Ok(false);
    }
    Ok(output.status.success() || combined.contains("active"))
}

fn run_native_nvml(action: &str) -> Result<String, String> {
    let output = std::process::Command::new("/usr/local/lib/mocha/mocha-nvidia-oc-nvml")
        .arg(action)
        .output()
        .map_err(|error| format!("não foi possível executar o backend NVML nativo: {error}"))?;

    let stdout = String::from_utf8_lossy(&output.stdout).into_owned();
    let stderr = String::from_utf8_lossy(&output.stderr).trim().to_owned();

    if !output.status.success() {
        let code = output.status.code().unwrap_or(1);
        return Err(format!(
            "backend NVML falhou no comando {action} (código {code}): {}{}",
            if stderr.is_empty() {
                "sem mensagem"
            } else {
                &stderr
            },
            if stdout.trim().is_empty() {
                String::new()
            } else {
                format!("; saída: {}", stdout.trim())
            }
        ));
    }

    if !stdout.lines().any(|line| line == "STATUS_BACKEND=NVML") {
        return Err(format!(
            "backend nativo não confirmou STATUS_BACKEND=NVML no comando {action}"
        ));
    }

    Ok(stdout)
}

fn apply_oc_offsets(user: &InvokingUser) -> Result<(), String> {
    let output = run_native_nvml("start")?;
    let core_ok = output.lines().any(|line| line == "STATUS_CORE_OFFSET=50");
    let memory_ok = output
        .lines()
        .any(|line| line == "STATUS_MEMORY_TRANSFER_RATE_OFFSET=400");
    if !core_ok || !memory_ok {
        return Err(format!(
            "NVML não confirmou o perfil Mocha OC +50/+400: {}",
            output.trim()
        ));
    }
    Ok(())
}

fn restore_oc_offsets() -> Result<(), String> {
    let _output = run_native_nvml("end")?;
    Ok(())
}

fn state_value<'a>(contents: &'a str, key: &str) -> Option<&'a str> {
    contents
        .lines()
        .find_map(|line| line.strip_prefix(&format!("{key}=")))
}

fn nvidia_target(attribute: &str) -> String {
    format!("[gpu:{OC_GPU_INDEX}]/{attribute}")
}

fn query_nvidia_value(user: &InvokingUser, attribute: &str) -> Result<i32, String> {
    let target = nvidia_target(attribute);
    let output = run_as_user(user, NVIDIA_SETTINGS, &["-q", &target, "-t"])?;
    if !output.status.success() {
        return Err(command_failure("consulta NVIDIA", &output));
    }
    let text = String::from_utf8_lossy(&output.stdout);
    text.lines()
        .find_map(|line| line.trim().parse::<i32>().ok())
        .ok_or_else(|| format!("valor inválido retornado para {attribute}: {}", text.trim()))
}

fn assign_nvidia_values(
    user: &InvokingUser,
    core: i32,
    memory: i32,
    powermizer: Option<i32>,
) -> Result<(), String> {
    let mut owned = Vec::new();

    // O PowerMizer deve ser ajustado antes dos offsets.
    // No driver NVIDIA atual, ajustá-lo por último pode zerar core e memória.
    if let Some(value) = powermizer {
        owned.push("-a".to_owned());
        owned.push(format!("{}={value}", nvidia_target("GPUPowerMizerMode")));
    }

    owned.push("-a".to_owned());
    owned.push(format!(
        "{}={core}",
        nvidia_target("GPUGraphicsClockOffsetAllPerformanceLevels")
    ));
    owned.push("-a".to_owned());
    owned.push(format!(
        "{}={memory}",
        nvidia_target("GPUMemoryTransferRateOffsetAllPerformanceLevels")
    ));

    let refs = owned.iter().map(String::as_str).collect::<Vec<_>>();
    let output = run_as_user(user, NVIDIA_SETTINGS, &refs)?;
    if !output.status.success() {
        return Err(command_failure("aplicação do perfil NVIDIA", &output));
    }
    Ok(())
}

fn run_as_user(user: &InvokingUser, program: &str, args: &[&str]) -> Result<Output, String> {
    let environment = desktop_environment(user);
    let mut command = Command::new(RUNUSER);
    command.arg("-u").arg(&user.name).arg("--").arg(ENV);
    for (key, value) in environment {
        command.arg(format!("{key}={value}"));
    }
    command.arg(program).args(args).env("LC_ALL", "C");
    command
        .output()
        .map_err(|error| format!("falha ao executar {program} como {}: {error}", user.name))
}

fn desktop_environment(user: &InvokingUser) -> BTreeMap<String, String> {
    let mut values = BTreeMap::new();
    values.insert("HOME".to_owned(), user.home.clone());
    values.insert("USER".to_owned(), user.name.clone());
    values.insert("LOGNAME".to_owned(), user.name.clone());
    values.insert(
        "XDG_RUNTIME_DIR".to_owned(),
        format!("/run/user/{}", user.uid),
    );
    for key in [
        "DISPLAY",
        "XAUTHORITY",
        "WAYLAND_DISPLAY",
        "DBUS_SESSION_BUS_ADDRESS",
    ] {
        if let Ok(value) = env::var(key) {
            if !value.is_empty() {
                values.insert(key.to_owned(), value);
            }
        }
    }
    let mut pids = fs::read_dir("/proc")
        .into_iter()
        .flatten()
        .flatten()
        .filter_map(|entry| entry.file_name().to_string_lossy().parse::<u32>().ok())
        .collect::<Vec<_>>();
    pids.sort_unstable();
    for pid in pids {
        let status = fs::read_to_string(format!("/proc/{pid}/status")).unwrap_or_default();
        let process_uid = status
            .lines()
            .find_map(|line| line.strip_prefix("Uid:"))
            .and_then(|line| line.split_whitespace().next())
            .and_then(|value| value.parse::<u32>().ok());
        if process_uid != Some(user.uid) {
            continue;
        }
        let environ = fs::read(format!("/proc/{pid}/environ")).unwrap_or_default();
        for item in environ.split(|byte| *byte == 0) {
            let Ok(item) = std::str::from_utf8(item) else {
                continue;
            };
            let Some((key, value)) = item.split_once('=') else {
                continue;
            };
            if [
                "DISPLAY",
                "XAUTHORITY",
                "WAYLAND_DISPLAY",
                "DBUS_SESSION_BUS_ADDRESS",
            ]
            .contains(&key)
                && !value.is_empty()
            {
                values
                    .entry(key.to_owned())
                    .or_insert_with(|| value.to_owned());
            }
        }
        if values.contains_key("DISPLAY") && values.contains_key("DBUS_SESSION_BUS_ADDRESS") {
            break;
        }
    }
    values
        .entry("DISPLAY".to_owned())
        .or_insert_with(|| ":0".to_owned());
    values
}

fn check_general(reporter: &mut Reporter) -> Result<String, String> {
    require_tools(&[PACMAN, CHECKUPDATES])?;
    reporter.progress(10, "Consultando atualizações de pacotes");
    let updates = available_package_updates(reporter, false)?;
    let normal: Vec<_> = updates
        .iter()
        .filter(|update| !is_protected_general_package(&update.name))
        .collect();
    let protected: Vec<_> = updates
        .iter()
        .filter(|update| is_protected_general_package(&update.name))
        .collect();

    reporter.data("general_update_count", &normal.len().to_string());
    reporter.data("protected_update_count", &protected.len().to_string());
    reporter.data("general_update_summary", &summarize_updates(&normal));

    reporter.progress(55, "Consultando aplicativos Flatpak");
    let flatpak_count = flatpak_update_count(reporter);
    reporter.data("flatpak_update_count", &flatpak_count.to_string());

    reporter.progress(100, "Verificação concluída");
    Ok(format!(
        "{} pacote(s) normal(is) e {} aplicativo(s) Flatpak disponíveis; kernel, NVIDIA e o próprio Mocha Update permanecem protegidos",
        normal.len(), flatpak_count
    ))
}

fn apply_general(reporter: &mut Reporter) -> Result<String, String> {
    require_tools(&[PACMAN, FINDMNT, LVS, LVCREATE, LVREMOVE, SYNC])?;
    ensure_pacman_unlocked()?;
    reporter.progress(
        5,
        "Validando separação entre atualização geral e conjunto gráfico",
    );

    let before = installed_versions(PROTECTED_GENERAL_PACKAGES, reporter)?;
    let pending = available_package_updates(reporter, true)?;
    let normal_count = pending
        .iter()
        .filter(|update| !is_protected_general_package(&update.name))
        .count();

    reporter.progress(15, "Criando ponto de restauração LVM");
    let rollback = create_rollback_snapshot(reporter, "system")?;
    reporter.data("created_rollback_id", &rollback.id);

    reporter.progress(30, "Atualizando pacotes normais do sistema");
    let mut args = vec!["-Syu".to_owned(), "--noconfirm".to_owned()];
    for package in PROTECTED_GENERAL_PACKAGES {
        args.push("--ignore".to_owned());
        args.push((*package).to_owned());
    }
    reporter.required("atualização geral do Pacman", PACMAN, &args)?;

    reporter.progress(78, "Atualizando aplicativos Flatpak do sistema");
    update_system_flatpaks(reporter)?;
    reporter.progress(86, "Atualizando aplicativos Flatpak do usuário");
    update_user_flatpaks(reporter)?;

    reporter.progress(
        92,
        "Confirmando que kernel, driver e aplicativo não foram alterados",
    );
    let after = installed_versions(PROTECTED_GENERAL_PACKAGES, reporter)?;
    if before != after {
        return Err(format!(
            "a proteção detectou alteração inesperada no kernel, no driver ou no aplicativo; restaure o ponto {}",
            rollback.id
        ));
    }

    reporter.progress(100, "Atualização geral concluída");
    Ok(format!(
        "atualização geral concluída para {} pacote(s); kernel, driver e Mocha Update permaneceram inalterados",
        normal_count
    ))
}

fn check_kernel(reporter: &mut Reporter) -> Result<String, String> {
    require_tools(&[PACMAN, CHECKUPDATES, "/usr/bin/vercmp"])?;
    reporter.progress(10, "Validando o repositório próprio mocha-kernel");
    validate_repository_configuration()?;

    reporter.progress(22, "Atualizando a leitura de versões disponíveis");
    let updates = available_package_updates(reporter, false)?;
    let general_pending = updates
        .iter()
        .filter(|update| !is_protected_general_package(&update.name))
        .count();
    reporter.data(
        "general_pending_before_kernel",
        &general_pending.to_string(),
    );

    reporter.progress(
        38,
        "Comparando o conjunto Mocha instalado com o repositório",
    );
    let mut installed = BTreeMap::new();
    let mut candidates = BTreeMap::new();
    let mut changed_packages = Vec::new();

    let mut stack_packages = KERNEL_PACKAGES.to_vec();
    stack_packages.extend_from_slice(NVIDIA_REQUIRED_PACKAGES);
    for &package in NVIDIA_OPTIONAL_PACKAGES {
        if package_installed(package, reporter)? {
            stack_packages.push(package);
        }
    }

    for package in stack_packages {
        let info = sync_package_info(package, reporter)?;
        if KERNEL_PACKAGES.contains(&package) && info.repository != REPOSITORY_NAME {
            return Err(format!(
                "{package} foi encontrado no repositório {}, não em {}",
                info.repository, REPOSITORY_NAME
            ));
        }

        let installed_version = package_version(package, reporter)?;
        let candidate_version = updates
            .iter()
            .find(|update| update.name == package)
            .map(|update| update.new.clone())
            .unwrap_or(info.version);

        let needs_change = match installed_version.as_deref() {
            Some(current) => version_compare(&candidate_version, current)? > 0,
            None => true,
        };
        if needs_change {
            changed_packages.push(package.to_owned());
        }
        installed.insert(
            package.to_owned(),
            installed_version.unwrap_or_else(|| "não instalado".to_owned()),
        );
        candidates.insert(package.to_owned(), candidate_version);
    }

    let installed_kernel = installed
        .get("linux-mocha-lqx")
        .cloned()
        .unwrap_or_else(|| "não instalado".to_owned());
    let candidate_kernel = candidates
        .get("linux-mocha-lqx")
        .cloned()
        .ok_or_else(|| "versão candidata de linux-mocha-lqx não identificada".to_owned())?;
    let installed_driver = installed
        .get("nvidia-open-dkms")
        .cloned()
        .unwrap_or_else(|| "não instalado".to_owned());
    let candidate_driver = candidates
        .get("nvidia-open-dkms")
        .cloned()
        .ok_or_else(|| "versão candidata de nvidia-open-dkms não identificada".to_owned())?;

    reporter.data("kernel_installed_package_version", &installed_kernel);
    reporter.data("kernel_candidate_version", &candidate_kernel);
    reporter.data("driver_installed_package_version", &installed_driver);
    reporter.data("driver_candidate_version", &candidate_driver);
    reporter.data(
        "kernel_stack_change_count",
        &changed_packages.len().to_string(),
    );

    let ready = general_pending == 0 && !changed_packages.is_empty();
    reporter.data("kernel_update_ready", if ready { "true" } else { "false" });

    let summary = if general_pending > 0 {
        format!(
            "há {general_pending} atualização(ões) geral(is) pendente(s); conclua a atualização geral antes do conjunto"
        )
    } else if ready {
        format!(
            "{} pacote(s) do conjunto requer(em) atualização ou reparo; kernel {} e NVIDIA {}",
            changed_packages.len(),
            candidate_kernel,
            candidate_driver
        )
    } else {
        format!(
            "conjunto atual já corresponde ao repositório: kernel {} e NVIDIA {}",
            installed_kernel, installed_driver
        )
    };

    reporter.data("kernel_update_summary", &summary);
    reporter.progress(100, "Verificação do conjunto concluída");
    Ok(summary)
}

fn apply_kernel(reporter: &mut Reporter) -> Result<String, String> {
    require_tools(&[
        PACMAN, DKMS, MKINITCPIO, FINDMNT, LVS, LVCREATE, LVREMOVE, SYNC, GPG,
    ])?;
    ensure_pacman_unlocked()?;
    reporter.progress(5, "Validando repositório e assinatura GPG do Mocha");
    validate_repository_configuration()?;
    validate_repository_key(reporter)?;

    reporter.progress(12, "Sincronizando bancos de dados do Pacman");
    reporter.required(
        "sincronização dos bancos do Pacman",
        PACMAN,
        &["-Syy".to_owned(), "--noconfirm".to_owned()],
    )?;

    reporter.progress(16, "Validando os três pacotes do repositório próprio");
    validate_kernel_repository_packages(reporter)?;

    reporter.progress(20, "Confirmando que a atualização geral está em dia");
    let pending = available_package_updates(reporter, true)?;
    let general_pending: Vec<_> = pending
        .iter()
        .filter(|update| !is_protected_general_package(&update.name))
        .collect();
    if !general_pending.is_empty() {
        return Err(format!(
            "existem {} atualização(ões) geral(is) pendente(s); execute a atualização geral primeiro",
            general_pending.len()
        ));
    }

    reporter.progress(28, "Criando ponto de restauração LVM");
    let rollback = create_rollback_snapshot(reporter, "kernel-driver")?;
    reporter.data("created_rollback_id", &rollback.id);

    reporter.progress(40, "Instalando o kernel Mocha e a pilha NVIDIA");
    let packages = kernel_update_packages(reporter)?;
    let mut args = vec!["-S".to_owned(), "--noconfirm".to_owned()];
    args.extend(packages.iter().map(|package| {
        if KERNEL_PACKAGES.contains(&package.as_str()) {
            format!("{REPOSITORY_NAME}/{package}")
        } else {
            package.clone()
        }
    }));
    reporter.required("instalação do conjunto kernel e driver", PACMAN, &args)?;

    reporter.progress(72, "Reconstruindo módulos DKMS");
    reporter.required("reconstrução DKMS", DKMS, &["autoinstall".to_owned()])?;
    reporter.progress(82, "Regenerando initramfs");
    reporter.required("regeneração do initramfs", MKINITCPIO, &["-P".to_owned()])?;
    reporter.progress(90, "Atualizando o bootloader");
    update_bootloader(reporter)?;

    reporter.progress(96, "Validando o conjunto instalado");
    validate_installed_kernel_driver(reporter)?;
    reporter.data("reboot_required", "true");
    reporter.progress(100, "Kernel e driver atualizados");

    Ok(format!(
        "kernel e driver atualizados; ponto de restauração {} preservado; reinicialização necessária",
        rollback.id
    ))
}

fn remarry(reporter: &mut Reporter) -> Result<String, String> {
    // MOCHA_REMARRY_DKMS_INSTALLED_V66
    fn installed_package_files(package: &str) -> Result<Vec<String>, String> {
        let output = Command::new(PACMAN)
            .args(["-Qql", package])
            .output()
            .map_err(|error| {
                format!("falha ao consultar os arquivos instalados de {package}: {error}")
            })?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr).trim().to_owned();
            return Err(format!(
                "não foi possível consultar os arquivos instalados de {package}: {stderr}"
            ));
        }

        let files = String::from_utf8_lossy(&output.stdout)
            .lines()
            .map(str::trim)
            .filter(|line| !line.is_empty())
            .map(str::to_owned)
            .collect::<Vec<_>>();

        if files.is_empty() {
            return Err(format!(
                "o pacote instalado {package} não publicou sua lista de arquivos"
            ));
        }

        Ok(files)
    }

    fn normalized_package_path(path: &str) -> &str {
        path.trim().trim_start_matches('/').trim_end_matches('/')
    }

    fn kernel_releases(files: &[String]) -> Vec<String> {
        let mut releases = files
            .iter()
            .filter_map(|path| {
                let normalized = normalized_package_path(path);
                let rest = normalized.strip_prefix("usr/lib/modules/")?;
                let (release, tail) = rest.split_once('/')?;
                (!release.is_empty()
                    && (tail == "pkgbase" || tail == "vmlinuz" || tail.starts_with("kernel/")))
                .then_some(release.to_owned())
            })
            .collect::<Vec<_>>();

        releases.sort();
        releases.dedup();
        releases
    }

    fn nvidia_dkms_versions(files: &[String]) -> Vec<String> {
        let mut versions = files
            .iter()
            .filter_map(|path| {
                let normalized = normalized_package_path(path);
                let rest = normalized.strip_prefix("usr/src/nvidia-")?;
                rest.strip_suffix("/dkms.conf").map(str::to_owned)
            })
            .collect::<Vec<_>>();

        versions.sort();
        versions.dedup();
        versions
    }

    fn required_output(program: &str, args: &[&str], label: &str) -> Result<String, String> {
        let output = Command::new(program)
            .args(args)
            .output()
            .map_err(|error| format!("falha ao executar {label}: {error}"))?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr).trim().to_owned();
            return Err(format!("{label} falhou: {stderr}"));
        }

        Ok(String::from_utf8_lossy(&output.stdout).trim().to_owned())
    }

    fn installed_package_version(package: &str) -> Result<String, String> {
        let output = required_output(
            PACMAN,
            &["-Q", package],
            &format!("consulta do pacote {package}"),
        )?;
        let mut fields = output.split_whitespace();
        let installed_name = fields
            .next()
            .ok_or_else(|| format!("resposta vazia ao consultar {package}"))?;
        let version = fields
            .next()
            .ok_or_else(|| format!("versão ausente ao consultar {package}"))?;

        if installed_name != package || fields.next().is_some() {
            return Err(format!(
                "resposta inesperada ao consultar {package}: {output}"
            ));
        }

        Ok(version.to_owned())
    }

    require_tools(&[
        PACMAN, DKMS, DEPMOD, MODINFO, MKINITCPIO, FINDMNT, LVS, LVCREATE, LVREMOVE, SYNC,
    ])?;
    ensure_pacman_unlocked()?;

    reporter.progress(5, "Lendo o conjunto exato já instalado");
    let packages = installed_kernel_driver_packages(reporter)?;
    let before = installed_versions_strings(&packages, reporter)?;

    let kernel_package_version = installed_package_version("linux-mocha-lqx")?;
    let headers_package_version = installed_package_version("linux-mocha-lqx-headers")?;
    let nvidia_package_version = installed_package_version("nvidia-open-dkms")?;

    if kernel_package_version != headers_package_version {
        return Err(format!(
            "kernel e headers instalados não correspondem: linux-mocha-lqx {kernel_package_version}; linux-mocha-lqx-headers {headers_package_version}"
        ));
    }

    reporter.progress(12, "Validando o kernel e os headers instalados");
    let kernel_files = installed_package_files("linux-mocha-lqx")?;
    let releases = kernel_releases(&kernel_files);
    if releases.len() != 1 {
        return Err(format!(
            "o pacote linux-mocha-lqx deveria identificar exatamente um kernel instalado; encontrados: {}",
            if releases.is_empty() {
                "nenhum".to_owned()
            } else {
                releases.join(", ")
            }
        ));
    }
    let kernel_release = releases[0].clone();
    let modules_dir = PathBuf::from("/usr/lib/modules").join(&kernel_release);
    let build_link = modules_dir.join("build");
    let vmlinuz = Path::new("/boot/vmlinuz-linux-mocha-lqx");

    if !modules_dir.is_dir() {
        return Err(format!(
            "diretório do kernel instalado ausente: {}",
            modules_dir.display()
        ));
    }
    if !build_link.is_dir() {
        return Err(format!(
            "headers instalados ausentes ou com link build inválido: {}",
            build_link.display()
        ));
    }
    if !vmlinuz.is_file() {
        return Err(format!(
            "imagem do kernel instalada ausente: {}",
            vmlinuz.display()
        ));
    }

    let build_target = fs::canonicalize(&build_link).map_err(|error| {
        format!(
            "não foi possível resolver {}: {error}",
            build_link.display()
        )
    })?;
    let headers_makefile = build_target.join("Makefile");
    let headers_release_file = build_target.join("include/config/kernel.release");
    if !headers_makefile.is_file() {
        return Err(format!(
            "Makefile dos headers ausente: {}",
            headers_makefile.display()
        ));
    }
    if !headers_release_file.is_file() {
        return Err(format!(
            "kernel.release dos headers ausente: {}",
            headers_release_file.display()
        ));
    }

    let headers_kernel_release = fs::read_to_string(&headers_release_file)
        .map_err(|error| {
            format!(
                "não foi possível ler {}: {error}",
                headers_release_file.display()
            )
        })?
        .trim()
        .to_owned();
    if headers_kernel_release != kernel_release {
        return Err(format!(
            "kernel.release dos headers diverge do kernel instalado: esperado={kernel_release}; encontrado={headers_kernel_release}"
        ));
    }

    let headers_files = installed_package_files("linux-mocha-lqx-headers")?;
    for required_header in [&headers_makefile, &headers_release_file] {
        let required_text = required_header.to_string_lossy();
        let required_normalized = required_text.trim_start_matches('/').trim_end_matches('/');
        let header_owns_file = headers_files
            .iter()
            .any(|path| normalized_package_path(path) == required_normalized);

        if !header_owns_file {
            return Err(format!(
                "arquivo de headers não pertence a linux-mocha-lqx-headers: {}",
                required_header.display()
            ));
        }
    }

    reporter.record(&format!(
        "REMARRY_KERNEL={} KERNEL_PACKAGE_VERSION={} HEADERS={} HEADERS_TARGET={} HEADERS_KERNEL_RELEASE={}",
        kernel_release,
        kernel_package_version,
        build_link.display(),
        build_target.display(),
        headers_kernel_release
    ));

    reporter.progress(20, "Validando o código-fonte NVIDIA DKMS instalado");
    let nvidia_files = installed_package_files("nvidia-open-dkms")?;
    let dkms_versions = nvidia_dkms_versions(&nvidia_files);
    if dkms_versions.len() != 1 {
        return Err(format!(
            "nvidia-open-dkms deveria identificar exatamente uma fonte DKMS instalada; encontradas: {}",
            if dkms_versions.is_empty() {
                "nenhuma".to_owned()
            } else {
                dkms_versions.join(", ")
            }
        ));
    }
    let dkms_version = dkms_versions[0].clone();
    let dkms_conf = PathBuf::from(format!("/usr/src/nvidia-{dkms_version}/dkms.conf"));
    if !dkms_conf.is_file() {
        return Err(format!(
            "fonte NVIDIA DKMS instalada incompleta: {}",
            dkms_conf.display()
        ));
    }
    reporter.record(&format!(
        "REMARRY_NVIDIA_PACKAGE_VERSION={} DKMS_VERSION={} DKMS_CONF={}",
        nvidia_package_version,
        dkms_version,
        dkms_conf.display()
    ));

    reporter.progress(28, "Criando ponto de restauração LVM e backup do boot");
    let rollback = create_rollback_snapshot(reporter, "remarry")?;
    reporter.data("created_rollback_id", &rollback.id);

    reporter.progress(
        42,
        "Compilando novamente o NVIDIA DKMS para o kernel instalado",
    );
    reporter.required(
        "compilação forçada do NVIDIA DKMS",
        DKMS,
        &[
            "build".to_owned(),
            "--force".to_owned(),
            "-m".to_owned(),
            "nvidia".to_owned(),
            "-v".to_owned(),
            dkms_version.clone(),
            "-k".to_owned(),
            kernel_release.clone(),
        ],
    )?;

    reporter.progress(62, "Instalando novamente os módulos NVIDIA compilados");
    reporter.required(
        "instalação forçada do NVIDIA DKMS",
        DKMS,
        &[
            "install".to_owned(),
            "--force".to_owned(),
            "-m".to_owned(),
            "nvidia".to_owned(),
            "-v".to_owned(),
            dkms_version.clone(),
            "-k".to_owned(),
            kernel_release.clone(),
        ],
    )?;

    reporter.progress(72, "Atualizando dependências dos módulos do kernel");
    reporter.required(
        "atualização do depmod",
        DEPMOD,
        &["-a".to_owned(), kernel_release.clone()],
    )?;

    reporter.progress(80, "Regenerando o initramfs");
    reporter.required("regeneração do initramfs", MKINITCPIO, &["-P".to_owned()])?;

    reporter.progress(88, "Atualizando o bootloader");
    update_bootloader(reporter)?;

    reporter.progress(93, "Validando o casamento exato do NVIDIA");
    let dkms_status = required_output(
        DKMS,
        &[
            "status",
            "-m",
            "nvidia",
            "-v",
            &dkms_version,
            "-k",
            &kernel_release,
        ],
        "consulta do estado DKMS",
    )?;
    if !dkms_status.contains("installed") {
        return Err(format!(
            "o DKMS não confirmou o NVIDIA como instalado para {kernel_release}: {dkms_status}"
        ));
    }
    reporter.record(&format!("REMARRY_DKMS_STATUS={dkms_status}"));

    // V70_CANONICAL_MODULE_PATH_VALIDATION
    let expected_module_base =
        std::fs::canonicalize(format!("/usr/lib/modules/{kernel_release}")).map_err(|error| {
            format!(
                "não foi possível normalizar a árvore de módulos do kernel                  {kernel_release}: {error}"
            )
        })?;

    for module in ["nvidia", "nvidia_modeset", "nvidia_drm", "nvidia_uvm"] {
        let module_path = required_output(
            MODINFO,
            &["-k", &kernel_release, "-n", module],
            &format!("localização do módulo {module}"),
        )?;
        let module_path_real = std::fs::canonicalize(&module_path).map_err(|error| {
            format!(
                "não foi possível normalizar o caminho do módulo {module}:                  {module_path}: {error}"
            )
        })?;

        if !module_path_real.starts_with(&expected_module_base) {
            return Err(format!(
                "o módulo {module} não pertence ao kernel {kernel_release}:                  informado={module_path}; real={}",
                module_path_real.display()
            ));
        }

        let vermagic = required_output(
            MODINFO,
            &["-k", &kernel_release, "-F", "vermagic", module],
            &format!("vermagic do módulo {module}"),
        )?;
        let vermagic_release = vermagic.split_whitespace().next().unwrap_or("");

        if vermagic_release != kernel_release {
            return Err(format!(
                "o vermagic do módulo {module} não corresponde ao kernel                  {kernel_release}: {vermagic}"
            ));
        }

        reporter.record(&format!(
            "REMARRY_MODULE={} KERNEL={} PATH={} REAL_PATH={} VERMAGIC={}",
            module,
            kernel_release,
            module_path,
            module_path_real.display(),
            vermagic
        ));
    }

    let module_version = required_output(
        MODINFO,
        &["-k", &kernel_release, "-F", "version", "nvidia"],
        "leitura da versão do módulo NVIDIA",
    )?;
    if module_version != dkms_version {
        return Err(format!(
            "a versão do módulo NVIDIA diverge da fonte DKMS: módulo={module_version}; DKMS={dkms_version}"
        ));
    }

    reporter.progress(97, "Confirmando que nenhum pacote mudou de versão");
    let after = installed_versions_strings(&packages, reporter)?;
    if before != after {
        return Err(format!(
            "o recasamento detectou mudança de versão; restaure o ponto {}",
            rollback.id
        ));
    }

    validate_installed_kernel_driver(reporter)?;
    reporter.data("reboot_required", "true");
    reporter.progress(100, "Recasamento concluído sem depender do cache");

    Ok(format!(
        "kernel {} e NVIDIA {} recasados usando os arquivos já instalados, sem troca de pacotes; ponto {} preservado; reinicialização recomendada",
        kernel_release, dkms_version, rollback.id
    ))
}

#[allow(unreachable_code)]
fn check_rollbacks(reporter: &mut Reporter) -> Result<String, String> {
    return check_rollbacks_v61(reporter);
    require_tools(&[FINDMNT, LVS])?;
    reporter.progress(15, "Lendo pontos de restauração do Mocha Update");
    let mut rollbacks = Vec::new();
    for rollback in load_rollbacks()? {
        match validate_snapshot_exists(reporter, &rollback) {
            Ok(()) => rollbacks.push(rollback),
            Err(error) => reporter.record(&format!(
                "ROLLBACK_IGNORADO={} MOTIVO={}",
                rollback.id, error
            )),
        }
    }
    rollbacks.sort_by(|left, right| right.id.cmp(&left.id));

    reporter.data("rollback_count", &rollbacks.len().to_string());
    if let Some(selected) = rollbacks.first() {
        reporter.data("selected_rollback_id", &selected.id);
        reporter.data("selected_rollback_summary", &selected.summary());
        reporter.data("rollback_ready", "true");
        reporter.progress(100, "Ponto de restauração mais recente selecionado");
        Ok(format!(
            "{} ponto(s) válido(s); selecionado: {}",
            rollbacks.len(),
            selected.summary()
        ))
    } else {
        reporter.data("selected_rollback_id", "");
        reporter.data(
            "selected_rollback_summary",
            "Nenhum ponto de restauração válido",
        );
        reporter.data("rollback_ready", "false");
        reporter.progress(100, "Nenhum ponto de restauração encontrado");
        Ok("nenhum ponto de restauração criado pelo Mocha Update foi encontrado".to_owned())
    }
}

#[allow(unreachable_code)]
fn apply_rollback(reporter: &mut Reporter, id: &str) -> Result<String, String> {
    return apply_rollback_v61(reporter, id);
    require_tools(&[FINDMNT, LVS, LVCONVERT])?;
    if !safe_snapshot_id(id) {
        return Err("identificador de rollback inválido".to_owned());
    }

    reporter.progress(10, "Validando o ponto de restauração selecionado");
    let rollback = load_rollback(id)?;
    let boot_restore_marker = prepare_boot_restore(reporter, &rollback.id)?;
    validate_snapshot_exists(reporter, &rollback)?;

    reporter.progress(35, "Agendando a restauração dos volumes protegidos");
    let mut merge_args = vec!["--merge".to_owned(), "-y".to_owned()];
    merge_args.extend(
        rollback
            .volumes
            .iter()
            .rev()
            .map(|volume| volume.snapshot_path.clone()),
    );
    reporter.required(
        "mesclagem conjunta dos snapshots LVM",
        LVCONVERT,
        &merge_args,
    )?;

    reporter.data("reboot_required", "true");
    reporter.data("rollback_ready", "false");
    commit_boot_restore(boot_restore_marker.as_deref())?;
    reporter.progress(100, "Rollback agendado para a próxima ativação do volume");
    Ok(format!(
        "rollback {} agendado; reinicie o sistema para concluir a restauração",
        id
    ))
}

#[derive(Debug)]
struct UpdateInfo {
    name: String,
    old: String,
    new: String,
}

fn available_package_updates(
    reporter: &mut Reporter,
    synchronized_database: bool,
) -> Result<Vec<UpdateInfo>, String> {
    let (program, args, accepted_no_updates) = if synchronized_database {
        (PACMAN, vec!["-Qu".to_owned()], vec![0, 1])
    } else {
        if !Path::new(CHECKUPDATES).is_file() {
            return Err(
                "checkupdates não está instalado; instale pacman-contrib para verificações atuais"
                    .to_owned(),
            );
        }
        (CHECKUPDATES, Vec::new(), vec![0, 2])
    };

    let output = reporter.command("consulta de atualizações", program, &args)?;
    let code = output.status.code().unwrap_or(255);
    if !accepted_no_updates.contains(&code) {
        return Err(command_failure("consulta de atualizações", &output));
    }

    Ok(parse_updates(&String::from_utf8_lossy(&output.stdout)))
}

fn parse_updates(value: &str) -> Vec<UpdateInfo> {
    value
        .lines()
        .filter_map(|line| {
            let mut parts = line.split_whitespace();
            let name = parts.next()?.to_owned();
            let old = parts.next()?.to_owned();
            let arrow = parts.next()?;
            let new = parts.next()?.to_owned();
            (arrow == "->").then_some(UpdateInfo { name, old, new })
        })
        .collect()
}

fn summarize_updates(updates: &[&UpdateInfo]) -> String {
    if updates.is_empty() {
        return "Nenhuma atualização geral pendente".to_owned();
    }

    let mut summary = updates
        .iter()
        .take(6)
        .map(|update| format!("{} {}→{}", update.name, update.old, update.new))
        .collect::<Vec<_>>()
        .join(", ");
    if updates.len() > 6 {
        summary.push_str(&format!(" e mais {}", updates.len() - 6));
    }
    summary
}

fn flatpak_update_count(reporter: &mut Reporter) -> usize {
    if !Path::new(FLATPAK).is_file() {
        return 0;
    }

    flatpak_scope_update_count(reporter, "sistema", "--system")
        + flatpak_scope_update_count(reporter, "usuário", "--user")
}

fn flatpak_scope_update_count(reporter: &mut Reporter, label: &str, scope: &str) -> usize {
    let args = vec![
        "remote-ls".to_owned(),
        scope.to_owned(),
        "--updates".to_owned(),
        "--columns=application".to_owned(),
    ];
    reporter
        .command(
            &format!("consulta de atualizações Flatpak do {label}"),
            FLATPAK,
            &args,
        )
        .ok()
        .filter(|output| output.status.success())
        .map(|output| {
            String::from_utf8_lossy(&output.stdout)
                .lines()
                .filter(|line| !line.trim().is_empty())
                .count()
        })
        .unwrap_or(0)
}

fn update_system_flatpaks(reporter: &mut Reporter) -> Result<(), String> {
    if !Path::new(FLATPAK).is_file() {
        reporter.record("FLATPAK_SYSTEM=NAO_INSTALADO");
        return Ok(());
    }
    reporter.required(
        "atualização Flatpak do sistema",
        FLATPAK,
        &[
            "update".to_owned(),
            "--system".to_owned(),
            "--noninteractive".to_owned(),
            "-y".to_owned(),
        ],
    )?;
    Ok(())
}

fn update_user_flatpaks(reporter: &mut Reporter) -> Result<(), String> {
    if !Path::new(FLATPAK).is_file() {
        return Ok(());
    }
    let Some(user) = invoking_user()? else {
        reporter.record("FLATPAK_USER=NAO_IDENTIFICADO");
        return Ok(());
    };
    if !Path::new(RUNUSER).is_file() || !Path::new(ENV).is_file() {
        return Err(
            "runuser ou env não está disponível para atualizar Flatpaks do usuário".to_owned(),
        );
    }

    reporter.required(
        "atualização Flatpak do usuário",
        RUNUSER,
        &[
            "-u".to_owned(),
            user.name.clone(),
            "--".to_owned(),
            ENV.to_owned(),
            "-i".to_owned(),
            format!("HOME={}", user.home),
            format!("USER={}", user.name),
            format!("LOGNAME={}", user.name),
            format!("XDG_RUNTIME_DIR=/run/user/{}", user.uid),
            "PATH=/usr/bin:/bin".to_owned(),
            FLATPAK.to_owned(),
            "update".to_owned(),
            "--user".to_owned(),
            "--noninteractive".to_owned(),
            "-y".to_owned(),
        ],
    )?;
    Ok(())
}

#[derive(Debug)]
struct PackageInfo {
    repository: String,
    version: String,
}

fn sync_package_info(package: &str, reporter: &mut Reporter) -> Result<PackageInfo, String> {
    let text = reporter.required(
        &format!("consulta do pacote {package}"),
        PACMAN,
        &["-Si".to_owned(), package.to_owned()],
    )?;
    let repository = field_value(&text, "Repository")
        .ok_or_else(|| format!("repositório de {package} não identificado"))?;
    let version = field_value(&text, "Version")
        .ok_or_else(|| format!("versão de {package} não identificada"))?;
    Ok(PackageInfo {
        repository,
        version,
    })
}

fn field_value(text: &str, key: &str) -> Option<String> {
    text.lines().find_map(|line| {
        let (left, right) = line.split_once(':')?;
        (left.trim() == key).then(|| right.trim().to_owned())
    })
}

fn package_version(package: &str, reporter: &mut Reporter) -> Result<Option<String>, String> {
    let output = reporter.command(
        &format!("versão instalada de {package}"),
        PACMAN,
        &["-Q".to_owned(), package.to_owned()],
    )?;
    if output.status.success() {
        let text = String::from_utf8_lossy(&output.stdout);
        Ok(text.split_whitespace().nth(1).map(ToOwned::to_owned))
    } else if output.status.code() == Some(1) {
        Ok(None)
    } else {
        Err(command_failure(
            &format!("versão instalada de {package}"),
            &output,
        ))
    }
}

fn package_installed(package: &str, reporter: &mut Reporter) -> Result<bool, String> {
    Ok(package_version(package, reporter)?.is_some())
}

fn installed_versions(
    packages: &[&str],
    reporter: &mut Reporter,
) -> Result<BTreeMap<String, Option<String>>, String> {
    let mut values = BTreeMap::new();
    for package in packages {
        values.insert((*package).to_owned(), package_version(package, reporter)?);
    }
    Ok(values)
}

fn installed_versions_strings(
    packages: &[String],
    reporter: &mut Reporter,
) -> Result<BTreeMap<String, String>, String> {
    let mut values = BTreeMap::new();
    for package in packages {
        let version = package_version(package, reporter)?
            .ok_or_else(|| format!("{package} não está instalado"))?;
        values.insert(package.clone(), version);
    }
    Ok(values)
}

fn kernel_update_packages(reporter: &mut Reporter) -> Result<Vec<String>, String> {
    let mut packages = KERNEL_PACKAGES
        .iter()
        .map(|value| (*value).to_owned())
        .collect::<Vec<_>>();
    packages.extend(
        NVIDIA_REQUIRED_PACKAGES
            .iter()
            .map(|value| (*value).to_owned()),
    );
    for package in NVIDIA_OPTIONAL_PACKAGES {
        if package_installed(package, reporter)? {
            packages.push((*package).to_owned());
        }
    }
    Ok(packages)
}

fn installed_kernel_driver_packages(reporter: &mut Reporter) -> Result<Vec<String>, String> {
    let packages = kernel_update_packages(reporter)?;
    for package in &packages {
        if package_version(package, reporter)?.is_none() {
            return Err(format!(
                "o conjunto canônico instalado está incompleto: {package} não está instalado"
            ));
        }
    }
    Ok(packages)
}

fn version_compare(left: &str, right: &str) -> Result<i32, String> {
    let output = Command::new("/usr/bin/vercmp")
        .arg(left)
        .arg(right)
        .env("LC_ALL", "C")
        .output()
        .map_err(|error| format!("falha ao comparar versões: {error}"))?;
    if !output.status.success() {
        return Err("vercmp não conseguiu comparar as versões".to_owned());
    }
    String::from_utf8_lossy(&output.stdout)
        .trim()
        .parse::<i32>()
        .map_err(|error| format!("resultado inválido do vercmp: {error}"))
}

fn validate_repository_configuration() -> Result<(), String> {
    let contents = fs::read_to_string("/etc/pacman.conf")
        .map_err(|error| format!("não foi possível ler /etc/pacman.conf: {error}"))?;
    let expected_section = format!("[{REPOSITORY_NAME}]");
    let mut in_section = false;
    let mut found_section = false;
    let mut valid_server = false;

    for raw_line in contents.lines() {
        let line = raw_line.split('#').next().unwrap_or_default().trim();
        if line.starts_with('[') && line.ends_with(']') {
            in_section = line == expected_section;
            found_section |= in_section;
            continue;
        }
        if !in_section {
            continue;
        }
        let Some((key, value)) = line.split_once('=') else {
            continue;
        };
        if key.trim() != "Server" {
            continue;
        }
        let normalized = value
            .trim()
            .replace("$arch", "x86_64")
            .trim_end_matches('/')
            .to_owned();
        if normalized == REPOSITORY_URL {
            valid_server = true;
        }
    }

    if !found_section {
        return Err(format!(
            "o repositório [{REPOSITORY_NAME}] não está configurado"
        ));
    }
    if !valid_server {
        return Err(format!(
            "o repositório [{REPOSITORY_NAME}] não usa o servidor canônico {REPOSITORY_URL}"
        ));
    }
    Ok(())
}

fn validate_kernel_repository_packages(reporter: &mut Reporter) -> Result<(), String> {
    for package in KERNEL_PACKAGES {
        let info = sync_package_info(package, reporter)?;
        if info.repository != REPOSITORY_NAME {
            return Err(format!(
                "{package} foi encontrado no repositório {}, não em {}",
                info.repository, REPOSITORY_NAME
            ));
        }
    }
    Ok(())
}

fn validate_repository_key(reporter: &mut Reporter) -> Result<(), String> {
    let output = reporter.required(
        "validação da chave GPG do repositório",
        GPG,
        &[
            "--homedir".to_owned(),
            "/etc/pacman.d/gnupg".to_owned(),
            "--with-colons".to_owned(),
            "--fingerprint".to_owned(),
            REPOSITORY_FINGERPRINT.to_owned(),
        ],
    )?;
    let found = output.lines().any(|line| {
        let mut fields = line.split(':');
        fields.next() == Some("fpr") && fields.nth(8) == Some(REPOSITORY_FINGERPRINT)
    });
    if !found {
        return Err(format!(
            "a chave GPG {} não está presente no chaveiro do Pacman",
            REPOSITORY_FINGERPRINT
        ));
    }
    Ok(())
}

fn validate_installed_kernel_driver(reporter: &mut Reporter) -> Result<(), String> {
    for package in KERNEL_PACKAGES {
        if package_version(package, reporter)?.is_none() {
            return Err(format!("validação falhou: {package} não está instalado"));
        }
    }
    for package in NVIDIA_REQUIRED_PACKAGES {
        if package_version(package, reporter)?.is_none() {
            return Err(format!("validação falhou: {package} não está instalado"));
        }
    }

    let module_releases = fs::read_dir("/usr/lib/modules")
        .map_err(|error| format!("não foi possível ler /usr/lib/modules: {error}"))?
        .filter_map(Result::ok)
        .filter_map(|entry| {
            let file_type = entry.file_type().ok()?;
            if !file_type.is_dir() {
                return None;
            }
            let name = entry.file_name().into_string().ok()?;
            let lower = name.to_ascii_lowercase();
            (lower.contains("mocha") && lower.contains("lqx")).then_some(name)
        })
        .collect::<Vec<_>>();
    if module_releases.is_empty() {
        return Err("nenhuma árvore de módulos do kernel Mocha lqx foi encontrada".to_owned());
    }

    let dkms = reporter.required("estado DKMS", DKMS, &["status".to_owned()])?;
    let dkms_lower = dkms.to_ascii_lowercase();
    for release in &module_releases {
        let build_path = Path::new("/usr/lib/modules").join(release).join("build");
        if !build_path.exists() {
            return Err(format!(
                "os headers não criaram o caminho de compilação para {release}"
            ));
        }
        if !dkms_lower.contains("nvidia")
            || !dkms_lower.contains(&release.to_ascii_lowercase())
            || !dkms_lower.contains("installed")
        {
            return Err(format!(
                "a validação DKMS não encontrou o módulo NVIDIA instalado para {release}"
            ));
        }
    }

    for path in [
        "/boot/vmlinuz-linux-mocha-lqx",
        "/boot/initramfs-linux-mocha-lqx.img",
    ] {
        if !Path::new(path).is_file() {
            return Err(format!("artefato de inicialização ausente: {path}"));
        }
    }
    Ok(())
}

fn update_bootloader(reporter: &mut Reporter) -> Result<(), String> {
    if Path::new(GRUB_MKCONFIG).is_file() && Path::new("/boot/grub").is_dir() {
        reporter.required(
            "atualização do GRUB",
            GRUB_MKCONFIG,
            &["-o".to_owned(), "/boot/grub/grub.cfg".to_owned()],
        )?;
        let config = fs::read_to_string("/boot/grub/grub.cfg")
            .map_err(|error| format!("não foi possível validar /boot/grub/grub.cfg: {error}"))?;
        if !config.contains("vmlinuz-linux-mocha-lqx") {
            return Err(
                "o GRUB foi regenerado, mas não contém a entrada do kernel Mocha lqx".to_owned(),
            );
        }
        return Ok(());
    }
    Err("GRUB não foi encontrado no caminho canônico /boot/grub".to_owned())
}

#[derive(Debug, Clone)]
struct RollbackVolume {
    target: String,
    origin_path: String,
    snapshot_path: String,
    snapshot_name: String,
}

#[derive(Debug, Clone)]
struct RollbackInfo {
    id: String,
    operation: String,
    created_at: String,
    kernel: String,
    driver: String,
    volumes: Vec<RollbackVolume>,
}

impl RollbackInfo {
    fn summary(&self) -> String {
        format!(
            "{} · {} · kernel {} · NVIDIA {} · {} volume(s)",
            self.created_at,
            self.operation,
            self.kernel,
            self.driver,
            self.volumes.len()
        )
    }
}

#[allow(unreachable_code)]
fn create_rollback_snapshot(
    reporter: &mut Reporter,
    operation: &str,
) -> Result<RollbackInfo, String> {
    return create_rollback_snapshot_v61(reporter, operation);
    fs::create_dir_all(ROOT_STATE)
        .map_err(|error| format!("não foi possível criar {ROOT_STATE}: {error}"))?;
    fs::create_dir_all(ROLLBACKS)
        .map_err(|error| format!("não foi possível criar {ROLLBACKS}: {error}"))?;

    reporter.required("sincronização de buffers", SYNC, &[])?;

    let stamp = timestamp()?;
    let id = format!("mocha-update-{stamp}-{operation}");
    if !safe_snapshot_id(&id) {
        return Err("identificador interno de snapshot inválido".to_owned());
    }

    let rollback_directory = Path::new(ROLLBACKS).join(&id);
    if let Err(error) = create_boot_backups(reporter, &id) {
        let _ = fs::remove_dir_all(&rollback_directory);
        return Err(error);
    }

    let mut volumes = Vec::new();
    for (target, suffix) in [("/", "root"), ("/home", "home")] {
        let source = match mount_source(reporter, target) {
            Ok(value) => value,
            Err(error) => {
                remove_snapshots_best_effort(reporter, &volumes);
                let _ = fs::remove_dir_all(&rollback_directory);
                return Err(error);
            }
        };

        if volumes
            .iter()
            .any(|volume: &RollbackVolume| same_block_device(&volume.origin_path, &source))
        {
            reporter.record(&format!(
                "SNAPSHOT_TARGET={} SOURCE={} RESULT=COMPARTILHADO_COM_VOLUME_ANTERIOR",
                target, source
            ));
            continue;
        }

        let volume = match prepare_snapshot_volume(reporter, &id, target, suffix, &source) {
            Ok(value) => value,
            Err(error) => {
                remove_snapshots_best_effort(reporter, &volumes);
                let _ = fs::remove_dir_all(&rollback_directory);
                return Err(error);
            }
        };

        let result = reporter.required(
            &format!("criação do snapshot LVM de {target}"),
            LVCREATE,
            &[
                "-s".to_owned(),
                "-n".to_owned(),
                volume.snapshot_name.clone(),
                volume.origin_path.clone(),
            ],
        );
        if let Err(error) = result {
            remove_snapshots_best_effort(reporter, &volumes);
            let _ = fs::remove_dir_all(&rollback_directory);
            return Err(error);
        }
        volumes.push(volume);
    }

    if volumes.is_empty() {
        let _ = fs::remove_dir_all(&rollback_directory);
        return Err("nenhum volume thin LVM protegido foi identificado para / ou /home".to_owned());
    }

    let kernel =
        command_text("/usr/bin/uname", &["-r"]).unwrap_or_else(|_| "desconhecido".to_owned());
    let driver = fs::read_to_string("/sys/module/nvidia/version")
        .map(|value| value.trim().to_owned())
        .unwrap_or_else(|_| "não carregado".to_owned());
    let info = RollbackInfo {
        id,
        operation: operation.to_owned(),
        created_at: stamp,
        kernel,
        driver,
        volumes,
    };

    if let Err(error) = persist_rollback(reporter, &info) {
        remove_snapshots_best_effort(reporter, &info.volumes);
        let _ = fs::remove_dir_all(Path::new(ROLLBACKS).join(&info.id));
        return Err(error);
    }

    Ok(info)
}

fn exact_mount_target(
    reporter: &mut Reporter,
    target: &str,
    required: bool,
) -> Result<bool, String> {
    if !Path::new(target).exists() {
        if required {
            return Err(format!("ponto protegido ausente: {target}"));
        }
        reporter.record(&format!("BACKUP_TARGET={} RESULT=CAMINHO_AUSENTE", target));
        return Ok(false);
    }

    let mounted_target = reporter.required(
        &format!("validação do ponto de montagem {target}"),
        FINDMNT,
        &[
            "-n".to_owned(),
            "-o".to_owned(),
            "TARGET".to_owned(),
            "-T".to_owned(),
            target.to_owned(),
        ],
    )?;

    if mounted_target.trim() == target {
        return Ok(true);
    }

    if required {
        return Err(format!(
            "{target} precisa estar montado como ponto separado antes da operação"
        ));
    }

    reporter.record(&format!(
        "BACKUP_TARGET={} RESULT=NAO_E_PONTO_SEPARADO",
        target
    ));
    Ok(false)
}

fn backup_mounted_tree(
    reporter: &mut Reporter,
    rollback_id: &str,
    target: &str,
    stem: &str,
    required: bool,
) -> Result<bool, String> {
    if !exact_mount_target(reporter, target, required)? {
        return Ok(false);
    }

    let directory = Path::new(ROLLBACKS).join(rollback_id);
    fs::create_dir_all(&directory)
        .map_err(|error| format!("não foi possível criar {}: {error}", directory.display()))?;

    let archive = directory.join(format!("{stem}.tar"));
    let checksum = directory.join(format!("{stem}.sha256"));
    let source_file = directory.join(format!("{stem}-source.txt"));

    reporter.required(
        &format!("backup transacional de {target}"),
        "/usr/bin/tar",
        &[
            "-C".to_owned(),
            target.to_owned(),
            "--one-file-system".to_owned(),
            "--numeric-owner".to_owned(),
            "-cpf".to_owned(),
            archive.display().to_string(),
            ".".to_owned(),
        ],
    )?;

    reporter.required(
        &format!("validação estrutural do backup de {target}"),
        "/usr/bin/tar",
        &["-tf".to_owned(), archive.display().to_string()],
    )?;

    let digest_output = reporter.required(
        &format!("SHA-256 do backup de {target}"),
        "/usr/bin/sha256sum",
        &[archive.display().to_string()],
    )?;
    let digest = digest_output
        .split_whitespace()
        .next()
        .filter(|value| value.len() == 64 && value.bytes().all(|byte| byte.is_ascii_hexdigit()))
        .ok_or_else(|| format!("SHA-256 inválido para o backup de {target}"))?;

    fs::write(&checksum, format!("{digest}  {}\n", archive.display()))
        .map_err(|error| format!("não foi possível gravar {}: {error}", checksum.display()))?;

    let mount_description = reporter.required(
        &format!("identificação do dispositivo de {target}"),
        FINDMNT,
        &[
            "-n".to_owned(),
            "-o".to_owned(),
            "SOURCE,FSTYPE,UUID,OPTIONS".to_owned(),
            "-T".to_owned(),
            target.to_owned(),
        ],
    )?;
    fs::write(&source_file, mount_description)
        .map_err(|error| format!("não foi possível gravar {}: {error}", source_file.display()))?;

    for path in [&archive, &checksum, &source_file] {
        fs::set_permissions(path, fs::Permissions::from_mode(0o600))
            .map_err(|error| format!("não foi possível proteger {}: {error}", path.display()))?;
    }

    reporter.record(&format!(
        "BACKUP_TARGET={} ARCHIVE={} SHA256={} RESULT=CRIADO",
        target,
        archive.display(),
        digest
    ));
    Ok(true)
}

fn create_boot_backups(reporter: &mut Reporter, rollback_id: &str) -> Result<(), String> {
    let directory = Path::new(ROLLBACKS).join(rollback_id);

    let result = (|| -> Result<(), String> {
        backup_mounted_tree(reporter, rollback_id, "/boot", "boot", true)?;
        backup_mounted_tree(reporter, rollback_id, "/boot/efi", "efi", false)?;
        Ok(())
    })();

    if result.is_err() {
        let _ = fs::remove_dir_all(&directory);
    }
    result
}

fn prepare_boot_restore(
    reporter: &mut Reporter,
    rollback_id: &str,
) -> Result<Option<PathBuf>, String> {
    if !safe_snapshot_id(rollback_id) {
        return Err("identificador de rollback inválido para restaurar /boot".to_owned());
    }

    let directory = Path::new(ROLLBACKS).join(rollback_id);
    let boot_archive = directory.join("boot.tar");
    let boot_checksum = directory.join("boot.sha256");

    if !boot_archive.is_file() {
        reporter.record(&format!(
            "BOOT_RESTORE_ROLLBACK={} RESULT=LEGADO_SEM_BACKUP_DE_BOOT",
            rollback_id
        ));
        return Ok(None);
    }

    if !boot_checksum.is_file() {
        return Err(format!(
            "o rollback {rollback_id} possui boot.tar sem boot.sha256"
        ));
    }

    reporter.required(
        "validação SHA-256 do backup de /boot",
        "/usr/bin/sha256sum",
        &[
            "--check".to_owned(),
            "--strict".to_owned(),
            boot_checksum.display().to_string(),
        ],
    )?;

    let efi_archive = directory.join("efi.tar");
    let efi_checksum = directory.join("efi.sha256");
    if efi_archive.is_file() {
        if !efi_checksum.is_file() {
            return Err(format!(
                "o rollback {rollback_id} possui efi.tar sem efi.sha256"
            ));
        }
        reporter.required(
            "validação SHA-256 do backup da EFI",
            "/usr/bin/sha256sum",
            &[
                "--check".to_owned(),
                "--strict".to_owned(),
                efi_checksum.display().to_string(),
            ],
        )?;
    }

    let pending = Path::new(ROOT_STATE).join("pending-boot-restore.conf");
    if pending.exists() {
        return Err(
            "já existe uma restauração de /boot pendente; reinicie antes de agendar outra"
                .to_owned(),
        );
    }

    let prepared = directory.join("boot-restore.prepared");
    let prepared_text = format!("ROLLBACK_ID={rollback_id}\n");
    let prepared_path = prepared
        .to_str()
        .ok_or_else(|| "caminho interno de restauração de /boot inválido".to_owned())?;
    write_root_file(prepared_path, &prepared_text, 0o600)?;

    reporter.record(&format!(
        "BOOT_RESTORE_ROLLBACK={} RESULT=PREPARADO",
        rollback_id
    ));
    Ok(Some(prepared))
}

fn commit_boot_restore(prepared: Option<&Path>) -> Result<(), String> {
    let Some(prepared) = prepared else {
        return Ok(());
    };

    let pending = Path::new(ROOT_STATE).join("pending-boot-restore.conf");
    if pending.exists() {
        return Err(
            "já existe uma restauração de /boot pendente; reinicie antes de agendar outra"
                .to_owned(),
        );
    }

    fs::rename(prepared, &pending).map_err(|error| {
        format!(
            "os snapshots foram agendados, mas não foi possível agendar a restauração de /boot: {error}"
        )
    })?;
    fs::set_permissions(&pending, fs::Permissions::from_mode(0o600))
        .map_err(|error| format!("não foi possível proteger {}: {error}", pending.display()))?;
    Ok(())
}

fn same_block_device(left: &str, right: &str) -> bool {
    let left_path = fs::canonicalize(left).unwrap_or_else(|_| PathBuf::from(left));
    let right_path = fs::canonicalize(right).unwrap_or_else(|_| PathBuf::from(right));
    left_path == right_path
}

fn mount_source(reporter: &mut Reporter, target: &str) -> Result<String, String> {
    let source = reporter.required(
        &format!("identificação do volume de {target}"),
        FINDMNT,
        &[
            "-n".to_owned(),
            "-o".to_owned(),
            "SOURCE".to_owned(),
            "-T".to_owned(),
            target.to_owned(),
        ],
    )?;
    if !source.starts_with("/dev/") {
        return Err(format!(
            "{target} não está em um volume de bloco LVM suportado: {source}"
        ));
    }
    Ok(source)
}

fn prepare_snapshot_volume(
    reporter: &mut Reporter,
    rollback_id: &str,
    target: &str,
    suffix: &str,
    origin_path: &str,
) -> Result<RollbackVolume, String> {
    let lvs = reporter.required(
        &format!("validação LVM do volume de {target}"),
        LVS,
        &[
            "--noheadings".to_owned(),
            "--separator".to_owned(),
            "|".to_owned(),
            "-o".to_owned(),
            "vg_name,lv_name,lv_attr,pool_lv".to_owned(),
            origin_path.to_owned(),
        ],
    )?;
    let fields = lvs.trim().split('|').map(str::trim).collect::<Vec<_>>();
    if fields.len() < 4 || fields[0].is_empty() || fields[1].is_empty() {
        return Err(format!(
            "não foi possível identificar VG/LV do volume montado em {target}"
        ));
    }
    if fields[3].is_empty() {
        return Err(format!(
            "o volume montado em {target} não é thin LVM; snapshot automático bloqueado"
        ));
    }

    let snapshot_name = format!("{rollback_id}-{suffix}");
    if !safe_snapshot_id(&snapshot_name) {
        return Err("nome interno de snapshot inválido".to_owned());
    }
    let snapshot_path = format!("/dev/{}/{}", fields[0], snapshot_name);
    Ok(RollbackVolume {
        target: target.to_owned(),
        origin_path: origin_path.to_owned(),
        snapshot_path,
        snapshot_name,
    })
}

fn persist_rollback(reporter: &mut Reporter, info: &RollbackInfo) -> Result<(), String> {
    let directory = Path::new(ROLLBACKS).join(&info.id);
    fs::create_dir_all(&directory)
        .map_err(|error| format!("não foi possível criar {}: {error}", directory.display()))?;

    let mut metadata = format!(
        "id={}\noperation={}\ncreated_at={}\nkernel={}\ndriver={}\nvolume_count={}\nboot_backup=boot.tar\nboot_checksum=boot.sha256\nefi_backup=efi.tar-se-presente\nefi_checksum=efi.sha256-se-presente\n",
        info.id,
        info.operation,
        info.created_at,
        info.kernel,
        info.driver,
        info.volumes.len()
    );
    for (index, volume) in info.volumes.iter().enumerate() {
        metadata.push_str(&format!(
            "volume_{index}_target={}\nvolume_{index}_origin_path={}\nvolume_{index}_snapshot_path={}\nvolume_{index}_snapshot_name={}\n",
            volume.target, volume.origin_path, volume.snapshot_path, volume.snapshot_name
        ));
    }

    let metadata_path = directory.join("metadata.conf");
    fs::write(&metadata_path, metadata)
        .map_err(|error| format!("não foi possível gravar metadados de rollback: {error}"))?;
    fs::set_permissions(&metadata_path, fs::Permissions::from_mode(0o644))
        .map_err(|error| format!("não foi possível ajustar permissões dos metadados: {error}"))?;

    let packages = reporter.required("inventário de pacotes", PACMAN, &["-Q".to_owned()])?;
    let packages_path = directory.join("packages.txt");
    fs::write(&packages_path, packages)
        .map_err(|error| format!("não foi possível gravar inventário de pacotes: {error}"))?;
    fs::set_permissions(&packages_path, fs::Permissions::from_mode(0o644))
        .map_err(|error| format!("não foi possível ajustar permissões do inventário: {error}"))?;

    Ok(())
}

fn remove_snapshots_best_effort(reporter: &mut Reporter, volumes: &[RollbackVolume]) {
    for volume in volumes.iter().rev() {
        let _ = reporter.command(
            &format!("remoção compensatória do snapshot de {}", volume.target),
            LVREMOVE,
            &["-f".to_owned(), volume.snapshot_path.clone()],
        );
    }
}

fn load_rollbacks() -> Result<Vec<RollbackInfo>, String> {
    let path = Path::new(ROLLBACKS);
    if !path.is_dir() {
        return Ok(Vec::new());
    }
    let mut values = Vec::new();
    for entry in
        fs::read_dir(path).map_err(|error| format!("não foi possível ler {ROLLBACKS}: {error}"))?
    {
        let Ok(entry) = entry else { continue };
        let Ok(name) = entry.file_name().into_string() else {
            continue;
        };
        if !safe_snapshot_id(&name) {
            continue;
        }
        if let Ok(info) = load_rollback(&name) {
            values.push(info);
        }
    }
    Ok(values)
}

fn load_rollback(id: &str) -> Result<RollbackInfo, String> {
    if !safe_snapshot_id(id) {
        return Err("identificador de rollback inválido".to_owned());
    }
    let path = Path::new(ROLLBACKS).join(id).join("metadata.conf");
    let text = fs::read_to_string(&path)
        .map_err(|error| format!("não foi possível ler {}: {error}", path.display()))?;
    let mut fields = BTreeMap::new();
    for line in text.lines() {
        if let Some((key, value)) = line.split_once('=') {
            fields.insert(key.to_owned(), value.to_owned());
        }
    }
    let get = |key: &str| {
        fields
            .get(key)
            .cloned()
            .ok_or_else(|| format!("metadado ausente: {key}"))
    };
    let stored_id = get("id")?;
    if stored_id != id {
        return Err("metadados de rollback não correspondem ao identificador".to_owned());
    }

    let volume_count = get("volume_count")?
        .parse::<usize>()
        .map_err(|_| "volume_count inválido".to_owned())?;
    if !(1..=3).contains(&volume_count) {
        return Err("quantidade de volumes do rollback inválida".to_owned());
    }

    let mut volumes = Vec::with_capacity(volume_count);
    for index in 0..volume_count {
        let target = get(&format!("volume_{index}_target"))?;
        if !matches!(target.as_str(), "/" | "/boot" | "/home") {
            return Err(format!("alvo de rollback não permitido: {target}"));
        }
        let origin_path = get(&format!("volume_{index}_origin_path"))?;
        let snapshot_path = get(&format!("volume_{index}_snapshot_path"))?;
        let snapshot_name = get(&format!("volume_{index}_snapshot_name"))?;
        if !origin_path.starts_with("/dev/") || !snapshot_path.starts_with("/dev/") {
            return Err("caminho de volume inválido nos metadados".to_owned());
        }
        if !safe_snapshot_id(&snapshot_name) || !snapshot_name.starts_with(&format!("{stored_id}-"))
        {
            return Err("nome de snapshot inválido nos metadados".to_owned());
        }
        volumes.push(RollbackVolume {
            target,
            origin_path,
            snapshot_path,
            snapshot_name,
        });
    }

    Ok(RollbackInfo {
        id: stored_id,
        operation: get("operation")?,
        created_at: get("created_at")?,
        kernel: get("kernel")?,
        driver: get("driver")?,
        volumes,
    })
}

fn validate_snapshot_exists(
    reporter: &mut Reporter,
    rollback: &RollbackInfo,
) -> Result<(), String> {
    for volume in &rollback.volumes {
        let current_source = reporter.required(
            &format!("validação do volume atual de {}", volume.target),
            FINDMNT,
            &[
                "-n".to_owned(),
                "-o".to_owned(),
                "SOURCE".to_owned(),
                "-T".to_owned(),
                volume.target.clone(),
            ],
        )?;
        if !same_block_device(&current_source, &volume.origin_path) {
            return Err(format!(
                "o volume atual de {} mudou de {} para {}; rollback bloqueado",
                volume.target, volume.origin_path, current_source
            ));
        }
        let output = reporter.required(
            &format!("validação do snapshot selecionado de {}", volume.target),
            LVS,
            &[
                "--noheadings".to_owned(),
                "-o".to_owned(),
                "lv_name".to_owned(),
                volume.snapshot_path.clone(),
            ],
        )?;
        if output.trim() != volume.snapshot_name {
            return Err(format!(
                "o snapshot LVM de {} não existe ou não corresponde aos metadados",
                volume.target
            ));
        }
    }
    Ok(())
}

struct InvokingUser {
    uid: u32,
    name: String,
    home: String,
}

fn invoking_user() -> Result<Option<InvokingUser>, String> {
    let uid_text = env::var("PKEXEC_UID")
        .or_else(|_| env::var("SUDO_UID"))
        .ok();
    let Some(uid_text) = uid_text else {
        return Ok(None);
    };
    let uid = uid_text
        .parse::<u32>()
        .map_err(|_| "UID do usuário invocador inválido".to_owned())?;
    user_by_uid(uid).map(Some)
}

fn user_by_uid(uid: u32) -> Result<InvokingUser, String> {
    let passwd = fs::read_to_string("/etc/passwd")
        .map_err(|error| format!("não foi possível ler /etc/passwd: {error}"))?;
    for line in passwd.lines() {
        let fields = line.split(':').collect::<Vec<_>>();
        if fields.len() >= 7 && fields[2].parse::<u32>().ok() == Some(uid) {
            return Ok(InvokingUser {
                uid,
                name: fields[0].to_owned(),
                home: fields[5].to_owned(),
            });
        }
    }
    Err(format!("usuário de UID {uid} não encontrado"))
}

fn require_tools(paths: &[&str]) -> Result<(), String> {
    for path in paths {
        if !Path::new(path).is_file() {
            return Err(format!("ferramenta obrigatória ausente: {path}"));
        }
    }
    Ok(())
}

fn ensure_pacman_unlocked() -> Result<(), String> {
    if Path::new("/var/lib/pacman/db.lck").exists() {
        return Err(
            "o Pacman está ocupado ou deixou /var/lib/pacman/db.lck; nenhuma alteração foi iniciada"
                .to_owned(),
        );
    }
    Ok(())
}

fn effective_uid() -> u32 {
    let text = fs::read_to_string("/proc/self/status").unwrap_or_default();
    text.lines()
        .find_map(|line| line.strip_prefix("Uid:"))
        .and_then(|line| line.split_whitespace().nth(1))
        .and_then(|value| value.parse().ok())
        .unwrap_or(u32::MAX)
}

fn user_state_dir() -> PathBuf {
    if let Ok(value) = env::var("XDG_STATE_HOME") {
        return PathBuf::from(value).join("mocha-update");
    }
    env::var("HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|_| PathBuf::from("/tmp"))
        .join(".local/state/mocha-update")
}

fn timestamp() -> Result<String, String> {
    command_text(DATE, &["+%Y%m%d-%H%M%S"])
}

fn command_text(program: &str, args: &[&str]) -> Result<String, String> {
    let output = Command::new(program)
        .args(args)
        .env("LC_ALL", "C")
        .output()
        .map_err(|error| format!("falha ao executar {program}: {error}"))?;
    if !output.status.success() {
        return Err(command_failure(program, &output));
    }
    Ok(String::from_utf8_lossy(&output.stdout).trim().to_owned())
}

fn command_failure(label: &str, output: &Output) -> String {
    let stderr = String::from_utf8_lossy(&output.stderr).trim().to_owned();
    let stdout = String::from_utf8_lossy(&output.stdout).trim().to_owned();
    let detail = if !stderr.is_empty() { stderr } else { stdout };
    if detail.is_empty() {
        format!("{label} falhou com {}", output.status)
    } else {
        format!("{label} falhou: {}", last_nonempty_line(&detail))
    }
}

fn last_nonempty_line(value: &str) -> &str {
    value
        .lines()
        .rev()
        .find(|line| !line.trim().is_empty())
        .unwrap_or(value)
        .trim()
}

fn shell_free_display(args: &[String]) -> String {
    args.iter()
        .map(|value| format!("{:?}", value))
        .collect::<Vec<_>>()
        .join(" ")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_checkupdates_output() {
        let values = parse_updates("firefox 1.0 -> 2.0\nlinux-mocha-lqx 7.1 -> 7.2\n");
        assert_eq!(values.len(), 2);
        assert_eq!(values[0].name, "firefox");
        assert_eq!(values[1].new, "7.2");
    }

    #[test]
    fn extracts_pacman_fields() {
        let value = "Repository      : mocha-kernel\nVersion         : 7.1.4.lqx1-2\n";
        assert_eq!(
            field_value(value, "Repository").as_deref(),
            Some("mocha-kernel")
        );
        assert_eq!(
            field_value(value, "Version").as_deref(),
            Some("7.1.4.lqx1-2")
        );
    }
}

// MOCHA_SNAPSHOT_BACKEND_RUST_V61_BEGIN
const SNAPSHOT_ADMIN_V61: &str = "/usr/lib/mocha-update/mocha-snapshot-admin";

fn snapshot_admin_v61(
    reporter: &mut Reporter,
    label: &str,
    args: &[String],
) -> Result<String, String> {
    if !Path::new(SNAPSHOT_ADMIN_V61).is_file() {
        return Err(format!(
            "backend Rust de snapshots não instalado: {SNAPSHOT_ADMIN_V61}"
        ));
    }
    reporter.required(label, SNAPSHOT_ADMIN_V61, args)
}

fn create_rollback_snapshot_v61(
    reporter: &mut Reporter,
    operation: &str,
) -> Result<RollbackInfo, String> {
    reporter.progress(8, "Criando ponto integral pelo backend Rust");
    let output = snapshot_admin_v61(
        reporter,
        "criação integral do ponto de restauração",
        &["create".to_owned(), operation.to_owned()],
    )?;
    let id = output
        .lines()
        .find_map(|line| line.strip_prefix("SNAPSHOT="))
        .map(str::trim)
        .filter(|value| safe_snapshot_id(value))
        .ok_or_else(|| "o backend Rust não retornou o identificador do ponto criado".to_owned())?;
    let rollback = load_rollback(id)?;
    validate_snapshot_exists(reporter, &rollback)?;
    reporter.data("created_rollback_id", id);
    Ok(rollback)
}

fn apply_rollback_v61(reporter: &mut Reporter, id: &str) -> Result<String, String> {
    if !safe_snapshot_id(id) {
        return Err("identificador de rollback inválido".to_owned());
    }
    reporter.progress(10, "Validando volumes, /boot, EFI e checksums");
    snapshot_admin_v61(
        reporter,
        "agendamento integral do rollback",
        &["restore".to_owned(), id.to_owned()],
    )?;
    reporter.data("reboot_required", "true");
    reporter.data("rollback_ready", "false");
    reporter.progress(100, "Rollback integral agendado");
    Ok(format!(
        "rollback {id} agendado; reinicie o sistema para concluir a restauração"
    ))
}

fn check_rollbacks_v61(reporter: &mut Reporter) -> Result<String, String> {
    reporter.progress(15, "Validando pontos pelo backend Rust");
    let output = snapshot_admin_v61(
        reporter,
        "leitura dos pontos integrais",
        &["ready-latest".to_owned()],
    )?;
    let mut count = "0";
    let mut selected_id = "";
    let mut summary = "Nenhum ponto de restauração válido";
    let mut ready = "false";
    for line in output.lines() {
        if let Some(value) = line.strip_prefix("ROLLBACK_COUNT=") {
            count = value.trim();
        } else if let Some(value) = line.strip_prefix("SELECTED_ID=") {
            selected_id = value.trim();
        } else if let Some(value) = line.strip_prefix("SELECTED_SUMMARY=") {
            summary = value.trim();
        } else if let Some(value) = line.strip_prefix("ROLLBACK_READY=") {
            ready = value.trim();
        }
    }
    reporter.data("rollback_count", count);
    reporter.data("selected_rollback_id", selected_id);
    reporter.data("selected_rollback_summary", summary);
    reporter.data("rollback_ready", ready);
    reporter.progress(100, "Pontos de restauração validados");
    if ready == "true" {
        Ok(format!(
            "{count} ponto(s) integral(is); selecionado: {summary}"
        ))
    } else {
        Ok("nenhum ponto integral restaurável foi encontrado".to_owned())
    }
}
// MOCHA_SNAPSHOT_BACKEND_RUST_V61_END
