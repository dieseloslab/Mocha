//! Identificação do kernel instalado pelo proprietário registrado no Pacman.
use std::fs;
use std::path::Path;
use std::process::Command;

#[derive(Debug)]
pub struct KernelIdentity {
    pub release: String,
    pub package: String,
    pub version: String,
}

pub fn safe_package_name(value: &str) -> bool {
    !value.is_empty()
        && !value.starts_with('-')
        && value
            .bytes()
            .all(|c| c.is_ascii_alphanumeric() || b"@._+-".contains(&c))
}

fn pacman_text(args: &[&str]) -> Result<String, String> {
    let output = Command::new("/usr/bin/pacman")
        .args(args)
        .env("LC_ALL", "C")
        .output()
        .map_err(|e| format!("falha ao consultar o Pacman: {e}"))?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).trim().to_owned());
    }
    Ok(String::from_utf8_lossy(&output.stdout).trim().to_owned())
}

pub fn package_owner(path: &Path) -> Result<String, String> {
    let text = path.to_str().ok_or("caminho de kernel inválido")?;
    let owner = pacman_text(&["-Qoq", "--", text])?;
    if !safe_package_name(&owner) {
        return Err(format!("proprietário de pacote inválido para {text}"));
    }
    Ok(owner)
}

pub fn package_version(package: &str) -> Result<String, String> {
    if !safe_package_name(package) {
        return Err("nome de pacote inválido".to_owned());
    }
    let value = pacman_text(&["-Q", "--", package])?;
    let fields: Vec<_> = value.split_whitespace().collect();
    if fields.len() != 2 || fields[0] != package {
        return Err(format!("resposta inválida do Pacman para {package}"));
    }
    Ok(fields[1].to_owned())
}

pub fn identify_kernel(release: &str) -> Result<KernelIdentity, String> {
    if release.is_empty() || release.contains('/') || release.contains('\n') {
        return Err("identificador de kernel inválido".to_owned());
    }
    let path = Path::new("/usr/lib/modules").join(release).join("pkgbase");
    let package = package_owner(&path)?;
    let pkgbase = fs::read_to_string(&path)
        .map_err(|e| format!("não foi possível ler {}: {e}", path.display()))?;
    if pkgbase.trim() != package {
        return Err(format!(
            "pkgbase diverge do pacote proprietário em {}",
            path.display()
        ));
    }
    let version = package_version(&package)?;
    Ok(KernelIdentity {
        release: release.to_owned(),
        package,
        version,
    })
}

pub fn installed_mocha_summary() -> Result<String, String> {
    let output = Command::new("/usr/bin/pacman")
        .arg("-Q")
        .env("LC_ALL", "C")
        .output()
        .map_err(|e| e.to_string())?;
    if !output.status.success() {
        return Err("não foi possível consultar os kernels Mocha instalados".to_owned());
    }
    let mut values = Vec::new();
    for line in String::from_utf8_lossy(&output.stdout).lines() {
        let fields: Vec<_> = line.split_whitespace().collect();
        if fields.len() == 2
            && fields[0].starts_with("linux-mocha-")
            && !fields[0].ends_with("-headers")
            && !fields[0].ends_with("-docs")
        {
            values.push(line.to_owned());
        }
    }
    Ok(if values.is_empty() {
        "nenhum pacote de kernel Mocha instalado".to_owned()
    } else {
        values.join("; ")
    })
}

pub fn dkms_module_installed(status: &str, version: &str, release: &str) -> bool {
    status.lines().any(|line| {
        let Some((identity, state)) = line.split_once(':') else {
            return false;
        };
        if state.trim() != "installed" {
            return false;
        }
        let fields: Vec<_> = identity.split(',').map(str::trim).collect();
        if fields.len() < 2 {
            return false;
        }
        if fields[0] == format!("nvidia/{version}") {
            fields[1] == release
        } else {
            fields.len() >= 3
                && fields[0] == "nvidia"
                && fields[1] == version
                && fields[2] == release
        }
    })
}

pub fn nvidia_dkms_version() -> Result<String, String> {
    let files = pacman_text(&["-Qql", "--", "nvidia-open-dkms"])?;
    let mut versions = Vec::new();
    for line in files.lines() {
        let line = line.trim().trim_start_matches('/');
        if let Some(value) = line.strip_prefix("usr/src/nvidia-") {
            if let Some(version) = value.strip_suffix("/dkms.conf") {
                if safe_package_name(version) && !versions.iter().any(|v| v == version) {
                    versions.push(version.to_owned());
                }
            }
        }
    }
    if versions.len() != 1 {
        return Err("o pacote NVIDIA não identifica exatamente uma fonte DKMS".to_owned());
    }
    Ok(versions.remove(0))
}

pub fn upstream_version(version: &str) -> &str {
    let version = version.split_once(':').map(|(_, v)| v).unwrap_or(version);
    version.rsplit_once('-').map(|(v, _)| v).unwrap_or(version)
}

pub fn persistent_oc_enabled(contents: &str) -> bool {
    let mut enabled = false;
    for line in contents.lines() {
        let line = line.split('#').next().unwrap_or("").trim();
        if let Some((key, value)) = line.split_once('=') {
            if key.trim() == "OC_ENABLED" {
                enabled = value.trim() == "1";
            }
        }
    }
    enabled
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn accepts_real_packages() {
        for p in [
            "linux-mocha-gcc-726",
            "linux-mocha-gcc-728",
            "linux-mocha-lqx",
            "linux",
        ] {
            assert!(safe_package_name(p));
        }
    }
    #[test]
    fn rejects_multiple_owners_and_options() {
        for p in ["", "--root", "one\ntwo", "name with spaces", "../package"] {
            assert!(!safe_package_name(p));
        }
    }
    #[test]
    fn matches_exact_dkms_line() {
        assert!(dkms_module_installed(
            "nvidia/615.71.09, 7.2.8-mocha, x86_64: installed",
            "615.71.09",
            "7.2.8-mocha"
        ));
    }
    #[test]
    fn accepts_older_dkms_format() {
        assert!(dkms_module_installed(
            "nvidia, 615.71.09, 7.2.8-mocha, x86_64: installed",
            "615.71.09",
            "7.2.8-mocha"
        ));
    }
    #[test]
    fn rejects_mixed_dkms_lines() {
        assert!(!dkms_module_installed(
            "nvidia/615.71.09, fallback, x86_64: installed\nother/1, current, x86_64: installed",
            "615.71.09",
            "current"
        ));
    }
    #[test]
    fn rejects_wrong_version_or_state() {
        assert!(!dkms_module_installed(
            "nvidia/615.71.09, current, x86_64: built",
            "615.71.09",
            "current"
        ));
        assert!(!dkms_module_installed(
            "nvidia/610.0, current, x86_64: installed",
            "615.71.09",
            "current"
        ));
    }
    #[test]
    fn oc_requires_explicit_opt_in() {
        assert!(!persistent_oc_enabled("CORE_OFFSET=50\n"));
        assert!(!persistent_oc_enabled("# OC_ENABLED=1\nOC_ENABLED=0\n"));
        assert!(persistent_oc_enabled(
            "OC_ENABLED = 1 # escolhido na interface\n"
        ));
        assert!(!persistent_oc_enabled("OC_ENABLED=1\nOC_ENABLED=0\n"));
    }
    #[test]
    fn package_release_is_not_dkms_version() {
        assert_eq!(upstream_version("615.71.09-1"), "615.71.09");
        assert_eq!(upstream_version("1:615.71.09-2"), "615.71.09");
    }
}
