# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Staff::Subscriptions', type: :request do
  let(:staff_user) { create(:staff_user) }
  let(:token) { JWT.encode({ staff_user_id: staff_user.id, user_type: 'staff', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/staff/subscriptions' do
    get 'サブスクリプション一覧取得' do
      tags 'Staff'
      description 'サブスクリプションの一覧を取得します。スタッフ専用機能です。'
      security [{ Bearer: [] }]
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'ページ番号'

      response '200', 'サブスクリプション一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              tenant_id: { type: :integer },
              plan: {
                type: :string,
                enum: ['basic', 'standard', 'enterprise'],
                description: 'プラン種別'
              },
              max_stores: { type: :integer, description: '最大店舗数' },
              realtime_enabled: { type: :boolean, description: 'リアルタイム機能有効' },
              polling_enabled: { type: :boolean, description: 'ポーリング機能有効' },
              expires_at: { type: :string, format: 'date-time', description: '有効期限' },
              tenant: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  subdomain: { type: :string }
                }
              },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'tenant_id', 'plan', 'max_stores', 'realtime_enabled', 'polling_enabled', 'expires_at', 'tenant', 'created_at', 'updated_at']
          }

        run_test!
      end

      response '401', '認証エラー' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/staff/subscriptions/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'サブスクリプションID'

    get 'サブスクリプション詳細取得' do
      tags 'Staff'
      description '指定したサブスクリプションの詳細情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'サブスクリプション詳細取得成功' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            tenant_id: { type: :integer },
            plan: { type: :string },
            max_stores: { type: :integer },
            realtime_enabled: { type: :boolean },
            polling_enabled: { type: :boolean },
            expires_at: { type: :string, format: 'date-time' },
            tenant: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                subdomain: { type: :string }
              }
            },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'tenant_id', 'plan', 'max_stores', 'realtime_enabled', 'polling_enabled', 'expires_at', 'tenant', 'created_at', 'updated_at']

        let(:tenant) { create(:tenant) }
        let(:id) { create(:subscription, tenant: tenant).id }

        run_test!
      end

      response '404', 'サブスクリプションが見つからない' do
        let(:id) { 99999 }
        run_test!
      end
    end

    patch 'サブスクリプション更新' do
      tags 'Staff'
      description 'サブスクリプション情報を更新します。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :subscription_params, in: :body, schema: {
        type: :object,
        properties: {
          subscription: {
            type: :object,
            properties: {
              plan: {
                type: :string,
                enum: ['basic', 'standard', 'enterprise'],
                description: 'プラン種別'
              },
              max_stores: { type: :integer, description: '最大店舗数' },
              realtime_enabled: { type: :boolean, description: 'リアルタイム機能有効' },
              polling_enabled: { type: :boolean, description: 'ポーリング機能有効' },
              expires_at: { type: :string, format: 'date-time', description: '有効期限' }
            }
          }
        },
        required: ['subscription']
      }

      response '200', 'サブスクリプション更新成功' do
        let(:tenant) { create(:tenant) }
        let(:id) { create(:subscription, tenant: tenant).id }
        let(:subscription_params) do
          {
            subscription: {
              plan: 'standard',
              max_stores: 5,
              realtime_enabled: false,
              polling_enabled: true
            }
          }
        end

        run_test!
      end

      response '404', 'サブスクリプションが見つからない' do
        let(:id) { 99999 }
        let(:subscription_params) do
          {
            subscription: {
              plan: 'standard'
            }
          }
        end

        run_test!
      end

      response '422', 'バリデーションエラー' do
        let(:tenant) { create(:tenant) }
        let(:id) { create(:subscription, tenant: tenant).id }
        let(:subscription_params) do
          {
            subscription: {
              plan: 'invalid_plan'
            }
          }
        end

        run_test!
      end
    end
  end
end
