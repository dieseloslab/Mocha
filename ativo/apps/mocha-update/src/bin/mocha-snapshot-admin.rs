use std::collections::{BTreeMap, BTreeSet};
use std::env;
use std::fs::{self, DirBuilder, File, OpenOptions};
use std::io::Write;
use std::os::fd::AsRawFd;
use std::os::unix::fs::{DirBuilderExt, OpenOptionsExt, PermissionsExt};
use std::path::{Component, Path, PathBuf};
use std::process::{Command, Output};

const VERSION: &str = "62";
const STATE: &str = "/var/lib/mocha-update";
const ROLLBACKS: &str = "/var/lib/mocha-update/rollbacks";
const INDEX_DIR: &str = "/var/lib/mocha-update/snapshot-index";
const INDEX_FILE: &str = "/var/lib/mocha-update/snapshot-index/index.json";
const LOCK_FILE: &str = "/run/lock/mocha-update-snapshot.lock";
const PENDING_FILE: &str = "/boot/.mocha-update/rollback-pending.conf";
const PRE_RESTORE_ROOT: &str = "/var/backups/mocha";

const LVS: &str = "/usr/bin/lvs";
const LVCREATE: &str = "/usr/bin/lvcreate";
const LVREMOVE: &str = "/usr/bin/lvremove";
const LVCONVERT: &str = "/usr/bin/lvconvert";
const FINDMNT: &str = "/usr/bin/findmnt";
const TAR: &str = "/usr/bin/tar";
const SHA256SUM: &str = "/usr/bin/sha256sum";
const PACMAN: &str = "/usr/bin/pacman";
const UNAME: &str = "/usr/bin/uname";
const SYNC: &str = "/usr/bin/sync";
const RSYNC: &str = "/usr/bin/rsync";
const GRUB_MKCONFIG: &str = "/usr/bin/grub-mkconfig";
const DATE: &str = "/usr/bin/date";

const LOCK_EX: i32 = 2;
const THIN_POOL_SAFE_LIMIT: f64 = 85.0;
const LVCREATE_LOCAL_CONFIG: &str = "activation { thin_pool_autoextend_threshold = 100 }";

extern "C" {
    fn flock(fd: i32, operation: i32) -> i32;
    fn geteuid() -> u32;
}

#[derive(Debug)]
struct AdminLock {
    _file: File,
}

impl AdminLock {
    fn acquire() -> Result<Self, String> {
        if let Some(parent) = Path::new(LOCK_FILE).parent() {
            fs::create_dir_all(parent)
                .map_err(|error| format!("não foi possível criar {}: {error}", parent.display()))?;
        }
        let file = OpenOptions::new()
            .create(true)
            .read(true)
            .write(true)
            .open(LOCK_FILE)
            .map_err(|error| format!("não foi possível abrir {LOCK_FILE}: {error}"))?;
        let result = unsafe { flock(file.as_raw_fd(), LOCK_EX) };
        if result != 0 {
            return Err("não foi possível bloquear operações simultâneas de snapshot".to_owned());
        }
        Ok(Self { _file: file })
    }
}

#[derive(Clone, Debug)]
struct Volume {
    target: String,
    origin_path: String,
    snapshot_path: String,
    snapshot_name: String,
}

#[derive(Clone, Debug)]
struct Catalog {
    id: String,
    directory: PathBuf,
    operation: String,
    created_at: String,
    kernel: String,
    driver: String,
    volumes: Vec<Volume>,
    fields: BTreeMap<String, String>,
    errors: Vec<String>,
}

impl Catalog {
    fn summary(&self) -> String {
        format!(
            "{} · {} · kernel {} · NVIDIA {} · {} volume(s)",
            self.created_at,
            operation_label(&self.operation),
            self.kernel,
            self.driver,
            self.volumes.len()
        )
    }
}

#[derive(Clone, Debug)]
struct LvRow {
    vg: String,
    lv: String,
    size_bytes: f64,
    origin: String,
    data_percent: Option<f64>,
    lv_time: String,
}

impl LvRow {
    fn key(&self) -> (String, String) {
        (self.vg.clone(), self.lv.clone())
    }

    fn is_snapshot(&self) -> bool {
        !self.origin.is_empty()
    }
}

#[derive(Clone, Debug)]
struct IndexItem {
    key: String,
    kind: String,
    date: String,
    sort_date: String,
    title: String,
    detail: String,
    size: String,
    restore: bool,
    can_delete: bool,
    state: String,
}

fn main() {
    let code = match run_main() {
        Ok(()) => 0,
        Err(error) => {
            eprintln!("ERRO={error}");
            1
        }
    };
    std::process::exit(code);
}

fn run_main() -> Result<(), String> {
    let mut args = env::args().skip(1);
    let command = args.next().unwrap_or_default();

    if command == "--version" {
        println!("mocha-snapshot-admin-rust-v{VERSION}");
        return Ok(());
    }
    if command == "self-test" {
        if args.next().is_some() {
            return Err("argumentos excedentes".to_owned());
        }
        self_test()?;
        return Ok(());
    }

    require_root()?;
    let _lock = AdminLock::acquire()?;

    match command.as_str() {
        "capacity" => {
            no_more(args)?;
            capacity_report()?;
        }
        "index" => {
            no_more(args)?;
            let items = rebuild_index()?;
            println!("ITENS={}", items.len());
        }
        "create" => {
            let operation = args
                .next()
                .ok_or_else(|| "informe a operação do ponto".to_owned())?;
            no_more(args)?;
            let id = create_snapshot(&operation, false)?;
            println!("SNAPSHOT={id}");
        }
        "create-pacman" => {
            no_more(args)?;
            let id = create_snapshot("pacman", true)?;
            println!("SNAPSHOT={id}");
        }
        "preflight" => {
            let value = args
                .next()
                .ok_or_else(|| "informe o ponto a validar".to_owned())?;
            no_more(args)?;
            let id = catalog_id(&value)?;
            validate_catalog_full(&id, true)?;
            println!("RESULTADO=VALIDO");
            println!("SNAPSHOT={id}");
        }
        "preflight-all" => {
            no_more(args)?;
            preflight_all()?;
        }
        "restore" => {
            let value = args
                .next()
                .ok_or_else(|| "informe o ponto a restaurar".to_owned())?;
            no_more(args)?;
            let id = catalog_id(&value)?;
            restore_catalog(&id)?;
            println!("RESULTADO=RESTAURACAO_AGENDADA");
            println!("SNAPSHOT={id}");
        }
        "restore-test" => {
            let value = args
                .next()
                .ok_or_else(|| "informe o ponto a testar".to_owned())?;
            no_more(args)?;
            let id = catalog_id(&value)?;
            test_restore(&id)?;
            println!("RESULTADO=MERGE_LVM_TESTADO");
            println!("SNAPSHOT={id}");
        }
        "delete" => {
            let value = args
                .next()
                .ok_or_else(|| "informe o ponto a apagar".to_owned())?;
            no_more(args)?;
            delete_action(&value)?;
            println!("RESULTADO=APAGADO");
        }
        "ready-latest" => {
            no_more(args)?;
            ready_latest()?;
        }
        "finalize-rollback" => {
            no_more(args)?;
            finalize_rollback()?;
        }
        _ => {
            return Err("uso: mocha-snapshot-admin \
                 capacity|index|create OPERAÇÃO|create-pacman|preflight ID|preflight-all|\
                 restore ID|restore-test ID|delete ID|ready-latest|finalize-rollback|self-test"
                .to_owned());
        }
    }
    Ok(())
}

fn no_more(mut args: impl Iterator<Item = String>) -> Result<(), String> {
    if args.next().is_some() {
        Err("argumentos excedentes".to_owned())
    } else {
        Ok(())
    }
}

