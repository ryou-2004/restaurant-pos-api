# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Tenant::Users', type: :request do
  # テスト用データの準備
  let(:tenant) { create(:tenant) }
  let(:owner_user) { create(:tenant_user, :owner, tenant: tenant) }
  let(:manager_user) { create(:tenant_user, :manager, tenant: tenant) }
  let(:token) { JWT.encode({ tenant_user_id: owner_user.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  # GET /api/tenant/users - ユーザー一覧取得
  path '/api/tenant/users' do
    get 'ユーザー一覧取得' do
      tags 'Tenant'
      description 'テナントに紐づくユーザーの一覧を取得します。全てのロールで閲覧可能です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'ユーザー一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, description: 'ユーザーID' },
              name: { type: :string, description: 'ユーザー名' },
              email: { type: :string, description: 'メールアドレス' },
              role: {
                type: :string,
                enum: ['owner', 'manager', 'staff', 'kitchen_staff', 'cashier'],
                description: 'ロール'
              },
              tags: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string }
                  }
                },
                description: 'タグ一覧'
              },
              created_at: { type: :string, format: 'date-time', description: '作成日時' },
              updated_at: { type: :string, format: 'date-time', description: '更新日時' }
            },
            required: ['id', 'name', 'email', 'role', 'created_at', 'updated_at']
          }

        let!(:users) { create_list(:tenant_user, 3, tenant: tenant) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to be >= 1
          expect(data.first).to have_key('id')
          expect(data.first).to have_key('role')
        end
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  # POST /api/tenant/users - ユーザー作成
  path '/api/tenant/users' do
    post 'ユーザー作成' do
      tags 'Tenant'
      description '新しいユーザーを作成します。owner権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, description: 'ユーザー名' },
              email: { type: :string, description: 'メールアドレス' },
              password: { type: :string, description: 'パスワード (8文字以上)' },
              role: {
                type: :string,
                enum: ['owner', 'manager', 'staff', 'kitchen_staff', 'cashier'],
                description: 'ロール'
              },
              tag_ids: {
                type: :array,
                items: { type: :integer },
                description: 'タグIDの配列'
              }
            },
            required: ['name', 'email', 'role']
          }
        },
        required: ['user']
      }

      response '201', 'ユーザー作成成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            email: { type: :string },
            role: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'email', 'role', 'created_at', 'updated_at']

        let(:user_params) do
          {
            user: {
              name: '山田太郎',
              email: 'yamada@example.com',
              password: 'password123',
              role: 'manager'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('山田太郎')
          expect(data['role']).to eq('manager')
        end
      end

      response '422', 'バリデーションエラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:user_params) do
          {
            user: {
              name: '',
              email: 'invalid',
              role: 'manager'
            }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:user_params) do
          {
            user: { name: 'Test', email: 'test@example.com', role: 'staff' }
          }
        end

        run_test!
      end
    end
  end

  # GET /api/tenant/users/:id - ユーザー詳細取得
  path '/api/tenant/users/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ユーザーID'

    get 'ユーザー詳細取得' do
      tags 'Tenant'
      description '指定したユーザーの詳細情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'ユーザー詳細取得成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            email: { type: :string },
            role: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'email', 'role', 'created_at', 'updated_at']

        let!(:user) { create(:tenant_user, tenant: tenant) }
        let(:id) { user.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(user.id)
          expect(data['email']).to eq(user.email)
        end
      end

      response '404', 'ユーザーが見つからない' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

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

  # PATCH /api/tenant/users/:id - ユーザー更新
  path '/api/tenant/users/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ユーザーID'

    patch 'ユーザー更新' do
      tags 'Tenant'
      description '指定したユーザーの情報を更新します。owner権限が必要です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, description: 'ユーザー名' },
              email: { type: :string, description: 'メールアドレス' },
              password: { type: :string, description: 'パスワード (8文字以上、変更する場合のみ)' },
              role: {
                type: :string,
                enum: ['owner', 'manager', 'staff', 'kitchen_staff', 'cashier'],
                description: 'ロール'
              }
            }
          }
        },
        required: ['user']
      }

      response '200', 'ユーザー更新成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            email: { type: :string },
            role: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'email', 'role', 'created_at', 'updated_at']

        let!(:user) { create(:tenant_user, tenant: tenant, name: '旧名前') }
        let(:id) { user.id }
        let(:user_params) do
          {
            user: {
              name: '新名前',
              role: 'manager'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('新名前')
          expect(data['role']).to eq('manager')
        end
      end

      response '404', 'ユーザーが見つからない' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:id) { 99999 }
        let(:user_params) do
          {
            user: { name: '新名前' }
          }
        end

        run_test!
      end

      response '422', 'バリデーションエラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let!(:user) { create(:tenant_user, tenant: tenant) }
        let(:id) { user.id }
        let(:user_params) do
          {
            user: { email: 'invalid' }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }
        let(:user_params) do
          {
            user: { name: '新名前' }
          }
        end

        run_test!
      end
    end
  end

  # DELETE /api/tenant/users/:id - ユーザー削除
  path '/api/tenant/users/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ユーザーID'

    delete 'ユーザー削除' do
      tags 'Tenant'
      description '指定したユーザーを削除します。owner権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '204', 'ユーザー削除成功' do
        let!(:user) { create(:tenant_user, tenant: tenant) }
        let(:id) { user.id }

        run_test! do
          expect(TenantUser.exists?(id)).to be false
        end
      end

      response '404', 'ユーザーが見つからない' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

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
