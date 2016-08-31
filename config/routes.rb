Rails.application.routes.draw do
  get 'sessions/edit'

  root to: 'static_pages#home'
  get    'signup', to: 'users#new'
  get    'login' , to: 'sessions#new'
  post   'login' , to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :users do
    member do
      get :followings
      get :followers
#      get 'page/:page', :action => :index, :on => :collection
    end
  end
  resources :users
  resources :microposts
  resources :following_relationships, only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
end