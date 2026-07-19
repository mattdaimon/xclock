# xclock 仕様書

## 1. 文書の位置付け

この文書は、HTML5 Canvas版 xclock の設計仕様を記録する。

- 現行版: v1.1.1
- v1.1.0 の秒針機能を維持し、標準表示の分針位置と秒針形状をオリジナル xclock へさらに近づけた
- 本書には v1.1.1 で実装した値と動作を記録する

README は利用者向けの説明を担当し、本書は内部仕様、設計判断、オリジナル xclock との対応関係を担当する。

## 2. プロジェクト概要

X11 の古典的な `xclock` に着想を得た、小型アナログ時計である。

- HTML5 Canvas を使用する
- JavaScript のみで動作する
- 外部ライブラリを使用しない
- 単一 HTML を中心とする小さな構成を維持する
- Chrome のアプリモードでは 200×200 程度の小窓として使用する
- GitHub Pages では通常の Web ページとして提供する

## 3. 設計方針

- オリジナル xclock の外観と動きへ、可能な範囲で寄せる
- オリジナルの C/X11 内部実装をそのまま移植しない
- Canvas で理解しやすく簡潔な描画方法を選ぶ
- 標準表示は秒針なしとする
- 標準表示は秒針なし・1分更新を維持する
- 設定項目を増やしすぎない
- 大規模なクラス化、モジュール分割、処理の二重化を行わない
- 自分が使いやすいことを優先する

## 4. ファイル構成

主要ファイルは次のとおり。

- `index.html`: 時計本体
- `xclock.bat`: Chrome アプリモード起動用
- `xclock.ico`: アイコン
- `README.md`: 日本語 README
- `README-EN.md`: 英語 README
- `LICENSE.txt`: ライセンス
- `images/screenshot.png`: スクリーンショット
- `docs/SPEC.md`: 日本語仕様書
- `docs/SPEC-EN.md`: 英語仕様書

## 5. 共通表示仕様

- 背景色は白
- 描画色は黒
- 文字盤はウィンドウの短辺を基準とする正方形 Canvas 内に描画する
- 時計は常に真円として描画する
- Canvas はウィンドウ中央に配置する
- スクロールバーを表示しない
- ユーザーによる文字選択を無効にする
- 高 DPI 表示へ対応する

### 5.1 Canvas サイズ

`resizeCanvas()` は次を行う。

- `window.innerWidth` と `window.innerHeight` の短い方を CSS 上の一辺とする
- `window.devicePixelRatio` を使用して内部ピクセル数を拡大する
- `ctx.setTransform()` により、以降の座標は CSS ピクセル基準で扱う

## 6. 文字盤仕様

### 6.1 半径

文字盤半径は次の値を使用する。

```javascript
const radius = diameter * 0.46;
```

### 6.2 目盛り

- 目盛りは 60 本
- 5 分ごとの目盛りを長く、太くする
- 1 分目盛りは短く、細くする
- 線端は `butt`

現行値:

```javascript
const outer = radius * 0.985;
const inner = isHour ? radius * 0.900 : radius * 0.945;
```

線幅:

```javascript
isHour
  ? Math.max(1.35, radius * 0.0085)
  : Math.max(1.00, radius * 0.0058);
```

## 7. 時針・分針仕様

### 7.1 形状

- 時針と分針は黒い二等辺三角形
- 先端は尖らせる
- 根元は中心より少し後方へ突き出す
- `drawTriangleHand()` で共通描画する

### 7.2 現行比率

```javascript
// Hour hand
drawTriangleHand(..., radius, 0.40, 0.068);

// Minute hand
drawTriangleHand(..., radius, 0.68, 0.068);
```

後方への突き出し:

```javascript
-radius * 0.075
```

### 7.3 中心円

- 時針・分針の描画後に黒い中心円を描く
- 半径は次の値

```javascript
Math.max(1.5, radius * 0.017)
```

## 8. v1.1.1 の時刻計算

秒針の有無にかかわらず、分針の位置には現在の秒を反映する。これにより、針の位置計算をオリジナル xclock の動作へ合わせる。

```javascript
const seconds = now.getSeconds();
const minutes = now.getMinutes() + seconds / 60;
const hours = (now.getHours() % 12) + now.getMinutes() / 60;
```

