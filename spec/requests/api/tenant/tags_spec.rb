# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Tenant::Tags', type: :request do
  # テスト用データの準備
  let(:tenant) { create(:tenant) }
  let(:owner_user) { create(:tenant_user, :owner, tenant: tenant) }
  let(:manager_user) { create(:tenant_user, :manager, tenant: tenant) }
  let(:token) { JWT.encode({ tenant_user_id: manager_user.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  # GET /api/tenant/tags - タグ一覧取得
  path '/api/tenant/tags' do
    get 'タグ一覧取得' do
      tags 'Tenant'
      description 'テナントに紐づくタグの一覧を取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'タグ一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, description: 'タグID' },
              name: { type: :string, description: 'タグ名' },
              created_at: { type: :string, format: 'date-time', description: '作成日時' },
              updated_at: { type: :string, format: 'date-time', description: '更新日時' }
            },
            required: ['id', 'name', 'created_at', 'updated_at']
          }

        let!(:tag1) { create(:tag, tenant: tenant, name: '店長') }
        let!(:tag2) { create(:tag, tenant: tenant, name: 'エリアマネージャー') }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(2)
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

  # POST /api/tenant/tags - タグ作成
  path '/api/tenant/tags' do
    post 'タグ作成' do
      tags 'Tenant'
      description '新しいタグを作成します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :tag_params, in: :body, schema: {
        type: :object,
        properties: {
          tag: {
            type: :object,
            properties: {
              name: { type: :string, description: 'タグ名' }
            },
            required: ['name']
          }
        },
        required: ['tag']
      }

      response '201', 'タグ作成成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'created_at', 'updated_at']

        let(:tag_params) do
          {
            tag: {
              name: '店長'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('店長')
        end
      end

      response '422', 'バリデーションエラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:tag_params) do
          {
            tag: {
              name: ''
            }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:tag_params) do
          {
            tag: { name: '店長' }
          }
        end

        run_test!
      end
    end
  end

  # GET /api/tenant/tags/:id - タグ詳細取得
  path '/api/tenant/tags/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'タグID'

    get 'タグ詳細取得' do
      tags 'Tenant'
      description '指定したタグの詳細情報を取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'タグ詳細取得成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'created_at', 'updated_at']

        let!(:tag) { create(:tag, tenant: tenant, name: '店長') }
        let(:id) { tag.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(tag.id)
          expect(data['name']).to eq('店長')
        end
      end

      response '404', 'タグが見つからない' do
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

  # PATCH /api/tenant/tags/:id - タグ更新
  path '/api/tenant/tags/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'タグID'

    patch 'タグ更新' do
      tags 'Tenant'
      description '指定したタグの情報を更新します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :tag_params, in: :body, schema: {
        type: :object,
        properties: {
          tag: {
            type: :object,
            properties: {
              name: { type: :string, description: 'タグ名' }
            }
          }
        },
        required: ['tag']
      }

      response '200', 'タグ更新成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'created_at', 'updated_at']

        let!(:tag) { create(:tag, tenant: tenant, name: '旧タグ名') }
        let(:id) { tag.id }
        let(:tag_params) do
          {
            tag: {
              name: '新タグ名'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('新タグ名')
        end
      end

      response '404', 'タグが見つからない' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { 99999 }
        let(:tag_params) do
          {
            tag: { name: '新タグ名' }
          }
        end

        run_test!
      end

      response '422', 'バリデーションエラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let!(:tag) { create(:tag, tenant: tenant, name: '旧タグ名') }
        let(:id) { tag.id }
        let(:tag_params) do
          {
            tag: { name: '' }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }
        let(:tag_params) do
          {
            tag: { name: '新タグ名' }
          }
        end

        run_test!
      end
    end
  end

  # DELETE /api/tenant/tags/:id - タグ削除
  path '/api/tenant/tags/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'タグID'

    delete 'タグ削除' do
      tags 'Tenant'
      description '指定したタグを削除します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '204', 'タグ削除成功' do
        let!(:tag) { create(:tag, tenant: tenant, name: '削除対象') }
        let(:id) { tag.id }

        run_test! do
          expect(Tag.exists?(id)).to be false
        end
      end

      response '404', 'タグが見つからない' do
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
