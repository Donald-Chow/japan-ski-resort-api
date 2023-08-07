Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root to: "pages#home"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :resorts, only: %i[index show]
    end
  end
end
