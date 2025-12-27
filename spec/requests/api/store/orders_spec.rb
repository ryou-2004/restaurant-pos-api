# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Store::Orders', type: :request do
  let(:tenant) { create(:tenant) }
  let(:staff_user) { create(:tenant_user, :staff, tenant: tenant) }
  let(:token) { JWT.encode({ tenant_user_id: staff_user.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/store/orders' do
    get '注文一覧取得' do
      tags 'Store'
      description '店舗の注文一覧を取得します。statusパラメータでフィルタリング可能です。'
      security [{ Bearer: [] }]
      produces 'application/json'
      parameter name: :status, in: :query, type: :string, required: false, description: '注文ステータスフィルター (pending, cooking, ready, delivered, paid)'

      response '200', '注文一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              order_number: { type: :string },
              status: {
                type: :string,
                enum: ['pending', 'cooking', 'ready', 'delivered', 'paid']
              },
              table_id: { type: :integer, nullable: true },
              total_amount: { type: :integer },
              notes: { type: :string, nullable: true },
              order_items: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    menu_item_id: { type: :integer },
                    menu_item_name: { type: :string },
                    quantity: { type: :integer },
                    unit_price: { type: :integer },
                    subtotal: { type: :integer },
                    notes: { type: :string, nullable: true }
                  }
                }
              },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'order_number', 'status', 'total_amount', 'order_items', 'created_at', 'updated_at']
          }

        run_test!
      end
    end

    post '注文作成' do
      tags 'Store'
      description '新しい注文を作成します。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :order_params, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              table_id: { type: :integer },
              notes: { type: :string },
              order_items_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    menu_item_id: { type: :integer },
                    quantity: { type: :integer },
                    notes: { type: :string }
                  },
                  required: ['menu_item_id', 'quantity']
                }
              }
            },
            required: ['order_items_attributes']
          }
        },
        required: ['order']
      }

      response '201', '注文作成成功' do
        let(:menu_item) { create(:menu_item, tenant: tenant, price: 1000) }
        let(:order_params) do
          {
            order: {
              table_id: 1,
              notes: 'テスト注文',
              order_items_attributes: [
                { menu_item_id: menu_item.id, quantity: 2 }
              ]
            }
          }
        end

        run_test!
      end

      response '422', 'バリデーションエラー' do
        let(:order_params) { { order: { order_items_attributes: [] } } }
        run_test!
      end
    end
  end

  path '/api/store/orders/{id}' do
    parameter name: :id, in: :path, type: :integer, description: '注文ID'

    get '注文詳細取得' do
      tags 'Store'
      description '指定した注文の詳細情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '注文詳細取得成功' do
        let(:id) { create(:order, tenant: tenant).id }
        run_test!
      end

      response '404', '注文が見つからない' do
        let(:id) { 99999 }
        run_test!
      end
    end

    patch '注文更新' do
      tags 'Store'
      description '指定した注文の情報を更新します。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :order_params, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              table_id: { type: :integer },
              notes: { type: :string }
            }
          }
        },
        required: ['order']
      }

      response '200', '注文更新成功' do
        let(:id) { create(:order, tenant: tenant).id }
        let(:order_params) { { order: { notes: '更新されたメモ' } } }
        run_test!
      end

      response '404', '注文が見つからない' do
        let(:id) { 99999 }
        let(:order_params) { { order: { notes: '更新' } } }
        run_test!
      end
    end
  end

  path '/api/store/orders/{id}/start_cooking' do
    parameter name: :id, in: :path, type: :integer, description: '注文ID'

    patch '調理開始' do
      tags 'Store'
      description '注文の調理を開始します。ステータスをpending→cookingに変更します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '調理開始成功' do
        let(:id) { create(:order, tenant: tenant, status: :pending).id }
        run_test!
      end

      response '422', '調理開始できない状態' do
        let(:id) { create(:order, tenant: tenant, status: :cooking).id }
        run_test!
      end
    end
  end

  path '/api/store/orders/{id}/mark_as_ready' do
    parameter name: :id, in: :path, type: :integer, description: '注文ID'

    patch '調理完了' do
      tags 'Store'
      description '注文の調理を完了します。ステータスをcooking→readyに変更します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '調理完了成功' do
        let(:id) { create(:order, tenant: tenant, status: :cooking).id }
        run_test!
      end

      response '422', '調理完了にできない状態' do
        let(:id) { create(:order, tenant: tenant, status: :pending).id }
        run_test!
      end
    end
  end

  path '/api/store/orders/{id}/deliver' do
    parameter name: :id, in: :path, type: :integer, description: '注文ID'

    patch '配膳完了' do
      tags 'Store'
      description '注文の配膳を完了します。ステータスをready→deliveredに変更します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '配膳完了成功' do
        let(:id) { create(:order, tenant: tenant, status: :ready).id }
        run_test!
      end

      response '422', '配膳できない状態' do
        let(:id) { create(:order, tenant: tenant, status: :pending).id }
        run_test!
      end
    end
  end
end
