require 'sidekiq/web'

Rails.application.routes.draw do
  root 'uploads#new'
  
  resources :uploads, only: %i[new create]
  resources :customers, only: %i[index]
  resources :processing_logs, only: %i[index]
  
  mount Sidekiq::Web => '/sidekiq'
end
