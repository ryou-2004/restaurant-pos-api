# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Store::Payments', type: :request do
  let(:tenant) { create(:tenant) }
  let(:cashier) { create(:tenant_user, :cashier, tenant: tenant) }
  let(:token) { JWT.encode({ tenant_user_id: cashier.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/store/payments' do
    get '支払い一覧取得' do
      tags 'Store'
      description '店舗の支払い一覧を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '支払い一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              order_id: { type: :integer },
              payment_method: {
                type: :string,
                enum: ['cash', 'credit_card', 'qr_code', 'other']
              },
              amount: { type: :integer },
              status: {
                type: :string,
                enum: ['pending', 'completed', 'failed']
              },
              notes: { type: :string, nullable: true },
              order: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_number: { type: :string },
                  total_amount: { type: :integer }
                }
              },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'order_id', 'payment_method', 'amount', 'status', 'order', 'created_at', 'updated_at']
          }

        run_test!
      end
    end

    post '支払い作成' do
      tags 'Store'
      description '注文に対する支払いを作成します。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :payment_params, in: :body, schema: {
        type: :object,
        properties: {
          payment: {
            type: :object,
            properties: {
              order_id: { type: :integer, description: '注文ID' },
              payment_method: {
                type: :string,
                enum: ['cash', 'credit_card', 'qr_code', 'other'],
                description: '支払い方法'
              },
              notes: { type: :string, description: 'メモ' }
            },
            required: ['order_id', 'payment_method']
          }
        },
        required: ['payment']
      }

      response '201', '支払い作成成功' do
        let(:order) { create(:order, tenant: tenant, status: :delivered) }
        let(:payment_params) do
          {
            payment: {
              order_id: order.id,
              payment_method: 'cash',
              notes: '現金支払い'
            }
          }
        end

        run_test!
      end

      response '422', '会計できない状態' do
        let(:order) { create(:order, tenant: tenant, status: :pending) }
        let(:payment_params) do
          {
            payment: {
              order_id: order.id,
              payment_method: 'cash'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/store/payments/{id}' do
    parameter name: :id, in: :path, type: :integer, description: '支払いID'

    get '支払い詳細取得' do
      tags 'Store'
      description '指定した支払いの詳細情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '支払い詳細取得成功' do
        let(:order) { create(:order, tenant: tenant) }
        let(:id) { create(:payment, tenant: tenant, order: order).id }
        run_test!
      end

      response '404', '支払いが見つからない' do
        let(:id) { 99999 }
        run_test!
      end
    end
  end

  path '/api/store/payments/{id}/complete' do
    parameter name: :id, in: :path, type: :integer, description: '支払いID'

    patch '支払い完了' do
      tags 'Store'
      description '支払いを完了します。ステータスをpending→completedに変更し、注文ステータスをpaidに変更します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '支払い完了成功' do
        let(:order) { create(:order, tenant: tenant, status: :delivered) }
        let(:id) { create(:payment, tenant: tenant, order: order, status: :pending).id }
        run_test!
      end

      response '422', '完了できない状態' do
        let(:order) { create(:order, tenant: tenant) }
        let(:id) { create(:payment, tenant: tenant, order: order, status: :completed).id }
        run_test!
      end
    end
  end
end
