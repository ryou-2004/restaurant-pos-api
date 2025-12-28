require 'swagger_helper'

RSpec.describe 'Api::Customer::Authentication', type: :request do
  path '/api/customer/auth/login_via_qr' do
    post 'QRコードでログイン' do
      tags '顧客認証'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          qr_code: { type: :string, description: 'テーブルのQRコード' }
        },
        required: ['qr_code']
      }

      response '200', 'ログイン成功' do
        schema type: :object,
               properties: {
                 token: { type: :string, description: 'JWT認証トークン' },
                 session: {
                   type: :object,
                   properties: {
                     table_id: { type: :integer },
                     table_number: { type: :string },
                     store_id: { type: :integer },
                     store_name: { type: :string },
                     tenant_id: { type: :integer },
                     tenant_name: { type: :string }
                   }
                 }
               },
               required: ['token', 'session']

        let!(:tenant) { create(:tenant, name: 'デモカフェ') }
        let!(:store) { create(:store, tenant: tenant, name: 'デモカフェ本店') }
        let!(:table) { create(:table, tenant: tenant, store: store, number: 'T1', status: :available) }
        let(:params) { { qr_code: table.qr_code } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['token']).to be_present
          expect(data['session']['table_id']).to eq(table.id)
          expect(data['session']['table_number']).to eq('T1')
          expect(data['session']['store_name']).to eq('デモカフェ本店')
          expect(data['session']['tenant_name']).to eq('デモカフェ')

          # テーブルがoccupiedになっていることを確認
          expect(table.reload.status).to eq('occupied')
        end
      end

      response '400', 'QRコード未指定' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:params) { { qr_code: '' } }

        run_test!
      end

      response '404', 'QRコード無効' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:params) { { qr_code: 'invalid-qr-code' } }

        run_test!
      end

      response '403', 'テーブル使用不可' do
        schema type: :object,
               properties: {
                 error: { type: :string },
                 table_status: { type: :string }
               }

        let!(:tenant) { create(:tenant) }
        let!(:store) { create(:store, tenant: tenant) }
        let!(:table) { create(:table, tenant: tenant, store: store, status: :occupied) }
        let(:params) { { qr_code: table.qr_code } }

        run_test!
      end
    end
  end

  path '/api/customer/auth/logout' do
    post 'ログアウト' do
      tags '顧客認証'
      produces 'application/json'

      response '200', 'ログアウト成功' do
        schema type: :object,
               properties: {
                 message: { type: :string }
               }

        run_test!
      end
    end
  end
end
