Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root 'products#index'

  resources :products, only: [:index, :create] do
    collection do
      get :statistics
    end
  end
end
