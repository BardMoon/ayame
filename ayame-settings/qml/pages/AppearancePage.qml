import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import Ayame 1.0 as Ayame

// Editor for the settings Ayame itself (crates/qml6) reads from `ayamerc`
// at startup -- theme, font, and the QQC2 style's own
// corner-radius/border-width/animation/UI-scale presets. Every change here
// applies live immediately (this whole app runs under the Ayame style, see
// `ayame-settings/src/main.rs`, so the effect is visible right in this
// window's own controls) but is *not* written to `ayamerc` until
// `commit()` runs (the settings window's "Save" button) -- see
// `commit()`/`cancel()`/`resetToDefaults()` below, wired to
// Save/Cancel/Defaults respectively.
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
    Ayame.StyleInfo { id: styleInfo }

    property string themeMode: theme.mode()
    property color accentColor: theme.accent_color()
    property string fontFamily: fontSettings.family()
    property real fontPointSize: fontSettings.point_size() > 0 ? fontSettings.point_size() : fontSettings.current_point_size()
    // Corner radius / border width / animation / UI scale are driven
    // through the `Ayame.Units` singleton (not a private instance here)
    // so that changing them re-styles every Ayame-styled control in this
    // process live, including this settings window's own -- see
    // Units.qml's own seed-once-then-update-live properties.
    property string cornerRadiusOption: Ayame.Units.cornerRadiusOption
    property string borderWidthOption: Ayame.Units.borderWidthOption
    property string animationSpeedOption: Ayame.Units.animationSpeedOption
    property bool animationsEnabled: Ayame.Units.animationsEnabled
    property real uiScale: Ayame.Units.uiScale
    property string savedStyle: styleInfo.saved_style()

    // Snapshot of what's actually on `ayamerc` right now, used only to
    // compute `dirty` below -- captured imperatively (`snapshotDisk()`,
    // called from `Component.onCompleted` and after `commit()`/`cancel()`)
    // rather than as bindings, since some of the live properties above
    // (the `Ayame.Units`-backed ones) are themselves live bindings; a
    // binding here would just always mirror them and never show a diff.
    property string diskThemeMode
    property color diskAccentColor
    property string diskFontFamily
    property real diskFontPointSize
    property string diskCornerRadiusOption
    property string diskBorderWidthOption
    property string diskAnimationSpeedOption
    property bool diskAnimationsEnabled
    property real diskUiScale
    property string diskSavedStyle

    function snapshotDisk() {
        root.diskThemeMode = root.themeMode;
        root.diskAccentColor = root.accentColor;
        root.diskFontFamily = root.fontFamily;
        root.diskFontPointSize = root.fontPointSize;
        root.diskCornerRadiusOption = root.cornerRadiusOption;
        root.diskBorderWidthOption = root.borderWidthOption;
        root.diskAnimationSpeedOption = root.animationSpeedOption;
        root.diskAnimationsEnabled = root.animationsEnabled;
        root.diskUiScale = root.uiScale;
        root.diskSavedStyle = root.savedStyle;
    }
    Component.onCompleted: root.snapshotDisk()

    // True whenever anything on this page differs from what's persisted --
    // wired to enable/disable the settings window's Save/Cancel buttons.
    readonly property bool dirty: root.themeMode !== root.diskThemeMode
        || !Qt.colorEqual(root.accentColor, root.diskAccentColor)
        || root.fontFamily !== root.diskFontFamily
        || root.fontPointSize !== root.diskFontPointSize
        || root.cornerRadiusOption !== root.diskCornerRadiusOption
        || root.borderWidthOption !== root.diskBorderWidthOption
        || root.animationSpeedOption !== root.diskAnimationSpeedOption
        || root.animationsEnabled !== root.diskAnimationsEnabled
        || root.uiScale !== root.diskUiScale
        || root.savedStyle !== root.diskSavedStyle

    // `Settings::default()`'s values, for the "Defaults" button's own
    // enabled state (no point offering to reset to defaults when already
    // there). Seeded once, same idiom as the live properties above --
    // `default_*()` are plain qinvokables with no reactive dependencies.
    // `defaultFontPointSize` mirrors `fontPointSize`'s own
    // system-default-resolution fallback above (the raw default is `0`,
    // meaning "use the system default point size", so comparing against
    // the raw `0` would never match the resolved display value).
    property string defaultThemeMode: theme.default_mode()
    property color defaultAccentColor: theme.default_accent_color()
    property string defaultFontFamily: fontSettings.default_family()
    property real defaultFontPointSize: fontSettings.default_point_size() > 0 ? fontSettings.default_point_size() : fontSettings.current_point_size()
    property string defaultCornerRadiusOption: Ayame.Units.defaultCornerRadiusOption()
    property string defaultBorderWidthOption: Ayame.Units.defaultBorderWidthOption()
    property string defaultAnimationSpeedOption: Ayame.Units.defaultAnimationSpeedOption()
    property bool defaultAnimationsEnabled: Ayame.Units.defaultAnimationsEnabled()
    property real defaultUiScale: Ayame.Units.defaultUiScale()
    property string defaultSavedStyle: styleInfo.default_saved_style()

    // True whenever everything on this page already matches
    // `Settings::default()` -- wired to disable the settings window's
    // "Defaults" button when clicking it wouldn't change anything.
    readonly property bool atDefaults: root.themeMode === root.defaultThemeMode
        && Qt.colorEqual(root.accentColor, root.defaultAccentColor)
        && root.fontFamily === root.defaultFontFamily
        && root.fontPointSize === root.defaultFontPointSize
        && root.cornerRadiusOption === root.defaultCornerRadiusOption
        && root.borderWidthOption === root.defaultBorderWidthOption
        && root.animationSpeedOption === root.defaultAnimationSpeedOption
        && root.animationsEnabled === root.defaultAnimationsEnabled
        && root.uiScale === root.defaultUiScale
        && root.savedStyle === root.defaultSavedStyle

    function setThemeMode(mode) {
        theme.set_mode(mode);
        root.themeMode = mode;
        root.setAccentColor(theme.default_accent_for(mode));
    }
    function setAccentColor(color) {
        theme.set_accent_color(color);
        root.accentColor = color;
    }

    // Commits everything currently live (possibly unsaved) on this page to
    // `ayamerc` -- wired to the settings window's "Save" button.
    function commit() {
        theme.persist();
        fontSettings.persist();
        styleInfo.persist();
        Ayame.Units.persist();
        root.snapshotDisk();
    }

    // Discards unsaved changes on this page: reloads from `ayamerc`,
    // applies it live, and re-seeds the page's own buffered properties so
    // the controls reflect it -- wired to the settings window's "Cancel"
    // button.
    function cancel() {
        theme.reload();
        fontSettings.reload();
        styleInfo.reload();
        Ayame.Units.cancel();
        root.themeMode = theme.mode();
        root.accentColor = theme.accent_color();
        root.fontFamily = fontSettings.family();
        root.fontPointSize = fontSettings.point_size() > 0 ? fontSettings.point_size() : fontSettings.current_point_size();
        root.savedStyle = styleInfo.saved_style();
        root.snapshotDisk();
    }

    // Resets everything on this page to `Settings::default()`, applied
    // live but not persisted until `commit()` runs -- wired to the
    // settings window's "Defaults" button.
    function resetToDefaults() {
        theme.reset_to_default();
        fontSettings.reset_to_default();
        styleInfo.reset_to_default();
        Ayame.Units.resetToDefaults();
        root.themeMode = theme.mode();
        root.accentColor = theme.accent_color();
        root.fontFamily = fontSettings.family();
        root.fontPointSize = fontSettings.point_size() > 0 ? fontSettings.point_size() : fontSettings.current_point_size();
        root.savedStyle = styleInfo.saved_style();
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
                        Ayame.Units.setCornerRadiusOption(model[index]);
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
                        Ayame.Units.setBorderWidthOption(model[index]);
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
                        Ayame.Units.setAnimationSpeedOption(model[index]);
                        root.animationSpeedOption = model[index];
                    }
                }
                QQC2.CheckBox {
                    text: "Enabled"
                    checked: root.animationsEnabled
                    onToggled: {
                        Ayame.Units.setAnimationsEnabled(checked);
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
                        Ayame.Units.setUiScale(value / 100);
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
