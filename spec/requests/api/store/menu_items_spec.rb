# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Store::MenuItems', type: :request do
  # テスト用データの準備
  let(:tenant) { create(:tenant) }
  let(:store) { create(:store, tenant: tenant) }
  let(:store_user) { create(:tenant_user, tenant: tenant, role: :staff) }
  let(:token) { JWT.encode({ tenant_user_id: store_user.id, user_type: 'store', store_id: store.id, exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  # GET /api/store/menu_items - メニュー一覧取得
  path '/api/store/menu_items' do
    get 'メニュー一覧取得' do
      tags 'Store'
      description '利用可能なメニュー項目の一覧を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'メニュー一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, description: 'メニューID' },
              name: { type: :string, description: 'メニュー名' },
              price: { type: :integer, description: '価格' },
              category: { type: :string, description: 'カテゴリー' },
              available: { type: :boolean, description: '利用可能' }
            },
            required: ['id', 'name', 'price', 'category', 'available']
          }

        let!(:menu_items) { create_list(:menu_item, 3, tenant: tenant, available: true) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(3)
          expect(data.first).to have_key('id')
          expect(data.first).to have_key('name')
        end
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  # GET /api/store/menu_items/:id - メニュー詳細取得
  path '/api/store/menu_items/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'メニューID'

    get 'メニュー詳細取得' do
      tags 'Store'
      description '指定したメニュー項目の詳細情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'メニュー詳細取得成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            price: { type: :integer },
            category: { type: :string },
            available: { type: :boolean }
          },
          required: ['id', 'name', 'price', 'category', 'available']

        let!(:menu_item) { create(:menu_item, tenant: tenant, available: true) }
        let(:id) { menu_item.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(menu_item.id)
          expect(data['name']).to eq(menu_item.name)
        end
      end

      response '404', 'メニューが見つからない' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { 99999 }

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }

        run_test!
      end
    end
  end
end
