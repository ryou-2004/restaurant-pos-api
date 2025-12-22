Rails.application.routes.draw do
  # ========================================
  # ヘルスチェック
  # ========================================
  get "up" => "rails/health#show", as: :rails_health_check

  # ========================================
  # API
  # ========================================
  namespace :api do
    # 認証関連
    post 'auth/login', to: 'authentication#login'
    get 'auth/me', to: 'authentication#me'
    post 'auth/logout', to: 'authentication#logout'

    # メニュー項目
    resources :menu_items, only: [:index, :show, :create, :update, :destroy]

    # 注文管理
    resources :orders, only: [:index, :show, :create, :update, :destroy] do
      member do
        patch :start_cooking
        patch :mark_as_ready
        patch :deliver
      end
    end

    # 厨房キュー
    resources :kitchen_queues, only: [:index, :show, :update] do
      member do
        patch :start_cooking
        patch :complete
      end
    end

    # 会計
    resources :payments, only: [:index, :show, :create, :update] do
      member do
        patch :complete
      end
    end
  end
end