- 分針は秒を位置へ反映する
- 時針は分を反映する
- 時針には秒を反映しない
- 秒針なしの場合も、再描画周期は1分のままとする

## 9. v1.0.1 の更新処理

### 9.1 分境界への同期

`setInterval()` は使用せず、次の分境界までの時間を計算して `setTimeout()` を使用する。

```javascript
const delay =
  (60 - now.getSeconds()) * 1000 - now.getMilliseconds();
```

毎回現在時刻から待ち時間を再計算し、タイマーのずれを累積させない。

### 9.2 リサイズ

ウィンドウのリサイズ時は次を行う。

1. Canvas サイズを更新
2. 現在時刻で即時再描画

### 9.3 表示復帰

ページが非表示状態から戻った場合は次を行う。

1. 現在時刻で即時再描画
2. 既存タイマーを解除
3. 次の分境界へタイマーを再設定

## 10. v1.1.0 秒針オプション

### 10.1 有効化方法

正式な URL パラメータは次のとおり。

```text
?seconds=1
```

判定:

- パラメータなし: 秒針なし
- `?seconds=1`: 秒針あり
- `?seconds=0`: 秒針なし
- `?seconds=true`: 秒針なし
- `?seconds=false`: 秒針なし
- その他の値: 秒針なし

実装:

```javascript
const params = new URLSearchParams(window.location.search);
const showSeconds = params.get("seconds") === "1";
```

URL パラメータは文字列として扱われる。正式な有効値を `1` のみに限定し、曖昧な別名は追加しない。

### 10.2 オリジナル xclock との関係

オリジナル xclock は秒針専用の真偽値オプションを持たず、`-update seconds` で更新頻度を指定する。30 秒以下の更新値ではアナログ時計の秒針が有効になる。HTML 版は更新間隔を自由指定する設計にはせず、分かりやすい `seconds=1` を採用する。

## 11. v1.1.0 秒針デザイン

### 11.1 外観

秒針はオリジナル xclock の見た目を参考にし、次の構成とする。

```text
中心 ───────── 細い直線 ───── ◆ ── 短い先端線
```

- 黒い細線
- 先端寄りに黒いひし形
- ひし形は軸を中心に左右対称
- ひし形の先にも短い線を残す
- 赤色は使用しない
- 太い三角形にはしない
- 中心より後方へ目立つ尾は設けない
- 秒針専用の中心装飾は追加しない

### 11.2 Canvas での実装

オリジナルの一体型多頂点ポリゴンは移植しない。

`drawSecondHand()` 内で次を描く。

1. 中心から先端までの直線
2. 直線上の先端寄りに黒いひし形

線はひし形の下を通して先端まで描き、接合部に隙間を作らない。

この方式を採用する理由:

- コードが分かりやすい
- 寸法を調整しやすい
- Canvas らしい実装になる
- 見た目はオリジナルとほぼ同じにできる
- 将来の保守が容易

### 11.3 実装寸法

文字盤半径を `radius` とする。

```javascript
const length = radius * 0.935;
const diamondCenter = radius * 0.80;
const diamondHalfLength = radius * 0.105;
const diamondHalfWidth = radius * 0.045;
const lineWidth = Math.max(1.5, radius * 0.013);
```

- 秒針全長は半径の 93.5%
- ひし形の中心は半径の 80%位置
- ひし形の前後方向の全長は半径の 21%
- ひし形の左右方向の全幅は半径の 9%
- ひし形の前端から秒針先端まで、半径の 3%の線が残る
- 秒針は分針より長い
- 線幅には 1.5 CSS px の下限を設ける

## 12. v1.1.1 の針の動き

秒針の有無にかかわらず、針の位置計算をオリジナル xclock へ寄せる。

### 12.1 秒針

- 1 秒ごとのステップ運針
- 1 秒につき 1 目盛り進む
- ミリ秒を角度へ反映しない
- スムーズ運針にしない

```javascript
const seconds = now.getSeconds();
```

### 12.2 分針

- 秒を位置へ反映する
- 秒針ありでは毎秒わずかに進む
- 秒針なしでは再描画時にその時点の秒を反映する

```javascript
const minutes = now.getMinutes() + now.getSeconds() / 60;
```

### 12.3 時針