fn require_root() -> Result<(), String> {
    if unsafe { geteuid() } == 0 {
        Ok(())
    } else {
        Err("este backend exige autorização administrativa".to_owned())
    }
}

fn run(program: &str, args: &[String]) -> Result<String, String> {
    run_in(program, args, None)
}

fn run_in(program: &str, args: &[String], cwd: Option<&Path>) -> Result<String, String> {
    let mut command = Command::new(program);
    command
        .args(args)
        .env("LC_ALL", "C")
        .env("LANG", "C")
        .env("PAGER", "cat")
        .env("SYSTEMD_PAGER", "cat");
    if let Some(directory) = cwd {
        command.current_dir(directory);
    }
    let output = command.output().map_err(|error| {
        format!(
            "falha ao executar {}: {error}",
            display_command(program, args)
        )
    })?;
    require_success(program, args, output)
}

fn run_status(program: &str, args: &[String]) -> Result<Output, String> {
    Command::new(program)
        .args(args)
        .env("LC_ALL", "C")
        .env("LANG", "C")
        .env("PAGER", "cat")
        .env("SYSTEMD_PAGER", "cat")
        .output()
        .map_err(|error| {
            format!(
                "falha ao executar {}: {error}",
                display_command(program, args)
            )
        })
}

fn require_success(program: &str, args: &[String], output: Output) -> Result<String, String> {
    if output.status.success() {
        Ok(String::from_utf8_lossy(&output.stdout).trim().to_owned())
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr);
        let stdout = String::from_utf8_lossy(&output.stdout);
        let detail = if !stderr.trim().is_empty() {
            stderr.trim()
        } else {
            stdout.trim()
        };
        Err(format!(
            "{} falhou{}",
            display_command(program, args),
            if detail.is_empty() {
                String::new()
            } else {
                format!(": {detail}")
            }
        ))
    }
}

fn display_command(program: &str, args: &[String]) -> String {
    let name = Path::new(program)
        .file_name()
        .and_then(|value| value.to_str())
        .unwrap_or(program);
    format!("{name} {}", args.join(" "))
}

fn required_tools() -> Result<(), String> {
    for tool in [
        LVS, LVCREATE, LVREMOVE, LVCONVERT, FINDMNT, TAR, SHA256SUM, PACMAN, UNAME, SYNC, RSYNC,
        DATE,
    ] {
        let metadata = fs::metadata(tool)
            .map_err(|error| format!("ferramenta obrigatória ausente: {tool}: {error}"))?;
        if !metadata.is_file() || metadata.permissions().mode() & 0o111 == 0 {
            return Err(format!("ferramenta obrigatória não executável: {tool}"));
        }
    }
    Ok(())
}

fn safe_id(value: &str) -> bool {
    (20..=96).contains(&value.len())
        && value.starts_with("mocha-update-")
        && value
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'-' | b'_'))
}

fn safe_lvm(value: &str) -> bool {
    (1..=127).contains(&value.len())
        && value
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'+' | b'_' | b'.' | b'-'))
}

fn safe_operation(value: &str) -> bool {
    matches!(
        value,
        "system" | "kernel-driver" | "remarry" | "pacman" | "manual"
    )
}

fn catalog_id(value: &str) -> Result<String, String> {
    let id = value.strip_prefix("catalog:").unwrap_or(value);
    if safe_id(id) {
        Ok(id.to_owned())
    } else {
        Err("identificador de ponto inválido".to_owned())
    }
}

fn action_key(value: &str) -> Result<(&str, &str), String> {
    let (kind, key) = value
        .split_once(':')
        .ok_or_else(|| "identificador sem tipo".to_owned())?;
    if kind == "catalog" && safe_id(key) {
        return Ok((kind, key));
    }
    if kind == "orphan" {
        if let Some((vg, lv)) = key.split_once('/') {
            if safe_lvm(vg) && safe_lvm(lv) && !lv.contains('/') {
                return Ok((kind, key));
            }
        }
    }
    Err("identificador de snapshot inválido".to_owned())
}

fn timestamp() -> Result<String, String> {
    let value = run(DATE, &["+%Y%m%d-%H%M%S".to_owned()])?;
    if value.len() == 15
        && value.as_bytes()[8] == b'-'
        && value
            .bytes()
            .enumerate()
            .all(|(index, byte)| index == 8 || byte.is_ascii_digit())
    {
        Ok(value)
    } else {
        Err(format!("data inválida retornada pelo sistema: {value}"))
    }
}

fn exact_mount(target: &str) -> Result<bool, String> {
    let output = run_status(
        FINDMNT,
        &["-rn".to_owned(), "-M".to_owned(), target.to_owned()],
    )?;
    Ok(output.status.success())
}

fn mounted_source(target: &str, exact: bool) -> Result<String, String> {
    let mode = if exact { "-M" } else { "-T" };
    let source = run(
        FINDMNT,
        &[
            "-rn".to_owned(),
            mode.to_owned(),
            target.to_owned(),
            "-o".to_owned(),
            "SOURCE".to_owned(),
        ],
    )?;
    if source.starts_with("/dev/") {
        Ok(source)
    } else {
        Err(format!(
            "{target} não está em um dispositivo de bloco suportado: {source}"
        ))
    }
}

fn device_identity(device: &str) -> Result<(String, String), String> {
    let output = run(
        LVS,
        &[
            "--noheadings".to_owned(),
            "--separator".to_owned(),
            "|".to_owned(),
            "-o".to_owned(),
            "vg_name,lv_name".to_owned(),
            device.to_owned(),
        ],
    )?;
    let line = output
        .lines()
        .map(str::trim)
        .find(|line| !line.is_empty())
        .ok_or_else(|| format!("não foi possível identificar o volume {device}"))?;
    let parts = line.split('|').map(str::trim).collect::<Vec<_>>();
    if parts.len() == 2 && safe_lvm(parts[0]) && safe_lvm(parts[1]) {
        Ok((parts[0].to_owned(), parts[1].to_owned()))
    } else {
        Err(format!("identidade LVM inválida para {device}: {line}"))
    }
}

fn lvs_rows() -> Result<Vec<LvRow>, String> {
    let output = run(
        LVS,
        &[
            "--noheadings".to_owned(),
            "--separator".to_owned(),
            "|".to_owned(),
            "--units".to_owned(),
            "b".to_owned(),
            "--nosuffix".to_owned(),
            "-o".to_owned(),
            "vg_name,lv_name,lv_path,lv_size,origin,data_percent,lv_time".to_owned(),
        ],
    )?;
    let mut rows = Vec::new();
    for raw in output.lines().filter(|line| !line.trim().is_empty()) {
        let parts = raw.split('|').map(str::trim).collect::<Vec<_>>();
        if parts.len() != 7 || !safe_lvm(parts[0]) || !safe_lvm(parts[1]) {
            continue;
        }
        rows.push(LvRow {
            vg: parts[0].to_owned(),
            lv: parts[1].to_owned(),
            size_bytes: parts[3].parse::<f64>().unwrap_or(0.0),
            origin: parts[4].to_owned(),
            data_percent: parts[5].parse::<f64>().ok(),
            lv_time: parts[6].to_owned(),
        });
    }
    Ok(rows)
}

#[derive(Clone, Debug)]
struct ThinPoolStatus {
    vg: String,
    pool: String,
    data_percent: f64,
    metadata_percent: f64,
}

