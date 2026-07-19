xclock
======

[English](README-EN.md)

古典的なX11のxclockに着想を得た、HTML5実装です。

この小さなプロジェクトは、制限の厳しいWindows PC上でも、単純にxclockを使いたかったことから始まりました。

ピクセル単位で完全に同一の複製を目指したものではありません。
元のデザインを尊重しつつ、現在のWindows環境で使いやすい形にした再実装です。

Respect xclock!!

スクリーンショット
------------

![Windows上で動作するxclock](images/screenshot.png)

## Web版

標準（秒針なし）：

https://mattdaimon.github.io/xclock/

秒針あり：

https://mattdaimon.github.io/xclock/?seconds=1

開発について
------------

この小さなプログラムは私が仕様を考え、確認を行い、
実装と文書作成にChatGPTを利用しました。

内容
----

- index.html    メインプログラム
- xclock.ico     アイコン
- xclock.bat     Chromeアプリモード用ランチャー
- README.md      この日本語版README
- README-EN.md   英語版README
- LICENSE.txt    MIT License
- docs/SPEC.md    日本語仕様書
- docs/SPEC-EN.md 英語仕様書


特徴
----

- HTMLファイル1個で動作
- HTML5 CanvasとJavaScriptのみを使用
- 外部ライブラリ不使用
- 標準では秒針のないアナログ時計
- `?seconds=1` でオリジナルxclock風の秒針を表示
- 秒針表示時は1秒ごとのステップ運針
- 秒針表示時は分針が毎秒少し進み、時針は1分ごとに進む
- 次回更新を秒または分の境界に合わせて実行
- Chromeが休止状態から復帰した後に表示時刻を補正
- ウィンドウに合わせて正方形のCanvasを自動調整
- Chromeアプリモード向け
- 専用のChromeユーザーデータディレクトリを使用するため、
  xclockの200×200ピクセルのウィンドウが通常のChromeの
  ウィンドウサイズへ影響しない


インストール
------------

1. xclockフォルダ全体を任意の場所へコピーします。

   例:

     C:\Users\username\AppData\Local\Programs\xclock\

2. 次のファイルを同じフォルダに置いてください。

     - xclock.bat
     - index.html
     - xclock.ico

3. xclock.batをダブルクリックし、時計が開くことを確認します。

バッチファイルは、自身が置かれている場所を基準にindex.htmlを探します。
そのため、xclock.batとindex.htmlを一緒に移動する限り、
フォルダの場所を変更しても動作します。


推奨するショートカット設定
--------------------------

1. xclock.batを右クリックします。
2. 必要に応じて「その他のオプションを確認」を選択します。
3. 「送る」→「デスクトップ（ショートカットを作成）」を選択します。
4. 作成したショートカットのプロパティを開きます。
5. 「ショートカット」タブの「実行時の大きさ」を「最小化」にします。
6. 「アイコンの変更」を選択し、xclockフォルダ内のxclock.icoを指定します。
7. ショートカット名を「xclock」に変更します。

「実行時の大きさ」を「最小化」にすると、xclock起動時に
バッチファイルが使用するコマンドプロンプト画面が目立ちにくくなります。


Chromeプロファイルの分離
------------------------

xclock.batは、次の専用プロファイルフォルダを指定してChromeを起動します。

  %LOCALAPPDATA%\xclock-chrome-profile

これは通常のChromeプロファイルとは別です。
そのため、xclockの200×200ピクセルのウィンドウサイズや位置は、
通常のChromeウィンドウへ影響しません。

専用フォルダは初回起動時に自動作成されます。

xclock専用のChromeプロファイルだけをリセットしたい場合は、
このフォルダを削除できます。削除する前にxclockを終了してください。


スタートアップ
--------------

Windowsへのサインイン時にxclockを自動起動するには:

1. Win + Rを押します。
2. 次を入力します。

     shell:startup

3. xclockのショートカットをスタートアップフォルダへ置きます。

xclock.batそのものを別途コピーするのではなく、ショートカットを置いてください。
これにより、ショートカットの「最小化」設定と指定したアイコンが維持されます。


常に手前に表示
--------------

Windowsには、このHTMLファイルを常に手前に表示する標準機能はありません。

Microsoft PowerToysを利用できます。

  Win + Ctrl + T

xclockのウィンドウをアクティブにした状態で、このショートカットキーを押してください。


設定
----

xclock.batの先頭に、変更しやすい設定項目をまとめています。

  set "WINDOW_WIDTH=200"
  set "WINDOW_HEIGHT=200"
  set "SHOW_SECONDS=0"

別の初期サイズを使用する場合は、`WINDOW_WIDTH` と `WINDOW_HEIGHT` を変更してください。
時計本体は、現在のウィンドウサイズに合わせて再描画されます。

秒針を表示する場合は、次のように変更します。

  set "SHOW_SECONDS=1"

Web版ではURLの末尾に `?seconds=1` を付けます。

  https://mattdaimon.github.io/xclock/?seconds=1

正式な有効値は `1` のみです。パラメータなし、`0`、`true`、その他の値では秒針を表示しません。


Chromeの場所
------------

バッチファイルは、Chromeが次の場所にあることを前提としています。

  C:\Program Files\Google\Chrome\Application\chrome.exe

Chromeを別の場所へインストールしている場合は、
xclock.batのCHROME行を編集してください。


トラブルシューティング
----------------------

1. 「ファイルにアクセスできません」と表示される

   xclock.batとindex.htmlが同じフォルダにあることを確認してください。
   xclock.bat側も変更する場合を除き、index.htmlの名前を変更しないでください。

2. xclockが通常のChromeタブで開く

   すべてのxclockウィンドウを閉じ、xclock.batから再度起動してください。
   専用プロファイルフォルダへ書き込み可能であることも確認してください。

3. 通常のChromeが200×200ピクセルで開く

   xclock.batを使ってxclockを起動していることを確認してください。
   同梱のバッチファイルは専用のChromeユーザーデータディレクトリを使用します。

   通常のChromeウィンドウを希望する大きさへ戻し、そのウィンドウを最後に閉じると、
   Chromeが新しいウィンドウ位置と大きさを保存します。

4. 黒いコマンドプロンプト画面が一瞬表示される

   xclock.batへのショートカットを作成し、前述の手順どおり、
   ショートカットの「実行時の大きさ」を「最小化」にしてください。

5. 日本語などASCII以外の文字を含むユーザー名

   同梱のバッチファイルは、Windowsのローカルパスを自動的に
   file URL形式へ変換します。
   コマンドへユーザー名を直接記述する必要はありません。


ライセンス
----------

MIT Licenseです。LICENSE.txtを参照してください。