- 分を位置へ反映する
- 秒を位置へ反映しない
- 同じ分の間は位置が変わらず、分が変わると 1 分相当進む

```javascript
const hours =
  (now.getHours() % 12) + now.getMinutes() / 60;
```

秒針ありの場合の動作:

```text
秒針: 1 秒ごとに進む
分針: 1 秒ごとにわずかに進む
時針: 1 分ごとにわずかに進む
```

秒針なしの場合の動作:

```text
秒針: 描画しない
分針: 再描画時の秒を含む位置を指す
時針: 分を含む位置を指す
再描画: 分境界ごと
```

## 13. v1.1.1 の更新処理

### 13.1 共通タイマーへの整理

`minuteTimerId` と `scheduleNextMinute()` は、秒・分の両方を扱う名称へ一般化する。

想定名称:

```text
timerId
scheduleNextDraw()
```

### 13.2 秒針あり

次の整数秒境界まで待つ。

```javascript
const delay = 1000 - now.getMilliseconds();
```

タイマー発火後は現在時刻を取得し直すため、遅延が累積しない。

### 13.3 秒針なし

次の分境界まで待つ。分針の位置計算には描画時点の秒を反映するが、再描画周期は1分のままとする。

### 13.4 タイマー余裕値

初期実装では余裕値を追加しない。秒境界直前の発火などが実機で確認された場合のみ、数ミリ秒のマージン追加を検討する。

## 14. v1.1.0 の描画構成

現在の関数構成を維持し、主に次を変更する。

```text
resizeCanvas()
point()
fillPolygon()
drawTicks()
drawTriangleHand()
drawSecondHand()       新規
 drawClock()
scheduleNextDraw()     scheduleNextMinute() を一般化
```

- 秒針あり・なしで時計全体の処理を二重化しない
- 文字盤、目盛り、時針、分針は共通処理を使用する
- `showSeconds` が有効な場合のみ秒針を追加する

概念:

```javascript
drawTicks(...);

if (showSeconds) {
  drawSecondHand(...);
}

drawTriangleHand(...); // Hour hand
drawTriangleHand(...); // Minute hand
```

## 15. 描画順

実装順:

1. 背景
2. 目盛り
3. 秒針
4. 時針
5. 分針
6. 中心円

秒針を時針・分針より先に描き、中心付近を既存の針と中心円で自然に隠す。

描画順は実装後にオリジナル画像と比較し、必要な場合のみ変更する。中心円の寸法は標準表示を変えないため原則変更しない。

## 16. 処理負荷

秒針ありでは 1 分に 1 回から 1 秒に 1 回へ再描画回数が増えるが、対象は 200×200 程度の小さな Canvas である。

毎回の処理は次の程度。

- Canvas のクリア
- 60 本の目盛り
- 3 本の針
- 中心円
- 少数の時刻計算
- 次のタイマー設定

毎秒 60 フレームの連続アニメーションではなく毎秒 1 回の描画であり、実用上の負荷は小さい。`requestAnimationFrame()` は使用しない。

## 17. xclock.bat 仕様

### 17.1 設定項目の整理

変更可能な値をファイル先頭へ用途別にまとめる。

```bat
rem ============================================================
rem xclock display settings
rem ============================================================
set "WINDOW_WIDTH=200"
set "WINDOW_HEIGHT=200"
set "SHOW_SECONDS=0"

rem ============================================================
rem Google Chrome settings
rem ============================================================
set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
set "XCLOCK_PROFILE=%LOCALAPPDATA%\xclock-chrome-profile"

rem ============================================================
rem xclock file settings
rem ============================================================
set "XCLOCK_HTML=%~dp0index.html"
```

設定欄の下に内部処理との区切りを設ける。

```bat
rem ============================================================
rem Internal processing
rem Normally, do not edit below this line
rem ============================================================
```

### 17.2 秒針指定

- `SHOW_SECONDS=1`: 秒針あり
- その他: 秒針なし

秒針ありの場合のみ、クエリ文字列を生成する。

```bat
set "XCLOCK_QUERY="
set "XCLOCK_URL_PATH=%XCLOCK_HTML:\=/%"

if "%SHOW_SECONDS%"=="1" (
  set "XCLOCK_QUERY=?seconds=1"
)
```

