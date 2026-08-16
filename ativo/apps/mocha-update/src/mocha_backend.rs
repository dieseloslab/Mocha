use crate::protocol::{helper_path, parse_helper_event, HelperEvent, Operation};
use core::pin::Pin;
use cxx_qt::{CxxQtType, Threading};
use cxx_qt_lib::QString;
use std::env;
use std::fs;
use std::io::{BufRead, BufReader, Read};
use std::process::{Command, Stdio};
use std::thread;

#[cxx_qt::bridge]
mod ffi {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(QString, system_name, cxx_name = "systemName")]
        #[qproperty(QString, desktop_session, cxx_name = "desktopSession")]
        #[qproperty(QString, kernel_version, cxx_name = "kernelVersion")]
        #[qproperty(QString, kernel_detail, cxx_name = "kernelDetail")]
        #[qproperty(QString, kernel_package, cxx_name = "kernelPackage")]
        #[qproperty(QString, driver_version, cxx_name = "driverVersion")]
        #[qproperty(QString, driver_detail, cxx_name = "driverDetail")]
        #[qproperty(QString, status_message, cxx_name = "statusMessage")]
        #[qproperty(QString, activity_text, cxx_name = "activityText")]
        #[qproperty(QString, general_update_summary, cxx_name = "generalUpdateSummary")]
        #[qproperty(QString, kernel_update_summary, cxx_name = "kernelUpdateSummary")]
        #[qproperty(
            QString,
            arch_kernel_update_summary,
            cxx_name = "archKernelUpdateSummary"
        )]
        #[qproperty(QString, rollback_summary, cxx_name = "rollbackSummary")]
        #[qproperty(QString, oc_status, cxx_name = "ocStatus")]
        #[qproperty(QString, oc_mode, cxx_name = "ocMode")]
        #[qproperty(QString, oc_detail, cxx_name = "ocDetail")]
        #[qproperty(QString, selected_rollback_id, cxx_name = "selectedRollbackId")]
        #[qproperty(QString, log_path, cxx_name = "logPath")]
        #[qproperty(bool, operation_running, cxx_name = "operationRunning")]
        #[qproperty(bool, kernel_update_ready, cxx_name = "kernelUpdateReady")]
        #[qproperty(bool, arch_kernel_update_ready, cxx_name = "archKernelUpdateReady")]
        #[qproperty(bool, rollback_ready, cxx_name = "rollbackReady")]
        #[qproperty(bool, reboot_required, cxx_name = "rebootRequired")]
        #[qproperty(i32, operation_progress, cxx_name = "operationProgress")]
        type MochaBackend = super::MochaBackendRust;

        #[qinvokable]
        #[cxx_name = "refreshSystemStatus"]
        fn refresh_system_status(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "checkGeneralUpdates"]
        fn check_general_updates(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "applyGeneralUpdate"]
        fn apply_general_update(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "checkKernelDriver"]
        fn check_kernel_driver(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "applyKernelDriverUpdate"]
        fn apply_kernel_driver_update(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "checkArchKernel"]
        fn check_arch_kernel(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "applyArchKernel"]
        fn apply_arch_kernel(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "remarryKernelDriver"]
        fn remarry_kernel_driver(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "checkRollbacks"]
        fn check_rollbacks(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "applySelectedRollback"]
        fn apply_selected_rollback(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "checkMochaOc"]
        fn check_mocha_oc(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "enableOcSession"]
        fn enable_oc_session(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "enableOcPersistent"]
        fn enable_oc_persistent(self: Pin<&mut MochaBackend>);

        #[qinvokable]
        #[cxx_name = "disableOc"]
        fn disable_oc(self: Pin<&mut MochaBackend>);
    }

    impl cxx_qt::Threading for MochaBackend {}
}

pub struct MochaBackendRust {
    system_name: QString,
    desktop_session: QString,
    kernel_version: QString,
    kernel_detail: QString,
    kernel_package: QString,
    driver_version: QString,
    driver_detail: QString,
    status_message: QString,
    activity_text: QString,
    general_update_summary: QString,
    kernel_update_summary: QString,
    arch_kernel_update_summary: QString,
    rollback_summary: QString,
    oc_status: QString,
    oc_mode: QString,
    oc_detail: QString,
    selected_rollback_id: QString,
    log_path: QString,
    operation_running: bool,
    kernel_update_ready: bool,
    arch_kernel_update_ready: bool,
    rollback_ready: bool,
    reboot_required: bool,
    operation_progress: i32,
    selected_rollback_native: String,
}

