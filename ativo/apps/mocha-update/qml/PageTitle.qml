import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
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
