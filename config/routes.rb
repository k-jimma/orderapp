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

    resources :items
    resources :categories
    resources :tables, only: [ :index, :create, :update ] do
      post :generate_pin, on: :member
      post :generate_pin_bulk, on: :collection
      patch :activate_all, on: :collection
    end

    resources :staffs, only: [ :index, :new, :create, :destroy ]
  end

  devise_for :users, skip: [ :registrations ], controllers: { sessions: "users/sessions" }
  devise_scope :user do
    post "users/guest_sign_in", to: "users/sessions#guest", as: :guest_user_session
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "staff/dashboard#index"
end
