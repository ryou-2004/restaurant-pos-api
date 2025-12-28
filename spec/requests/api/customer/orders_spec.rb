require 'swagger_helper'

RSpec.describe 'Api::Customer::Orders', type: :request do
  let!(:tenant) { create(:tenant) }
  let!(:store) { create(:store, tenant: tenant) }
  let!(:table) { create(:table, tenant: tenant, store: store, qr_code: 'test-qr') }
  let!(:menu_item_1) { create(:menu_item, tenant: tenant, name: 'コーヒー', price: 400) }
  let!(:menu_item_2) { create(:menu_item, tenant: tenant, name: 'ケーキ', price: 500) }

  let(:token_payload) do
    {
      table_id: table.id,
      tenant_id: tenant.id,
      store_id: store.id,
      user_type: 'customer',
      exp: 24.hours.from_now.to_i
    }
  end

  let(:token) { JsonWebToken.encode(token_payload) }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/customer/orders' do
    get '自分のテーブルの注文一覧' do
      tags '顧客注文'
      produces 'application/json'
      security [{ bearer: [] }]

      parameter name: :Authorization, in: :header, type: :string, description: 'Bearer トークン'

      response '200', '注文一覧取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   order_number: { type: :string },
                   status: { type: :string, enum: %w[pending cooking ready delivered paid] },
                   table_id: { type: :integer },
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
                   created_at: { type: :string, format: :datetime },
                   updated_at: { type: :string, format: :datetime }
                 },
                 required: %w[id order_number status table_id total_amount order_items created_at updated_at]
               }

        let!(:order_1) { create(:order, tenant: tenant, table_id: table.id, status: :pending, total_amount: 900) }
        let!(:order_item_1) { create(:order_item, order: order_1, menu_item_id: menu_item_1.id, menu_item_name: 'コーヒー', quantity: 2, unit_price: 400) }

        # 他のテーブルの注文（表示されないはず）
        let!(:other_table) { create(:table, tenant: tenant, store: store) }
        let!(:other_order) { create(:order, tenant: tenant, table_id: other_table.id, status: :pending) }

        # 支払い済みの注文（表示されないはず）
        let!(:paid_order) { create(:order, tenant: tenant, table_id: table.id, status: :paid) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(1)  # 自分のテーブルの未払い注文のみ
          expect(data[0]['id']).to eq(order_1.id)
          expect(data[0]['order_items'].length).to eq(1)
          expect(data[0]['order_items'][0]['menu_item_name']).to eq('コーヒー')
        end
      end

      response '401', '認証エラー' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:Authorization) { 'Bearer invalid-token' }

        run_test!
      end
    end

    post '注文作成' do
      tags '顧客注文'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]

      parameter name: :Authorization, in: :header, type: :string, description: 'Bearer トークン'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              notes: { type: :string, description: '注文メモ', nullable: true },
              order_items_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    menu_item_id: { type: :integer },
                    quantity: { type: :integer },
                    notes: { type: :string, nullable: true }
                  },
                  required: %w[menu_item_id quantity]
                }
              }
            },
            required: ['order_items_attributes']
          }
        },
        required: ['order']
      }

      response '201', '注文作成成功' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 order_number: { type: :string },
                 status: { type: :string },
                 table_id: { type: :integer },
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
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }

        let(:params) do
          {
            order: {
              notes: 'テーブルから注文',
              order_items_attributes: [
                { menu_item_id: menu_item_1.id, quantity: 2 },
                { menu_item_id: menu_item_2.id, quantity: 1 }
              ]
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('pending')
          expect(data['table_id']).to eq(table.id)
          expect(data['total_amount']).to eq(1300)  # 400*2 + 500*1
          expect(data['order_items'].length).to eq(2)
        end
      end

      response '422', 'バリデーションエラー' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string }
                 }
               }

        let(:params) do
          {
            order: {
              order_items_attributes: [
                { menu_item_id: 99999, quantity: 1 }  # 存在しないメニュー
              ]
            }
          }
        end

        run_test!
      end

      response '401', '認証エラー' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:Authorization) { 'Bearer invalid-token' }
        let(:params) do
          {
            order: {
              order_items_attributes: [
                { menu_item_id: menu_item_1.id, quantity: 1 }
              ]
            }
          }
        end

        run_test!
      end
    end
  end
end
