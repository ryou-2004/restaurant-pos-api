# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Swagger仕様の設定
  config.openapi_root = Rails.root.join('swagger').to_s

  # OpenAPI 3.0仕様定義
  config.openapi_specs = {
    'v1/swagger.json' => {
      openapi: '3.0.3',
      info: {
        title: 'Restaurant POS API',
        version: 'v1',
        description: '飲食店向けマルチテナント対応POSシステムのAPI仕様'
      },
      servers: [
        {
          url: 'http://localhost:3000',
          description: '開発環境'
        }
      ],
      components: {
        # 認証スキーマ定義
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT トークンによる認証。ログインAPIで取得したトークンを使用。'
          }
        },
        # 共通スキーマ定義
        schemas: {
          # エラーレスポンス
          ErrorResponse: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string },
                description: 'エラーメッセージの配列'
              }
            },
            required: ['errors']
          },
          # ページネーション情報（将来の拡張用）
          PaginationMeta: {
            type: :object,
            properties: {
              current_page: { type: :integer },
              total_pages: { type: :integer },
              total_count: { type: :integer },
              per_page: { type: :integer }
            }
          }
        }
      },
      # タグ定義（APIのグループ化）
      tags: [
        {
          name: 'Tenant',
          description: 'テナント管理者向けAPI（店舗オーナー・マネージャー用）'
        },
        {
          name: 'Store',
          description: '店舗POS向けAPI（注文・調理・会計管理）'
        },
        {
          name: 'Staff',
          description: 'システム管理者向けAPI（テナント管理・プラン管理）'
        }
      ]
    }
  }

  # API仕様生成時のデフォルト設定
  config.openapi_format = :json
  config.openapi_strict_schema_validation = true
end
