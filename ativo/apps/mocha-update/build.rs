use cxx_qt_build::{CxxQtBuilder, QmlModule};

fn main() {
    CxxQtBuilder::new_qml_module(QmlModule::new("org.mocha.update").qml_file("qml/Main.qml"))
        .files(["src/mocha_backend.rs"])
        .build();
}
