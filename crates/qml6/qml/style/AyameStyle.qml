pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit

// Phase 0/1 of the migration described in
// `.agents/tasks/migrate-to-qt-labs-stylekit.md`: a real Qt.labs.StyleKit
// `Style` replacing `crates/stylekit`'s hand-rolled `Theme`/`Units`
// singletons as the color/metric data source for Ayame's QQC2 style
// delegates (`crates/qml6/qml/widgets/**`), which keep their own
// hand-painted structure and only read from this instead.
//
// Colors deliberately do NOT use Style's `light`/`dark`/`themeName`/`Theme`
// mechanism (that's for apps with a fixed, named palette per theme). Ayame
// has no palette of its own -- every color already comes from whatever
// QPalette is active (see the old `Theme.qml`'s class comment), and a
// `Style`'s own resolved `palette` property (`root.palette` below) already
// tracks that live, the same way `QQuickPalette` always has -- confirmed by
// this file's own pilot use in Button.qml (see task file Phase 1). Binding
// straight to `root.palette.<role>` is therefore both simpler than trying
// to make `Theme`'s light/dark switching track a live palette, and is the
// documented fallback for exactly this situation.
//
// Phase 2 extends Phase 1's pilot (`button`/`flatButton`/`control`) to the
// rest of Ayame's ~57 widgets, one category at a time (see task file's
// per-category checklist). Per the colorSet grep done during Phase 0
// planning, Ayame's old window/view/header/tooltip split is *already*
// nearly 1:1 with Qt.labs.StyleKit's per-control-type slots in practice
// (view -> `control`/`abstractButton`/most controls, window ->
// `applicationWindow`/`pane`/`page`, header ->
// `tabBar`/`tabButton`/`toolBar`/`toolSeparator`).
//
// `hoverColor`/`pressedColor` turned out to be the *same* formula
// (blended off `palette.highlight`) regardless of old-Theme colorSet --
// only background/text/border vary by colorSet -- so they're shared
// below instead of duplicated per colorSet like `_view*`/`_header*` are.
//
// "highlightColor"/"highlightedTextColor" reads (focus rings, checked
// indicators, pressed-state text on ghost buttons) are NOT being ported
// into this file at all: they turned out to be plain, unblended
// `palette.highlight`/`palette.highlightedText` passthroughs in the old
// Theme.qml, so widget files read `control.palette.highlight`/
// `.highlightedText` directly now -- same live value, one less thing
// funneled through AyameStyle, and it drops those widgets' need for the
// legacy `StyleKit.Theme` import entirely (they may still need
// `StyleKit.Units` for spacing/radius/icon sizes, per Phase 0's deferred
// scope).
//
// Open question for Phase 2: Qt.labs.StyleKit's `AbstractStylableControls`
// has no dedicated slot for tooltips (no `tooltip`/`toolTip` property, and
// `ToolTip` isn't in `StyleReader.ControlType` either) -- Ayame's
// `ToolTip.qml` may need to stay on the `control` fallback style, or this
// needs re-investigation against a newer Qt.labs.StyleKit revision.
//
// Border width still reads `StyleKit.Units.borderWidth` (the existing
// crate) rather than duplicating `Ayame.BorderWidthSettings` here -- see
// Phase 1's note in the task file for why (narrows the pilot's new
// variables; Phase 2 mechanically repeats the same choice for
// consistency, revisit once the bulk of the rollout is done).
import StyleKit 1.0 as LegacyStyleKit