impl Default for MochaBackendRust {
    fn default() -> Self {
        Self {
            system_name: QString::from("Mocha"),
            desktop_session: QString::from("Carregando sessão gráfica"),
            kernel_version: QString::from("Carregando kernel"),
            kernel_detail: QString::from("Leitura local do sistema"),
            kernel_package: QString::from("linux-mocha-lqx"),
            driver_version: QString::from("Carregando driver"),
            driver_detail: QString::from("Leitura local do sistema"),
            status_message: QString::from("Lendo o estado atual do sistema"),
            activity_text: QString::from(
                "O histórico apresenta verificações, atualizações, recasamentos e restaurações executados pelo Mocha Update.",
            ),
            general_update_summary: QString::from("Verificação ainda não executada"),
            kernel_update_summary: QString::from("Conjunto ainda não examinado"),
            arch_kernel_update_summary: QString::from("Canal Arch ainda não examinado"),
            rollback_summary: QString::from("Pontos de restauração ainda não examinados"),
            oc_status: QString::from("Lendo configuração"),
            oc_mode: QString::from("Mocha OC ainda não examinado"),
            oc_detail: QString::from(
                "Perfil +50 MHz GPU e +400 no controlador de memória (cerca de +200 MHz no clock real), restrito ao GameMode",
            ),
            selected_rollback_id: QString::default(),
            log_path: QString::default(),
            operation_running: false,
            kernel_update_ready: false,
            arch_kernel_update_ready: false,
            rollback_ready: false,
            reboot_required: false,
            operation_progress: 0,
            selected_rollback_native: String::new(),
        }
    }
}

impl ffi::MochaBackend {
    pub fn refresh_system_status(mut self: Pin<&mut Self>) {
        apply_system_status(self.as_mut());
        self.as_mut().set_status_message(QString::from(
            "Estado real do sistema carregado pelo backend Rust",
        ));
    }

    pub fn check_general_updates(self: Pin<&mut Self>) {
        start_operation(self, Operation::CheckGeneral, None);
    }

    pub fn apply_general_update(self: Pin<&mut Self>) {
        start_operation(self, Operation::ApplyGeneral, None);
    }

    pub fn check_kernel_driver(self: Pin<&mut Self>) {
        start_operation(self, Operation::CheckKernel, None);
    }

    pub fn apply_kernel_driver_update(self: Pin<&mut Self>) {
        start_operation(self, Operation::ApplyKernel, None);
    }

    pub fn check_arch_kernel(self: Pin<&mut Self>) {
        start_operation(self, Operation::CheckArchKernel, None);
    }

    pub fn apply_arch_kernel(self: Pin<&mut Self>) {
        start_operation(self, Operation::ApplyArchKernel, None);
    }

    pub fn remarry_kernel_driver(self: Pin<&mut Self>) {
        start_operation(self, Operation::Remarry, None);
    }

    pub fn check_rollbacks(self: Pin<&mut Self>) {
        start_operation(self, Operation::CheckRollbacks, None);
    }

    pub fn apply_selected_rollback(self: Pin<&mut Self>) {
        let rollback_id = self.as_ref().rust().selected_rollback_native.clone();
        if rollback_id.is_empty() {
            let mut this = self;
            this.as_mut().set_status_message(QString::from(
                "Localize e valide um ponto de restauração antes de restaurar",
            ));
            return;
        }
        start_operation(self, Operation::ApplyRollback, Some(rollback_id));
    }

    pub fn check_mocha_oc(self: Pin<&mut Self>) {
        start_operation(self, Operation::CheckOc, None);
    }

    pub fn enable_oc_session(self: Pin<&mut Self>) {
        start_operation(self, Operation::EnableOcSession, None);
    }

    pub fn enable_oc_persistent(self: Pin<&mut Self>) {
        start_operation(self, Operation::EnableOcPersistent, None);
    }