fn thin_pool_status(origin: &str) -> Result<ThinPoolStatus, String> {
    let output = run(
        LVS,
        &[
            "--noheadings".to_owned(),
            "--separator".to_owned(),
            "|".to_owned(),
            "-o".to_owned(),
            "segtype,pool_lv".to_owned(),
            origin.to_owned(),
        ],
    )?;
    let parts = output.trim().split('|').map(str::trim).collect::<Vec<_>>();
    if parts.len() != 2 || parts[0] != "thin" || !safe_lvm(parts[1]) {
        return Err(format!(
            "{origin} não é um volume thin com pool identificado"
        ));
    }
    let (vg, _) = device_identity(origin)?;
    let usage = run(
        LVS,
        &[
            "--noheadings".to_owned(),
            "--separator".to_owned(),
            "|".to_owned(),
            "-o".to_owned(),
            "data_percent,metadata_percent".to_owned(),
            format!("{vg}/{}", parts[1]),
        ],
    )?;
    let values = usage
        .trim()
        .split('|')
        .map(|value| value.trim().parse::<f64>())
        .collect::<Result<Vec<_>, _>>()
        .map_err(|_| "uso do thin pool não pôde ser validado".to_owned())?;
    if values.len() != 2 {
        return Err("uso do thin pool não pôde ser validado".to_owned());
    }
    Ok(ThinPoolStatus {
        vg,
        pool: parts[1].to_owned(),
        data_percent: values[0],
        metadata_percent: values[1],
    })
}

fn thin_guard(origin: &str) -> Result<ThinPoolStatus, String> {
    let status = thin_pool_status(origin)?;
    if status.data_percent >= THIN_POOL_SAFE_LIMIT
        || status.metadata_percent >= THIN_POOL_SAFE_LIMIT
    {
        return Err(format!(
            "thin pool {}/{} fora do limite seguro: dados {:.2}%, \
             metadados {:.2}%, limite {:.2}%",
            status.vg,
            status.pool,
            status.data_percent,
            status.metadata_percent,
            THIN_POOL_SAFE_LIMIT
        ));
    }
    Ok(status)
}

fn snapshot_origins() -> Result<Vec<(String, String)>, String> {
    if !exact_mount("/boot")? {
        return Err("/boot não é uma montagem separada; ponto integral bloqueado".to_owned());
    }

    let root_source = mounted_source("/", false)?;
    let root_identity = device_identity(&root_source)?;
    let mut origins = vec![("/".to_owned(), root_source)];
    if exact_mount("/home")? {
        let home_source = mounted_source("/home", true)?;
        if device_identity(&home_source)? != root_identity {
            origins.push(("/home".to_owned(), home_source));
        }
    }
    Ok(origins)
}

fn capacity_report() -> Result<(), String> {
    required_tools()?;
    let origins = snapshot_origins()?;
    let mut pools = BTreeSet::new();
    for (_, origin) in &origins {
        let status = thin_guard(origin)?;
        if pools.insert((status.vg.clone(), status.pool.clone())) {
            println!("THIN_POOL={}/{}", status.vg, status.pool);
            println!("DATA_PERCENT={:.2}", status.data_percent);
            println!("METADATA_PERCENT={:.2}", status.metadata_percent);
        }
    }
    println!("SAFETY_LIMIT_PERCENT={THIN_POOL_SAFE_LIMIT:.2}");
    println!("LVM_CONF_ALTERADO=NAO");
    println!("LVCREATE_OVERRIDE=APENAS_NA_CHAMADA");
    println!("CAPACIDADE_SNAPSHOT=SEGURA");
    Ok(())
}

fn lvcreate_snapshot_args(snapshot_name: &str, origin: &str) -> Vec<String> {
    vec![
        "--config".to_owned(),
        LVCREATE_LOCAL_CONFIG.to_owned(),
        "--snapshot".to_owned(),
        "--name".to_owned(),
        snapshot_name.to_owned(),
        origin.to_owned(),
    ]
}

fn read_metadata(path: &Path) -> Result<BTreeMap<String, String>, String> {
    let metadata = path
        .symlink_metadata()
        .map_err(|error| format!("metadata.conf ausente: {error}"))?;
    if !metadata.file_type().is_file() || metadata.file_type().is_symlink() {
        return Err("metadata.conf inseguro".to_owned());
    }
    let text = fs::read_to_string(path)
        .map_err(|error| format!("não foi possível ler {}: {error}", path.display()))?;
    let mut values = BTreeMap::new();
    for (number, raw) in text.lines().enumerate() {
        let line = raw.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let (key, value) = line
            .split_once('=')
            .ok_or_else(|| format!("metadata.conf inválido na linha {}", number + 1))?;
        let valid_key = !key.is_empty()
            && key
                .bytes()
                .all(|byte| byte.is_ascii_lowercase() || byte.is_ascii_digit() || byte == b'_');
        if !valid_key
            || value
                .chars()
                .any(|character| matches!(character, '\0' | '\r' | '\n'))
            || value.len() > 4096
        {
            return Err(format!("campo inseguro em metadata.conf: {key}"));
        }
        if values.insert(key.to_owned(), value.to_owned()).is_some() {
            return Err(format!("campo duplicado em metadata.conf: {key}"));
        }
    }
    Ok(values)
}

fn load_catalog(id: &str) -> Result<Catalog, String> {
    if !safe_id(id) {
        return Err("identificador de catálogo inválido".to_owned());
    }
    let directory = Path::new(ROLLBACKS).join(id);
    let directory_metadata = directory
        .symlink_metadata()
        .map_err(|error| format!("catálogo ausente: {id}: {error}"))?;
    if !directory_metadata.file_type().is_dir() || directory_metadata.file_type().is_symlink() {
        return Err(format!("catálogo inseguro: {id}"));
    }

    let mut errors = Vec::new();
    let fields = match read_metadata(&directory.join("metadata.conf")) {
        Ok(value) => value,
        Err(error) => {
            errors.push(error);
            BTreeMap::new()
        }
    };
    if fields.get("id").map(String::as_str) != Some(id) {
        errors.push("o ID do catálogo não corresponde ao diretório".to_owned());
    }
    let operation = fields
        .get("operation")
        .cloned()
        .unwrap_or_else(|| "desconhecida".to_owned());
    let created_at = fields.get("created_at").cloned().unwrap_or_default();
    let kernel = fields
        .get("kernel")
        .cloned()
        .unwrap_or_else(|| "desconhecido".to_owned());
    let driver = fields
        .get("driver")
        .cloned()
        .unwrap_or_else(|| "desconhecido".to_owned());
    let count = fields
        .get("volume_count")
        .and_then(|value| value.parse::<usize>().ok())
        .unwrap_or(0);
    if !(1..=3).contains(&count) {
        errors.push("quantidade de volumes inválida".to_owned());
    }

    let mut volumes = Vec::new();
    let mut targets = BTreeSet::new();
    let mut snapshots = BTreeSet::new();
    for index in 0..count.min(3) {
        let target = fields
            .get(&format!("volume_{index}_target"))
            .cloned()
            .unwrap_or_default();
        let origin_path = fields
            .get(&format!("volume_{index}_origin_path"))
            .cloned()
            .unwrap_or_default();
        let snapshot_path = fields
            .get(&format!("volume_{index}_snapshot_path"))
            .cloned()
            .unwrap_or_default();
        let snapshot_name = fields
            .get(&format!("volume_{index}_snapshot_name"))
            .cloned()
            .unwrap_or_default();
        let valid = matches!(target.as_str(), "/" | "/home")
            && targets.insert(target.clone())
            && origin_path.starts_with("/dev/")
            && snapshot_path.starts_with("/dev/")
            && safe_lvm(&snapshot_name)
            && snapshots.insert(snapshot_path.clone());
        if valid {
            volumes.push(Volume {
                target,
                origin_path,
                snapshot_path,
                snapshot_name,
            });
        } else {
            errors.push(format!("volume {index} inválido ou incompatível"));
        }
    }
    if !targets.contains("/") {
        errors.push("o catálogo não contém o volume raiz".to_owned());
    }

    Ok(Catalog {
        id: id.to_owned(),
        directory,
        operation,
        created_at,
        kernel,
        driver,
        volumes,
        fields,
        errors,
    })
}

