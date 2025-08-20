## 1. Google Cloud Consoleでの準備
まず、APIキーを取得してYouTube Data APIを使えるようにする必要があります。

Google Cloud Consoleにアクセスし、ログインします。

新しいプロジェクトを作成します。

左上のメニューから「APIとサービス」→「ライブラリ」を選択します。

検索バーで 「YouTube Data API v3」 を検索し、「有効にする」をクリックします。

左側のメニューで「APIとサービス」→**「認証情報」**を選択します。

「認証情報を作成」をクリックし、「APIキー」を選択してキーを生成します。

生成されたAPIキーは後でコードに貼り付けるため、メモしておいてください。

## 2.チャンネルIDの取得
まず、ご自身のチャンネルIDが必要です。YouTube Studioにアクセスし、左メニューの「設定」→「チャンネル」→「詳細設定」から確認できます。通常、UCで始まる英数字の文字列です。

## 3.Pythonでの実装

Pythonがインストールされていない場合は、まずインストールしてください。次に、以下のライブラリをインストールします。

pip install google-api-python-client pandas

Pythonコードを、メモ帳などで get_comments.py のようなファイル名で保存し、実行します。

python get_comments.py