    pub fn disable_oc(self: Pin<&mut Self>) {
        start_operation(self, Operation::DisableOc, None);
    }
}

fn start_operation(
    mut qobject: Pin<&mut ffi::MochaBackend>,
    operation: Operation,
    argument: Option<String>,
) {
    if qobject.as_ref().rust().operation_running {
        qobject
            .as_mut()
            .set_status_message(QString::from("Uma operação já está em execução"));
        return;
    }

    qobject.as_mut().set_operation_running(true);
    qobject.as_mut().set_operation_progress(0);
    qobject.as_mut().set_reboot_required(false);
    match operation {
        Operation::CheckKernel | Operation::ApplyKernel | Operation::ApplyGeneral => {
            qobject.as_mut().set_kernel_update_ready(false);
        }
        Operation::CheckArchKernel | Operation::ApplyArchKernel => {
            qobject.as_mut().set_arch_kernel_update_ready(false);
        }
        Operation::CheckRollbacks => {
            qobject.as_mut().set_rollback_ready(false);
            qobject
                .as_mut()
                .set_selected_rollback_id(QString::default());
            qobject.as_mut().rust_mut().selected_rollback_native.clear();
        }
        Operation::ApplyRollback => {
            qobject.as_mut().set_rollback_ready(false);
        }
        Operation::CheckGeneral
        | Operation::Remarry
        | Operation::CheckOc
        | Operation::EnableOcSession
        | Operation::EnableOcPersistent
        | Operation::DisableOc => {}
    }
    qobject
        .as_mut()
        .set_status_message(QString::from(&format!("{} iniciada", operation.label())));

    let qt_thread = qobject.qt_thread();
    thread::spawn(move || {
        let helper = match helper_path(operation.requires_root()) {
            Ok(path) => path,
            Err(error) => {
                let _ = qt_thread.queue(move |mut backend| {
                    backend.as_mut().set_operation_running(false);
                    backend.as_mut().set_status_message(QString::from(&error));
                    backend.as_mut().set_activity_text(QString::from(&error));
                });
                return;
            }
        };

        let mut command = if operation.requires_root() {
            let mut value = Command::new("/usr/bin/pkexec");
            value.arg(&helper);
            value
        } else {
            Command::new(&helper)
        };
        command.arg(operation.argument());
        if let Some(argument) = argument {
            command.arg(argument);
        }
        command
            .env("LC_ALL", "C")
            .env("LANG", "C")
            .stdout(Stdio::piped())
            .stderr(Stdio::piped());

        let mut child = match command.spawn() {
            Ok(value) => value,
            Err(error) => {
                let message = format!("não foi possível iniciar {}: {error}", operation.label());
                let _ = qt_thread.queue(move |mut backend| {
                    backend.as_mut().set_operation_running(false);
                    backend.as_mut().set_status_message(QString::from(&message));
                    backend.as_mut().set_activity_text(QString::from(&message));
                });
                return;
            }
        };

        let stderr = child.stderr.take();
        let stderr_thread = thread::spawn(move || {
            let mut text = String::new();
            if let Some(mut stream) = stderr {
                let _ = stream.read_to_string(&mut text);
            }
            text
        });

        let mut explicit_result = false;
        if let Some(stdout) = child.stdout.take() {
            for line in BufReader::new(stdout).lines().map_while(Result::ok) {
                let Some(event) = parse_helper_event(&line) else {
                    continue;
                };
                match event {
                    HelperEvent::Progress(progress, message) => {
                        let _ = qt_thread.queue(move |mut backend| {
                            backend.as_mut().set_operation_progress(progress);
                            backend.as_mut().set_status_message(QString::from(&message));
                        });
                    }
                    HelperEvent::Data(key, value) => {
                        let _ = qt_thread.queue(move |mut backend| {
                            apply_helper_data(backend.as_mut(), &key, &value);
                        });
                    }
                    HelperEvent::Result(success, message) => {
                        explicit_result = true;
                        let refresh = operation.requires_root();
                        let _ = qt_thread.queue(move |mut backend| {
                            backend.as_mut().set_operation_running(false);
                            if success {
                                backend.as_mut().set_operation_progress(100);
                            }
                            backend.as_mut().set_status_message(QString::from(&message));
                            backend.as_mut().set_activity_text(QString::from(&message));
                            if refresh {
                                apply_system_status(backend.as_mut());
                            }
                        });
                    }
                }
            }
        }

        let status = child.wait();
        let stderr = stderr_thread.join().unwrap_or_default();
        if !explicit_result {
            let message = match status {
                Ok(status) if status.success() => format!("{} concluída", operation.label()),
                Ok(status) if status.code() == Some(126) => {
                    "Autorização administrativa cancelada".to_owned()
                }
                Ok(status) => {
                    let detail = stderr.lines().rev().find(|line| !line.trim().is_empty());
                    detail.map_or_else(
                        || format!("{} falhou com {status}", operation.label()),
                        |line| format!("{} falhou: {}", operation.label(), line.trim()),
                    )
                }
                Err(error) => format!("falha ao aguardar {}: {error}", operation.label()),
            };
            let _ = qt_thread.queue(move |mut backend| {
                backend.as_mut().set_operation_running(false);
                backend.as_mut().set_status_message(QString::from(&message));
                backend.as_mut().set_activity_text(QString::from(&message));
            });
        }
    });
}