fn all_catalogs() -> Result<Vec<Catalog>, String> {
    let path = Path::new(ROLLBACKS);
    if !path.exists() {
        return Ok(Vec::new());
    }
    let mut catalogs = Vec::new();
    for entry in
        fs::read_dir(path).map_err(|error| format!("não foi possível ler {ROLLBACKS}: {error}"))?
    {
        let Ok(entry) = entry else { continue };
        let Ok(name) = entry.file_name().into_string() else {
            continue;
        };
        if name.starts_with('.') || !safe_id(&name) {
            continue;
        }
        if let Ok(catalog) = load_catalog(&name) {
            catalogs.push(catalog);
        }
    }
    Ok(catalogs)
}

fn is_regular_file(path: &Path) -> bool {
    path.symlink_metadata()
        .map(|metadata| metadata.file_type().is_file() && !metadata.file_type().is_symlink())
        .unwrap_or(false)
}

fn current_pending_id() -> String {
    let path = Path::new(PENDING_FILE);
    if !is_regular_file(path) {
        return String::new();
    }
    let Ok(text) = fs::read_to_string(path) else {
        return String::new();
    };
    text.lines()
        .find_map(|line| line.strip_prefix("ROLLBACK_ID="))
        .map(str::trim)
        .filter(|id| safe_id(id))
        .unwrap_or_default()
        .to_owned()
}

fn snapshot_map(rows: &[LvRow]) -> BTreeMap<(String, String), LvRow> {
    rows.iter()
        .filter(|row| row.is_snapshot())
        .map(|row| (row.key(), row.clone()))
        .collect()
}

fn runtime_catalog(catalog: &Catalog, rows: &[LvRow]) -> (Vec<LvRow>, Vec<String>) {
    let snapshots = snapshot_map(rows);
    let mut members = Vec::new();
    let mut errors = catalog.errors.clone();
    for volume in &catalog.volumes {
        let snapshot_identity = match device_identity(&volume.snapshot_path) {
            Ok(value) => value,
            Err(_) => {
                errors.push(format!("snapshot ausente: {}", volume.snapshot_name));
                continue;
            }
        };
        if snapshot_identity.1 != volume.snapshot_name {
            errors.push(format!(
                "o nome do snapshot diverge do catálogo: {}",
                volume.snapshot_name
            ));
            continue;
        }
        let Some(row) = snapshots.get(&snapshot_identity) else {
            errors.push(format!(
                "snapshot não corresponde ao catálogo: {}",
                volume.snapshot_name
            ));
            continue;
        };
        let origin_identity = match device_identity(&volume.origin_path) {
            Ok(value) => value,
            Err(error) => {
                errors.push(error);
                continue;
            }
        };
        if snapshot_identity.0 != origin_identity.0 || row.origin != origin_identity.1 {
            errors.push(format!("origem divergente no volume {}", volume.target));
            continue;
        }
        match mounted_source(&volume.target, volume.target == "/home") {
            Ok(current) => match device_identity(&current) {
                Ok(identity) if identity == origin_identity => {}
                Ok(_) => errors.push(format!("a montagem atual de {} mudou", volume.target)),
                Err(error) => errors.push(error),
            },
            Err(error) => errors.push(error),
        }
        members.push(row.clone());
    }

    if !is_regular_file(&catalog.directory.join("boot.tar")) {
        errors.push("backup de /boot ausente".to_owned());
    }
    if !is_regular_file(&catalog.directory.join("boot.sha256")) {
        errors.push("checksum de /boot ausente".to_owned());
    }
    let efi_present = catalog.fields.get("efi_present").map(String::as_str) == Some("1");
    if efi_present
        && (!is_regular_file(&catalog.directory.join("efi.tar"))
            || !is_regular_file(&catalog.directory.join("efi.sha256")))
    {
        errors.push("backup EFI incompleto".to_owned());
    }
    errors.sort();
    errors.dedup();
    (members, errors)
}

fn verify_archive(directory: &Path, archive: &str, checksum: &str) -> Result<(), String> {
    let archive_path = directory.join(archive);
    let checksum_path = directory.join(checksum);
    if !is_regular_file(&archive_path) || !is_regular_file(&checksum_path) {
        return Err(format!("backup incompleto: {archive}"));
    }
    run_in(
        SHA256SUM,
        &[
            "--check".to_owned(),
            "--strict".to_owned(),
            checksum.to_owned(),
        ],
        Some(directory),
    )?;
    let listing = run(
        TAR,
        &[
            "-tf".to_owned(),
            archive_path.to_string_lossy().into_owned(),
        ],
    )?;
    for entry in listing.lines() {
        if !safe_archive_entry(entry) {
            return Err(format!("entrada insegura no arquivo {archive}: {entry:?}"));
        }
    }
    Ok(())
}

fn safe_archive_entry(entry: &str) -> bool {
    !entry.is_empty()
        && Path::new(entry)
            .components()
            .all(|component| matches!(component, Component::CurDir | Component::Normal(_)))
}

fn validate_catalog_full(id: &str, require_no_pending: bool) -> Result<Catalog, String> {
    let catalog = load_catalog(id)?;
    let rows = lvs_rows()?;
    let (_, errors) = runtime_catalog(&catalog, &rows);
    if !errors.is_empty() {
        return Err(errors.join("; "));
    }
    if require_no_pending && !current_pending_id().is_empty() {
        return Err("já existe uma restauração pendente; reinicie primeiro".to_owned());
    }
    verify_archive(&catalog.directory, "boot.tar", "boot.sha256")?;
    if catalog.fields.get("efi_present").map(String::as_str) == Some("1") {
        verify_archive(&catalog.directory, "efi.tar", "efi.sha256")?;
        if !exact_mount("/boot/efi")? {
            return Err("o ponto contém EFI, mas /boot/efi não está montado".to_owned());
        }
    }
    if !is_regular_file(&catalog.directory.join("packages.txt")) {
        return Err("inventário de pacotes ausente".to_owned());
    }
    let current_boot = mounted_source("/boot", true)?;
    if catalog.fields.get("boot_source").map(String::as_str) != Some(current_boot.as_str()) {
        return Err("a origem montada em /boot mudou desde a criação do ponto".to_owned());
    }
    if catalog.fields.get("efi_present").map(String::as_str) == Some("1") {
        let current_efi = mounted_source("/boot/efi", true)?;
        if catalog.fields.get("efi_source").map(String::as_str) != Some(current_efi.as_str()) {
            return Err("a origem montada em /boot/efi mudou desde a criação do ponto".to_owned());
        }
    }
    Ok(catalog)
}

fn tar_tree(source: &str, destination: &Path, exclude_efi: bool) -> Result<(), String> {
    let mut args = vec![
        "--acls".to_owned(),
        "--xattrs".to_owned(),
        "--numeric-owner".to_owned(),
        "--one-file-system".to_owned(),
        "-C".to_owned(),
        source.to_owned(),
    ];
    if exclude_efi {
        args.extend([
            "--exclude".to_owned(),
            "./efi".to_owned(),
            "--exclude".to_owned(),
            "./efi/*".to_owned(),
        ]);
    }
    args.extend([
        "-cpf".to_owned(),
        destination.to_string_lossy().into_owned(),
        ".".to_owned(),
    ]);
    run(TAR, &args)?;
    Ok(())
}

