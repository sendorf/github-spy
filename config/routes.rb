Rails.application.routes.draw do
  root 'github_users#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :github_users, only: [:index, :show] do
    collection do
      post :search
      get  :list
    end
  end
end
