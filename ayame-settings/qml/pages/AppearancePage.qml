import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit

// Editor for the settings Ayame itself (crates/qml6) reads from `ayamerc`
// at startup -- theme, font, and the QQC2 style's own
// corner-radius/border-width/animation/UI-scale presets.
//
// No live preview: every control here only updates this page's own
// buffered `root.*` property (see below) -- it does NOT call into
// `theme`/`fontSettings`/`styleInfo`/`StyleKit.Units`'s live-apply methods
// (`set_mode`/`set_accent_color`/`set_family`/`set_point_size`/`set*Option`
// etc.) until `commit()` runs (the settings window's "Save" button), which
// applies everything staged here in one go and then persists it. Changes
// are only guaranteed visible after an app restart -- some already-open
// windows' controls may not pick up an applied-but-not-restarted change
// even after Save (see `.agents/tasks/migrate-to-qt-labs-stylekit.md`:
// `Qt.labs.StyleKit`'s `StyleReader` doesn't reliably re-resolve for
// already-instantiated widgets, which made a true live-preview design
// unworkable once Ayame's own widgets started reading from it -- removing
// live preview entirely, for every setting here, keeps the UX consistent
// instead of only some controls updating live and others not).
// `cancel()`/`resetToDefaults()` (Cancel/Defaults) only ever touch this
// page's own buffered properties too -- neither needs to call into the
// singletons at all, since nothing was ever live-applied to begin with.
//
// Every value below is seeded once from its singleton (`option()`/`mode()`/
// etc. are plain qinvokables, not NOTIFYing properties, so a direct
// `color: theme.accent_color()` binding would never refresh) then kept in
// a root property that setters update explicitly -- same "seed once, keep
// in a root property" idiom `crates/qml6/qml/theme/Units.qml` uses for
// these exact singletons, just without that file's "...then update live"
// half anymore.
QQC2.Page {
    id: root

    Ayame.ThemeSettings { id: theme }
    Ayame.FontSettings { id: fontSettings }
    Ayame.StyleInfo { id: styleInfo }

    property string themeMode: theme.mode()
    property color accentColor: theme.accent_color()
    property string fontFamily: fontSettings.family()
    property real fontPointSize: fontSettings.point_size() > 0 ? fontSettings.point_size() : fontSettings.current_point_size()
    // Corner radius / border width / animation / UI scale read from the
    // `StyleKit.Units` singleton, but only as a one-shot seed via
    // Component.onCompleted below -- `StyleKit.Units.cornerRadiusOption`
    // etc. are themselves live properties (Units.qml's own
    // seed-once-then-update-live idiom), so declaring these as ordinary
    // property-initializer bindings here (`property string
    // cornerRadiusOption: StyleKit.Units.cornerRadiusOption`) would keep
    // permanently mirroring the live singleton and this page could never
    // hold a staged-but-not-yet-applied value distinct from it.
    property string cornerRadiusOption
    property string borderWidthOption
    property string animationSpeedOption
    property bool animationsEnabled
    property real uiScale
    property string savedStyle: styleInfo.saved_style()

    // Snapshot of what's actually on `ayamerc` right now, used only to
    // compute `dirty` below -- captured imperatively (`snapshotDisk()`,
    // called from `Component.onCompleted` and after `commit()`/`cancel()`)
    // rather than as bindings, since some of the live properties above
    // (the `StyleKit.Units`-backed ones) are themselves live bindings; a
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
    Component.onCompleted: {
        root.cornerRadiusOption = StyleKit.Units.cornerRadiusOption;
        root.borderWidthOption = StyleKit.Units.borderWidthOption;
        root.animationSpeedOption = StyleKit.Units.animationSpeedOption;
        root.animationsEnabled = StyleKit.Units.animationsEnabled;
        root.uiScale = StyleKit.Units.uiScale;
        root.snapshotDisk();
    }

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
    property string defaultCornerRadiusOption: StyleKit.Units.defaultCornerRadiusOption()
    property string defaultBorderWidthOption: StyleKit.Units.defaultBorderWidthOption()
    property string defaultAnimationSpeedOption: StyleKit.Units.defaultAnimationSpeedOption()
    property bool defaultAnimationsEnabled: StyleKit.Units.defaultAnimationsEnabled()
    property real defaultUiScale: StyleKit.Units.defaultUiScale()
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
        root.themeMode = mode;
        root.setAccentColor(theme.default_accent_for(mode));
    }
    function setAccentColor(color) {
        root.accentColor = color;
    }

    // Applies everything staged on this page (see class comment above --
    // nothing below was live-applied yet) to the underlying singletons,
    // then persists it to `ayamerc` -- wired to the settings window's
    // "Save" button.
    function commit() {
        theme.set_mode(root.themeMode);
        theme.set_accent_color(root.accentColor);
        fontSettings.set_family(root.fontFamily);
        fontSettings.set_point_size(root.fontPointSize);
        styleInfo.save_style(root.savedStyle);
        StyleKit.Units.setCornerRadiusOption(root.cornerRadiusOption);
        StyleKit.Units.setBorderWidthOption(root.borderWidthOption);
        StyleKit.Units.setAnimationSpeedOption(root.animationSpeedOption);
        StyleKit.Units.setAnimationsEnabled(root.animationsEnabled);
        StyleKit.Units.setUiScale(root.uiScale);

        theme.persist();
        fontSettings.persist();
        styleInfo.persist();
        StyleKit.Units.persist();
        root.snapshotDisk();
    }

    // Discards unsaved changes on this page: nothing was ever live-applied
    // (see class comment above), so this just resets the page's own
    // buffered properties back to the last-saved snapshot -- wired to the
    // settings window's "Cancel" button.
    function cancel() {
        root.themeMode = root.diskThemeMode;
        root.accentColor = root.diskAccentColor;
        root.fontFamily = root.diskFontFamily;
        root.fontPointSize = root.diskFontPointSize;
        root.cornerRadiusOption = root.diskCornerRadiusOption;
        root.borderWidthOption = root.diskBorderWidthOption;
        root.animationSpeedOption = root.diskAnimationSpeedOption;
        root.animationsEnabled = root.diskAnimationsEnabled;
        root.uiScale = root.diskUiScale;
        root.savedStyle = root.diskSavedStyle;
    }

    // Resets everything on this page's buffered properties to
    // `Settings::default()` -- not applied to the singletons or persisted
    // until `commit()` runs, same as any other change on this page --
    // wired to the settings window's "Defaults" button.
    function resetToDefaults() {
        root.themeMode = root.defaultThemeMode;
        root.accentColor = root.defaultAccentColor;
        root.fontFamily = root.defaultFontFamily;
        root.fontPointSize = root.defaultFontPointSize;
        root.cornerRadiusOption = root.defaultCornerRadiusOption;
        root.borderWidthOption = root.defaultBorderWidthOption;
        root.animationSpeedOption = root.defaultAnimationSpeedOption;
        root.animationsEnabled = root.defaultAnimationsEnabled;
        root.uiScale = root.defaultUiScale;
        root.savedStyle = root.defaultSavedStyle;
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
                    onActivated: (index) => root.fontFamily = families[index]
                }
                QQC2.Button {
                    text: "System Default"
                    onClicked: root.fontFamily = ""
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Point Size:" }
                QQC2.SpinBox {
                    from: 0
                    to: 72
                    value: root.fontPointSize
                    onValueModified: root.fontPointSize = value
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
                    onActivated: (index) => root.cornerRadiusOption = model[index]
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Border Width:" }
                QQC2.ComboBox {
                    model: ["thin", "default", "thick"]
                    currentIndex: Math.max(0, model.indexOf(root.borderWidthOption))
                    onActivated: (index) => root.borderWidthOption = model[index]
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Animation Speed:" }
                QQC2.ComboBox {
                    enabled: root.animationsEnabled
                    model: ["slow", "normal", "fast"]
                    currentIndex: Math.max(0, model.indexOf(root.animationSpeedOption))
                    onActivated: (index) => root.animationSpeedOption = model[index]
                }
                QQC2.CheckBox {
                    text: "Enabled"
                    checked: root.animationsEnabled
                    onToggled: root.animationsEnabled = checked
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "UI Scale:" }
                QQC2.SpinBox {
                    from: 50
                    to: 200
                    stepSize: 1
                    value: Math.round(root.uiScale * 100)
                    textFromValue: (value) => (value / 100).toFixed(2)
                    valueFromText: (text) => Math.round(parseFloat(text) * 100)
                    onValueModified: root.uiScale = value / 100
                }
            }

            RowLayout {
                spacing: 8
                QQC2.Label { text: "Application Style:" }
                QQC2.ComboBox {
                    readonly property var styles: styleInfo.available_styles().split("\n").filter(s => s.length > 0)
                    model: styles
                    currentIndex: Math.max(0, styles.indexOf(root.savedStyle))
                    onActivated: (index) => root.savedStyle = styles[index]
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
