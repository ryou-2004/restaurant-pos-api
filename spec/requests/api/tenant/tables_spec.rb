# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Tenant::Tables', type: :request do
  # テスト用データの準備
  let(:tenant) { create(:tenant) }
  let(:manager_user) { create(:tenant_user, tenant: tenant, role: :manager) }
  let(:token) { JWT.encode({ tenant_user_id: manager_user.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }
  let(:store) { create(:store, tenant: tenant) }

  # GET /api/tenant/tables - テーブル一覧取得
  path '/api/tenant/tables' do
    get 'テーブル一覧取得' do
      tags 'Tenant'
      description 'テナントに紐づくテーブルの一覧を取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'テーブル一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, description: 'テーブルID' },
              store_id: { type: :integer, description: '店舗ID' },
              store_name: { type: :string, description: '店舗名' },
              number: { type: :string, description: 'テーブル番号' },
              capacity: { type: :integer, description: '収容人数' },
              status: { type: :string, enum: ['available', 'occupied', 'reserved', 'cleaning'], description: 'ステータス' },
              qr_code: { type: :string, description: 'QRコード' },
              created_at: { type: :string, format: 'date-time', description: '作成日時' },
              updated_at: { type: :string, format: 'date-time', description: '更新日時' }
            },
            required: ['id', 'store_id', 'store_name', 'number', 'capacity', 'status', 'created_at', 'updated_at']
          }

        let!(:tables) { create_list(:table, 3, tenant: tenant, store: store) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(3)
          expect(data.first).to have_key('id')
          expect(data.first).to have_key('store_name')
        end
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  # POST /api/tenant/tables - テーブル作成
  path '/api/tenant/tables' do
    post 'テーブル作成' do
      tags 'Tenant'
      description '新しいテーブルを作成します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :table_params, in: :body, schema: {
        type: :object,
        properties: {
          table: {
            type: :object,
            properties: {
              store_id: { type: :integer, description: '店舗ID' },
              number: { type: :string, description: 'テーブル番号' },
              capacity: { type: :integer, description: '収容人数' },
              status: { type: :string, enum: ['available', 'occupied', 'reserved', 'cleaning'], description: 'ステータス' }
            },
            required: ['store_id', 'number']
          }
        },
        required: ['table']
      }

      response '201', 'テーブル作成成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            store_id: { type: :integer },
            store_name: { type: :string },
            number: { type: :string },
            capacity: { type: :integer },
            status: { type: :string },
            qr_code: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'store_id', 'store_name', 'number', 'capacity', 'status', 'created_at', 'updated_at']

        let(:table_params) do
          {
            table: {
              store_id: store.id,
              number: 'T1',
              capacity: 4,
              status: 'available'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['number']).to eq('T1')
          expect(data['capacity']).to eq(4)
          expect(data['qr_code']).to be_present
        end
      end

      response '422', 'バリデーションエラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:table_params) do
          {
            table: {
              store_id: store.id,
              number: '' # 必須項目が空
            }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:table_params) do
          {
            table: { store_id: store.id, number: 'T1' }
          }
        end

        run_test!
      end
    end
  end

  # GET /api/tenant/tables/:id - テーブル詳細取得
  path '/api/tenant/tables/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'テーブルID'

    get 'テーブル詳細取得' do
      tags 'Tenant'
      description '指定したテーブルの詳細情報を取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'テーブル詳細取得成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            store_id: { type: :integer },
            store_name: { type: :string },
            number: { type: :string },
            capacity: { type: :integer },
            status: { type: :string },
            qr_code: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'store_id', 'store_name', 'number', 'capacity', 'status', 'created_at', 'updated_at']

        let!(:table) { create(:table, tenant: tenant, store: store) }
        let(:id) { table.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(table.id)
          expect(data['number']).to eq(table.number)
        end
      end

      response '404', 'テーブルが見つからない' do
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

  # PATCH /api/tenant/tables/:id - テーブル更新
  path '/api/tenant/tables/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'テーブルID'

    patch 'テーブル更新' do
      tags 'Tenant'
      description '指定したテーブルの情報を更新します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :table_params, in: :body, schema: {
        type: :object,
        properties: {
          table: {
            type: :object,
            properties: {
              number: { type: :string, description: 'テーブル番号' },
              capacity: { type: :integer, description: '収容人数' },
              status: { type: :string, enum: ['available', 'occupied', 'reserved', 'cleaning'], description: 'ステータス' }
            }
          }
        },
        required: ['table']
      }

      response '200', 'テーブル更新成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            store_id: { type: :integer },
            store_name: { type: :string },
            number: { type: :string },
            capacity: { type: :integer },
            status: { type: :string },
            qr_code: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'store_id', 'store_name', 'number', 'capacity', 'status', 'created_at', 'updated_at']

        let!(:table) { create(:table, tenant: tenant, store: store, number: 'T1') }
        let(:id) { table.id }
        let(:table_params) do
          {
            table: {
              number: 'T2',
              capacity: 6,
              status: 'occupied'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['number']).to eq('T2')
          expect(data['capacity']).to eq(6)
          expect(data['status']).to eq('occupied')
        end
      end

      response '404', 'テーブルが見つからない' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { 99999 }
        let(:table_params) do
          {
            table: { number: 'T2' }
          }
        end

        run_test!
      end

      response '422', 'バリデーションエラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let!(:table) { create(:table, tenant: tenant, store: store) }
        let(:id) { table.id }
        let(:table_params) do
          {
            table: { number: '' }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }
        let(:table_params) do
          {
            table: { number: 'T2' }
          }
        end

        run_test!
      end
    end
  end

  # DELETE /api/tenant/tables/:id - テーブル削除
  path '/api/tenant/tables/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'テーブルID'

    delete 'テーブル削除' do
      tags 'Tenant'
      description '指定したテーブルを削除します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '204', 'テーブル削除成功' do
        let!(:table) { create(:table, tenant: tenant, store: store) }
        let(:id) { table.id }

        run_test! do
          expect(Table.exists?(id)).to be false
        end
      end

      response '404', 'テーブルが見つからない' do
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
