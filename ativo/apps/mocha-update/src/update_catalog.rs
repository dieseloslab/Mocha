use semver::{Version, VersionReq};
use serde::Deserialize;
use std::collections::{BTreeMap, HashMap, HashSet};
use std::fs;
use std::path::{Component, Path};

const SUPPORTED_SCHEMA: u32 = 1;
const MAX_ARTIFACT_SIZE: u64 = 8 * 1024 * 1024 * 1024;

#[derive(Debug, Clone, Copy, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum UpdateKind {
    Application,
    Component,
    Content,
}

impl UpdateKind {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Application => "application",
            Self::Component => "component",
            Self::Content => "content",
        }
    }
}

#[derive(Debug, Clone, Deserialize)]
pub struct Catalog {
    pub schema: u32,
    pub channel: String,
    pub generated_at: String,
    pub minimum_catalog_client: u32,
    pub items: Vec<CatalogItem>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CatalogItem {
    pub id: String,
    pub kind: UpdateKind,
    pub version: String,
    pub architecture: String,
    pub artifact: String,
    pub sha256: String,
    pub size: u64,
    #[serde(default)]
    pub release_notes: Vec<String>,
    #[serde(default)]
    pub requires_app_restart: bool,
    #[serde(default)]
    pub requires_reboot: bool,
    pub minimum_mocha_update: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Allowlist {
    pub schema: u32,
    pub components: Vec<AllowedComponent>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct AllowedComponent {
    pub id: String,
    pub kind: UpdateKind,
    pub install_root: String,
    pub launcher: Option<String>,
    pub requires_root: bool,
    pub validator: Vec<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct InstalledState {
    pub schema: u32,
    pub components: BTreeMap<String, String>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DecisionKind {
    Install,
    NotNewer,
    WrongArchitecture,
    BlockedByClientVersion,
}

impl DecisionKind {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Install => "INSTALL",
            Self::NotNewer => "NOT_NEWER",
            Self::WrongArchitecture => "WRONG_ARCHITECTURE",
            Self::BlockedByClientVersion => "BLOCKED_CLIENT_VERSION",
        }
    }
}

#[derive(Debug, Clone)]
pub struct UpdateDecision {
    pub id: String,
    pub kind: UpdateKind,
    pub installed_version: Option<String>,
    pub available_version: String,
    pub decision: DecisionKind,
    pub artifact: String,
    pub size: u64,
    pub requires_app_restart: bool,
    pub requires_reboot: bool,
}

pub fn read_catalog(path: &Path) -> Result<Catalog, String> {
    read_json(path, "catálogo")
}

pub fn read_allowlist(path: &Path) -> Result<Allowlist, String> {
    read_json(path, "allowlist")
}

pub fn read_installed_state(path: &Path) -> Result<InstalledState, String> {
    read_json(path, "estado instalado")
}

fn read_json<T>(path: &Path, label: &str) -> Result<T, String>
where
    T: for<'de> Deserialize<'de>,
{
    let data = fs::read(path)
        .map_err(|error| format!("não foi possível ler {label} {}: {error}", path.display()))?;
    serde_json::from_slice(&data)
        .map_err(|error| format!("{label} JSON inválido em {}: {error}", path.display()))
}

pub fn validate_catalog(catalog: &Catalog) -> Result<(), String> {
    if catalog.schema != SUPPORTED_SCHEMA {
        return Err(format!(
            "schema de catálogo não suportado: {}",
            catalog.schema
        ));
    }
    if catalog.minimum_catalog_client > SUPPORTED_SCHEMA {
        return Err(format!(
            "catálogo exige cliente de catálogo {}",
            catalog.minimum_catalog_client
        ));
    }
    if !matches!(catalog.channel.as_str(), "stable" | "testing") {
        return Err(format!("canal inválido: {}", catalog.channel));
    }
    if catalog.generated_at.trim().is_empty() {
        return Err("generated_at vazio".to_string());
    }

    let mut ids = HashSet::new();
    for item in &catalog.items {
        validate_item(item)?;
        if !ids.insert(item.id.as_str()) {
            return Err(format!("ID duplicado no catálogo: {}", item.id));
        }
    }
    Ok(())
}

pub fn validate_allowlist(allowlist: &Allowlist) -> Result<(), String> {
    if allowlist.schema != SUPPORTED_SCHEMA {
        return Err(format!(
            "schema de allowlist não suportado: {}",
            allowlist.schema
        ));
    }

    let mut ids = HashSet::new();
    for item in &allowlist.components {
        validate_id(&item.id)?;
        if !ids.insert(item.id.as_str()) {
            return Err(format!("ID duplicado na allowlist: {}", item.id));
        }
        if item.kind == UpdateKind::Application && item.id != "mocha-update" {
            return Err(format!(
                "somente mocha-update pode usar kind=application: {}",
                item.id
            ));
        }
        if !Path::new(&item.install_root).is_absolute() {
            return Err(format!(
                "install_root precisa ser absoluto para {}",
                item.id
            ));
        }
        if item.validator.is_empty() || item.validator.iter().any(|part| part.trim().is_empty()) {
            return Err(format!("validador vazio para {}", item.id));
        }
        if let Some(launcher) = &item.launcher {
            if !Path::new(launcher).is_absolute() {
                return Err(format!("launcher precisa ser absoluto para {}", item.id));
            }
        }
    }
    Ok(())
}

pub fn classify_updates(
    catalog: &Catalog,
    allowlist: &Allowlist,
    installed: &InstalledState,
    architecture: &str,
) -> Result<Vec<UpdateDecision>, String> {
    validate_catalog(catalog)?;
    validate_allowlist(allowlist)?;
    if installed.schema != SUPPORTED_SCHEMA {
        return Err(format!(
            "schema de estado instalado não suportado: {}",
            installed.schema
        ));
    }

    let allowed: HashMap<&str, &AllowedComponent> = allowlist
        .components
        .iter()
        .map(|entry| (entry.id.as_str(), entry))
        .collect();

    let current_mocha = installed
        .components
        .get("mocha-update")
        .map(|value| Version::parse(value))
        .transpose()
        .map_err(|error| format!("versão instalada do mocha-update é inválida: {error}"))?;

    let mut decisions = Vec::with_capacity(catalog.items.len());
    for item in &catalog.items {
        let allow = allowed
            .get(item.id.as_str())
            .ok_or_else(|| format!("componente remoto não autorizado localmente: {}", item.id))?;
        if allow.kind != item.kind {
            return Err(format!(
                "kind remoto diverge da allowlist para {}: remoto={}, local={}",
                item.id,
                item.kind.as_str(),
                allow.kind.as_str()
            ));
        }

        let available = Version::parse(&item.version)
            .map_err(|error| format!("versão inválida para {}: {error}", item.id))?;
        let installed_text = installed.components.get(&item.id).cloned();
        let installed_version = installed_text
            .as_deref()
            .map(Version::parse)
            .transpose()
            .map_err(|error| format!("versão instalada inválida para {}: {error}", item.id))?;

        let decision = if item.architecture != "any" && item.architecture != architecture {
            DecisionKind::WrongArchitecture
        } else if let Some(requirement) = &item.minimum_mocha_update {
            let requirement = VersionReq::parse(requirement).map_err(|error| {
                format!(
                    "requisito do mocha-update inválido para {}: {error}",
                    item.id
                )
            })?;
            match &current_mocha {
                Some(current) if requirement.matches(current) => {
                    if installed_version
                        .as_ref()
                        .is_some_and(|current| current >= &available)
                    {
                        DecisionKind::NotNewer
                    } else {
                        DecisionKind::Install
                    }
                }
                _ => DecisionKind::BlockedByClientVersion,
            }
        } else if installed_version
            .as_ref()
            .is_some_and(|current| current >= &available)
        {
            DecisionKind::NotNewer
        } else {
            DecisionKind::Install
        };

        decisions.push(UpdateDecision {
            id: item.id.clone(),
            kind: item.kind,
            installed_version: installed_text,
            available_version: item.version.clone(),
            decision,
            artifact: item.artifact.clone(),
            size: item.size,
            requires_app_restart: item.requires_app_restart,
            requires_reboot: item.requires_reboot,
        });
    }

    Ok(decisions)
}

fn validate_item(item: &CatalogItem) -> Result<(), String> {
    validate_id(&item.id)?;
    if item.kind == UpdateKind::Application && item.id != "mocha-update" {
        return Err(format!(
            "somente mocha-update pode usar kind=application: {}",
            item.id
        ));
    }
    Version::parse(&item.version)
        .map_err(|error| format!("versão inválida para {}: {error}", item.id))?;
    if !matches!(item.architecture.as_str(), "x86_64" | "any") {
        return Err(format!(
            "arquitetura inválida para {}: {}",
            item.id, item.architecture
        ));
    }
    validate_artifact_path(&item.artifact, &item.id)?;
    if item.sha256.len() != 64
        || !item
            .sha256
            .bytes()
            .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
    {
        return Err(format!("SHA-256 inválido para {}", item.id));
    }
    if item.size == 0 || item.size > MAX_ARTIFACT_SIZE {
        return Err(format!("tamanho inválido para {}: {}", item.id, item.size));
    }
    if item.release_notes.len() > 64 || item.release_notes.iter().any(|note| note.len() > 512) {
        return Err(format!("notas de versão excessivas para {}", item.id));
    }
    if let Some(requirement) = &item.minimum_mocha_update {
        VersionReq::parse(requirement).map_err(|error| {
            format!(
                "requisito do mocha-update inválido para {}: {error}",
                item.id
            )
        })?;
    }
    Ok(())
}

fn validate_id(id: &str) -> Result<(), String> {
    if !(3..=64).contains(&id.len())
        || !id
            .bytes()
            .all(|byte| byte.is_ascii_lowercase() || byte.is_ascii_digit() || byte == b'-')
        || id.starts_with('-')
        || id.ends_with('-')
        || id.contains("--")
    {
        return Err(format!("ID inválido: {id}"));
    }
    Ok(())
}

fn validate_artifact_path(artifact: &str, id: &str) -> Result<(), String> {
    if artifact.is_empty()
        || artifact.starts_with('/')
        || artifact.contains("\\")
        || artifact.contains("://")
        || artifact.contains('?')
        || artifact.contains('#')
    {
        return Err(format!("caminho de artefato inválido para {id}"));
    }
    let path = Path::new(artifact);
    if path.components().any(|component| {
        matches!(
            component,
            Component::ParentDir | Component::RootDir | Component::Prefix(_)
        )
    }) {
        return Err(format!("caminho de artefato inseguro para {id}"));
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn valid_item() -> CatalogItem {
        CatalogItem {
            id: "mocha-steam-wrapper".to_string(),
            kind: UpdateKind::Component,
            version: "1.2.3".to_string(),
            architecture: "any".to_string(),
            artifact: "stable/component/wrapper/1.2.3/wrapper.tar.zst".to_string(),
            sha256: "a".repeat(64),
            size: 1024,
            release_notes: vec!["correção".to_string()],
            requires_app_restart: false,
            requires_reboot: false,
            minimum_mocha_update: Some(">=0.1.0".to_string()),
        }
    }

    #[test]
    fn accepts_valid_item() {
        assert!(validate_item(&valid_item()).is_ok());
    }

    #[test]
    fn rejects_parent_directory() {
        let mut item = valid_item();
        item.artifact = "../payload.tar.zst".to_string();
        assert!(validate_item(&item).is_err());
    }

    #[test]
    fn rejects_unknown_application_id() {
        let mut item = valid_item();
        item.kind = UpdateKind::Application;
        assert!(validate_item(&item).is_err());
    }

    #[test]
    fn rejects_uppercase_hash() {
        let mut item = valid_item();
        item.sha256 = "A".repeat(64);
        assert!(validate_item(&item).is_err());
    }
}