### 17.3 ローカル file URL

現在正常に動作している Windows パス変換を維持し、その末尾へクエリ文字列を追加する。

```bat
--app="file:///%XCLOCK_URL_PATH%%XCLOCK_QUERY%"
```

例:

```text
file:///C:/path/to/xclock/index.html?seconds=1
```

Chrome は `index.html` をローカルファイルとして開き、`?seconds=1` をページのクエリ文字列として解釈する。

### 17.4 ウィンドウサイズ

現在の固定値:

```bat
--window-size=200,200
```

を次へ変更する。

```bat
--window-size=%WINDOW_WIDTH%,%WINDOW_HEIGHT%
```

秒針用の別 BAT は作らない。

## 18. ブラウザ運用

### 18.1 Chrome

- ローカル版の正式運用
- `--app` を使用する
- 専用 `user-data-dir` を使用する
- 200×200 程度の小窓として利用する

### 18.2 Firefox

- GitHub Pages 版を通常の Web ページとして表示できる
- 小型アプリウィンドウには最小幅の制約があるため、現時点では Chrome と同じ正式運用にはしない
- Firefox の制約は README には記載しない

## 19. README 更新範囲

v1.1.0 では日本語版・英語版 README に次を追記する。

- 標準では秒針なし
- `?seconds=1` で秒針表示
- 秒針は 1 秒ごとのステップ運針
- BAT では `SHOW_SECONDS=1` を設定
- BAT で幅と高さを変更可能

ひし形の寸法、針の計算式、内部描画方式は README へ記載しない。

## 20. バージョン方針

今回のバージョンは `v1.1.1` とする。

- 秒針のひし形をオリジナル xclock に近づける
- 標準表示でも分針の位置へ秒を反映する
- 標準表示の1分更新と既存の URL/BAT オプションは維持する
- 日本語版・英語版の仕様書を実装へ合わせる

`MAJOR.MINOR.PATCH` の慣例により、既存機能の調整と修正として PATCH を上げる。

```text
v1.1.0 → v1.1.1
```

## 21. 実装後の確認項目

### 21.1 標準表示

- パラメータなしで v1.0.1 と同じ表示
- 秒針なし
- 分境界で更新
- 目盛り、時針、分針、中心円に意図しない変更がない

### 21.2 URL パラメータ

- `?seconds=1` で秒針あり
- `?seconds=0` で秒針なし
- `?seconds=true` で秒針なし
- 不明値で秒針なし

### 21.3 秒針の外観

- 細い直線として見える
- 先端寄りにひし形がある
- ひし形の先に短い線が残る
- 矢じりのように見えすぎない
- 分針より長い
- 200×200 で潰れない
- 高 DPI 環境で線が消えない
- オリジナル xclock に近く見える

### 21.4 針の動き

- 秒針が 1 秒ごとに 1 目盛り進む
- 分針が毎秒わずかに進む
- 時針は同じ分の間は動かない
- 分が変わると時針が進む
- ミリ秒によるスムーズ運針にならない
- 0、15、30、45 秒で正しい方向を指す

### 21.5 タイマーとイベント

- 秒境界へおおむね同期する
- 長時間動作してもずれが累積しない
- 二重タイマーが発生しない
- 非表示から戻ると正しい時刻へ復帰する
- リサイズ後も比率が維持される

### 21.6 BAT

- `SHOW_SECONDS=0` で秒針なし
- `SHOW_SECONDS=1` で秒針あり
- 幅と高さの設定が反映される
- Chrome パス、プロファイル、HTML の場所を変更できる
- ローカル file URL のクエリが正しく渡る
- 既存の Chrome アプリモード起動が維持される

## 22. 既知の調整項目

実装後に最終確定する項目:

- 秒針全長
- 秒針の線幅
- ひし形の位置と縦横比
- ひし形の先に残す線の長さ
- 秒針と他の針の描画順
- 必要な場合のタイマーマージン

これらは仕様漏れではなく、実画面を見ながら決める視覚・実機調整値である。

## 23. 参考資料

- X.Org xclock manual: https://www.x.org/archive/X11R7.5/doc/man/man1/xclock.1.html
- X.Org xclock project: https://gitlab.freedesktop.org/xorg/app/xclock

