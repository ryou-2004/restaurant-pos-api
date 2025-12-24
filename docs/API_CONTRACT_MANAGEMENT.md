# API Contract Management - Rails と Next.js の型不整合を防ぐ仕組み

## 📋 目的

**RailsのAPIレスポンス** と **Next.jsの期待する型** が不一致になることを防ぎ、以下を実現する：

1. ✅ APIレスポンス構造をコードで自動検証
2. ✅ OpenAPI仕様書を自動生成
3. ✅ TypeScript型定義をOpenAPIから自動生成
4. ✅ フロントエンド・バックエンドの型が常に同期

---

## 🏗️ アーキテクチャ概要

```
┌─────────────────────┐
│  Rails API (Backend) │
│                     │
│  ┌───────────────┐ │
│  │ Serializers   │ │  ← JSONレスポンス生成
│  └───────────────┘ │
│         │           │
│         ▼           │
│  ┌───────────────┐ │
│  │ RSpec Tests   │ │  ← APIテスト + OpenAPI spec生成
│  │ (rswag-specs) │ │
│  └───────────────┘ │
│         │           │
│         ▼           │
│  ┌───────────────┐ │
│  │ OpenAPI JSON  │ │  ← 仕様書（swagger.json）
│  └───────────────┘ │
└─────────┼───────────┘
          │
          │ (自動生成)
          ▼
┌─────────────────────┐
│  TypeScript Types   │  ← openapi-typescript
│  (frontend/types/)  │
└─────────────────────┘
          │
          ▼
┌─────────────────────┐
│  Next.js (Frontend) │
│                     │
│  ┌───────────────┐ │
│  │ API Client    │ │  ← 型安全なfetch
│  └───────────────┘ │
└─────────────────────┘
```

---

## 🛠️ セットアップ手順

### 1. rswag初期化（まだ未実施）

```bash
cd api/
bundle install
rails generate rswag:install
```

**生成されるファイル:**
- `spec/swagger_helper.rb` - OpenAPI設定
- `config/initializers/rswag_api.rb` - Swagger UIルート設定
- `config/initializers/rswag_ui.rb` - UI設定
- `swagger/v1/swagger.yaml` - OpenAPI仕様書（生成先）

### 2. Swagger UIアクセス

```
http://localhost:3000/api-docs
```

ブラウザでAPIドキュメントを確認できる。

### 3. openapi-typescript インストール（フロントエンド側）

```bash
cd front/
pnpm add -D openapi-typescript
```

---

## 📝 運用フロー

### A. 新しいAPIエンドポイント追加時

#### Step 1: Serializerを作成

```ruby
# api/app/serializers/order_serializer.rb
class OrderSerializer
  def initialize(order)
    @order = order
  end

  def as_json(options = {})
    {
      id: @order.id,
      order_number: @order.order_number,
      status: @order.status,
      total_amount: @order.total_amount,
      created_at: @order.created_at
    }
  end
end
```

#### Step 2: Controllerで使用

```ruby
# api/app/controllers/api/store/orders_controller.rb
def index
  @orders = current_tenant.orders
  render json: @orders.map { |order| OrderSerializer.new(order).as_json }
end
```

#### Step 3: RSpec + rswagでAPIテスト作成

```ruby
# api/spec/requests/api/store/orders_spec.rb
require 'swagger_helper'

RSpec.describe 'api/store/orders', type: :request do
  path '/api/store/orders' do
    get 'List orders' do
      tags 'Orders'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'orders found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              order_number: { type: :string },
              status: { type: :string, enum: ['pending', 'cooking', 'ready', 'delivered', 'paid'] },
              total_amount: { type: :integer },
              created_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'order_number', 'status', 'total_amount', 'created_at']
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
        end
      end
    end
  end
end
```

#### Step 4: OpenAPI仕様書を生成

```bash
SWAGGER_DRY_RUN=0 rake rswag:specs:swaggerize
```

`swagger/v1/swagger.json` が生成される。

#### Step 5: TypeScript型を自動生成

```bash
cd front/
pnpm openapi-typescript http://localhost:3000/api-docs/v1/swagger.json -o types/api-schema.ts
```

#### Step 6: フロントエンドで型安全にAPIを呼び出す

