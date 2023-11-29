require 'sidekiq/web'

Rails.application.routes.draw do
  resources :src_url_subsets
  resources :src_urls
  resources :mixtapes
  resources :source_urls
  resources :link_contents
  resources :kernals
  resources :hypertexts

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users,
            controllers: {
              sessions: 'users/sessions',
              registrations: 'users/registrations'
            }
  get '/member-data', to: 'members#show'
  # Defines the root path route ("/")
  # root "articles#index"
 
  # sidekiq
  resources :events
  mount Sidekiq::Web => '/sidekiq'
  root to: proc { [404, {}, ["Not found."]] }
end
