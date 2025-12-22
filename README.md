# Restaurant POS API

飲食店向けマルチテナント対応POSシステムのバックエンドAPIです。

## 技術スタック

- **Ruby**: 3.3+
- **Rails**: 8.0
- **Database**: PostgreSQL 16+
- **Authentication**: JWT
- **Real-time**: Action Cable (WebSocket)

## セットアップ

### 1. 依存関係のインストール

```bash
bundle install
```

### 2. データベース作成

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 3. 開発サーバー起動

```bash
rails server
# => http://localhost:3000
```

## 環境変数

`.env`ファイルを作成して以下の環境変数を設定：

```bash
# データベース
DB_USERNAME=postgres
DB_PASSWORD=

# CORS
ALLOWED_ORIGINS=http://localhost:3001

# JWT Secret
JWT_SECRET=your_secret_key_here
```

## API エンドポイント

### 認証
- `POST /api/v1/auth/login` - ログイン
- `POST /api/v1/auth/logout` - ログアウト

### 注文管理
- `GET /api/v1/orders` - 注文一覧
- `POST /api/v1/orders` - 注文作成
- `GET /api/v1/orders/:id` - 注文詳細
- `PATCH /api/v1/orders/:id` - 注文更新
- `POST /api/v1/orders/:id/start_cooking` - 調理開始
- `POST /api/v1/orders/:id/mark_ready` - 調理完了
- `POST /api/v1/orders/:id/deliver` - 配膳完了

### 厨房管理
- `GET /api/v1/kitchen/queues` - 厨房キュー一覧

### 会計
- `POST /api/v1/payments` - 会計処理

## テスト

```bash
bundle exec rspec
```

## コード品質チェック

```bash
bundle exec rubocop
```

## マルチテナント設計

- すべてのモデルは `tenant_id` を持つ
- リクエストごとに `Current.tenant` でテナントコンテキストを設定
- テナント間のデータ分離を保証

## プラン別機能

| プラン | リアルタイム性 | 主要機能 |
|--------|--------------|---------|
| ベーシック | 手動リロード | 基本的な注文・会計フロー |
| スタンダード | 3-5秒自動更新 | + メニュー管理、売上分析 |
| エンタープライズ | WebSocketリアルタイム | + 顧客管理、在庫管理 |