fn write_checksum(directory: &Path, filename: &str) -> Result<(), String> {
    let output = run_in(SHA256SUM, &[filename.to_owned()], Some(directory))?;
    let digest = output
        .split_whitespace()
        .next()
        .ok_or_else(|| format!("sha256sum não retornou hash para {filename}"))?;
    if digest.len() != 64 || !digest.bytes().all(|byte| byte.is_ascii_hexdigit()) {
        return Err(format!("SHA-256 inválido para {filename}"));
    }
    let stem = filename
        .strip_suffix(".tar")
        .ok_or_else(|| format!("nome de arquivo inesperado: {filename}"))?;
    let checksum = directory.join(format!("{stem}.sha256"));
    write_file_atomic(
        &checksum,
        format!("{digest}  {filename}\n").as_bytes(),
        0o600,
    )
}

fn write_file_atomic(path: &Path, contents: &[u8], mode: u32) -> Result<(), String> {
    let parent = path
        .parent()
        .ok_or_else(|| format!("caminho sem diretório: {}", path.display()))?;
    fs::create_dir_all(parent)
        .map_err(|error| format!("não foi possível criar {}: {error}", parent.display()))?;
    let temporary = parent.join(format!(
        ".{}.{}.tmp",
        path.file_name()
            .and_then(|value| value.to_str())
            .unwrap_or("file"),
        std::process::id()
    ));
    let mut file = OpenOptions::new()
        .create_new(true)
        .write(true)
        .mode(mode)
        .open(&temporary)
        .map_err(|error| format!("não foi possível criar {}: {error}", temporary.display()))?;
    let result = (|| {
        file.write_all(contents)
            .map_err(|error| format!("não foi possível gravar {}: {error}", temporary.display()))?;
        file.sync_all().map_err(|error| {
            format!(
                "não foi possível sincronizar {}: {error}",
                temporary.display()
            )
        })
    })();
    if let Err(error) = result {
        let _ = fs::remove_file(&temporary);
        return Err(error);
    }
    fs::rename(&temporary, path)
        .map_err(|error| format!("não foi possível publicar {}: {error}", path.display()))
}

fn recent_valid_catalog() -> Option<String> {
    let mut catalogs = all_catalogs().ok()?;
    catalogs.sort_by(|left, right| right.id.cmp(&left.id));
    for catalog in catalogs {
        let modified = catalog.directory.metadata().ok()?.modified().ok()?;
        if modified.elapsed().ok()?.as_secs() > 180 {
            continue;
        }
        if validate_catalog_full(&catalog.id, false).is_ok() {
            return Some(catalog.id);
        }
    }
    None
}

fn create_snapshot(operation: &str, allow_recent: bool) -> Result<String, String> {
    required_tools()?;
    if !safe_operation(operation) {
        return Err(format!("operação de snapshot inválida: {operation}"));
    }
    if !current_pending_id().is_empty() {
        return Err("restauração pendente; criação de ponto bloqueada".to_owned());
    }
    if allow_recent {
        if let Some(id) = recent_valid_catalog() {
            rebuild_index()?;
            return Ok(id);
        }
    }
    let origins = snapshot_origins()?;
    for (_, origin) in &origins {
        thin_guard(origin)?;
    }

    run(SYNC, &[])?;
    let stamp = timestamp()?;
    let id = format!("mocha-update-{stamp}-{operation}");
    if !safe_id(&id) {
        return Err("identificador interno do ponto inválido".to_owned());
    }
    fs::create_dir_all(STATE)
        .map_err(|error| format!("não foi possível criar {STATE}: {error}"))?;
    fs::create_dir_all(ROLLBACKS)
        .map_err(|error| format!("não foi possível criar {ROLLBACKS}: {error}"))?;
    fs::set_permissions(ROLLBACKS, fs::Permissions::from_mode(0o700))
        .map_err(|error| format!("não foi possível proteger {ROLLBACKS}: {error}"))?;

    let temporary = Path::new(ROLLBACKS).join(format!(".creating-{id}-{}", std::process::id()));
    let final_directory = Path::new(ROLLBACKS).join(&id);
    if final_directory.exists() || temporary.exists() {
        return Err("já existe um ponto com o mesmo identificador".to_owned());
    }
    DirBuilder::new()
        .mode(0o700)
        .create(&temporary)
        .map_err(|error| format!("não foi possível criar {}: {error}", temporary.display()))?;

    let mut created = Vec::<String>::new();
    let mut published = false;
    let result = (|| {
        let mut volumes = Vec::<Volume>::new();
        for (target, origin) in &origins {
            let (vg, _) = device_identity(origin)?;
            let suffix = if target == "/" { "root" } else { "home" };
            let snapshot_name = format!("{id}-{suffix}");
            run(LVCREATE, &lvcreate_snapshot_args(&snapshot_name, origin))?;
            let snapshot_path = format!("/dev/{vg}/{snapshot_name}");
            created.push(snapshot_path.clone());
            if device_identity(&snapshot_path)? != (vg.clone(), snapshot_name.clone()) {
                return Err(format!(
                    "snapshot recém-criado não validou: {snapshot_name}"
                ));
            }
            volumes.push(Volume {
                target: target.clone(),
                origin_path: origin.clone(),
                snapshot_path,
                snapshot_name,
            });
        }

        tar_tree("/boot", &temporary.join("boot.tar"), true)?;
        write_checksum(&temporary, "boot.tar")?;
        let boot_source = mounted_source("/boot", true)?;
        let efi_present = exact_mount("/boot/efi")?;
        let efi_source = if efi_present {
            tar_tree("/boot/efi", &temporary.join("efi.tar"), false)?;
            write_checksum(&temporary, "efi.tar")?;
            mounted_source("/boot/efi", true)?
        } else {
            String::new()
        };

        let packages = run(PACMAN, &["-Q".to_owned()])?;
        write_file_atomic(
            &temporary.join("packages.txt"),
            format!("{packages}\n").as_bytes(),
            0o600,
        )?;
        let kernel = run(UNAME, &["-r".to_owned()]).unwrap_or_else(|_| "desconhecido".to_owned());
        let driver_output = run_status(PACMAN, &["-Q".to_owned(), "nvidia-open-dkms".to_owned()])?;
        let driver = if driver_output.status.success() {
            String::from_utf8_lossy(&driver_output.stdout)
                .split_whitespace()
                .nth(1)
                .unwrap_or("desconhecido")
                .to_owned()
        } else {
            "não instalado".to_owned()
        };

        let mut metadata = format!(
            "id={id}\noperation={operation}\ncreated_at={stamp}\n\
             kernel={kernel}\ndriver={driver}\nvolume_count={}\n\
             boot_backup=boot.tar\nboot_checksum=boot.sha256\n\
             boot_source={boot_source}\nefi_present={}\n",
            volumes.len(),
            if efi_present { "1" } else { "0" }
        );
        if efi_present {
            metadata.push_str(&format!(
                "efi_backup=efi.tar\nefi_checksum=efi.sha256\nefi_source={efi_source}\n"
            ));
        }
        for (index, volume) in volumes.iter().enumerate() {
            metadata.push_str(&format!(
                "volume_{index}_target={}\n\
                 volume_{index}_origin_path={}\n\
                 volume_{index}_snapshot_path={}\n\
                 volume_{index}_snapshot_name={}\n",
                volume.target, volume.origin_path, volume.snapshot_path, volume.snapshot_name
            ));
        }
        write_file_atomic(&temporary.join("metadata.conf"), metadata.as_bytes(), 0o600)?;
        run(SYNC, &[])?;
        fs::rename(&temporary, &final_directory).map_err(|error| {
            format!(
                "não foi possível publicar {}: {error}",
                final_directory.display()
            )
        })?;
        published = true;
        validate_catalog_full(&id, false)?;
        rebuild_index()?;
        Ok(id.clone())
    })();

    if result.is_err() {
        for snapshot in created.iter().rev() {
            let _ = run_status(LVREMOVE, &["-f".to_owned(), snapshot.clone()]);
        }
        let _ = fs::remove_dir_all(if published {
            &final_directory
        } else {
            &temporary
        });
        let _ = rebuild_index();
    }
    result
}

