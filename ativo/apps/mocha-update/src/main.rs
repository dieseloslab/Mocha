use cxx_qt_lib::{QGuiApplication, QQmlApplicationEngine, QUrl};

fn main() {
    // O QML incorporado é confiável e lê somente o índice JSON gerado pelo Mocha.
    // Em Rust 2024, set_var é seguro aqui porque nenhuma thread foi iniciada.
    #[allow(unused_unsafe)]
    unsafe {
        std::env::set_var("QML_XHR_ALLOW_FILE_READ", "1");
    }
    mocha_update::initialize_qml_backend();
    let mut application = QGuiApplication::new();
    let mut engine = QQmlApplicationEngine::new();

    if let Some(engine) = engine.as_mut() {
        engine.load(&QUrl::from("qrc:/qt/qml/org/mocha/update/qml/Main.qml"));
    }

    if let Some(application) = application.as_mut() {
        application.exec();
    }
}
