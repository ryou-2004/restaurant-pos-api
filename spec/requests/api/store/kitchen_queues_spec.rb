# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::Store::KitchenQueues', type: :request do
  let(:tenant) { create(:tenant) }
  let(:kitchen_staff) { create(:tenant_user, :kitchen_staff, tenant: tenant) }
  let(:token) { JWT.encode({ tenant_user_id: kitchen_staff.id, user_type: 'tenant', exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256') }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/store/kitchen_queues' do
    get '厨房キュー一覧取得' do
      tags 'Store'
      description '厨房の調理キュー一覧を取得します。アクティブなキューのみを優先度順に返します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'キュー一覧取得成功' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              order_id: { type: :integer },
              status: {
                type: :string,
                enum: ['waiting', 'in_progress', 'completed']
              },
              priority: { type: :integer },
              notes: { type: :string, nullable: true },
              order: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_number: { type: :string },
                  order_items: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        id: { type: :integer },
                        menu_item_name: { type: :string },
                        quantity: { type: :integer },
                        notes: { type: :string, nullable: true }
                      }
                    }
                  }
                }
              },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'order_id', 'status', 'priority', 'order', 'created_at', 'updated_at']
          }

        run_test!
      end
    end
  end

  path '/api/store/kitchen_queues/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'キューID'

    get 'キュー詳細取得' do
      tags 'Store'
      description '指定したキューの詳細情報を取得します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', 'キュー詳細取得成功' do
        let(:order) { create(:order, tenant: tenant) }
        let(:id) { create(:kitchen_queue, tenant: tenant, order: order).id }
        run_test!
      end

      response '404', 'キューが見つからない' do
        let(:id) { 99999 }
        run_test!
      end
    end

    patch 'キュー更新' do
      tags 'Store'
      description 'キューの情報（優先度、メモ）を更新します。'
      security [{ Bearer: [] }]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :kitchen_queue_params, in: :body, schema: {
        type: :object,
        properties: {
          kitchen_queue: {
            type: :object,
            properties: {
              priority: { type: :integer },
              notes: { type: :string }
            }
          }
        },
        required: ['kitchen_queue']
      }

      response '200', 'キュー更新成功' do
        let(:order) { create(:order, tenant: tenant) }
        let(:id) { create(:kitchen_queue, tenant: tenant, order: order).id }
        let(:kitchen_queue_params) { { kitchen_queue: { priority: 10, notes: '急ぎ対応' } } }
        run_test!
      end

      response '404', 'キューが見つからない' do
        let(:id) { 99999 }
        let(:kitchen_queue_params) { { kitchen_queue: { priority: 10 } } }
        run_test!
      end
    end
  end

  path '/api/store/kitchen_queues/{id}/start' do
    parameter name: :id, in: :path, type: :integer, description: 'キューID'

    patch '調理開始' do
      tags 'Store'
      description 'キューの調理を開始します。ステータスをwaiting→in_progressに変更します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '調理開始成功' do
        let(:order) { create(:order, tenant: tenant) }
        let(:id) { create(:kitchen_queue, tenant: tenant, order: order, status: :waiting).id }
        run_test!
      end

      response '422', '調理開始できない状態' do
        let(:order) { create(:order, tenant: tenant) }
        let(:id) { create(:kitchen_queue, tenant: tenant, order: order, status: :in_progress).id }
        run_test!
      end
    end
  end

  path '/api/store/kitchen_queues/{id}/complete' do
    parameter name: :id, in: :path, type: :integer, description: 'キューID'

    patch '調理完了' do
      tags 'Store'
      description 'キューの調理を完了します。ステータスをin_progress→completedに変更します。'
      security [{ Bearer: [] }]
      produces 'application/json'

      response '200', '調理完了成功' do
        let(:order) { create(:order, tenant: tenant) }
        let(:id) { create(:kitchen_queue, tenant: tenant, order: order, status: :in_progress).id }
        run_test!
      end

      response '422', '完了できない状態' do
        let(:order) { create(:order, tenant: tenant) }
        let(:id) { create(:kitchen_queue, tenant: tenant, order: order, status: :waiting).id }
        run_test!
      end
    end
  end
end