fn format_date(value: &str, fallback: &str) -> (String, String) {
    let stamp = exact_stamp(value)
        .or_else(|| extract_stamp(fallback))
        .unwrap_or_default();
    if stamp.len() == 15 {
        let display = format!(
            "{}/{}/{} às {}:{}:{}",
            &stamp[6..8],
            &stamp[4..6],
            &stamp[0..4],
            &stamp[9..11],
            &stamp[11..13],
            &stamp[13..15]
        );
        (display, stamp)
    } else {
        ("Data não identificada".to_owned(), value.to_owned())
    }
}

fn exact_stamp(value: &str) -> Option<String> {
    let bytes = value.as_bytes();
    if bytes.len() >= 15
        && bytes[8] == b'-'
        && bytes[..8].iter().all(u8::is_ascii_digit)
        && bytes[9..15].iter().all(u8::is_ascii_digit)
    {
        String::from_utf8(bytes[..15].to_vec()).ok()
    } else {
        None
    }
}

fn extract_stamp(value: &str) -> Option<String> {
    let bytes = value.as_bytes();
    for candidate in bytes.windows(15) {
        if candidate[8] == b'-'
            && candidate[..8].iter().all(u8::is_ascii_digit)
            && candidate[9..].iter().all(u8::is_ascii_digit)
            && candidate.starts_with(b"20")
        {
            return String::from_utf8(candidate.to_vec()).ok();
        }
    }
    None
}

fn operation_label(value: &str) -> &str {
    match value {
        "system" => "Atualização do sistema",
        "kernel-driver" => "Kernel e driver",
        "remarry" => "Recasamento de kernel e driver",
        "pacman" => "Transação do Pacman",
        "manual" => "Ponto manual",
        "" => "Operação desconhecida",
        other => other,
    }
}

fn human_bytes(mut value: f64) -> String {
    let units = ["B", "KiB", "MiB", "GiB", "TiB"];
    let mut index = 0usize;
    while value >= 1024.0 && index + 1 < units.len() {
        value /= 1024.0;
        index += 1;
    }
    format!("{value:.1} {}", units[index])
}

fn used_size(rows: &[LvRow]) -> String {
    let mut total = 0.0;
    let mut known = false;
    for row in rows {
        if let Some(percent) = row.data_percent {
            total += row.size_bytes * percent / 100.0;
            known = true;
        }
    }
    if known {
        format!("{} alterados", human_bytes(total))
    } else {
        "uso não informado pelo LVM".to_owned()
    }
}

fn build_index() -> Result<Vec<IndexItem>, String> {
    let catalogs = all_catalogs()?;
    let rows = lvs_rows()?;
    let snapshots = snapshot_map(&rows);
    let pending = current_pending_id();
    let mut consumed = BTreeSet::new();
    let mut items = Vec::new();

    for catalog in catalogs {
        let (members, errors) = runtime_catalog(&catalog, &rows);
        for volume in &catalog.volumes {
            if let Ok(key) = device_identity(&volume.snapshot_path) {
                if snapshots.contains_key(&key) {
                    consumed.insert(key);
                }
            }
        }
        let (date, sort_date) = format_date(&catalog.created_at, &catalog.id);
        let blocked = !pending.is_empty();
        let ready = errors.is_empty() && !blocked;
        let state = if pending == catalog.id {
            "Restauração agendada; reinicie para concluir".to_owned()
        } else if blocked {
            "Bloqueado até concluir a restauração pendente".to_owned()
        } else if errors.is_empty() {
            "Completo e pronto para restaurar".to_owned()
        } else {
            format!(
                "Não restaurável: {}",
                errors
                    .iter()
                    .take(2)
                    .cloned()
                    .collect::<Vec<_>>()
                    .join("; ")
            )
        };
        let scope = catalog
            .volumes
            .iter()
            .map(|volume| volume.target.clone())
            .collect::<Vec<_>>()
            .join(" + ");
        items.push(IndexItem {
            key: format!("catalog:{}", catalog.id),
            kind: "catalog".to_owned(),
            date,
            sort_date,
            title: operation_label(&catalog.operation).to_owned(),
            detail: format!(
                "{scope} + /boot{} · kernel {} · NVIDIA {} · {}",
                if catalog.fields.get("efi_present").map(String::as_str) == Some("1") {
                    " + EFI"
                } else {
                    ""
                },
                catalog.kernel,
                catalog.driver,
                catalog.id
            ),
            size: used_size(&members),
            restore: ready,
            can_delete: !blocked,
            state,
        });
    }

    for (key, row) in snapshots {
        if consumed.contains(&key) {
            continue;
        }
        let (date, sort_date) = format_date(&row.lv_time, &row.lv);
        items.push(IndexItem {
            key: format!("orphan:{}/{}", row.vg, row.lv),
            kind: "orphan".to_owned(),
            date,
            sort_date,
            title: format!("Snapshot órfão · {}/{}", row.vg, row.lv),
            detail: format!(
                "Origem {}/{} · sem catálogo integral verificado",
                row.vg, row.origin
            ),
            size: used_size(&[row]),
            restore: false,
            can_delete: pending.is_empty(),
            state: if pending.is_empty() {
                "Somente exclusão; restauração integral bloqueada".to_owned()
            } else {
                "Bloqueado até concluir a restauração pendente".to_owned()
            },
        });
    }
    items.sort_by(|left, right| right.sort_date.cmp(&left.sort_date));
    Ok(items)
}

fn json_escape(value: &str) -> String {
    let mut result = String::new();
    for character in value.chars() {
        match character {
            '"' => result.push_str("\\\""),
            '\\' => result.push_str("\\\\"),
            '\n' => result.push_str("\\n"),
            '\r' => result.push_str("\\r"),
            '\t' => result.push_str("\\t"),
            value if value.is_control() => {
                result.push_str(&format!("\\u{:04x}", value as u32));
            }
            value => result.push(value),
        }
    }
    result
}

fn index_json(items: &[IndexItem]) -> String {
    let mut output = String::from("[\n");
    for (index, item) in items.iter().enumerate() {
        if index > 0 {
            output.push_str(",\n");
        }
        output.push_str(&format!(
            "  {{\"key\":\"{}\",\"kind\":\"{}\",\"date\":\"{}\",\
             \"title\":\"{}\",\"detail\":\"{}\",\"size\":\"{}\",\
             \"restore\":{},\"canDelete\":{},\"state\":\"{}\"}}",
            json_escape(&item.key),
            json_escape(&item.kind),
            json_escape(&item.date),
            json_escape(&item.title),
            json_escape(&item.detail),
            json_escape(&item.size),
            item.restore,
            item.can_delete,
            json_escape(&item.state)
        ));
    }
    output.push_str("\n]\n");
    output
}

fn rebuild_index() -> Result<Vec<IndexItem>, String> {
    fs::create_dir_all(INDEX_DIR)
        .map_err(|error| format!("não foi possível criar {INDEX_DIR}: {error}"))?;
    let items = build_index()?;
    write_file_atomic(Path::new(INDEX_FILE), index_json(&items).as_bytes(), 0o644)?;
    fs::set_permissions(INDEX_DIR, fs::Permissions::from_mode(0o755))
        .map_err(|error| format!("não foi possível ajustar {INDEX_DIR}: {error}"))?;
    Ok(items)
}