```typescript
// front/types/api-schema.ts（自動生成）
export interface paths {
  '/api/store/orders': {
    get: {
      responses: {
        200: {
          content: {
            'application/json': {
              id: number
              order_number: string
              status: 'pending' | 'cooking' | 'ready' | 'delivered' | 'paid'
              total_amount: number
              created_at: string
            }[]
          }
        }
      }
    }
  }
}

// front/lib/api-client.ts
import type { paths } from '@/types/api-schema'

type OrdersResponse = paths['/api/store/orders']['get']['responses']['200']['content']['application/json']

export async function fetchOrders(): Promise<OrdersResponse> {
  const response = await fetch('/api/store/orders', {
    headers: { 'Authorization': `Bearer ${token}` }
  })
  return response.json()
}
```

---

## ✅ これにより防げるバグ

### 1. フィールド名のtypo

```typescript
// ❌ Before: コンパイルエラーなし、実行時にundefined
const orderNum = order.orderNumber  // API は order_number を返す

// ✅ After: コンパイルエラー
const orderNum = order.orderNumber  // TS Error: Property 'orderNumber' does not exist
const orderNum = order.order_number  // OK
```

### 2. ネスト構造の不一致

```typescript
// ❌ Before: 実行時エラー
const items = queue.order_items  // API は queue.order.order_items を返す

// ✅ After: コンパイルエラー
const items = queue.order_items  // TS Error
const items = queue.order.order_items  // OK
```

### 3. Enum値の不一致

```typescript
// ❌ Before: 無効な値を送信してしまう
order.status = 'complete'  // API は 'completed' を期待

// ✅ After: コンパイルエラー
order.status = 'complete'  // TS Error: Type '"complete"' is not assignable to type 'pending' | 'cooking' | 'ready' | 'delivered' | 'paid'
order.status = 'completed'  // OK
```

### 4. 必須フィールドの欠落

```typescript
// ❌ Before: APIリクエストが400エラー
fetch('/api/store/orders', {
  body: JSON.stringify({ table_id: 1 })  // order_items が必須だが忘れている
})

// ✅ After: コンパイルエラー
type CreateOrderRequest = paths['/api/store/orders']['post']['requestBody']['content']['application/json']
const payload: CreateOrderRequest = {
  table_id: 1  // TS Error: Property 'order_items' is missing
}
```

---

## 🎯 現在の状況

### ✅ 完了済み

- [x] Serializer統一（Store名前空間 + 認証系）
- [x] Jbuilder削除（Store名前空間 + 認証系）
- [x] rswag gem追加（Gemfile）
- [x] MenuItemSerializer に `description` 追加（フロントエンド対応）

### 🚧 未完了（次のステップ）

- [ ] `rails g rswag:install` 実行
- [ ] API仕様テストを記述（主要エンドポイント）
  - [ ] GET /api/store/orders
  - [ ] POST /api/store/orders
  - [ ] GET /api/store/kitchen_queues
  - [ ] POST /api/store/auth/login
  - [ ] GET /api/store/menu_items
  - [ ] POST /api/store/payments
- [ ] OpenAPI仕様書生成
- [ ] TypeScript型自動生成スクリプト作成
- [ ] CI/CDでの自動検証（GitHub Actions等）
- [ ] Staff/Tenant名前空間のSerializer化

---

## 📚 参考リンク

- [rswag GitHub](https://github.com/rswag/rswag)
- [OpenAPI Specification](https://swagger.io/specification/)
- [openapi-typescript](https://github.com/drwpow/openapi-typescript)
- [Rails API Best Practices](https://guides.rubyonrails.org/api_app.html)

---

## 🔄 CI/CDでの自動チェック（将来）

```yaml
# .github/workflows/api-contract.yml
name: API Contract Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # バックエンド: OpenAPI仕様書生成
      - name: Generate OpenAPI spec
        run: |
          cd api
          bundle install
          SWAGGER_DRY_RUN=0 rake rswag:specs:swaggerize

      # フロントエンド: TypeScript型生成
      - name: Generate TypeScript types
        run: |
          cd front
          pnpm openapi-typescript ../api/swagger/v1/swagger.json -o types/api-schema.ts

      # TypeScriptコンパイルエラーチェック
      - name: TypeScript check
        run: |
          cd front
          pnpm tsc --noEmit
```

これにより、プルリクエスト時にAPI契約違反を自動検出できる。

---

**最終更新:** 2025年12月24日
**メンテナー:** Development Team
