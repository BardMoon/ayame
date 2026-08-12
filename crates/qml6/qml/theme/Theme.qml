pragma Singleton
import QtQuick

// Kirigami.Themeの代替。QtQuick標準のSystemPalette(実行中のQQC2スタイル
// -- 通常org.kde.breeze -- が設定するQPaletteをそのまま反映し、ライト/
// ダーク切り替えにも自動追従する)を唯一の色ソースとする。
//
// Kirigamiの「colorSet」(Window/View/Header/Tooltip等、部分木ごとに
// 異なる配色を割り当てる仕組み)は、cxx-qt 0.9.1にQML attached property
// を生成する機構が無いため、同じ形では再現しない。代わりに
// paletteFor(set)が呼ばれた時点のパレットをプレーンなオブジェクトとして
// 返す。呼び出し側は各コンポーネントのルートで
//
//   readonly property var colors: Theme.paletteFor(Theme.header)
//
// のように一度だけ取得し、子要素からは`root.colors.backgroundColor`の
// ように参照する(Kirigamiのような自動継承はない。祖先が設定した
// colorSetを子が暗黙に読むことはできないので、必要な範囲ごとに明示的に
// 取得すること)。
//
// 各colorSetの対応はQPaletteのロールによる近似であり、Breezeの実際の
// カラースキームファイル(KColorScheme由来)とピクセル単位で一致する
// わけではない。
QtObject {
    id: theme

    readonly property SystemPalette _palette: SystemPalette {
        colorGroup: SystemPalette.Active
    }

    // QMLのプロパティ名は大文字始まりにできないため、Kirigami.Theme.Window
    // のような命名はできず、小文字始まりにする(呼び出し側はTheme.window
    // のように参照する)。
    readonly property int window: 0
    readonly property int view: 1
    readonly property int header: 2
    readonly property int tooltip: 3

    // Kirigamiのセマンティックカラー相当。QPaletteに対応するロールが
    // 無いため固定値。
    readonly property color positiveTextColor: "#27ae60"
    readonly property color negativeTextColor: "#da4453"
    readonly property color neutralTextColor: "#f67400"

    function paletteFor(set) {
        var pal = theme._palette;
        var backgroundColor = pal.window;
        var textColor = pal.windowText;

        if (set === theme.view) {
            backgroundColor = pal.base;
            textColor = pal.text;
        } else if (set === theme.header) {
            backgroundColor = pal.button;
            textColor = pal.buttonText;
        } else if (set === theme.tooltip) {
            backgroundColor = pal.light;
            textColor = pal.windowText;
        }

        return {
            backgroundColor: backgroundColor,
            textColor: textColor,
            highlightColor: pal.highlight,
            highlightedTextColor: pal.highlightedText,
            hoverColor: Qt.rgba(pal.highlight.r, pal.highlight.g, pal.highlight.b, 0.15),
            positiveTextColor: theme.positiveTextColor,
            negativeTextColor: theme.negativeTextColor,
            neutralTextColor: theme.neutralTextColor
        };
    }
}
