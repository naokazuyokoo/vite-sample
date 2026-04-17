# Vite Sample Theme

WordPress テーマで Vite を使う最小サンプルです。

## セットアップ

```bash
cd wp-content/themes/vite-sample
npm install
```

## 開発

```bash
npm run dev
```

`npm run dev` 実行中は `.hot` を使って Vite 開発サーバーを読み込みます。

## 本番ビルド

```bash
npm run build
```

`dist/.vite/manifest.json` を読み込み、ビルド済み JS/CSS を enqueue します。
