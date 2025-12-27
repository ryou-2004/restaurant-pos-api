# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Tenant::Stores', type: :request do
  # テスト用データの準備
  let(:tenant) { create(:tenant) }
  let(:owner_user) { create(:tenant_user, tenant: tenant, role: :owner) }
  let(:manager_user) { create(:tenant_user, tenant: tenant, role: :manager) }
  let(:staff_user) { create(:tenant_user, tenant: tenant, role: :staff) }
  let(:token) { JWT.encode({ tenant_user_id: manager_user.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  # GET /api/tenant/stores - 店舗一覧取得
  path '/api/tenant/stores' do
    get '店舗一覧取得' do
      tags 'Tenant'
      description 'テナントに紐づく店舗の一覧を取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '店舗一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, description: '店舗ID' },
              name: { type: :string, description: '店舗名' },
              address: { type: :string, nullable: true, description: '住所' },
              phone: { type: :string, nullable: true, description: '電話番号' },
              active: { type: :boolean, description: '有効/無効' },
              created_at: { type: :string, format: 'date-time', description: '作成日時' },
              updated_at: { type: :string, format: 'date-time', description: '更新日時' }
            },
            required: ['id', 'name', 'active', 'created_at', 'updated_at']
          }

        let!(:stores) { create_list(:store, 3, tenant: tenant) }

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

  # POST /api/tenant/stores - 店舗作成
  path '/api/tenant/stores' do
    post '店舗作成' do
      tags 'Tenant'
      description '新しい店舗を作成します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :store_params, in: :body, schema: {
        type: :object,
        properties: {
          store: {
            type: :object,
            properties: {
              name: { type: :string, description: '店舗名' },
              address: { type: :string, description: '住所' },
              phone: { type: :string, description: '電話番号' },
              active: { type: :boolean, description: '有効/無効', default: true }
            },
            required: ['name']
          }
        },
        required: ['store']
      }

      response '201', '店舗作成成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            address: { type: :string, nullable: true },
            phone: { type: :string, nullable: true },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'active', 'created_at', 'updated_at']

        let(:store_params) do
          {
            store: {
              name: '渋谷店',
              address: '東京都渋谷区',
              phone: '03-1234-5678',
              active: true
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('渋谷店')
          expect(data['address']).to eq('東京都渋谷区')
        end
      end

      response '422', 'バリデーションエラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:store_params) do
          {
            store: {
              name: '' # 必須項目が空
            }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:store_params) do
          {
            store: { name: '渋谷店' }
          }
        end

        run_test!
      end
    end
  end

  # GET /api/tenant/stores/:id - 店舗詳細取得
  path '/api/tenant/stores/{id}' do
    parameter name: :id, in: :path, type: :integer, description: '店舗ID'

    get '店舗詳細取得' do
      tags 'Tenant'
      description '指定した店舗の詳細情報を取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '店舗詳細取得成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            address: { type: :string, nullable: true },
            phone: { type: :string, nullable: true },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'active', 'created_at', 'updated_at']

        let!(:store) { create(:store, tenant: tenant) }
        let(:id) { store.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(store.id)
          expect(data['name']).to eq(store.name)
        end
      end

      response '404', '店舗が見つからない' do
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

  # PATCH /api/tenant/stores/:id - 店舗更新
  path '/api/tenant/stores/{id}' do
    parameter name: :id, in: :path, type: :integer, description: '店舗ID'

    patch '店舗更新' do
      tags 'Tenant'
      description '指定した店舗の情報を更新します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :store_params, in: :body, schema: {
        type: :object,
        properties: {
          store: {
            type: :object,
            properties: {
              name: { type: :string, description: '店舗名' },
              address: { type: :string, description: '住所' },
              phone: { type: :string, description: '電話番号' },
              active: { type: :boolean, description: '有効/無効' }
            }
          }
        },
        required: ['store']
      }

      response '200', '店舗更新成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            address: { type: :string, nullable: true },
            phone: { type: :string, nullable: true },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'active', 'created_at', 'updated_at']

        let!(:store) { create(:store, tenant: tenant, name: '旧店舗名') }
        let(:id) { store.id }
        let(:store_params) do
          {
            store: {
              name: '新店舗名',
              active: false
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('新店舗名')
          expect(data['active']).to be false
        end
      end

      response '404', '店舗が見つからない' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { 99999 }
        let(:store_params) do
          {
            store: { name: '新店舗名' }
          }
        end

        run_test!
      end

      response '422', 'バリデーションエラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let!(:store) { create(:store, tenant: tenant) }
        let(:id) { store.id }
        let(:store_params) do
          {
            store: { name: '' }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }
        let(:store_params) do
          {
            store: { name: '新店舗名' }
          }
        end

        run_test!
      end
    end
  end

  # DELETE /api/tenant/stores/:id - 店舗削除
  path '/api/tenant/stores/{id}' do
    parameter name: :id, in: :path, type: :integer, description: '店舗ID'

    delete '店舗削除' do
      tags 'Tenant'
      description '指定した店舗を削除します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '204', '店舗削除成功' do
        let!(:store) { create(:store, tenant: tenant) }
        let(:id) { store.id }

        run_test! do
          expect(Store.exists?(id)).to be false
        end
      end

      response '404', '店舗が見つからない' do
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
