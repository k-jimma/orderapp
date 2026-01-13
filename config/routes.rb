Rails.application.routes.draw do
  scope "t/:token", as: :table, module: :customer do
    resource :access, only: [ :new, :create, :destroy ], controller: :accesses
    resources :items, only: [ :index ]

    resource :order, only: [ :show, :create ] do
      resources :order_items, only: [ :index, :create ]
      get :complete
    end

    resources :calls, only: [ :create ]

    resource :table_status, only: [], controller: :table_statuses do
      patch :activate
    end

    resource :cart, only: [ :show ], controller: :carts do
      post :add
      patch :update_item
      delete :remove_item
      post :checkout
      delete :clear
    end
  end

  namespace :staff do
    get "/" => "dashboard#index", as: :root

    resource :password, only: [ :edit, :update ]

    resources :orders, only: [ :index, :show ] do
      post :start_billing, on: :member

      resources :order_items, only: [] do
        member do
          patch :to_cooking
          patch :to_ready
          patch :to_served
          patch :cancel
        end
      end
    end

    resources :payments, only: [ :new, :create, :show ]
    resources :calls, only: [ :index, :update ]
  end

  namespace :admin do
    get "/" => "dashboard#index", as: :root

    resource :settings, only: [ :edit, :update ]
    resources :order_histories, only: [ :index, :destroy ]
    resources :table_maintenance, only: [ :index ] do
      member do
        patch :update_number
        patch :rotate_token
        get :qr
      end
      collection do
        get :qr_bulk
      end
    end
    delete "table_maintenance/:id", to: "table_maintenance#destroy", as: :delete_table_maintenance

    resources :items
    resources :categories
    resources :tables, only: [ :index, :create, :update ] do
      post :generate_pin, on: :member
      post :generate_pin_bulk, on: :collection
      patch :activate_all, on: :collection
      patch :deactivate_all, on: :collection
    end

    resources :staffs, only: [ :index, :new, :create, :destroy ]
  end

  devise_for :users, skip: [ :registrations ], controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords"
  }
  devise_scope :user do
    get "users/request_access", to: "users/requests#new", as: :user_request_access
    post "users/guest_sign_in", to: "users/sessions#guest", as: :guest_user_session
    post "users/guest_admin_sign_in", to: "users/sessions#guest_admin", as: :guest_admin_user_session
  end

  get "portfolio/tables/:id/qr", to: "portfolio_tables#qr", as: :portfolio_table_qr

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "staff/dashboard#index"
end
