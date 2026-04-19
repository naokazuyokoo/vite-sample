# Vite Sample Theme

WordPress テーマで Vite を使う最小サンプルです。

新規テーマの土台としても使えますが、主な狙いは「既存の WordPress テーマに Vite を後付けするときの最小構成」を読める形で示すことです。

## 既存テーマに組み込む場合

既存テーマへ追加する場合は、テーマ直下に `vite/` ディレクトリをコピーし、既存テーマの `functions.php` から `vite/vite.php` を読み込みます。

```php
require_once get_theme_file_path('/vite/vite.php');
```

このサンプルは既存テンプレート構造の置き換えを前提にしていません。`header.php`、`footer.php`、`template-parts/` などはそのままにして、Vite で管理したい JS / Sass の entry point を `vite/src/main.js` から追加していく想定です。

後付け専用ではないため、サンプルテーマとしてそのまま有効化して動作確認することもできます。

## bootstrap.sh でセットアップ（推奨）

`bootstrap.sh` は、対話式（`y/n`）で 1 ステップずつ確認しながら実行します。

実行コマンド:

```bash
cd wp-content/themes/vite-sample/vite
```

```bash
./bootstrap.sh
```

実行される主な処理:

1. `brew` のインストール（未導入時）
2. `brew install fnm`
3. `~/.zshrc` へ `fnm` 設定の追記（重複防止）
4. Node.js LTS の導入（`node` 未導入時）
5. `npm install`
6. `npm run dev`

補足（`~/.zshrc` の反映範囲）:

- `bootstrap.sh` の最後で実行される `zsh -ic 'source ~/.zshrc'` は、子プロセスの zsh にだけ反映されます。
- そのため、現在開いているターミナル（親シェル）に反映したい場合は、ユーザー側で `source ~/.zshrc` を実行するか、ターミナルを再起動してください。

## 手動セットアップ（コピペ実行）

1. Vite ディレクトリへ移動

```bash
cd /path/to/theme/vite
```

2. Homebrew インストール（未導入の場合）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. `brew` をシェルで有効化

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
```

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

4. `fnm` をインストール

```bash
brew install fnm
```

5. `fnm` 設定を `~/.zshrc` に追加

```bash
echo 'eval "$(fnm env --use-on-cd --shell zsh)"' >> ~/.zshrc
```

6. 現在のシェルで `fnm` を有効化

```bash
eval "$(fnm env --shell zsh)"
```

7. Node.js LTS をインストールして有効化

```bash
fnm install --lts
```

```bash
fnm default lts-latest
```

```bash
fnm use lts-latest
```

8. 依存関係をインストール

```bash
npm install
```

9. 本番ビルド

```bash
npm run build
```

## 開発

```bash
npm run dev
```

`npm run dev` 実行前に `wp option get home` からホスト名を取得し、`.env.local` の `VITE_DEV_SERVER_HOST` を自動更新します（`wp` コマンドが使える環境が前提）。

`npm run dev` では `VITE ready` 後に WordPress URL を自動でブラウザ起動します。

`npm run dev` 実行中は `vite/.hot` を使って Vite 開発サーバーを読み込みます。

## 本番ビルド

```bash
npm run build
```

`vite/dist/.vite/manifest.json` を読み込み、ビルド済み JS/CSS を enqueue します。
