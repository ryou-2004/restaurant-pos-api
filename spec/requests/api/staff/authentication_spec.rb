# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Staff::Authentication', type: :request do
  path '/api/staff/auth/login' do
    post 'スタッフログイン' do
      tags 'Staff'
      description 'スタッフユーザーの認証を行います。'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, description: 'メールアドレス' },
          password: { type: :string, description: 'パスワード' }
        },
        required: ['email', 'password']
      }

      response '200', 'ログイン成功' do
        schema type: :object,
          properties: {
            token: { type: :string, description: 'JWTトークン' },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' }
              }
            }
          },
          required: ['token', 'user']

        let(:staff_user) { create(:staff_user, email: 'staff@example.com', password: 'password123') }
        let(:credentials) { { email: 'staff@example.com', password: 'password123' } }

        run_test!
      end

      response '401', '認証失敗' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:credentials) { { email: 'wrong@example.com', password: 'wrongpass' } }

        run_test!
      end
    end
  end

  path '/api/staff/auth/me' do
    get '現在のスタッフユーザー情報取得' do
      tags 'Staff'
      description '認証中のスタッフユーザー情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'ユーザー情報取得成功' do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' }
              }
            }
          },
          required: ['user']

        let(:staff_user) { create(:staff_user) }
        let(:token) { JWT.encode({ staff_user_id: staff_user.id, user_type: 'staff', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
        let(:Authorization) { "Bearer #{token}" }

        run_test!
      end

      response '401', '認証エラー' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/api/staff/auth/logout' do
    post 'スタッフログアウト' do
      tags 'Staff'
      description 'スタッフユーザーのログアウトを行います。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'ログアウト成功' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }

        let(:staff_user) { create(:staff_user) }
        let(:token) { JWT.encode({ staff_user_id: staff_user.id, user_type: 'staff', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
        let(:Authorization) { "Bearer #{token}" }

        run_test!
      end
    end
  end
end
