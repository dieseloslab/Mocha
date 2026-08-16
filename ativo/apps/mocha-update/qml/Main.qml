import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mocha.update

ApplicationWindow {
    id: window

    visible: true
    width: 1180
    height: 760
    minimumWidth: 980
    minimumHeight: 640

    title: "Mocha Update"
    color: "#211610"

    property int currentPage: 0
    property string operationMessage: backend.statusMessage

    readonly property color backgroundColor: "#211610"
    readonly property color panelColor: "#2A1B14"
    readonly property color elevatedColor: "#35231A"
    readonly property color selectedColor: "#4A3025"
    readonly property color hoverColor: "#3D281F"
    readonly property color borderColor: "#604335"
    readonly property color accentColor: "#C89063"
    readonly property color accentSoftColor: "#E3B78D"
    readonly property color primaryTextColor: "#F4E9DF"
    readonly property color secondaryTextColor: "#BFA99A"
    readonly property color successColor: "#91B68B"
    readonly property color warningColor: "#D7B16F"

    MochaBackend {
        id: backend

        Component.onCompleted: backend.refreshSystemStatus()
    }

    component MochaLogo: Item {
        implicitWidth: 52
        implicitHeight: 52

        Rectangle {
            x: 34
            y: 22
            width: 15
            height: 16
            radius: height / 2
            color: "transparent"
            border.width: 3
            border.color: window.accentColor
        }

        Rectangle {
            x: 7
            y: 18
            width: 33
            height: 25
            radius: 7
            color: window.accentColor
        }

        Rectangle {
            x: 11
            y: 20
            width: 25
            height: 6
            radius: 3
            color: window.accentSoftColor
            opacity: 0.72
        }

        Rectangle {
            x: 5
            y: 45
            width: 42
            height: 4
            radius: 2
            color: window.borderColor
        }

        Rectangle {
            x: 15
            y: 3
            width: 3
            height: 11
            radius: 2
            color: window.accentSoftColor
            rotation: -10
        }

        Rectangle {
            x: 25
            y: 1
            width: 3
            height: 13
            radius: 2
            color: window.accentSoftColor
            rotation: 8
        }

        Rectangle {
            x: 34
            y: 5
            width: 3
            height: 9
            radius: 2
            color: window.accentSoftColor
            rotation: -8
        }
    }

    component NavItem: Button {
        id: navControl

        required property int pageIndex
        required property string label
        property string description: ""

        Layout.fillWidth: true
        implicitHeight: 64
        leftPadding: 14
        rightPadding: 10
        flat: true
        hoverEnabled: true

        background: Rectangle {
            radius: 10

            color: window.currentPage === navControl.pageIndex
                   ? window.selectedColor
                   : navControl.hovered
                     ? window.hoverColor
                     : "transparent"

            border.width: window.currentPage === navControl.pageIndex ? 1 : 0
            border.color: window.borderColor
        }

        contentItem: Column {
            spacing: 3

            Text {
                width: parent.width
                text: navControl.label
                color: window.currentPage === navControl.pageIndex
                       ? window.primaryTextColor
                       : window.secondaryTextColor
                font.pixelSize: 15
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: navControl.description
                color: window.secondaryTextColor
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        onClicked: window.currentPage = navControl.pageIndex
    }

    component PageTitle: ColumnLayout {
        required property string titleText
        required property string descriptionText

        Layout.fillWidth: true
        spacing: 5

        Text {
            text: titleText
            color: window.primaryTextColor
            font.pixelSize: 28
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            text: descriptionText
            color: window.secondaryTextColor
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }
    }

    component StatusCard: Rectangle {
        id: statusCard

        required property string titleText
        required property string valueText
        property string detailText: ""
        property color valueColor: window.primaryTextColor

        Layout.fillWidth: true
        Layout.preferredHeight: 128

        radius: 14
        color: window.elevatedColor
        border.width: 1
        border.color: window.borderColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 8

            Text {
                text: statusCard.titleText
                color: window.secondaryTextColor
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: statusCard.valueText
                color: statusCard.valueColor
                font.pixelSize: 18
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: statusCard.detailText
                color: window.secondaryTextColor
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }
    }

    component MochaButton: Button {
        id: mochaButton

        property bool emphasized: false

        implicitHeight: 46
        leftPadding: 18
        rightPadding: 18
        hoverEnabled: true

        contentItem: Text {
            text: mochaButton.text
            color: mochaButton.emphasized
                   ? "#211610"
                   : window.primaryTextColor
            font.pixelSize: 14
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 9
            color: mochaButton.emphasized
                   ? window.accentColor
                   : mochaButton.hovered
                     ? window.selectedColor
                     : window.elevatedColor

            border.width: mochaButton.emphasized ? 0 : 1
            border.color: window.borderColor
        }
    }

    component OperationPanel: Rectangle {
        id: operationPanel

        required property string titleText
        required property string descriptionText
        required property string buttonText
        property bool dangerous: false
        property bool actionEnabled: true
        signal triggered()

        Layout.fillWidth: true
        Layout.preferredHeight: 184

        radius: 14
        color: window.elevatedColor
        border.width: 1
        border.color: window.borderColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 24

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: operationPanel.titleText
                    color: window.primaryTextColor
                    font.pixelSize: 19
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                }

                Text {
                    Layout.fillWidth: true
                    text: operationPanel.descriptionText
                    color: window.secondaryTextColor
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }
            }

            MochaButton {
                text: operationPanel.buttonText
                emphasized: !operationPanel.dangerous

                enabled: operationPanel.actionEnabled && !backend.operationRunning
                onClicked: operationPanel.triggered()
            }
        }
    }

    component OcActionCard: Rectangle {
        id: ocActionCard

        required property string titleText
        required property string descriptionText
        required property string buttonText
        property bool dangerous: false
        signal triggered()

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: 210
        radius: 14
        color: window.elevatedColor
        border.width: 1
        border.color: ocActionCard.dangerous ? window.warningColor : window.borderColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: ocActionCard.titleText
                color: ocActionCard.dangerous ? window.warningColor : window.primaryTextColor
                font.pixelSize: 17
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: ocActionCard.descriptionText
                color: window.secondaryTextColor
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            MochaButton {
                Layout.fillWidth: true
                text: ocActionCard.buttonText
                emphasized: !ocActionCard.dangerous
                enabled: !backend.operationRunning
                onClicked: ocActionCard.triggered()
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 274
            Layout.fillHeight: true

            color: window.panelColor
            border.width: 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 78

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        MochaLogo {
                            Layout.preferredWidth: 52
                            Layout.preferredHeight: 52
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: "Mocha Update"
                                color: window.primaryTextColor
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Central do sistema"
                                color: window.accentColor
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: window.borderColor
                }

                NavItem {
                    pageIndex: 0
                    label: "Início"
                    description: "Resumo e ações rápidas"
                }

                NavItem {
                    pageIndex: 1
                    label: "Atualização do Sistema"
                    description: "Pacotes e aplicativos"
                }

                NavItem {
                    pageIndex: 2
                    label: "Kernel e Driver"
                    description: "Atualização controlada"
                }

                NavItem {
                    pageIndex: 3
                    label: "Recasar Kernel e Driver"
                    description: "Reinstalar o conjunto atual"
                }

                NavItem {
                    pageIndex: 4
                    label: "Mocha OC"
                    description: "Overclock somente no GameMode"
                }

                NavItem {
                    pageIndex: 5
                    label: "Rollback"
                    description: "Restaurar um estado anterior"
                }

                NavItem {
                pageIndex: 6
                label: "Sobre o Mocha"
                description: "Sistema e apoio"
                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74

                    radius: 10
                    color: window.elevatedColor
                    border.width: 1
                    border.color: window.borderColor

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 5

                        Text {
                            text: "Estado operacional"
                            color: window.secondaryTextColor
                            font.pixelSize: 11
                        }

                        Text {
                            text: "Proteção ativa"
                            color: window.successColor
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: "Operações separadas e verificadas"
                            color: window.secondaryTextColor
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: window.backgroundColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        Layout.fillWidth: true
                        text: "Mocha"
                        color: window.accentSoftColor
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        Layout.preferredWidth: 156
                        Layout.preferredHeight: 32
                        radius: 16
                        color: window.elevatedColor
                        border.width: 1
                        border.color: window.borderColor

                        Text {
                            anchors.centerIn: parent
                            text: "Sistema protegido"
                            color: window.successColor
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: window.currentPage

                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 18

                            PageTitle {
                                titleText: "Visão geral"
                                descriptionText:
                                    "Estado atual do sistema e acesso direto às operações do Mocha."
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 14

                                StatusCard {
                                    titleText: "Sistema"
                                    valueText: backend.systemName
                                    detailText: backend.desktopSession
                                }

                                StatusCard {
                                    titleText: "Kernel ativo"
                                    valueText: backend.kernelVersion
                                    detailText: backend.kernelDetail
                                }

                                StatusCard {
                                    titleText: "Driver gráfico"
                                    valueText: backend.driverVersion
                                    detailText: backend.driverDetail
                                    valueColor: backend.driverVersion === "NVIDIA não carregado"
                                                ? window.warningColor
                                                : window.successColor
                                }
                            }

                            Text {
                                text: "Ações rápidas"
                                color: window.primaryTextColor
                                font.pixelSize: 17
                                font.weight: Font.DemiBold
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                MochaButton {
                                    Layout.fillWidth: true
                                    text: "Verificar atualizações"
                                    emphasized: true

                                    enabled: !backend.operationRunning
                                    onClicked: backend.checkGeneralUpdates()
                                }

                                MochaButton {
                                    Layout.fillWidth: true
                                    text: "Examinar kernel e driver"

                                    onClicked: {
                                        window.currentPage = 2
                                    }
                                }

                                MochaButton {
                                    Layout.fillWidth: true
                                    text: "Abrir rollback"

                                    onClicked: {
                                        window.currentPage = 5
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 150

                                radius: 14
                                color: window.elevatedColor
                                border.width: 1
                                border.color: window.borderColor

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    spacing: 10

                                    Text {
                                        text: "Atividade recente"
                                        color: window.primaryTextColor
                                        font.pixelSize: 16
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: backend.activityText
                                        color: window.secondaryTextColor
                                        font.pixelSize: 13
                                        wrapMode: Text.WordWrap
                                    }

                                    Item {
                                        Layout.fillHeight: true
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 18

                            PageTitle {
                                titleText: "Atualização do Sistema"
                                descriptionText:
                                    "Consulta pacotes, Flatpak e o catálogo R2 stable em "
                                    + "https://updates.dieseloslab.org. Kernel e driver usam "
                                    + "exclusivamente o repositório separado."
                            }

                            OperationPanel {
                                titleText: "Examinar atualizações disponíveis"
                                descriptionText: backend.generalUpdateSummary
                                buttonText: "Examinar"
                                onTriggered: backend.checkGeneralUpdates()
                            }

                            OperationPanel {
                                titleText: "Aplicar atualização geral"
                                descriptionText:
                                    "Instala pacotes gerais e componentes Mocha autorizados, "
                                    + "com catálogo assinado e SHA-256. Kernel e driver não "
                                    + "são tratados por esta operação."
                                buttonText: "Atualizar sistema"
                                onTriggered: backend.applyGeneralUpdate()
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 18

                            PageTitle {
                                titleText: "Kernel e Driver"
                                descriptionText:
                                    "Consulte e instale os canais Mocha e Arch separadamente. "
                                    + "Nenhum kernel instalado é removido automaticamente."
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 14

                                StatusCard {
                                    titleText: "Kernel atual"
                                    valueText: backend.kernelVersion
                                    detailText: backend.kernelPackage
                                }

                                StatusCard {
                                    titleText: "Driver atual"
                                    valueText: backend.driverVersion
                                    detailText: backend.driverDetail
                                }
                            }

                            OperationPanel {
                                titleText: "Kernel Mocha (LQX)"
                                descriptionText: backend.kernelUpdateSummary
                                buttonText: backend.kernelUpdateReady
                                            ? "Instalar ou atualizar Mocha"
                                            : "Consultar canal Mocha"
                                onTriggered: {
                                    if (backend.kernelUpdateReady)
                                        backend.applyKernelDriverUpdate()
                                    else
                                        backend.checkKernelDriver()
                                }
                            }

                            OperationPanel {
                                titleText: "Kernel padrão Arch"
                                descriptionText: backend.archKernelUpdateSummary
                                buttonText: backend.archKernelUpdateReady
                                            ? "Instalar ou atualizar Arch"
                                            : "Consultar canal Arch"
                                onTriggered: {
                                    if (backend.archKernelUpdateReady)
                                        backend.applyArchKernel()
                                    else
                                        backend.checkArchKernel()
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 18

                            PageTitle {
                                titleText: "Recasar Kernel e Driver"
                                descriptionText:
                                    "Reconstrói o NVIDIA DKMS para o kernel iniciado, "
                                    + "seja Mocha, Arch ou outro kernel com headers válidos."
                            }

                            OperationPanel {
                                titleText: "Recasar conjunto atual"
                                descriptionText:
                                    "Não troca pacotes de kernel. Usa o kernel iniciado, "
                                    + "valida seus headers, recompila o NVIDIA DKMS, "
                                    + "regenera initramfs e atualiza o bootloader."
                                buttonText: "Recasar conjunto"
                                onTriggered: backend.remarryKernelDriver()
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 112

                                radius: 14
                                color: window.elevatedColor
                                border.width: 1
                                border.color: window.warningColor

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    text:
                                        "Nenhuma versão é trocada silenciosamente. "
                                        + "Qualquer necessidade técnica de mudança é "
                                        + "apresentada para confirmação antes da execução."
                                    color: window.warningColor
                                    font.pixelSize: 13
                                    wrapMode: Text.WordWrap
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 18

                            PageTitle {
                                titleText: "Mocha OC"
                                descriptionText:
                                    "Controla o perfil NVIDIA validado do Mocha. O overclock "
                                    + "é aplicado somente enquanto o GameMode estiver ativo."
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 14

                                StatusCard {
                                    titleText: "Estado do Mocha OC"
                                    valueText: backend.ocStatus
                                    detailText: backend.ocMode
                                    valueColor: backend.ocStatus === "Desativado"
                                                ? window.secondaryTextColor
                                                : window.successColor
                                }

                                StatusCard {
                                    titleText: "Perfil validado"
                                    valueText: "+50 MHz GPU"
                                    detailText: "+400 no controlador de memória (cerca de +200 MHz no clock real)"
                                    valueColor: window.accentSoftColor
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 14

                                OcActionCard {
                                    titleText: "Ativar OC nesta sessão"
                                    descriptionText:
                                        "Habilita o perfil somente nos jogos que ativarem o "
                                        + "GameMode. A preferência desaparece no próximo "
                                        + "reinício e os valores normais retornam ao sair do jogo."
                                    buttonText: "Ativar OC"
                                    onTriggered: backend.enableOcSession()
                                }

                                OcActionCard {
                                    titleText: "Ativar OC permanentemente no GameMode"
                                    descriptionText:
                                        "Mantém a preferência após reinicializações. O OC "
                                        + "continua restrito ao período em que o GameMode "
                                        + "estiver ativo."
                                    buttonText: "Ativar OC permanentemente"
                                    onTriggered: backend.enableOcPersistent()
                                }

                                OcActionCard {
                                    titleText: "Desativar totalmente o OC"
                                    descriptionText:
                                        "Remove os modos temporário e persistente e restaura "
                                        + "imediatamente os offsets normais da GPU e da memória."
                                    buttonText: "Desativar totalmente"
                                    dangerous: true
                                    onTriggered: backend.disableOc()
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: backend.ocDetail
                                color: window.secondaryTextColor
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Item { // MOCHA_SNAPSHOT_MANAGER_V11
                    SnapshotManager {
                    anchors.fill: parent
                    hostWindow: window
                    }
                    }

                    Item { // MOCHA_SUPPORT_PAGE_V13
                        SupportPage {
                            anchors.fill: parent
                            hostWindow: window
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58

                    radius: 11
                    color: window.panelColor
                    border.width: 1
                    border.color: window.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 14

                        BusyIndicator {
                            running: backend.operationRunning
                            visible: backend.operationRunning
                        }

                        Text {
                            Layout.fillWidth: true
                            text: window.operationMessage
                            color: window.secondaryTextColor
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            Layout.preferredWidth: 210
                            Layout.preferredHeight: 8
                            radius: 4
                            color: window.borderColor
                            clip: true

                            Rectangle {
                                width: parent.width
                                    * Math.max(
                                        0,
                                        Math.min(
                                            100,
                                            backend.operationProgress
                                        )
                                    ) / 100
                                height: parent.height
                                radius: parent.radius
                                color: window.accentColor
                            }
                        }
                    }
                }
            }
        }
    }

    Timer { // MOCHA_ABOUT_ARGUMENT_V13
        interval: 0
        running: true
        repeat: false
        onTriggered: {
            for (let index = 0; index < Qt.application.arguments.length; ++index) {
                if (Qt.application.arguments[index] === "--about") {
                    window.currentPage = 6
                    break
                }
            }
        }
    }
}
