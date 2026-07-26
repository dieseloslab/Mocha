import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var hostWindow

    ColumnLayout {
        anchors.fill: parent
        spacing: 18

        PageTitle {
            titleText: "Sobre o Mocha"
            descriptionText:
                "Informações do sistema e apoio ao desenvolvimento "
                + "do Mocha Linux."
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            StatusCard {
                titleText: "Sistema"
                valueText: "Mocha Linux 1.0"
                detailText: "Distribuição para jogos, criação e uso diário"
            }

            StatusCard {
                titleText: "Projeto"
                valueText: "Mocha Linux"
                detailText: "Desenvolvido por DieselOSLab"
                valueColor: hostWindow.accentSoftColor
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 205
            radius: 14
            color: hostWindow.elevatedColor
            border.width: 1
            border.color: hostWindow.borderColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 13

                Text {
                    text: "Apoie o projeto"
                    color: hostWindow.primaryTextColor
                    font.pixelSize: 19
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text:
                        "O apoio voluntário ajuda a manter a infraestrutura, "
                        + "os testes, a documentação e a evolução do Mocha Linux."
                    color: hostWindow.secondaryTextColor
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }

                MochaButton { // MOCHA_SUPPORT_APOIAR_V38
                    Layout.fillWidth: true
                    text: "Apoiar"
                    emphasized: true
                    onClicked: Qt.openUrlExternally("https://link.mercadopago.com.br/mochalinux")
                }

                MochaButton { // MOCHA_SUPPORT_PATREON_V38
                    Layout.fillWidth: true
                    text: "Patreon"
                    onClicked: Qt.openUrlExternally("https://www.patreon.com/MochaLinux")
                }

            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
