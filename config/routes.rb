Rails.application.routes.draw do
  # ================== DEVISE (registrations + passwords) ==================
  devise_for :users, skip: [:sessions], path_names: { sign_up: 'register' }

  # ================== CUSTOMER AUTH ==================
  devise_scope :user do
    get 'login', to: 'customer/sessions#new', as: :new_user_session
    post 'login', to: 'customer/sessions#create', as: :user_session
    delete 'logout', to: 'customer/sessions#destroy', as: :destroy_user_session
  end

  # ================== VENDOR ==================
  namespace :vendor do
    get "login",  to: "sessions#new", as: :login
    post "login", to: "sessions#login"
    delete "logout", to: "sessions#destroy", as: :logout

    get  "signup", to: "sessions#sign_up", as: :signup
    post "signup", to: "sessions#create"

    get "dashboard", to: "dashboards#index"
    resources :products
    get "orders/new_orders", to: "orders#new_orders", as: :new_orders
    resources :orders, only: [:index, :show, :new, :create] do
      member do
        patch :update_status
        patch :collect_cash
        patch :confirm_online
      end
    end
    resources :customers, only: [:index, :show]
    resource :profile, only: [:show, :edit, :update]
    get "reports/daily_collection", to: "reports#daily_collection", as: :daily_collection_report
    get "invoices/:id", to: "invoices#show", as: :invoice

    # Notifications
    resources :notifications, only: [:index, :new, :create]
    get "notifications/sent", to: "notifications#sent", as: :sent_notifications
    patch "notifications/:id/read", to: "notifications#mark_as_read", as: :mark_notification_read
    patch "notifications/mark_all_read", to: "notifications#mark_all_as_read", as: :mark_all_notifications_read
  end

  # ================== ADMIN AUTH + PORTAL ==================
  devise_scope :user do
    get 'admin/login', to: 'admin/sessions#new', as: :admin_login
    post 'admin/login', to: 'admin/sessions#create'
    delete 'admin/logout', to: 'admin/sessions#destroy', as: :admin_logout
  end

  namespace :admin do
    get "dashboard", to: "dashboards#index"
    resources :workers
    resources :raw_materials
    resources :discounts
    get "reports/daily_sales", to: "reports#daily_sales", as: :daily_sales_report
    get "reports/monthly_sales", to: "reports#monthly_sales", as: :monthly_sales_report
    get "reports/product_wise", to: "reports#product_wise", as: :product_wise_report
    get "reports/customer_wise", to: "reports#customer_wise", as: :customer_wise_report
    get "reports/daily_collection", to: "reports#daily_collection", as: :daily_collection_report
    get "settings", to: "settings#edit", as: :settings
    patch "settings", to: "settings#update"
    resources :vendors, only: [:index, :show, :destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :customers, only: [:index, :show, :edit, :update, :destroy]
    resources :products
    resources :orders, only: [:index, :show] do
      member do
        patch :update_status
        patch :assign_vendor
      end
    end
    get "invoices/:id", to: "invoices#show", as: :invoice

    # Notifications
    resources :notifications, only: [:index, :new, :create]
    get "notifications/sent", to: "notifications#sent", as: :sent_notifications
    patch "notifications/:id/read", to: "notifications#mark_as_read", as: :mark_notification_read
    patch "notifications/mark_all_read", to: "notifications#mark_all_as_read", as: :mark_all_notifications_read
  end

  # ================== CUSTOMER PORTAL ==================
  namespace :customer do
    get 'dashboard', to: 'dashboards#index'
    get 'landing', to: 'landing#index'
    resources :products, only: [:index]
    resources :orders, only: [:index, :show, :new, :create] do
      member do
        patch :cancel
        get :pay
        post :review, to: 'reviews#create'
      end
    end
    get "invoices/:id", to: "invoices#show", as: :invoice
    resource :profile, only: [:show, :edit, :update]
    resources :addresses, except: [:show]

    # Notifications
    get "notifications", to: "notifications#index", as: :notifications
    patch "notifications/:id/read", to: "notifications#mark_as_read", as: :mark_notification_read
    patch "notifications/mark_all_read", to: "notifications#mark_all_as_read", as: :mark_all_notifications_read
  end

  # ================== ROOT ==================
  root "customer/landing#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
