use cxx_qt_build::{CxxQtBuilder, QmlModule};

fn main() {
    CxxQtBuilder::new_qml_module(
        QmlModule::new("org.mocha.update")
            .qml_file("qml/Main.qml")
            .qml_file("qml/SnapshotManager.qml")
            .qml_file("qml/SupportPage.qml")
            .qml_file("qml/MochaButton.qml")
            .qml_file("qml/PageTitle.qml")
            .qml_file("qml/StatusCard.qml"),
    )
    .files(["src/mocha_backend.rs"])
    .build();
}
