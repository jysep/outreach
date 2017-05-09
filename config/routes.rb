Rails.application.routes.draw do
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
  resources :campaigns, only: [:index, :create, :new, :show, :destroy] do
    resources :permissions, only: [:create]
    resources :entries, only: [:index] do
      post 'submit', on: :collection
    end
    get 'export', on: :member
  end
  resources :entries, only: [:show, :update, :edit]

  root to: "home#show"

  get 'hello_world', to: 'hello_world#index'
end
