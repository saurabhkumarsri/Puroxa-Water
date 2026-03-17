Rails.application.routes.draw do

  namespace :customer do
    get  "login",  to: "sessions#new"
    post "login",  to: "sessions#login"
    delete "logout", to: "sessions#destroy"

    get  "signup", to: "sessions#sign_up"
    post "signup", to: "sessions#sign_up"

    get "dashboards/index"
  end


  root "customer/landing#index"

  namespace :admin do
    get "dashboards/index"
  end
  devise_for :users,
    path: 'admin',
    path_names: { sign_in: 'sign_in', sign_out: 'sign_out' },
    controllers: { sessions: 'admin/sessions' }

  get "up" => "rails/health#show", as: :rails_health_check
end