Style {
    id: root

    function _blend(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    // Pre-composites `fg` over `bg` at `alpha` and returns an opaque
    // (alpha=1) result -- used for border colors, which need to render as
    // solid pixels rather than semi-transparent ones (a translucent border
    // double-blends wherever it overlaps another translucent layer, e.g.
    // two adjacent bordered widgets, or a border drawn over a thumbnail).
    // `_blend` above is left alone for `_hoverColor`/`_pressedColor`, which
    // are genuinely meant to overlay whatever background color they're
    // drawn on top of.
    function _opaqueBlend(fg, bg, alpha) {
        return Qt.rgba(
            fg.r * alpha + bg.r * (1 - alpha),
            fg.g * alpha + bg.g * (1 - alpha),
            fg.b * alpha + bg.b * (1 - alpha),
            1.0);
    }

    // Same for every colorSet -- see class comment above.
    readonly property color _hoverColor: root._blend(root.palette.highlight, 0.15)
    readonly property color _pressedColor: root._blend(root.palette.highlight, 0.5)

    // Follow-up task (migrate-units-cornerradius-to-stylekit.md): a single
    // global value, same deliberate passthrough-via-AyameStyle pattern as
    // `LegacyStyleKit.Units.borderWidth` below -- `Units.qml`'s
    // corner-radius preset UI/persistence stays right where it is, this
    // just gives widget files one grouped-property read instead of a
    // second direct `StyleKit.Units` import for radius alone.
    readonly property real _cornerRadius: LegacyStyleKit.Units.cornerRadius

    // Mirrors the old Theme.qml's paletteFor(view)/derived-color math,
    // just reading root.palette (this Style's own live-resolved
    // QQuickPalette) instead of a SystemPalette singleton.
    readonly property color _viewBackground: root.palette.base
    readonly property color _viewText: root.palette.text
    readonly property color _viewBorder: root._opaqueBlend(root._viewText, root._viewBackground, 0.3)
    readonly property color _viewHoverBorder: root._opaqueBlend(root._viewText, root._viewBackground, 0.4)

    // paletteFor(header) used pal.button/pal.buttonText as its base pair
    // (see old Theme.qml) -- everything else follows the same formula as
    // view above, just off that pair instead.
    readonly property color _headerBackground: root.palette.button
    readonly property color _headerText: root.palette.buttonText
    readonly property color _headerBorder: root._opaqueBlend(root._headerText, root._headerBackground, 0.3)
    readonly property color _headerHoverBorder: root._opaqueBlend(root._headerText, root._headerBackground, 0.4)

    // paletteFor(window) was the old Theme.qml's default/fallback branch
    // (pal.window/pal.windowText, no explicit colorSet check needed) --
    // same formula as view/header above, just off that pair.
    readonly property color _windowBackground: root.palette.window
    readonly property color _windowText: root.palette.windowText
    readonly property color _windowBorder: root._opaqueBlend(root._windowText, root._windowBackground, 0.3)
    readonly property color _windowHoverBorder: root._opaqueBlend(root._windowText, root._windowBackground, 0.4)

    // `control` is the ultimate fallback every other slot cascades to when
    // left unset, so it's seeded with the same view-colorSet look as a
    // safety net for anything read via StyleReader before it gets a more
    // specific slot below.
    control: ControlStyle {
        background.color: root._viewBackground
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._viewBorder
        background.radius: root._cornerRadius
        text.color: root._viewText

        hovered.background.color: root._hoverColor
        hovered.background.border.color: root._viewHoverBorder

        pressed.background.color: root._pressedColor
    }

    // Cascades to button/checkBox/radioButton/etc. per Qt.labs.StyleKit's
    // own inheritance (see plan doc) whenever a more specific slot below
    // isn't set for a given control type -- also directly read by
    // AbstractButton.qml itself (no built-in control subclasses it, but
    // it's Ayame's public "roll your own AbstractButton" delegate).
    // `focused`/`pressed.text` overrides here are for DelayButton.qml/
    // RoundButton.qml specifically (both fall back to this slot -- see
    // above -- and both old-Theme-era swapped border-to-highlight on
    // activeFocus, and RoundButton also swapped text-to-highlightedText
    // on pressed). `button`/`flatButton` above don't get either: Button.qml
    // relies on HighlightRing for focus instead, and never had the
    // pressed-text swap.
    abstractButton: ControlStyle {
        background.color: root._viewBackground
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._viewBorder
        background.radius: root._cornerRadius
        text.color: root._viewText

        hovered.background.color: root._hoverColor
        hovered.background.border.color: root._viewHoverBorder

        pressed.background.color: root._pressedColor
        pressed.text.color: root.palette.highlightedText

        focused.background.border.color: root.palette.highlight
    }

    button: ControlStyle {
        background.color: root._viewBackground
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._viewBorder
        background.radius: root._cornerRadius
        text.color: root._viewText

        hovered.background.color: root._hoverColor
        hovered.background.border.color: root._viewHoverBorder

        pressed.background.color: root._pressedColor
    }

    flatButton: ControlStyle {
        background.color: root._viewBackground
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._viewBorder
        background.radius: root._cornerRadius
        text.color: root._viewText

        hovered.background.color: root._hoverColor
        hovered.background.border.color: root._viewHoverBorder

        pressed.background.color: root._pressedColor
    }

    // RadioButton.qml draws no background rect of its own (just an
    // indicator ring + dot) -- only border/text end up read.
    radioButton: ControlStyle {
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._viewBorder
        text.color: root._viewText

        hovered.background.border.color: root._viewHoverBorder
        checked.background.border.color: root.palette.highlight
    }

    // Ghost buttons: transparent at rest, tinted on hover/press, no
    // border. header colorSet (matches old Theme.Theme.header colorSet
    // both used).
    tabButton: ControlStyle {
        background.color: "transparent"
        text.color: root._headerText

        hovered.background.color: root._hoverColor
        pressed.background.color: root._pressedColor
    }

    toolButton: ControlStyle {
        background.color: "transparent"
        background.radius: root._cornerRadius
        text.color: root._viewText

        hovered.background.color: root._hoverColor
        pressed.background.color: root._pressedColor
        pressed.text.color: root.palette.highlightedText
    }

    // CheckBox.qml's indicator: transparent at rest (unlike radioButton
    // above, which has no fill at all -- CheckBox's does), tinted on
    // hover, solid highlight when checked -- checked wins over hover, same
    // precedence assumption as radioButton's checked-border-wins-over-hover.
    checkBox: ControlStyle {
        background.color: "transparent"
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._viewBorder
        background.radius: root._cornerRadius
        text.color: root._viewText

        hovered.background.color: root._hoverColor
        hovered.background.border.color: root._viewHoverBorder

        checked.background.color: root.palette.highlight
        checked.background.border.color: root.palette.highlight
    }

    // ComboBox.qml has no HighlightRing (unlike Button.qml/SpinBox.qml) --
    // its only activeFocus cue is swapping the border to full highlight,
    // same shape as abstractButton's `focused` override above.
    comboBox: ControlStyle {
        background.color: root._viewBackground
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._viewBorder
        background.radius: root._cornerRadius
        text.color: root._viewText

        hovered.background.color: root._hoverColor
        pressed.background.color: root._pressedColor
        focused.background.border.color: root.palette.highlight
    }

    // Switch.qml's track: filled backgroundColor at rest (unlike
    // checkBox's transparent indicator), solid highlight when checked.
    // Thumb color (highlightedText/text pass-through, no hover/pressed
    // variance) stays a direct control.palette.* read in the widget, same
    // as checkBox's checkmark glyph.
    switchControl: ControlStyle {
        background.color: root._viewBackground
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._viewBorder

        hovered.background.border.color: root._viewHoverBorder

        checked.background.color: root.palette.highlight
        checked.background.border.color: root.palette.highlight
    }

    // Phase 4: ApplicationWindow.qml's own app-chrome background -- the
    // last real `StyleKit.Theme` reference in the tree (was
    // `Theme.paletteFor(Theme.window).backgroundColor`). Same `window`
    // colorSet/background-only shape as `page` below.
    applicationWindow: ControlStyle {
        background.color: root._windowBackground
    }

    // containers/ batch: Page.qml/Pane.qml used the old Theme's `window`
    // colorSet (unlike everything in buttons/controls, which was all
    // `view`) -- `control`'s own fallback is seeded with the view look, so
    // these two need their own slot rather than relying on the cascade.
    // Both only ever read `background.color` (no border/text) before this
    // migration, so that's all that's set here.
    page: ControlStyle {
        background.color: root._windowBackground
    }

    // `pane` also picked up a border in the inputs/menus/popups/scroll/
    // impl batch: Pane.qml itself never reads background.border.*, so
    // this addition is silently unused there, but popups/Drawer.qml
    // reuses this same slot for its own (bordered) background -- see that
    // file's own comment.
    pane: ControlStyle {
        background.color: root._windowBackground
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._windowBorder
    }

    // TabBar.qml/ToolBar.qml used the old Theme's `header` colorSet.
    tabBar: ControlStyle {
        background.color: root._headerBackground
    }

    toolBar: ControlStyle {
        background.color: root._headerBackground
        background.border.width: LegacyStyleKit.Units.borderWidth
        background.border.color: root._headerBorder
    }

    // delegates/ batch: ItemDelegate.qml's "ghost" background (transparent
    // at rest, tinted hover/press, no border) -- textually the same shape
    // as toolButton above, but kept as its own slot since `itemDelegate`
    // is the semantically-correct AbstractStylableControls entry for it
    // (and for CheckDelegate/RadioDelegate/SwipeDelegate/SwitchDelegate,
    // none of which have their own StyleReader.ControlType -- they all
    // read this same slot for their shared background+text look, then
    // layer their own indicator's StyleReader on top for the
    // check/radio/switch-shaped part -- see those widgets' own
    // `indicatorStyleReader`).
    itemDelegate: ControlStyle {
        background.color: "transparent"
        background.radius: root._cornerRadius
        text.color: root._viewText

        hovered.background.color: root._hoverColor
        pressed.background.color: root._pressedColor

        highlighted.text.color: root.palette.highlightedText
    }

    // inputs/menus/popups/scroll/impl batch: ToolSeparator.qml's rule
    // color -- the old Theme.qml's `subColor` and `borderColor` were the
    // *same* formula for every colorSet (both just `blend(textColor,
    // 0.3)`), so this doubles as MenuSeparator.qml's rule too (reused
    // directly, see that file -- Menu/MenuItem/MenuSeparator have no
    // AbstractStylableControls entry of their own at all, unlike
    // ToolSeparator, which does; see that file's own comment for why the
    // header-colorSet math for those three lives locally instead).
    // `background.color` (not `.border.color`) simply because that's the
    // property both widgets actually read for a solid-fill Rectangle,
    // not because this represents an actual background anywhere.
    toolSeparator: ControlStyle {
        background.color: root._headerBorder
    }
}
