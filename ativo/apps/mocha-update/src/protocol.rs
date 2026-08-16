use std::path::{Path, PathBuf};

pub const REPOSITORY_NAME: &str = "mocha-kernel";
pub const REPOSITORY_URL: &str = "https://repo.dieseloslab.org/stable/x86_64";

pub const R2_REPOSITORY_NAME: &str = "mocha-updates";
pub const R2_REPOSITORY_URL: &str = "https://updates.dieseloslab.org";
pub const R2_CHANNEL: &str = "stable";
pub const REPOSITORY_FINGERPRINT: &str = "CC16C3925C923E1826860641CB1EFF2340CBAB47";

pub const KERNEL_PACKAGES: &[&str] = &[
    "linux-mocha-lqx",
    "linux-mocha-lqx-headers",
    "linux-mocha-lqx-docs",
];

pub const NVIDIA_REQUIRED_PACKAGES: &[&str] =
    &["nvidia-open-dkms", "nvidia-utils", "lib32-nvidia-utils"];

pub const NVIDIA_OPTIONAL_PACKAGES: &[&str] =
    &["nvidia-settings", "opencl-nvidia", "lib32-opencl-nvidia"];

pub const PROTECTED_GENERAL_PACKAGES: &[&str] = &[
    "linux-mocha-lqx",
    "linux-mocha-lqx-headers",
    "linux-mocha-lqx-docs",
    "linux",
    "linux-headers",
    "linux-zen",
    "linux-zen-headers",
    "nvidia-open-dkms",
    "nvidia-dkms",
    "nvidia-open",
    "nvidia",
    "nvidia-utils",
    "lib32-nvidia-utils",
    "nvidia-settings",
    "opencl-nvidia",
    "lib32-opencl-nvidia",
    "mocha-update",
];

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum Operation {
    CheckGeneral,
    ApplyGeneral,
    CheckKernel,
    ApplyKernel,
    CheckArchKernel,
    ApplyArchKernel,
    Remarry,
    CheckRollbacks,
    ApplyRollback,
    CheckOc,
    EnableOcSession,
    EnableOcPersistent,
    DisableOc,
}

impl Operation {
    pub fn argument(self) -> &'static str {
        match self {
            Self::CheckGeneral => "check-general",
            Self::ApplyGeneral => "apply-general",
            Self::CheckKernel => "check-kernel",
            Self::ApplyKernel => "apply-kernel",
            Self::CheckArchKernel => "check-arch-kernel",
            Self::ApplyArchKernel => "apply-arch-kernel",
            Self::Remarry => "remarry",
            Self::CheckRollbacks => "check-rollbacks",
            Self::ApplyRollback => "apply-rollback",
            Self::CheckOc => "check-oc",
            Self::EnableOcSession => "enable-oc-session",
            Self::EnableOcPersistent => "enable-oc-persistent",
            Self::DisableOc => "disable-oc",
        }
    }

    pub fn requires_root(self) -> bool {
        matches!(
            self,
            Self::ApplyGeneral
                | Self::CheckRollbacks
                | Self::ApplyKernel
                | Self::ApplyArchKernel
                | Self::Remarry
                | Self::ApplyRollback
                | Self::EnableOcSession
                | Self::EnableOcPersistent
                | Self::DisableOc
        )
    }

    pub fn label(self) -> &'static str {
        match self {
            Self::CheckGeneral => "Verificação de atualizações",
            Self::ApplyGeneral => "Atualização geral",
            Self::CheckKernel => "Verificação de kernel e driver",
            Self::ApplyKernel => "Atualização de kernel e driver",
            Self::CheckArchKernel => "Verificação do kernel padrão Arch",
            Self::ApplyArchKernel => "Instalação do kernel padrão Arch",
            Self::Remarry => "Recasamento de kernel e driver",
            Self::CheckRollbacks => "Verificação de pontos de restauração",
            Self::ApplyRollback => "Rollback",
            Self::CheckOc => "Verificação do Mocha OC",
            Self::EnableOcSession => "Ativação temporária do Mocha OC",
            Self::EnableOcPersistent => "Ativação permanente do Mocha OC no GameMode",
            Self::DisableOc => "Desativação total do Mocha OC",
        }
    }
}

impl TryFrom<&str> for Operation {
    type Error = String;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            "check-general" => Ok(Self::CheckGeneral),
            "apply-general" => Ok(Self::ApplyGeneral),
            "check-kernel" => Ok(Self::CheckKernel),
            "apply-kernel" => Ok(Self::ApplyKernel),
            "check-arch-kernel" => Ok(Self::CheckArchKernel),
            "apply-arch-kernel" => Ok(Self::ApplyArchKernel),
            "remarry" => Ok(Self::Remarry),
            "check-rollbacks" => Ok(Self::CheckRollbacks),
            "apply-rollback" => Ok(Self::ApplyRollback),
            "check-oc" => Ok(Self::CheckOc),
            "enable-oc-session" => Ok(Self::EnableOcSession),
            "enable-oc-persistent" => Ok(Self::EnableOcPersistent),
            "disable-oc" => Ok(Self::DisableOc),
            _ => Err(format!("operação desconhecida: {value}")),
        }
    }
}

#[derive(Debug, Eq, PartialEq)]
pub enum HelperEvent {
    Progress(i32, String),
    Data(String, String),
    Result(bool, String),
}

pub fn encode_progress(progress: i32, message: &str) -> String {
    format!(
        "@@MOCHA_PROGRESS@@{}@@{}",
        progress.clamp(0, 100),
        clean_field(message)
    )
}

pub fn encode_data(key: &str, value: &str) -> String {
    format!("@@MOCHA_DATA@@{}@@{}", clean_field(key), clean_field(value))
}

