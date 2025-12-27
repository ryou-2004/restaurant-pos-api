# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Tenant::MenuItems', type: :request do
  let(:tenant) { create(:tenant) }
  let(:manager_user) { create(:tenant_user, :manager, tenant: tenant) }
  let(:token) { JWT.encode({ tenant_user_id: manager_user.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/tenant/menu_items' do
    get 'メニュー一覧取得' do
      tags 'Tenant'
      description 'テナントのメニュー一覧を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'ページ番号'

      response '200', 'メニュー一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              price: { type: :integer },
              category: { type: :string, nullable: true },
              available: { type: :boolean },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'name', 'price', 'available', 'created_at', 'updated_at']
          }

        run_test!
      end
    end

    post 'メニュー作成' do
      tags 'Tenant'
      description '新しいメニューを作成します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :menu_item_params, in: :body, schema: {
        type: :object,
        properties: {
          menu_item: {
            type: :object,
            properties: {
              name: { type: :string },
              price: { type: :integer },
              category: { type: :string },
              available: { type: :boolean, default: true }
            },
            required: ['name', 'price']
          }
        },
        required: ['menu_item']
      }

      response '201', 'メニュー作成成功' do
        let(:menu_item_params) { { menu_item: { name: 'ラーメン', price: 800, category: '麺類' } } }
        run_test!
      end

      response '422', 'バリデーションエラー' do
        let(:menu_item_params) { { menu_item: { name: '', price: -100 } } }
        run_test!
      end
    end
  end

  path '/api/tenant/menu_items/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'メニュー詳細取得' do
      tags 'Tenant'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'メニュー詳細取得成功' do
        let(:id) { create(:menu_item, tenant: tenant).id }
        run_test!
      end

      response '404', 'メニューが見つからない' do
        let(:id) { 99999 }
        run_test!
      end
    end

    patch 'メニュー更新' do
      tags 'Tenant'
      security [{ Bearer: [] }]
      consumes 'application/json'

      parameter name: :menu_item_params, in: :body, schema: {
        type: :object,
        properties: {
          menu_item: {
            type: :object,
            properties: {
              name: { type: :string },
              price: { type: :integer },
              category: { type: :string },
              available: { type: :boolean }
            }
          }
        }
      }

      response '200', 'メニュー更新成功' do
        let(:id) { create(:menu_item, tenant: tenant).id }
        let(:menu_item_params) { { menu_item: { name: '新ラーメン', price: 900 } } }
        run_test!
      end
    end

    delete 'メニュー削除' do
      tags 'Tenant'
      security [{ Bearer: [] }]

      response '204', 'メニュー削除成功' do
        let(:id) { create(:menu_item, tenant: tenant).id }
        run_test!
      end
    end
  end
end
