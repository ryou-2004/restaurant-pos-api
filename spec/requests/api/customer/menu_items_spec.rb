require 'swagger_helper'

RSpec.describe 'Api::Customer::MenuItems', type: :request do
  let!(:tenant) { create(:tenant) }
  let!(:store) { create(:store, tenant: tenant) }
  let!(:table) { create(:table, tenant: tenant, store: store, qr_code: 'test-qr') }

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

  path '/api/customer/menu_items' do
    get '利用可能なメニュー一覧' do
      tags '顧客メニュー'
      produces 'application/json'
      security [{ bearer: [] }]

      parameter name: :Authorization, in: :header, type: :string, description: 'Bearer トークン'

      response '200', 'メニュー一覧取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   price: { type: :integer },
                   category: { type: :string },
                   description: { type: :string, nullable: true },
                   available: { type: :boolean },
                   created_at: { type: :string, format: :datetime },
                   updated_at: { type: :string, format: :datetime }
                 },
                 required: %w[id name price category available created_at updated_at]
               }

        let!(:menu_item_1) { create(:menu_item, tenant: tenant, name: 'コーヒー', price: 400, category: 'ドリンク', available: true) }
        let!(:menu_item_2) { create(:menu_item, tenant: tenant, name: 'ケーキ', price: 500, category: 'デザート', available: true) }
        let!(:menu_item_3) { create(:menu_item, tenant: tenant, name: '季節限定', price: 600, category: 'デザート', available: false) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(2)  # available: true のみ
          expect(data.map { |item| item['name'] }).to contain_exactly('コーヒー', 'ケーキ')
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
  end
end
