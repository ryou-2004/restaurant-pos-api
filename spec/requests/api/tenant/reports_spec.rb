# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Tenant::Reports', type: :request do
  let(:tenant) { create(:tenant) }
  let(:manager_user) { create(:tenant_user, :manager, tenant: tenant) }
  let(:token) { JWT.encode({ tenant_user_id: manager_user.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/tenant/reports/daily' do
    get '日次売上レポート' do
      tags 'Tenant'
      description '指定日の売上レポートを取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'
      parameter name: :date, in: :query, type: :string, required: false, description: '日付 (YYYY-MM-DD形式、省略時は今日)'

      response '200', '日次レポート取得成功' do
        schema type: :object,
          properties: {
            date: { type: :string },
            total_orders: { type: :integer },
            total_amount: { type: :integer },
            active_orders: { type: :integer },
            orders: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_number: { type: :string },
                  total_amount: { type: :integer },
                  created_at: { type: :string, format: 'date-time' }
                }
              }
            }
          }

        run_test!
      end
    end
  end

  path '/api/tenant/reports/monthly' do
    get '月次売上レポート' do
      tags 'Tenant'
      description '指定月の売上レポートを取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'
      parameter name: :year, in: :query, type: :integer, required: false, description: '年 (省略時は今年)'
      parameter name: :month, in: :query, type: :integer, required: false, description: '月 (省略時は今月)'

      response '200', '月次レポート取得成功' do
        schema type: :object,
          properties: {
            year: { type: :integer },
            month: { type: :integer },
            total_orders: { type: :integer },
            total_amount: { type: :integer },
            daily_breakdown: {
              type: :object,
              additionalProperties: {
                type: :object,
                properties: {
                  total_orders: { type: :integer },
                  total_amount: { type: :integer }
                }
              }
            }
          }

        run_test!
      end
    end
  end

  path '/api/tenant/reports/by_menu_item' do
    get 'メニュー別売上レポート' do
      tags 'Tenant'
      description 'メニュー項目別の売上を取得します。manager以上の権限が必要です。'
      security [{ Bearer: [] }]
      produces 'application/json'
      parameter name: :start_date, in: :query, type: :string, required: false, description: '開始日 (YYYY-MM-DD形式、省略時は1ヶ月前)'
      parameter name: :end_date, in: :query, type: :string, required: false, description: '終了日 (YYYY-MM-DD形式、省略時は今日)'

      response '200', 'メニュー別レポート取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              menu_item_id: { type: :integer },
              menu_item_name: { type: :string },
              total_quantity: { type: :integer },
              total_sales: { type: :integer }
            }
          }

        run_test!
      end
    end
  end
end