fn preflight_all() -> Result<(), String> {
    lvs_rows()?;
    let mut valid = 0usize;
    let mut invalid = 0usize;
    let mut catalogs = all_catalogs()?;
    catalogs.sort_by(|left, right| right.id.cmp(&left.id));
    for catalog in catalogs {
        match validate_catalog_full(&catalog.id, false) {
            Ok(_) => {
                println!("VALIDO={}", catalog.id);
                valid += 1;
            }
            Err(error) => {
                println!("INVALIDO={}|{error}", catalog.id);
                invalid += 1;
            }
        }
    }
    println!("CATALOGOS_VALIDOS={valid}");
    println!("CATALOGOS_INVALIDOS={invalid}");
    Ok(())
}

fn ready_latest() -> Result<(), String> {
    let mut valid = Vec::new();
    let mut catalogs = all_catalogs()?;
    catalogs.sort_by(|left, right| right.id.cmp(&left.id));
    for catalog in catalogs {
        if validate_catalog_full(&catalog.id, false).is_ok() {
            valid.push(catalog);
        }
    }
    println!("ROLLBACK_COUNT={}", valid.len());
    if let Some(selected) = valid.first() {
        println!("SELECTED_ID={}", selected.id);
        println!("SELECTED_SUMMARY={}", selected.summary());
        println!("ROLLBACK_READY=true");
    } else {
        println!("SELECTED_ID=");
        println!("SELECTED_SUMMARY=Nenhum ponto de restauração válido");
        println!("ROLLBACK_READY=false");
    }
    Ok(())
}

fn extract_archive(archive: &Path, destination: &Path) -> Result<(), String> {
    fs::create_dir_all(destination)
        .map_err(|error| format!("não foi possível criar {}: {error}", destination.display()))?;
    run(
        TAR,
        &[
            "--acls".to_owned(),
            "--xattrs".to_owned(),
            "--numeric-owner".to_owned(),
            "-xpf".to_owned(),
            archive.to_string_lossy().into_owned(),
            "-C".to_owned(),
            destination.to_string_lossy().into_owned(),
        ],
    )?;
    Ok(())
}

fn restore_tree(source: &Path, target: &str, exclude_efi: bool) -> Result<(), String> {
    let mut args = vec![
        "-aHAX".to_owned(),
        "--delete".to_owned(),
        "--numeric-ids".to_owned(),
    ];
    if exclude_efi {
        args.extend([
            "--exclude".to_owned(),
            "/efi/".to_owned(),
            "--exclude".to_owned(),
            "/efi/***".to_owned(),
        ]);
    }
    args.push(format!("{}/", source.display()));
    args.push(format!("{target}/"));
    run(RSYNC, &args)?;
    Ok(())
}

fn restore_archives(
    boot_archive: &Path,
    efi_archive: Option<&Path>,
    prefix: &str,
) -> Result<(), String> {
    let temporary = Path::new("/run").join(format!("{prefix}-{}", std::process::id()));
    if temporary.exists() {
        fs::remove_dir_all(&temporary)
            .map_err(|error| format!("não foi possível limpar {}: {error}", temporary.display()))?;
    }
    DirBuilder::new()
        .mode(0o700)
        .create(&temporary)
        .map_err(|error| format!("não foi possível criar {}: {error}", temporary.display()))?;
    let result = (|| {
        let boot_tree = temporary.join("boot");
        extract_archive(boot_archive, &boot_tree)?;
        restore_tree(&boot_tree, "/boot", true)?;
        if let Some(archive) = efi_archive {
            if !exact_mount("/boot/efi")? {
                return Err("/boot/efi não está montado".to_owned());
            }
            let efi_tree = temporary.join("efi");
            extract_archive(archive, &efi_tree)?;
            restore_tree(&efi_tree, "/boot/efi", false)?;
        }
        Ok(())
    })();
    let _ = fs::remove_dir_all(&temporary);
    result
}

fn backup_current_boot(directory: &Path, efi_present: bool) -> Result<(), String> {
    DirBuilder::new()
        .recursive(true)
        .mode(0o700)
        .create(directory)
        .map_err(|error| format!("não foi possível criar {}: {error}", directory.display()))?;
    tar_tree("/boot", &directory.join("current-boot.tar"), true)?;
    write_checksum(directory, "current-boot.tar")?;
    if efi_present {
        tar_tree("/boot/efi", &directory.join("current-efi.tar"), false)?;
        write_checksum(directory, "current-efi.tar")?;
    }
    Ok(())
}

fn write_pending(id: &str, backup: &Path) -> Result<(), String> {
    let contents = format!(
        "ROLLBACK_ID={id}\nPRE_RESTORE_BACKUP={}\nCREATED_AT={}\n",
        backup.display(),
        timestamp()?
    );
    write_file_atomic(Path::new(PENDING_FILE), contents.as_bytes(), 0o600)
}

fn restore_catalog(id: &str) -> Result<(), String> {
    required_tools()?;
    let catalog = validate_catalog_full(id, true)?;
    let snapshots = catalog
        .volumes
        .iter()
        .map(|volume| volume.snapshot_path.clone())
        .collect::<Vec<_>>();
    if snapshots.is_empty() {
        return Err("o catálogo não contém snapshots restauráveis".to_owned());
    }
    let mut test_args = vec!["--test".to_owned(), "--merge".to_owned(), "-y".to_owned()];
    test_args.extend(snapshots.clone());
    run(LVCONVERT, &test_args)?;

    let efi_present = catalog.fields.get("efi_present").map(String::as_str) == Some("1");
    let backup_directory =
        Path::new(PRE_RESTORE_ROOT).join(format!("mocha-update-pre-restore-{id}-{}", timestamp()?));
    backup_current_boot(&backup_directory, efi_present)?;

    let boot_archive = catalog.directory.join("boot.tar");
    let efi_archive = efi_present.then(|| catalog.directory.join("efi.tar"));
    restore_archives(
        &boot_archive,
        efi_archive.as_deref(),
        "mocha-restore-selected",
    )?;
    write_pending(id, &backup_directory)?;
    run(SYNC, &[])?;

    let mut merge_args = vec!["--merge".to_owned(), "-y".to_owned()];
    merge_args.extend(snapshots);
    if let Err(error) = run(LVCONVERT, &merge_args) {
        let rollback_boot = backup_directory.join("current-boot.tar");
        let rollback_efi = efi_present.then(|| backup_directory.join("current-efi.tar"));
        let rollback_result = restore_archives(
            &rollback_boot,
            rollback_efi.as_deref(),
            "mocha-restore-compensation",
        );
        let _ = fs::remove_file(PENDING_FILE);
        return match rollback_result {
            Ok(()) => Err(format!(
                "o merge LVM falhou; /boot e EFI atuais foram restaurados: {error}"
            )),
            Err(compensation) => Err(format!(
                "o merge LVM falhou e a compensação de /boot também falhou: \
                 merge={error}; compensação={compensation}; backup={}",
                backup_directory.display()
            )),
        };
    }
    rebuild_index()?;
    println!("REINICIALIZACAO_NECESSARIA=SIM");
    println!("REINICIALIZACAO_AUTOMATICA=NAO");
    Ok(())
}

fn test_restore(id: &str) -> Result<(), String> {
    required_tools()?;
    let catalog = validate_catalog_full(id, true)?;
    let mut args = vec!["--test".to_owned(), "--merge".to_owned(), "-y".to_owned()];
    args.extend(
        catalog
            .volumes
            .iter()
            .map(|volume| volume.snapshot_path.clone()),
    );
    if args.len() <= 3 {
        return Err("o catálogo não contém snapshots restauráveis".to_owned());
    }
    run(LVCONVERT, &args)?;
    Ok(())
}

fn lv_exists(device: &str) -> bool {
    run_status(
        LVS,
        &[
            "--noheadings".to_owned(),
            "-o".to_owned(),
            "lv_name".to_owned(),
            device.to_owned(),
        ],
    )
    .map(|output| output.status.success() && !output.stdout.is_empty())
    .unwrap_or(false)
}

