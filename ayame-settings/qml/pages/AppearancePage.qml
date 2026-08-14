import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import Ayame 1.0 as Ayame

// Editor for the settings Ayame itself (crates/qml6) reads from `ayamerc`
// on startup and persists on every change -- theme, font, and the QQC2
// style's own corner-radius/border-width/animation/UI-scale presets. Each
// control writes straight through to the corresponding Ayame QML
// singleton, no local buffering: the same objects `Units.qml` and app
// startup already read.
//
// Every value below is seeded once from its singleton (`option()`/`mode()`/
// etc. are plain qinvokables, not NOTIFYing properties, so a direct
// `color: theme.accent_color()` binding would never refresh) then kept in
// a root property that setters update explicitly -- same "seed once,
// update live" idiom `crates/qml6/qml/theme/Units.qml` already uses for
// these exact singletons.
QQC2.Page {
    id: root

    Ayame.ThemeSettings { id: theme }
    Ayame.FontSettings { id: fontSettings }
    Ayame.CornerRadiusSettings { id: cornerRadiusSettings }
    Ayame.BorderWidthSettings { id: borderWidthSettings }
    Ayame.AnimationSettings { id: animationSettings }
    Ayame.UiScaleSettings { id: uiScaleSettings }
    Ayame.StyleInfo { id: styleInfo }

    property string themeMode: theme.mode()
    property color accentColor: theme.accent_color()
    property string fontFamily: fontSettings.family()
    property real fontPointSize: fontSettings.point_size() > 0 ? fontSettings.point_size() : fontSettings.current_point_size()
    property string cornerRadiusOption: cornerRadiusSettings.option()
    property string borderWidthOption: borderWidthSettings.option()
    property string animationSpeedOption: animationSettings.speed_option()
    property bool animationsEnabled: animationSettings.enabled()
    property real uiScale: uiScaleSettings.scale()
    property string savedStyle: styleInfo.saved_style()

    function setThemeMode(mode) {
        theme.set_mode(mode);
        root.themeMode = mode;
        root.setAccentColor(theme.default_accent_for(mode));
    }
    function setAccentColor(color) {
        theme.set_accent_color(color);
        root.accentColor = color;
    }

    readonly property var schemeIds: ["system"].concat(theme.available_scheme_ids().split("\n").filter(s => s.length > 0))
    readonly property var schemeNames: ["System"].concat(theme.available_scheme_names().split("\n").filter(s => s.length > 0))

    function variantIdsFor(schemeId) {
        return schemeId === "system" ? [] : theme.available_variant_ids(schemeId).split("\n").filter(s => s.length > 0);
    }
    function variantNamesFor(schemeId) {
        return schemeId === "system" ? [] : theme.available_variant_names(schemeId).split("\n").filter(s => s.length > 0);
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: layout.implicitHeight
        clip: true

        ColumnLayout {
            id: layout
            width: parent.width
            anchors.margins: 16
            spacing: 20

            QQC2.Label {
                text: "Appearance"
                font.pixelSize: 18
                font.bold: true
            }

            // -- Theme --------------------------------------------------
            QQC2.Label { text: "Theme"; font.bold: true }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Color Scheme:" }
                QQC2.ComboBox {
                    id: schemeCombo
                    Layout.minimumWidth: 160
                    model: root.schemeNames
                    currentIndex: {
                        const currentScheme = root.themeMode === "system" ? "system" : theme.scheme_of(root.themeMode);
                        const i = root.schemeIds.indexOf(currentScheme);
                        return i >= 0 ? i : 0;
                    }
                    onActivated: (index) => {
                        const schemeId = root.schemeIds[index];
                        if (schemeId === "system") {
                            root.setThemeMode("system");
                        } else {
                            const variantIds = root.variantIdsFor(schemeId);
                            if (variantIds.length > 0)
                                root.setThemeMode(variantIds[0]);
                        }
                    }
                }

                QQC2.Label { text: "Variant:"; visible: variantCombo.count > 0 }
                QQC2.ComboBox {
                    id: variantCombo
                    Layout.minimumWidth: 140
                    visible: count > 0
                    readonly property string schemeId: root.schemeIds[schemeCombo.currentIndex] ?? "system"
                    model: root.variantNamesFor(schemeId)
                    currentIndex: {
                        const ids = root.variantIdsFor(schemeId);
                        const i = ids.indexOf(root.themeMode);
                        return i >= 0 ? i : 0;
                    }
                    onActivated: (index) => root.setThemeMode(root.variantIdsFor(schemeId)[index])
                }
            }

            RowLayout {
                spacing: 8
                visible: schemeCombo.currentIndex !== 0

                QQC2.Label { text: "Accent Color:" }

                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: root.accentColor
                    border.width: 1
                    border.color: "#00000040"
                }

                QQC2.TextField {
                    text: root.accentColor.toString()
                    Layout.preferredWidth: 100
                    selectByMouse: true
                    onEditingFinished: root.setAccentColor(text)
                }
            }

            // -- Font -----------------------------------------------------
            QQC2.Label { text: "Font"; font.bold: true }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Family:" }
                QQC2.ComboBox {
                    Layout.minimumWidth: 200
                    editable: true
                    readonly property var families: fontSettings.available_families().split("\n").filter(s => s.length > 0)
                    model: families
                    currentIndex: {
                        const f = root.fontFamily.length > 0 ? root.fontFamily : fontSettings.current_family();
                        const i = families.indexOf(f);
                        return i >= 0 ? i : -1;
                    }
                    onActivated: (index) => {
                        fontSettings.set_family(families[index]);
                        root.fontFamily = families[index];
                    }
                }
                QQC2.Button {
                    text: "System Default"
                    onClicked: {
                        fontSettings.set_family("");
                        root.fontFamily = "";
                    }
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Point Size:" }
                QQC2.SpinBox {
                    from: 0
                    to: 72
                    value: root.fontPointSize
                    onValueModified: {
                        fontSettings.set_point_size(value);
                        root.fontPointSize = value;
                    }
                }
            }

            // -- Style ------------------------------------------------------
            QQC2.Label { text: "Style"; font.bold: true }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Corner Radius:" }
                QQC2.ComboBox {
                    model: ["disabled", "small", "medium", "large", "circle"]
                    currentIndex: Math.max(0, model.indexOf(root.cornerRadiusOption))
                    onActivated: (index) => {
                        cornerRadiusSettings.set_option(model[index]);
                        root.cornerRadiusOption = model[index];
                    }
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Border Width:" }
                QQC2.ComboBox {
                    model: ["thin", "default", "thick"]
                    currentIndex: Math.max(0, model.indexOf(root.borderWidthOption))
                    onActivated: (index) => {
                        borderWidthSettings.set_option(model[index]);
                        root.borderWidthOption = model[index];
                    }
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Animation Speed:" }
                QQC2.ComboBox {
                    enabled: root.animationsEnabled
                    model: ["slow", "normal", "fast"]
                    currentIndex: Math.max(0, model.indexOf(root.animationSpeedOption))
                    onActivated: (index) => {
                        animationSettings.set_speed_option(model[index]);
                        root.animationSpeedOption = model[index];
                    }
                }
                QQC2.CheckBox {
                    text: "Enabled"
                    checked: root.animationsEnabled
                    onToggled: {
                        animationSettings.set_enabled(checked);
                        root.animationsEnabled = checked;
                    }
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "UI Scale:" }
                QQC2.SpinBox {
                    from: 50
                    to: 200
                    stepSize: 10
                    value: Math.round(root.uiScale * 100)
                    textFromValue: (value) => value + "%"
                    valueFromText: (text) => parseInt(text)
                    onValueModified: {
                        uiScaleSettings.set_scale(value / 100);
                        root.uiScale = value / 100;
                    }
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Application Style:" }
                QQC2.ComboBox {
                    readonly property var styles: styleInfo.available_styles().split("\n").filter(s => s.length > 0)
                    model: styles
                    currentIndex: Math.max(0, styles.indexOf(root.savedStyle))
                    onActivated: (index) => {
                        styleInfo.save_style(styles[index]);
                        root.savedStyle = styles[index];
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
