Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    post 'auth/login', to: 'authentication#login'
    get 'auth/me', to: 'authentication#me'
    post 'auth/logout', to: 'authentication#logout'

    namespace :staff do
      resources :orders, only: [:index, :show, :create, :update] do
        member do
          patch :start_cooking
          patch :mark_as_ready
          patch :deliver
        end
      end

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
    end

    namespace :admin do
      resources :menu_items
      resources :users do
        member do
          patch :activate
          patch :deactivate
        end
      end

      resources :reports, only: [:index] do
        collection do
          get :daily
          get :monthly
          get :by_menu_item
        end
      end

      resource :subscription, only: [:show, :update]
    end
  end
end