fn delete_action(value: &str) -> Result<(), String> {
    if !current_pending_id().is_empty() {
        return Err("há uma restauração pendente; reinicie antes de excluir".to_owned());
    }
    let (kind, key) = action_key(value)?;
    if kind == "orphan" {
        let (vg, lv) = key
            .split_once('/')
            .ok_or_else(|| "snapshot órfão inválido".to_owned())?;
        let rows = lvs_rows()?;
        let row = rows
            .iter()
            .find(|row| row.vg == vg && row.lv == lv && row.is_snapshot())
            .ok_or_else(|| "snapshot órfão não existe mais".to_owned())?;
        for catalog in all_catalogs()? {
            for volume in catalog.volumes {
                if device_identity(&volume.snapshot_path).ok() == Some(row.key()) {
                    return Err("o snapshot pertence a um catálogo; exclusão bloqueada".to_owned());
                }
            }
        }
        let target = format!("{vg}/{lv}");
        run(LVREMOVE, &["-f".to_owned(), target.clone()])?;
        if lv_exists(&format!("/dev/{target}")) {
            return Err("o LVM ainda apresenta o snapshot após a exclusão".to_owned());
        }
    } else {
        let catalog = load_catalog(key)?;
        let rows = snapshot_map(&lvs_rows()?);
        let mut members = Vec::new();
        for volume in &catalog.volumes {
            let Ok(identity) = device_identity(&volume.snapshot_path) else {
                continue;
            };
            let Some(row) = rows.get(&identity) else {
                continue;
            };
            let origin = device_identity(&volume.origin_path)?;
            if identity.0 != origin.0 || row.origin != origin.1 {
                return Err("catálogo diverge do LVM; exclusão bloqueada".to_owned());
            }
            members.push(volume.snapshot_path.clone());
        }
        if !members.is_empty() {
            let mut args = vec!["-f".to_owned()];
            args.extend(members.clone());
            run(LVREMOVE, &args)?;
            for member in members {
                if lv_exists(&member) {
                    return Err(format!(
                        "o LVM ainda apresenta o snapshot após a exclusão: {member}"
                    ));
                }
            }
        }
        fs::remove_dir_all(&catalog.directory).map_err(|error| {
            format!(
                "não foi possível apagar o catálogo {}: {error}",
                catalog.directory.display()
            )
        })?;
    }
    rebuild_index()?;
    Ok(())
}

fn finalize_rollback() -> Result<(), String> {
    let id = current_pending_id();
    if id.is_empty() {
        println!("RESTAURACAO_PENDENTE=NAO");
        return Ok(());
    }
    let expected_names = [format!("{id}-root"), format!("{id}-home")];
    let remaining = lvs_rows()?
        .into_iter()
        .filter(|row| expected_names.contains(&row.lv))
        .map(|row| format!("{}/{}", row.vg, row.lv))
        .collect::<Vec<_>>();
    if !remaining.is_empty() {
        return Err(format!(
            "o merge LVM ainda não foi concluído; volumes pendentes: {}",
            remaining.join(", ")
        ));
    }
    if Path::new(GRUB_MKCONFIG).is_file() && Path::new("/boot/grub").is_dir() {
        run(
            GRUB_MKCONFIG,
            &["-o".to_owned(), "/boot/grub/grub.cfg".to_owned()],
        )?;
    }
    fs::remove_file(PENDING_FILE)
        .map_err(|error| format!("não foi possível concluir o marcador pendente: {error}"))?;
    let _ = rebuild_index();
    println!("MERGE_LVM_CONFIRMADO=SIM");
    println!("RESTAURACAO_FINALIZADA={id}");
    Ok(())
}

fn self_test() -> Result<(), String> {
    if !safe_id("mocha-update-20260726-120000-manual")
        || safe_id("../../etc/shadow")
        || !safe_lvm("mocha_vg")
        || safe_lvm("../root")
    {
        return Err("teste de identificadores falhou".to_owned());
    }
    if catalog_id("catalog:mocha-update-20260726-120000-manual")?
        != "mocha-update-20260726-120000-manual"
    {
        return Err("teste de catálogo falhou".to_owned());
    }
    if action_key("orphan:mocha_vg/snapshot-root")? != ("orphan", "mocha_vg/snapshot-root") {
        return Err("teste de órfão falhou".to_owned());
    }
    if json_escape("Mocha \"Rust\"\\\n") != "Mocha \\\"Rust\\\"\\\\\\n" {
        return Err("teste de JSON falhou".to_owned());
    }
    if exact_stamp("20260726-120000Z").as_deref() != Some("20260726-120000")
        || exact_stamp("éééééééé").is_some()
        || extract_stamp("prefixo-20260726-120000-sufixo").as_deref() != Some("20260726-120000")
    {
        return Err("teste de data segura falhou".to_owned());
    }
    if !safe_archive_entry("./efi/EFI/Mocha/grubx64.efi")
        || safe_archive_entry("../etc/shadow")
        || safe_archive_entry("/etc/shadow")
        || safe_archive_entry("")
    {
        return Err("teste de caminhos do arquivo de boot falhou".to_owned());
    }
    let lvcreate_args = lvcreate_snapshot_args(
        "mocha-update-20260726-120000-manual-root",
        "/dev/mocha_vg/mocha_root",
    );
    if lvcreate_args
        != [
            "--config",
            LVCREATE_LOCAL_CONFIG,
            "--snapshot",
            "--name",
            "mocha-update-20260726-120000-manual-root",
            "/dev/mocha_vg/mocha_root",
        ]
    {
        return Err("teste do limite local do lvcreate falhou".to_owned());
    }

    let fixture = Path::new("/tmp").join(format!(
        "mocha-snapshot-rust-self-test-{}",
        std::process::id()
    ));
    if fixture.exists() {
        fs::remove_dir_all(&fixture)
            .map_err(|error| format!("não foi possível limpar fixture: {error}"))?;
    }
    DirBuilder::new()
        .mode(0o700)
        .create(&fixture)
        .map_err(|error| format!("não foi possível criar fixture: {error}"))?;
    let result = (|| {
        let metadata = b"id=mocha-update-20260726-120000-manual\n\
operation=manual\ncreated_at=20260726-120000\nkernel=7.1.4-mocha-lqx\n\
driver=610.43.03\nvolume_count=1\nvolume_0_target=/\n\
volume_0_origin_path=/dev/mocha_vg/mocha_root\n\
volume_0_snapshot_path=/dev/mocha_vg/mocha-update-20260726-120000-manual-root\n\
volume_0_snapshot_name=mocha-update-20260726-120000-manual-root\n";
        write_file_atomic(&fixture.join("metadata.conf"), metadata, 0o600)?;
        let values = read_metadata(&fixture.join("metadata.conf"))?;
        if values.get("operation").map(String::as_str) != Some("manual")
            || values.get("volume_count").map(String::as_str) != Some("1")
        {
            return Err("teste de metadados falhou".to_owned());
        }
        let item = IndexItem {
            key: "catalog:test".to_owned(),
            kind: "catalog".to_owned(),
            date: "26/07/2026 às 12:00:00".to_owned(),
            sort_date: "20260726-120000".to_owned(),
            title: "Ponto manual".to_owned(),
            detail: "Rust".to_owned(),
            size: "1.0 MiB".to_owned(),
            restore: true,
            can_delete: true,
            state: "Completo".to_owned(),
        };
        let json = index_json(&[item]);
        if !json.contains("\"restore\":true") || !json.contains("\"canDelete\":true") {
            return Err("teste de índice JSON falhou".to_owned());
        }
        Ok(())
    })();
    let _ = fs::remove_dir_all(&fixture);
    result?;
    println!("SELF_TEST_RUST=OK");
    println!("BACKEND_SNAPSHOTS=RUST_UNICO");
    Ok(())
}