fn apply_helper_data(mut backend: Pin<&mut ffi::MochaBackend>, key: &str, value: &str) {
    match key {
        "general_update_summary" => backend
            .as_mut()
            .set_general_update_summary(QString::from(value)),
        "kernel_update_summary" => backend
            .as_mut()
            .set_kernel_update_summary(QString::from(value)),
        "kernel_update_ready" => backend.as_mut().set_kernel_update_ready(value == "true"),
        "arch_kernel_update_summary" => backend
            .as_mut()
            .set_arch_kernel_update_summary(QString::from(value)),
        "arch_kernel_update_ready" => backend
            .as_mut()
            .set_arch_kernel_update_ready(value == "true"),
        "selected_rollback_id" => {
            backend
                .as_mut()
                .set_selected_rollback_id(QString::from(value));
            backend.as_mut().rust_mut().selected_rollback_native = value.to_owned();
        }
        "selected_rollback_summary" => {
            backend.as_mut().set_rollback_summary(QString::from(value));
        }
        "rollback_ready" => backend.as_mut().set_rollback_ready(value == "true"),
        "oc_status" => backend.as_mut().set_oc_status(QString::from(value)),
        "oc_mode" => backend.as_mut().set_oc_mode(QString::from(value)),
        "oc_detail" => backend.as_mut().set_oc_detail(QString::from(value)),
        "reboot_required" => backend.as_mut().set_reboot_required(value == "true"),
        "log_path" => backend.as_mut().set_log_path(QString::from(value)),
        _ => {}
    }
}

fn apply_system_status(mut backend: Pin<&mut ffi::MochaBackend>) {
    let system_name = system_name();
    let desktop_session = desktop_session();
    let kernel_version = command_output("/usr/bin/uname", &["-r"])
        .unwrap_or_else(|| "Kernel não identificado".to_owned());
    let kernel_package = installed_package_version("linux-mocha-lqx")
        .map(|version| format!("linux-mocha-lqx {version}"))
        .unwrap_or_else(|| "linux-mocha-lqx não instalado".to_owned());
    let kernel_detail = kernel_detail(&kernel_version);
    let driver_version = nvidia_version()
        .map(|version| format!("NVIDIA {version}"))
        .unwrap_or_else(|| "NVIDIA não carregado".to_owned());
    let driver_detail = installed_package_version("nvidia-open-dkms")
        .map(|version| format!("nvidia-open-dkms {version}"))
        .unwrap_or_else(|| "nvidia-open-dkms não instalado".to_owned());

    let (oc_status, oc_mode, oc_detail) = local_oc_status();

    backend
        .as_mut()
        .set_system_name(QString::from(&system_name));
    backend
        .as_mut()
        .set_desktop_session(QString::from(&desktop_session));
    backend
        .as_mut()
        .set_kernel_version(QString::from(&kernel_version));
    backend
        .as_mut()
        .set_kernel_detail(QString::from(&kernel_detail));
    backend
        .as_mut()
        .set_kernel_package(QString::from(&kernel_package));
    backend
        .as_mut()
        .set_driver_version(QString::from(&driver_version));
    backend
        .as_mut()
        .set_driver_detail(QString::from(&driver_detail));
    backend.as_mut().set_oc_status(QString::from(&oc_status));
    backend.as_mut().set_oc_mode(QString::from(&oc_mode));
    backend.as_mut().set_oc_detail(QString::from(&oc_detail));
}

