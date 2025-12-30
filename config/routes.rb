Rails.application.routes.draw do
  # Swagger UI / OpenAPI ドキュメント
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :staff do
      post 'auth/login', to: 'authentication#login'
      get 'auth/me', to: 'authentication#me'
      post 'auth/logout', to: 'authentication#logout'

      resources :tenants, only: [:index, :show, :create, :update]
      resources :subscriptions, only: [:index, :show, :update]
    end

    namespace :tenant do
      post 'auth/login', to: 'authentication#login'
      get 'auth/me', to: 'authentication#me'
      post 'auth/logout', to: 'authentication#logout'

      resources :menu_items
      resources :users
      resources :stores
      resources :tags
      resources :tables

      resources :reports, only: [:index] do
        collection do
          get :daily
          get :monthly
          get :by_menu_item
        end
      end

      resource :subscription, only: [:show, :update]
    end

    namespace :store do
      post 'auth/login', to: 'authentication#login'
      get 'auth/me', to: 'authentication#me'
      post 'auth/logout', to: 'authentication#logout'

      resources :orders, only: [:index, :show, :create, :update] do
        member do
          patch :start_cooking
          patch :mark_as_ready
          patch :deliver
          post :print_kitchen_ticket
        end
      end

      resources :print_templates, only: [:index, :show, :update]
      resources :print_logs, only: [:index, :show, :create]

      resources :kitchen_queues, only: [:index, :show, :update] do
        member do
          patch :start
          patch :complete
        end
      end

      resources :payments, only: [:index, :show, :create] do
        member do
          patch :complete
        end
      end

      resources :menu_items, only: [:index, :show]
      resources :tables, only: [:index, :show]

      resources :table_sessions, only: [:index, :create] do
        member do
          patch :complete
        end
      end

      resources :reports, only: [] do
        collection do
          get :daily
          get :monthly
        end
      end
    end

    namespace :customer do
      post 'auth/login_via_qr', to: 'authentication#login_via_qr'
      post 'auth/logout', to: 'authentication#logout'

      resources :menu_items, only: [:index]
      resources :orders, only: [:index, :create]
    end
  end
end
