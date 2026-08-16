import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var hostWindow
    property string pendingAction: ""
    property string pendingKey: ""
    property string pendingTitle: ""

    ListModel {
        id: snapshotModel
    }

    function loadSnapshots() {
        const request = new XMLHttpRequest()
        request.open(
            "GET",
            "file:///var/lib/mocha-update/snapshot-index/index.json"
        )
        request.onreadystatechange = function() {
            if (request.readyState !== XMLHttpRequest.DONE)
                return

            if (request.status !== 0 && request.status !== 200) {
                statusText.text =
                    "Não foi possível ler o índice de pontos de restauração."
                return
            }

            try {
                const data = JSON.parse(request.responseText)
                if (!Array.isArray(data))
                    throw new Error("o índice não é uma lista")

                snapshotModel.clear()
                let catalogs = 0
                let restorable = 0
                let orphan = 0
                for (let index = 0; index < data.length; ++index) {
                    snapshotModel.append(data[index])
                    if (data[index].kind === "catalog") {
                        ++catalogs
                        if (data[index].restore)
                            ++restorable
                    } else {
                        ++orphan
                    }
                }

                statusText.text = data.length === 0
                    ? "Nenhum ponto de restauração foi encontrado."
                    : catalogs + " registro(s) catalogado(s), "
                        + restorable + " restaurável(is) e "
                        + orphan + " snapshot(s) órfão(s)."
            } catch (error) {
                statusText.text = "Índice inválido: " + error
            }
        }
        request.send()
    }

    function openAction(action, key, title, confirm) {
        pendingAction = action
        pendingKey = key
        pendingTitle = title
        if (confirm)
            confirmation.open()
        else
            executePendingAction()
    }

    function executePendingAction() {
        Qt.openUrlExternally(
            "mocha-snapshot-action://"
            + pendingAction
            + "/"
            + encodeURIComponent(pendingKey)
        )
        if (pendingAction === "restore") {
            actionHint.text =
                "O ponto será validado por completo e, se estiver íntegro, "
                + "o rollback será agendado. Reinicie somente após a confirmação."
        } else if (pendingAction === "delete") {
            actionHint.text =
                "A exclusão foi enviada. A lista será atualizada automaticamente."
        } else if (pendingAction === "create") {
            actionHint.text =
                "A criação real de um ponto completo foi iniciada. "
                + "A lista será atualizada após a validação."
        } else {
            actionHint.text =
                "A validação de integridade foi iniciada; o resultado aparecerá "
                + "em uma notificação."
        }
        refreshDelay.restart()
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.loadSnapshots()
    }

    Timer {
        id: refreshDelay
        interval: 3500
        repeat: false
        onTriggered: root.loadSnapshots()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Rollback"
                    color: "#f5e9df"
                    font.pixelSize: 27
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text:
                        "Pontos completos agrupam snapshots thin de / e /home "
                        + "com cópias verificadas de /boot e EFI."
                    color: "#bea99c"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }
            }

            Button {
                text: "Criar ponto"
                onClicked: root.openAction(
                    "create",
                    "manual",
                    "Ponto manual",
                    false
                )
            }

            Button {
                text: "Atualizar lista"
                onClicked: root.openAction(
                    "index",
                    "refresh",
                    "",
                    false
                )
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: "#38241b"
            border.width: 1
            border.color: "#714b37"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text {
                    id: statusText
                    Layout.fillWidth: true
                    text: "Carregando pontos de restauração..."
                    color: "#cdb8aa"
                    font.pixelSize: 12
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: snapshotList
                        width: parent.width
                        model: snapshotModel
                        spacing: 10

                        delegate: Rectangle {
                            required property string key
                            required property string kind
                            required property string date
                            required property string title
                            required property string detail
                            required property string size
                            required property bool restore
                            required property bool canDelete
                            required property string state

                            width: snapshotList.width
                            height: 150
                            radius: 12
                            color: kind === "catalog" ? "#432b20" : "#352a26"
                            border.width: 1
                            border.color: kind === "catalog" ? "#76503b" : "#5c504a"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 14

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Text {
                                        Layout.fillWidth: true
                                        text: date
                                        color: "#d69a68"
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: title
                                        color: "#f4e8df"
                                        font.pixelSize: 16
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideMiddle
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: detail
                                        color: "#c0aa9c"
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: size + " · " + state
                                        color: restore ? "#9fc58a" : "#d1a477"
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                ColumnLayout {
                                    spacing: 7

                                    Button {
                                        text: "Validar"
                                        visible: kind === "catalog"
                                        enabled: restore
                                        onClicked: root.openAction(
                                            "preflight",
                                            key,
                                            title,
                                            false
                                        )
                                    }

                                    Button {
                                        text: "Restaurar"
                                        visible: kind === "catalog"
                                        enabled: restore
                                        onClicked: root.openAction(
                                            "restore",
                                            key,
                                            title,
                                            true
                                        )
                                    }

                                    Button {
                                        text: kind === "catalog"
                                            ? "Apagar ponto"
                                            : "Apagar órfão"
                                        enabled: canDelete
                                        onClicked: root.openAction(
                                            "delete",
                                            key,
                                            title,
                                            true
                                        )
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: snapshotModel.count === 0
                            text: "Nenhum ponto de restauração disponível"
                            color: "#bda89a"
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }

        Text {
            id: actionHint
            Layout.fillWidth: true
            text:
                "Antes de uma transação do Pacman, o Mocha cria ou reutiliza "
                + "um ponto completo e validado. Se isso falhar, a transação é bloqueada."
            color: "#bea99c"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }
    }

    Dialog {
        id: confirmation
        modal: true
        anchors.centerIn: parent
        width: 520
        title: pendingAction === "restore"
            ? "Confirmar restauração"
            : "Confirmar exclusão"
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: root.executePendingAction()

        contentItem: Text {
            padding: 18
            wrapMode: Text.WordWrap
            color: "#f3e7de"
            text: pendingAction === "restore"
                ? (
                    "Restaurar “" + pendingTitle + "”?\n\n"
                    + "O Mocha conferirá catálogo, volumes, /boot, EFI e checksums. "
                    + "Se tudo estiver íntegro, o merge LVM será agendado. "
                    + "O programa não reiniciará o computador sozinho."
                )
                : (
                    "Apagar permanentemente “" + pendingTitle + "”?\n\n"
                    + "Volumes LVM e arquivos do catálogo serão removidos. "
                    + "Esta operação não pode ser desfeita."
                )
        }
    }
}
