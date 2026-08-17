ayamerc

ButtonGroup

- ayame-settings(ウィンドウ装飾KCM)へのUI追加は今回のスコープ外。
Cettilaの設定画面だけにUIを置く。新クレートayame-colorsは依存関係として素
直に再利用できる形にしておくが、ayame-settings側の配線は別タスク。
- ThemeSettingsRustの起動時シード漏れは既存の別バグ、今回は据え置き。
ThemeSettingsRust::default()は常にmode: "auto"から始まり、実際にディスク
から読んだ値を反映しない(表示上のズレのみで、起動時の実パレット適用自体は
apply_saved_theme_mode()経由で正しい)。accentもこのバグを同じ形で継承す
る。直すにはqml6がorigami-configに依存する新しい層構造が要り、今回の頼ま
れた範囲を超えるため据え置く。


- ライブプレビュー
  - Stylekit非対応
- qml type compiler
  - Tech Preview更新待ち。
  - cxx-qt 対応