fn local_oc_status() -> (String, String, String) {
    let persistent = std::path::Path::new("/etc/mocha/nvidia-game-oc.conf").is_file();
    let session = std::path::Path::new("/run/mocha-update/mocha-oc-session.enabled").is_file();
    let runtime = std::path::Path::new("/run/mocha-update/mocha-oc-runtime.conf").is_file();
    let (status, mode) = if persistent {
        (
            "Ativo permanentemente no GameMode",
            "A preferência permanece após reinicializações",
        )
    } else if session {
        (
            "Ativo nesta sessão",
            "A preferência temporária será removida no próximo reinício",
        )
    } else {
        (
            "Desativado",
            "Nenhum OC será aplicado quando o GameMode iniciar",
        )
    };
    let detail = if runtime {
        "OC aplicado agora: +50 MHz GPU e +400 no controlador de memória (cerca de +200 MHz no clock real)"
    } else {
        "Perfil: +50 MHz GPU e +400 no controlador de memória (cerca de +200 MHz no clock real), somente durante o GameMode"
    };
    (status.to_owned(), mode.to_owned(), detail.to_owned())
}

fn command_output(program: &str, args: &[&str]) -> Option<String> {
    let output = Command::new(program)
        .args(args)
        .env("LC_ALL", "C")
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }
    let value = String::from_utf8_lossy(&output.stdout).trim().to_owned();
    (!value.is_empty()).then_some(value)
}

fn installed_package_version(package: &str) -> Option<String> {
    command_output("/usr/bin/pacman", &["-Q", package])
        .and_then(|value| value.split_whitespace().nth(1).map(ToOwned::to_owned))
}

fn system_name() -> String {
    let contents = fs::read_to_string("/etc/os-release").unwrap_or_default();
    for line in contents.lines() {
        if let Some(value) = line.strip_prefix("PRETTY_NAME=") {
            let value = value.trim().trim_matches('"');
            if !value.is_empty() {
                return value.to_owned();
            }
        }
    }
    "Mocha".to_owned()
}

fn desktop_session() -> String {
    let desktop_raw = env::var("XDG_CURRENT_DESKTOP")
        .or_else(|_| env::var("DESKTOP_SESSION"))
        .unwrap_or_else(|_| "KDE".to_owned());
    let desktop_upper = desktop_raw.to_ascii_uppercase();
    let desktop = if desktop_upper.contains("KDE") || desktop_upper.contains("PLASMA") {
        "Plasma"
    } else if desktop_upper.contains("GNOME") {
        "GNOME"
    } else {
        desktop_raw.split(':').next().unwrap_or("Sessão gráfica")
    };
    let session_raw = env::var("XDG_SESSION_TYPE").unwrap_or_else(|_| "desconhecida".to_owned());
    let session = match session_raw.to_ascii_lowercase().as_str() {
        "wayland" => "Wayland",
        "x11" => "X11",
        _ => "Sessão gráfica",
    };
    format!("Arch Linux · {desktop} {session}")
}

fn kernel_detail(version: &str) -> String {
    let version_lower = version.to_ascii_lowercase();
    if version_lower.contains("mocha") && version_lower.contains("lqx") {
        "Mocha lqx ativo".to_owned()
    } else if version_lower.contains("arch") {
        "Kernel Arch de fallback ativo".to_owned()
    } else {
        "Kernel ativo fora do conjunto Mocha lqx".to_owned()
    }
}

fn nvidia_version() -> Option<String> {
    fs::read_to_string("/sys/module/nvidia/version")
        .ok()
        .map(|value| value.trim().to_owned())
        .filter(|value| !value.is_empty())
        .or_else(|| command_output("/usr/bin/modinfo", &["-F", "version", "nvidia"]))
}
