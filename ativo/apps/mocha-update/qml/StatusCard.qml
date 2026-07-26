import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
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
