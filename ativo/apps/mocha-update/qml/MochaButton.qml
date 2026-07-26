import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
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
