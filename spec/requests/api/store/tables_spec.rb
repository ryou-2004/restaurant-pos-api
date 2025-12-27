# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Store::Tables', type: :request do
  # テスト用データの準備
  let(:tenant) { create(:tenant) }
  let(:store) { create(:store, tenant: tenant) }
  let(:store_user) { create(:tenant_user, tenant: tenant, role: :staff) }
  let(:token) { JWT.encode({ tenant_user_id: store_user.id, user_type: 'store', store_id: store.id, exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  # GET /api/store/tables - テーブル一覧取得
  path '/api/store/tables' do
    get 'テーブル一覧取得' do
      tags 'Store'
      description '店舗のテーブル一覧を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'テーブル一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, description: 'テーブルID' },
              number: { type: :string, description: 'テーブル番号' },
              capacity: { type: :integer, description: '収容人数' },
              status: { type: :string, enum: ['available', 'occupied', 'reserved', 'cleaning'], description: 'ステータス' },
              qr_code: { type: :string, description: 'QRコード' }
            },
            required: ['id', 'number', 'capacity', 'status']
          }

        let!(:tables) { create_list(:table, 3, tenant: tenant, store: store) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(3)
          expect(data.first).to have_key('id')
          expect(data.first).to have_key('number')
        end
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  # GET /api/store/tables/:id - テーブル詳細取得
  path '/api/store/tables/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'テーブルID'

    get 'テーブル詳細取得' do
      tags 'Store'
      description '指定したテーブルの詳細情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'テーブル詳細取得成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            number: { type: :string },
            capacity: { type: :integer },
            status: { type: :string },
            qr_code: { type: :string }
          },
          required: ['id', 'number', 'capacity', 'status']

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
end
