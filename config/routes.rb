Rails.application.routes.draw do
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
  resources :campaigns, only: [:index, :create, :new, :show, :destroy] do
    resources :permissions, only: [:create]
    resources :entries, only: [:index, :show, :create, :update] do
      post 'submit', on: :collection
    end
  end

  root to: "home#show"

  get 'hello_world', to: 'hello_world#index'
end
