Rails.application.routes.draw do
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
end
