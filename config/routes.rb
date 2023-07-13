Rails.application.routes.draw do
  resources :source_urls
  resources :link_contents
  resources :kernals
  resources :hypertexts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