pub fn encode_result(success: bool, message: &str) -> String {
    format!(
        "@@MOCHA_RESULT@@{}@@{}",
        if success { "SUCCESS" } else { "FAILURE" },
        clean_field(message)
    )
}

pub fn parse_helper_event(line: &str) -> Option<HelperEvent> {
    if let Some(rest) = line.strip_prefix("@@MOCHA_PROGRESS@@") {
        let (progress, message) = rest.split_once("@@")?;
        return progress
            .parse::<i32>()
            .ok()
            .map(|value| HelperEvent::Progress(value.clamp(0, 100), message.to_owned()));
    }

    if let Some(rest) = line.strip_prefix("@@MOCHA_DATA@@") {
        let (key, value) = rest.split_once("@@")?;
        return Some(HelperEvent::Data(key.to_owned(), value.to_owned()));
    }

    if let Some(rest) = line.strip_prefix("@@MOCHA_RESULT@@") {
        let (status, message) = rest.split_once("@@")?;
        return Some(HelperEvent::Result(status == "SUCCESS", message.to_owned()));
    }

    None
}

pub fn is_protected_general_package(package: &str) -> bool {
    let package = package.trim();
    PROTECTED_GENERAL_PACKAGES.contains(&package)
        // A atualização comum nunca administra kernels.  A lista explícita
        // acima documenta os pacotes suportados; estes prefixos fecham a
        // lacuna para variantes instaladas (por exemplo linux-lqx).
        || package == "linux"
        || package.starts_with("linux-")
        || package.starts_with("nvidia")
        || package.starts_with("lib32-nvidia")
        || package.starts_with("opencl-nvidia")
        || package == "mocha-update"
}

pub fn safe_snapshot_id(value: &str) -> bool {
    let valid_length = (20..=96).contains(&value.len());
    valid_length
        && value.starts_with("mocha-update-")
        && value
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || byte == b'-' || byte == b'_')
}

pub fn helper_path(require_installed: bool) -> Result<PathBuf, String> {
    let installed = PathBuf::from("/usr/lib/mocha-update/mocha-update-helper");
    if valid_installed_helper(&installed) {
        return Ok(installed);
    }

    if require_installed {
        return Err(
            "executor administrativo fixo não está instalado em /usr/lib/mocha-update".to_owned(),
        );
    }

    let current = std::env::current_exe()
        .map_err(|error| format!("não foi possível localizar o executável atual: {error}"))?;
    let sibling = current.with_file_name("mocha-update-helper");
    if valid_executable(&sibling) {
        return Ok(sibling);
    }

    Err("executor administrativo do Mocha Update não está instalado".to_owned())
}

fn valid_installed_helper(path: &Path) -> bool {
    use std::os::unix::fs::{MetadataExt, PermissionsExt};

    let Ok(metadata) = path.symlink_metadata() else {
        return false;
    };
    let mode = metadata.permissions().mode();
    metadata.file_type().is_file() && metadata.uid() == 0 && mode & 0o111 != 0 && mode & 0o022 == 0
}

fn valid_executable(path: &Path) -> bool {
    use std::os::unix::fs::PermissionsExt;

    let Ok(metadata) = path.symlink_metadata() else {
        return false;
    };

    metadata.file_type().is_file() && metadata.permissions().mode() & 0o111 != 0
}

fn clean_field(value: &str) -> String {
    value.replace(['\n', '\r'], " ").replace("@@", "@ @")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn protocol_round_trip() {
        assert_eq!(
            parse_helper_event(&encode_progress(42, "Executando")),
            Some(HelperEvent::Progress(42, "Executando".to_owned()))
        );
        assert_eq!(
            parse_helper_event(&encode_data("kernel", "7.1.4")),
            Some(HelperEvent::Data("kernel".to_owned(), "7.1.4".to_owned()))
        );
        assert_eq!(
            parse_helper_event(&encode_result(true, "Concluído")),
            Some(HelperEvent::Result(true, "Concluído".to_owned()))
        );
    }

    #[test]
    fn rejects_unsafe_snapshot_ids() {
        assert!(safe_snapshot_id("mocha-update-20260722-010203-kernel"));
        assert!(!safe_snapshot_id("../../etc/shadow"));
        assert!(!safe_snapshot_id("mocha-update-x;reboot"));
    }

    #[test]
    fn protects_mocha_kernel_and_nvidia() {
        assert!(is_protected_general_package("linux-mocha-lqx"));
        assert!(is_protected_general_package("nvidia-open-dkms"));
        assert!(is_protected_general_package("mocha-update"));
        assert!(is_protected_general_package("linux-lqx"));
        assert!(is_protected_general_package("linux-cachyos"));
        assert!(is_protected_general_package("linux-headers"));
        assert!(is_protected_general_package("nvidia-open-beta-dkms"));
        assert!(!is_protected_general_package("firefox"));
    }

    #[test]
    fn maps_oc_operations_and_root_policy() {
        assert_eq!(Operation::try_from("check-oc"), Ok(Operation::CheckOc));
        assert_eq!(
            Operation::try_from("enable-oc-session"),
            Ok(Operation::EnableOcSession)
        );
        assert_eq!(
            Operation::try_from("enable-oc-persistent"),
            Ok(Operation::EnableOcPersistent)
        );
        assert_eq!(Operation::try_from("disable-oc"), Ok(Operation::DisableOc));
        assert!(!Operation::CheckOc.requires_root());
        assert!(Operation::EnableOcSession.requires_root());
        assert!(Operation::EnableOcPersistent.requires_root());
        assert!(Operation::DisableOc.requires_root());
    }
}
