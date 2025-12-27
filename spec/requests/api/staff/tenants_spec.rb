# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Staff::Tenants', type: :request do
  let(:staff_user) { create(:staff_user) }
  let(:token) { JWT.encode({ staff_user_id: staff_user.id, user_type: 'staff', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/staff/tenants' do
    get 'テナント一覧取得' do
      tags 'Staff'
      description 'テナントの一覧を取得します。スタッフ専用機能です。'
      security [{ Bearer: [] }]
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'ページ番号'

      response '200', 'テナント一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              subdomain: { type: :string },
              subscription: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  plan: {
                    type: :string,
                    enum: ['basic', 'standard', 'enterprise']
                  },
                  max_stores: { type: :integer },
                  realtime_enabled: { type: :boolean },
                  polling_enabled: { type: :boolean },
                  expires_at: { type: :string, format: 'date-time' }
                }
              },
              users_count: { type: :integer },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'name', 'subdomain', 'subscription', 'created_at', 'updated_at']
          }

        run_test!
      end

      response '401', '認証エラー' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    post 'テナント作成' do
      tags 'Staff'
      description '新しいテナントを作成します。スタッフ専用機能です。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :tenant_params, in: :body, schema: {
        type: :object,
        properties: {
          tenant: {
            type: :object,
            properties: {
              name: { type: :string, description: 'テナント名' },
              subdomain: { type: :string, description: 'サブドメイン' }
            },
            required: ['name', 'subdomain']
          }
        },
        required: ['tenant']
      }

      response '201', 'テナント作成成功' do
        let(:tenant_params) do
          {
            tenant: {
              name: 'テスト店舗',
              subdomain: 'test-shop'
            }
          }
        end

        run_test!
      end

      response '422', 'バリデーションエラー' do
        let(:tenant_params) do
          {
            tenant: {
              name: '',
              subdomain: ''
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/staff/tenants/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'テナントID'

    get 'テナント詳細取得' do
      tags 'Staff'
      description '指定したテナントの詳細情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'テナント詳細取得成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            subdomain: { type: :string },
            subscription: {
              type: :object,
              properties: {
                id: { type: :integer },
                plan: { type: :string },
                max_stores: { type: :integer },
                realtime_enabled: { type: :boolean },
                polling_enabled: { type: :boolean },
                expires_at: { type: :string, format: 'date-time' }
              }
            },
            users: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  email: { type: :string },
                  role: { type: :string }
                }
              }
            },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'name', 'subdomain', 'subscription', 'created_at', 'updated_at']

        let(:id) { create(:tenant).id }

        run_test!
      end

      response '404', 'テナントが見つからない' do
        let(:id) { 99999 }
        run_test!
      end
    end

    patch 'テナント更新' do
      tags 'Staff'
      description 'テナント情報を更新します。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :tenant_params, in: :body, schema: {
        type: :object,
        properties: {
          tenant: {
            type: :object,
            properties: {
              name: { type: :string },
              subdomain: { type: :string }
            }
          }
        },
        required: ['tenant']
      }

      response '200', 'テナント更新成功' do
        let(:id) { create(:tenant).id }
        let(:tenant_params) do
          {
            tenant: {
              name: '更新された店舗名'
            }
          }
        end

        run_test!
      end

      response '404', 'テナントが見つからない' do
        let(:id) { 99999 }
        let(:tenant_params) { { tenant: { name: '更新' } } }
        run_test!
      end
    end
  end
end
