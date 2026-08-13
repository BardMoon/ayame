import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.ayame.settings

Page {
    id: root

    required property AyameSettingsObject settings

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Label {
            text: "General Settings"
            font.pixelSize: 18
            font.bold: true
        }

        CheckBox {
            text: "Draw Widget Borders"
            checked: root.settings.draw_widget_borders
            onCheckedChanged: root.settings.draw_widget_borders = checked
        }

        CheckBox {
            id: animCheck
            text: "Enable UI Animations"
            checked: root.settings.animations_enabled
            onCheckedChanged: root.settings.animations_enabled = checked
        }

        RowLayout {
            enabled: animCheck.checked
            spacing: 8

            Label { text: "Animation Duration (ms):" }

            SpinBox {
                from: 50
                to: 1000
                stepSize: 25
                value: root.settings.animation_duration_ms
                onValueChanged: root.settings.animation_duration_ms = value
            }
        }

        Item { Layout.fillHeight: true }
    }
}
