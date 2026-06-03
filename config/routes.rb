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
    resources :orders, only: [:index, :show] do
      member { patch :update_status }
    end
    resource :profile, only: [:show, :edit, :update]
  end

  # ================== ADMIN AUTH + PORTAL ==================
  devise_scope :user do
    get 'admin/login', to: 'admin/sessions#new', as: :admin_login
    post 'admin/login', to: 'admin/sessions#create'
    delete 'admin/logout', to: 'admin/sessions#destroy', as: :admin_logout
  end

  namespace :admin do
    get "dashboard", to: "dashboards#index"
    resources :vendors, only: [:index, :show, :destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :customers, only: [:index, :show, :edit, :update, :destroy]
    resources :subadmins
    resources :products
    resources :orders, only: [:index, :show] do
      member do
        patch :update_status
        patch :assign_vendor
      end
    end
  end

  # ================== SUBADMIN AUTH + PORTAL ==================
  devise_scope :user do
    get 'subadmin/login', to: 'subadmin/sessions#new', as: :subadmin_login
    post 'subadmin/login', to: 'subadmin/sessions#create'
    delete 'subadmin/logout', to: 'subadmin/sessions#destroy', as: :subadmin_logout
  end

  namespace :subadmin do
    get "dashboard", to: "dashboards#index"
    resources :orders, only: [:index, :show] do
      member do
        patch :update_status
        patch :assign_vendor
      end
    end
    resources :customers, only: [:index, :show]
    resources :vendors, only: [:index, :show]
  end

  # ================== CUSTOMER PORTAL ==================
  namespace :customer do
    get 'dashboard', to: 'dashboards#index'
    get 'landing', to: 'landing#index'
    resources :products, only: [:index]
    resources :orders, only: [:index, :show, :new, :create] do
      member { patch :cancel }
    end
    resource :profile, only: [:show, :edit, :update]
    resources :addresses, except: [:show]
  end

  # ================== ROOT ==================
  root "customer/landing#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
