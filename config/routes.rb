require 'sidekiq/web'

Rails.application.routes.draw do
  resources :folders
  resources :user_feeds
  resources :permissions
  resources :src_url_subsets
  resources :src_urls
  resources :mixtapes
  resources :kernals
  resources :events
  resources :contents

  mount Sidekiq::Web, at: "/sidekiq"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users,
            controllers: {
              sessions: 'users/sessions',
              registrations: 'users/registrations'
            }
  get '/member-data', to: 'members#show'

  root to: proc { [404, {}, ["Not found."]] }
end
