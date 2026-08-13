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
            text: "Window Decoration Settings"
            font.pixelSize: 18
            font.bold: true
        }

        RowLayout {
            spacing: 8
            Label { text: "Shadow Size:" }
            ComboBox {
                model: ["None", "Small", "Medium", "Large", "VeryLarge"]
                currentIndex: Math.max(0, model.indexOf(root.settings.shadow_size))
                onActivated: (index) => root.settings.shadow_size = model[index]
            }
        }

        RowLayout {
            spacing: 8
            Label { text: "Shadow Strength (%):" }
            Slider {
                from: 0
                to: 100
                value: root.settings.shadow_strength
                onValueChanged: root.settings.shadow_strength = Math.round(value)
            }
            Label { text: root.settings.shadow_strength + "%" }
        }

        RowLayout {
            spacing: 8
            Label { text: "Corner Radius (px):" }
            SpinBox {
                from: 0
                to: 30
                value: root.settings.corner_radius
                onValueChanged: root.settings.corner_radius = value
            }
        }

        RowLayout {
            spacing: 8
            Label { text: "Border Size:" }
            ComboBox {
                model: ["None", "Tiny", "Normal", "Large"]
                currentIndex: Math.max(0, model.indexOf(root.settings.border_size))
                onActivated: (index) => root.settings.border_size = model[index]
            }
        }

        RowLayout {
            spacing: 8
            Label { text: "Titlebar Alignment:" }
            ComboBox {
                model: ["Left", "Center", "Right"]
                currentIndex: Math.max(0, model.indexOf(root.settings.titlebar_alignment))
                onActivated: (index) => root.settings.titlebar_alignment = model[index]
            }
        }

        Item { Layout.fillHeight: true }
    }
}
